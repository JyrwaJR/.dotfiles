# Design: Modular Flutter Neovim Integration

**Status:** APPROVED
**Topic:** Neovim Configuration for Flutter
**Date:** 2026-05-04

## Goals
- Add Flutter/Dart support to the existing `jyrwa` Neovim configuration.
- Integrate with `blink.cmp` for autocompletion.
- Ensure modularity and keep it lightweight.

## Proposed Changes

### 1. Flutter Plugin (`lua/jyrwa/plugins/flutter.lua`)
Add `flutter-tools.nvim` with the following configuration:
- LSP integrated with existing LSP setup.
- Keybindings:
  - `<leader>Fr` -> `FlutterRun`
  - `<leader>Fh` -> `FlutterHotReload`
  - `<leader>FR` -> `FlutterHotRestart`
- Widget guides enabled.

### 2. LSP Integration (`lua/jyrwa/plugins/lsp/lspconfig.lua`)
- Add `dartls` to `mason-lspconfig` ensure_installed list.
- Note: `flutter-tools.nvim` will manage the `dartls` setup, so we don't need to manually call `lspconfig.dartls.setup` in `lspconfig.lua` to avoid conflicts.

### 3. Treesitter (`lua/jyrwa/plugins/treesitter.lua`)
- Add `dart` to the `ensure_installed` list for syntax highlighting.

## Approaches Considered
- **Standalone init.lua**: Rejected to maintain user's existing modular configuration.
- **Switch to nvim-cmp**: Rejected as user preferred staying with their current `blink.cmp` setup.

## Success Criteria
- Opening a `.dart` file triggers `dartls`.
- Flutter commands are available via keymaps.
- Autocompletion works via `blink.cmp`.
- Syntax highlighting is active for Dart.
