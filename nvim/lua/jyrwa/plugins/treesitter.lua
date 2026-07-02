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
        -- Disable vim regex fallback to avoid double-highlight overhead
        additional_vim_regex_highlighting = false,
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
        "markdown",
        "markdown_inline",
        "bash",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "http",
        "json",
        "vimdoc",
        "c",
        "dart",
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
