-- tests/run.lua — exercises the ported logic outside noctalia.
--
--   lua5.4 tests/run.lua            # fixture tree
--   lua5.4 tests/run.lua --live     # plus a scan of this machine's real sysfs
--
-- service.luau keeps all filesystem access behind an injectable `fs` table and
-- publishes its internals on WHATCABLE_INTERNALS, so a plain Lua interpreter
-- can load it and drive the scanners against a fixture. Lua 5.4 dropped bit32
-- and has no `noctalia` global; both are shimmed below, and neither shim
-- changes the semantics the plugin runs under.

local here = (arg[0]:match("^(.*)/[^/]*$") or ".")

_G.bit32 = _G.bit32 or {
  band = function(a, b) return a & b end,
  rshift = function(a, n) return a >> n end,
}

-- Only what loading service.luau touches at chunk scope; nothing here is called
-- by the code under test.
_G.noctalia = {
  readFile = function() return nil end,
  listDir = function() return nil end,
  fileExists = function() return false end,
  fileInfo = function() return nil end,
  getConfig = function() return nil end,
  pluginDir = function() return here .. "/.." end,
  setUpdateInterval = function() end,
  runAsync = function() end,
  state = { set = function() end, get = function() return nil end, watch = function() end },
  json = { decode = function() error("unused") end },
  string = { trim = function(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end },
}

assert(loadfile(here .. "/../service.luau"))()
local W = _G.WHATCABLE_INTERNALS

-- ── tiny assertion harness ───────────────────────────────────────────────────

local failures, checks = 0, 0

local function check(label, got, want)
  checks = checks + 1
  if got ~= want then
    failures = failures + 1
    print(string.format("FAIL %s\n  got:  %s\n  want: %s", label, tostring(got), tostring(want)))
  end
end

-- ── fixture sysfs tree ───────────────────────────────────────────────────────
--
-- Modelled on a laptop sinking from a 100 W charger over an e-marked 5 A cable:
-- port0 has a partner advertising five PDOs, a cable with an active-cable VDO,
-- and a DisplayPort alt mode. port1 is empty.

local FILES = {
  ["/typec/port0/data_role"] = "[host] device",
  ["/typec/port0/power_role"] = "source [sink]",
  ["/typec/port0/port_type"] = "[dual]",
  ["/typec/port0/usb_power_delivery_revision"] = "3.0",

  ["/typec/port0-partner/supports_usb_power_delivery"] = "yes",
  ["/typec/port0-partner/identity/id_header"] = "0xd00002e0",
  ["/typec/port0-partner/identity/product"] = "0x01000001",
  ["/typec/port0-partner/port0-partner.0/svid"] = "ff01",
  ["/typec/port0-partner/port0-partner.0/mode"] = "1",
  ["/typec/port0-partner/port0-partner.0/description"] = "DisplayPort",

  ["/typec/port0-cable/active"] = "yes",
  -- product type 4 (active cable) in the UFP field, vendor 0x04b4
  ["/typec/port0-cable/identity/id_header"] = "0x200004b4",
  -- speed bits 3 (USB4 Gen 3), current bits 2 (5 A), max voltage 1 (30 V)
  ["/typec/port0-cable/identity/product_type_vdo1"] = "0x00000253",

  ["/typec/port1/data_role"] = "[host] device",
  ["/typec/port1/power_role"] = "[source] sink",

  -- Source capabilities hang off the partner: the charger is the source.
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/1:fixed_supply/voltage"] = "5000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/1:fixed_supply/maximum_current"] = "3000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/2:fixed_supply/voltage"] = "9000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/2:fixed_supply/maximum_current"] = "3000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/3:fixed_supply/voltage"] = "20000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/3:fixed_supply/maximum_current"] = "5000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/4:battery/maximum_voltage"] = "20000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/4:battery/minimum_voltage"] = "9000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/4:battery/maximum_power"] = "60000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/5:programmable_supply/maximum_voltage"] = "21000",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/5:programmable_supply/minimum_voltage"] = "3300",
  ["/typec/port0-partner/usb_power_delivery/source-capabilities/5:programmable_supply/maximum_current"] = "5000",

  ["/usb/1-2/busnum"] = "1",
  ["/usb/1-2/devnum"] = "7",
  ["/usb/1-2/speed"] = "5000",
  ["/usb/1-2/version"] = "3.10",
  ["/usb/1-2/idVendor"] = "05e3",
  ["/usb/1-2/idProduct"] = "0620",
  ["/usb/1-2/product"] = "USB3.1 Hub",
  ["/usb/1-2/bDeviceClass"] = "09",
  ["/usb/1-2/uevent"] = "DEVTYPE=usb_device\nDRIVER=usb\n",
  ["/usb/1-2:1.0/bInterfaceClass"] = "09",
  ["/usb/1-2:1.0/uevent"] = "DEVTYPE=usb_interface\nDRIVER=hub\n",
  ["/usb/usb1/idVendor"] = "1d6b",
  ["/usb/usb1/product"] = "xHCI Host Controller",

  ["/thunderbolt/0-0/device_name"] = "Framework",
  ["/thunderbolt/0-0/generation"] = "4",
  ["/thunderbolt/0-0/security"] = "user",
  ["/thunderbolt/0-0/authorized"] = "1",

  ["/chromeec/version"] = "RO version:    hx30_v0.0.1-7a61a89\n"
    .. "RW version:    \nFirmware copy: RO\nBoard version: 12\n",
}

-- Directories are implied by the file paths above.
local DIRS = {}
for path in pairs(FILES) do
  local prefix = ""
  for part in path:gmatch("/([^/]+)") do
    DIRS[prefix] = DIRS[prefix] or {}
    DIRS[prefix][part] = true
    prefix = prefix .. "/" .. part
  end
end
for path in pairs(FILES) do
  DIRS[path] = nil
end

local ROOTS = {
  typec = "/typec",
  pd = "/pd",
  usb = "/usb",
  thunderbolt = "/thunderbolt",
  usb4 = "/usb4",
  debugUsb = "/debug",
  chromeEc = "/chromeec",
  dmi = "/dmi",
}

W.setFs({
  readFile = function(path) return FILES[path] end,
  listDir = function(path)
    local entries = DIRS[path]
    if entries == nil then return nil end
    local names = {}
    for name in pairs(entries) do table.insert(names, name) end
    return names
  end,
  exists = function(path) return FILES[path] ~= nil or DIRS[path] ~= nil end,
  isDir = function(path) return DIRS[path] ~= nil end,
})

-- ── PD decoding ──────────────────────────────────────────────────────────────

check("parseInt hex", W.parseInt("0x2c0004b4"), 0x2c0004b4)
check("parseInt decimal", W.parseInt(" 5000 "), 5000)
check("parseInt junk", W.parseInt("n/a"), nil)
check("parseInt empty", W.parseInt(""), nil)

local header = W.decodeIdHeader(0x200004b4)
check("id header vendor", string.format("0x%04x", header.vendorId), "0x04b4")
check("id header product type", header.productLabel, "Active cable")
-- Falls back to the DFP field when the UFP product type is Unspecified.
check("id header dfp fallback", W.decodeIdHeader(0x01800000).productLabel, "Passive cable")

local cable = W.decodeCableVdo(0x00000253, true)
check("cable speed", cable.speedLabel, "USB4 Gen 3 (40 Gbps)")
check("cable current", cable.currentLabel, "5 A")
check("cable max volts", cable.maxVolts, 30)
check("cable max watts", cable.maxWatts, 150)
check("cable usb2 speed", W.decodeCableVdo(0, false).speedLabel, "USB 2.0 (480 Mbps)")

-- 20 V @ 5 A fixed-supply PDO: (20000/50 << 10) | (5000/10)
local option = W.decodeFixedSupplyPdo(0x641f4)
check("raw pdo volts", option.voltsLabel, "20V")
check("raw pdo amps", option.ampsLabel, "5.00A")
check("raw pdo watts", option.wattsLabel, "100W")
check("raw pdo detail", option.detailLabel, "20V @ 5.00A (100W)")
check("non-fixed pdo ignored", W.decodeFixedSupplyPdo(0xc0000000), nil)

-- ── Type-C scan ──────────────────────────────────────────────────────────────

local ports = W.typecPorts(ROOTS)
check("port count", #ports, 2)
check("port0 name", ports[1].name, "port0")
check("port0 power role", ports[1].powerRole, "source [sink]")
check("port0 partner present", ports[1].partner ~= nil, true)
check("port0 partner pd", ports[1].partner.supportsUsbPowerDelivery, true)
check("port0 alt mode", ports[1].partner.altModes[1], "DisplayPort")
check("port0 cable active", ports[1].cable.active, true)
check("port0 cable vdo", ports[1].cable.identity.productTypeVdo1, 0x253)
check("port1 partner absent", ports[2].partner, nil)

local caps = ports[1].sourceCapabilities
check("pdo count", #caps, 5)
check("pdo 1 fixed", caps[1].detailLabel, "5V @ 3.00A (15W)")
check("pdo 2 fixed", caps[2].detailLabel, "9V @ 3.00A (27W)")
check("pdo 3 fixed", caps[3].detailLabel, "20V @ 5.00A (100W)")
check("pdo 4 battery", caps[4].detailLabel, "9–20V (60W)")
check("pdo 5 pps", caps[5].detailLabel, "3.3–21V @ 5.00A (105W)")
check("best option", W.bestOption(caps).wattsLabel, "105W")

local devices = W.usbDevices("/usb")
check("usb device count", #devices, 2)
local hub = devices[1].name == "1-2" and devices[1] or devices[2]
check("usb hub driver", hub.driver, "usb")
check("usb hub interfaces", #hub.interfaces, 1)
check("usb interface driver", hub.interfaces[1].driver, "hub")

local advanced = W.advancedSources(ROOTS)
check("advanced count", #advanced, 1)
check("advanced summary", advanced[1].summary, "Framework · Gen 4, Security user, authorized")

local ecVersion = W.chromeEcVersion("/chromeec")
check("ec ro version", ecVersion.ro_version, "hx30_v0.0.1-7a61a89")
check("ec blank rw version dropped", ecVersion.rw_version, nil)
check("ec board version", ecVersion.board_version, "12")

-- ── summaries ────────────────────────────────────────────────────────────────

local s0 = W.summarizePort(ports[1])
check("port0 status", s0.status, "charging")
check("port0 headline", s0.headline, "USB-C power source · 105W")
check("port0 bullet 1", s0.bullets[1], "Power role: source [sink]")
check("port0 bullet 2", s0.bullets[2], "Data role: [host] device")
check("port0 alt bullet", s0.bullets[3], "Alt modes: DisplayPort")
check("port0 advertises", s0.bullets[4], "Source advertises up to 105W")
check("port0 cable identity", s0.bullets[10], "Cable identity: Active cable")
check("port0 cable speed", s0.bullets[11], "Cable speed: USB4 Gen 3 (40 Gbps)")
check("port0 cable current", s0.bullets[12], "Cable current: 5 A at up to 30V (~150W)")
check("port0 connected device", s0.bullets[13], "Connected device: USB peripheral")
check("port0 active cable", s0.bullets[14], "Active cable")

local s1 = W.summarizePort(ports[2])
check("port1 status", s1.status, "empty")
check("port1 headline", s1.headline, "Nothing connected")
check("port1 subtitle", s1.subtitle, "Plug a cable into port1 to see what it exposes.")

check("root hub detected", W.isRootHub({ name = "usb1", idVendor = "1d6b" }), true)
check("hub not root", W.isRootHub(hub), false)
check("usb summary", W.summarizeUsbDevice(hub), "USB3.1 Hub · 5 Gbps, USB 3.10, usb")
check("usb class label", W.usbClassLabel("09"), "Hub")
check("usb vendor label", W.usbVendorLabel("05E3"), "Genesys Logic")

local ecPort = {
  source = "Framework EC",
  name = "port0",
  summary = "Right back · Sink · USB PD · 20 V, 5 A · up to 100 W",
  properties = { location = "Right back", role = "Sink", charging_type = "USB PD" },
}
check("ec title", W.chromeEcPortTitle(ecPort), "Right back")
check("ec subtitle", W.chromeEcPortSubtitle(ecPort), "Sink · USB PD · 20 V, 5 A · up to 100 W")
check("ec status", W.chromeEcPortStatus(ecPort), "charging")
check("ec disconnected status",
  W.chromeEcPortStatus({ name = "port1", properties = { role = "Disconnected" } }), "empty")

-- ── whole report, as the widget and panel see it ─────────────────────────────

local ec = {
  ok = true,
  access = "Available",
  framework = true,
  ports = {
    {
      source = "Framework EC",
      name = "port0",
      summary = "Right back · Sink · USB PD · 20 V, 5 A · up to 100 W",
      properties = {
        location = "Right back", role = "Sink", charging_type = "USB PD",
        voltage_now = "20 V", voltage_max = "20 V",
        current_limit = "5 A", current_max = "5 A",
        max_power = "100 W", dual_role = "Yes",
      },
      values = { voltage_now_mv = 20000, current_limit_ma = 5000 },
    },
    {
      source = "Framework EC",
      name = "port1",
      summary = "Right front · Disconnected",
      properties = { location = "Right front", role = "Disconnected" },
      values = { voltage_now_mv = 0, current_limit_ma = 0 },
    },
  },
}

local report = W.buildReport(ec, { roots = ROOTS, showAdvanced = true, showUsbDevices = true })
check("report has source", report.anySource, true)
check("report port count", #report.ports, 2)
check("report usb hides root hubs", #report.usb, 1)
check("report usb title", report.usb[1].title, "USB3.1 Hub")
check("report advanced count", #report.advanced, 1)
check("report ec title precomputed", report.ec.ports[1].title, "Right back")
check("report ec details", report.ec.ports[1].details[1], "Charging type: USB PD")
check("report ec empty port has no details", #report.ec.ports[2].details, 0)
check("bar status", report.bar.status, "charging")
-- The EC's live figure wins over the charger's 105 W advertisement.
check("bar watts", report.bar.watts, 100)
check("bar negotiated watts", report.bar.negotiatedWatts, 100)
check("bar advertised watts", report.bar.advertisedWatts, 105)
check("bar connected", report.bar.connected, 1)
check("bar total", report.bar.total, 2)
check("bar tooltip head", report.bar.tooltip:match("^[^\n]+"), "USB-C · Framework EC")

local rootHubs = W.buildReport(ec, { roots = ROOTS, showUsbDevices = true, showRootHubs = true })
check("report usb with root hubs", #rootHubs.usb, 2)
check("report advanced off by default", #rootHubs.advanced, 0)

-- No EC at all: ports are counted from Type-C sysfs and the only power figure
-- available is the charger's advertisement.
local noEc = W.buildReport(
  { ok = false, access = "EC query disabled", framework = false, ports = {} },
  { roots = ROOTS }
)
check("no-ec connected", noEc.bar.connected, 1)
check("no-ec total", noEc.bar.total, 2)
check("no-ec watts", noEc.bar.watts, 105)
check("no-ec negotiated", noEc.bar.negotiatedWatts, nil)
check("no-ec status", noEc.bar.status, "charging")

-- With no Type-C sysfs data and no EC ports, the panel shows its empty state.
local blank = W.buildReport(
  { ok = false, access = "Permission denied", framework = true, ports = {} },
  { roots = { typec = "/nope", pd = "/nope", chromeEc = "/chromeec" } }
)
check("blank report anySource", blank.anySource, false)
check("blank bar status", blank.bar.status, "unavailable")
check("blank bar tooltip", blank.bar.tooltip, "USB-C · Framework EC\nPermission denied")

-- ── optional live scan ───────────────────────────────────────────────────────

if arg[1] == "--live" then
  local function shellTest(flag, path)
    return os.execute("test " .. flag .. " " .. string.format("%q", path)) == true
  end

  W.setFs({
    readFile = function(path)
      local f = io.open(path, "rb")
      if not f then return nil end
      local text = f:read("a")
      f:close()
      return text
    end,
    listDir = function(path)
      if not shellTest("-d", path) then return nil end
      local pipe = io.popen("ls -A " .. string.format("%q", path) .. " 2>/dev/null")
      if not pipe then return nil end
      local names = {}
      for line in pipe:lines() do table.insert(names, line) end
      pipe:close()
      return names
    end,
    exists = function(path) return shellTest("-e", path) end,
    isDir = function(path) return shellTest("-d", path) end,
  })

  print("\n-- live scan --")
  local live = W.buildReport(
    { ok = false, access = "not queried", framework = false, ports = {} },
    { showAdvanced = true }
  )
  for _, port in ipairs(live.ports) do
    print(port.name .. ": " .. port.summary.headline)
    print("  " .. port.summary.subtitle)
    for _, bullet in ipairs(port.summary.bullets) do print("  - " .. bullet) end
  end
  for _, device in ipairs(live.advanced) do
    print(device.source .. " " .. device.name .. ": " .. device.summary)
  end
  if live.ecVersion then
    print("Chrome EC: " .. (live.ecVersion.ro_version or "?")
      .. " board " .. (live.ecVersion.board_version or "?"))
  end
  print("bar: " .. live.bar.status .. " | " .. live.bar.tooltip:gsub("\n", " / "))
end

print(string.format("\n%d checks, %d failures", checks, failures))
os.exit(failures == 0 and 0 or 1)
