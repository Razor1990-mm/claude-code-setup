# Development Playbook

The step-by-step guide for how a feature goes from idea to merged code. This ties together the rules, workflows, and templates — telling you **what to run, when, and why**.

---

## The Big Picture

```
IDEA -> SPEC -> VALIDATE -> IMPLEMENT (TDD) -> REVIEW -> MERGE
```

Every feature follows this flow. The workflows automate each stage. Skip stages at your own risk — every one exists because something broke without it.

---

## Stage 1: Planning (Spec)

**Goal:** Define what you're building before writing any code.

### What to do

1. **Run the spec workflow** (`workflows/spec.md`)
   - The agent interviews you (minimum 2 rounds)
   - Researches the codebase for entry points and existing patterns
   - Runs external research (WebSearch + Context7) for best practices
   - Writes a spec with Prior Art, Build vs Adopt, Control Flow Design
   - Saves to `specs/<name>.md`

2. **Validate the spec** (run both in parallel):
   - `workflows/staff-review.md` — Reviews as a skeptical senior engineer (design quality, engineering filters, risk, scope, format checks)
   - `workflows/codex-cto.md` — Codex reads the plan + real code independently (feasibility, file boundaries, invariant coverage)
   - If verdicts disagree, both are flagged

3. **`/clear`** — Start implementation with fresh context

### When to skip
- Trivial changes (typo, rename, constant) — go straight to Stage 3
- Bug fixes from error logs — use `workflows/fix.md` instead

### Output
- `specs/<name>.md` — your implementation contract
- Staff review + Codex CTO verdicts: both PROCEED

---

## Stage 2: Branch Setup

**Goal:** Create an isolated workspace.

### What to do

1. Create a feature branch from main:
   ```bash
   git checkout -b feature/short-description
   ```

2. **Stay on this branch for the entire session.** Never switch back to main after committing.

### Rules
- Branch naming: `feature/`, `fix/`, `refactor/`, `sprint-N/`
- One spec per branch
- Never commit directly to main

---

## Stage 3: Implementation (TDD)

**Goal:** Build the feature test-first.

### What to do

1. **Run the TDD workflow** (`workflows/tdd-workflow.md`)
   - Writes failing tests FIRST (RED phase)
   - Creates `.tdd-red-phase` marker file for compliance tracking
   - Outputs test plan with A-H categories from `rules/testing.md`
   - Full sub-pattern templates (A-MIN through G-MT-4)
   - Hands off to GREEN phase

2. **Write production code** (GREEN phase)
   - Make the failing tests pass
   - Write minimal code — don't over-build
   - Follow patterns from `rules/code-patterns.md`

3. **Commit** (`workflows/commit.md`)
   - 60-140 LOC production code per commit
   - Conventional format: `feat:`, `fix:`, `refactor:`, `test:`
   - Commit frequently — uncommitted work is lost work

4. **Repeat** steps 1-3 for each piece of the spec

### Mid-implementation checks

| Trigger | Workflow | Why |
|---------|----------|-----|
| Edited domain files | `workflows/check-tenancy.md` | Catch missing tenant filters (P0 security) |
| Edited domain files | `workflows/check-consistency.md` | Catch string constant drift |
| Changed auth/middleware | `workflows/security.md` | Catch auth bypass, PII leaks |

### When things go wrong
- **Existing test breaks:** STOP. Fix your code, not the test. Tests are sacred.
- **Need a file outside spec scope:** STOP. Report as blocker.
- **Spec is wrong:** Append `[DISCOVERY]` to spec changelog. Continue against corrected spec.
- **3+ discoveries in one session:** STOP. Spec may need full re-plan.
- **Bug from error output:** Use `workflows/fix.md` (parse -> locate -> fix -> verify)

---

## Stage 4: Pre-PR Quality Gates

**Goal:** Catch issues before the formal review.

### What to do (pick based on confidence)

| Confidence | Run | Why |
|------------|-----|-----|
| High | `workflows/audit.md` | Quick multi-dimensional scan |
| Medium | `workflows/audit.md` + `workflows/grill.md` | Audit + adversarial pressure |
| Low | `workflows/audit.md` + `workflows/grill.md` + `workflows/review.md` | Full battery |

---

## Stage 5: PR Review-Fix Loop

**Goal:** Automated triple review, fix, and re-review until clean.

### What to do

1. **`/clear`** — Fresh context for the review loop
2. **Run the PR workflow** (`workflows/pr.md`)

   This orchestrates everything:
   ```
   Commit + Push + Create PR
       |
   Run 3 reviews in parallel:
     - workflows/review.md (Claude: completeness + AI-smell)
     - workflows/codex-code-review.md (Codex: production-readiness)
     - workflows/codex-pr-review.md (Codex: strategic cohesion)
       |
   Parse findings (workflows/ingest-review.md)
       |
   Classify: AUTO-FIX / ASK_USER / SUGGEST
       |
   Auto-fix safe findings (max 5/cycle, allowlist only)
       |
   Verify (lint + typecheck + full test suite)
       |
   Re-review -> convergence check
       |
   Max 2 cycles, then human decides
   ```

### How findings are classified

| Class | Criteria | Action |
|-------|----------|--------|
| **AUTO** | P0/P1 + concrete fix + on allowlist + small blast radius | Agent fixes automatically |
| **ASK_USER** | Architectural, ambiguous, recurring, contradictions, large blast radius | You decide |
| **SUGGEST** | P2 severity | Presented at end, no action |

### Auto-fix allowlist (the ONLY things auto-fixed)
<!-- CUSTOMIZE: Define your allowlist -->
- Missing tenant filter on queries
- Unused imports
- Missing typed error throws
- Missing CAS count checks
- Missing timeouts on external calls

**Everything else goes to ASK_USER.** The agent is the fixer, not the triage arbiter.

### Triple review — why 3 reviewers?
Validated across 32+ review-fix commits:
- Claude `/review` caught 11 findings (spec adherence, architecture, test gaps)
- Codex code-review caught 13 findings (MT violations, unbounded queries, PII, crashes)
- Codex PR-review caught 3 strategic P0s
- **Near-zero overlap** between reviewers

---

## Stage 6: Sprint Closeout (if applicable)

**Goal:** Verify all slices compose into a coherent whole before merging to main.

### What to do

1. **Run sprint closeout** (`workflows/sprint-closeout.md`)

   7 phases:
   - **Gather context:** Parse spec, build branch diff
   - **Spec fidelity:** Did we build what the spec said? Ghosts? Dead ends?
   - **Cross-slice cohesion:** Naming, interface contracts, data flow, imports
   - **Dead-end detection:** TODOs, stubs, unused code, debug artifacts
   - **Main compatibility:** Merge conflicts, shared-file overlaps
   - **Proof gates:** Lint + typecheck + full test suite
   - **Closeout report:** Compiled verdicts

   Verdict: MERGE / FIX FIRST / RETHINK

---

## Stage 7: Merge

1. Sprint closeout verdict is MERGE
2. Human merges (the agent does NOT merge — that's your call)
3. If items were cut, add them to backlog (`workflows/backlog.md`)

---

## Quick Reference: Which Workflow When

### "I'm starting a new feature"
-> `spec.md` -> `staff-review.md` + `codex-cto.md` -> `/clear` -> `tdd-workflow.md` -> `pr.md`

### "I have a bug to fix"
-> `fix.md` -> `commit.md`

### "I want to review my code before PR"
-> `audit.md` + `grill.md`

### "I'm ready for PR"
-> `/clear` -> `pr.md` (orchestrates triple review + fix + re-review)

### "Sprint is done, ready to merge"
-> `sprint-closeout.md`

### "I need to explain this code/PR to someone"
-> `explain.md` (code mode, PR mode, or sprint mode)

### "I found something we should do later"
-> `backlog.md`

### "I want the full CTO process with agents"
-> `agents/cto.md` delegates to specialist agents (see `agents/README.md`)

### "Just a quick fix, no ceremony"
-> Fix it -> quality gates (lint, typecheck, tests) -> `commit.md`

---

## Multi-Agent Parallel Work

When multiple agents work on the same sprint, you run them in **separate terminal windows** with **git worktrees** so they don't step on each other.

### Terminal Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  WINDOW 1: Spec Writer                                          │
│  Purpose: Write specs, validate plans, manage backlog           │
│  Branch: sprint-N/main (or main for cross-sprint specs)         │
│  Runs: /spec, /staff-review, /codex-cto                        │
│  When done: Spec is in specs/<name>.md, ready for work orders   │
├─────────────────────────────────────────────────────────────────┤
│  WINDOW 2: CTO Orchestrator                                     │
│  Purpose: Create work orders, delegate to specialists, review   │
│  Branch: sprint-N/main (sprint branch)                          │
│  Runs: Creates work orders from spec, spawns agents, runs /pr   │
│  When done: Work orders dispatched, PR reviewed and merged      │
├─────────────────────────────────────────────────────────────────┤
│  WINDOW 3+: Specialist Agents (one per worktree)                │
│  Purpose: Implement slices from work orders                     │
│  Branch: sprint-N/slice-name (worktree off sprint branch)       │
│  Runs: /tdd-workflow, implements, /commit, /check-tenancy       │
│  When done: Slice complete, pushed, ready for CTO review        │
└─────────────────────────────────────────────────────────────────┘
```

### Setting Up Worktrees

Each specialist agent works in a **git worktree** — an isolated copy of the repo on its own branch. This lets agents edit files in parallel without merge conflicts.

```bash
# You're on the sprint branch
git checkout sprint-19/main

# Create a worktree for each specialist
git worktree add ../project-backend sprint-19/backend-slice
git worktree add ../project-frontend sprint-19/frontend-slice

# Open each worktree in a separate terminal
cd ../project-backend   # Window 3: Backend Lead works here
cd ../project-frontend  # Window 4: Frontend Lead works here
```

**Key rules:**
- Worktrees branch off the **sprint branch**, not main
- One sprint branch per sprint (e.g., `sprint-19/main`)
- Each worktree gets its own slice branch (e.g., `sprint-19/backend-slice`)
- When a slice is done, merge it back to the sprint branch

### Cleanup

```bash
# After slices are merged back to sprint branch
git worktree remove ../project-backend
git worktree remove ../project-frontend
```

### Parallelization Rules

```
Sprint Spec (slices table)
    |
SCHEMA slices: Serial (one agent at a time)
    |
DOMAIN/ROUTE/TEST slices: Parallel (disjoint file lists)
```

- **SCHEMA slices are serial** — only one agent touches the database schema at a time
- **DOMAIN/ROUTE/TEST slices can parallelize** — but file lists must be disjoint
- **Shared bottleneck files** (schema, error types, event types, test helpers, app config) are owned by one agent (usually CTO or the infrastructure slice). Others report needs as blockers.
- **Each agent owns exclusive files** declared in the work order's FILES YOU MAY TOUCH section
- If you need a file outside your scope: **STOP and report as blocker** — do NOT edit it

### Typical Flow

```
1. Window 1: /spec → write spec → /staff-review + /codex-cto → PROCEED
   |
2. Window 2: CTO reads spec → creates work orders → delegates
   |
   ├── Window 3: Backend Lead receives work order → /tdd-workflow → implement → /commit
   ├── Window 4: Frontend Lead receives work order → /tdd-workflow → implement → /commit
   |
3. Window 2: CTO reviews completed slices → merges to sprint branch
   |
4. Window 2: /pr (triple review on sprint branch) → fix → converge
   |
5. Window 2: /sprint-closeout → MERGE verdict → human merges to main
```

### Agent Org Chart

| Role | Model | Focus |
|------|-------|-------|
| CTO | opus | Orchestrator, work orders, process |
| Backend Lead | opus | Domain logic, DB, API design |
| Frontend Lead | sonnet | UI, components, UX |
| QA Engineer | sonnet | Testing strategy, blocking power |
| Security Engineer | opus | Auth, tenancy, PII, P0 blocking |
| DevOps Engineer | sonnet | Cost, deployment, infrastructure |

See `agents/README.md` for the full org chart, context inheritance, and skill-to-agent mapping.

### Work Orders

Use `templates/work-order.md` to delegate bounded slices. Key sections:
- FILES YOU MAY TOUCH (allowlist)
- DO NOT TOUCH (out of scope)
- MUST-COVER INVARIANTS (missing any = blocker)
- STOP CONDITIONS (when to halt and report)
- PROOF COMMANDS (how to verify)

---

## Anti-Patterns (What NOT to Do)

| Anti-Pattern | Why It Fails | Do This Instead |
|--------------|-------------|-----------------|
| Code first, spec later | Wrong assumptions, rework | Spec first, even a short one |
| Tests after production code | Tests become confirmatory, not preventive | TDD: tests first, always |
| Modify tests to make code pass | Erodes the safety net | Fix the code, not the tests |
| One giant commit | Can't rollback safely | 60-140 LOC per commit |
| Switch to main after committing | Lose branch context | Stay on branch until PR/merge |
| Auto-fix everything | Agent makes wrong judgment calls | Allowlist only, max 5/cycle |
| Skip the spec for "simple" features | Simple features balloon | Spec it or explicitly call it trivial |
| Defer quality to "future work" | Future work never happens | Ship complete or cut scope now |
| Dismiss Codex findings as "out of scope" | Hides real issues | If Codex found it in changed files, it's in scope |
| Single reviewer | Misses entire categories | Triple review: near-zero overlap |
