# Workflows

These are structured workflow prompts that guide AI agents through complex multi-step tasks. Each file contains the full instructions an agent needs to execute a workflow correctly.

## How to Use

**With any AI agent:** Paste the workflow content into your conversation, or reference it in your project rules so the agent reads it when needed.

**With Claude Code:** These can be converted to `/commands` by placing them in `.claude/commands/` with frontmatter. See `wiring/claude-code.md`.

**With Codex:** Reference these from `AGENTS.md` or paste them when you need a specific workflow. See `wiring/codex.md`.

## Workflow Catalog

### Planning
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `spec.md` | Write an upfront spec with interview + external research | Before any feature, hardening, or refactor |
| `staff-review.md` | Senior engineer review of a plan (auto-triggers before ExitPlanMode) | After writing a spec, before implementing |

### Implementation
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `tdd-workflow.md` | Write failing tests first (RED phase) with .tdd-red-phase marker | Before writing production code |
| `test-gen.md` | Generate test plan and scaffold | When you need tests for existing code |
| `fix.md` | Autonomous bug fixing from error output | When you have a stack trace or error log |

### Quality Gates
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `review.md` | Comprehensive code review (completeness + adversarial + AI-smell) | Before creating PRs |
| `audit.md` | Multi-dimensional audit on branch changes | Before PRs or at sprint end |
| `audit-full.md` | Full codebase audit with 4 parallel sub-audits | Before releases or quarterly health check |
| `grill.md` | Adversarial "break the code" review | When you want honest, hostile feedback |
| `security.md` | Security-focused OWASP checklist | When touching auth, middleware, or routes |

### PR & Release
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `pr.md` | Automated triple review-fix loop (review -> fix -> re-review) | When ready to merge |
| `ingest-review.md` | Parse review output into structured findings with IDs | Used internally by pr.md |
| `commit.md` | Structured commit with conventional format | At logical boundaries |
| `sprint-closeout.md` | Final 7-phase gate before merging sprint branch | End of sprint, before merge |

### Codex Integration (Dual-Model Review)
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `codex-cto.md` | CTO advisor — plan review + implementation review | Before implementation (plan) or before PR (review) |
| `codex-code-review.md` | Production-readiness review ("will this survive 3am?") | Part of `/pr` triple review |
| `codex-pr-review.md` | Strategic 8-dimension PR review (coherence, completeness) | Part of `/pr` triple review |
| `codex-cto-parallel.md` | Parallel CTO review across multiple spec files | When validating multiple specs at once |

### Utilities
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `backlog.md` | Add agent-ready items to backlog | When you discover future work |
| `explain.md` | Explain code, PRs, or sprint scope (3 modes) | When you need to understand or document |
| `check-tenancy.md` | Validate multi-tenancy + schema blast radius | After editing domain files or schema |
| `check-consistency.md` | Detect string constant drift | After editing domain files |

## Trust Model (Codex Workflows)

**Critical:** For Codex review workflows, Claude does NOT read the changed files. Codex navigates the codebase independently. This ensures Codex sees the real code, not Claude's version of it. Claude's job is to compose the prompt and present results — not to act as a middleman for code reading.

## Workflow Relationships

```
/spec -> /staff-review + /codex-cto (validate)
  |
  v
/tdd-workflow -> implementation -> /commit (repeat)
  |
  v
/pr orchestrates:
  /review (Claude) + /codex-code-review + /codex-pr-review
    |
    v
  /ingest-review (classify findings)
    |
    v
  Auto-fix -> verify -> re-review -> converge
  |
  v
/sprint-closeout -> MERGE
```
