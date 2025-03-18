return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
  init = function()
    -- Enable Nerd Fonts for better UI icons
    vim.g.db_ui_use_nerd_fonts = 1
  end,
  keys = {
    {
      "<leader>d",
      function()
        -- Close NvimTree if open, open DBUI in a new tab
        vim.cmd("NvimTreeClose")
        vim.cmd("tabnew")
        vim.cmd("DBUI")
      end,
      desc = "Open Database UI",
    },
  },
}
