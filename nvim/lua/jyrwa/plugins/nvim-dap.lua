return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "mxsdev/nvim-dap-vscode-js",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("nvim-dap-virtual-text").setup()

    -- ============================================================
    -- 1. Breakpoint signs
    -- ============================================================
    vim.fn.sign_define("DapBreakpoint", {
      text = "🔴",
      texthl = "DiagnosticError",
    })
    vim.fn.sign_define("DapStopped", {
      text = "▶",
      texthl = "DiagnosticWarn",
    })
    vim.fn.sign_define("DapBreakpointRejected", {
      text = "✗",
      texthl = "DiagnosticError",
    })

    -- ============================================================
    -- 2. ADAPTER SETUP (via dap-vscode-js)
    --    Requires `:MasonInstall js-debug-adapter`.
    --    The `adapters` list tells setup() which debug types to
    --    register (pwa-node, pwa-chrome, node-terminal, etc.).
    -- ============================================================
    require("dap-vscode-js").setup({
      node_path = "node",
      -- debugger_path is unused when debugger_cmd is set — the plugin
      -- looks for <debugger_path>/out/src/vsDebugServer.js, but mason
      -- ships the raw source without the build output, so that check
      -- always fails.  debugger_cmd bypasses the check and points
      -- directly to the real entrypoint.
      debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug",
      debugger_cmd = {
        "node",
        vim.fn.stdpath("data")
          .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
      },
      -- `adapters` tells setup() which debugger types to register.
      -- Accepted values are: "pwa-node", "pwa-chrome", "pwa-msedge",
      -- "node-terminal", "pwa-extensionHost".
      adapters = { "pwa-node", "pwa-chrome", "node-terminal" },
    })

    -- ============================================================
    -- 3. HELPERS
    --    One `prompt()` helper backs every dynamic value below
    --    (URL, port, npm script) so nothing in this file is
    --    hardcoded to one machine or one project — you type the
    --    real value (or just hit <CR> to accept the default) each
    --    time you launch. dap resolves config fields inside its own
    --    coroutine, so pulling a value out of an async
    --    `vim.ui.input` call means round-tripping through a second
    --    coroutine — the same trick `dap.utils.pick_process` uses
    --    internally.
    -- ============================================================
    local function prompt(opts)
      return function()
        local co = coroutine.running()
        return coroutine.create(function()
          vim.ui.input({ prompt = opts.prompt, default = opts.default }, function(input)
            input = input or opts.default
            if opts.numeric then
              input = tonumber(input)
            end
            coroutine.resume(co, input)
          end)
        end)
      end
    end

    -- ============================================================
    -- 4. CONFIGURATIONS
    --    Grouped by what you're debugging, all registered for every
    --    JS/TS filetype. `dap.continue()` (see keymaps below) pops
    --    up a picker whenever more than one config matches the
    --    current file, so all of these live side by side — just
    --    pick whichever fits the project you're in that day.
    -- ============================================================
    local js_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

    for _, language in ipairs(js_languages) do
      dap.configurations[language] = {

        -- ── Node.js / Express / any backend script ────────────────
        {
          type = "pwa-node",
          request = "attach",
          name = "Node: Attach to Process",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Node: Launch Current File",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Node: Launch Current File (TS, via tsx)",
          -- Needs `tsx` in the project (npm i -D tsx). Point this at
          -- node_modules/.bin/ts-node instead if that's what you use.
          runtimeExecutable = "${workspaceFolder}/node_modules/.bin/tsx",
          program = "${file}",
          cwd = "${workspaceFolder}",
          skipFiles = { "<node_internals>/**" },
          resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
        },
        {
          type = "node-terminal",
          request = "launch",
          name = "Node: Run npm/yarn/pnpm Script",
          -- Covers Express behind nodemon/ts-node-dev, or any other
          -- dev script — type the real command if "npm run dev"
          -- isn't the one your package.json uses.
          command = prompt({ prompt = "Command: ", default = "npm run dev" }),
          cwd = "${workspaceFolder}",
        },

        -- ── Next.js ────────────────────────────────────────────────
        -- Mirrors Next.js's own documented two-config setup. Run
        -- "Debug Server-Side" first; once the terminal prints
        -- "- Local: http://localhost:3000", run "Debug Client-Side"
        -- to attach a browser alongside it. nvim-dap doesn't support
        -- VS Code's `serverReadyAction` yet (open request:
        -- mfussenegger/nvim-dap#1559) — that's the feature that
        -- auto-chains these two configs in VS Code — so doing it as
        -- two manual steps is currently the reliable way in Neovim.
        {
          type = "node-terminal",
          request = "launch",
          name = "Next.js: Debug Server-Side",
          command = prompt({ prompt = "Command: ", default = "npm run dev -- --inspect" }),
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Next.js: Debug Client-Side",
          url = prompt({ prompt = "URL: ", default = "http://localhost:3000" }),
          webRoot = "${workspaceFolder}",
          sourceMaps = true,
        },

        -- ── Web React (Vite, CRA, or any browser client) ───────────
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Web: Launch Chrome",
          url = prompt({ prompt = "URL: ", default = "http://localhost:3000" }),
          webRoot = "${workspaceFolder}",
          sourceMaps = true,
          userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
        },
        {
          type = "pwa-chrome",
          request = "attach",
          name = "Web: Attach Chrome (port 9222)",
          port = 9222,
          webRoot = "${workspaceFolder}",
          sourceMaps = true,
        },

        -- ── Expo / React Native (Hermes) — experimental ────────────
        -- Hermes speaks the Chrome DevTools Protocol, so pwa-chrome
        -- *can* attach to it, but there's no first-class nvim-dap
        -- support for React Native the way VS Code's "React Native
        -- Tools" extension provides it — breakpoints can be flaky or
        -- get rejected. For something that reliably works, use React
        -- Native DevTools instead of this config: run
        -- `npx expo start`, then press `j` in that terminal. Reach
        -- for the config below only if you specifically want
        -- breakpoints inside Neovim and are fine with best-effort.
        {
          type = "pwa-chrome",
          request = "attach",
          name = "Expo/RN: Attach to Hermes (experimental)",
          -- "localhost", not your machine's LAN IP: nvim-dap talks to
          -- Metro's inspector proxy on your dev machine, not to the
          -- phone/emulator directly — that's true even when you're
          -- debugging on a physical device. If localhost doesn't
          -- connect (WSL2, devcontainers), try 127.0.0.1 instead.
          address = "localhost",
          port = prompt({ prompt = "Metro port: ", default = "8081", numeric = true }),
          webRoot = "${workspaceFolder}",
          sourceMaps = true,
        },
      }
    end

    -- ============================================================
    -- 5. KEYMAPS
    -- ============================================================
    local keymap = vim.keymap.set
    keymap("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
    keymap("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
    keymap("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Breakpoint" })
    keymap("n", "<leader>dB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Debug: Conditional Breakpoint" })
    keymap("n", "<leader>dt", dap.terminate, { desc = "Debug: Stop" })
    keymap("n", "<leader>dX", dap.clear_breakpoints, { desc = "Debug: Clear All" })

    -- Stepping
    keymap("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
    keymap("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
    keymap("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })

    -- UI / REPL
    keymap("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
    keymap("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: Toggle REPL" })

    -- ============================================================
    -- 6. Auto open/close UI
    -- ============================================================
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
}
