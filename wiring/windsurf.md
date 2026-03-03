# Wiring Guide: Windsurf

How to set up this rule system for [Windsurf](https://windsurf.com).

## Global Preferences

Windsurf supports global rules. Paste `global-preferences.md` content into your global rules config.

## Project Structure

Windsurf uses `.windsurfrules` at the project root:

```
your-project/
├── .windsurfrules               # ← All rules concatenated into one file
├── specs/
│   └── sprint-01-title.md
└── templates/
    ├── sprint-spec.md
    └── work-order.md
```

## Setup Steps

1. Concatenate all rules into `.windsurfrules`:
   ```bash
   cat rules/project.md > .windsurfrules
   echo -e "\n\n---\n\n" >> .windsurfrules
   cat rules/workflow.md >> .windsurfrules
   echo -e "\n\n---\n\n" >> .windsurfrules
   cat rules/code-patterns.md >> .windsurfrules
   echo -e "\n\n---\n\n" >> .windsurfrules
   cat rules/testing.md >> .windsurfrules
   echo -e "\n\n---\n\n" >> .windsurfrules
   cat rules/security.md >> .windsurfrules
   ```

2. Copy templates:
   ```bash
   mkdir -p templates
   cp templates/sprint-spec.md templates/
   cp templates/work-order.md templates/
   ```

3. Search for `<!-- CUSTOMIZE -->` and fill in project details

## Key Differences from Claude Code

| Feature | Claude Code | Windsurf |
|---------|-------------|----------|
| Instruction file | `CLAUDE.md` + `.claude/rules/` | `.windsurfrules` (single file) |
| Scoped rules | Frontmatter `paths:` | Not supported — all rules are global |
| Custom commands | `.claude/commands/` | Not supported |
| Global config | `~/.claude/CLAUDE.md` | Global rules setting |

## Tips

- Windsurf reads one file, so keep the most critical rules at the top
- Use clear markdown headers — Windsurf navigates by heading structure
- Put project-specific instructions (structure, auth, stack) first
- Put detailed patterns (testing categories, code patterns) later
- The file can be long — Windsurf handles large rule files well
