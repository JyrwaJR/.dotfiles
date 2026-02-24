local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Macchiato" -- Mocha Macchiato

config.font = wezterm.font("RecMonoCasual Nerd Font", {
	weight = 900,
	italic = true,
})

-- config.font = wezterm.font("FiraCode Nerd Font Mono", {
-- 	weight = 600,
-- 	italic = false,
-- })

config.font_size = 20
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_background_opacity = 1
config.hide_mouse_cursor_when_typing = true
config.macos_window_background_blur = 8
config.window_close_confirmation = "NeverPrompt"

-- Set zsh as the default shell for new tabs/windows
config.default_prog = { "/bin/zsh", "--login" } -- Replace with the correct path to zsh for your system

config.keys = {
	{
		key = "|",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "|",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	-- Modify the keybinding for Ctrl+Shift+B to open a new tab with zsh
	{
		key = "B",
		mods = "CTRL",
		action = wezterm.action({
			SpawnCommandInNewTab = { args = { "/bin/zsh", "--login" } }, -- Ensure this points to the correct zsh path
		}),
	},
	-- Key bindings for pane navigation like nvim
	{
		key = "H",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "J",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "K",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "L",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
}
return config
