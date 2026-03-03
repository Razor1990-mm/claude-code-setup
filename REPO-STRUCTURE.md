# Recommended Repo Structure

How to organize your project for AI-assisted development. This structure works across agents — the wiring guides show how to map it to each tool's conventions.

## The Layout

```
your-project/
├── agent.md                     # Main project instructions for your AI agent
│                                # (CLAUDE.md, AGENTS.md, .cursorrules — see wiring/)
│
├── rules/                       # Detailed rules (referenced from agent.md)
│   ├── workflow.md              # Dev workflow: spec → TDD → PR
│   ├── code-patterns.md         # ORM patterns, error handling, idempotency
│   ├── testing.md               # TDD rules, test categories, depth checklist
│   ├── security.md              # Auth, PII, logging, fail-closed
│   └── templates.md             # Template usage enforcement
│
├── specs/                       # Sprint specs (one per sprint/feature)
│   ├── sprint-01-auth.md
│   ├── sprint-02-billing.md
│   └── ...
│
├── templates/                   # Reusable templates
│   ├── sprint-spec.md           # Sprint planning template
│   └── work-order.md            # Agent delegation template
│
├── docs/                        # Project documentation
│   ├── start-here/              # Onboarding: vision, product context, backlog
│   ├── architecture/            # Architecture decisions, ontology, diagrams
│   ├── sprints/                 # Sprint history and status
│   └── runbooks/                # Operational procedures
│
├── src/                         # Application source (your actual code)
│   ├── domain/                  # Business logic (fat domain)
│   │   ├── __tests__/           # Domain unit tests
│   │   ├── users.ts
│   │   └── orders.ts
│   ├── routes/                  # HTTP handlers (thin controllers)
│   └── middleware/              # Auth, validation, rate limiting
│
└── hooks/                       # Git hooks (optional)
    ├── pre-commit               # Lint + typecheck + domain test check
    └── pre-push                 # Full test suite
```

## Why This Structure

### `agent.md` at the root
Every AI agent looks for instructions at the project root first. This is your "system prompt" for the codebase. Keep it concise — link to `rules/` for details.

### `rules/` separate from `agent.md`
Rules files are detailed reference material. Keeping them separate:
- Lets you scope rules to specific file patterns (testing rules only for test files)
- Keeps the main agent config readable
- Makes it easy to share rules across projects

### `specs/` for planning
Specs are the unit of planning. One spec per feature/sprint. The AI agent reads the spec before implementing — it's the implementation contract.

### `templates/` for consistency
Templates enforce structure on recurring artifacts (sprint specs, work orders). The AI agent reads these before creating new ones.

### `docs/` for humans and agents
Documentation serves double duty:
- **Humans**: onboarding, architecture decisions, operational procedures
- **Agents**: context for implementation (product vision, sprint history, domain model)

### `domain/` with colocated tests
Business logic lives in the domain layer. Tests live next to the code they test. This makes it easy for agents to find and update tests when modifying domain code.

## Scaling Patterns

### Solo dev
```
your-project/
├── agent.md          # All rules in one file
├── specs/            # 1-2 active specs
└── src/
```

### Small team (2-5 devs)
```
your-project/
├── agent.md          # Core instructions
├── rules/            # Detailed rules (split by concern)
├── specs/            # Active specs
├── templates/        # Sprint spec + work order
└── src/
```

### Multi-agent / parallel work
```
your-project/
├── agent.md          # Core instructions + parallel agent rules
├── rules/            # Full rule set
├── specs/            # Specs with slice ownership (agent assignments)
├── templates/        # Sprint spec + work order
├── docs/             # Full doc structure
└── src/
```

## Anti-Patterns

| Anti-Pattern | Why It Fails | Fix |
|--------------|-------------|-----|
| All rules in one giant file | Agent loses focus, rules conflict | Split into `rules/` by concern |
| No specs, just "build X" | Agent makes wrong assumptions, rework | Write a spec first, even a short one |
| Tests in a separate `tests/` tree | Agent can't find related tests | Colocate: `domain/__tests__/` |
| No `templates/` | Every sprint spec has different structure | Use templates for recurring artifacts |
| Rules that reference agent-specific features | Breaks when switching agents | Keep rules agent-agnostic, use `wiring/` |
| Docs scattered across wikis/Notion/Confluence | Agent can't read external tools | Keep docs in-repo as markdown |
