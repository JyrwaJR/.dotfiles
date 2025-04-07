-- Install jq for formatting
return {
  "mistweaverco/kulala.nvim",
  ft = "http",
  keys = {
    { "<leader>hs", "<cmd>lua require('kulala').run()<cr>", desc = "Run HTTP request" },
    { "<leader>hp", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad" },
    { "<leader>ha", "<cmd>lua require('kulala').run_all()<cr>", desc = "Run All HTTP request" },
    { "<leader>hr", "<cmd>lua require('kulala').replay()<cr>", desc = "Run last HTTP request" },
    { "<leader>hc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL" },
    { "<leader>hi", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect request" },
    { "<leader>hS", "<cmd>lua require('kulala').search()<cr>", desc = "Search request" },
    { "<leader>ho", "<cmd>lua require('kulala').open()<cr>", desc = "Search request" },
  },
  config = function()
    require("kulala").setup({
      winbar = false,
      kulala_keymaps = true,
      -- Display mode, possible values: "split", "float"
      display_mode = "float",
      -- q to close the float (only used when display_mode is set to "float")
      q_to_close_float = true,
    })
  end,
}
