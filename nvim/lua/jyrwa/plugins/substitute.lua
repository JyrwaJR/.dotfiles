return {
  "gbprod/substitute.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local substitute = require("substitute")
    substitute.setup()
    -- set keymaps
    local keymap = vim.keymap -- for conciseness
    keymap.set("x", "s", substitute.visual, { desc = "Substitute in visual mode" })
  end,
}
