# Design: Geist Mono Nerd Font Integration for WezTerm

**Status:** PENDING APPROVAL
**Target:** WezTerm + Neovim
**Date:** 2026-06-01

## 🎯 Goal
Replicate the font aesthetic of AstroNvim's default "AstroDark" setup using **Geist Mono Nerd Font** in WezTerm, ensuring high-quality glyph rendering and "airy" line spacing.

## 🛠️ Components

### 1. Font Selection
- **Primary Font:** `Geist Mono`
- **Nerd Font Patch:** `GeistMono Nerd Font`
- **Rationale:** The AstroNvim website screenshots (2026 revision) use Geist Mono for its geometric precision and modern developer aesthetic.

### 2. WezTerm Configuration (`wezterm.lua`)
We will apply the following settings to your WezTerm configuration:

```lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback {
  'Geist Mono',
  'GeistMono Nerd Font',
}
config.font_size = 13.5
config.line_height = 1.15 -- This provides the AstroNvim "airy" spacing

return config
```

### 3. Neovim Alignment
- **Mini Icons:** Already configured to use Nerd Font glyphs (`mini.icons`).
- **Devicons:** Mocked via `mini.icons` in `mini-icon.lua`.
- **Action:** No Neovim config changes required; the font update in the terminal will automatically apply to Neovim.

## ✅ Success Criteria
- Neovim displays JetBrains Mono as the primary typeface.
- File icons in `bufferline` and `mini.icons` render without clipping.
- Vertical spacing matches the AstroNvim reference image.

## 🚀 Execution Plan
1. Install font via `brew install --cask font-jetbrains-mono-nerd-font`.
2. Locate and update `wezterm.lua`.
3. Restart WezTerm.
