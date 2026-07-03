return {
  "pwntester/octo.nvim",
  cmd = { "Octo" },
  keys = {
    { "<leader>o", "<cmd>Octo<cr>", desc = "Octo" },
  },
  config = function()
    require("octo").setup({
      enable_builtin = true,
    })
    vim.cmd([[hi OctoEditable guibg=none]])
  end,
}
