return {
  "nvim-telescope/telescope.nvim",
  version = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "debugloop/telescope-undo.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod
    local builtin = require("telescope.builtin")

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    local custom_actions = transform_mod({
      open_trouble_qflist = function()
        trouble.toggle("quickfix")
      end,
    })

    local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
    if ok_parsers and parsers and parsers.ft_to_lang == nil then
      parsers.ft_to_lang = function(ft)
        local ok_get, lang = pcall(function()
          return vim.treesitter.language.get_lang(ft)
        end)
        return (ok_get and lang) and lang or ft
      end
    end
    local ok_highlighter, highlighter = pcall(function()
      return vim.treesitter.highlighter
    end)
    if ok_highlighter and highlighter and highlighter.is_enabled == nil then
      highlighter.is_enabled = function(bufnr, lang)
        local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
        if ok_configs and configs and configs.is_enabled then
          return configs.is_enabled("highlight", bufnr, lang)
        end
        return true
      end
    end
    local ok_vth, vth = pcall(require, "vim.treesitter.highlighter")
    if ok_vth and vth and vth.is_enabled == nil then
      vth.is_enabled = function(bufnr, lang)
        local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
        if ok_configs and configs and configs.is_enabled then
          return configs.is_enabled("highlight", bufnr, lang)
        end
        return true
      end
    end
    local ok_utils, utils = pcall(require, "telescope.previewers.utils")
    if ok_utils and utils and utils.ts_highlighter then
      local orig_ts_highlighter = utils.ts_highlighter
      utils.ts_highlighter = function(...)
        local ok, res = pcall(orig_ts_highlighter, ...)
        if not ok then
          return
        end
        return res
      end
    end

    telescope.setup({
      extensions_list = { "fzf", "noice", "undo", "lazygit", "file_browser", "todo-comments" },
      defaults = {
        prompt_prefix = "  ",
        selection_caret = "  ",
        layout_strategy = "horizontal", -- Horizontal or vertical
        layout_config = {
          prompt_position = "bottom",
          horizontal = { width = 0.9 },
          vertical = { width = 0.9 },
        },
        file_ignore_patterns = { ".git/", "node_modules" },
        path_shorten = 2,
        path_display = { "filename_first" },
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
    -- telescope.load_extension("noice")
    telescope.load_extension("lazygit")
    telescope.load_extension("file_browser")
    telescope.load_extension("todo-comments")
    telescope.load_extension("undo")

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
