--!nonstrict
-- panel.luau — the detail view, this plugin's answer to whatcable's window.
--
-- One section per data source, ordered by how much it tells you: Type-C ports
-- from sysfs, the EC's per-port power figures, firmware metadata, then the
-- optional Thunderbolt/USB4 and USB device lists. Sections with no data are
-- omitted rather than shown empty.
--
-- Every label here is precomputed by service.luau and read from shared state:
-- this entry does no scanning and no formatting of its own.

local STATE_KEY = "whatcable/report"

-- status -> (glyph, accent). Shared by the sysfs ports and the EC ports so a
-- charging port looks the same whichever source reported it.
local STATUS_STYLE = {
  charging = { "bolt", "primary" },
  source = { "plug-connected", "secondary" },
  display = { "device-desktop", "secondary" },
  cable = { "plug", "on_surface" },
  device = { "usb", "on_surface" },
  empty = { "plug-off", "on_surface_variant" },
}

local function style(status)
  return STATUS_STYLE[status] or STATUS_STYLE.device
end

local function sectionTitle(text)
  return ui.label({
    text = text,
    color = "on_surface_variant",
    fontSize = 11,
    fontWeight = "semibold",
  })
end

local function detailRows(lines, limit)
  local rows = {}
  for index, text in ipairs(lines) do
    if limit and index > limit then
      table.insert(rows, ui.label({
        text = noctalia.trp("panel.more", #lines - limit),
        color = "on_surface_variant",
        fontSize = 11,
      }))
      break
    end
    table.insert(rows, ui.label({
      text = "· " .. text,
      color = "on_surface_variant",
      fontSize = 11,
      maxLines = 2,
    }))
  end
  return rows
end

-- The common card: icon + title/subtitle header, then detail lines.
local function card(status, title, subtitle, details)
  local st = style(status)
  local children = {
    ui.row({ gap = 8, align = "center" }, {
      ui.glyph({ name = st[1], size = 15, color = st[2] }),
      ui.column({ gap = 1, flexGrow = 1 }, {
        ui.label({ text = title, color = "on_surface", fontWeight = "bold", maxLines = 2 }),
        ui.label({ text = subtitle, color = "on_surface_variant", fontSize = 11, maxLines = 2 }),
      }),
    }),
  }
  for _, row in ipairs(details or {}) do
    table.insert(children, row)
  end
  return ui.column({ gap = 3, paddingV = 4 }, children)
end

local function typecSection(report)
  if #report.ports == 0 then
    return nil
  end
  local children = { sectionTitle(noctalia.tr("panel.typec")) }
  for _, port in ipairs(report.ports) do
    local s = port.summary
    table.insert(children, card(s.status, port.name .. " · " .. s.headline, s.subtitle,
      detailRows(s.bullets, 10)))
  end
  return ui.column({ gap = 6 }, children)
end

local function ecSection(report)
  if #report.ec.ports == 0 then
    return nil
  end
  local heading = report.ec.framework and noctalia.tr("panel.framework") or noctalia.tr("panel.ec")
  local children = { sectionTitle(heading) }
  for _, port in ipairs(report.ec.ports) do
    table.insert(children, card(port.status, port.title, port.subtitle, detailRows(port.details)))
  end
  return ui.column({ gap = 6 }, children)
end

local function firmwareSection(report)
  local version = report.ecVersion
  local access = report.ec.access
  if version == nil and access == nil then
    return nil
  end

  local lines = {}
  if version then
    local build = version.rw_version
    if build == nil or build == "" then
      build = version.ro_version
    end
    if build then table.insert(lines, "Firmware: " .. build) end
    if version.firmware_copy then table.insert(lines, "Copy: " .. version.firmware_copy) end
    if version.board_version then table.insert(lines, "Board version: " .. version.board_version) end
  end
  if access then table.insert(lines, "PD power info: " .. access) end

  local children = { sectionTitle(noctalia.tr("panel.firmware")) }
  for _, row in ipairs(detailRows(lines)) do
    table.insert(children, row)
  end
  if access == "Permission denied" then
    table.insert(children, ui.label({
      text = noctalia.tr("panel.permission-hint"),
      color = "on_surface_variant",
      fontSize = 11,
      maxLines = 4,
    }))
  end
  return ui.column({ gap = 3 }, children)
end

local function advancedSection(report)
  if #report.advanced == 0 then
    return nil
  end
  local children = { sectionTitle(noctalia.tr("panel.advanced")) }
  for _, device in ipairs(report.advanced) do
    table.insert(children, card("device", device.source .. " " .. device.name,
      device.summary or device.name))
  end
  return ui.column({ gap = 6 }, children)
end

local function usbSection(report)
  if #report.usb == 0 then
    return nil
  end
  local children = { sectionTitle(noctalia.tr("panel.usb")) }
  for _, device in ipairs(report.usb) do
    table.insert(children, card("device", device.title or device.name,
      device.summaryText or device.name, detailRows(device.bullets or {}, 4)))
  end
  return ui.column({ gap = 6 }, children)
end

-- Shown when both sysfs classes are empty, which is the common case on a laptop
-- whose firmware negotiates PD without handing identity data to the kernel.
local function emptyState(report)
  local children = {
    ui.row({ gap = 8, align = "center" }, {
      ui.glyph({ name = "plug-off", size = 16, color = "on_surface_variant" }),
      ui.label({ text = noctalia.tr("panel.empty"), color = "on_surface", fontWeight = "bold" }),
    }),
    ui.label({
      text = noctalia.tr("panel.empty-detail"),
      color = "on_surface_variant",
      fontSize = 11,
      maxLines = 8,
    }),
  }
  if report.ec.access and report.ec.access ~= "Available" then
    table.insert(children, ui.label({
      text = "Chrome EC: " .. report.ec.access,
      color = "on_surface_variant",
      fontSize = 11,
      maxLines = 2,
    }))
  end
  return ui.column({ gap = 6 }, children)
end

function onOpen()
  local report = noctalia.state.get(STATE_KEY)

  if type(report) ~= "table" then
    panel.render(ui.column({ gap = 12, padding = 16 }, {
      ui.label({ text = noctalia.tr("tooltip.scanning"), color = "on_surface_variant" }),
    }))
    return
  end

  local sections = {}
  local function push(section)
    if section ~= nil then
      if #sections > 0 then
        table.insert(sections, ui.separator({ color = "outline" }))
      end
      table.insert(sections, section)
    end
  end

  if report.anySource then
    push(typecSection(report))
    push(ecSection(report))
  else
    push(emptyState(report))
  end
  push(firmwareSection(report))
  push(advancedSection(report))
  push(usbSection(report))

  local watts = report.bar and report.bar.watts

  panel.render(ui.column({ gap = 8, padding = 14 }, {
    ui.row({ gap = 8, align = "center" }, {
      ui.glyph({ name = "plug-connected", size = 16, color = "primary" }),
      ui.label({ text = "WhatCable", color = "on_surface", fontWeight = "bold", flexGrow = 1 }),
      ui.label({
        text = watts and string.format("%.1f W", watts) or "",
        color = "primary",
        fontWeight = "bold",
      }),
    }),
    ui.scroll({ flexGrow = 1 }, {
      ui.column({ gap = 8 }, sections),
    }),
  }))
end
