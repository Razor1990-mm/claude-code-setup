# Wiring Guide: Claude Code

How to set up this rule system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Global Preferences

Copy `global-preferences.md` content into:
```
~/.claude/CLAUDE.md
```

## Project Structure

Claude Code uses a `.claude/` directory at the project root:

```
your-project/
├── CLAUDE.md                    # ← rules/project.md content goes here
├── .claude/
│   └── rules/
│       ├── workflow.md          # ← rules/workflow.md
│       ├── code-patterns.md    # ← rules/code-patterns.md
│       ├── testing.md          # ← rules/testing.md
│       ├── security.md         # ← rules/security.md
│       └── templates.md        # ← rules/templates.md
├── specs/                       # Sprint specs go here
│   └── sprint-01-title.md
└── templates/                   # Or .claude/templates/
    ├── sprint-spec.md
    └── work-order.md
```

## Setup Steps

1. Copy `rules/project.md` → `your-project/CLAUDE.md`
2. Create `.claude/rules/` and copy the rule files:
   ```bash
   mkdir -p .claude/rules
   cp rules/workflow.md .claude/rules/
   cp rules/code-patterns.md .claude/rules/
   cp rules/testing.md .claude/rules/
   cp rules/security.md .claude/rules/
   cp rules/templates.md .claude/rules/
   ```
3. Copy templates:
   ```bash
   mkdir -p templates
   cp templates/sprint-spec.md templates/
   cp templates/work-order.md templates/
   ```
4. Search for `<!-- CUSTOMIZE -->` and fill in project details

## Rules File Scoping

Claude Code rule files support frontmatter to scope rules to specific file patterns:

```yaml
---
paths:
  - "**/__tests__/**"
  - "**/*.test.ts"
---
```

Add this to `testing.md` so testing rules only activate when editing test files.
Add path scoping to `security.md` for route/middleware files.

## Skills (Commands)

Claude Code supports custom commands in `.claude/commands/`. The workflows described in `rules/workflow.md` (spec-driven dev, TDD, PR review) can be implemented as commands. See the Claude Code docs for creating custom commands.

## Memory

Claude Code has auto-memory at `~/.claude/projects/<project>/memory/MEMORY.md`. Use it for project-specific patterns learned across sessions.
