---
description: Evidence-before-claims verification gate
agent: build
---

Verify before claiming completion: $ARGUMENTS

## Skills

- **verification-before-completion** (primary) — evidence-based completion gate
- **code-reviewer** — post-verification quality check
- **security-reviewer** — post-verification security audit

## Process

1. Load the `verification-before-completion` skill.
2. Identify what "done" means for the current task (tests pass, build succeeds, etc.).
3. Run each verification command **fresh** — do not rely on previous output:

   | Check        | Command                        |
   | ------------ | ------------------------------ |
   | Tests        | `npm test` / `vitest` / `pytest` |
   | Build        | `npm run build` / `tsc --noEmit` |
   | Lint         | `npm run lint` / `eslint .`    |
   | Type check   | `tsc --noEmit`                 |

4. Read the actual output — do not assume success.
5. If any check fails, fix before claiming completion.
6. For significant changes, dispatch a `code-reviewer` subagent as a final gate.

## Rules

- **Evidence before assertions** — never claim success without running the command.
- No shortcuts — each check must be run and its output read.
- If verification reveals issues, fix them and re-verify.
- Only claim completion after all checks pass **and** output is confirmed.
