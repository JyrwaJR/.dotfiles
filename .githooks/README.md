# Git Hooks

Version-controlled custom hooks for this repository.

## Install

```sh
git config core.hooksPath .githooks
```

## Hooks

### `pre-commit`

Runs on every commit. Checks staged files for:

- **Merge conflict markers** (`<<<<<<<`, `=======`, `>>>>>>>`) — prevents accidental commits of unresolved conflicts
- **Sensitive files** — rejects `.env`, `id_rsa`, `id_ed25519`, `.pem`, `.key`, and files matching `*secrets*`

Only staged content is checked (via `git diff --cached`).

### `commit-msg`

Validates commit messages follow **Conventional Commits** format:

```
<type>(<optional scope>): <description>

feat:       new feature
fix:        bug fix
chore:      maintenance, tooling
refactor:   code restructuring
docs:       documentation only
test:       adding/fixing tests
```

## Bypass

Skip hooks for a single commit:

```sh
git commit --no-verify
```
