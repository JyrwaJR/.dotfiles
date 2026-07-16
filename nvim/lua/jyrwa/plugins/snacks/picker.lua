return {
  enabled = true,
  sources = {
    explorer = {
      hidden = true,
      ignored = true,
      exclude = {
        ".git",
        ".DS_Store",
      },
      follow_file = false,
      auto_close = true,
    },
  },
  actions = {
    opencode_send = function(picker)
      local items = vim.tbl_map(function(item)
        return item.file and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
          or item.text
      end, picker:selected({ fallback = true }))

      require("opencode").prompt(table.concat(items, ", ") .. " ")
    end,
  },
  win = {
    input = {
      keys = {
        ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
      },
    },
  },
}
