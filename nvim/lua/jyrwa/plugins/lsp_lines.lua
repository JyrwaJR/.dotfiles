-- Use Neovim built-in virtual_lines instead of the lsp_lines plugin
vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = true,
})

vim.keymap.set("n", "<leader>ll", function()
  local config = vim.diagnostic.config()
  if config.virtual_text then
    vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
  else
    vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
  end
end, { desc = "Toggle virtual_lines" })

return {
  "ErichDonGubler/lsp_lines.nvim",
  enabled = false,
}
