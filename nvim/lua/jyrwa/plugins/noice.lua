return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
      },
    },
    routes = {
      -- skip info/trace/debug notifications; only show warn/error
      { filter = { event = "notify", level = "INFO" },  opts = { skip = true } },
      { filter = { event = "notify", level = "TRACE" }, opts = { skip = true } },
      { filter = { event = "notify", level = "DEBUG" }, opts = { skip = true } },
    },
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    {
      "rcarriga/nvim-notify",
      opts = {
        level = vim.log.levels.WARN,
      },
    },
  },
}
