return {
  "windwp/nvim-ts-autotag",
  event = "VeryLazy",
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = false,
    per_filetype = {
      html = { enable_close = false },
      javascript = { enable_close = true },
      typescript = { enable_close = true },
      javascriptreact = { enable_close = true },
      typescriptreact = { enable_close = true },
    },
  },
}
