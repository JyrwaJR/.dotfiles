---
description: Explore ideas, requirements, and design before implementation
---

Explore the idea or problem described: $ARGUMENTS

## Skills

- **brainstorming** (primary) — structured ideation workflow
- **writing-plans** — follow up with a formal plan once direction is clear
- **subagent-driven-development** — dispatch parallel exploration for complex multi-faceted ideas

## Process

1. Load the `brainstorming` skill and follow its structured workflow.
2. Ask clarifying questions to understand intent, constraints, and success criteria.
3. Propose 2–3 viable approaches with trade-offs (complexity, maintainability, security, DX).
4. Help the user converge on a design direction.
5. If the user wants to proceed, hand off to `/plan` to create a formal implementation plan.

## Rules

- Do not write or modify code during brainstorming.
- Do not skip the exploration phase — even seemingly simple ideas benefit from structured thinking.
- Capture key decisions and rationale for downstream reference.
