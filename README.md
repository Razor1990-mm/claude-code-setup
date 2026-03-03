# AI Dev Setup

Battle-tested rules, templates, and workflow patterns for AI-assisted development. Agent-agnostic — works with Claude Code, Cursor, Codex, Windsurf, or any AI coding agent.

## What's Inside

```
ai-dev-setup/
├── README.md                  # You are here
├── INSTALL.md                 # Per-agent wiring instructions
├── global-preferences.md      # Personal working style (your global agent config)
├── rules/
│   ├── project.md             # Main project instructions template
│   ├── workflow.md            # Spec-driven dev, TDD, PR review flow
│   ├── code-patterns.md       # Idempotency, multi-tenancy, error handling
│   ├── testing.md             # TDD rules, test categories, depth checklist
│   ├── security.md            # Auth patterns, PII, logging, fail-closed
│   └── templates.md           # Template usage enforcement
├── templates/
│   ├── sprint-spec.md         # Sprint planning template (hard-capped sections)
│   └── work-order.md          # Agent delegation template (bounded scope)
└── wiring/
    ├── claude-code.md         # Setup for Claude Code (.claude/ structure)
    ├── codex.md               # Setup for OpenAI Codex (AGENTS.md)
    ├── cursor.md              # Setup for Cursor (.cursor/rules/)
    └── windsurf.md            # Setup for Windsurf (.windsurfrules)
```

## Philosophy

These rules encode a specific development philosophy:

- **Spec-driven**: Plan before code. Write specs, validate them, then implement.
- **TDD by default**: Tests first for all non-trivial changes.
- **Sacred tests**: Never modify existing tests to make code pass. If tests break, the code is wrong.
- **Ship complete**: Build it now or cut scope explicitly. Never defer to "future work."
- **Fail-closed**: Missing auth = error, not silent bypass. Least privilege always.
- **Proof required**: Claims about correctness must be backed by tests, logs, or reproducible checks.
- **Append-only audit**: Event and audit log tables are immutable. Never UPDATE or DELETE.

## Quick Start

1. Read `INSTALL.md` for your specific agent
2. Copy `global-preferences.md` into your agent's global config location
3. Copy `rules/project.md` into your project and fill in the `<!-- CUSTOMIZE -->` sections
4. Copy additional `rules/` files as needed for your stack
5. Copy `templates/` into your project for sprint planning and delegation

## Customization

Files with `<!-- CUSTOMIZE -->` markers have sections you need to fill in for your specific project. Search for these markers and replace with your project's details.

Rules without customize markers are stack-agnostic and can be used as-is.

## Origin

Extracted from a production AI agent orchestration platform. Every rule exists because something went wrong without it.
