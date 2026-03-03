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
| `spec.md` | Write an upfront spec with interview | Before any feature, hardening, or refactor |
| `staff-review.md` | Senior engineer review of a plan | After writing a spec, before implementing |

### Implementation
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `tdd-workflow.md` | Write failing tests first (RED phase) | Before writing production code |
| `test-gen.md` | Generate test plan and scaffold | When you need tests for existing code |
| `fix.md` | Autonomous bug fixing from error output | When you have a stack trace or error log |

### Quality Gates
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `review.md` | Comprehensive code review (completeness + adversarial + AI-smell) | Before creating PRs |
| `audit.md` | Multi-dimensional audit (security, tenancy, cost, hygiene) | Before PRs or at sprint end |
| `grill.md` | Adversarial "break the code" review | When you want honest, hostile feedback |
| `security.md` | Security-focused checklist | When touching auth, middleware, or routes |

### PR & Release
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `pr.md` | Automated review-fix loop (review → fix → re-review) | When ready to merge |
| `ingest-review.md` | Parse review output into structured findings | Used internally by pr.md |
| `commit.md` | Structured commit with conventional format | At logical boundaries |
| `sprint-closeout.md` | Final gate before merging sprint branch | End of sprint, before merge |

### Utilities
| Workflow | Purpose | When to Use |
|----------|---------|-------------|
| `backlog.md` | Add agent-ready items to backlog | When you discover future work |
| `explain.md` | Explain code, PRs, or sprint scope | When you need to understand or document |
| `check-tenancy.md` | Validate multi-tenancy (org-scoping) | After editing domain files |
| `check-consistency.md` | Detect string constant drift | After editing domain files |
