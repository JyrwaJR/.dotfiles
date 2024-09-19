return {
  "smjonas/inc-rename.nvim",
  config = function()
    require("inc_rename").setup({
      -- The name of the command
      cmd_name = "IncRename",
      -- The highlight group used for highlighting the identifier's new name
      hl_group = "Substitute",
      -- Whether an empty new name should be previewed; if false the command preview will be cancelled instead
      preview_empty_name = true,
      -- Whether to display a `Renamed m instances in n files` message after a rename operation
      show_message = true,
      -- Whether to save the "IncRename" command in the command line history
      save_in_cmdline_history = true,
      -- The type of the external input buffer to use (the only supported value is currently "dressing")
      input_buffer_type = nil,
    })

    -- Keymap to start incremental renaming with the current word under the cursor
    vim.keymap.set("n", "<leader>rn", function()
      return ":IncRename " .. vim.fn.expand("<cword>")
    end, { expr = true, noremap = true, silent = true })
  end,
}
