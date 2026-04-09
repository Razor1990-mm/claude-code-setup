# AI Dev Setup

Battle-tested rules, templates, and workflow patterns for AI-assisted development. Agent-agnostic — works with Claude Code, Cursor, Codex, Windsurf, or any AI coding agent.

## What's Inside

```
ai-dev-setup/
├── README.md                  # You are here
├── GETTING-STARTED.md         # Beginner guide (VS Code, logins, first commands)
├── INSTALL.md                 # Per-agent wiring instructions
├── PLAYBOOK.md                # Step-by-step: which workflow to run at each stage
├── PROCESS-LESSONS.md         # Distilled hard-won workflow rules from real production sprints
├── REPO-STRUCTURE.md          # Recommended project layout for AI-assisted dev
├── global-preferences.md      # Personal working style (your global agent config)
├── rules/
│   ├── project.md             # Main project instructions template
│   ├── workflow.md            # Spec-driven dev, TDD, PR review flow
│   ├── code-patterns.md       # Idempotency, CAS, multi-tenancy, composite FKs
│   ├── testing.md             # TDD rules, A-H categories, depth checklist, INV mapping
│   ├── test-cleanup.md        # FK-safe delete ordering, SET NULL risks, blast radius
│   ├── security.md            # Auth patterns, PII, logging, fail-closed
│   └── templates.md           # Template usage enforcement
├── workflows/                 # 28 structured workflow prompts
│   ├── README.md              # Catalog of all workflows
│   ├── spec.md                # Write specs with interview process + external research
│   ├── tdd-workflow.md        # TDD RED phase (tests first, .tdd-red-phase marker)
│   ├── review.md              # Code review (completeness + adversarial + AI-smell)
│   ├── pr.md                  # Automated review-fix loop (triple review)
│   ├── grill.md               # Adversarial "break the code" review
│   ├── audit.md               # Multi-dimensional code audit (branch changes)
│   ├── audit-full.md          # Full codebase audit (4 parallel sub-audits)
│   ├── security.md            # Security-focused OWASP checklist
│   ├── staff-review.md        # Senior engineer plan review (auto-triggers)
│   ├── sprint-cohesion.md     # Cross-spec wiring review (after all specs written)
│   ├── sprint-closeout.md     # Sprint merge readiness gate (7 phases)
│   ├── commit.md              # Structured commits
│   ├── fix.md                 # Autonomous bug fixing
│   ├── backlog.md             # Agent-ready backlog items
│   ├── test-gen.md            # Test plan generation
│   ├── explain.md             # Code/PR/sprint explanations (3 modes)
│   ├── mock.md                # Research-driven UI mock process
│   ├── council.md             # LLM Council — 5-advisor debate for high-stakes decisions
│   ├── check-taste.md         # Frontend taste / voice-spec validator
│   ├── ingest-review.md       # Parse review findings (IDs, classification)
│   ├── check-tenancy.md       # Multi-tenancy validator (+ schema blast radius)
│   ├── check-consistency.md   # String constant drift checker
│   ├── codex-cto.md           # Codex CTO advisor (plan + implementation review)
│   ├── codex-code-review.md   # Codex production-readiness review
│   ├── codex-pr-review.md     # Codex strategic 8-dimension PR review
│   ├── codex-cto-parallel.md  # Parallel Codex CTO review across specs
│   ├── codex-spec-review.md   # Mid-spec thought partner (challenges spec vs code)
│   ├── codex-sprint-cohesion.md # Independent second opinion on cross-spec wiring
│   └── codex-audit-runtime-prompt.md # Runtime audit prompt for deployed systems
├── agents/                    # Multi-agent org chart and specialist definitions
│   ├── README.md              # Org chart, model rationale, phase flow
│   ├── cto.md                 # CTO orchestrator (opus)
│   ├── backend-lead.md        # Backend specialist (opus)
│   ├── frontend-lead.md       # Frontend specialist (sonnet)
│   ├── qa-eng.md              # QA engineer (sonnet) — blocking power
│   ├── security-eng.md        # Security engineer (opus) — P0 blocking
│   └── devops-eng.md          # DevOps engineer (sonnet)
├── hooks/                     # Git/tool hooks for automation
│   ├── block-checkout-main.sh # Prevents switching to main from feature branches
│   └── check-domain-tenancy.sh# Post-edit tenancy check on domain files
├── settings.json              # Hook wiring config (PreToolUse/PostToolUse)
├── SETTINGS-GUIDE.md          # Explains hooks, matchers, exit codes, env vars
├── memory/                    # Persistent memory system
│   ├── README.md              # Memory types, format, rules
│   ├── MEMORY.md              # Template index
│   ├── example-user.md        # Example user memory
│   └── example-feedback.md    # Example feedback memory
├── templates/
│   ├── sprint-spec.md         # Sprint planning template (hard-capped sections)
│   └── work-order.md          # Agent delegation template (bounded scope)
└── wiring/
    ├── claude-code.md         # Setup for Claude Code (.claude/ structure)
    ├── codex.md               # Setup for OpenAI Codex (AGENTS.md)
    ├── cursor.md              # Setup for Cursor (.cursor/rules/)
    └── windsurf.md            # Setup for Windsurf (.windsurfrules)
```

## New Here?

**Start with [`GETTING-STARTED.md`](GETTING-STARTED.md)** — walks you through installing VS Code, setting up Claude Code / Cursor / Codex, running the setup script, and trying your first commands. No prior experience needed.

Already have your tools set up? Keep reading.

## Quick Start

### Option A: One-liner setup (recommended)

```bash
bash <(curl -s https://raw.githubusercontent.com/Razor1990-mm/claude-code-setup/main/setup.sh)
```

This detects your project type, asks 2-3 questions, and generates the right `.claude/` directory structure.

### Option B: Manual setup

1. **Read `PLAYBOOK.md`** — the end-to-end guide: which workflow to run, when, and why
2. Read `INSTALL.md` for your specific agent's setup
3. Copy `global-preferences.md` into your agent's global config location
4. Copy `rules/project.md` into your project and fill in the `<!-- CUSTOMIZE -->` sections
5. Copy additional `rules/` files as needed for your stack
6. Copy `workflows/` into your project
7. Copy `agents/` if you want multi-agent delegation
8. Copy `hooks/` and `settings.json` for automation
9. Copy `memory/` for persistent cross-session context
10. Copy `templates/` for sprint planning and delegation

## Philosophy

These rules encode a specific development philosophy:

- **Spec-driven**: Plan before code. Write specs, validate them, then implement.
- **TDD by default**: Tests first for all non-trivial changes.
- **Sacred tests**: Never modify existing tests to make code pass. If tests break, the code is wrong.
- **Ship complete**: Build it now or cut scope explicitly. Never defer to "future work."
- **Fail-closed**: Missing auth = error, not silent bypass. Least privilege always.
- **Proof required**: Claims about correctness must be backed by tests, logs, or reproducible checks.
- **Triple review**: Claude reviews + Codex reviews = adversarial tension. Near-zero overlap between reviewers.
- **Codex reviews, Claude fixes**: Role separation prevents closed feedback loops.

## Customization

Files with `<!-- CUSTOMIZE -->` markers have sections you need to fill in for your specific project. Search for these markers and replace with your project's details.

```bash
grep -r "CUSTOMIZE" . --include="*.md"
```

## Origin

Extracted from a production AI agent orchestration platform. Every rule exists because something went wrong without it. The triple-review system was validated across 32+ review-fix commits with near-zero overlap between reviewers.
