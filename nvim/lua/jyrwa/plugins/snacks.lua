return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = function()
    return require("jyrwa.plugins.snacks.config").get_opts()
  end,
  keys = function()
    return require("jyrwa.plugins.snacks.config").get_keys()
  end,
}
