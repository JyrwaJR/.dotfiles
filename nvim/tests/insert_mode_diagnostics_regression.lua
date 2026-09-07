-- Regression test: entering insert mode must NOT hide lint/LSP diagnostics.
--
-- Root cause (2026-08-30): an InsertEnter autocmd called vim.diagnostic.hide(),
-- which hid ALL namespaces (nvim-lint + LSP) in ALL buffers. Nothing ever
-- called vim.diagnostic.show(), so diagnostics stayed hidden until a new
-- linter result or an LSP didChange re-pushed them -- and an empty lint
-- result permanently wiped the cache.
--
-- Structural test: asserts the config no longer registers the hide autocmd
-- while lint-on-InsertLeave is preserved. Behavioral verification is manual
-- (see plan Task 6).
--
-- Run from anywhere:
--   nvim --headless -u NONE -l ~/.config/nvim/tests/insert_mode_diagnostics_regression.lua
--
-- NOTE: load-bearing order -- `dofile` only RETURNS the plugin spec table and
-- does NOT execute config(). The nvim-lint stubs below must be installed
-- BEFORE `pcall(spec.config)` runs. Do not reorder.

local src = debug.getinfo(1, "S").source:sub(2) -- strip leading '@'
local script_dir = vim.fn.fnamemodify(src, ":p:h")

-- Stub nvim-lint so the plugin config can run headless without the plugin.
package.preload["lint"] = function()
  return {
    util = { path = {} },
    linters = {},
    linters_by_ft = {},
    try_lint = function() end,
  }
end
package.preload["lint.util"] = function()
  return { path = { join = function(...) return table.concat({ ... }, "/") end } }
end
package.preload["lint.parser"] = function()
  return { from_errorformat = function() return {} end }
end

local spec = dofile(script_dir .. "/../lua/jyrwa/plugins/linting.lua")
assert(type(spec.config) == "function", "linting.lua must export a config function")

local ok, err = pcall(spec.config)
assert(ok, "linting.lua config failed: " .. tostring(err))

local autocmds = vim.api.nvim_get_autocmds({ group = "LintAutoGroup" })
local function count(event)
  return #vim.tbl_filter(function(a)
    return a.event == event
  end, autocmds)
end

assert(count("InsertLeave") >= 1, "InsertLeave lint trigger must remain")
assert(
  count("InsertEnter") == 0,
  "REGRESSION: an InsertEnter autocmd hides diagnostics and they never come back"
)

print("PASS: no InsertEnter hide autocmd; InsertLeave lint trigger intact")
