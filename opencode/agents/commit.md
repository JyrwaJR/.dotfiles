---
description: Stage and commit related changes with Conventional Commit messages
agent: build
---

Analyze the working tree with `git status --short` and `git diff --stat`. Group related files by path and diff content. Commit behavior depends on the invocation:

- If specific files are mentioned → `git add <files>` then commit with Conventional Commit type
- If "all" is mentioned → stage and commit every changed file
- If neither → do not commit anything. Just show the working tree state grouped by Conventional Commit type

Use Conventional Commit types (feat:, fix:, chore:, refactor:, docs:, test:). Do not ask for approval on groups — just commit.
