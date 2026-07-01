# opencode Config Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add every remaining `opencode.jsonc` config option that is not already present: identity fields, model config, instructions, formatter/LSP, compaction, tool_output, slash commands, experimental flags, and agent overrides.

**Architecture:** Incrementally insert new top-level keys into the existing `opencode/opencode.jsonc` between the `mcp` block and the root closing brace. Each task adds a logical group of related fields.

**Tech Stack:** opencode JSONC config, single file: `opencode/opencode.jsonc`

---

### Task 1: Add identity & behavior fields (username, logLevel, autoupdate, snapshot)

**Files:**
- Modify: `opencode/opencode.jsonc:119-121`

- [ ] **Read the current config file**

Run: `read file:///Users/harrison/.dotfiles/opencode/opencode.jsonc`
Expected: 121 lines, the file ending with:
```
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "."],
      "enabled": true
    }
  }
}
```

- [ ] **Add username, logLevel, autoupdate, snapshot**

Use the Edit tool with:

oldString:
```
    }
  }
}
```

newString:
```
    }
  },
  "username": "harrison",
  "logLevel": "INFO",
  "autoupdate": "notify",
  "snapshot": true
}
```

Expected result — the file now ends with:
```
    }
  },
  "username": "harrison",
  "logLevel": "INFO",
  "autoupdate": "notify",
  "snapshot": true
}
```

- [ ] **Verify the edit**

Run: `read file:///Users/harrison/.dotfiles/opencode/opencode.jsonc`
Expected: valid JSONC, file now has 126 lines, `"username"` appears at line ~121.

---

### Task 2: Add instructions loading, default_agent, model, small_model

**Files:**
- Modify: `opencode/opencode.jsonc` (after Task 1)

- [ ] **Add instructions and model fields**

Use the Edit tool with:

oldString:
```
  "snapshot": true
}
```

newString:
```
  "snapshot": true,
  "instructions": ["AGENTS.md"],
  "default_agent": "build",
  "model": "anthropic/claude-sonnet-4-6",
  "small_model": "anthropic/claude-haiku-3-5-20241022"
}
```

Expected result — the file now ends with:
```
  "snapshot": true,
  "instructions": ["AGENTS.md"],
  "default_agent": "build",
  "model": "anthropic/claude-sonnet-4-6",
  "small_model": "anthropic/claude-haiku-3-5-20241022"
}
```

- [ ] **Verify**

Run: `read file:///Users/harrison/.dotfiles/opencode/opencode.jsonc | tail -10`
Expected: the last 10 lines show `instructions`, `default_agent`, `model`, `small_model` fields before the closing `}`.

---

### Task 3: Add formatter and LSP

**Files:**
- Modify: `opencode/opencode.jsonc` (after Task 2)

- [ ] **Enable built-in formatter and LSP**

Use the Edit tool with:

oldString:
```
  "small_model": "anthropic/claude-haiku-3-5-20241022"
}
```

newString:
```
  "small_model": "anthropic/claude-haiku-3-5-20241022",
  "formatter": true,
  "lsp": true
}
```

Expected result — the file now ends with:
```
  "small_model": "anthropic/claude-haiku-3-5-20241022",
  "formatter": true,
  "lsp": true
}
```

- [ ] **Verify**

Run: `read file:///Users/harrison/.dotfiles/opencode/opencode.jsonc | tail -10`
Expected: shows `formatter: true` and `lsp: true` as last two fields before `}`.

---

### Task 4: Add compaction and tool_output

**Files:**
- Modify: `opencode/opencode.jsonc` (after Task 3)

- [ ] **Add context compaction and tool output thresholds**

Use the Edit tool with:

oldString:
```
  "lsp": true
}
```

newString:
```
  "lsp": true,
  "compaction": {
    "auto": true,
    "tail_turns": 15
  },
  "tool_output": {
    "max_lines": 2000,
    "max_bytes": 51200
  }
}
```

Expected result — the file now ends with:
```
  "lsp": true,
  "compaction": {
    "auto": true,
    "tail_turns": 15
  },
  "tool_output": {
    "max_lines": 2000,
    "max_bytes": 51200
  }
}
```

- [ ] **Verify**

Run: `read file:///Users/harrison/.dotfiles/opencode/opencode.jsonc | tail -15`
Expected: shows the `compaction` object and `tool_output` object before `}`.

---

### Task 5: Add slash commands (command block)

**Files:**
- Modify: `opencode/opencode.jsonc` (after Task 4)

- [ ] **Add custom slash commands: fix, review, deploy, plan**

Use the Edit tool with:

oldString:
```
  "tool_output": {
    "max_lines": 2000,
    "max_bytes": 51200
  }
}
```

newString:
```
  "tool_output": {
    "max_lines": 2000,
    "max_bytes": 51200
  },
  "command": {
    "fix": {
      "description": "Fix code issues found during review or build",
      "template": "Fix the issues found in the current codebase. Read any review findings, lint errors, or test failures, then implement fixes."
    },
    "review": {
      "description": "Request a code review of current changes",
      "template": "Review all uncommitted changes in the working tree for quality, correctness, and security issues."
    },
    "deploy": {
      "description": "Deploy the current branch",
      "template": "Deploy the current branch to production following the project's deployment process."
    },
    "plan": {
      "description": "Create an implementation plan",
      "template": "Create a detailed implementation plan for the requested feature or change."
    }
  }
}
```

Expected result — the file now ends with the `command` block before `}`:
```
  "tool_output": { ... },
  "command": {
    "fix": { ... },
    "review": { ... },
    "deploy": { ... },
    "plan": { ... }
  }
}
```

- [ ] **Verify**

Run: `read file:///Users/harrison/.dotfiles/opencode/opencode.jsonc | tail -25`
Expected: shows `command` block with `fix`, `review`, `deploy`, `plan` entries.

---

### Task 6: Add experimental flags

**Files:**
- Modify: `opencode/opencode.jsonc` (after Task 5)

- [ ] **Add experimental.mcp_timeout**

Use the Edit tool with:

oldString:
```
  "command": {
    "fix": {
      "description": "Fix code issues found during review or build",
      "template": "Fix the issues found in the current codebase. Read any review findings, lint errors, or test failures, then implement fixes."
    },
    "review": {
      "description": "Request a code review of current changes",
      "template": "Review all uncommitted changes in the working tree for quality, correctness, and security issues."
    },
    "deploy": {
      "description": "Deploy the current branch",
      "template": "Deploy the current branch to production following the project's deployment process."
    },
    "plan": {
      "description": "Create an implementation plan",
      "template": "Create a detailed implementation plan for the requested feature or change."
    }
  }
}
```

newString:
```
  "command": {
    "fix": {
      "description": "Fix code issues found during review or build",
      "template": "Fix the issues found in the current codebase. Read any review findings, lint errors, or test failures, then implement fixes."
    },
    "review": {
      "description": "Request a code review of current changes",
      "template": "Review all uncommitted changes in the working tree for quality, correctness, and security issues."
    },
    "deploy": {
      "description": "Deploy the current branch",
      "template": "Deploy the current branch to production following the project's deployment process."
    },
    "plan": {
      "description": "Create an implementation plan",
      "template": "Create a detailed implementation plan for the requested feature or change."
    }
  },
  "experimental": {
    "mcp_timeout": 30000
  }
}
```

Expected result — the file now ends with the `experimental` block before `}`:
```
  "command": { ... },
  "experimental": {
    "mcp_timeout": 30000
  }
}
```

- [ ] **Verify**

Run: `read file:///Users/harrison/.dotfiles/opencode/opencode.jsonc | tail -10`
Expected: shows `experimental` with `mcp_timeout: 30000`.

---

### Task 7: Add agent overrides (agent block)

**Files:**
- Modify: `opencode/opencode.jsonc` (after Task 6)

- [ ] **Register existing agents with model and steps overrides**

Use the Edit tool with:

oldString:
```
  "experimental": {
    "mcp_timeout": 30000
  }
}
```

newString:
```
  "experimental": {
    "mcp_timeout": 30000
  },
  "agent": {
    "brainstormer": {
      "model": "anthropic/claude-sonnet-4-6",
      "steps": 50
    },
    "planner": {
      "model": "anthropic/claude-sonnet-4-6",
      "steps": 30
    },
    "build": {
      "model": "anthropic/claude-sonnet-4-6",
      "steps": 100
    },
    "review": {
      "model": "anthropic/claude-sonnet-4-6",
      "steps": 30
    }
  }
}
```

Expected result — the file now ends with:
```
  "experimental": { ... },
  "agent": {
    "brainstormer": { "model": "...", "steps": 50 },
    "planner": { "model": "...", "steps": 30 },
    "build": { "model": "...", "steps": 100 },
    "review": { "model": "...", "steps": 30 }
  }
}
```

- [ ] **Verify**

Run: `read file:///Users/harrison/.dotfiles/opencode/opencode.jsonc | tail -25`
Expected: shows `agent` block with all four agent entries.

---

### Task 8: Validate the final config

- [ ] **Inspect the complete file**

Run: `read file:///Users/harrison/.dotfiles/opencode/opencode.jsonc`
Expected: The file should show all fields in this order:

```
$schema
permission
skills
plugin
mcp
username
logLevel
autoupdate
snapshot
instructions
default_agent
model
small_model
formatter
lsp
compaction
tool_output
command
experimental
agent
```

- [ ] **Verify JSONC validity**

Run: `python3 -c "import json; json.loads(open('/Users/harrison/.dotfiles/opencode/opencode.jsonc').read())" 2>&1 || echo "JSONC may have trailing commas or comments - try with commentjson instead"`
If that fails, try:
Run: `pip3 install commentjson -q && python3 -c "import commentjson; commentjson.load(open('/Users/harrison/.dotfiles/opencode/opencode.jsonc')); print('VALID JSONC')"`
Expected: `VALID JSONC`

- [ ] **(Optional) Start opencode to test config loading**

Run: `opencode --version`
Expected: exits successfully (config was valid enough for startup).

- [ ] **If config is invalid, fix errors**

If opencode fails to start with `ConfigInvalidError`, check the error message, identify the offending field, and correct it. Common issues:
- Wrong model ID format (must be `provider/model-id`)
- Typo in field name
- Wrong type for a field (e.g., string instead of array)

Use `OPENCODE_DISABLE_PROJECT_CONFIG=1` to start opencode if the broken config prevents startup, then fix the file and restart without the flag.

---

### Task 9: Commit

- [ ] **Stage and commit**

Run:
```bash
git add opencode/opencode.jsonc
git commit -m "chore: add all remaining opencode config options

Adds the following previously unset config keys:
- username, logLevel, autoupdate, snapshot (identity/behavior)
- instructions, default_agent, model, small_model (session setup)
- formatter, lsp (built-in tools)
- compaction, tool_output (context management)
- command (custom slash commands: fix, review, deploy, plan)
- experimental (mcp_timeout)
- agent (per-agent model and steps overrides)"
```

Expected: commit succeeds with message.

- [ ] **Verify commit**

Run: `git log --oneline -3`
Expected: the latest commit has the message above.

---

### Reminder

After the config is updated, tell the user to **quit and restart opencode** for config changes to take effect. Config is loaded once at startup and is not hot-reloaded.
