--!nonstrict
-- panel.luau — detail popup opened from the bar widget. Reads the same shared
-- state and renders both rate limits plus today's local activity.

local STATE_KEY = "model-usage/claude"

local function limit_block(label, pct, reset)
  local value = (pct ~= nil and pct >= 0) and (tostring(pct) .. "%") or "n/a"
  local sub = (reset ~= nil and reset ~= "") and ("resets in " .. reset) or "no reset info"
  return ui.column({ gap = 2 }, {
    ui.row({ gap = 8, align = "center" }, {
      ui.label({ text = label, color = "on_surface", fontWeight = "bold" }),
      ui.label({ text = value, color = "primary", fontWeight = "bold" }),
    }),
    ui.label({ text = sub, color = "on_surface_variant" }),
  })
end

function onOpen(context)
  local d = noctalia.state.get(STATE_KEY) or {}

  local title = "Claude Code"
  if d.tier ~= nil and d.tier ~= "" then title = title .. "  ·  " .. d.tier end

  local children = {
    ui.label({ text = title, color = "on_surface", fontWeight = "bold" }),
  }

  if not d.ok then
    table.insert(children, ui.label({
      text = d.status or "Usage unavailable",
      color = "on_surface_variant",
    }))
    if d.auth == "none" or d.auth == "expired" then
      table.insert(children, ui.label({
        text = "Run `claude` and sign in to restore authoritative usage.",
        color = "on_surface_variant",
      }))
    end
  else
    table.insert(children, limit_block("Session (5-hour)", d.session_pct, d.session_reset))
    table.insert(children, limit_block("Weekly (7-day)", d.weekly_pct, d.weekly_reset))
  end

  table.insert(children, ui.row({ gap = 6, align = "center" }, {
    ui.glyph({ name = "message", size = 13, color = "on_surface_variant" }),
    ui.label({
      text = (d.today_prompts or 0) .. " prompts · " .. (d.today_sessions or 0)
        .. " sessions today",
      color = "on_surface_variant",
    }),
  }))

  panel.render(ui.column({ gap = 12, paddingH = 16 }, children))
end
