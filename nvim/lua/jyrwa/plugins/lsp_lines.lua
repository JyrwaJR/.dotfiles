-- Use Neovim built-in virtual_lines instead of the lsp_lines plugin.
-- NOTE: Diagnostic config is managed in lspconfig.lua to avoid conflicts.
-- This file only provides the toggle keymap and disables the plugin.

local toggle_lines = function()
  local config = vim.diagnostic.config()
  local new_val = not config.virtual_lines
  vim.diagnostic.config({
    virtual_text = not new_val,
    virtual_lines = new_val,
  })
end

vim.keymap.set("n", "<leader>ll", toggle_lines, { desc = "Toggle virtual_lines on/off" })

return {
  "ErichDonGubler/lsp_lines.nvim",
  enabled = false,
}
