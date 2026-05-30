return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = false },
    {
      "kristijanhusak/vim-dadbod-completion",
      ft = { "sql", "mysql", "plsql" },
      lazy = true,
    },
  },

  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },

  init = function()
    vim.g.db_ui_save_location = vim.fn.stdpath("config") .. "/db_ui"
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_auto_focus = 1

    vim.g.db_ui_default_query = "select * from {table} limit 100"

    vim.g.db_ui_table_helpers = {
      postgresql = {
        List = 'select * from "{table}" order by id desc limit 100',
        Count = 'select count(*) from "{table}"',
        Explain = 'explain analyze select * from "{table}"',
      },
    }
  end,

  config = function()
    vim.treesitter.language.register("sql", "dbui")
  end,
}
