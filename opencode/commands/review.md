---
description: Request code review to catch issues before they cascade (dispatched to BUILD mode)
agent: build
---

Load the requesting-code-review skill and dispatch a code reviewer subagent to review the current changes against requirements. Provide git SHAs (BASE and HEAD) and the plan context.
