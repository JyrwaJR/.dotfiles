return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },

  keys = {
    {
      "<leader>kr",
      function()
        require("kulala").run()
      end,
      desc = "Run request",
    },
    {
      "<leader>ka",
      function()
        require("kulala").run_all()
      end,
      desc = "Run all requests",
    },
    {
      "<leader>kp",
      function()
        vim.cmd("enew")
        vim.bo.filetype = "http"
      end,
      desc = "New HTTP scratch",
    },
    {
      "<leader>ko",
      function()
        require("kulala").show_last_response()
      end,
      desc = "Show last response",
    },
    {
      "<leader>ke",
      function()
        require("kulala").set_selected_env()
      end,
      desc = "Select environment",
    },
  },

  opts = {
    global_keymaps = false,

    default_env = "dev",

    default_view = "body",

    split_direction = "vertical",

    contenttypes = {
      ["application/json"] = {
        ft = "json",
        formatter = { "jq", "." },
      },
    },
  },
}
