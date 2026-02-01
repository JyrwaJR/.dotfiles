return {
  "rest-nvim/rest.nvim",
  ft = "http",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter", -- Required for JSON highlighting
  },

  ------------------------------------------------------------------
  -- KEYMAPS (same as your old Kulala muscle memory)
  ------------------------------------------------------------------
  keys = {
    { "<leader>kr", "<cmd>Rest run<cr>", desc = "Run HTTP request" },
    { "<leader>ka", "<cmd>Rest run_all<cr>", desc = "Run all HTTP requests" },
    { "<leader>kl", "<cmd>Rest last<cr>", desc = "Replay last request" },

    -- scratchpad
    {
      "<leader>kp",
      function()
        vim.cmd("enew")
        vim.bo.filetype = "http"
      end,
      desc = "Open scratchpad",
    },

    { "<leader>kc", "<cmd>Rest curl<cr>", desc = "Copy as cURL" },
    { "<leader>ki", "<cmd>Rest preview<cr>", desc = "Inspect request" },
    { "<leader>ks", "<cmd>Rest env show<cr>", desc = "Show env" },
    { "<leader>ko", "<cmd>Rest open<cr>", desc = "Open last response" },
  },

  ------------------------------------------------------------------
  -- CONFIG
  ------------------------------------------------------------------
  config = function()
    require("rest-nvim").setup({
      ----------------------------------------------------------------
      -- 🔥 FIXED: NO FILETYPE CONFLICTS + FAST LOCAL DEV
      ----------------------------------------------------------------
      result_split_in_place = false,
      result_split = false, -- Disable split
      float = true, -- ✅ FLOATING WINDOW

      -- Float styling
      float_opts = {
        border = "rounded",
        winblend = 0,
        height = 0.8,
        width = 0.9,
        zindex = 1000,
      },

      -- Local dev performance
      skip_ssl_verification = true,
      timeout = 10,

      -- Fast system curl for local backend
      curl = {
        bin = "curl",
        args = { "--max-time", "10", "--noproxy", "localhost,127.0.0.1" },
      },

      highlight = {
        enabled = true,
        timeout = 150,
      },

      result = {
        show_url = false,
        show_headers = false,
        show_http_info = true,
        max_name_width = 100,
      },
    })

    ------------------------------------------------------------------
    -- ✅ FIXED: NAMESPACED AUTOCOMMANDS (no conflicts)
    ------------------------------------------------------------------
    local rest_group = vim.api.nvim_create_augroup("RestNvim", { clear = true })

    -- JSON formatter (only for actual JSON files)
    vim.api.nvim_create_autocmd("FileType", {
      group = rest_group,
      pattern = "json",
      callback = function()
        vim.bo.formatprg = "jq ."
        vim.bo.formatexpr = nil
      end,
    })

    -- FIXED: Rest buffers ONLY (no filetype conflicts)
    vim.api.nvim_create_autocmd("BufEnter", {
      group = rest_group,
      callback = function()
        local name = vim.api.nvim_buf_get_name(0)
        -- Only untitled rest buffers + no existing filetype
        if name:match("^rest://") and vim.bo.filetype == "" then
          vim.bo.filetype = "json"
          vim.cmd("silent! TSBufEnable highlight")

          -- Safe formatting
          vim.bo.modifiable = true
          vim.bo.swapfile = false
          vim.opt_local.foldmethod = "indent"

          vim.schedule(function()
            vim.cmd("normal! gg=G")
            vim.bo.modifiable = false
          end)
        end
      end,
    })
  end,
}
