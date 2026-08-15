# WhatCable — noctalia v5 plugin

USB-C port, cable e-marker and USB Power Delivery diagnostics on the bar.

A port of [nedrichards/whatcable-linux](https://github.com/nedrichards/whatcable-linux)
(GTK4/libadwaita + Python, itself a Linux reimplementation of
[darrylmorley/whatcable](https://github.com/darrylmorley/whatcable) for macOS).
The upstream app's scanning and summarising logic is reimplemented in Luau;
the wording of every summary line is kept verbatim, so a panel row says what
the GTK app's row says.

## What it reads

Same sources as upstream, all read-only and non-privileged:

| Source | What it gives |
| --- | --- |
| `/sys/class/typec` | ports, partners, cables, plugs, roles, alt modes, identity VDOs |
| `/sys/class/usb_power_delivery` | advertised source PDOs (fixed, variable, battery, PPS, adjustable) |
| `/sys/class/chromeos/cros_ec/version` | EC firmware metadata |
| `/dev/cros_ec` (ioctl) | on Framework: per-port role, charging type, voltage, current, max power |
| `/sys/bus/usb/devices` | the USB device tree (optional, off by default) |
| `/sys/bus/thunderbolt`, `/sys/bus/usb4` | Thunderbolt/USB4 devices (optional, off by default) |
| `/sys/kernel/debug/usb/devices` | debugfs dump when readable (normally root-only) |

What you actually see depends on your machine's Type-C/PD driver. If firmware
negotiates PD without exposing identity and capability data to the kernel, both
sysfs classes exist but are empty, and the embedded controller is the only
source left — the panel says so rather than showing an empty list.

## Layout

    plugin.toml                    manifest: settings, service, widget, panel
    service.luau                   the entire scanner + summariser
    widget.luau                    bar item (glyph, power/port text, tooltip)
    panel.luau                     detail view
    scripts/cros_ec_pd_info.py     Chrome EC ioctl helper
    tests/run.lua                  fixture + live tests
    translations/en.json

Two structural notes, both forced by the runtime:

- **Everything is in `service.luau`.** noctalia v5.0.0-beta.3's Luau host has no
  `require` (it landed on `main` after that tag), so an entry cannot pull in a
  sibling script. The service is the only entry that needs the scanning code —
  it precomputes every label and publishes one report to plugin state, and the
  widget and panel are pure presentation over that state. If a future noctalia
  gains `require`, this can be split back into `lib/pd.luau`, `lib/scan.luau`
  and `lib/summary.luau` along the section banners already in the file.
- **The EC query stayed in Python.** A Luau plugin can read sysfs but cannot
  issue an ioctl, and `EC_CMD_USB_PD_POWER_INFO` on `/dev/cros_ec` is an ioctl.
  `scripts/cros_ec_pd_info.py` is a direct port of upstream's `chrome_ec.py`,
  stdlib only, opens the device read-only, and issues no other EC command.

One deliberate behavioural difference from upstream: upstream walks
`/sys/class/usb_power_delivery` and maps each `pd` device back to its port by
resolving the symlink. Luau has no `realpath`, so this reads the capabilities
from the port and partner devices instead — the same data reached from the
other end. A single-port machine falls back to the class walk if that finds
nothing.

## Framework laptops: `/dev/cros_ec` permissions

The device is `root`-only by default, so the per-port power figures are
unavailable until you grant read access. The panel's FIRMWARE section says
`PD power info: Permission denied` when that is the case.

One-off (resets when the device is recreated):

```sh
sudo setfacl -m "u:$USER:r" /dev/cros_ec
```

Persistent, via udev:

```sh
# /etc/udev/rules.d/01-cros-ec.rules
SUBSYSTEM=="misc", KERNEL=="cros_ec", TAG+="uaccess"
```

then `sudo udevadm control --reload && sudo udevadm trigger`.

`uaccess` hands the device to whoever holds the active local seat session,
via a logind ACL that is dropped when the session ends — narrower in the
dimension that matters than a static `GROUP=`, which would apply to every
member all the time. **The file must sort before `73-seat-late.rules`**, which
is what consumes the tag; a `99-` prefix would be applied too late to do
anything. `/etc/udev/rules.d` is admin territory that pacman never writes to,
so the rule survives upgrades.

Note that the mode is not a security boundary here: `cros_ec_chardev_ioctl`
performs no `f_mode` or capability check, so anything that can open the node at
all can issue arbitrary EC commands, read-only fd or not. The question is who
gets to open it, not with which mode.

Without access the plugin still shows the readable EC firmware metadata and
whatever the Type-C sysfs classes expose; only the per-port voltage/current/
power rows go missing. Turn the query off entirely with the **Query the
Chrome/Framework EC** setting if you would rather not run the helper.

## Settings

| Setting | Default | Notes |
| --- | --- | --- |
| Refresh interval | 10 s | sysfs rescan + EC helper cadence |
| Query the Chrome/Framework EC | on | runs `scripts/cros_ec_pd_info.py` |
| Show Thunderbolt / USB4 devices | off | extra panel section |
| Show USB devices | off | extra panel section; the full device tree is long |
| Include USB root hubs | off | only when the USB section is on |
| Bar icon | `plug-connected` | |
| Bar text | negotiated power | or connected-port count, or icon only |

The bar prefers the EC's negotiated figure over a charger's advertised
capability — those are different quantities, and the advertisement is only a
ceiling. The tooltip shows both when both are known.

## Install

The plugin lives in `$XDG_DATA_HOME/noctalia/plugins/whatcable` (v5 requires
local plugins there), and is tracked in place from `$HOME` via a `!` rule in
`.gitignore`. Enable it with:

```sh
noctalia msg plugins enable jcorbin/whatcable
```

Then add `"jcorbin/whatcable:indicator"` to a bar section in
`~/.local/state/noctalia/settings.toml` and `noctalia msg config-reload`.
The panel can also be opened without the bar item:

```sh
noctalia msg plugin jcorbin/whatcable:indicator focused toggle
```

## Tests

```sh
lua5.4 tests/run.lua           # fixture tree
lua5.4 tests/run.lua --live    # plus a scan of this machine's real sysfs
noctalia plugins lint .        # manifest vs. getConfig cross-check
```

`service.luau` keeps all filesystem access behind an injectable `fs` table and
publishes its internals on `WHATCABLE_INTERNALS`, so plain Lua 5.4 can load it
and drive the scanners against a fixture. The harness shims `bit32` (dropped in
Lua 5.3) and the `noctalia` global; neither shim changes the semantics the
plugin runs under.

## License

GPL-3.0-or-later, following upstream.
