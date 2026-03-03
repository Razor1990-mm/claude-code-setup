# Workflow: Sprint Closeout

Final quality gate before merging a sprint branch to main. Validates that all slices compose into a coherent product increment.

**When to run:** After all slices are DONE on the branch, before merging to main.

---

## Process

### Phase 1: GATHER CONTEXT

1. Find sprint spec (latest file in `specs/` matching current branch, or user-specified)
2. Parse: TL;DR, slices table, "Not Building" list, acceptance criteria, decisions
3. Build branch diff (changed-file set against main)

### Phase 2: SPEC FIDELITY (Did we build what we said?)

For each slice in the spec:

- **DONE slices:** Verify code exists + acceptance criteria have test coverage
  - DONE but no code = **GHOST**
  - DONE but no tests = **UNTESTED**
- **CUT slices:** Verify NO code exists for cut slices
  - CUT but code exists = **DEAD END**
- **Scope drift:** Files changed that don't appear in any slice = **UNPLANNED**
- **Scope violation:** Items from "Not Building" that have code = **SCOPE VIOLATION**

Output: Spec Fidelity Table

### Phase 3: CROSS-SLICE COHESION (Do the slices work together?)

Read ALL changed domain files. Scan for:
1. **Naming consistency** — Same concept named differently across slices
2. **Interface contracts** — Types match, return shapes consistent, error types consistent
3. **Data flow completeness** — Data from slice 1 flows correctly to slice 2
4. **Import graph health** — No circular imports, no imports from CUT slices

### Phase 4: DEAD-END DETECTION

Hunt for half-built code:
1. TODO/FIXME/HACK added on this branch
2. Stub functions (throw NotImplemented, return hardcoded, empty bodies)
3. Unused new code (not called, not tested, not exported)
4. Debug artifacts (console.log, debug comments)

### Phase 5: MAIN COMPATIBILITY

1. Check for merge conflicts
2. Scan for breaking changes in files modified on both branch and main
3. Check commits behind main (recommend rebase if >20)

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

### 1. Spec Fidelity
| Slice ID | Slice Name | Spec Status | Code Status | Tests | Verdict |

### 2. Cross-Slice Cohesion
Verdict: CLEAN / DRIFT DETECTED / BROKEN LINK

### 3. Dead Ends
Verdict: CLEAN / N FOUND

### 4. Merge Readiness
Verdict: CLEAN / CONFLICTS / NEEDS REBASE

### 5. Proof Gates
| Gate | Result |

### VERDICT: MERGE / FIX FIRST / RETHINK
```

## Verdict Criteria

- **MERGE**: All proof gates pass, no ghosts/dead ends, cohesion clean, merge clean
- **FIX FIRST**: Any proof gate fails, dead ends found, P0/P1 cohesion issues, merge conflicts
- **RETHINK**: 2+ ghost slices, 2+ broken links, >50% slices cut
