# Installation Guide

## Quick Start (Automated)

```bash
bash <(curl -s https://raw.githubusercontent.com/Razor1990-mm/claude-code-setup/main/setup.sh)
```

The setup script detects your project type, asks 2-3 questions, and generates the right directory structure.

---

## Manual Installation

### Step 1: Global Preferences

Copy `global-preferences.md` content into your agent's global config:

| Agent | Global Config Location |
|-------|----------------------|
| Claude Code | `~/.claude/CLAUDE.md` |
| Codex | Not applicable (project-level only) |
| Cursor | Settings > Rules for AI (global) |
| Windsurf | `~/.windsurf/rules` |

### Step 2: Project Rules

Copy rules into your project. See `wiring/` for agent-specific instructions:

- `wiring/claude-code.md` — Claude Code setup
- `wiring/codex.md` — OpenAI Codex setup
- `wiring/cursor.md` — Cursor setup
- `wiring/windsurf.md` — Windsurf setup

### Step 3: Customize

Search all copied files for `<!-- CUSTOMIZE -->` markers and fill in your project's details:

```bash
grep -r "CUSTOMIZE" . --include="*.md"
```

Typical customizations:
- Project name and description
- Directory structure
- Tech stack (language, framework, ORM, hosting)
- Authentication methods per endpoint type
- Middleware ordering
- Environment variables
- Test commands
- Branch naming conventions
- Multi-tenancy field name (orgId, tenantId, etc.)
- Auto-fix allowlist for PR workflow

### Step 4: Templates

Copy `templates/` into your project for structured planning:

- `sprint-spec.md` — Sprint planning with hard-capped sections
- `work-order.md` — Bounded work delegation for multi-agent workflows

### Step 5: Hooks & Automation (Optional)

Copy `hooks/` and `settings.json` for automated quality gates:

- `hooks/block-checkout-main.sh` — Prevents switching to main from feature branches (PreToolUse)
- `hooks/check-domain-tenancy.sh` — Post-edit tenancy check on domain files (PostToolUse)
- `settings.json` — Hook wiring config for Claude Code

See `SETTINGS-GUIDE.md` for how hooks work, matchers, exit codes, and env vars.

### Step 6: Agents (Optional — Multi-Agent)

Copy `agents/` for multi-agent delegation:

- `agents/cto.md` — CTO orchestrator (opus)
- `agents/backend-lead.md` — Backend specialist (opus)
- `agents/frontend-lead.md` — Frontend specialist (sonnet)
- `agents/qa-eng.md` — QA engineer (sonnet)
- `agents/security-eng.md` — Security engineer (opus)
- `agents/devops-eng.md` — DevOps engineer (sonnet)

### Step 7: Memory (Optional — Cross-Session Context)

Copy `memory/` for persistent cross-session context:

- `memory/MEMORY.md` — Index file (loaded into context automatically)
- Memory files with frontmatter (user, feedback, project, reference types)

See `memory/README.md` for the full memory system docs.

### Step 8: Codex Commands (Optional — Dual-Model Review)

Copy the `codex-*.md` workflows for dual-model adversarial review:

- `workflows/codex-cto.md` — Plan review + implementation review
- `workflows/codex-code-review.md` — Production-readiness review
- `workflows/codex-pr-review.md` — Strategic 8-dimension PR review
- `workflows/codex-cto-parallel.md` — Parallel review across specs

Requires the [Codex CLI](https://github.com/openai/codex) to be installed.

## What to Skip

Not every rule applies to every project:

| Rule File | Skip If... |
|-----------|-----------|
| `code-patterns.md` | No ORM, no multi-tenancy, simple CRUD app |
| `security.md` | Internal tool with no auth requirements |
| `testing.md` | Prototype / spike (add back before production) |
| `templates.md` | Solo dev, no sprint planning needed |
| `workflow.md` | You prefer a different dev workflow |
| `agents/` | Solo dev, no multi-agent delegation |
| `hooks/` | Don't want automated quality gates |
| `memory/` | Don't need cross-session context |
| `codex-*.md` | Not using Codex CLI for dual-model review |

Start with `rules/project.md` + `global-preferences.md`. Add others as your project matures.
