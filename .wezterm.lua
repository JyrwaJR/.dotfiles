local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- ==========================================================
-- THEME & VISUALS
-- ==========================================================
config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font("RecMonoCasual Nerd Font", { weight = 900, italic = true })
config.font_size = 20.0

config.set_environment_variables = {
	HOME = os.getenv("HOME"),
	PATH = "/opt/homebrew/bin:/usr/local/bin:" .. os.getenv("PATH"),
}
-- SLEEK UI
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.command_palette_rows = 1
config.enable_tab_bar = false
config.status_update_interval = 1000
config.term = "xterm-256color"
-- Padding: slightly more room at bottom for the status text
config.window_padding = { left = 15, right = 15, top = 15, bottom = 0 }
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.85
config.macos_window_background_blur = 30

-- Status Bar (Right side info)
wezterm.on("update-right-status", function(window, pane)
	local name = window:active_workspace()
	window:set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { AnsiColor = "Fuchsia" } },
		{ Text = "  WS: " .. name .. "  " },
	}))
end)

-- ==========================================================
-- PERFORMANCE & BEHAVIOR
-- ==========================================================
config.scrollback_lines = 5000
config.front_end = "WebGpu"
config.default_cursor_style = "SteadyBar"
config.window_close_confirmation = "NeverPrompt"

-- ==========================================================
-- KEYBINDINGS
-- ==========================================================
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

config.keys = {
	-- PANE MANAGEMENT
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

	-- SMART NAVIGATION (Ctrl + Shift + H/J/K/L)
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

	-- RESIZING PANES
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "UpArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "DownArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },

	-- WORKSPACE MANAGEMENT
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{
		key = "N",
		mods = "LEADER|SHIFT",
		action = act.PromptInputLine({
			description = "Create Workspace:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},
	{
		key = "R",
		mods = "LEADER|SHIFT",
		action = act.PromptInputLine({
			description = "Rename Workspace:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
				end
			end),
		}),
	},
	{ key = "n", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(1) },
	{ key = "p", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
	{ key = "D", mods = "LEADER|SHIFT", action = act.SwitchToWorkspace({ name = "default" }) },

	-- SEARCH & COPY
	{ key = "f", mods = "LEADER", action = act.Search({ CaseInSensitiveString = "" }) },
	{ key = "v", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "p", mods = "LEADER", action = act.PasteFrom("Clipboard") },

	-- UTILS
	{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
	{ key = "+", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	{
		key = ",",
		mods = "LEADER",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = wezterm.home_dir,
			args = {
				"/bin/zsh",
				"-lc",
				"export XDG_CONFIG_HOME=$HOME/.config; nvim " .. wezterm.home_dir .. "/.wezterm.lua",
			},
		}),
	},
	-- TAB SWITCHING
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },

	-- NEW TAB (same directory as current pane)
	{
		key = "b",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local cwd = pane:get_current_working_dir()
			window:perform_action(
				act.SpawnCommandInNewTab({
					cwd = cwd and cwd.file_path or wezterm.home_dir,
				}),
				pane
			)
		end),
	},
}

return config
