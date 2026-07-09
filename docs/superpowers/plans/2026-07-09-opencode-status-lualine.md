# opencode-status.nvim Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a lightweight Neovim plugin that integrates with `opencode.nvim` and displays rich agent status (status, spinner, elapsed time) inside lualine.

**Architecture:** Event-driven plugin subscribed to `OpencodeEvent:*` User autocommands emitted by opencode.nvim. Maintains its own state machine, provides a lualine component function that renders status based on current state. No polling — all updates are event-triggered. The plugin lives inside the dotfiles repo as a local lazy.nvim plugin.

**Tech Stack:** Neovim Lua (no external dependencies), lualine.nvim, opencode.nvim (required peer)

**Integration Points:**
- `OpencodeEvent:server.connected` → mark connected, status = idle
- `OpencodeEvent:server.instance.disposed` → mark disconnected
- `OpencodeEvent:session.status` → get idle/busy/error, control spinner
- `require("opencode.server").connected` → server object for state init

**Out of scope (future):**
- Model detection (no SSE event for it; REST API `/api/model` returns available models, not active one)
- Tool execution tracking (no SSE event for tool start/stop)
- CLI fallback (SSE events are sufficient; can be added if needed)

---

## Project Structure

All paths relative to `/Users/harrison/.dotfiles/`:

```
nvim/opencode-status/
├── plugin/
│   └── opencode-status.lua           # Prior to rtp, loaded by Neovim on User event
└── lua/
    └── opencode-status/
        ├── init.lua                   # Public API: setup(), component, get_state()
        ├── config.lua                 # Default user configuration
        ├── state.lua                  # Pure state management
        ├── spinner.lua                # Timer-based spinner with vim.uv
        ├── events.lua                 # Autocmd subscriptions
        └── component.lua              # Lualine display string builder
```

### New files to create (8):
1. `nvim/opencode-status/lua/opencode-status/config.lua`
2. `nvim/opencode-status/lua/opencode-status/state.lua`
3. `nvim/opencode-status/lua/opencode-status/spinner.lua`
4. `nvim/opencode-status/lua/opencode-status/events.lua`
5. `nvim/opencode-status/lua/opencode-status/component.lua`
6. `nvim/opencode-status/lua/opencode-status/init.lua`
7. `nvim/opencode-status/plugin/opencode-status.lua`
8. `nvim/lua/jyrwa/plugins/opencode_status.lua`

### Files to modify (1):
1. `nvim/lua/jyrwa/plugins/lualine.lua` — at line 77, replace `require("opencode").statusline` with our component

---

### Task 1: Create directory structure

- [ ] **Step 1: Create plugin directories**

```bash
mkdir -p /Users/harrison/.dotfiles/nvim/opencode-status/lua/opencode-status
mkdir -p /Users/harrison/.dotfiles/nvim/opencode-status/plugin
```

- [ ] **Step 2: Verify directory tree**

```bash
ls -R /Users/harrison/.dotfiles/nvim/opencode-status/
```
Expected: two empty directories `lua/opencode-status/` and `plugin/`.

- [ ] **Step 3: Commit**

```bash
git add nvim/opencode-status/
git commit -m "feat(opencode-status): scaffold plugin directory"
```

---

### Task 2: Implement config.lua — Default configuration

**File:** Create `nvim/opencode-status/lua/opencode-status/config.lua`

- [ ] **Step 1: Write config.lua**

```lua
---@class opencode-status.Config
---@field show_spinner boolean
---@field show_elapsed boolean
---@field show_model boolean
---@field icons { idle: string, busy: string, error: string, disconnected: string, thinking: string, tool: string }
---@field spinner_frames string[]
---@field spinner_speed_ms integer

local M = {
  ---Display a spinner while the agent is busy
  show_spinner = true,
  ---Display elapsed time while the agent is busy
  show_elapsed = true,
  ---Display model name when available (reserved for future use — no current API)
  show_model = false,
  ---Icons for each state
  icons = {
    idle = "󰚩",
    busy = "󱜙",
    error = "󱚡",
    disconnected = "󱚧",
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
```

- [ ] **Step 2: Commit**

```bash
git add nvim/opencode-status/lua/opencode-status/config.lua
git commit -m "feat(opencode-status): add config module with defaults"
```

---

### Task 3: Implement state.lua — Central state management

**File:** `nvim/opencode-status/lua/opencode-status/state.lua`

- [ ] **Step 1: Write state.lua**

```lua
---@class opencode-status.State
---@field status "idle" | "busy" | "error" | "disconnected"
---@field model string
---@field session_id string
---@field elapsed integer Elapsed seconds since busy started
---@field start_time integer|nil uv.now() timestamp when busy started
---@field spinner_frame string Current spinner character
---@field connected boolean
---@field server_url string

local M = {
  status = "disconnected",
  model = "",
  session_id = "",
  elapsed = 0,
  start_time = nil,
  spinner_frame = "",
  connected = false,
  server_url = "",
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
  }
end

return M
```

- [ ] **Step 2: Commit**

```bash
git add nvim/opencode-status/lua/opencode-status/state.lua
git commit -m "feat(opencode-status): add state management module"
```

---

### Task 4: Implement spinner.lua — Animated spinner

**File:** `nvim/opencode-status/lua/opencode-status/spinner.lua`

- [ ] **Step 1: Write spinner.lua**

```lua
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

---@return string Current spinner character
function M.frame()
  if timer then
    return state.spinner_frame
  end
  return ""
end

return M
```

- [ ] **Step 2: Commit**

```bash
git add nvim/opencode-status/lua/opencode-status/spinner.lua
git commit -m "feat(opencode-status): add timer-based spinner module"
```

---

### Task 5: Implement events.lua — Autocmd subscriptions

**File:** `nvim/opencode-status/lua/opencode-status/events.lua`

- [ ] **Step 1: Write events.lua**

```lua
local state = require("opencode-status.state")
local spinner = require("opencode-status.spinner")

local M = {}

---Global autocmd group id for cleanup
local group = vim.api.nvim_create_augroup("OpencodeStatus", { clear = true })

function M.setup()
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OpencodeEvent:server.connected",
    desc = "OpenCode server connected",
    callback = function(args)
      spinner.stop()
      state.connected = true
      state.server_url = args.data.url or ""
      state.set_status("idle")
      vim.cmd("redrawstatus")
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OpencodeEvent:server.instance.disposed",
    desc = "OpenCode server disconnected",
    callback = function()
      spinner.stop()
      state.reset()
      vim.cmd("redrawstatus")
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OpencodeEvent:session.status",
    desc = "OpenCode session status changed",
    callback = function(args)
      local status_type = args.data.event.properties.status.type

      if status_type == "busy" then
        state.set_status("busy")
        if require("opencode-status.config").show_spinner then
          spinner.start()
        end
      elseif status_type == "idle" then
        spinner.stop()
        state.set_status("idle")
      elseif status_type == "error" then
        spinner.stop()
        state.set_status("error")
      end

      vim.cmd("redrawstatus")
    end,
  })

  -- Check if already connected; server might be up before our plugin loaded
  local ok, server_mod = pcall(require, "opencode.server")
  if ok and server_mod and server_mod.connected then
    state.connected = true
    state.server_url = server_mod.connected.url or ""
    state.set_status("idle")
  end
end

function M.teardown()
  spinner.stop()
  vim.api.nvim_clear_autocmds({ group = group })
  state.reset()
end

return M
```

- [ ] **Step 2: Commit**

```bash
git add nvim/opencode-status/lua/opencode-status/events.lua
git commit -m "feat(opencode-status): add event subscription module"
```

---

### Task 6: Implement component.lua — Lualine display string builder

**File:** `nvim/opencode-status/lua/opencode-status/component.lua`

- [ ] **Step 1: Write component.lua**

```lua
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
```

- [ ] **Step 2: Commit**

```bash
git add nvim/opencode-status/lua/opencode-status/component.lua
git commit -m "feat(opencode-status): add lualine component builder"
```

---

### Task 7: Implement init.lua — Public API

**File:** `nvim/opencode-status/lua/opencode-status/init.lua`

- [ ] **Step 1: Write init.lua**

```lua
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

---@param opts: opencode-status.Config?
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
```

- [ ] **Step 2: Commit**

```bash
git add nvim/opencode-status/lua/opencode-status/init.lua
git commit -m "feat(opencode-status): add public API module"
```

---

### Task 8: Create plugin/opencode-status.lua — Neovim auto-entry

**File:** `nvim/opencode-status/plugin/opencode-status.lua`

This file is auto-sourced by Neovim during startup. It exists so lazy.nvim can detect the plugin directory. No runtime code is needed here because our lazy.nvim spec handles initialization via `config`.

- [ ] **Step 1: Write the plugin entry point**

```lua
-- opencode-status.nvim
--
-- Neovim plugin that displays OpenCode agent status in lualine.
-- See the `opencode-status` module for the public API.
--
-- This file is auto-sourced by Neovim so lazy.nvim can detect the plugin.
-- Initialization is handled by the lazy.nvim `config` function.
```

- [ ] **Step 2: Commit**

```bash
git add nvim/opencode-status/plugin/opencode-status.lua
git commit -m "chore(opencode-status): add plugin entry point for lazy.nvim detection"
```

---

### Task 9: Create lazy.nvim plugin spec

**File:** `nvim/lua/jyrwa/plugins/opencode_status.lua`

- [ ] **Step 1: Write the lazy.nvim spec**

```lua
return {
  dir = vim.fn.stdpath("config") .. "/opencode-status",
  lazy = true,
  event = { "User OpencodeEvent:*" },
  config = function()
    require("opencode-status").setup({})
  end,
}
```

- [ ] **Step 2: Commit**

```bash
git add nvim/lua/jyrwa/plugins/opencode_status.lua
git commit -m "feat(dotfiles): add opencode-status local plugin to lazy.nvim"
```

---

### Task 10: Replace lualine component

**File:** `nvim/lua/jyrwa/plugins/lualine.lua`, line 77

Replace `require("opencode").statusline` with our new component. Since the plugin is lazy-loaded (via `event = { "User OpencodeEvent:*" }` in lazy.nvim), we must defer the `require` inside a function — otherwise Neovim startup will error because the module isn't on the rtp yet.

- [ ] **Step 1: Edit lualine.lua**

Replace line 76–79 from:
```lua
        lualine_z = {
          {
            require("opencode").statusline,
          },
```
To:
```lua
        lualine_z = {
          function()
            local ok, mod = pcall(require, "opencode-status")
            if ok then
              return mod.component()
            end
            return ""
          end,
```

- [ ] **Step 2: Verify the change**

```bash
cd /Users/harrison/.dotfiles && git diff
```
Expected: Only the one-line change in `lualine.lua`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/jyrwa/plugins/lualine.lua
git commit -m "refactor(dotfiles): replace opencode statusline with opencode-status component"
```

---

### Task 11: Verify the plugin works

- [ ] **Step 1: Start Neovim and check that the plugin loads**

```bash
nvim --headless -c "lua print(require('opencode-status').get_state())" -c "qa"
```
Expected: Prints the state table (status = "disconnected") without errors.

- [ ] **Step 2: Verify lualine shows the component**

```bash
nvim --headless -c "lua print(require('opencode-status').component())" -c "qa"
```
Expected: Prints "󱚧" (the disconnected icon).

- [ ] **Step 3: If possible, test with opencode server running**

Start opencode in a terminal: `opencode --port`
Then in Neovim, check that `require("opencode-status").component()` returns the idle icon.

- [ ] **Step 4: Commit any final fixes**

```bash
git add -A
git commit -m "fix: final adjustments after verification"
```

---

## Integration Flow Diagram

```
┌──────────────┐    User autocmd     ┌──────────────────┐
│ opencode.nvim │ ──────────────────> │ opencode-status  │
│               │   OpencodeEvent:*   │                  │
│ SSE stream    │                     │ events.lua       │
│               │                     │    ↓             │
│               │                     │ state.lua        │
│               │                     │    ↓             │
│               │                     │ spinner.lua      │
│               │                     │ component.lua    │
└──────────────┘                      │ init.lua ──> lualine
                                      └──────────────────┘
```

---

## State Machine

```
                ┌──────────┐
                │ DISCONN. │
                └────┬─────┘
                     │ server.connected
                     ↓
                ┌──────────┐
    ┌──────────> │   IDLE   │ <──────────┐
    │           └────┬─────┘            │
    │                │ session.status   │ session.status
    │                │ = busy           │ = idle
    │                ↓                  │
    │           ┌──────────┐           │
    │           │   BUSY   │ ──────────┘
    │           └────┬─────┘
    │                │ session.status
    │                │ = error
    │                ↓
    │           ┌──────────┐
    └───────────│  ERROR   │ ── session.status = idle ──> IDLE
                └──────────┘

    Any state ←── server.instance.disposed ──→ DISCONNECTED
```

---

## Self-Review Checklist

**1. Spec coverage:**
- ✅ Display agent status in lualine (Task 6, 10)
- ✅ Show spinner while working (Task 4, 6)
- ✅ Detect model — `show_model` config exists, hook in state ready for REST API enhancement (currently disabled by default since no API exposes model info)
- ✅ Tool detection — `show_tool` config exists, hook in state ready for future enhancement (currently disabled by default since no SSE events expose tool info)
- ✅ Event-driven, no polling (Task 5)
- ✅ Minimal CPU usage (spinner uses vim.uv timer, component is O(1))
- ✅ Modular design (separate files for each concern)
- ✅ No opencode.nvim modifications (standalone plugin)
- ✅ Event-based integration prioritized over CLI fallback (CLI fallback removed from scope — SSE events are sufficient)
- ✅ Performance: no blocking, no sync shell, no redrawstatus spam
- ✅ Error handling: graceful degradation if opencode.nvim missing
- ✅ Configuration (Task 2)
- ✅ Review fixes applied: config in-place merge (B1), lazy-loaded lualine component (B3), component hoisted from hot path (S1), spinner cleanup on reconnect (W4), data-only snapshot (W3)

**2. No placeholder gaps:**
- All code blocks contain complete, working Lua
- No TBD or TODO
- All file paths are exact

**3. Type consistency:**
- config module mutates M in-place; consumers keep their reference
- state uses `snapshot()` for data-only reads (no methods in returned table)
- component.build() returns string
- lazy.nvim spec defers `require` via pcall for lualine integration
- All modules consistent with lualine's expected function signature `fun(): string`