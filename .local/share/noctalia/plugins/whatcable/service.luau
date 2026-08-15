--!nonstrict
-- service.luau — the whole scanner, in one file.
--
-- Port of whatcable-linux's pd.py, sysfs.py, usb_sysfs.py,
-- advanced_sources.py, naming.py and summary.py. The one part that stayed in
-- Python is the Chrome EC ioctl (scripts/cros_ec_pd_info.py): a Luau plugin can
-- read sysfs but cannot issue an ioctl.
--
-- Why one file rather than a lib/ of modules: noctalia v5.0.0-beta.3 has no
-- `require` in its Luau host (it landed on main after that tag), so an entry
-- cannot pull in a sibling script. This entry is the only one that needs any of
-- it — the widget and panel are pure presentation over the state published at
-- the bottom — so everything lives here and the surfaces stay thin.
--
-- All sysfs access is read-only and non-privileged. A path that is missing or
-- unreadable yields "unavailable", never an error: Type-C devices can appear
-- and disappear while a scan is running.

local STATE_KEY = "whatcable/report"

-- ═══ pd.py — Power Delivery decoding ═════════════════════════════════════════

-- ID header VDO product types (USB PD spec, Table 6-30).
local PRODUCT_TYPES = {
  [0] = "Unspecified",
  [1] = "USB hub",
  [2] = "USB peripheral",
  [3] = "Passive cable",
  [4] = "Active cable",
  [5] = "Alternate mode adapter",
  [6] = "VCONN-powered device",
  [7] = "Other",
}

-- Cable VDO USB highest-speed field: label plus nominal Gbps.
local CABLE_SPEEDS = {
  [0] = { "USB 2.0", 0.48 },
  [1] = { "USB 3.2 Gen 1", 5 },
  [2] = { "USB 3.2 Gen 2", 10 },
  [3] = { "USB4 Gen 3", 40 },
  [4] = { "USB4 Gen 4", 80 },
}

-- Cable VDO VBUS current handling field: label plus amps.
local CABLE_CURRENTS = {
  [0] = { "USB default", 3.0 },
  [1] = { "3 A", 3.0 },
  [2] = { "5 A", 5.0 },
}

local MAX_VOLTS = { [0] = 20, [1] = 30, [2] = 40, [3] = 50 }

-- `%g` matches Python's `:g`: trailing zeros dropped, so 9.0 prints as "9".
local function g(value)
  return string.format("%g", value)
end

-- Accepts decimal and the "0x…" form the kernel uses for identity VDOs.
-- Returns nil for anything that is not a whole number, which is what every
-- caller treats as "attribute absent".
local function parseInt(text)
  if text == nil then
    return nil
  end
  text = (tostring(text):gsub("^%s*(.-)%s*$", "%1"))
  if text == "" then
    return nil
  end
  local hex = text:match("^0[xX](%x+)$")
  if hex then
    return tonumber(hex, 16)
  end
  local value = tonumber(text)
  if value == nil or value ~= math.floor(value) then
    return nil
  end
  return value
end

-- Luau has no bitwise operators, only bit32, so the shifts and masks below read
-- a little differently from the Python original.
local function decodeIdHeader(vdo)
  local ufp = bit32.band(bit32.rshift(vdo, 27), 0x7)
  local dfp = bit32.band(bit32.rshift(vdo, 23), 0x7)
  local productType = (ufp ~= 0) and ufp or dfp
  return {
    usbCommHost = bit32.band(bit32.rshift(vdo, 31), 1) == 1,
    usbCommDevice = bit32.band(bit32.rshift(vdo, 30), 1) == 1,
    modalOperation = bit32.band(bit32.rshift(vdo, 26), 1) == 1,
    ufpProductType = ufp,
    dfpProductType = dfp,
    vendorId = bit32.band(vdo, 0xFFFF),
    productLabel = PRODUCT_TYPES[productType] or "Unknown",
  }
end

local function decodeCableVdo(vdo, active)
  local speedBits = bit32.band(vdo, 0x7)
  local currentBits = bit32.band(bit32.rshift(vdo, 5), 0x3)
  local maxVoltageEncoded = bit32.band(bit32.rshift(vdo, 9), 0x3)

  local speed = CABLE_SPEEDS[speedBits] or { "Unknown speed", 0 }
  local speedLabel
  if speed[2] >= 1 then
    speedLabel = speed[1] .. " (" .. g(speed[2]) .. " Gbps)"
  elseif speed[2] > 0 then
    speedLabel = speed[1] .. " (" .. g(speed[2] * 1000) .. " Mbps)"
  else
    speedLabel = speed[1]
  end

  local current = CABLE_CURRENTS[currentBits] or { "Unknown", 3.0 }
  local maxVolts = MAX_VOLTS[maxVoltageEncoded] or 20

  return {
    speedBits = speedBits,
    currentBits = currentBits,
    active = active == true,
    vbusThroughCable = bit32.band(bit32.rshift(vdo, 4), 1) == 1,
    speedLabel = speedLabel,
    currentLabel = current[1],
    maxVolts = maxVolts,
    -- The e-marker's ceiling, not a negotiated figure: volts × rated current.
    maxWatts = math.floor(maxVolts * current[2] + 0.5),
  }
end

-- Builds the record every power-option consumer expects, with its labels
-- precomputed so the UI never has to reimplement the formatting.
local function powerOption(fields)
  local option = {
    voltageMv = fields.voltageMv,
    minVoltageMv = fields.minVoltageMv,
    maxCurrentMa = fields.maxCurrentMa,
    maxPowerMw = fields.maxPowerMw,
    supplyType = fields.supplyType or "fixed_supply",
    raw = fields.raw,
  }

  option.watts = option.maxPowerMw / 1000
  if option.minVoltageMv ~= nil and option.minVoltageMv ~= option.voltageMv then
    option.voltsLabel = g(option.minVoltageMv / 1000) .. "–" .. g(option.voltageMv / 1000) .. "V"
  else
    option.voltsLabel = g(option.voltageMv / 1000) .. "V"
  end
  option.ampsLabel = option.maxCurrentMa and string.format("%.2fA", option.maxCurrentMa / 1000) or ""
  option.wattsLabel = g(option.watts) .. "W"
  if option.maxCurrentMa == nil then
    option.detailLabel = option.voltsLabel .. " (" .. option.wattsLabel .. ")"
  else
    option.detailLabel = option.voltsLabel .. " @ " .. option.ampsLabel .. " (" .. option.wattsLabel .. ")"
  end
  return option
end

-- Decodes a raw 32-bit fixed-supply source PDO. Used only for the older
-- driver-specific attributes that expose PDOs as integers rather than as the
-- current directory-per-PDO ABI.
local function decodeFixedSupplyPdo(value)
  if bit32.band(bit32.rshift(value, 30), 0x3) ~= 0 then
    return nil
  end
  local voltageMv = bit32.band(bit32.rshift(value, 10), 0x3FF) * 50
  local currentMa = bit32.band(value, 0x3FF) * 10
  if voltageMv <= 0 or currentMa <= 0 then
    return nil
  end
  return powerOption({
    voltageMv = voltageMv,
    maxCurrentMa = currentMa,
    maxPowerMw = math.floor(voltageMv * currentMa / 1000),
    raw = value,
  })
end

local function bestOption(options)
  local best = nil
  for _, option in ipairs(options) do
    if best == nil or option.maxPowerMw > best.maxPowerMw then
      best = option
    end
  end
  return best
end

-- ═══ sysfs access ════════════════════════════════════════════════════════════

local DEFAULT_ROOTS = {
  typec = "/sys/class/typec",
  pd = "/sys/class/usb_power_delivery",
  usb = "/sys/bus/usb/devices",
  thunderbolt = "/sys/bus/thunderbolt/devices",
  usb4 = "/sys/bus/usb4/devices",
  debugUsb = "/sys/kernel/debug/usb/devices",
  chromeEc = "/sys/class/chromeos/cros_ec",
  dmi = "/sys/class/dmi/id",
}

-- All filesystem access goes through this table so tests/run.lua can point the
-- scanners at a fixture tree. The host bindings follow symlinks, which matters:
-- most of /sys/class is symlinks into /sys/devices.
local fs = {
  readFile = function(path)
    return noctalia.readFile(path)
  end,
  listDir = function(path)
    return noctalia.listDir(path)
  end,
  exists = function(path)
    return noctalia.fileExists(path) == true
  end,
  isDir = function(path)
    local info = noctalia.fileInfo(path)
    return type(info) == "table" and info.isDir == true
  end,
}

-- Trimmed contents, or nil when the attribute is absent, unreadable, or blank.
-- (whatcable keeps blank values; here an empty attribute carries no more
-- information than a missing one, and dropping it keeps `raw` tables tidy.)
local function readText(path)
  local text = fs.readFile(path)
  if type(text) ~= "string" then
    return nil
  end
  text = (text:gsub("^%s*(.-)%s*$", "%1"))
  if text == "" then
    return nil
  end
  return text
end

local function readFields(path, fields)
  local values = {}
  for _, field in ipairs(fields) do
    local value = readText(path .. "/" .. field)
    if value ~= nil then
      values[field] = value
    end
  end
  return values
end

local function isEmpty(tbl)
  return next(tbl) == nil
end

local function sortedDir(path)
  local names = fs.listDir(path)
  if type(names) ~= "table" then
    return {}
  end
  table.sort(names)
  return names
end

local function parseBool(value)
  if value == nil then
    return nil
  end
  local text = value:lower()
  if text == "1" or text == "yes" or text == "true" or text == "y" then
    return true
  end
  if text == "0" or text == "no" or text == "false" or text == "n" then
    return false
  end
  return nil
end

-- The kernel exposes the driver as a `driver` symlink. Luau cannot readlink, so
-- the name is taken from the uevent DRIVER= line the same device carries.
local function driverName(path)
  local uevent = fs.readFile(path .. "/uevent")
  if type(uevent) ~= "string" then
    return nil
  end
  return uevent:match("DRIVER=([^\n]+)")
end

-- ═══ sysfs.py — Type-C ═══════════════════════════════════════════════════════

local PORT_FIELDS = {
  "data_role",
  "power_role",
  "port_type",
  "supported_accessory_modes",
  "usb_power_delivery_revision",
}

local PARTNER_FIELDS = { "accessory_mode", "supports_usb_power_delivery" }
local CABLE_FIELDS = { "active" }

local IDENTITY_FIELDS = {
  "id_header",
  "cert_stat",
  "product",
  "product_type_vdo1",
  "product_type_vdo2",
  "product_type_vdo3",
}

local function readIdentity(path)
  if not fs.exists(path) then
    return nil
  end
  local raw = readFields(path, IDENTITY_FIELDS)
  if isEmpty(raw) then
    return nil
  end
  local identity = {
    idHeader = parseInt(raw.id_header),
    certStat = parseInt(raw.cert_stat),
    product = parseInt(raw.product),
    productTypeVdo1 = parseInt(raw.product_type_vdo1),
    productTypeVdo2 = parseInt(raw.product_type_vdo2),
    productTypeVdo3 = parseInt(raw.product_type_vdo3),
    raw = raw,
  }
  if identity.idHeader ~= nil then
    identity.vendorId = bit32.band(identity.idHeader, 0xFFFF)
  end
  if identity.product ~= nil then
    identity.productId = bit32.band(identity.product, 0xFFFF)
  end
  return identity
end

-- A partner's alternate modes are subdirectories of the partner device, named
-- either "<partner>.<n>" or "…-mode…" depending on kernel version.
local function readAltModes(path)
  local base = path:match("([^/]+)$") or ""
  local modes = {}
  for _, name in ipairs(sortedDir(path)) do
    if name:find("-mode", 1, true) or name:sub(1, #base + 1) == base .. "." then
      local fields = readFields(path .. "/" .. name, { "description", "mode", "svid", "vdo" })
      if fields.description then
        table.insert(modes, fields.description)
      elseif fields.svid and fields.mode then
        table.insert(modes, "SVID " .. fields.svid .. ", mode " .. fields.mode)
      elseif fields.svid then
        table.insert(modes, "SVID " .. fields.svid)
      else
        table.insert(modes, name)
      end
    end
  end
  return modes
end

-- Device nodes hang off either the port directory or the class root, depending
-- on kernel version; both spellings are tried.
local function firstExistingChild(portPath, root, name)
  for _, candidate in ipairs({ portPath .. "/" .. name, root .. "/" .. name }) do
    if fs.exists(candidate) then
      return candidate
    end
  end
  return nil
end

local function currentBasedOption(path, supplyType, voltageField)
  local voltageMv = parseInt(readText(path .. "/" .. voltageField))
  local currentMa = parseInt(readText(path .. "/maximum_current"))
  if voltageMv == nil or voltageMv <= 0 or currentMa == nil or currentMa <= 0 then
    return nil
  end
  return powerOption({
    voltageMv = voltageMv,
    minVoltageMv = parseInt(readText(path .. "/minimum_voltage")),
    maxCurrentMa = currentMa,
    maxPowerMw = math.floor(voltageMv * currentMa / 1000),
    supplyType = supplyType,
  })
end

local function batteryOption(path)
  local voltageMv = parseInt(readText(path .. "/maximum_voltage"))
  local powerMw = parseInt(readText(path .. "/maximum_power"))
  if voltageMv == nil or voltageMv <= 0 or powerMw == nil or powerMw <= 0 then
    return nil
  end
  return powerOption({
    voltageMv = voltageMv,
    minVoltageMv = parseInt(readText(path .. "/minimum_voltage")),
    maxCurrentMa = nil,
    maxPowerMw = powerMw,
    supplyType = "battery",
  })
end

local ADJUSTABLE_RANGES = {
  { 9000, 15000, "maximum_current_9V_to_15V" },
  { 15000, 20000, "maximum_current_15V_to_20V" },
}

local function adjustableVoltageOptions(path)
  local options = {}
  for _, range in ipairs(ADJUSTABLE_RANGES) do
    local currentMa = parseInt(readText(path .. "/" .. range[3]))
    if currentMa ~= nil and currentMa > 0 then
      table.insert(options, powerOption({
        voltageMv = range[2],
        minVoltageMv = range[1],
        maxCurrentMa = currentMa,
        maxPowerMw = math.floor(range[2] * currentMa / 1000),
        supplyType = "spr_adjustable_voltage_supply",
      }))
    end
  end
  return options
end

-- Entries are "<position>:<supply_type>"; position orders the advertisement.
local function pdoPosition(name)
  local position = name:match("^(%d+):")
  return position and tonumber(position) or (2 ^ 31 - 1)
end

local function readSourceCapabilityDirectory(path)
  local names = fs.listDir(path)
  if type(names) ~= "table" then
    return {}
  end
  table.sort(names, function(a, b)
    local pa, pb = pdoPosition(a), pdoPosition(b)
    if pa ~= pb then
      return pa < pb
    end
    return a < b
  end)

  local options = {}
  for _, name in ipairs(names) do
    local supplyType = name:match("^%d*:(.+)$")
    local entry = path .. "/" .. name
    if supplyType and fs.isDir(entry) then
      if supplyType == "fixed_supply" then
        local option = currentBasedOption(entry, supplyType, "voltage")
        if option then table.insert(options, option) end
      elseif supplyType == "variable_supply" or supplyType == "programmable_supply" then
        local option = currentBasedOption(entry, supplyType, "maximum_voltage")
        if option then table.insert(options, option) end
      elseif supplyType == "battery" then
        local option = batteryOption(entry)
        if option then table.insert(options, option) end
      elseif supplyType == "spr_adjustable_voltage_supply" then
        for _, option in ipairs(adjustableVoltageOptions(entry)) do
          table.insert(options, option)
        end
      end
    end
  end
  return options
end

-- Compatibility with early/driver-specific attributes that expose the raw PDO
-- integers in a single file rather than one directory per PDO.
local function parseRawSourceCapabilities(text)
  if text == nil then
    return {}
  end
  local options = {}
  for token in text:gsub(",", " "):gmatch("%S+") do
    local value = parseInt(token)
    if value ~= nil then
      local option = decodeFixedSupplyPdo(value)
      if option then
        table.insert(options, option)
      end
    end
  end
  return options
end

-- `<device>/usb_power_delivery/source-capabilities`, in either ABI shape.
local function readSourceCapabilities(devicePath)
  if devicePath == nil then
    return {}
  end
  local path = devicePath .. "/usb_power_delivery/source-capabilities"
  if not fs.exists(path) then
    -- Some kernels link source-capabilities directly onto the device.
    path = devicePath .. "/source-capabilities"
    if not fs.exists(path) then
      return {}
    end
  end
  if fs.isDir(path) then
    return readSourceCapabilityDirectory(path)
  end
  return parseRawSourceCapabilities(readText(path))
end

-- whatcable walks /sys/class/usb_power_delivery and maps each pd device back to
-- its port by resolving the symlink. Luau has no realpath, so capabilities are
-- collected from the port and partner devices instead — the same data reached
-- from the other end. This fallback only fires when that walk found nothing at
-- all and there is exactly one port to attribute them to.
local function orphanSourceCapabilities(pdRoot)
  local options = {}
  for _, name in ipairs(sortedDir(pdRoot)) do
    for _, option in ipairs(readSourceCapabilities(pdRoot .. "/" .. name)) do
      table.insert(options, option)
    end
  end
  return options
end

local function typecPorts(roots)
  roots = roots or DEFAULT_ROOTS
  local typecRoot = roots.typec or DEFAULT_ROOTS.typec
  local pdRoot = roots.pd or DEFAULT_ROOTS.pd

  local ports = {}
  local anyCapabilities = false

  for _, name in ipairs(sortedDir(typecRoot)) do
    local isPort = name:sub(1, 4) == "port"
      and not name:find("-partner", 1, true)
      and not name:find("-cable", 1, true)
      and not name:find("-plug", 1, true)
    if isPort then
      local path = typecRoot .. "/" .. name
      local raw = readFields(path, PORT_FIELDS)

      local port = {
        name = name,
        sysfsPath = path,
        dataRole = raw.data_role,
        powerRole = raw.power_role,
        portType = raw.port_type,
        supportedAccessoryModes = raw.supported_accessory_modes,
        usbPowerDeliveryRevision = raw.usb_power_delivery_revision,
        raw = raw,
        sourceCapabilities = {},
      }

      local partnerPath = firstExistingChild(path, typecRoot, name .. "-partner")
      if partnerPath then
        local partnerRaw = readFields(partnerPath, PARTNER_FIELDS)
        port.partner = {
          name = partnerPath:match("([^/]+)$"),
          sysfsPath = partnerPath,
          accessoryMode = partnerRaw.accessory_mode,
          supportsUsbPowerDelivery = parseBool(partnerRaw.supports_usb_power_delivery),
          identity = readIdentity(partnerPath .. "/identity"),
          altModes = readAltModes(partnerPath),
          raw = partnerRaw,
        }
      end

      local cablePath = firstExistingChild(path, typecRoot, name .. "-cable")
      if cablePath then
        local cableRaw = readFields(cablePath, CABLE_FIELDS)
        port.cable = {
          name = cablePath:match("([^/]+)$"),
          sysfsPath = cablePath,
          active = parseBool(cableRaw.active),
          identity = readIdentity(cablePath .. "/identity"),
          raw = cableRaw,
        }
      end

      local plugPath = firstExistingChild(path, typecRoot, name .. "-plug0")
      if plugPath then
        port.plug = {
          name = plugPath:match("([^/]+)$"),
          sysfsPath = plugPath,
          identity = readIdentity(plugPath .. "/identity"),
          raw = {},
        }
      end

      -- The port advertises when sourcing; the partner advertises when it is
      -- the charger. Both belong to this port's story, so both are collected.
      for _, option in ipairs(readSourceCapabilities(path)) do
        table.insert(port.sourceCapabilities, option)
      end
      if port.partner then
        for _, option in ipairs(readSourceCapabilities(port.partner.sysfsPath)) do
          table.insert(port.sourceCapabilities, option)
        end
      end
      if #port.sourceCapabilities > 0 then
        anyCapabilities = true
      end

      table.insert(ports, port)
    end
  end

  if not anyCapabilities and #ports == 1 then
    ports[1].sourceCapabilities = orphanSourceCapabilities(pdRoot)
  end

  return ports
end

-- ═══ usb_sysfs.py — USB device tree ══════════════════════════════════════════

local USB_DEVICE_FIELDS = {
  "busnum", "devnum", "devpath", "speed", "version",
  "idVendor", "idProduct", "manufacturer", "product", "serial",
  "bDeviceClass", "bDeviceSubClass", "bDeviceProtocol",
  "bMaxPower", "configuration", "tx_lanes", "rx_lanes",
}

local USB_INTERFACE_FIELDS = {
  "bInterfaceClass", "bInterfaceSubClass", "bInterfaceProtocol",
  "bInterfaceNumber", "bAlternateSetting",
}

local function readInterfaces(root, names, deviceName)
  local prefix = deviceName .. ":"
  local interfaces = {}
  for _, name in ipairs(names) do
    if name:sub(1, #prefix) == prefix then
      local path = root .. "/" .. name
      local raw = readFields(path, USB_INTERFACE_FIELDS)
      table.insert(interfaces, {
        name = name,
        sysfsPath = path,
        interfaceClass = raw.bInterfaceClass,
        interfaceSubclass = raw.bInterfaceSubClass,
        interfaceProtocol = raw.bInterfaceProtocol,
        interfaceNumber = raw.bInterfaceNumber,
        alternateSetting = raw.bAlternateSetting,
        driver = driverName(path),
        raw = raw,
      })
    end
  end
  return interfaces
end

local function usbDevices(root)
  root = root or DEFAULT_ROOTS.usb
  local names = sortedDir(root)
  local devices = {}

  for _, name in ipairs(names) do
    local path = root .. "/" .. name
    -- ":" marks an interface, which is attached to its device below.
    if not name:find(":", 1, true) and fs.isDir(path) then
      local raw = readFields(path, USB_DEVICE_FIELDS)
      if not isEmpty(raw) or name:sub(1, 3) == "usb" then
        table.insert(devices, {
          name = name,
          sysfsPath = path,
          busnum = raw.busnum,
          devnum = raw.devnum,
          devpath = raw.devpath,
          speed = raw.speed,
          version = raw.version,
          idVendor = raw.idVendor,
          idProduct = raw.idProduct,
          manufacturer = raw.manufacturer,
          product = raw.product,
          serial = raw.serial,
          deviceClass = raw.bDeviceClass,
          deviceSubclass = raw.bDeviceSubClass,
          deviceProtocol = raw.bDeviceProtocol,
          maxPower = raw.bMaxPower,
          configuration = raw.configuration,
          driver = driverName(path),
          txLanes = raw.tx_lanes,
          rxLanes = raw.rx_lanes,
          interfaces = readInterfaces(root, names, name),
          raw = raw,
        })
      end
    end
  end
  return devices
end

-- ═══ advanced_sources.py — Thunderbolt / USB4 / debugfs ══════════════════════

local ADVANCED_FIELDS = {
  "authorized", "device", "device_name", "device_type", "generation",
  "iommu_dma_protection", "key", "link", "maxhopid", "nvm_authenticate",
  "nvm_version", "rx_speed", "rx_lanes", "security", "tx_speed", "tx_lanes",
  "unique_id", "vendor", "vendor_name",
}

local function scanBus(source, root)
  local devices = {}
  for _, name in ipairs(sortedDir(root)) do
    local path = root .. "/" .. name
    if fs.isDir(path) then
      local raw = readFields(path, ADVANCED_FIELDS)
      if not isEmpty(raw) then
        local label = raw.device_name or raw.vendor_name or name
        local bits = {}
        if raw.generation then table.insert(bits, "Gen " .. raw.generation) end
        if raw.security then table.insert(bits, "Security " .. raw.security) end
        if raw.authorized then
          table.insert(bits, raw.authorized == "1" and "authorized" or "not authorized")
        end
        if raw.tx_speed or raw.rx_speed then
          table.insert(bits, "TX " .. (raw.tx_speed or "?") .. " / RX " .. (raw.rx_speed or "?"))
        end
        table.insert(devices, {
          source = source,
          name = name,
          sysfsPath = path,
          summary = #bits == 0 and label or (label .. " · " .. table.concat(bits, ", ")),
          properties = raw,
        })
      end
    end
  end
  return devices
end

-- /sys/kernel/debug/usb/devices is normally root-only; an unreadable path just
-- yields nothing, same as upstream.
local function scanDebugUsb(path)
  local text = fs.readFile(path)
  if type(text) ~= "string" or text == "" then
    return {}
  end

  local devices = {}
  local current = nil
  local index = 0

  local function flush()
    if current == nil then
      return
    end
    local name = current.product or current.manufacturer or ("debug-usb-" .. index)
    local bits = {}
    if current.manufacturer then table.insert(bits, current.manufacturer) end
    if current.serialnumber then table.insert(bits, current.serialnumber) end
    table.insert(devices, {
      source = "USB debugfs",
      name = "debug-usb-" .. index,
      sysfsPath = path,
      summary = #bits == 0 and name or (name .. " · " .. table.concat(bits, ", ")),
      properties = current,
    })
    index = index + 1
    current = nil
  end

  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    local tag, rest = line:sub(1, 2), line:sub(3):gsub("^%s*(.-)%s*$", "%1")
    if tag == "T:" then
      flush()
      current = { topology = rest }
    elseif current ~= nil then
      if tag == "D:" then
        current.device = rest
      elseif tag == "P:" then
        current.product_ids = rest
      elseif tag == "C:" then
        current.configuration = rest
      elseif tag == "S:" then
        local key, value = rest:match("^([^=]+)=(.*)$")
        if key and value ~= "" then
          current[key:lower()] = value
        end
      end
    end
  end
  flush()
  return devices
end

local function advancedSources(roots)
  roots = roots or DEFAULT_ROOTS
  local devices = {}
  for _, device in ipairs(scanBus("Thunderbolt", roots.thunderbolt or DEFAULT_ROOTS.thunderbolt)) do
    table.insert(devices, device)
  end
  for _, device in ipairs(scanBus("USB4", roots.usb4 or DEFAULT_ROOTS.usb4)) do
    table.insert(devices, device)
  end
  for _, device in ipairs(scanDebugUsb(roots.debugUsb or DEFAULT_ROOTS.debugUsb)) do
    table.insert(devices, device)
  end
  return devices
end

-- Chrome EC firmware metadata. The per-port PD figures need an ioctl on
-- /dev/cros_ec and come from scripts/cros_ec_pd_info.py instead.
local function chromeEcVersion(sysfsRoot)
  local text = readText((sysfsRoot or DEFAULT_ROOTS.chromeEc) .. "/version")
  if text == nil then
    return nil
  end
  local properties = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    local key, value = line:match("^([^:]+):%s*(.-)%s*$")
    if key and value ~= "" then
      properties[(key:lower():gsub("%s+", "_"))] = value
    end
  end
  return properties
end

-- ═══ naming.py ═══════════════════════════════════════════════════════════════

local USB_CLASS_NAMES = {
  ["00"] = "Per-interface",
  ["01"] = "Audio",
  ["02"] = "Communications",
  ["03"] = "Human Interface Device",
  ["05"] = "Physical",
  ["06"] = "Still Imaging",
  ["07"] = "Printer",
  ["08"] = "Mass Storage",
  ["09"] = "Hub",
  ["0a"] = "CDC Data",
  ["0b"] = "Smart Card",
  ["0d"] = "Content Security",
  ["0e"] = "Video",
  ["0f"] = "Personal Healthcare",
  ["10"] = "Audio/Video",
  ["11"] = "Billboard",
  ["12"] = "USB-C Bridge",
  ["dc"] = "Diagnostic",
  ["e0"] = "Wireless Controller",
  ["ef"] = "Miscellaneous",
  ["fe"] = "Application Specific",
  ["ff"] = "Vendor Specific",
}

local USB_VENDOR_NAMES = {
  ["05e3"] = "Genesys Logic",
  ["0bda"] = "Realtek",
  ["1d6b"] = "Linux Foundation",
  ["27c6"] = "Goodix",
  ["8087"] = "Intel",
}

local function usbClassLabel(code)
  if code == nil or code == "" then
    return nil
  end
  return USB_CLASS_NAMES[code:lower()] or code
end

local function usbVendorLabel(vendorId)
  if vendorId == nil or vendorId == "" then
    return nil
  end
  return USB_VENDOR_NAMES[vendorId:lower()]
end

-- ═══ summary.py — plain-English summaries ════════════════════════════════════
--
-- The wording is kept verbatim from upstream, so a panel row says the same
-- thing the GTK app's row does.

-- Returns { status, headline, subtitle, bullets }. `status` drives the icon and
-- accent colour: empty | charging | display | cable | device.
local function summarizePort(port)
  local connected = port.partner ~= nil or port.cable ~= nil
  if not connected then
    return {
      status = "empty",
      headline = "Nothing connected",
      subtitle = "Plug a cable into " .. port.name .. " to see what it exposes.",
      bullets = {},
    }
  end

  local bullets = {}
  local function add(text)
    table.insert(bullets, text)
  end

  if port.powerRole then add("Power role: " .. port.powerRole) end
  if port.dataRole then add("Data role: " .. port.dataRole) end
  if port.partner and port.partner.accessoryMode then
    add("Accessory mode: " .. port.partner.accessoryMode)
  end
  if port.partner and #port.partner.altModes > 0 then
    add("Alt modes: " .. table.concat(port.partner.altModes, ", "))
  end

  local caps = port.sourceCapabilities or {}
  local best = bestOption(caps)
  if best then
    add("Source advertises up to " .. best.wattsLabel)
    for _, option in ipairs(caps) do
      add(option.detailLabel)
    end
  end

  if port.cable and port.cable.identity then
    local identity = port.cable.identity
    if identity.idHeader ~= nil then
      add("Cable identity: " .. decodeIdHeader(identity.idHeader).productLabel)
    end
    local cableVdoRaw = identity.productTypeVdo1 or identity.productTypeVdo2 or identity.productTypeVdo3
    if cableVdoRaw ~= nil then
      local vdo = decodeCableVdo(cableVdoRaw, port.cable.active == true)
      add("Cable speed: " .. vdo.speedLabel)
      add("Cable current: " .. vdo.currentLabel .. " at up to "
        .. vdo.maxVolts .. "V (~" .. vdo.maxWatts .. "W)")
    elseif next(identity.raw) ~= nil then
      add("Cable identity is exposed, but no cable VDO was found")
    end
  end

  if port.partner and port.partner.identity and port.partner.identity.idHeader ~= nil then
    add("Connected device: " .. decodeIdHeader(port.partner.identity.idHeader).productLabel)
  end

  if port.cable and port.cable.active ~= nil then
    add(port.cable.active and "Active cable" or "Passive cable")
  end

  local status, headline, subtitle
  if best then
    status = "charging"
    headline = "USB-C power source · " .. best.wattsLabel
    subtitle = "Power Delivery source capabilities are available."
  elseif port.partner and #port.partner.altModes > 0 then
    status = "display"
    headline = "USB-C alt mode device"
    subtitle = "The kernel reports alternate mode support."
  elseif port.cable and port.cable.identity then
    status = "cable"
    headline = "USB-C cable with identity"
    subtitle = "The kernel exposes cable e-marker data."
  elseif port.partner then
    status = "device"
    headline = "USB-C device connected"
    subtitle = "A partner is present, but detailed capabilities are limited."
  else
    status = "cable"
    headline = "USB-C cable connected"
    subtitle = "A cable is present, but detailed capabilities are limited."
  end

  return { status = status, headline = headline, subtitle = subtitle, bullets = bullets }
end

local function speedLabel(speed)
  local mbps = tonumber(speed)
  if mbps == nil then
    return speed
  end
  if mbps >= 1000 then
    return g(mbps / 1000) .. " Gbps"
  end
  return g(mbps) .. " Mbps"
end

local function isRootHub(device)
  return device.name:sub(1, 3) == "usb"
    or (device.idVendor == "1d6b" and device.product ~= nil
      and device.product:find("Host Controller", 1, true) ~= nil)
end

local function usbDeviceName(device)
  return device.product
    or device.manufacturer
    or usbVendorLabel(device.idVendor)
    or usbClassLabel(device.deviceClass)
    or device.name
end

local function summarizeUsbDevice(device)
  local name = usbDeviceName(device)
  local bits = {}
  if device.speed then table.insert(bits, speedLabel(device.speed)) end
  if device.version then table.insert(bits, "USB " .. device.version) end
  if device.driver then table.insert(bits, device.driver) end
  if #bits == 0 then
    return name
  end
  return name .. " · " .. table.concat(bits, ", ")
end

local function usbDeviceBullets(device)
  local bullets = {}
  local function add(text)
    table.insert(bullets, text)
  end

  if device.idVendor and device.idProduct then
    local vendor = usbVendorLabel(device.idVendor)
    add("USB ID: " .. device.idVendor .. ":" .. device.idProduct
      .. (vendor and (" (" .. vendor .. ")") or ""))
  end
  if device.manufacturer then add("Manufacturer: " .. device.manufacturer) end
  if device.product then add("Product: " .. device.product) end
  if device.speed then add("Negotiated speed: " .. speedLabel(device.speed)) end
  if device.version then add("USB version: " .. device.version) end
  if device.txLanes or device.rxLanes then
    add("Lanes: TX " .. (device.txLanes or "?") .. " / RX " .. (device.rxLanes or "?"))
  end
  if device.maxPower then add("Max power from descriptor: " .. device.maxPower) end
  if device.configuration then add("Configuration: " .. device.configuration) end
  if device.deviceClass then
    local classLabel = usbClassLabel(device.deviceClass)
    local parts = {}
    for _, part in ipairs({ device.deviceClass, device.deviceSubclass, device.deviceProtocol }) do
      if part ~= nil then table.insert(parts, part) end
    end
    local classCode = table.concat(parts, ":")
    add("Device class: " .. (classLabel and (classLabel .. " (" .. classCode .. ")") or classCode))
  end
  if device.driver then add("Driver: " .. device.driver) end
  if #device.interfaces > 0 then add("Interfaces: " .. #device.interfaces) end
  return bullets
end

-- ═══ chrome_ec.py presentation ═══════════════════════════════════════════════

local function chromeEcPortTitle(port)
  return port.properties.location or port.name
end

local function chromeEcPortSubtitle(port)
  local title = chromeEcPortTitle(port)
  local text = port.summary or port.properties.role or port.name
  local prefix = title .. " · "
  if text:sub(1, #prefix) == prefix then
    return text:sub(#prefix + 1)
  end
  return text
end

local function chromeEcPortStatus(port)
  local role = port.properties.role
  if role == "Disconnected" then
    return "empty"
  end
  if role == "Source" then
    return "source"
  end
  local charging = port.properties.charging_type
  if role == "Sink" and charging ~= nil and charging ~= "None" then
    return "charging"
  end
  return "device"
end

-- ═══ report assembly ═════════════════════════════════════════════════════════

-- Watts a port is entitled to draw, from the EC's live figures. The EC reports
-- the negotiated current limit rather than instantaneous draw — the same number
-- the upstream app's per-port row shows.
local function ecPortWatts(port)
  local values = port.values
  if type(values) ~= "table" then
    return nil
  end
  local mv, ma = values.voltage_now_mv, values.current_limit_ma
  if type(mv) ~= "number" or type(ma) ~= "number" or mv <= 0 or ma <= 0 then
    return nil
  end
  return mv * ma / 1000000
end

-- Everything the bar item needs, computed once here rather than in each widget
-- instance: text, accent, and the tooltip.
local function buildBarState(report)
  local connected, total = 0, 0
  -- Two different quantities, deliberately kept apart: the EC reports what a
  -- port is actually negotiated to draw, while a PD source advertisement is a
  -- ceiling the charger offers. The bar prefers the live figure and falls back
  -- to the advertisement, rather than taking the larger of the two.
  local negotiatedWatts, advertisedWatts = nil, nil
  local charging = false

  for _, port in ipairs(report.ec.ports) do
    total = total + 1
    local role = port.properties and port.properties.role
    if role ~= nil and role ~= "Disconnected" then
      connected = connected + 1
    end
    if role == "Sink" or role == "Sink, not charging" then
      local portWatts = ecPortWatts(port)
      if portWatts and (negotiatedWatts == nil or portWatts > negotiatedWatts) then
        negotiatedWatts = portWatts
        charging = role == "Sink"
      end
    end
  end

  -- With no EC view of the ports, fall back to the Type-C sysfs ports.
  for _, port in ipairs(report.ports) do
    if total == 0 and (port.partner ~= nil or port.cable ~= nil) then
      connected = connected + 1
    end
    local best = bestOption(port.sourceCapabilities or {})
    if best and (advertisedWatts == nil or best.watts > advertisedWatts) then
      advertisedWatts = best.watts
    end
  end
  if total == 0 then
    total = #report.ports
  end

  local watts = negotiatedWatts or advertisedWatts
  if negotiatedWatts == nil and advertisedWatts ~= nil then
    charging = true
  end

  local status
  if not report.anySource then
    status = "unavailable"
  elseif charging and watts then
    status = "charging"
  elseif connected > 0 then
    status = "connected"
  else
    status = "idle"
  end

  local lines = { report.ec.framework and "USB-C · Framework EC" or "USB-C" }
  if not report.anySource then
    table.insert(lines, report.ec.access or "No Type-C data exposed")
  else
    if negotiatedWatts then
      table.insert(lines, string.format("Power: %.1f W", negotiatedWatts))
    end
    if advertisedWatts then
      table.insert(lines, string.format("Source advertises up to %g W", advertisedWatts))
    end
    table.insert(lines, connected .. " of " .. total .. " ports connected")
    for _, port in ipairs(report.ec.ports) do
      table.insert(lines, "· " .. (port.summary or port.name))
    end
    if #report.ec.ports == 0 then
      for _, port in ipairs(report.ports) do
        table.insert(lines, "· " .. port.name .. ": " .. port.summary.headline)
      end
    end
  end

  return {
    status = status,
    watts = watts,
    negotiatedWatts = negotiatedWatts,
    advertisedWatts = advertisedWatts,
    connected = connected,
    total = total,
    tooltip = table.concat(lines, "\n"),
  }
end

-- Builds the whole report. Every label the panel and widget draw is computed
-- here, so those entries need none of the code above — which is what lets this
-- stay a single file on a runtime without `require`.
local function buildReport(ec, options)
  local roots = options.roots or DEFAULT_ROOTS

  local ports = typecPorts(roots)
  for _, port in ipairs(ports) do
    port.summary = summarizePort(port)
  end

  for _, port in ipairs(ec.ports) do
    port.properties = port.properties or {}
    port.title = chromeEcPortTitle(port)
    port.subtitle = chromeEcPortSubtitle(port)
    port.status = chromeEcPortStatus(port)
    port.details = {}
    if port.properties.role ~= "Disconnected" then
      local p = port.properties
      port.details = {
        "Charging type: " .. (p.charging_type or "?"),
        "Voltage: " .. (p.voltage_now or "?") .. " (max " .. (p.voltage_max or "?") .. ")",
        "Current: " .. (p.current_limit or "?") .. " (max " .. (p.current_max or "?") .. ")",
        "Maximum power: " .. (p.max_power or "?"),
        "Dual role: " .. (p.dual_role or "?"),
      }
    end
  end

  local report = {
    ok = true,
    scannedAt = os.time(),
    ports = ports,
    ec = ec,
    ecVersion = chromeEcVersion(roots.chromeEc),
    advanced = options.showAdvanced and advancedSources(roots) or {},
    usb = {},
  }

  if options.showUsbDevices then
    for _, device in ipairs(usbDevices(roots.usb)) do
      if options.showRootHubs or not isRootHub(device) then
        device.title = usbDeviceName(device)
        device.summaryText = summarizeUsbDevice(device)
        device.bullets = usbDeviceBullets(device)
        table.insert(report.usb, device)
      end
    end
  end

  -- "Is there anything at all to show?" — drives the panel's empty state, and
  -- is the honest answer on hardware whose firmware negotiates PD without
  -- telling the kernel (both sysfs classes present but empty).
  report.anySource = #report.ports > 0 or #report.ec.ports > 0
  report.bar = buildBarState(report)
  return report
end

-- ═══ entry point ═════════════════════════════════════════════════════════════

local NO_EC = { ok = false, access = "EC query disabled", framework = false, ports = {} }

local function currentOptions()
  return {
    showAdvanced = noctalia.getConfig("show_advanced") == true,
    showUsbDevices = noctalia.getConfig("show_usb_devices") == true,
    showRootHubs = noctalia.getConfig("show_root_hubs") == true,
  }
end

local function publish(ec)
  noctalia.state.set(STATE_KEY, buildReport(ec, currentOptions()))
end

local function intervalMs()
  return math.max(2, noctalia.getConfig("refresh_interval") or 10) * 1000
end

local function poll()
  if noctalia.getConfig("query_ec") == false then
    publish(NO_EC)
    return
  end

  local command = "python3 " .. noctalia.pluginDir() .. "/scripts/cros_ec_pd_info.py"
  noctalia.runAsync(command, function(result)
    local out = noctalia.string.trim(result and result.stdout or "")
    if out == "" then
      local err = noctalia.string.trim(result and result.stderr or "")
      publish({
        ok = false,
        access = err ~= "" and ("Helper failed: " .. err) or "Helper produced no output",
        framework = false,
        ports = {},
      })
      return
    end

    local ok, decoded = pcall(noctalia.json.decode, out)
    if ok and type(decoded) == "table" then
      decoded.ports = decoded.ports or {}
      publish(decoded)
    else
      publish({ ok = false, access = "Helper output was not JSON", framework = false, ports = {} })
    end
  end, 10000)
end

-- update() fires on the setUpdateInterval cadence, and once shortly after load.
function update()
  noctalia.setUpdateInterval(intervalMs())
  poll()
end

function onConfigChanged()
  noctalia.setUpdateInterval(intervalMs())
  poll()
end

-- Test hook. tests/run.lua loads this file with a stubbed `noctalia` global and
-- drives the internals through here; the plugin runtime gives every entry its
-- own writable globals table, so nothing else can see it.
WHATCABLE_INTERNALS = {
  parseInt = parseInt,
  decodeIdHeader = decodeIdHeader,
  decodeCableVdo = decodeCableVdo,
  decodeFixedSupplyPdo = decodeFixedSupplyPdo,
  bestOption = bestOption,
  fs = fs,
  setFs = function(replacement) fs = replacement end,
  typecPorts = typecPorts,
  usbDevices = usbDevices,
  advancedSources = advancedSources,
  chromeEcVersion = chromeEcVersion,
  summarizePort = summarizePort,
  summarizeUsbDevice = summarizeUsbDevice,
  usbDeviceName = usbDeviceName,
  usbClassLabel = usbClassLabel,
  usbVendorLabel = usbVendorLabel,
  isRootHub = isRootHub,
  chromeEcPortTitle = chromeEcPortTitle,
  chromeEcPortSubtitle = chromeEcPortSubtitle,
  chromeEcPortStatus = chromeEcPortStatus,
  buildReport = buildReport,
  DEFAULT_ROOTS = DEFAULT_ROOTS,
}
