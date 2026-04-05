return {
  "robitx/gp.nvim",
  keys = {
    { "<leader>gn", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat" },
    { "<leader>gt", "<cmd>GpChatToggle vsplit<cr>", desc = "Toggle Chat" },
    { "<leader>s", "<cmd>GpChatRespond<cr>", desc = "Send to AI" },
  },
  config = function()
    require("gp").setup({
      providers = {
        ollama = {
          endpoint = "http://192.168.1.11:11434/api/chat", -- IMPORTANT: /v1
        },
      },

      agents = {
        {
          provider = "ollama",
          name = "QwenCoder",
          chat = true,
          command = true,

          -- your actual model
          model = { model = "qwen2.5-coder:3b-instruct-q4_0" },

          system_prompt = "You are a helpful coding assistant. Explain things simply and clearly.",
        },
      },

      default_chat_agent = "QwenCoder",
      default_command_agent = "QwenCoder",
    })
  end,
}
