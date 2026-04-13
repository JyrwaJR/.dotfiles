return {
  "gbprod/substitute.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local substitute = require("substitute")
    substitute.setup()
    -- set keymaps
    local keymap = vim.keymap -- for conciseness
    keymap.set("x", "SS", substitute.visual, { desc = "Substitute in visual mode" })
    keymap.set("n", "SS", substitute.operator, { desc = "Substitute in operator mode" })
  end,
}
