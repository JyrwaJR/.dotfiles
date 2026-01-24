return {
  "ggandor/leap.nvim",
  enabled = true,
  keys = {
    { "s", mode = { "n", "x", "o" }, desc = "Leap Forward to" },
    { "S", mode = { "n", "x", "o" }, desc = "Leap Backward to" },
    { "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" },
  },
  config = function(_, opts)
    local leap = require("leap")
    for k, v in pairs(opts) do
      leap.opts[k] = v
    end
    vim.keymap.set({ "n", "x", "o" }, "s", function()
      leap.leap({})
    end, { desc = "Leap Forward to" })
    vim.keymap.set({ "n", "x", "o" }, "S", function()
      leap.leap({ backward = true })
    end, { desc = "Leap Backward to" })
    vim.keymap.set({ "n", "x", "o" }, "gs", function()
      local util = require("leap.util")
      leap.leap({ target_windows = util.get_enterable_windows() })
    end, { desc = "Leap from Windows" })
    vim.keymap.del({ "x", "o" }, "x")
    vim.keymap.del({ "x", "o" }, "X")
  end,
}
