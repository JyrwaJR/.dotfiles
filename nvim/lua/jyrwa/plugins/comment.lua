return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    -- Import Comment.nvim safely
    local comment = require("Comment")
    local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

    -- Enable comment plugin with JSX/TSX support
    comment.setup({
      pre_hook = ts_context_commentstring.create_pre_hook(),
      padding = true,
      sticky = true,
      ignore = "^%s*$",
    })
  end,
}
