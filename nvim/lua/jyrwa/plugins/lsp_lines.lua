return {
  "ErichDonGubler/lsp_lines.nvim",
  config = function()
    require("lsp_lines").setup()
    
    -- Disable virtual_text since it's redundant when lsp_lines is on
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = true, 
    })

    -- Toggle lsp_lines via keymap
    vim.keymap.set("n", "<leader>ll", function()
      local config = vim.diagnostic.config()
      if config.virtual_text then
        vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
      else
        vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
      end
    end, { desc = "Toggle lsp_lines" })
  end,
}
