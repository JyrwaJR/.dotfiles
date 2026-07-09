---@class opencode-status.Config
---@field show_spinner boolean
---@field show_elapsed boolean
---@field show_agent boolean
---@field show_model boolean
---@field icons { idle: string, busy: string, error: string, disconnected: string, pending: string, thinking: string, tool: string }
---@field spinner_frames string[]
---@field spinner_speed_ms integer

local M = {
  ---Display a spinner while the agent is busy
  show_spinner = true,
  ---Display elapsed time while the agent is busy
  show_elapsed = true,
  ---Display the currently active agent name (fetched from server on connect)
  show_agent = true,
  ---Display model name when available (reserved for future use — no current API)
  show_model = false,
  ---Icons for each state
  icons = {
    idle = "󰚩",
    busy = "󱜙",
    error = "󱚡",
    disconnected = "󱚧",
    pending = "󰅚",  -- bell, needs user attention
    thinking = "󰠠",
    tool = "󰘔",
  },
  ---Spinner animation frames
  spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  ---Spinner tick interval in milliseconds
  spinner_speed_ms = 100,
}

---Merge user options with defaults by mutating M in-place.
---Does NOT reassign M — modules that captured M via require() keep the reference.
---@param opts? opencode-status.Config
function M.setup(opts)
  if not opts then
    return
  end
  for k, v in pairs(opts) do
    if type(v) == "table" and type(M[k]) == "table" then
      M[k] = vim.tbl_deep_extend("force", M[k], v)
    else
      M[k] = v
    end
  end
end

return M