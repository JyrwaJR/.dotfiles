# Configuration Reference

<!-- Generated: 2026-06-27 | Files scanned: 33 | Token estimate: ~300 -->

## opencode.jsonc

- **Schema**: https://opencode.ai/config.json
- **Plugin**: superpowers v5.1.0 (git+https)
- **MCP Servers**: 8 total

### MCP Server Chain

```
opencode.jsonc
├── sequential-thinking  (npx) — Chain-of-thought reasoning
├── context7             (npx) — Library documentation
├── chrome-devtools      (npx, Brave exec) — Browser automation
├── playwright           (npx) — E2E testing
├── filesystem           (npx, cwd: .) — File access
├── expo                 (npx) — React Native
├── react-native-expo    (npx) — RN MCP tools
└── opencode-mcp         (npx) — OpenCode API control
```

## AGENTS.md (v2.0.1)

- 1100 lines, 18 sections
- Platform: Google Antigravity
- Security: OWASP Top 10, SSRF prevention, prompt injection
- Terminal: T1/T2/T3 policy model

## Themes

- `themes/catppuccin-no-bg.json` — Catppuccin variant (no background)

## Logging

- `logs/combined.log` — All activity
- `logs/error.log` — Errors only
