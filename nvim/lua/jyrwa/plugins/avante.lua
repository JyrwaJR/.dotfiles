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
    provider = "gemini", -- Changed to free tier option

    -- AI Provider configurations
    providers = {
      -- FREE OPTION: Google Gemini (no credit card needed)
      gemini = {
        endpoint = "https://generativelanguage.googleapis.com",
        model = "gemini-2.0-flash-exp", -- Fast, free tier friendly
        timeout = 30000,
        extra_request_body = {
          temperature = 0.7, -- Balanced creativity
          max_tokens = 8192, -- Reasonable for code
        },
      },

      -- Moonshot Kimi (India-friendly, limited free quota)
      moonshot = {
        endpoint = "https://api.moonshot.ai/v1",
        model = "kimi-k2-0711-preview",
        timeout = 30000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
        },
      },

      -- Claude (requires paid API key - export AVANTE_ANTHROPIC_API_KEY)
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-5-sonnet-20241022", -- Update to latest model
        timeout = 30000,
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 16384,
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
