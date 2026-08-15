--!nonstrict
-- widget.luau — bar item.
--
-- Purely reactive: the service entry does the scanning and precomputes the bar
-- text and tooltip, so this paints whatever is in shared state and nothing more.
-- Click opens the detail panel.

local STATE_KEY = "whatcable/report"

local function paint(report)
  local bar = (type(report) == "table" and report.bar) or nil

  barWidget.setGlyph(noctalia.getConfig("glyph") or "plug-connected")

  if bar == nil then
    barWidget.setText("")
    barWidget.setColor("on_surface_variant")
    barWidget.setGlyphColor("on_surface_variant")
    barWidget.setTooltip(noctalia.tr("tooltip.scanning"))
    return
  end

  local display = noctalia.getConfig("display") or "power"
  local text = ""
  if display == "power" and bar.watts then
    text = string.format("%.0fW", bar.watts)
  elseif display == "ports" and bar.total > 0 then
    text = bar.connected .. "/" .. bar.total
  end
  barWidget.setText(text)

  -- charging is the one state worth pulling the eye; a plugged-but-idle port
  -- reads as normal text, and "nothing exposed" recedes.
  local color = "on_surface"
  if bar.status == "charging" then
    color = "primary"
  elseif bar.status == "unavailable" then
    color = "on_surface_variant"
  elseif bar.status == "idle" then
    color = "on_surface_variant"
  end
  barWidget.setColor(color)
  barWidget.setGlyphColor(color)
  barWidget.setTooltip(bar.tooltip or "")
end

noctalia.state.watch(STATE_KEY, paint)
paint(noctalia.state.get(STATE_KEY))

function onClick()
  noctalia.togglePanel("jcorbin/whatcable:panel")
end

-- So the panel can also be opened from a keybind or a script:
--   noctalia msg plugin jcorbin/whatcable:indicator focused toggle
function onIpc(event)
  if event == "toggle" or event == "click" then
    onClick()
  end
end
