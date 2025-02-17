return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPre", "BufNewFile" },
  main = "ibl",
  opts = {
    indent = { char = "┊" },
    scope = { enabled = false },
  },
  config = function(_, opts)
    require("ibl").setup(opts)
  end,
}
