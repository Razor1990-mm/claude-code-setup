# Sprint Spec Template

Unified sprint spec replacing PRD + tech spec + sprint doc. One file per sprint: `specs/sprint-NN-title.md`.

**Policy:** Standalone PRDs are reserved for multi-sprint strategic features only. Sprint-scoped work uses this format — no separate PRD or tech spec.

---

## Hard Caps (Enforced)

| Section | Cap | Rationale |
|---------|-----|-----------|
| TL;DR | 10 lines | If you can't summarize it, you don't understand it |
| Problem | 4 rows | More = too many problems for one sprint |
| Not Building | 3-5 bullets | Explicit exclusions prevent scope creep |
| Assumptions | 8 | More = you haven't validated enough |
| Decisions | 7 rows | More = over-designing |
| Defaults | 15 rows | Table, not prose |
| Slices | 15 | More = split into two sprints |
| Acceptance criteria | 1 PASS + 1 FAIL per slice min | Compact, per-slice |
| Failure modes | 7 | Focus on sprint-killers, not exhaustive catalog |
| Verification scenarios | 3 | 1 happy, 1 failure, 1 edge |
| Observability metrics | 5 | Track what matters, not everything |

## Fast Path

For sprints with <=3 slices and no architecture changes: sections 9-13 may be omitted with a 1-sentence justification each.

---

## Sprint Spec Structure

### TL;DR (10 lines max)

```
Sprint: <N> — "<Title>"
Branch: sprint-N/short-name
Depends on: <what must be merged first, or "none">
Theme: "<one-sentence theme>"

Problem: <1 sentence — what is broken or missing>
Solution: <1 sentence — what we build>
Success: <1 sentence — ONE observable outcome a human can verify>
Slices: <N> slices across <N> phases
Risk: <1 sentence — the #1 thing that could derail this>
```

Rules:
- Each line is ONE sentence. No semicolons chaining multiple thoughts.
- "Success" must describe a human-observable outcome, not a technical milestone.
- This block is the only thing guaranteed to be read every time the spec is opened.

---

### 1. Problem (max 4 rows)

| # | Problem | Evidence | Impact |
|---|---------|----------|--------|
| 1 | <what's broken> | <data/observation> | <who is hurt and how> |

### 2. Not Building (3-5 bullets)

- NOT building X because Y
- NOT building Z — deferred to Sprint N+1

### 3. Assumptions (max 8)

| # | Assumption | Risk if Wrong | Mitigation |
|---|-----------|--------------|------------|
| 1 | <statement> | <what breaks> | <fallback plan> |

### 4. Decisions (max 7)

| # | Decision | Options Considered | Chosen | Why | Risk |
|---|----------|-------------------|--------|-----|------|
| 1 | <what was decided> | <option A, option B> | <which one> | <1 sentence> | <1 sentence + mitigation> |

### 5. Defaults (max 15 rows)

| Area | Default |
|------|---------|
| <config/convention> | <value> |

### 6. Slices (max 15)

| ID | Slice | Phase | Type | Agent | Depends On | Entry Point | Files (exclusive) | Size | Status |
|----|-------|-------|------|-------|------------|-------------|-------------------|------|--------|
| N.0 | Schema migration | 1 | SCHEMA | 1 | — | schema file | schema, helpers, errors | S | NOT_STARTED |
| N.1 | <name> | 1 | DOMAIN | 2 | N.0 | `domain/foo.ts:fn` | `foo.ts`, `foo.test.ts` | M | NOT_STARTED |

- **Entry Point:** file + function name where implementation starts
- **Files (exclusive):** files this slice may modify. Only this agent writes to these files.
- **Type:** `SCHEMA` (serial), `DOMAIN` (parallelizable), `ROUTE` (parallelizable), `TEST` (parallelizable)
- **Agent:** agent number for parallel execution. SCHEMA slices must be Agent 1.
- **Status:** NOT_STARTED / IN_PROGRESS / DONE / CUT
- **Depends On:** uses slice IDs or "—" for no deps

**Parallel execution rules:**
- At most ONE `SCHEMA` slice in progress at a time
- `DOMAIN`/`ROUTE`/`TEST` slices with disjoint file lists can run in parallel
- Shared bottleneck files belong to the SCHEMA slice agent exclusively

### 7. Acceptance Criteria (per-slice, grouped by phase)

```
#### Phase 1 — <Phase Name>

**N.1 <Slice Name>**
- PASS: <positive criterion — what should succeed>
- FAIL: <negative criterion — what should fail safely>
```

- Each slice gets exactly 1 PASS and 1 FAIL minimum.
- Add up to 3 more criteria per slice only if the slice is M or L complexity.

### 8. Failure Modes (max 7)

| Failure | Impact | Detection | Recovery |
|---------|--------|-----------|----------|
| <what goes wrong> | P0/P1/P2 | <how you notice> | <what to do> |

### 9. Verification Scenarios (max 3)

```
#### Scenario 1: <Name> (happy path)
Setup: <1 sentence — prerequisites and data state>
Trigger: <curl command or UI action>
Expect: <observable outcome — DB state, API response, log entry>

#### Scenario 2: <Name> (failure)
Setup: <1 sentence>
Trigger: <curl command or UI action>
Expect: <observable outcome>
```

### 10. Observability (max 5)

| Metric | Target | Alert When | Action |
|--------|--------|------------|--------|
| <what to measure> | <goal> | <threshold> | <response> |

### 11. User Journeys (max 2, skip if N/A)

ASCII diagrams only. Max 15 nodes per journey.

### 12. State Machines (max 1, skip if N/A)

ASCII state diagrams only. Include only if the sprint adds or modifies entity lifecycle states.

### 13. Implementation Notes (optional)

For code snippets, migration SQL, interface contracts, and reference patterns that apply across slices.

### 14. Spec Changelog (living)

```
### YYYY-MM-DD — <context>
- Changed: <what + why>
```

### 15. References

- Backlog items consumed: <list IDs>
- Related docs: <links>
- Previous sprint: <link>

---

## Sprint Spec Checklist

Before marking sprint spec "ready":

- [ ] TL;DR is exactly 10 lines
- [ ] Problem table has 1-4 rows with evidence
- [ ] "Not Building" has 3-5 explicit exclusions
- [ ] Every decision has a rejected alternative and a risk
- [ ] Every slice has an entry point (file + function)
- [ ] Commits target 60-140 LOC, one concern
- [ ] Every slice has at least 1 PASS and 1 FAIL acceptance criterion
- [ ] Failure modes table has 3-7 rows with recovery plans
- [ ] At least 2 verification scenarios (1 happy, 1 failure)
- [ ] All hard caps respected

---

## Slice Close-Out (During Sprint)

When completing a slice:
1. Set slice Status to DONE in section 6
2. Add Spec Changelog entry in section 14
3. If any decision changed, update section 4

## Phase Close-Out (During Sprint)

When all slices in a phase are DONE:
1. Write at least 1 integration test per verification scenario
2. Run full test suite
3. Update Spec Changelog with phase completion note

## When to Update This Spec

- **Before sprint start:** Write full spec with all sections
- **During sprint:** Update slice status + spec changelog after each slice
- **After sprint:** Final changelog entry summarizing what shipped vs planned
