local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

config.font = wezterm.font("Recursive Mn Csl St")
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.75
config.hide_mouse_cursor_when_typing = true
config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" }
config.macos_window_background_blur = 10
config.keys = {
	{
		key = "H",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "V",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "|",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	{
		key = "B",
		mods = "CTRL|SHIFT",
		action = wezterm.action({
			SpawnCommandInNewTab = { args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-l" } },
		}),
	},
	{
		key = "C",
		mods = "CTRL|SHIFT",
		action = wezterm.action({
			SpawnCommandInNewTab = { args = { "C:\\Windows\\System32\\cmd.exe" } },
		}),
	},
	{
		key = "P",
		mods = "CTRL|SHIFT",
		action = wezterm.action({
			SpawnCommandInNewTab = { args = { "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" } },
		}),
	},
	{
		key = "]",
		mods = "CMD|SHIFT",
		action = wezterm.action.ToggleAlwaysOnTop,
	},
}

return config
