> This file extends [common/hooks.md](../common/hooks.md) with web-specific hook recommendations.

# Web Hooks

> OpenCode implements hooks via **plugins**, not JSON config.
> Use the `tool.execute.after` hook for PostToolUse equivalents.

## Recommended tool.execute.after Hooks

Prefer project-local tooling. Do not wire hooks to remote one-off package execution.

### Format on Save

Use the project's existing formatter entrypoint after edits:

```typescript
"tool.execute.after": async (input, output) => {
  if ((input.tool === "edit" || input.tool === "write") && input.args?.filePath) {
    await $`pnpm prettier --write ${input.args.filePath}`
  }
}
```

### Lint Check

```typescript
"tool.execute.after": async (input, output) => {
  if ((input.tool === "edit" || input.tool === "write") && input.args?.filePath) {
    await $`pnpm eslint --fix ${input.args.filePath}`
  }
}
```

### Type Check

```typescript
"tool.execute.after": async (input, output) => {
  if (input.tool === "edit" || input.tool === "write") {
    await $`pnpm tsc --noEmit --pretty false`
  }
}
```

### CSS Lint

```typescript
"tool.execute.after": async (input, output) => {
  if ((input.tool === "edit" || input.tool === "write") && input.args?.filePath) {
    await $`pnpm stylelint --fix ${input.args.filePath}`
  }
}
```

## tool.execute.before Hooks

### Guard File Size

Block oversized writes from tool input content:

```typescript
"tool.execute.before": async (input, output) => {
  if (input.tool === "write") {
    const content = output.args?.content ?? ""
    const lines = content.split("\n").length
    if (lines > 800) {
      throw new Error(`Blocked: File exceeds 800 lines (${lines} lines). Split into smaller modules.`)
    }
  }
}
```

## Session Idle Verification

### Final Build Verification

```typescript
event: async ({ event }) => {
  if (event.type === "session.idle") {
    await $`pnpm build`
  }
}
```

## Ordering

Recommended order:
1. format
2. lint
3. type check
4. build verification (on session idle)
