---
name: sprint-closeout
description: Sprint closeout gate — cohesion, drift, dead ends, merge readiness
model: opus
---

Final quality gate before merging a sprint branch to main. Validates that all slices compose into a coherent product increment with no drift, dead ends, or integration gaps.

**Usage:** `/sprint-closeout` or `/sprint-closeout <sprint-spec-path>`

**When to run:** After all slices are DONE on the branch, before merging to main.

### Expected Runtime & Cost

| Scenario | Wall Time | Token Cost |
|----------|-----------|------------|
| Small sprint (3-5 slices) | ~5-8 min | ~80-120K tokens |
| Medium sprint (6-10 slices) | ~8-12 min | ~120-200K tokens |
| Large sprint (11-15 slices) | ~12-18 min | ~200-300K tokens |

---

## Process

### Phase 1: GATHER CONTEXT

1. **Find sprint spec:** Use latest file in `specs/` matching the current branch name, or user-specified path.
2. **Parse spec sections:**
   - TL;DR (theme, success criterion)
   - Slices table: ID, name, status, files, dependencies
   - "Not Building" list
   - Acceptance criteria
   - Decisions
3. **Build branch diff:** Run merge-base changed-file set against `origin/main` (fallback `main`).
4. **Read spec changelog** for mid-sprint decisions and scope changes.

### Phase 2: SPEC FIDELITY (Did we build what we said?)

For each slice in the spec:

1. **DONE slices:** Verify code exists + acceptance criteria have test coverage
   - DONE but no code -> **GHOST**
   - DONE but no tests -> **UNTESTED**

2. **CUT slices:** Verify NO code exists
   - CUT but code exists -> **DEAD END**

3. **NOT_STARTED slices:** Same as CUT — verify no partial code.

4. **Scope drift detection:**
   - Files changed not in ANY slice -> **UNPLANNED**
   - Items from "Not Building" that have code -> **SCOPE VIOLATION**

### Phase 3: CROSS-SLICE COHESION (Do the slices work together?)

Read ALL changed domain files. Scan for:

1. **Naming consistency** — Same concept named differently across slices
2. **Interface contracts** — Types match, return shapes consistent, error types consistent
3. **Data flow completeness** — Data from slice 1 flows correctly to slice 2
4. **Import graph health** — No circular imports, no imports from CUT slices

### Phase 4: DEAD-END DETECTION

1. **TODO/FIXME/HACK** added on this branch
2. **Stub functions** — throw NotImplemented, return hardcoded, empty bodies
3. **Unused new code** — not called, not tested, not exported
4. **Partial feature flags** — checks without both branches
5. **Debug artifacts** — console.log, debug comments

### Phase 5: MAIN COMPATIBILITY

1. **Merge conflict check**
2. **Breaking change scan:** Files modified on BOTH branch and main
3. **Rebase status:** If >20 commits behind, recommend rebase

### Phase 6: PROOF GATES

<!-- CUSTOMIZE: Your actual verify commands -->
Run and capture full output:
1. Linter
2. Type checker
3. Test suite
4. Integration tests (if applicable)

**All must pass. Any failure is BLOCKING.**

---

## Output Format

```
## Sprint Closeout: Sprint N — "Title"

**Branch:** <branch-name>
**Spec:** <spec-path>
**Theme:** <from TL;DR>

---

### 1. Spec Fidelity

| Slice ID | Slice Name | Spec Status | Code Status | Tests | Verdict |
|----------|------------|-------------|-------------|-------|---------|

**Shipped:** N/M slices
**Cut:** N slices
**Unplanned files:** N
**Scope violations:** N

### 2. Cross-Slice Cohesion

**Verdict:** CLEAN / DRIFT DETECTED / BROKEN LINK

### 3. Dead Ends

**Verdict:** CLEAN / N FOUND

### 4. Merge Readiness

**Verdict:** CLEAN / CONFLICTS / NEEDS REBASE

### 5. Proof Gates

| Gate | Result |
|------|--------|
| Lint | PASS / FAIL |
| Typecheck | PASS / FAIL |
| Tests | PASS / FAIL |
| Integration Tests | PASS / FAIL |

### 6. Sprint Changelog Entry

### VERDICT: MERGE / FIX FIRST / RETHINK

### Required Actions (if FIX FIRST)
1. [Concrete action with file:line]
```

---

## Verdict Criteria

- **MERGE**: All proof gates pass AND zero GHOST/DEAD END AND cohesion CLEAN or only P2 AND merge clean
- **FIX FIRST**: Any proof gate fails OR DEAD END found OR P0/P1 cohesion issue OR merge conflicts
- **RETHINK**: 2+ GHOST slices OR 2+ BROKEN LINK OR >50% slices CUT

---

## What This Skill Does NOT Do

- **Does not review code quality** — that's `/review` and `/pr`
- **Does not run the review-fix loop** — that's `/pr`
- **Does not audit security/tenancy** — that's `/audit` and `/check-tenancy`

This skill answers ONE question: **"Do all the pieces fit together, and is this branch ready to become main?"**

---

## Post-Closeout Actions (Manual)

After MERGE verdict:
1. Copy Sprint Changelog Entry into the spec
2. Mark sprint spec with final status
3. User merges branch to main (Claude does NOT merge — user decision)
4. If items flagged as UNPLANNED or CUT, ask user: "Add to backlog?"
