-- Install jq for formatting (ensure jq is installed on your system for response formatting)

return {
  "mistweaverco/kulala.nvim",
  ft = "http", -- optional: uncomment if you want to lazy-load by filetype
  cmd = { "Kulala" }, -- optional: uncomment if lazy-loading by command
  keys = {
    { "<leader>kr", "<cmd>lua require('kulala').run()<cr>", desc = "Run HTTP request" },
    { "<leader>kp", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad" },
    { "<leader>ka", "<cmd>lua require('kulala').run_all()<cr>", desc = "Run All HTTP request" },
    { "<leader>kl", "<cmd>lua require('kulala').replay()<cr>", desc = "Run last HTTP request" },
    { "<leader>kc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL" },
    { "<leader>ki", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect request" },
    { "<leader>ks", "<cmd>lua require('kulala').search()<cr>", desc = "Search request" },
    { "<leader>ko", "<cmd>lua require('kulala').open()<cr>", desc = "Open request" },
  },
  config = function()
    require("kulala").setup({
      winbar = false,
      global_keymaps = true,
      kulala_keymaps = true,
      -- Display mode: "split" or "float"
      display_mode = "float",
      -- 'q' to close the float window
      q_to_close_float = true,
      -- Scratchpad settings
      scratchpad_mode = "float",
      scratchpad_q_to_close_float = true,
      -- other options here
    })

    -- Disable folding inside Kulala response windows
    -- Kulala sets buffer name contains 'kulala://' for response buffers
    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern = "*",
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname:match("kulala://") then
          vim.opt_local.foldenable = false
        end
      end,
    })
  end,
}
