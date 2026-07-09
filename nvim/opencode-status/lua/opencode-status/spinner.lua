local config = require("opencode-status.config")
local state = require("opencode-status.state")

local M = {}

---@type vim.uv.uv_timer_t|nil
local timer = nil
local frame_index = 1

function M.start()
  if timer then
    return
  end

  frame_index = 1
  state.set_spinner_frame(config.spinner_frames[frame_index])

  timer = vim.uv.new_timer()
  if timer then
    timer:start(
      config.spinner_speed_ms,
      config.spinner_speed_ms,
      vim.schedule_wrap(function()
        frame_index = (frame_index % #config.spinner_frames) + 1
        state.set_spinner_frame(config.spinner_frames[frame_index])
        state.tick_elapsed()
        vim.cmd("redrawstatus")
      end)
    )
  end
end

function M.stop()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
  state.set_spinner_frame("")
end

return M