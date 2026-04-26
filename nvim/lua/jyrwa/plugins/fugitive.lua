return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G" },
  keys = {
    {
      "<leader>gs",
      function()
        vim.cmd("topleft vertical Git")
      end,
      desc = "Git Status (Left)",
    },
    {
      "<leader>gc",
      function()
        vim.cmd("Git commit")
      end,
      desc = "Git Commit",
    },
    {
      "<leader>gp",
      function()
        vim.cmd("Git push")
      end,
      desc = "Git Push",
    },
    {
      "<leader>gP",
      function()
        vim.cmd("Git push --force")
      end,
      desc = "Git Push (Force)",
    },
    {
      "<leader>gl",
      function()
        vim.cmd("Git pull")
      end,
      desc = "Git Pull",
    },
    {
      "<leader>gf",
      function()
        vim.cmd("Git fetch")
      end,
      desc = "Git Fetch",
    },
    {
      "<leader>gb",
      function()
        vim.cmd("Git blame")
      end,
      desc = "Git Blame",
    },
    {
      "<leader>gd",
      function()
        vim.cmd("botright vertical Gdiffsplit")
      end,
      desc = "Git Diff (Right)",
    },
    -- Normal mode staging/reverting (whole file)
    {
      "<leader>gw",
      "<cmd>Gwrite<CR>",
      desc = "Git Stage (Write) Current File",
    },
    {
      "<leader>gr",
      "<cmd>Gread<CR>",
      desc = "Git Checkout Current File (Revert)",
    },
    {
      "<leader>gm",
      function()
        vim.cmd("Git mergetool")
      end,
      desc = "Git Mergetool",
    },
    {
      "<leader>gh",
      function()
        vim.cmd("topleft vertical Git log --oneline -- %")
      end,
      desc = "Git File History",
    },
  },
  config = function()
    local keymap = vim.keymap

    -- Resize Git window automatically
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fugitive",
      callback = function()
        vim.cmd("vertical resize 80")
      end,
    })

    -- Close fugitive buffer with q
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fugitive",
      callback = function()
        keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true })
      end,
    })
  end,
}
