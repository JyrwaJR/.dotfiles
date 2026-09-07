---
description: Request code review to catch issues before they cascade
agent: build
---

Review the current changes: $ARGUMENTS

## Skills

- **requesting-code-review** (primary) — structured review dispatch workflow
- **code-reviewer** — the review specialist invoked as a subagent
- **receiving-code-review** — when acting on review feedback
- **verification-before-completion** — verify fixes from review feedback

## Process

1. Load the `requesting-code-review` skill.
2. Determine the review scope:
   - If SHAs provided → review the diff between BASE and HEAD
   - If no SHAs → review all uncommitted changes (`git diff`)
3. Dispatch a `code-reviewer` subagent with:
   - Git diff context (file changes, diff stats)
   - Plan context (if an active plan exists)
   - Specific review focus areas (if mentioned)
4. Present findings organized by severity: **Critical → High → Medium → Low → Nit**
5. For critical/high findings, propose or implement fixes.

## Review Focus Areas

- **Correctness** — logic errors, edge cases, off-by-one
- **Security** — injection, XSS, auth bypass, secrets in code
- **Performance** — N+1 queries, unnecessary re-renders, memory leaks
- **Maintainability** — naming, complexity, duplication, test coverage
- **Type safety** — `any` usage, missing types, type assertions

## Rules

- Do not skip the review — even small changes can have subtle issues.
- Critical and high findings are blockers — fix before proceeding.
- If the user asks you to act on feedback, load `receiving-code-review` first.
