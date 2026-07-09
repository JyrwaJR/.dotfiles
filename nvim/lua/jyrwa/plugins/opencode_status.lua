return {
  dir = vim.fn.stdpath("config") .. "/opencode-status",
  lazy = true,
  event = { "User OpencodeEvent:*" },
  config = function()
    require("opencode-status").setup({})
  end,
}