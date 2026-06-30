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
- **brainstormer.md** — Design exploration, requirements gathering
- **planner.md** — Creates structured plans with task breakdowns
- **build.md** — Implementation, testing, refactoring, commits
- **review.md** — Code quality and security review

### Skills (`opencode/skills/`)
42 skills covering: API design, Code review, Expo (module/dev/deploy/CI-CD), Express, Feature refactoring, Liquid glass design, OWASP security, Performance optimization, Plannotator, Prisma, TDD, TypeScript advanced types, Git worktrees, Debugging, Brainstorming, and more.

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
