return {
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = "BufEnter",
    opts = {
      symbol = "╎",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "lazy",
          "mason",
          "notify",
          "oil",
          "Oil",
          "nvim-tree",
          "qf",
          "query",
          "spectre_panel",
          "startuptime",
          "toggleterm",
          "Trouble",
          "aerial",
          "dap-repl",
          "dapui_scopes",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
}
