# Hooks System

> OpenCode implements hooks via **plugins** (`@opencode-ai/plugin`), not JSON config.
> The Claude Code-style `PreToolUse`/`PostToolUse`/`Stop` JSON format does **not** work in opencode.

## Hook Types (OpenCode Plugin API)

| Claude Code Concept | OpenCode Equivalent | When It Runs |
|---------------------|---------------------|--------------|
| `PreToolUse` | `tool.execute.before` | Before tool execution (validation, blocking) |
| `PostToolUse` | `tool.execute.after` | After tool execution (auto-format, checks) |
| `Stop` | `event` hook → `session.idle` | When agent finishes a turn |
| — | `dispose()` | When plugin is torn down |
| — | `chat.message` | When a new message is received |
| — | `chat.params` | Modify LLM parameters |
| — | `permission.ask` | Intercept permission requests |
| — | `shell.env` | Inject env vars into shell execution |

## Plugin Structure

```typescript
import type { Plugin } from "@opencode-ai/plugin"

/** @description Example plugin showing hook signatures */
export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    // Before tool execution - can block or modify args
    "tool.execute.before": async (input, output) => {
      // input: { tool, sessionID, callID }
      // output: { args } - mutable, can modify tool arguments
      if (input.tool === "read" && output.args.filePath.includes(".env")) {
        throw new Error("Do not read .env files")
      }
    },

    // After tool execution - can modify output
    "tool.execute.after": async (input, output) => {
      // input: { tool, sessionID, callID, args }
      // output: { title, output, metadata } - all mutable
      if (input.tool === "edit" || input.tool === "write") {
        await $`npx prettier --write ${input.args.filePath}`
      }
    },

    // Session idle - agent finished a turn
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        // Run final verification
      }
    },
  }
}
```

## Plugin Registration

Plugins load automatically from:
- `.opencode/plugins/` — project-level (auto-loaded)
- `~/.config/opencode/plugins/` — global (auto-loaded)
- `opencode.json` `plugin` array — npm packages or explicit paths

## Hook Parameters

### tool.execute.before

```
input:  { tool: string, sessionID: string, callID: string }
output: { args: any }  // mutable — modify tool arguments
```

Throwing an `Error` blocks the tool call.

### tool.execute.after

```
input:  { tool: string, sessionID: string, callID: string, args: any }
output: { title: string, output: string, metadata: any }  // all mutable
```

### event

Receives every server event: `session.created`, `session.idle`, `session.error`,
`tool.execute.before`, `tool.execute.after`, `permission.asked`, etc.

### dispose

No parameters. Fires at teardown — good for cleanup, no session context.

## Security Best Practices

- Validate all `output.args` before forwarding
- Never log raw tool arguments (may contain secrets)
- Throw errors for blocked operations (do not silently allow)
- Prefer await on `$` shell commands — async hooks can stall without timeout

## TodoWrite / Task Tracking

Use the todowrite tool to:
- Track progress on multi-step tasks
- Verify understanding of instructions
- Enable real-time steering

## Example Plugin: Auto-Lint

See `.opencode/plugins/auto-lint.ts` in the repository root.

## Example Plugin: Verify-On-Idle

See `.opencode/plugins/verify-on-idle.ts` in the repository root.
