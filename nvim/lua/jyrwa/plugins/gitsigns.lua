return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },

  opts = {
    current_line_blame = true, -- 👈 show blame info inline by default
    current_line_blame_opts = {
      delay = 0,
      virt_text_pos = "eol", -- "eol" | "overlay" -- position the virtual text
      virt_text_focusable = true,
      virt_text = true,
      virt_text_win_col = nil,
      current_line_blame_formatter_opts = {
        relative_time = true,
      },
    },
    signs = {
      add = { text = "┃" },
      change = { text = "┃" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    signs_staged = {
      add = { text = "┃" },
      change = { text = "┃" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },

    signs_staged_enable = true, -- Show staged signs

    -- Display
    signcolumn = true,
    numhl = true, -- Highlight line number
    linehl = false, -- Highlight line
    word_diff = false, -- Show word diff

    -- Git directory watch
    watch_gitdir = { follow_files = true },

    auto_attach = true,
    attach_to_untracked = true, -- Change to false if you don't want signs on untracked files

    -- Performance and UI
    sign_priority = 6,
    update_debounce = 100,
    max_file_length = 40000,

    preview_config = {
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },

    -- Statusline format (nil = use default)
    status_formatter = nil,
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map("n", "]h", gs.next_hunk, "Next Hunk")
      map("n", "[h", gs.prev_hunk, "Prev Hunk")

      -- Actions
      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")
      map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset hunk")
      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk") -- in visual mode, select hunk
    end,
  },
}
