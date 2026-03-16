# Memory System

A persistent, file-based memory system that helps your AI agent retain context across conversations.

## Why Memory?

Without memory, every conversation starts from zero. The agent re-asks the same questions, makes the same mistakes, and doesn't learn your preferences. Memory fixes this.

## Memory Types

| Type | What to Store | When to Save |
|------|--------------|-------------|
| **user** | Role, goals, preferences, knowledge level | When you learn about the user's background |
| **feedback** | Corrections, "don't do X", "always do Y" | Any time the user corrects your approach |
| **project** | Ongoing work, goals, deadlines, decisions | When you learn who's doing what, why, by when |
| **reference** | Pointers to external systems (Linear, Slack, Grafana) | When you learn about external resources |

## File Format

Each memory is a separate `.md` file with YAML frontmatter:

```markdown
---
name: descriptive-name
description: One-line description (used to decide relevance in future conversations)
type: user | feedback | project | reference
---

Memory content here.
```

## Index File (MEMORY.md)

`MEMORY.md` is the index — it contains only links to memory files with brief descriptions. Never write memory content directly into `MEMORY.md`.

```markdown
# Memory Index

## User
- [memory/user-role.md](memory/user-role.md) — Senior backend engineer, new to React

## Feedback
- [memory/feedback-no-mocks.md](memory/feedback-no-mocks.md) — Don't mock the database in tests
```

## What NOT to Save

- Code patterns (derivable from reading the code)
- Git history (use `git log` / `git blame`)
- Debugging solutions (the fix is in the code)
- Anything in CLAUDE.md files
- Temporary state or current conversation context

## Rules

1. **Check before writing** — Don't create duplicate memories. Update existing ones.
2. **Keep the index concise** — Lines after 200 will be truncated.
3. **Convert relative dates** — "Thursday" → "2026-03-05" so it stays interpretable.
4. **Organize by topic** — Not chronologically.
5. **Remove stale memories** — Delete or update when wrong/outdated.

## Setup

1. Create a `memory/` directory in your project
2. Create `MEMORY.md` at the memory directory root
3. Add memories as separate files as you work
4. Reference `MEMORY.md` in your project instructions so the agent loads it
