return {
  "rcarriga/nvim-notify",
  config = function()
    local notify = require("notify")
    notify.setup({
      background_colour = "#000000",
      fps = 60,
      render = "default",
      stages = "fade_in_slide_out", -- Amazing animation style
      timeout = 3000,
      top_down = true,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
    })
    
    -- Replace default vim notification with this animated one
    vim.notify = notify
    
    -- Map to dismiss all active notifications
    vim.keymap.set("n", "<leader>nd", function() require("notify").dismiss({ silent = true, pending = true }) end, { desc = "Dismiss unread notifications" })
  end,
}
