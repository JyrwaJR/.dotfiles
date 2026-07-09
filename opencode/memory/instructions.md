# Agent Harness — Dotfiles Project

## Project Overview

- **Repository:** `/Users/harrison/.dotfiles`
- **Config:** `opencode/opencode.jsonc`
- **Package:** `@opencode-ai/plugin 1.16.0`

## Purpose

Personal dotfiles repository containing:
- System configuration (`.zshrc`, `.wezterm.lua`, `.bashrc`, `starship/`, `nvim/`)
- OpenCode agent harness with skills, agents, and rules
- Agent-driven development workflow (Plan → Brainstorm → Build → Review)

## Architecture

### Agents (`opencode/agents/`)
- **plan.md** — Creates structured plans with design exploration, deep reasoning, and subagent review gates
- **build.md** — TDD-driven implementation, security review via OWASP Top 10, verification before completion

### Skills (`opencode/skills/`)
42 skills covering: API design, Code review, Expo (module/dev/deploy/CI-CD), Express, Feature refactoring, Liquid glass design, OWASP security, Performance optimization, Plannotator, Prisma, TDD, TypeScript advanced types, Git worktrees, Debugging, Brainstorming, and more.

### Skill Protocol

Always check for applicable skills before acting (§12 AGENTS.md). Priority:
1. Process skills first (brainstorming, debugging, writing-plans)
2. Implementation skills second (code-reviewer, security-reviewer, tdd-guide)
3. For skills not in the local directory, use `find-skills` skill or web search to discover them

### Rules (`opencode/rules/`)
- **common/** — Language-agnostic: coding-style, git-workflow, testing, performance, patterns, security, agents
- **web/** — Web/frontend specific
- **swift/** — Swift specific
- **typescript/** — TypeScript/JavaScript specific
- **dart/** — Dart specific

## MCP Servers Configured

| Server | Type | Purpose |
|--------|------|---------|
| sequential-thinking | local | Step-by-step reasoning |
| memories | local | Persistent memory (@memories.sh/cli) |
| shadcn | local | shadcn/ui component registry |
| context7 | local | Documentation queries |
| chrome-devtools | local | Browser DevTools automation (Brave) |
| playwright | local | Browser automation/testing |
| filesystem | local | File system access |

## Tech Stack Defaults

- TypeScript (strict)
- Node.js 18+
- Tailwind CSS, shadcn/ui
- PostgreSQL + Prisma
- Vitest + React Testing Library
- Playwright (E2E)
- Next.js 14+ (App Router)

## Key Conventions

- **File naming:** kebab-case files, PascalCase components
- **Exports:** Named exports preferred
- **Imports:** Absolute via `@` alias
- **Commits:** Conventional Commits (feat:, fix:, chore:, docs:, test:, refactor:)
- **JSDoc:** Required on every exported symbol
- **Security:** OWASP Top 10 compliance, zero-knowledge principles
- **Memory store:** `~/.dotfiles/opencode/memory/db/local.db`

## Security Rules

- No hardcoded secrets; use env vars
- All user input validated server-side (Zod)
- Parameterized DB queries only
- Passwords hashed with Argon2id or bcrypt
- Domain allowlist enforced for outbound requests
- Internal IP ranges always blocked
- T3 permissions auto-expire when production config appears
