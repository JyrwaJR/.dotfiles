# Commands Reference

<!-- Generated: 2026-06-27 | Files scanned: 29 | Token estimate: ~500 -->

## Command Categories

### PRP Workflow (5)
| Command | Description |
|---------|-------------|
| `prp-plan` | Deep codebase analysis → implementation plan artifact |
| `prp-implement` | Execute plan step-by-step with validation loops |
| `prp-commit` | Commit with descriptive message |
| `prp-pr` | Create pull request |
| `prp-prd` | Create product requirements document |

### Multi-Model Collaboration (5)
| Command | Description |
|---------|-------------|
| `multi-plan` | Codex (backend) + Gemini (frontend) collaborative planning |
| `multi-execute` | Distributed implementation across models |
| `multi-backend` | Backend-focused Codex delegation |
| `multi-frontend` | Frontend-focused Gemini delegation |
| `multi-workflow` | Full 6-phase: Research → Ideation → Plan → Execute → Optimize → Review |

### Feature Development (4)
| Command | Description |
|---------|-------------|
| `feature-dev` | 7-phase: Discovery → Exploration → Design → Implementation → Review |
| `build-fix` | Build error diagnosis and fix |
| `refactor-clean` | Code refactoring workflow |
| `evolve` | Cluster instincts into skills/agents |

### Code Review (2)
| Command | Description |
|---------|-------------|
| `code-review` | Implementation review gate |
| `review-pr` | Pull request review |

### Planning & Management (4)
| Command | Description |
|---------|-------------|
| `plan` | Structured implementation planning |
| `projects` | List project registry entries |
| `checkpoint` | Create/verify/list workflow checkpoints |
| `prune` | Clean up stale state |

### Design (1)
| Command | Description |
|---------|-------------|
| `gan-design` | GAN-related design workflow |

### Routing (1)
| Command | Description |
|---------|-------------|
| `model-route` | Recommend best model tier (haiku/sonnet/opus) |

### Documentation (2)
| Command | Description |
|---------|-------------|
| `update-codemaps` | Generate token-lean architecture docs |
| `update-docs` | Update project documentation |

### Utilities (3)
| Command | Description |
|---------|-------------|
| `skill-create` | Extract patterns from git history → SKILL.md |
| `instinct-export` / `instinct-import` / `instinct-status` | Continuous learning v2 |
| `gradle-build` | Gradle build support |

## Command Conventions

- YAML frontmatter: `description` field
- `$ARGUMENTS` placeholder for user input
- Follow AGENTS.md security protocols
