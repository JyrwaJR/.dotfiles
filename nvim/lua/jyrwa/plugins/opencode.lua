return {
  "nickjvandyke/opencode.nvim",
  version = "*", -- Latest stable release
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any; goto definition on the type for details
    }

    vim.o.autoread = true -- Required for `vim.g.opencode_opts.events.reload`

    -- Recommended/example keymaps
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ")
    end, { desc = "Ask OpenCode…" })
    vim.keymap.set({ "n", "x" }, "<leader>os", function()
      require("opencode").select()
    end, { desc = "Select OpenCode…" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Append range to OpenCode", expr = true })
    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Append line to OpenCode", expr = true })

    -- Scroll
    vim.keymap.set("n", "<leader>ou", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "Scroll OpenCode up" })
    vim.keymap.set("n", "<leader>od", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "Scroll OpenCode down" })

    -- Ask raw — no @mention, just an empty prompt
    vim.keymap.set({ "n", "x" }, "<leader>oo", function()
      require("opencode").ask("")
    end, { desc = "Open OpenCode prompt" })

    -- Ask variants with @context presets
    vim.keymap.set({ "n", "x" }, "<leader>ob", function()
      require("opencode").ask("@buffer: ")
    end, { desc = "Ask about buffer" })
    vim.keymap.set({ "n", "x" }, "<leader>oB", function()
      require("opencode").ask("@buffers: ")
    end, { desc = "Ask about all buffers" })
    vim.keymap.set({ "n", "x" }, "<leader>oD", function()
      require("opencode").ask("Fix @diagnostics")
    end, { desc = "Fix diagnostics" })
    vim.keymap.set({ "n", "x" }, "<leader>or", function()
      require("opencode").ask("Review @this for correctness and readability")
    end, { desc = "Review @this" })
    vim.keymap.set({ "n", "x" }, "<leader>ox", function()
      require("opencode").ask("Explain @this and its context")
    end, { desc = "Explain @this" })

    -- Agent
    vim.keymap.set({ "n", "x" }, "<leader>oA", function()
      require("opencode").command("agent.cycle")
    end, { desc = "Cycle OpenCode agent" })

    -- Session management
    vim.keymap.set("n", "<leader>on", function()
      require("opencode").command("session.new")
    end, { desc = "New OpenCode session" })
    vim.keymap.set("n", "<leader>oi", function()
      require("opencode").command("session.interrupt")
    end, { desc = "Interrupt OpenCode session" })
    vim.keymap.set("n", "<leader>oc", function()
      require("opencode").command("session.compact")
    end, { desc = "Compact OpenCode session" })
    vim.keymap.set("n", "<leader>oS", function()
      require("opencode").command("session.select")
    end, { desc = "Select OpenCode session" })
    vim.keymap.set("n", "<leader>oU", function()
      require("opencode").command("session.undo")
    end, { desc = "Undo OpenCode session" })
    vim.keymap.set("n", "<leader>oR", function()
      require("opencode").command("session.redo")
    end, { desc = "Redo OpenCode session" })

    -- Prompt operations
    vim.keymap.set({ "n", "x" }, "<leader>op", function()
      require("opencode").command("prompt.clear")
    end, { desc = "Clear OpenCode prompt" })

    -- Server switching
    vim.keymap.set("n", "<leader>o,", function()
      require("opencode").command("server.select")
    end, { desc = "Select OpenCode server" })

    -- Toggle opencode server in a terminal split
    local opencode_cmd = "opencode --port"
    vim.keymap.set({ "n", "t" }, "<leader>ot", function()
      require("snacks.terminal").toggle(opencode_cmd, {
        win = { position = "right", enter = false },
      })
    end, { desc = "Toggle OpenCode terminal" })

    -- Terminal mode: Ctrl+h/j/k/l to navigate windows
    -- In terminal mode, keys go to the terminal by default, so we need to
    -- escape to normal mode (<C-\><C-n>) before moving windows
    vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal: go to left window" })
    vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal: go to lower window" })
    vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal: go to upper window" })
    vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal: go to right window" })

    -- Terminal window resize: <leader>sm/se are defined in core/keymaps.lua
  end,
}
