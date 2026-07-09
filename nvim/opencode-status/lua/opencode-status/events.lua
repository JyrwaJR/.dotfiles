local state = require("opencode-status.state")
local spinner = require("opencode-status.spinner")

local M = {}

---Global autocmd group id for cleanup
local group = vim.api.nvim_create_augroup("OpencodeStatus", { clear = true })

---Fetch the current primary agent info from the OpenCode server.
---Spawns a background curl job to GET /agent, parses the JSON,
---and updates state.agent_name and state.model_id.
---@param url string The server URL (e.g. "http://localhost:4096")
local function fetch_agent_info(url)
  if not url or url == "" then
    return
  end
  vim.fn.jobstart({
    "curl", "-s", "--max-time", "2",
    url .. "/agent",
  }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data or #data == 0 then
        return
      end
      local ok, agents = pcall(vim.fn.json_decode, table.concat(data))
      if not ok or type(agents) ~= "table" then
        return
      end
      -- Find the first non-hidden primary agent
      for _, agent in ipairs(agents) do
        if agent.mode == "primary" and not agent.hidden then
          state.agent_name = agent.name or ""
          if agent.model and agent.model.modelID then
            state.model_id = agent.model.modelID
          end
          vim.schedule(function()
            vim.cmd("redrawstatus")
          end)
          return
        end
      end
    end,
  })
end

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
      fetch_agent_info(state.server_url)
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

  -- Track when the agent needs user attention (e.g., file edit permission)
  -- We don't override the session status, but we set a flag so the
  -- component can show a "needs attention" indicator alongside idle.
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OpencodeEvent:permission.asked",
    desc = "OpenCode needs user attention (permission)",
    callback = function(args)
      state.attention_on_user = true
      state.pending_permission = args.data.event.properties.permission or ""
      if state.status == "idle" then
        state.set_status("pending")
      end
      vim.cmd("redrawstatus")
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OpencodeEvent:permission.replied",
    desc = "OpenCode permission resolved",
    callback = function()
      state.attention_on_user = false
      state.pending_permission = nil
      if state.status == "pending" then
        state.set_status("idle")
      end
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
        -- If there's a pending permission, stay in pending state
        if state.attention_on_user then
          state.set_status("pending")
        else
          state.set_status("idle")
        end
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
    fetch_agent_info(state.server_url)
  end
end

function M.teardown()
  spinner.stop()
  vim.api.nvim_clear_autocmds({ group = group })
  state.reset()
end

return M