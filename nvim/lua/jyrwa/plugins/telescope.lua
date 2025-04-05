return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "debugloop/telescope-undo.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function()
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      extensions_list = { "fzf", "noice", "undo", "lazygit", "file_browser", "todo-comments" },
      defaults = {
        prompt_prefix = "  ",
        selection_caret = "  ",
        layout_strategy = "vertical",
        layout_config = {
          horizontal = { width = 0.9 },
          vertical = { width = 0.9 },
        },
        file_ignore_patterns = { ".git/", "node_modules" },
        path_shorten = 2,
        path_display = {
          "filename_first",
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
          n = {
            ["q"] = actions.close,
            ["J"] = actions.move_selection_next,
            ["K"] = actions.move_selection_previous,
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("noice")
    telescope.load_extension("lazygit")
    telescope.load_extension("file_browser")
    telescope.load_extension("todo-comments")
    telescope.load_extension("undo")
  end,
}
