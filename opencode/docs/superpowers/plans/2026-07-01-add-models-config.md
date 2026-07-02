# Add New Models and Configure Planner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add new model configurations to `opencode.jsonc` and update the planning agent to use `antigravity-claude-opus-4-6-thinking`.

**Architecture:** Merge the provided model definitions under the `provider` key in `opencode.jsonc` and update the `agent.planner` configuration.

**Tech Stack:** `opencode` JSON configuration.

## Global Constraints

- Must maintain valid JSONC format (comments allowed).
- Must adhere to the `opencode.json` schema.

---

### Task 1: Update opencode.jsonc

**Files:**
- Modify: `/Users/harrison/.dotfiles/opencode/opencode.jsonc`

**Interfaces:**
- Produces: Updated `provider` and `agent.planner` configuration.

- [ ] **Step 1: Backup opencode.jsonc**

Run: `cp /Users/harrison/.dotfiles/opencode/opencode.jsonc /Users/harrison/.dotfiles/opencode/opencode.jsonc.bak`

- [ ] **Step 2: Update configuration**

Edit `/Users/harrison/.dotfiles/opencode/opencode.jsonc` to merge the new `provider` configuration and update the `planner` agent model.

```jsonc
// ... add provider section ...
"provider": {
  "google": {
    "models": {
      "antigravity-gemini-3-pro": { ... },
      // ... all models from user input ...
    }
  }
},
// ... update planner ...
"agent": {
  "planner": {
    "model": "antigravity-claude-opus-4-6-thinking",
    "steps": 30
  },
  // ... rest of agents ...
}
```

- [ ] **Step 3: Commit**

Run: `git add /Users/harrison/.dotfiles/opencode/opencode.jsonc && git commit -m "chore: add models and configure planner agent"`

### Task 2: Verify Configuration

**Files:**
- N/A

- [ ] **Step 1: Restart opencode**

Remind user: "Changes will take effect after restarting opencode."
