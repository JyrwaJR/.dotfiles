---
description: Stage and commit related changes with Conventional Commit messages
agent: build
---

Analyze the working tree with `git status --short` and `git diff --stat`. Group related files by path and diff content. Show groups to the user and for each approved group: `git add <files>` then `git commit -m "type: description"`. Use Conventional Commit types (feat:, fix:, chore:, refactor:, docs:, test:).
