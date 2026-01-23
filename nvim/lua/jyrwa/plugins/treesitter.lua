return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
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
        "html",
        "css",
        "prisma",
        "markdown",
        "markdown_inline",
        "svelte",
        "graphql",
        "bash",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "http",
        "json",
        "vimdoc",
        "c",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
    require("nvim-ts-autotag").setup({
      filetypes = {
        "html",
        "xml",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "tsx",
        "jsx",
        "svelte",
        "vue",
        "markdown",
        "php",
      },
    })
  end,
}
