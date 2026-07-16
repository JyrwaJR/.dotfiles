return {
  "JoosepAlviste/nvim-ts-context-commentstring",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    enable_autocmd = true,
  },
  config = function(_, opts)
    require("ts_context_commentstring").setup(opts)

    -- Update commentstring on cursor move (not just CursorHold which has
    -- a 4-second delay by default). This ensures correct commentstring
    -- when pressing gcc immediately after moving to a JSX line.
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = vim.api.nvim_create_augroup("ts_context_commentstring_moved", { clear = true }),
      pattern = { "*.tsx", "*.jsx", "*.js" },
      callback = function()
        require("ts_context_commentstring").update_commentstring()
      end,
    })
  end,
}
