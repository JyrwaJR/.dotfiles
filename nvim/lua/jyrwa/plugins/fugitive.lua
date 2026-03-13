return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G" },
  keys = {
    {
      "<leader>gs",
      function()
        -- 'topleft' ensures it opens on the far left
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
      "<leader>gl",
      function()
        vim.cmd("Git pull")
      end,
      desc = "Git Pull",
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
        vim.cmd("Gvdiffsplit")
      end,
      desc = "Git Diff",
    },
    -- New useful keybindings
    {
      "<leader>gr",
      function()
        vim.cmd("Gread")
      end,
      desc = "Git Checkout Current File (Revert)",
    },
    {
      "<leader>gw",
      function()
        vim.cmd("Gwrite")
      end,
      desc = "Git Stage (Write) Current File",
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
        -- Opens the commit log for the current file
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
