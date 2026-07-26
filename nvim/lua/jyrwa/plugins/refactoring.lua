return {
  "ThePrimeagen/refactoring.nvim",
  keys = {
    -- Visual Mode: Extract
    {
      "<leader>re",
      function()
        require("refactoring").extract_var({ show_success_message = true })
      end,
      mode = "v",
      desc = "Extract variable",
    },
    {
      "<leader>rf",
      function()
        require("refactoring").extract_func({ show_success_message = true })
      end,
      mode = "v",
      desc = "Extract function",
    },
    {
      "<leader>rF",
      function()
        require("refactoring").extract_func_to_file({ show_success_message = true })
      end,
      mode = "v",
      desc = "Extract function to file",
    },

    -- Normal Mode: Inline
    {
      "<leader>ri",
      function()
        require("refactoring").inline_var({ show_success_message = true })
      end,
      mode = "n",
      desc = "Inline variable",
    },
    {
      "<leader>rI",
      function()
        require("refactoring").inline_func({ show_success_message = true })
      end,
      mode = "n",
      desc = "Inline function",
    },

    -- Visual Mode: Debug Print
    {
      "<leader>rp",
      function()
        require("refactoring").debug.print_var({})
      end,
      mode = "v",
      desc = "Debug: print variable(s)",
    },
    {
      "<leader>rx",
      function()
        require("refactoring").debug.print_exp({})
      end,
      mode = "v",
      desc = "Debug: print expression",
    },
    {
      "<leader>rc",
      function()
        require("refactoring").debug.cleanup({})
      end,
      mode = "v",
      desc = "Debug: cleanup prints",
    },

    -- Normal Mode: Debug Print
    {
      "<leader>rl",
      function()
        require("refactoring").debug.print_loc({})
      end,
      mode = "n",
      desc = "Debug: print location",
    },

    -- Fallback: Select refactor menu
    {
      "<leader>r",
      function()
        require("refactoring").select_refactor({
          show_success_message = true,
        })
      end,
      mode = "v",
      desc = "Select refactor...",
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
