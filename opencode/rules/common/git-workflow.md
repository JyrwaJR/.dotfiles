# Git Workflow

## Branch Creation

- **Always create a new branch** before making any changes. Never work directly on `master`.
- **Branch naming:** `<type>/<description>` — types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `perf`, `experiment`
- **Create with:** `git checkout -b <type>/<description>`
- **No direct master work.** All changes must be developed on a feature branch.
- **Merging to master** requires explicit user instruction. Never merge without being told.

## Commit Message Format
```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Note: Attribution disabled globally via ~/.claude/settings.json.

## Pull Request Workflow

When creating PRs:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch

> For the full development process (planning, TDD, code review) before git operations,
> see [development-workflow.md](./development-workflow.md).
