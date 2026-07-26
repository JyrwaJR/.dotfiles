return {
  "RRethy/vim-illuminate",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    delay = 100,
    filetypes_denylist = {
      "Trouble",
      "lazy",
      "oil",
      "TelescopePrompt",
      "which-key",
      "aerial",
      "snacks_terminal",
    },
    providers = { "lsp", "treesitter", "regex" },
    under_cursor = true,
    large_file_cutoff = 2000,
  },
  config = function(_, opts)
    require("illuminate").configure(opts)
    vim.keymap.set("n", "<leader>uh", function()
      local i = require("illuminate")
      if vim.g.illuminate_disabled then
        i.resume()
        vim.g.illuminate_disabled = false
        vim.notify("Illuminate: ON")
      else
        i.pause()
        vim.g.illuminate_disabled = true
        vim.notify("Illuminate: OFF")
      end
    end, { desc = "Toggle illuminate" })
  end,
}
