local config = require("opencode-status.config")
local state = require("opencode-status.state")

local M = {}

---Build the lualine component string from current state.
---Called on every lualine refresh (fast — no allocations, no I/O).
---@return string
function M.build()
  if not state.connected or state.status == "disconnected" then
    return config.icons.disconnected
  end

  local parts = {}

  if state.status == "idle" then
    parts[#parts + 1] = config.icons.idle
    -- Agent name
    if config.show_agent and state.agent_name ~= "" then
      parts[#parts + 1] = " "
      parts[#parts + 1] = state.agent_name
    end
  elseif state.status == "pending" then
    parts[#parts + 1] = config.icons.pending
    parts[#parts + 1] = " "
    parts[#parts + 1] = "Attention"
    if state.pending_permission ~= "" then
      parts[#parts + 1] = " ("
      parts[#parts + 1] = state.pending_permission
      parts[#parts + 1] = ")"
    end
  elseif state.status == "busy" then
    -- Spinner
    if config.show_spinner and state.spinner_frame ~= "" then
      parts[#parts + 1] = state.spinner_frame
    else
      parts[#parts + 1] = config.icons.busy
    end
    parts[#parts + 1] = " "

    -- Activity indicator
    parts[#parts + 1] = config.icons.thinking

    -- Agent name during busy
    if config.show_agent and state.agent_name ~= "" then
      parts[#parts + 1] = " "
      parts[#parts + 1] = state.agent_name
    end

    -- Elapsed time
    if config.show_elapsed and state.elapsed > 0 then
      parts[#parts + 1] = " ("
      parts[#parts + 1] = tostring(state.elapsed)
      parts[#parts + 1] = "s)"
    end
  elseif state.status == "error" then
    parts[#parts + 1] = config.icons.error
    parts[#parts + 1] = " Error"
  end

  return table.concat(parts)
end

return M