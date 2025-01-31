return {
  "ThePrimeagen/refactoring.nvim",
  keys = {
    {
      "<leader>r",
      function()
        require("refactoring").select_refactor({
          show_success_message = true,
        })
      end,
      mode = "v",
      noremap = true,
      silent = true,
      expr = false,
    },
  },
  opts = {
    prompt_func_return_type = {
      go = true,
      cpp = true,
      c = true,
      java = true,
    },
    prompt_func_param_type = {
      go = true,
      cpp = true,
      c = true,
      java = true,
    },
  },
}
