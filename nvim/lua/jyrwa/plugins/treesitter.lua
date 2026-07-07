return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    local ok, treesitter = pcall(require, "nvim-treesitter.configs")
    if not ok or not treesitter then
      return
    end

    -- configure treesitter
    treesitter.setup({ -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- explicitly disable deprecated treesitter autotag module
      autotag = { enable = false },
      -- ensure these language parsers are installed
      ensure_installed = {
        "javascript",
        "typescript",
        "tsx",
        "sql",
        "yaml",
        "css",
        "prisma",
        "bash",
        "vim",
        "gitignore",
        "query", -- for orgmode
        "http",
        "json",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-s>",
          node_incremental = "<C-s>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
