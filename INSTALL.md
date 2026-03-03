# Installation Guide

## Step 1: Global Preferences

Copy `global-preferences.md` content into your agent's global config:

| Agent | Global Config Location |
|-------|----------------------|
| Claude Code | `~/.claude/CLAUDE.md` |
| Codex | Not applicable (project-level only) |
| Cursor | Settings > Rules for AI (global) |
| Windsurf | `~/.windsurf/rules` |

## Step 2: Project Rules

Copy rules into your project. See `wiring/` for agent-specific instructions:

- `wiring/claude-code.md` — Claude Code setup
- `wiring/codex.md` — OpenAI Codex setup
- `wiring/cursor.md` — Cursor setup
- `wiring/windsurf.md` — Windsurf setup

## Step 3: Customize

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

## Step 4: Templates

Copy `templates/` into your project for structured planning:

- `sprint-spec.md` — Sprint planning with hard-capped sections
- `work-order.md` — Bounded work delegation for multi-agent workflows

## What to Skip

Not every rule applies to every project:

| Rule File | Skip If... |
|-----------|-----------|
| `code-patterns.md` | You don't use an ORM, don't have multi-tenancy, or have a simple CRUD app |
| `security.md` | Internal tool with no auth requirements |
| `testing.md` | Prototype / spike (but add it back before production) |
| `templates.md` | Solo dev, no sprint planning needed |
| `workflow.md` | You prefer a different dev workflow |

Start with `rules/project.md` + `global-preferences.md`. Add others as your project matures.
