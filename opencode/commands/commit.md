---
description: Stage and commit related changes with Conventional Commit messages
agent: build
---

Stage and commit changes: $ARGUMENTS

## Skills

- **code-reviewer** — quick pre-commit quality check (optional, for large changesets)
- **verification-before-completion** — ensure tests pass before committing

## Process

1. Run `git status --short` and `git diff --stat` to assess the working tree.
2. Group related files by path and diff content into logical commits.
3. For each group, determine the Conventional Commit type:

   | Type       | When                                                    |
   | ---------- | ------------------------------------------------------- |
   | `feat:`    | New feature or capability                               |
   | `fix:`     | Bug fix                                                 |
   | `chore:`   | Maintenance, dependency updates, config changes         |
   | `refactor:`| Code restructuring without behavior change             |
   | `docs:`    | Documentation-only changes                              |
   | `test:`    | Adding or updating tests                                |

4. Commit behavior based on invocation:

   - **Specific files mentioned** → `git add <files>` then commit
   - **"all" mentioned** → `git add -A` and commit every changed file
   - **Neither** → show working tree state grouped by commit type, do not commit

5. Write clear, concise commit messages — subject line ≤72 chars, body when needed.

## Rules

- Do not ask for approval on groups — just commit.
- Never commit `.env`, secrets, credentials, or private keys.
- If tests exist, verify they pass before committing (run `npm test` or equivalent).
- Multiple atomic commits preferred over one large commit when changes are unrelated.
