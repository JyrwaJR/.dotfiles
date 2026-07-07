return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  keys = {
    -- Same keymaps as rest.nvim
    {
      "<leader>kr",
      function()
        require("kulala").run()
      end,
      desc = "Run HTTP request",
    },
    {
      "<leader>ka",
      function()
        require("kulala").run_all()
      end,
      desc = "Run all HTTP requests",
    },
    {
      "<leader>kl",
      function()
        require("kulala").replay()
      end,
      desc = "Replay last request",
    },

    {
      "<leader>kp",
      function()
        vim.cmd("enew")
        vim.bo.filetype = "http"
      end,
      desc = "Open scratchpad",
    },

    {
      "<leader>kc",
      function()
        require("kulala").copy()
      end,
      desc = "Copy as cURL",
    },
    {
      "<leader>ki",
      function()
        require("kulala").inspect()
      end,
      desc = "Inspect request",
    },
    {
      "<leader>ks",
      function()
        require("kulala").show_env()
      end,
      desc = "Show env",
    },
    {
      "<leader>ko",
      function()
        require("kulala").open()
      end,
      desc = "Open last response",
    },
  },

  opts = {
    global_keymaps = false,

    -- UI
    ui = {
      display_mode = "float",
      win_opts = {
        border = "rounded",
      },
    },

    -- Local development
    default_env = "dev",
    debug = false,

    -- Request options
    request_timeout = 10000,
    additional_curl_options = {
      "-k",
      "--noproxy",
      "localhost,127.0.0.1",
    },

    -- Response
    show_request_summary = false,
    show_icons = true,
  },
}
