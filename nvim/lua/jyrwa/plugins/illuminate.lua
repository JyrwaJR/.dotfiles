return {
  "RRethy/vim-illuminate",
  event = "VeryLazy",
  config = function()
    require("illuminate").configure({
      providers = { "lsp", "treesitter", "regex" },
      delay = 100,
      filetypes_denylist = { "dirbuf", "dirvish", "fugitive" },
      under_cursor = true,
      large_file_cutoff = 10000,
      min_count_to_highlight = 1,
    })

    -- Optional: custom Catppuccin-style highlight (override only if you want different look)
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#313244", bold = true })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#45475a", bold = true })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#585b70", bold = true })

    -- Keymaps for jumping between references
    vim.keymap.set("n", "]]", function()
      require("illuminate").goto_next_reference(false)
    end, { desc = "Go to next reference" })

    vim.keymap.set("n", "[[", function()
      require("illuminate").goto_prev_reference(false)
    end, { desc = "Go to previous reference" })
  end,
}
