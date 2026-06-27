# Architecture

<!-- Generated: 2026-06-27 | Files scanned: 33 | Token estimate: ~400 -->

## Project Type

**Tool Configuration** — OpenCode AI agent configuration within dotfiles.

## Entry Point

opencode.jsonc (46 lines) — Plugin + MCP server registration

## Key Files

```
opencode.jsonc        → MCP servers (7), plugin (1)
AGENTS.md             → Agent instructions (1100 lines, v2.0.1)
commands/             → 29 custom slash commands
themes/               → 1 theme (catppuccin-no-bg)
logs/                 → Application logs (combined.log, error.log)
package.json          → Plugin dependency (@opencode-ai/plugin 1.15.13)
```

## Data Flow

```
User slash command → opencode.jsonc dispatches → commands/<name>.md executes
         ↓
    MCP servers (chrome-devtools, playwright, filesystem, context7, etc.)
         ↓
    Agent processes via AGENTS.md instructions
```

## File Boundaries

| Layer | Directory | Purpose |
|-------|-----------|---------|
| Config | `opencode.jsonc` | Plugin/MCP/feature flags |
| Instructions | `AGENTS.md` | Agent behavior, OWASP, security |
| Commands | `commands/*.md` | User-invokable workflows |
| Themes | `themes/*.json` | UI appearance |
| Logs | `logs/*.log` | Runtime errors + activity |
