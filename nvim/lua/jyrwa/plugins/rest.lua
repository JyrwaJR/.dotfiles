return {
  "rest-nvim/rest.nvim",
  ft = { "http", "rest" },

  keys = {
    {
      "<leader>kr",
      function()
        require("rest-nvim").run()
      end,
      desc = "Run HTTP request",
    },
    {
      "<leader>kl",
      function()
        require("rest-nvim").last()
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
      "<leader>ko",
      "<cmd>Rest open<CR>",
      desc = "Open last response",
    },
    {
      "<leader>ke",
      "<cmd>Rest env show<CR>",
      desc = "Show active env file",
    },
  },

  -- rest.nvim uses vim.g.rest_nvim instead of a .setup() function.
  -- We set the global here via lazy.nvim's config hook.
  config = function()
    ---@type rest.Config
    vim.g.rest_nvim = {
      request = {
        skip_ssl_verification = true,
        hooks = {
          encode_url = true,
        },
      },
      response = {
        hooks = {
          decode_url = true,
          format = true,
        },
      },
      highlight = {
        enable = true,
        timeout = 750,
      },
      ui = {
        winbar = true,
      },
      cookies = {
        enable = true,
      },
      env = {
        enable = true,
      },
    }
  end,
}
