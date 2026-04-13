return {
  {
    "echasnovski/mini.indentscope",
    version = "*",
    event = "BufEnter",
    enabled = false,
    opts = {
      symbol = "|",
      options = { try_as_border = true, border = "both" },
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
