return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-note"),
        template = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Templates"),
        standalone = true,
      },
      {
        name = "work",
        path = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/work-vault"),
        template = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Templates"),
      },
    },
    -- Enable cross-workspace search and completion
    detect_cwd = false,
    completion = {
      nvim_cmp = true,
      min_chars = 2,
      new_notes_location = "current_dir",
      prepend_note_id = true,
      prepend_note_path = false,
      use_path_only = false,
    },
    -- Enable searching across all workspaces
    finder = "telescope.nvim",
    open_notes_in = "current",
    sort_by = "modified",
    sort_reversed = true,
    open_app_foreground = false,
  },
}
