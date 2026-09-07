---
description: Deep reasoning and structured planning for complex problems
agent: plan
---

Reason through the problem: $ARGUMENTS

## Skills

- **sequential-thinking** (MCP tool) — step-by-step reflective reasoning
- **writing-plans** — follow up with a formal plan once the analysis is complete
- **brainstorming** — if the problem is open-ended or needs design exploration first

## Process

Use the `sequential-thinking` MCP tool to reason through the problem systematically. Work through these steps:

1. **Understand** — identify the objective, requirements, constraints, and assumptions
2. **Inspect** — examine relevant code, architecture, configs, APIs, and patterns
3. **Decompose** — break into smaller parts, identify dependencies and critical path
4. **Explore** — consider multiple approaches when appropriate
5. **Evaluate** — compare trade-offs (correctness, complexity, performance, security, DX)
6. **Recommend** — select the best approach with clear rationale
7. **Plan** — produce an ordered, actionable implementation plan
8. **Edge cases** — identify failure scenarios and unusual inputs
9. **Verify** — check internal consistency, missing deps, and regressions

## Output Format

Structure the response as:

- **Problem** — restate the objective
- **Current Understanding** — relevant architecture and constraints
- **Analysis** — reasoning, dependencies, technical considerations
- **Alternatives** — meaningful approaches with trade-offs
- **Recommended Approach** — chosen approach and why
- **Implementation Plan** — ordered, actionable steps
- **Risks & Edge Cases** — failure modes and concerns
- **Testing & Verification** — how to validate the solution
- **Open Questions** — only what genuinely blocks implementation

## Rules

- Do not write or modify code unless explicitly requested.
- Purpose is to **reason, investigate, compare, and plan** — not to implement.
- If the problem needs design exploration first, load `brainstorming` before reasoning.
- Once analysis is complete, suggest `/plan` to formalize the implementation plan.
