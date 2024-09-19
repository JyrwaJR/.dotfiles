-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
-- my coolnight colorscheme
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	split = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

config.font_size = 14
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_background_opacity = 1
config.hide_mouse_cursor_when_typing = true
config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" }
--spit pane
config.keys = {
	-- This will create a new split and run your default program inside it
	{
		key = "H",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- This will create a new split and run the `top` program inside it
	{
		key = "V",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitVertical({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		key = "|",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitPane({
			direction = "Left",
			size = { Percent = 50 },
		}),
	}, -- 	-- Open a new tab with bash
	{
		key = "B",
		mods = "CTRL|SHIFT",
		action = wezterm.action({ SpawnCommandInNewTab = { args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" } } }),
	},
	--Open a new tab with cmd (Command Prompt)
	{
		key = "C",
		mods = "CTRL|SHIFT",
		action = wezterm.action({ SpawnCommandInNewTab = { args = { "C:\\Windows\\System32\\cmd.exe" } } }),
	},
	-- Open a new tab with PowerShell
	{
		key = "P",
		mods = "CTRL|SHIFT",
		action = wezterm.action({
			SpawnCommandInNewTab = { args = { "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" } },
		}),
	},
	-- Toggle always on top
	{
		key = "]",
		mods = "CMD|SHIFT",
		action = wezterm.action.ToggleAlwaysOnTop,
	},
}

return config
