-- Diagnostic display mode toggle
-- Cycles between: virtual_text only → virtual_lines (current line) → virtual_text only
-- Provides <leader>ll to switch between compact and expanded inline display.
-- The current_line option keeps virtual_lines clean by only showing the full
-- diagnostic message on the line under the cursor.

local function cycle_diagnostic_mode()
  local config = vim.diagnostic.config()
  local has_lines = config.virtual_lines ~= false and config.virtual_lines ~= nil

  if has_lines then
    -- Currently in virtual_lines mode → switch back to virtual_text
    vim.diagnostic.config({
      virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        prefix = "●",
        spacing = 3,
        source = "if_many",
      },
      virtual_lines = false,
    })
  else
    -- Currently in virtual_text mode → switch to virtual_lines on current line
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = {
        current_line = true,
        severity = { min = vim.diagnostic.severity.WARN },
      },
    })
  end
end

vim.keymap.set("n", "<leader>ll", cycle_diagnostic_mode, {
  desc = "Cycle diagnostic display: virtual_text ↔ virtual_lines (current line)",
})

return {
  "ErichDonGubler/lsp_lines.nvim",
  enabled = false,
}
