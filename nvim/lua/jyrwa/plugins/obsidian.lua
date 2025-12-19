return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-note"),
        template = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Templates"),
        standalone = true,
      },
      {
        name = "work",
        path = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/work-vault"),
        template = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Templates"),
      },
    },
    new_notes_location = "current_dir",
    wiki_link_func = function(opts)
      if opts.id == nil then
        return string.format("[[%s]]", opts.label)
      elseif opts.label ~= opts.id then
        return string.format("[[%s|%s]]", opts.id, opts.label)
      else
        return string.format("[[%s]]", opts.id)
      end
    end,
    markdown_link_func = function(opts)
      return string.format("[%s](%s)", opts.label, opts.path or opts.url or "")
    end,
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    -- Enable searching across all workspaces
    finder = "telescope.nvim",
    open_notes_in = "current",
    sort_by = "modified",
    sort_reversed = true,
    open_app_foreground = false,
  },
}
