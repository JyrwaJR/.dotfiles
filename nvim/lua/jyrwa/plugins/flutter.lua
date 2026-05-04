return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for better UI
  },
  config = function()
    require("flutter-tools").setup({
      ui = {
        border = "rounded",
        notification_style = "native",
      },
      decorations = {
        statusline = {
          device = true,
          app_version = true,
        },
      },
      widget_guides = {
        enabled = true,
      },
      lsp = {
        color_indicator = true,
        on_attach = function(client, bufnr)
          local keymap = vim.keymap
          local opts = { buffer = bufnr, silent = true }

          -- Flutter specific keymaps
          opts.desc = "Flutter Run"
          keymap.set("n", "<leader>Fr", "<cmd>FlutterRun<CR>", opts)
          opts.desc = "Flutter Hot Reload"
          keymap.set("n", "<leader>Fh", "<cmd>FlutterHotReload<CR>", opts)
          opts.desc = "Flutter Hot Restart"
          keymap.set("n", "<leader>FR", "<cmd>FlutterHotRestart<CR>", opts)
        end,
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          renameFilesWithClasses = "always",
          enableSnippets = true,
        },
      },
    })
  end,
}
