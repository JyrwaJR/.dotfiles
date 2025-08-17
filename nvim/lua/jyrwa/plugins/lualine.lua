return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  enabled = true,
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        component_separators = { left = "|", right = "|" }, -- Rounded separators
        section_separators = { left = "", right = "" }, -- More rounded look
        icons_enabled = true, -- Ensure icons are enabled for better styling
        globalstatus = true,
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "", right = "" } } }, -- Rounded corners
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename", { "filetype", icon_only = true } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { { "location", separator = { left = "", right = "" } } },
      },
    })
  end,
}
