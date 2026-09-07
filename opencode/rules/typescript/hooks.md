---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript/JavaScript Hooks

> This file extends [common/hooks.md](../common/hooks.md) with TypeScript/JavaScript specific content.
> OpenCode implements hooks via **plugins** (`@opencode-ai/plugin`), not JSON config.

## tool.execute.after Hooks

Place in `.opencode/plugins/`:

- **Prettier**: Auto-format JS/TS files after edit
- **TypeScript check**: Run `tsc --noEmit` after editing `.ts`/`.tsx` files
- **console.log warning**: Detect `console.log` in edited files

```typescript
"tool.execute.after": async (input, output) => {
  if (input.tool !== "edit" && input.tool !== "write") return
  const filePath = input.args?.filePath
  if (!filePath || !filePath.endsWith(".ts") && !filePath.endsWith(".tsx")) return

  // Auto-format
  await $`npx prettier --write ${filePath}`

  // Type check
  await $`npx tsc --noEmit`

  // console.log detection
  const content = await $`cat ${filePath}`.text()
  if (/\bconsole\.log\b/.test(content)) {
    console.warn(`[hook] console.log found in ${filePath}`)
    throw new Error(`Remove console.log from ${filePath} — use a structured logger instead`)
  }
}
```

## Session Idle (Stop Equivalent)

- **console.log audit**: Check all modified files for `console.log` when the session ends

```typescript
event: async ({ event }) => {
  if (event.type === "session.idle") {
    // Audit modified files for console.log
  }
}
```
