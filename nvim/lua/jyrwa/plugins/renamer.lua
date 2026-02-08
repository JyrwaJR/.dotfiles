return {
  "filipdutescu/renamer.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local mappings_utils = require("renamer.mappings.utils")
    require("renamer").setup({
      -- The popup title, shown if `border` is true
      title = "Rename",
      -- The padding around the popup content
      padding = {
        top = 0,
        left = 0,
        bottom = 0,
        right = 0,
      },
      -- The minimum width of the popup
      min_width = 15,
      -- The maximum width of the popup
      max_width = 45,
      -- Whether or not to shown a border around the popup
      border = true,
      -- The characters which make up the border
      border_chars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      -- Whether or not to highlight the current word references through LSP
      show_refs = true,
      -- Whether or not to add resulting changes to the quickfix list
      with_qf_list = true,
      -- Whether or not to enter the new name through the UI or Neovim's `input`
      -- function, possible values: "win", "input", "both"
      with_popup = true,
      -- The keybindings for the popup
      mappings = {
        ["<c-i>"] = mappings_utils.set_cursor_to_start,
        ["<c-a>"] = mappings_utils.set_cursor_to_end,
        ["<c-e>"] = mappings_utils.set_cursor_to_end,
        ["<c-b>"] = mappings_utils.backward,
        ["<c-f>"] = mappings_utils.forward,
        ["<c-u>"] = mappings_utils.clear_line,
        ["<c-c>"] = mappings_utils.close,
        ["<cr>"] = mappings_utils.apply,
        ["<c-s>"] = mappings_utils.apply,
      },
      handler = nil,
    })
  end,
}
