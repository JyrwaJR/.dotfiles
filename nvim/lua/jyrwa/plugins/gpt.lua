return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  opts = {
    -- 1. Point to your local Ollama server
    -- Note: Ollama's OpenAI-compatible endpoint is usually at /v1
    api_host_cmd = "echo http://localhost:11434",

    -- 2. Ollama doesn't need a key, but the plugin requires one to start
    api_key_cmd = "echo 'ollama'",

    -- 3. Configure the model settings
    openai_params = {
      model = "qwen2.5-coder:3b-instruct-q4_0",
      frequency_penalty = 0,
      presence_penalty = 0,
      max_tokens = 4096,
      temperature = 0,
      top_p = 1,
      n = 1,
    },
    openai_edit_params = {
      model = "qwen2.5-coder:3b-instruct-q4_0",
      temperature = 0,
      top_p = 1,
      n = 1,
    },
    -- 4. Set the chat specific instructions (persona)
    system_prompt = "You are a helpful AI assistant and expert coder.",
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
}
