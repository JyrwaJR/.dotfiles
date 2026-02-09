return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = false },
    {
      "kristijanhusak/vim-dadbod-completion",
      ft = { "sql", "mysql", "plsql", "sqlite", "psql", "mongodb" },
      lazy = true,
    },
  },

  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },

  opts = {
    default = true,
    save_location = vim.fn.stdpath("config") .. "/db_ui",
    execute_on_save = true,
    use_nerd_fonts = true,
    show_database_icon = true,
    sort_by = "name",
    auto_focus = true,

    window = {
      width = 20,
      position = "right",
    },

    -- ✅ CRITICAL: Force right position + disable bottom split
    result = {
      default = true,
      show_headers = true,
      max_column_width = 60,
      truncate = true,
      position = "right", -- Right side
      split = "vertical", -- VERTICAL split only
      size = 0.6, -- 60% width
    },
  },

  config = function()
    -- Force global settings
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_show_database_icon = 1
    vim.g.db_ui_auto_execute_table_helpers = 1

    -- ✅ Fix result position globally
    vim.g.db_ui_result_position = "right"
    vim.g.db_ui_result_split = "vertical"

    -- Disable folding in ALL dbout buffers
    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = "dbout",
      callback = function()
        vim.opt_local.foldenable = false
        vim.opt_local.foldlevel = 99
        vim.opt_local.wrap = false
      end,
    })

  end,
}
