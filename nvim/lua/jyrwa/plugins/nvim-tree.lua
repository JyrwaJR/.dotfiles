return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      view = {
        width = 30,
        relativenumber = true,
      },
      -- change folder arrow icons
      renderer = {
        indent_markers = { enable = true },
      },
      -- disable window_picker for
      --
      -- explorer to work well with
      -- window splits
      actions = {
        open_file = {
          quit_on_open = true, -- quit neovim when opening a file
          window_picker = {
            enable = true,
            picker = "default",
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "packer", "qf", "diff" },
              buftype = { "terminal", "help" },
            },
          },
        },
      },
      filters = {
        custom = { ".DS_Store", "node_modules", ".git", "ios", "android", ".vercel", ".expo" },
      },
      git = {
        ignore = true,
      },
    })
  end,
}
