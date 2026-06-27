# Contributing to ECC for OpenCode

## Adding a New Agent

1. Create a prompt file in `prompts/agents/<name>.txt`
2. Add the agent config to `opencode.json` under `agent` key

## Adding a New Command

1. Create `commands/<name>.md` with frontmatter
2. Add the command entry to `opencode.json` under `command` key

## Adding a New Skill

1. Create `skills/<name>/SKILL.md` with workflow instructions
2. Add the skill path to the `instructions` array in `opencode.json`

## Plugin Hooks

Hooks live in `plugins/ecc-hooks.ts` using OpenCode's event system.
Available events: `file.edited`, `tool.execute.before`, `tool.execute.after`,
`session.created`, `session.idle`, `session.deleted`, `shell.env`, `permission.ask`.
