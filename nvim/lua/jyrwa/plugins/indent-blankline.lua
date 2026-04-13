return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPre", "BufNewFile" },
  main = "ibl",
  enable = false,
  opts = {
    indent = { char = "┊" },
    scope = { enabled = true },
    exclude = {
      filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
      buftypes = { "terminal" },
    },
  },
  config = function(_, opts)
    require("ibl").setup(opts)
  end,
}
