# Rename `~/.dotfiles` → `~/.config` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the local dotfiles folder from `~/.dotfiles` to `~/.config`, update every `.dotfiles` path reference (live shell config + repo-tracked files) to `.config`, and extract real secrets out of the live `~/.zshrc` into a gitignored env file so the rename is repo-safe and nothing sensitive enters git.

**Architecture:** The folder `~/.dotfiles` serves as `$XDG_CONFIG_HOME` (set in the live `~/.zshrc`). Tools read their configs from inside it (Neovim, starship, opencode, memories). We will (1) back up the live shell config, (2) move the real secrets out of `~/.zshrc` into a new gitignored `~/.config/.env.local` sourced by the shell, (3) update all `.dotfiles` → `.config` refs in the live `~/.zshrc`, the repo-tracked `.zshrc`/`.bashrc`, and repo config/docs files, (4) physically move the folder, (5) verify nothing breaks, then (6) commit and push to the already-renamed `JyrwaJR/.config` GitHub remote.

**Tech Stack:** zsh shell config, bash, git, Neovim (blink.cmp snippet `search_paths`), opencode (permissions + memories MCP), memories.sh (`MEMORIES_DATA_DIR`), starship.

**Critical pre-existing facts (verified):**
- Live shell is **zsh** (`SHELL=/bin/zsh`). Only `~/.zshrc` and `~/.zprofile` exist on disk; `.bashrc` does **not** exist on disk (but IS tracked in the repo as a stale copy).
- `~/.config` **does not physically exist** on disk — the `ls ~/.config` output earlier was just `~/.dotfiles` contents shown via `XDG_CONFIG_HOME`. So there is **no collision** when we rename.
- There are **two diverged `.zshrc` files**: the **live** `~/.zshrc` (3071 bytes, on disk, what zsh reads — contains real secrets) and the **stale repo-tracked** `~/.dotfiles/.zshrc` (1868 bytes). They are **not symlinked**. Both must be updated and kept consistent.
- The **live `~/.zshrc` contains real hardcoded secrets** at the bottom:
  - `OPENCODE_SERVER_PASSWORD="<REDACTED>"`
  - `STITCH_API_KEY="<REDACTED>"`
  These are **NOT tracked in git** (0 commits contain them) — verified safe. They must be moved to a gitignored env file so they never enter the repo and survive the folder move.
- The GitHub remote is **already renamed** to `JyrwaJR/.config.git` (URL updated), but the remote's `master` still contains `.dotfiles` refs in `.zshrc` and `blink.lua`. Local `master` is in sync with `origin/master` (0 ahead / 0 behind). After fixing refs locally we must **push** to update the remote.

---

## File Structure

| Path | Responsibility | Action |
|------|----------------|--------|
| `~/.zshrc` (LIVE, untracked) | Shell config zsh actually reads. Holds real secrets. | **Secret extraction + 4 path updates** |
| `~/.config/.env.local` (NEW, gitignored) | Holds the real secrets, sourced by `~/.zshrc`. | **Create** (gitignore it) |
| `~/.dotfiles/.zshrc` (tracked) | Stale repo copy of shell config. | **Update paths to `.config`** |
| `~/.dotfiles/.bashrc` (tracked) | Stale repo copy (bash). | **Update paths to `.config`** |
| `~/.dotfiles/.gitignore` | Git ignore rules. | **Add `.env.local`** |
| `nvim/lua/jyrwa/plugins/blink.lua` | Snippet search path. | **Update** `~/.dotfiles/nvim` → `~/.config/nvim` |
| `opencode/opencode.jsonc` | Permission allowlist + MCP env. | **Update** `~/.dotfiles` → `~/.config` |
| `opencode/scripts/memories-mcp.sh` | Memory MCP script. | **Update** 2 path refs |
| `opencode/memory/config.yaml` | Memory DB store. | **Update** 1 path ref |
| `opencode/AGENTS.md` | Agent instructions. | **Update** 3 path refs |
| `opencode/memory/instructions.md` | Memory instructions. | **Update** 2 path refs |
| `nvim/tests/insert_mode_diagnostics_regression.lua` | Test comment. | **Update** 1 path ref |
| `Readme.md` | Windows symlink docs. | **Update** 4 refs (cosmetic) |
| `docs/superpowers/plans/2026-07-09-opencode-status-lualine.md` | Historical plan. | **Update** 5 refs (consistency) |
| `opencode/docs/.../2026-06-30-*.md`, `2026-07-01-*.md` | Historical plans. | **Update** (consistency, optional) |
| `~/.dotfiles` (folder) | The repo root. | **`mv ~/.dotfiles ~/.config` in the last task** |

---

## Task 0: Verify baseline & create feature branch

**Files:** (none modified)

**Goal:** Confirm clean, known-good starting state and an isolated branch before any destructive change.

- [ ] **Step 1: Confirm working tree is clean**

Run:
```bash
cd /Users/harrison/.dotfiles && git status --short
```
Expected: empty output (clean), on branch `master`.

- [ ] **Step 2: Create the feature branch**

```bash
cd /Users/harrison/.dotfiles && git checkout -b feat/rename-dotfiles-to-config
```
Expected: `Switched to a new branch 'feat/rename-dotfiles-to-config'`.

- [ ] **Step 3: Confirm the live shell config is untouched & safe to edit**

Run:
```bash
cp ~/.zshrc ~/.zshrc.backup-$(date +%Y%m%d)
ls -la ~/.zshrc.backup-*
```
Expected: a backup file `~/.zshrc.backup-20260907` is created.

- [ ] **Step 4: Commit the baseline guard (nothing changed yet, but confirm backup exists)**

This task does not modify tracked files, so no commit yet. Move to Task 1 after verifying Step 3's backup file exists.

---

## Task 1: Extract real secrets from live `~/.zshrc` into a gitignored env file

**Files:**
- Create: `~/.config/.env.local` (will be the moved location; during this task file is at `~/.dotfiles/.env.local` but we create the final target only after the move — instead create `~/.env.local` temporarily, OR create at `~/.dotfiles/.env.local` and move with the folder)

> **Design note:** Because `~/.config` does not exist yet and the folder is currently `~/.dotfiles`, the cleanest approach is to create the env file **inside the repo** at `~/.dotfiles/.env.local`, gitignore it, then let the folder move carry it to `~/.config/.env.local`. `~/.zshrc` will source `$XDG_CONFIG_HOME/.env.local` (which resolves correctly before and after the move, since `XDG_CONFIG_HOME` points at the repo folder either way).

**Purpose:** The live `~/.zshrc` has two hardcoded secrets:
- `OPENCODE_SERVER_PASSWORD="<REDACTED>"`
- `STITCH_API_KEY="<REDACTED>"`

We move them to a gitignored file. This keeps `~/.zshrc` clean and prevents the secrets from ever entering git (currently they are untracked and safe, but this makes it structurally impossible).

- [ ] **Step 1: Create the env file inside the repo**

Create `~/.dotfiles/.env.local` with:

```bash
# Local-only secrets. This file is gitignored — never commit it.
# Sourced by ~/.zshrc via: [ -f "$XDG_CONFIG_HOME/.env.local" ] && source "$XDG_CONFIG_HOME/.env.local"

# [SECRET] OpenCode server credentials
export OPENCODE_SERVER_USERNAME="jyrwa"
export OPENCODE_SERVER_PASSWORD="<REDACTED>"

# [SECRET] Google Stitch MCP API key
export STITCH_API_KEY="<REDACTED>"
```

- [ ] **Step 2: Add `.env.local` to `.gitignore`**

Add these lines to `~/.dotfiles/.gitignore` (append if not present):

```
# Local secrets — never commit
.env.local
```

- [ ] **Step 3: Verify the file is ignored by git**

Run:
```bash
cd /Users/harrison/.dotfiles && git check-ignore .env.local
```
Expected: prints `.env.local` (confirming it's ignored). If it prints nothing, the ignore rule didn't take; fix `.gitignore`.

- [ ] **Step 4: Remove the two secret exports from the LIVE `~/.zshrc`**

Edit the live `~/.zshrc` (`/Users/harrison/.zshrc`) and **delete** these three lines (they are the last 3 lines of the file):

```
export OPENCODE_SERVER_USERNAME="jyrwa"
export OPENCODE_SERVER_PASSWORD="<REDACTED>"
export STITCH_API_KEY="<REDACTED>"
```

- [ ] **Step 5: Add a source line for the env file into live `~/.zshrc`**

In the `### 🧠 Environment Setup ###` block of `/Users/harrison/.zshrc`, after the `export XDG_CONFIG_HOME=...` / `export MEMORIES_DATA_DIR=...` lines, add:

```bash
# Source local-only secrets (gitignored)
[ -f "$XDG_CONFIG_HOME/.env.local" ] && source "$XDG_CONFIG_HOME/.env.local"
```

- [ ] **Step 6: Verify the secrets still load correctly in a fresh shell**

Run:
```bash
zsh -lic 'echo "PASS=$OPENCODE_SERVER_PASSWORD"; echo "KEY=$STITCH_API_KEY"' 2>&1 | tail -3
```
Expected: prints the real values (confirming the source line works and secrets survived).

- [ ] **Step 7: Commit the gitignore + env file handling**

```bash
cd /Users/harrison/.dotfiles
git add .gitignore
git commit -m "chore: gitignore .env.local for local secrets"
```
Note: `.env.local` itself must NOT be staged (it's ignored, so `git add .gitignore` only stages the ignore rule). Confirm with `git status --short` that `.env.local` is absent from staged output.

---

## Task 2: Update the LIVE `~/.zshrc` paths from `.dotfiles` to `.config`

**Files:**
- Modify: `/Users/harrison/.zshrc` (LIVE, untracked — the file zsh actually reads)

**Purpose:** All 4 hardcoded `.dotfiles` references in the live shell config must become `.config`, so that after the folder move everything resolves. Because `XDG_CONFIG_HOME` is being changed to `$HOME/.config`, the `$XDG_CONFIG_HOME`-derived paths self-heal; only hardcoded `$HOME/.dotfiles/...` paths need literal replacement.

Live `~/.zshrc` current references (verified lines):

| Line# (live) | Current | New |
|---|---|---|
| 10 | `export PATH="$HOME/bin:$HOME/.dotfiles/lazygit:$HOME/.console-ninja/.bin:$PATH"` | `...:$HOME/.config/lazygit:...` |
| 29 | `export XDG_CONFIG_HOME="$HOME/.dotfiles"` | `export XDG_CONFIG_HOME="$HOME/.config"` |
| 34 | `export MEMORIES_DATA_DIR="$HOME/.dotfiles/opencode/memory/db"` | `...="$HOME/.config/opencode/memory/db"` |
| ~121 | `export PATH="$HOME/.dotfiles/composer/vendor/bin:$PATH"` | `...="$HOME/.config/composer/vendor/bin:$PATH"` |

Line 30 (`STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"`) self-heals via the new `XDG_CONFIG_HOME`.

- [ ] **Step 1: Replace the four `.dotfiles` path occurrences in live `~/.zshrc`**

Edit `/Users/harrison/.zshrc` replacing each `$HOME/.dotfiles` with `$HOME/.config` where it refers to lazygit, composer/vendor/bin, memories, and the XDG_CONFIG_HOME line. Do NOT touch the `MEMORIES_DATA_DIR`/composer lines' semantics beyond the path.

Concretely, apply these exact edits:

```bash
# Edit 1 (line 29):
sed -i '' 's|export XDG_CONFIG_HOME="$HOME/.dotfiles"|export XDG_CONFIG_HOME="$HOME/.config"|' ~/.zshrc

# Edit 2 (line 10 lazygit):
sed -i '' 's|\$HOME/\.dotfiles/lazygit|$HOME/.config/lazygit|' ~/.zshrc

# Edit 3 (line 34 memories):
sed -i '' 's|\$HOME/\.dotfiles/opencode/memory/db|$HOME/.config/opencode/memory/db|' ~/.zshrc

# Edit 4 (composer/vendor/bin):
sed -i '' 's|\$HOME/\.dotfiles/composer/vendor/bin|$HOME/.config/composer/vendor/bin|' ~/.zshrc
```

- [ ] **Step 2: Verify no `.dotfiles` remains in the live `~/.zshrc`**

Run:
```bash
grep -n '\.dotfiles' ~/.zshrc || echo "NO .dotfiles refs remain in live ~/.zshrc"
```
Expected: `NO .dotfiles refs remain in live ~/.zshrc`.

- [ ] **Step 3: Verify `~/.config` now resolves (through env) without breaking**

Since the folder move hasn't happened yet, `$HOME/.config` does not physically exist and `XDG_CONFIG_HOME=$HOME/.config` would be broken **until Task 3 moves the folder**. This is expected — do NOT test shell functionality until after the move. Just confirm the file content is correct with `grep -n 'XDG_CONFIG_HOME' ~/.zshrc` showing `$HOME/.config`.

No commit (live file untracked).

---

## Task 3: Physically move the folder and fix the git remote path on disk

**Files:**
- Move: `~/.dotfiles` → `~/.config` (entire repo folder)

**Purpose:** Perform the actual filesystem rename. The git history and remote are preserved because it's the same `.git` directory.

> **IMPORTANT:** Do this only after Task 1 (secrets extracted) and Task 2 (live `~/.zshrc` paths updated) so that the shell config pointing at `.config` is already correct, and the secrets travel inside the moved folder.

- [ ] **Step 1: Ensure no shell is mid-write and folder is stationary**

Run:
```bash
ls -la ~/.dotfiles/.env.local   # confirm secrets env file exists before move
```
Expected: `.env.local` present (contains the secrets from Task 1).

- [ ] **Step 2: Move the folder**

```bash
mv ~/.dotfiles ~/.config
```
Expected: `~/.config` now contains all of the former `~/.dotfiles` contents (nvim, opencode, starship, `.git`, etc.).

- [ ] **Step 3: Verify the move succeeded and git is intact**

Run:
```bash
ls ~/.config | head
git -C ~/.config status --short
git -C ~/.config branch --show-current
git -C ~/.config remote -v
```
Expected: contents listed; `git status` clean; branch `feat/rename-dotfiles-to-config`; remote `https://github.com/JyrwaJR/.config.git`.

- [ ] **Step 4: Confirm `.gitignore` still guards `.env.local` after the move**

Run:
```bash
cd ~/.config && git check-ignore .env.local
```
Expected: prints `.env.local`.

- [ ] **Step 5: Open a fresh shell and smoke-test key tools** (references move into Task 4-6 verification)

Because tasks 4–6 haven't updated the repo's internal `.dotfiles` refs yet, some repo-configured tools may not fully work until those tasks land. At minimum confirm the shell loads:

```bash
zsh -lic 'echo "XDG=$XDG_CONFIG_HOME"; echo "STARSHIP=$STARSHIP_CONFIG"; echo "MEM=$MEMORIES_DATA_DIR"; echo "PASS_OK=$([ -n "$OPENCODE_SERVER_PASSWORD" ] && echo yes || echo no)"'
```
Expected: `XDG=/Users/harrison/.config`, `STARSHIP=/Users/harrison/.config/starship/starship.toml`, `MEM=/Users/harrison/.config/opencode/memory/db`, `PASS_OK=yes`.

No git commit (pure filesystem move; git sees it as unchanged since `.git` moved with the tree — verify with `git status` in Step 3).

---

## Task 4: Update repo-tracked `.zshrc` and `.bashrc` (stale copies)

**Files:**
- Modify: `~/.config/.zshrc` (tracked)
- Modify: `~/.config/.bashrc` (tracked)

**Purpose:** Keep the tracked shell config copies consistent with the live file and with the new `.config` path. These are stale duplicates; we align their `.dotfiles` refs.

- [ ] **Step 1: Update tracked `.zshrc`**

In `~/.config/.zshrc` (tracked), replace all `$HOME/.dotfiles` → `$HOME/.config`:

```bash
cd ~/.config
sed -i '' 's|\$HOME/\.dotfiles|$HOME/.config|g' .zshrc
```

- [ ] **Step 2: Update tracked `.bashrc`**

In `~/.config/.bashrc` (tracked), replace:

```bash
cd ~/.config
sed -i '' 's|\$HOME/\.dotfiles|$HOME/.config|g' .bashrc
```

- [ ] **Step 3: Verify no `.dotfiles` refs remain in either tracked file**

Run:
```bash
cd ~/.config
grep -n '\.dotfiles' .zshrc .bashrc || echo "CLEAN: no .dotfiles in tracked shell configs"
```
Expected: `CLEAN: no .dotfiles in tracked shell configs`.

- [ ] **Step 4: Show the diff to confirm only path substitutions occurred**

Run: `cd ~/.config && git diff .zshrc .bashrc`
Expected: only `$HOME/.dotfiles` → `$HOME/.config` substitutions (and any whitespace the `sed -i ''` preserved). No content drift.

- [ ] **Step 5: Commit**

```bash
cd ~/.config
git add .zshrc .bashrc
git commit -m "refactor: point tracked shell configs at ~/.config"
```

---

## Task 5: Update blink.cmp snippet search path

**Files:**
- Modify: `~/.config/nvim/lua/jyrwa/plugins/blink.lua` (line 69)

**Purpose:** The blink.cmp `snippets.search_paths` hardcodes `~/.dotfiles/nvim`. After the move, `$XDG_CONFIG_HOME` is `~/.config` and Neovim config lives at `~/.config/nvim`, so the first search path (`vim.fn.stdpath("config") .. "/snippets"`) already resolves to `~/.config/nvim/snippets`. The second hardcoded path must change.

- [ ] **Step 1: Read the current line**

Run:
```bash
cd ~/.config && sed -n '65,72p' nvim/lua/jyrwa/plugins/blink.lua
```
Expected: shows the `snippets` provider block containing `vim.fn.fnamemodify("~/.dotfiles/nvim", ":p") .. "snippets",`.

- [ ] **Step 2: Replace the hardcoded path**

Edit `nvim/lua/jyrwa/plugins/blink.lua` line 69:

```bash
cd ~/.config
sed -i '' 's|~/.dotfiles/nvim|~/.config/nvim|' nvim/lua/jyrwa/plugins/blink.lua
```

- [ ] **Step 3: Verify the change and that the file is still valid Lua**

Run:
```bash
cd ~/.config
grep -n '\.dotfiles\|\.config/nvim' nvim/lua/jyrwa/plugins/blink.lua
luajit -e "loadfile('/Users/harrison/.config/nvim/lua/jyrwa/plugins/blink.lua')" && echo "blink.lua: VALID LUA"
```
Expected: `~/.config/nvim` present, no `.dotfiles`; `blink.lua: VALID LUA`.

- [ ] **Step 4: Verify the custom snippets still resolve (headless test)**

Run the snippet verification against the new path:
```bash
cd ~/.config && nvim --headless -u NONE -l /tmp/test_all.lua 2>&1 | tail -3
```
Expected: `RESULT: 20/20 passed, 0 failed`. (If `/tmp/test_all.lua` was removed, re-run the standard 20-snippet parse check from the earlier snippet work.)

- [ ] **Step 5: Commit**

```bash
cd ~/.config
git add nvim/lua/jyrwa/plugins/blink.lua
git commit -m "fix(nvim): point blink.cmp snippet search path at ~/.config"
```

---

## Task 6: Update opencode config, scripts, and memory files

**Files:**
- Modify: `~/.config/opencode/opencode.jsonc` (2 refs)
- Modify: `~/.config/opencode/scripts/memories-mcp.sh` (2 refs)
- Modify: `~/.config/opencode/memory/config.yaml` (1 ref)
- Modify: `~/.config/opencode/AGENTS.md` (3 refs)
- Modify: `~/.config/opencode/memory/instructions.md` (2 refs)

**Purpose:** opencode's permission allowlist, memories MCP data dir, and agent/memory docs all hardcode `.dotfiles`. Update them to `.config` so opencode functions after the move.

- [ ] **Step 1: Update `opencode.jsonc`**

Replace `~/.dotfiles` → `~/.config` in both the external_directory allowlist and the MEMORIES_DATA_DIR env:

```bash
cd ~/.config
sed -i '' 's|~/.dotfiles|~/.config|g' opencode/opencode.jsonc
# The absolute path variant:
sed -i '' 's|"/Users/harrison/.dotfiles|"/Users/harrison/.config|g' opencode/opencode.jsonc
```

- [ ] **Step 2: Update `memories-mcp.sh`**

```bash
cd ~/.config
sed -i '' 's|\$HOME/\.dotfiles|$HOME/.config|g' opencode/scripts/memories-mcp.sh
```

- [ ] **Step 3: Update `memory/config.yaml`**

```bash
cd ~/.config
sed -i '' 's|~/.dotfiles|~/.config|g' opencode/memory/config.yaml
```

- [ ] **Step 4: Update `AGENTS.md`**

```bash
cd ~/.config
sed -i '' 's|~/.dotfiles|~/.config|g' opencode/AGENTS.md
```

- [ ] **Step 5: Update `memory/instructions.md`**

```bash
cd ~/.config
sed -i '' 's|/Users/harrison/\.dotfiles|/Users/harrison/.config|g' opencode/memory/instructions.md
```

- [ ] **Step 6: Verify no `.dotfiles` refs remain in any opencode file (except historical docs)**

Run:
```bash
cd ~/.config
grep -rn '\.dotfiles' opencode/opencode.jsonc opencode/scripts/memories-mcp.sh opencode/memory/config.yaml opencode/AGENTS.md opencode/memory/instructions.md || echo "CLEAN: no .dotfiles in opencode config/scripts/memory"
```
Expected: `CLEAN` (historical plan docs under `opencode/docs/` are handled separately in Task 7 and will still show, which is fine).

- [ ] **Step 7: Validate JSONC still parses**

Run:
```bash
cd ~/.config
python3 -c "import json,re; s=open('opencode/opencode.jsonc').read(); s=re.sub(r'//.*','',s); json.loads(s); print('opencode.jsonc: VALID JSONC')"
```
Expected: `opencode.jsonc: VALID JSONC`.

- [ ] **Step 8: Commit**

```bash
cd ~/.config
git add opencode/opencode.jsonc opencode/scripts/memories-mcp.sh opencode/memory/config.yaml opencode/AGENTS.md opencode/memory/instructions.md
git commit -m "refactor(opencode): point opencode + memories at ~/.config"
```

---

## Task 7: Update docs, tests, and Readme references (consistency)

**Files:**
- Modify: `~/.config/nvim/tests/insert_mode_diagnostics_regression.lua` (1 ref)
- Modify: `~/.config/Readme.md` (4 refs)
- Modify: `~/.config/docs/superpowers/plans/2026-07-09-opencode-status-lualine.md` (5 refs)
- Modify (consistency, optional but recommended): `~/.config/opencode/docs/superpowers/plans/*.md`

**Purpose:** Remove the remaining `.dotfiles` references from tests, the Readme, and historical plan docs so the repo is internally consistent. These are cosmetic but keep the codebase grep-clean.

- [ ] **Step 1: Update the nvim test comment**

```bash
cd ~/.config
sed -i '' 's|~/.dotfiles/nvim|~/.config/nvim|g' nvim/tests/insert_mode_diagnostics_regression.lua
```

- [ ] **Step 2: Update the Readme (Windows symlink docs)**

```bash
cd ~/.config
sed -i '' 's|\.dotfiles|\.config|g' Readme.md
```

- [ ] **Step 3: Update the recent plan doc**

```bash
cd ~/.config
sed -i '' 's|\.dotfiles|\.config|g' docs/superpowers/plans/2026-07-09-opencode-status-lualine.md
```

- [ ] **Step 4: Update the historical opencode plan docs**

```bash
cd ~/.config
sed -i '' 's|\.dotfiles|\.config|g' opencode/docs/superpowers/plans/2026-06-30-opencode-config-complete.md
sed -i '' 's|\.dotfiles|\.config|g' opencode/docs/superpowers/plans/2026-07-01-add-models-config.md
```

- [ ] **Step 5: Verify zero remaining `.dotfiles` refs in tracked files**

Run:
```bash
cd ~/.config && git grep -n -I '\.dotfiles' || echo "ZERO .dotfiles refs remain in repo"
```
Expected: `ZERO .dotfiles refs remain in repo` (or an empty grep). This is the definitive "rename complete" check for repo content.

- [ ] **Step 6: Commit**

```bash
cd ~/.config
git add nvim/tests/insert_mode_diagnostics_regression.lua Readme.md docs/superpowers/plans/2026-07-09-opencode-status-lualine.md opencode/docs/superpowers/plans/2026-06-30-opencode-config-complete.md opencode/docs/superpowers/plans/2026-07-01-add-models-config.md
git commit -m "docs: update remaining .dotfiles references to .config"
```

---

## Task 8: Final end-to-end verification

**Files:** (none modified)

**Purpose:** Prove the rename is complete and nothing is broken before merging/pushing. This is the verification gate (see `verification-before-completion`).

- [ ] **Step 1: Repo grep is clean**

Run:
```bash
cd ~/.config && git grep -n -I '\.dotfiles' ; echo "exit=$?"
```
Expected: no output, or exit non-zero meaning zero matches.

- [ ] **Step 2: Working tree clean & branch correct**

Run:
```bash
cd ~/.config
git status --short
git branch --show-current
```
Expected: empty (clean) + `feat/rename-dotfiles-to-config`.

- [ ] **Step 3: Live shell loads with `.config` and secrets present**

Run:
```bash
zsh -lic 'echo "XDG=$XDG_CONFIG_HOME"; echo "STARSHIP=$STARSHIP_CONFIG"; echo "MEM=$MEMORIES_DATA_DIR"; echo "PASS_OK=$([ -n "$OPENCODE_SERVER_PASSWORD" ] && echo yes || echo no)"; echo "KEY_OK=$([ -n "$STITCH_API_KEY" ] && echo yes || echo no)"'
```
Expected: `XDG=/Users/harrison/.config`, `STARSHIP=/Users/harrison/.config/starship/starship.toml`, `MEM=/Users/harrison/.config/opencode/memory/db`, `PASS_OK=yes`, `KEY_OK=yes`.

- [ ] **Step 4: Neovim starts and snippet search path resolves**

Run (headless config load):
```bash
cd ~/.config/nvim && ls snippets
```
Expected: `hooks.json package.json react-native.json react.json` present at `~/.config/nvim/snippets`.

- [ ] **Step 5: Confirm `.env.local` is ignored and untracked**

Run:
```bash
cd ~/.config && git status --short .env.local ; git check-ignore .env.local
```
Expected: check-ignore prints `.env.local`; status shows it as ignored (not listed). **Critical:** confirm `.env.local` is NOT in `git ls-files`:
```bash
git ls-files | grep -c '\.env.local'   # must print 0
```

- [ ] **Step 6: Confirm secrets are not in git (double safety)**

Run:
```bash
cd ~/.config && git log --all -S '<REDACTED>' --oneline | wc -l  # expect 0
cd ~/.config && git log --all -S '<REDACTED>' --oneline | wc -l                        # expect 0
```
Expected: both print `0`.

---

## Task 9: Merge to master and push to `.config` GitHub remote

**Files:** (git operations only)

**Purpose:** Land the completed rename on `master` and push to the already-renamed `JyrwaJR/.config` remote so the remote reflects the new path.

- [ ] **Step 1: Confirm verification passed (Task 8)**

If any Task 8 check failed, stop and debug — do NOT merge/push. Only proceed when all green.

- [ ] **Step 2: Merge the feature branch to master**

Since local `master` is in sync with `origin/master` (verified 0/0):
```bash
cd ~/.config
git checkout master
git merge feat/rename-dotfiles-to-config
git branch -d feat/rename-dotfiles-to-config
```
Expected: clean merge (likely fast-forward); branch deleted.

- [ ] **Step 3: Push to the `.config` remote**

```bash
cd ~/.config
git push origin master
```
Expected: pushes the renamed refs to `https://github.com/JyrwaJR/.config.git`.

- [ ] **Step 4: Confirm remote is up to date**

Run:
```bash
cd ~/.config && git log --oneline origin/master -1
```
Expected: shows the last merge/push commit.

- [ ] **Step 5: Final full-tree grep on the pushed state**

Run:
```bash
cd ~/.config && git grep -n -I '\.dotfiles' || echo "ZERO .dotfiles in repo"
```
Expected: `ZERO .dotfiles in repo`.

---

## Rollback / Safety Notes

- **Everything except Task 3 (the `mv`) is reversible via git.** The repo-tracked changes can be reverted with `git checkout` on `feat/rename-dotfiles-to-config`.
- **The `mv ~/.dotfiles ~/.config` in Task 3 is the only destructive step.** To roll back: `mv ~/.config ~/.dotfiles` and revert `~/.zshrc` from the backup `~/.zshrc.backup-20260907` created in Task 0.
- **Secrets safety:** `.env.local` is gitignored (Task 1, Step 2) and verified absent from `git ls-files` and history (Task 8, Steps 5–6). If the real values ever leak, rotate `STITCH_API_KEY` and `OPENCODE_SERVER_PASSWORD` at their sources — do NOT rely on deletion alone.
- **Shell break risk:** Do not run a login shell expecting tools to fully work between Task 2 (live `~/.zshrc` now points at `.config`) and Task 3 (folder actually moved). The window is handled because we only smoke-test after the move in Task 3 Step 5.
- **Historical plan docs** (Task 7) are updated for tidiness. If you prefer to preserve history verbatim, skip Task 7's doc edits (Steps 3–4) — Task 8's "zero refs" grep would then expectedly not be zero for those files. Requirement is only that **live config + active code** are clean; historical plans are documentation.

---

## Self-Review Checklist

- **Spec coverage:** All `.dotfiles` references from the audit (13 files, 33 occurrences) are covered: live `.zshrc` (Task 1–2), tracked `.zshrc`/`.bashrc` (Task 4), blink.lua (Task 5), opencode.jsonc/scripts/config.yaml/AGENTS.md/instructions.md (Task 6), nvim test + Readme + plan docs (Task 7). The folder move is Task 3. Full verification Task 8. Commit/push Task 9.
- **Placeholder scan:** No TBD/TODO; every step has concrete sed commands / verification commands / expected output.
- **Type consistency:** Path tokens consistently `~/.dotfiles` → `~/.config` and `/Users/harrison/.dotfiles` → `/Users/harrison/.config`. The `$XDG_CONFIG_HOME` self-healing is explicitly called out so steps don't double-edit.
