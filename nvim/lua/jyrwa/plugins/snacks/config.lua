local M = {}

function M.get_opts()
  return {
    bigfile = { enabled = true, notify = false },
    dashboard = require("jyrwa.plugins.snacks.dashboard"),
    indent = { enabled = false },
    input = {
      enabled = true,
      win = {
        style = "input",
        relative = "cursor",
        row = 1,
        col = 0,
        width = 30,
      },
    },
    notifier = require("jyrwa.plugins.snacks.notifier"),
    picker = require("jyrwa.plugins.snacks.picker"),
    quickfile = { enabled = true },
    rename = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = { enabled = true },
    words = { enabled = true },
    zen = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true },
      },
    },
  }
end

function M.get_keys()
  return require("jyrwa.plugins.snacks.keys")
end

return M
