---@class opencode-status.State
---@field status "idle" | "busy" | "error" | "pending" | "disconnected"
---@field model string
---@field session_id string
---@field elapsed integer Elapsed seconds since busy started
---@field start_time integer|nil uv.now() timestamp when busy started
---@field spinner_frame string Current spinner character
---@field connected boolean
---@field server_url string
---@field waiting_on_user boolean Agent is blocked waiting for user input (permission, question)
---@field pending_permission string|nil Current pending permission type (e.g. "edit", "tool")
---@field agent_name string Name of the currently active primary agent
---@field model_id string Model ID from the active agent (e.g. "claude-sonnet-4-20250514")

local M = {
  status = "disconnected",
  model = "",
  session_id = "",
  elapsed = 0,
  start_time = nil,
  spinner_frame = "",
  connected = false,
  server_url = "",
  attention_on_user = false,
  pending_permission = nil,
  agent_name = "",
  model_id = "",
}

function M.reset()
  M.status = "disconnected"
  M.model = ""
  M.session_id = ""
  M.elapsed = 0
  M.start_time = nil
  M.spinner_frame = ""
  M.connected = false
  M.server_url = ""
  M.attention_on_user = false
  M.pending_permission = nil
  M.agent_name = ""
  M.model_id = ""
end

function M.set_status(new_status)
  M.status = new_status
  if new_status == "busy" then
    M.start_time = vim.uv.now()
    M.elapsed = 0
  elseif new_status ~= "busy" then
    M.start_time = nil
    M.elapsed = 0
  end
end

function M.set_spinner_frame(frame)
  M.spinner_frame = frame
end

---Call periodically while busy to update elapsed time
function M.tick_elapsed()
  if M.start_time then
    M.elapsed = math.floor((vim.uv.now() - M.start_time) / 1000)
  end
end

---Return a readonly snapshot of current state (data fields only, no methods)
---@return opencode-status.State
function M.snapshot()
  return {
    status = M.status,
    model = M.model,
    session_id = M.session_id,
    elapsed = M.elapsed,
    start_time = M.start_time,
    spinner_frame = M.spinner_frame,
    connected = M.connected,
    server_url = M.server_url,
    attention_on_user = M.attention_on_user,
    pending_permission = M.pending_permission,
    agent_name = M.agent_name,
    model_id = M.model_id,
  }
end

return M