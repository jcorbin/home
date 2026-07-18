--!nonstrict
-- service.luau — poll the claude-usage helper on a timer and publish the
-- parsed result to plugin state, where the widget and panel read it.

local STATE_KEY = "model-usage/claude"
-- runAsync runs through the shell, so $HOME expands. `bash <path>` avoids
-- depending on the exec bit surviving install/sync.
local CMD = 'bash "$HOME/.local/share/noctalia/plugins/model-usage/claude-usage"'

local function trim(s)
  return (tostring(s or ""):gsub("^%s*(.-)%s*$", "%1"))
end

local function interval_ms()
  return (noctalia.getConfig("refresh_interval") or 30) * 1000
end

local function poll()
  noctalia.runAsync(CMD, function(r)
    local out = trim(r and r.stdout or "")
    if out == "" then
      noctalia.state.set(STATE_KEY, { ok = false, status = "No output" })
      return
    end
    local ok, data = pcall(noctalia.json.decode, out)
    if ok and type(data) == "table" then
      noctalia.state.set(STATE_KEY, data)
    else
      noctalia.state.set(STATE_KEY, { ok = false, status = "Parse error" })
    end
  end, 15000)
end

-- update() fires on the setUpdateInterval cadence (and once shortly after load).
function update()
  noctalia.setUpdateInterval(interval_ms())
  poll()
end

function onConfigChanged()
  noctalia.setUpdateInterval(interval_ms())
end
