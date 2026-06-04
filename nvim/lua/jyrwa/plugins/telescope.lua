return {
  "nvim-telescope/telescope.nvim",
  version = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter",
    "folke/todo-comments.nvim",
    "debugloop/telescope-undo.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod
    local builtin = require("telescope.builtin")

    local ok_trouble, trouble = pcall(require, "trouble")
    local ok_trouble_tel, trouble_telescope = pcall(require, "trouble.sources.telescope")

    local custom_actions = transform_mod({
      open_trouble_qflist = function()
        if ok_trouble then
          trouble.toggle("quickfix")
        end
      end,
    })

    telescope.setup({
      defaults = {
        prompt_prefix = "  ",
        selection_caret = "  ",
        layout_strategy = "vertical",
        preview = true,
        layout_config = {
          prompt_position = "bottom",
          horizontal = { width = 0.9 },
          vertical = { width = 0.9 },
        },
        file_ignore_patterns = { ".git/", "node_modules", "*.test.*", "migration.sql", "__tests__", "__mocks__" },
        path_shorten = 2,
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = ok_trouble_tel and trouble_telescope.open or nil,
          },
          n = {
            ["q"] = actions.close,
            ["J"] = actions.move_selection_next,
            ["K"] = actions.move_selection_previous,
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = ok_trouble_tel and trouble_telescope.open or nil,
          },
        },
      },
    })

    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "todo-comments")
    pcall(telescope.load_extension, "undo")
    pcall(telescope.load_extension, "rest")

    local function grep_globs(globs, title)
      builtin.live_grep({
        prompt_title = title,
        additional_args = function()
          local args = {}
          for _, g in ipairs(globs) do
            table.insert(args, "-g")
            table.insert(args, g)
          end
          return args
        end,
      })
    end

    vim.api.nvim_create_user_command("FindTS", function()
      grep_globs({ "*.ts" }, "Search *.ts")
    end, {})
    vim.api.nvim_create_user_command("FindJS", function()
      grep_globs({ "*.js" }, "Search *.js")
    end, {})
    vim.api.nvim_create_user_command("FindTSX", function()
      grep_globs({ "*.tsx" }, "Search *.tsx")
    end, {})
    vim.api.nvim_create_user_command("FindJSX", function()
      grep_globs({ "*.jsx" }, "Search *.jsx")
    end, {})
    vim.api.nvim_create_user_command("FindJSON", function()
      grep_globs({ "*.json", "*.jsonc" }, "Search JSON")
    end, {})
    vim.api.nvim_create_user_command("FindYAML", function()
      grep_globs({ "*.yml", "*.yaml" }, "Search YAML")
    end, {})
    vim.api.nvim_create_user_command("FindPrisma", function()
      grep_globs({ "*.prisma" }, "Search Prisma")
    end, {})
    vim.api.nvim_create_user_command("FindSQL", function()
      grep_globs({ "*.sql" }, "Search SQL")
    end, {})
  end,
}
