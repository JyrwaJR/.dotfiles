return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("nvim-dap-virtual-text").setup()

    -- 1. ADAPTER SETUP (The "Bridge")
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        -- Corrected path to the Mason-installed JS Debugger
        args = {
          vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
          "${port}",
        },
      },
    }

    -- 2. CONFIGURATIONS
    local js_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
    for _, language in ipairs(js_languages) do
      dap.configurations[language] = {
        -- For Next.js/Node API
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach: Next.js / Node (9229)",
          address = "localhost",
          port = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input({ prompt = "Enter port (default: 9230): ", default = "9230" }, function(input)
                coroutine.resume(co, tonumber(input) or 9230)
              end)
            end)
          end,
          cwd = "${workspaceFolder}",
          webRoot = "${workspaceFolder}",
          sourceMaps = true,
          sourceMapPathOverrides = {
            ["webpack://_N_E/*"] = "${webRoot}/*",
            ["webpack://*"] = "${webRoot}/*",
          },
          resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
          skipFiles = { "**/node_modules/**", "<node_internals>/**" },
        },
        -- For React Native
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach: Metro (8081)",
          address = "localhost",
          port = 8081,
          sourceMaps = true,
          resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
        },
        -- Custom
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach: Pick Process",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
    end

    -- 3. KEYMAPS (Starting with 'd')
    local keymap = vim.keymap.set
    keymap("n", "<leader>dc", function()
      if vim.fn.filereadable(".vscode/launch.json") == 1 then
        require("dap.ext.vscode").load_launchjs(nil, { ["pwa-node"] = js_languages })
      end
      -- If in a DAP UI buffer (like console), run_last instead of trying to debug the console buffer
      local ft = vim.bo.filetype
      if
        ft == "dapui_console"
        or ft == "dapui_watches"
        or ft == "dapui_stacks"
        or ft == "dapui_breakpoints"
        or ft == "dap-repl"
      then
        dap.run_last()
      else
        dap.continue()
      end
    end, { desc = "Debug: Start/Continue" })

    keymap("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
    keymap("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Breakpoint" })
    keymap("n", "<leader>dt", dap.terminate, { desc = "Debug: Stop" })
    keymap("n", "<leader>dX", dap.clear_breakpoints, { desc = "Debug: Clear All" })

    -- Stepping
    keymap("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
    keymap("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
    keymap("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })

    -- UI & Exit
    keymap("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
    keymap("n", "<leader>de", function()
      dap.terminate()
      dapui.close()
      vim.cmd("DapVirtualTextForceRefresh")
    end, { desc = "Debug: Exit (Stop & Close)" })

    -- UI Logic
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
  end,
}
