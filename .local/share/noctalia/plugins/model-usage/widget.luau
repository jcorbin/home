--!nonstrict
-- widget.luau — bar item. Shows the worst-case (highest) rate-limit percent
-- for Claude, colored by severity. Click opens the detail panel. The service
-- entry does the polling; this just reacts to shared state.

local STATE_KEY = "model-usage/claude"

-- Highest of the session / weekly utilization; -1 if neither is known.
local function worst(data)
  local s = data.session_pct or -1
  local w = data.weekly_pct or -1
  if s < 0 and w < 0 then return -1 end
  if s < 0 then return w end
  if w < 0 then return s end
  return math.max(s, w)
end

local function pct_line(label, pct, reset)
  local v = (pct ~= nil and pct >= 0) and (tostring(pct) .. "%") or "n/a"
  if reset ~= nil and reset ~= "" then
    return label .. ": " .. v .. " (resets in " .. reset .. ")"
  end
  return label .. ": " .. v
end

local function paint(data)
  data = data or {}
  barWidget.setGlyph(noctalia.getConfig("glyph") or "brain")

  if not data.ok then
    barWidget.setText("—")
    barWidget.setGlyphColor("on_surface_variant")
    barWidget.setColor("on_surface_variant")
    barWidget.setTooltip("Claude · " .. (data.status or "unavailable"))
    return
  end

  local pct = worst(data)
  if pct < 0 then
    barWidget.setText("—")
    barWidget.setColor("on_surface_variant")
  else
    barWidget.setText(tostring(pct) .. "%")
    if pct >= 90 then
      barWidget.setColor("primary")        -- near the cap
    elseif pct >= 75 then
      barWidget.setColor("secondary")      -- getting there
    else
      barWidget.setColor("on_surface")     -- comfortable
    end
  end

  local head = "Claude"
  if data.tier ~= nil and data.tier ~= "" then head = head .. " · " .. data.tier end
  barWidget.setTooltip(table.concat({
    head,
    pct_line("Session (5h)", data.session_pct, data.session_reset),
    pct_line("Weekly (7d)", data.weekly_pct, data.weekly_reset),
    "Today: " .. (data.today_prompts or 0) .. " prompts, "
      .. (data.today_sessions or 0) .. " sessions",
  }, "\n"))
end

-- React to the service's state updates, and paint whatever's there now.
noctalia.state.watch(STATE_KEY, paint)
paint(noctalia.state.get(STATE_KEY))

function onClick()
  noctalia.togglePanel("jcorbin/model-usage:panel")
end
