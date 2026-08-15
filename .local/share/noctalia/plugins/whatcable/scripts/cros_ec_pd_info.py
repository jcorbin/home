#!/usr/bin/env python3
"""Per-port USB-PD power info from a Chrome EC, as JSON on stdout.

Port of whatcable-linux's src/whatcable_linux/chrome_ec.py. This is the one
part of the scan that a Luau plugin cannot do itself: it needs an ioctl on
/dev/cros_ec, not a sysfs read. Everything else lives in lib/scan.luau.

The device is opened read-only and only EC_CMD_USB_PD_POWER_INFO is issued; no
arbitrary EC command is exposed. Stdlib only, and it never exits non-zero for a
missing or unreadable device — the JSON's "access" field carries that instead,
so the plugin can say *why* the figures are unavailable.
"""

from __future__ import annotations

import fcntl
import json
import struct
import sys
from pathlib import Path

CROS_EC_COMMAND_HEADER = struct.Struct("=IIIII")
USB_PD_POWER_INFO_RESPONSE = struct.Struct("<BBBBHHHHI")
EC_CMD_USB_PD_POWER_INFO = 0x0103
EC_RESPONSE_SUCCESS = 0
EC_RESPONSE_INVALID_COMMAND = 1
EC_RESPONSE_INVALID_PARAM = 3
EC_MAX_PORTS = 4

ROLE_LABELS = {
    0: "Disconnected",
    1: "Source",
    2: "Sink",
    3: "Sink, not charging",
}

CHARGING_TYPE_LABELS = {
    0: "None",
    1: "USB PD",
    2: "USB Type-C",
    3: "Proprietary",
    4: "BC 1.2 DCP",
    5: "BC 1.2 CDP",
    6: "BC 1.2 SDP",
    7: "Other",
    8: "VBUS",
    9: "Unknown",
}

# Framework's port order, front to back on each side.
FRAMEWORK_PORT_LOCATIONS = {
    0: "Right back",
    1: "Right front",
    2: "Left front",
    3: "Left back",
}


class ChromeEcError(Exception):
    pass


class ChromeEcResponseError(ChromeEcError):
    def __init__(self, result: int) -> None:
        self.result = result
        super().__init__(f"EC response code {result}")


def _cros_ec_command_ioctl() -> int:
    # Linux _IOWR(0xEC, 0, struct cros_ec_command), whose fixed header is 20 bytes.
    read_write = 3
    return (read_write << 30) | (CROS_EC_COMMAND_HEADER.size << 16) | (0xEC << 8)


def _volts(millivolts: int) -> str:
    return f"{millivolts / 1000:g} V"


def _amps(milliamps: int) -> str:
    return f"{milliamps / 1000:g} A"


def _watts(milliwatts: int) -> str:
    return f"{milliwatts / 1000:g} W"


def _read_pd_power_info(device, port: int):
    response_size = USB_PD_POWER_INFO_RESPONSE.size
    buffer = bytearray(CROS_EC_COMMAND_HEADER.size + response_size)
    CROS_EC_COMMAND_HEADER.pack_into(
        buffer, 0, 0, EC_CMD_USB_PD_POWER_INFO, 1, response_size, 0xFF
    )
    buffer[CROS_EC_COMMAND_HEADER.size] = port

    returned_size = fcntl.ioctl(device.fileno(), _cros_ec_command_ioctl(), buffer, True)
    *_unused, result = CROS_EC_COMMAND_HEADER.unpack_from(buffer)
    if result != EC_RESPONSE_SUCCESS:
        raise ChromeEcResponseError(result)
    if returned_size < response_size:
        raise ChromeEcError(
            f"short EC response: expected {response_size} bytes, received {returned_size}"
        )
    return USB_PD_POWER_INFO_RESPONSE.unpack_from(buffer, CROS_EC_COMMAND_HEADER.size)


def _port_summary(
    location: str,
    role: str,
    charging_type: str,
    voltage_mv: int,
    current_ma: int,
    max_power_mw: int,
) -> str:
    if role == "Disconnected":
        return f"{location} · Disconnected"
    bits = [location, role]
    if charging_type != "None":
        bits.append(charging_type)
    if voltage_mv and current_ma:
        bits.append(f"{_volts(voltage_mv)}, {_amps(current_ma)}")
    elif voltage_mv:
        bits.append(_volts(voltage_mv))
    elif current_ma:
        bits.append(_amps(current_ma))
    if max_power_mw:
        bits.append(f"up to {_watts(max_power_mw)}")
    return " · ".join(bits)


def _port_device(port: int, device_path: Path, values, is_framework: bool) -> dict:
    (
        role,
        charging_type,
        dual_role,
        _reserved,
        voltage_max_mv,
        voltage_now_mv,
        current_max_ma,
        current_limit_ma,
        max_power_uw,
    ) = values
    role_label = ROLE_LABELS.get(role, f"Unknown ({role})")
    charging_label = CHARGING_TYPE_LABELS.get(charging_type, f"Unknown ({charging_type})")
    location = (
        FRAMEWORK_PORT_LOCATIONS.get(port, f"Port {port}") if is_framework else f"Port {port}"
    )
    max_power_mw = max_power_uw // 1000

    return {
        "source": "Framework EC" if is_framework else "Chrome EC",
        "name": f"port{port}",
        "sysfsPath": str(device_path),
        "summary": _port_summary(
            location, role_label, charging_label, voltage_now_mv, current_limit_ma, max_power_mw
        ),
        "properties": {
            "location": location,
            "role": role_label,
            "charging_type": charging_label,
            "dual_role": "Yes" if dual_role else "No",
            "voltage_now": _volts(voltage_now_mv),
            "voltage_max": _volts(voltage_max_mv),
            "current_limit": _amps(current_limit_ma),
            "current_max": _amps(current_max_ma),
            "max_power": _watts(max_power_mw),
        },
        # Numbers the UI can compute with, alongside the labels above.
        "values": {
            "role": role,
            "charging_type": charging_type,
            "dual_role": bool(dual_role),
            "voltage_max_mv": voltage_max_mv,
            "voltage_now_mv": voltage_now_mv,
            "current_max_ma": current_max_ma,
            "current_limit_ma": current_limit_ma,
            "max_power_mw": max_power_mw,
        },
    }


def scan(device_path: Path, dmi_root: Path) -> dict:
    is_framework = _read_text(dmi_root / "sys_vendor").startswith("Framework")
    ports: list[dict] = []

    try:
        with device_path.open("rb", buffering=0) as device:
            for port in range(EC_MAX_PORTS):
                try:
                    values = _read_pd_power_info(device, port)
                except ChromeEcResponseError as error:
                    # An out-of-range port is how the EC reports "that's all".
                    if error.result in {EC_RESPONSE_INVALID_COMMAND, EC_RESPONSE_INVALID_PARAM}:
                        break
                    continue
                except (ChromeEcError, OSError):
                    break
                ports.append(_port_device(port, device_path, values, is_framework))
        access = "Available"
    except FileNotFoundError:
        access = "Device not exposed"
    except PermissionError:
        access = "Permission denied"
    except OSError as error:
        access = f"Unavailable: {error.strerror or error}"

    return {
        "ok": access == "Available",
        "access": access,
        "framework": is_framework,
        "devicePath": str(device_path),
        "ports": ports,
    }


def _read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8").strip()
    except (OSError, UnicodeDecodeError):
        return ""


def main(argv: list[str]) -> int:
    device_path = Path(argv[1]) if len(argv) > 1 else Path("/dev/cros_ec")
    dmi_root = Path(argv[2]) if len(argv) > 2 else Path("/sys/class/dmi/id")
    json.dump(scan(device_path, dmi_root), sys.stdout)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
