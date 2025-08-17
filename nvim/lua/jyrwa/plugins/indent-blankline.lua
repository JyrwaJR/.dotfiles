return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPre", "BufNewFile" },
  main = "ibl",
  enabled = true,
  opts = {
    indent = { char = "┊" },
    scope = { enabled = true },
  },
  config = function(_, opts)
    require("ibl").setup(opts)
  end,
}
