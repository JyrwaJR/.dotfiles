-- Load .env file automatically
local function load_env()
  local env_path = vim.fn.stdpath("config") .. "/.env"
  if vim.fn.filereadable(env_path) == 1 then
    for line in io.lines(env_path) do
      local key, value = line:match("^%s*([^=]+)%s*=%s*(.-)%s*$")
      if key and value then
        vim.env[key] = value
      end
    end
  end
end

load_env()

return {
  "yetone/avante.nvim",
  -- Build from precompiled binaries (faster install). Use `make BUILD_FROM_SOURCE=true` if you need source build
  build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",

  event = "VeryLazy", -- Lazy-load on first use (performance)
  version = false, -- Always use latest main branch (set to "vX.Y.Z" for stability)

  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- Project-specific instructions file (create avante.md in your project root)
    instructions_file = "avante.md",

    -- Default provider (fallback when not specified)
    provider = "openrouter", -- Use OpenRouter by default

    -- AI Provider configurations
    providers = {
      openrouter = {
        __inherited_from = "openai",
        endpoint = "https://openrouter.ai/api/v1",
        api_key_name = "OPENROUTER_API_KEY",

        model = "openai/gpt-4.1", -- primary working model
        fallback_models = {
          "openai/gpt-4.1-2025-04-14",
          "anthropic/claude-3-opus",
          "anthropic/claude-3.5-sonnet",
          "deepseek/deepseek-v3-base:free", -- if your plan allows
        },

        timeout = 30000,
        extra_request_body = {
          temperature = 0.2,
          max_tokens = 1200,
        },
      },
    },

    -- UI/Behavior optimizations for your React Native/Next.js workflow
    behaviour = {
      auto_suggestions = false, -- Disable experimental autosuggest (saves API quota)
      auto_set_keymaps = true, -- Auto-setup useful keybindings
      auto_add_current_file = true, -- Auto-add current file to context
      minimize_diff = true, -- Cleaner diffs (hide unchanged lines)
      enable_token_counting = true,
    },

    -- Enhanced UI with better input/selection
    input = {
      provider = "snacks", -- Modern input UI (requires snacks.nvim dependency)
    },

    selector = {
      provider = "fzf", -- Fast file selection (requires fzf-lua)
    },

    -- Sidebar positioning and size (right side, 35% width for code review)
    windows = {
      position = "right",
      width = 35,
      wrap = true,
    },

    -- Keybindings (all safe with lazy.nvim - won't override existing)
    mappings = {
      sidebar = {
        apply_all = "A", -- Apply all suggestions
        apply_cursor = "a", -- Apply at cursor
        add_file = "@", -- Add file to context
        close = { "q", "<Esc>" },
      },
    },
  },

  -- Required dependencies
  dependencies = {
    "nvim-lua/plenary.nvim", -- Core async library
    "MunifTanjim/nui.nvim", -- UI components

    -- File selectors (pick one or keep all)
    "nvim-mini/mini.pick",
    "nvim-telescope/telescope.nvim",
    "ibhagwan/fzf-lua",

    -- Input providers (snacks recommended)
    "stevearc/dressing.nvim",
    "folke/snacks.nvim",

    -- UI enhancements
    "nvim-tree/nvim-web-devicons",

    -- Markdown rendering for Avante buffer
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },

    -- Image pasting support (screenshots → Avante)
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true, -- Windows fix
        },
      },
    },
  },
}
