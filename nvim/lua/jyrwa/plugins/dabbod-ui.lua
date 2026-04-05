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

    result = {
      default = true,
      show_headers = true,
      max_column_width = 60,
      truncate = true,
      position = "right",
      split = "vertical",
      size = 0.6,
    },
  },
}
