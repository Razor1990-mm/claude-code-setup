# Wiring Guide: OpenAI Codex

How to set up this rule system for [OpenAI Codex](https://openai.com/index/codex/).

## Project Structure

Codex uses `AGENTS.md` at the project root, plus optional `AGENTS.md` files in subdirectories for scoped instructions:

```
your-project/
├── AGENTS.md                    # ← Main project instructions (rules/project.md content)
├── src/
│   ├── AGENTS.md                # ← Optional: src-specific rules
│   └── domain/
│       └── AGENTS.md            # ← Optional: domain-specific rules
├── specs/
│   └── sprint-01-title.md
└── templates/
    ├── sprint-spec.md
    └── work-order.md
```

## Setup Steps

1. Copy `rules/project.md` → `your-project/AGENTS.md`
2. Append additional rule content to `AGENTS.md` or use subdirectory `AGENTS.md` files:

   **Option A — Single file (simpler):**
   Concatenate all rules into one `AGENTS.md`:
   ```bash
   cat rules/project.md > AGENTS.md
   echo -e "\n---\n" >> AGENTS.md
   cat rules/workflow.md >> AGENTS.md
   echo -e "\n---\n" >> AGENTS.md
   cat rules/code-patterns.md >> AGENTS.md
   echo -e "\n---\n" >> AGENTS.md
   cat rules/testing.md >> AGENTS.md
   echo -e "\n---\n" >> AGENTS.md
   cat rules/security.md >> AGENTS.md
   ```

   **Option B — Scoped files (more organized):**
   ```
   your-project/
   ├── AGENTS.md                  # rules/project.md (core instructions)
   ├── src/
   │   ├── AGENTS.md              # rules/code-patterns.md
   │   └── __tests__/
   │       └── AGENTS.md          # rules/testing.md
   └── src/routes/
       └── AGENTS.md              # rules/security.md
   ```

3. Copy templates:
   ```bash
   mkdir -p templates
   cp templates/sprint-spec.md templates/
   cp templates/work-order.md templates/
   ```

4. Search for `<!-- CUSTOMIZE -->` and fill in project details

## Key Differences from Claude Code

| Feature | Claude Code | Codex |
|---------|-------------|-------|
| Instruction file | `CLAUDE.md` + `.claude/rules/` | `AGENTS.md` (root + subdirs) |
| Scoped rules | Frontmatter `paths:` | Subdirectory `AGENTS.md` files |
| Custom commands | `.claude/commands/` | Not supported — describe workflows in AGENTS.md |
| Memory | Auto-memory directory | Not supported — use AGENTS.md for persistent context |
| Global config | `~/.claude/CLAUDE.md` | Not supported (project-level only) |

## Tips

- Codex works best with a single comprehensive `AGENTS.md` at the root
- Keep the most critical rules (project structure, core principles, security) at the top
- Use markdown headers liberally — Codex navigates by heading structure
- Subdirectory `AGENTS.md` files are additive — they don't override the root
