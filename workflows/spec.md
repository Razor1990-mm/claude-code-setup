# Workflow: Write a Spec

Write a spec interactively, then save to `specs/<name>.md`.

## Process

1. **Determine type**: Feature (default), hardening, or refactor
2. **Interview**: Gather requirements (2-4 questions per round, minimum 2 rounds mandatory). Round 1 gathers core requirements, round 2 probes scope boundaries, edge cases, and priority calls. Keep asking beyond 2 rounds if the picture is incomplete. Do NOT rush to write the spec.
3. **Research**: Read relevant codebase files to ground the spec in real code (entry points, existing patterns, test coverage)
4. **Write spec**: Fill the appropriate template below and save to `specs/<name>.md`
5. **Validate**: Run a staff review on the spec before implementing
6. **Suggest next step**: "Spec validated. Ready to implement."

## Interview Questions (adapt to type)

**Feature:**
- What problem does this solve? Why now?
- What's the acceptance criteria? (specific, testable)
- What's explicitly out of scope?
- Which external systems are involved?

**Hardening:**
- Which area/invariant are you hardening?
- What's the current state? (existing coverage, known gaps)
- What specific invariants must hold after this work?

**Refactor:**
- What code are you refactoring and why?
- What's the target structure?
- Which existing tests must still pass?

---

## Feature Template (default)

```markdown
# Feature: <name>

## Problem
What's broken or missing. Why now.

## Requirements
- Acceptance criteria (testable, specific)
- Edge cases to handle
- What's explicitly out of scope

## Design
- Entry points (files + functions)
- Data flow (which tables, which domain functions)
- External systems touched

## Constraints
<!-- CUSTOMIZE: Adapt these to your project's invariants -->
- Multi-tenancy: which queries need tenant scoping
- Idempotency: which operations could retry
- Concurrency: which state transitions need compare-and-swap
- Security: auth pattern, PII considerations

## Stop Conditions
- If any existing test breaks, STOP — fix the code, not the test
- If you need to modify a file outside the Files Touched table, STOP and report as blocker

## Verification
- Test cases (input -> expected output)
- Manual verification steps
- What "done" looks like
```

## Hardening Template

```markdown
# Hardening: <area>

## Current State
What exists today (files, behavior, test coverage). Evidence with file:line references.

## Invariants to Enforce
- [ ] INV-1: <specific invariant with test assertion>
(Each must have a corresponding test)

## Existing Tests That Must Still Pass
List by file. Sacred — if they break, the hardening is wrong.

## New Tests Required
- [ ] <test description with input -> expected output>

## Stop Conditions
- If any existing test breaks, STOP — fix the code, not the test
- If you need to modify a file outside the Files Touched table, STOP and report as blocker

## What "Done" Looks Like
Before/after comparison. Concrete metrics where applicable.
```

## Refactor Template

```markdown
# Refactor: <area>

## Current State
What exists, why it's problematic. Existing test coverage.

## Target State
Desired structure (files, modules, interfaces). Behavioral equivalence proof.

## Constraints
- No behavior changes (refactor, not rewrite)
- Existing tests must pass WITHOUT modification

## Stop Conditions
- If any existing test breaks, STOP — fix the code, not the test
- If you need to modify a file outside the Files Touched table, STOP and report as blocker

## Verification
- All existing tests green
- New structural tests if interfaces change
```

## Spec Quality Checks (before saving)

- Every requirement is testable (not vague like "improve performance")
- Entry points reference real files (read them to verify)
- At least 2 test cases in Verification (1 happy path, 1 failure)
- Out-of-scope section is non-empty (forces explicit scoping)

## Session Sizing

- Target: 200-400 LOC production code per spec (TDD adds ~2-3x test code on top)
- If a spec would need >4 implementation commits, split into two specs
