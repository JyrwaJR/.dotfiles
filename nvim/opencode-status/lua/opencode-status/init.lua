--- opencode-status.nvim
---
--- Displays OpenCode agent status inside lualine.
--- Uses OpencodeEvent:* User autocmds for event-driven updates.
---
--- # Setup:
---
--- ```lua
--- require("opencode-status").setup({
---   show_spinner = true,
---   show_elapsed = true,
--- })
--- ```
---
--- # Lualine component:
---
--- ```lua
--- require("lualine").setup({
---   sections = {
---     lualine_z = { require("opencode-status").component },
---   },
--- })
--- ```

local M = {}

local config = require("opencode-status.config")
local events = require("opencode-status.events")

---Hoisted component builder — set during setup() to avoid require() on every render
local component_build = nil

---@param opts opencode-status.Config|?
function M.setup(opts)
  config.setup(opts or {})
  events.setup()
  component_build = require("opencode-status.component").build
end

---Function to use as a lualine component.
---Usage: `{ require("opencode-status").component }` in lualine sections.
---@return string
function M.component()
  if component_build then
    return component_build()
  end
  return ""
end

---Get a snapshot of the current state for diagnostics.
---@return opencode-status.State
function M.get_state()
  return require("opencode-status.state").snapshot()
end

return M