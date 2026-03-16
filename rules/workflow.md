# Workflow Rules

These apply to all files. Root CLAUDE.md has the summary; this file has the detailed flow.

## Spec-Driven Development

**Default flow:**

```
/spec -> explore codebase -> external research -> interview (2+ rounds) -> write spec
  -> /clear
  -> /codex-cto + /staff-review (validates spec)
  -> /clear
  -> implement (guided by spec)
    -> commit at logical boundaries
    -> git hook: lint + typecheck + domain-test-check + affected tests
    -> repeat
  -> /clear
  -> /pr (automated review-fix loop, once when ready):
    -> commit + push + create/update PR
    -> /review + /codex-code-review + /codex-pr-review (parallel)
    -> parse findings -> classify (AUTO / ASK_USER / SUGGEST)
    -> Claude fixes AUTO findings (allowlist only, max 5/cycle, max 3 files/30 LOC each)
    -> full verify (lint + typecheck + full test suite)
    -> commit fixes -> re-review -> convergence check
    -> max 2 cycles, then human decides
```

> **Token efficiency:** `/clear` between phases to avoid context bloat. Explore agents use `model="haiku"` (80% cheaper). Codex reviews (cheap tokens), Claude fixes and verifies.

> Work orders (`templates/work-order.md`) are for multi-agent delegation only (CTO chain -> specialist agents). Solo-dev implementation uses the spec directly as the implementation contract.

### Spec Phase
- Run `/spec` — every spec gets the full process (no FAST/FULL distinction)
- **Process**: explore codebase -> external research (WebSearch + Context7) -> interview (2+ rounds) with Prior Art + Research -> write spec with Build vs Adopt + Control Flow Design -> validate with `/codex-cto` + `/staff-review`
- Spec is saved to `specs/<name>.md`
- Implementation can continue in the same session — no mandatory `/clear`. The spec is self-contained.

### Implementation Phase
- `/clear` before starting implementation (fresh context, spec is self-contained)
- Read the spec from `specs/<name>.md`
- Write tests first via `/tdd-workflow` (TDD ordering)
- Commit freely at logical boundaries — git hook runs mechanical checks
- **High-risk checkpoint:** For tenancy/auth/state-transition code, run `/check-tenancy` mid-session

**Mid-flight discovery rule:** When implementation reveals the spec is wrong, use this decision tree:

| Situation | Trigger | Action |
|-----------|---------|--------|
| **Spec approach is technically impossible** | You cannot implement what the spec says | 1. Stop and tell user. 2. Append `[DISCOVERY]` to spec changelog. 3. Continue against corrected spec. |
| **Spec has a factual error** (wrong file name, wrong function signature) | Spec references something that doesn't match reality | 1. Append `[CORRECTION]` to spec changelog. 2. Continue — no user prompt needed for typo-level fixes. |
| **You need a file outside spec's declared scope** | Implementation requires editing an unlisted file | **STOP and report as blocker.** Do NOT silently edit out-of-scope files. |
| **Scope cut** | You or user decide not to build a planned slice | Set slice Status to `CUT` in spec. Add cut item to backlog. |

- A discovery is NOT an implementation bug or a scope cut.
- If you hit 3+ discoveries in one session, stop — the spec may need a full re-plan.

### PR Phase (Automated via `/pr`)
- `/clear` before running `/pr` (fresh context for review loop)
- Run `/pr` which orchestrates the full review-fix loop:
  1. Commit + push + create/update PR
  2. Run `/review` + `/codex-code-review` + `/codex-pr-review` in parallel
  3. Parse findings via `/ingest-review` (verbatim severity, unique IDs)
  4. Claude fixes AUTO findings (allowlist-only, blast radius capped)
  5. Full verify after every fix cycle (lint + typecheck + full test suite)
  6. Commit fixes -> re-review with prior finding list -> convergence check
  7. Max **2 cycles**. Human involved for ASK_USER findings or non-convergence.
- **Role separation:** Codex reviews. Claude fixes. Severity is immutable.
- Both models review independently = adversarial tension (two models, two perspectives)

### Commit Discipline
- **Spec** is the unit of planning: one feature, 200-400 LOC production code per session (tests add ~2-3x on top)
- **Commit** is the unit of rollback: 60-140 LOC production code, one concern, max 5 branches. With TDD, commits up to ~300 LOC (production + tests) are normal.
- **Split trigger:** If a spec needs >4 implementation commits, split into two specs
- **Review-fix commit:** The `/pr` loop typically produces 1 additional fix commit. Plan for N+1 commits.
- Typical session: 2-4 implementation commits + 1 review-fix commit

## When User Requests CTO Chain
Trigger phrases: "CTO this", "full workflow", "get the team on this", "I want the full process"

Flow:
1. **Spawn CTO** — `Agent(subagent_type="goose-cto", model="opus", prompt="<feature + context>")`
   - CTO creates work order (must follow `templates/work-order.md`)
   - CTO delegates to specialists
2. **CTO delegates:**
   - Backend -> `Agent(subagent_type="goose-backend-lead", model="opus", prompt="<work order>")`
   - Frontend -> `Agent(subagent_type="goose-frontend-lead", model="opus", prompt="<work order>")`
3. **PR gate** — `/review` + `/codex-pr-review` before merge

## Trivial Changes
Trigger phrases: "Just fix it", "quick fix"

Flow: fix -> quality gates (no TDD ceremony, no spec)

"Trivial" means small change (typo, rename, constant), not relaxed quality.

## Branch Discipline

**NEVER switch to main after committing.** Stay on the working branch for the entire session.

- At session start: check current branch. If on `main`, create or checkout the sprint/feature branch FIRST.
- After committing: stay on the same branch. Do NOT run `git checkout main`.
- After completing a slice: stay on the branch. Ask the user what's next.
- The only time to touch `main` is when the user explicitly says "merge" or "switch to main."

**Branch lifecycle:**
```
create branch -> implement -> commit (stay on branch) -> implement more -> commit (stay on branch) -> PR
```

**Anti-pattern (DO NOT DO):**
```
create branch -> implement -> commit -> git checkout main <- WRONG
```

## Parallel Agent Rules

When multiple agents work on the same sprint:

- **Each agent owns exclusive files** declared in the spec/slice. Do NOT edit files assigned to another agent.
- **Shared bottleneck files** (schema, shared types, helpers, app config) are owned by the infrastructure agent. Other agents report needs as blockers.
- **SCHEMA slices are serial** — at most one agent works on schema changes at a time.
- **DOMAIN/ROUTE/TEST slices can parallelize** if their file lists are disjoint.
- If you discover you need a file outside your spec's declared scope: STOP and report as blocker. Do NOT edit it.
- **Pull frequently** — `git pull --rebase` before starting new work to pick up other agents' changes.

## Process Enforcement

Non-negotiable rules:
- **TDD is default** for all code changes except trivial. Invoke `/tdd-workflow` via Skill tool.
- **Skills must be invoked via the Skill tool**, not manually replicated
- **Existing tests are sacred** — never modify to make code pass. If tests break, the code is wrong.
- **Files outside spec scope are off-limits** — report as blocker
- **Commit frequently** — uncommitted work is lost work
- **Ship complete features** — never defer pieces to hypothetical future work
- **Stay on your branch** — never switch to main after committing

## File Routing (Auto-Apply)

| User says... | Claude does... |
|--------------|----------------|
| "We should eventually..." / "Future idea..." | Add to backlog |
| "We need a runbook..." | Create in `docs/runbooks/` |

## Definition of Done

<!-- CUSTOMIZE: Replace with your project's verify commands -->
- [ ] Linter passes
- [ ] Type checker passes
- [ ] Test suite passes
- [ ] Integration tests pass (if DB schema changed)
- [ ] `/check-tenancy` passes on modified domain files
- [ ] Every new/modified domain file has a test file
- [ ] Never modify existing tests — fix the code, not the tests
