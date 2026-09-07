---
description: Systematic root-cause debugging before proposing fixes
agent: plan
---

Debug the issue: $ARGUMENTS

## Skills

- **systematic-debugging** (primary) — four-phase root-cause analysis
- **sequential-thinking** (MCP) — step-by-step reasoning for complex bugs
- **build-error-resolver** — when the issue is a build/type error

## Process

1. Load the `systematic-debugging` skill and follow its four phases:

   | Phase | Activity                                        |
   | ----- | ----------------------------------------------- |
   | 1     | **Reproduce** — confirm the bug exists, gather symptoms |
   | 2     | **Investigate** — read error messages, stack traces, logs |
   | 3     | **Hypothesize** — form root-cause hypotheses, test each |
   | 4     | **Fix** — implement minimal fix, verify resolution    |

2. Use `sequential-thinking` MCP for complex multi-step reasoning.
3. Read relevant source files, configs, and logs before proposing fixes.
4. Never propose a fix without identifying the root cause first.

## Rules

- No fixes without root cause — symptoms ≠ cause.
- Prefer reading code over guessing — trace the actual execution path.
- If the bug is a build/type error, load `build-error-resolver` instead.
- Document the root cause and fix rationale for future reference.
