return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  opts = {
    left = {
      { title = "Outline", ft = "aerial", pinned = true },
    },
    right = {
      { title = "Trouble", ft = "trouble", size = { width = 0.2 } },
      { title = "DAP", ft = "dapui_.*", size = { width = 0.2 } },
      { title = "Spectre", ft = "spectre_panel", size = { width = 0.25 } },
    },
    animate = { enabled = false },
    exit_when_last = true,
    keys = {
      { "<leader>ea", "<cmd>EdgyToggle left<cr>", desc = "Toggle left edge" },
      { "<leader>ed", "<cmd>EdgyToggle right<cr>", desc = "Toggle right edge" },
    },
  },
}
