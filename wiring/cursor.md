# Wiring Guide: Cursor

How to set up this rule system for [Cursor](https://cursor.com).

## Global Preferences

Go to **Cursor Settings > Rules for AI** and paste the content of `global-preferences.md`.

## Project Structure

Cursor uses `.cursor/rules/` for project-level rules (previously `.cursorrules`):

```
your-project/
├── .cursor/
│   └── rules/
│       ├── project.mdc          # ← rules/project.md content
│       ├── workflow.mdc         # ← rules/workflow.md
│       ├── code-patterns.mdc   # ← rules/code-patterns.md
│       ├── testing.mdc         # ← rules/testing.md
│       ├── security.mdc        # ← rules/security.md
│       └── templates.mdc       # ← rules/templates.md
├── specs/
│   └── sprint-01-title.md
└── templates/
    ├── sprint-spec.md
    └── work-order.md
```

## Setup Steps

1. Create `.cursor/rules/` directory:
   ```bash
   mkdir -p .cursor/rules
   ```

2. Copy rule files with `.mdc` extension (Cursor's rule format):
   ```bash
   cp rules/project.md .cursor/rules/project.mdc
   cp rules/workflow.md .cursor/rules/workflow.mdc
   cp rules/code-patterns.md .cursor/rules/code-patterns.mdc
   cp rules/testing.md .cursor/rules/testing.mdc
   cp rules/security.md .cursor/rules/security.mdc
   cp rules/templates.md .cursor/rules/templates.mdc
   ```

3. Copy templates:
   ```bash
   mkdir -p templates
   cp templates/sprint-spec.md templates/
   cp templates/work-order.md templates/
   ```

4. Search for `<!-- CUSTOMIZE -->` and fill in project details

## Rule Scoping with Frontmatter

Cursor `.mdc` files support frontmatter for file-pattern scoping:

```yaml
---
description: Testing rules for test files
globs:
  - "**/__tests__/**"
  - "**/*.test.ts"
  - "**/*.spec.ts"
alwaysApply: false
---
```

Add this to:
- `testing.mdc` — scope to test files
- `security.mdc` — scope to route/middleware files
- `project.mdc` — set `alwaysApply: true` (core rules always active)

## Key Differences from Claude Code

| Feature | Claude Code | Cursor |
|---------|-------------|--------|
| Instruction file | `CLAUDE.md` | `.cursor/rules/*.mdc` |
| Rule format | Markdown + YAML frontmatter | `.mdc` (markdown) + YAML frontmatter |
| Scoped rules | `paths:` in frontmatter | `globs:` in frontmatter |
| Custom commands | `.claude/commands/` | Not directly — use @-mentions or rules |
| Global config | `~/.claude/CLAUDE.md` | Settings > Rules for AI |

## Tips

- Use `alwaysApply: true` for project.mdc (core rules)
- Use `alwaysApply: false` + `globs` for context-specific rules
- Cursor reads all `.mdc` files — no need to reference them from a central file
- The `description` field helps Cursor decide when to apply rules automatically
