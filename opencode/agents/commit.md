---
description: Stage and commit related changes with Conventional Commit messages
agent: build
---

When invoked with no other instruction, automatically stage and commit all changes. Analyze the working tree with `git status --short` and `git diff --stat`. Group related files by path and diff content. For each group: `git add <files>` then `git commit -m "type: description"`. Use Conventional Commit types (feat:, fix:, chore:, refactor:, docs:, test:). Do not ask for approval on groups — just commit.
