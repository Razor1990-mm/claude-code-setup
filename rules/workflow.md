# Workflow Rules

Detailed spec-driven development flow. The project config has the summary; this file has the detailed mechanics.

## Spec-Driven Development

**Default flow:**

```
Write spec → Validate spec → Implement

Implement (guided by spec)
  → commit at logical boundaries
  → lint + typecheck + affected tests on commit
  → repeat

PR (once when ready):
  → commit + push + create PR
  → code review (automated and/or manual)
  → fix findings
  → re-review → merge
```

### Spec Phase
- Write a spec before starting any feature, hardening, or refactor work
- Spec is saved to `specs/<name>.md` (use `templates/sprint-spec.md` as the template)
- Validate the spec against the real codebase before implementing
- Implementation can continue in the same session — no mandatory context clear

### Implementation Phase
- Read the spec from `specs/<name>.md`
- Write tests first (TDD ordering)
- Commit freely at logical boundaries — git hooks run mechanical checks

### PR Phase
- Push and create PR
- Run code review (automated or manual)
- Fix findings, re-review
- Merge when clean

## Commit Discipline

- **Spec** is the unit of planning: one feature, manageable LOC per session
- **Commit** is the unit of rollback: 60-140 LOC production code, one concern
- With TDD, commits up to ~300 LOC (production + tests) are normal
- **Split trigger:** If a spec needs >4 implementation commits, split into two specs

## Trivial Changes

Trigger phrases: "Just fix it", "quick fix"

Flow: fix -> quality gates (no TDD ceremony, no spec)

"Trivial" means small change (typo, rename, constant), not relaxed quality.

## Branch Discipline

**NEVER switch to main after committing.** Stay on the working branch for the entire session.

- At session start: check current branch. If on `main`, create or checkout the feature branch FIRST.
- After committing: stay on the same branch. Do NOT run `git checkout main`.
- After completing a slice: stay on the branch. Ask the user what's next.
- The only time to touch `main` is when the user explicitly says "merge" or "switch to main."

**Branch lifecycle:**
```
create branch → implement → commit (stay on branch) → implement more → commit (stay on branch) → PR
```

**Anti-pattern (DO NOT DO):**
```
create branch → implement → commit → git checkout main ← WRONG
```

## Parallel Agent Rules

When multiple agents work on the same project:

- **Each agent owns exclusive files** declared in the spec/slice. Do NOT edit files assigned to another agent.
- **Shared bottleneck files** (schema, shared types, shared helpers, app config) are owned by the infrastructure agent. Other agents report needs as blockers.
- **Schema slices are serial** — at most one agent works on schema changes at a time.
- **Domain/route/test slices can parallelize** if their file lists are disjoint.
- If you discover you need a file outside your spec's declared scope: STOP and report as blocker.

## Process Enforcement

Non-negotiable rules:
- **TDD is default** for all code changes except trivial
- **Existing tests are sacred** — never modify to make code pass. If tests break, the code is wrong.
- **Files outside spec scope are off-limits** — report as blocker
- **Commit frequently** — uncommitted work is lost work
- **Ship complete features** — never defer pieces to hypothetical future work
- **Stay on your branch** — never switch to main after committing

## Engineering Decision Filter

Every implementation decision passes three filters:
1. **10x scale:** Would we build this the same way at 10x current load?
2. **Series A audit:** Would a senior engineer at a top-tier company approve this?
3. **Simplest correct solution:** Build it right or cut it entirely.
