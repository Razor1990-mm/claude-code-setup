# Workflow: Comprehensive Code Review

Completeness checks, project-rules compliance, adversarial code review, and AI-smell detection in one pass.

## Process

1. **Identify changes**: Build changed-file set from branch diff (merge-base against main)
2. **Read every changed file fully** (not just diffs) — understand full context
3. **Run all checks below** against each file
4. **Produce findings + verdict**

---

## Checklist 0: Spec Adherence

If a spec file exists for this work:
1. Read the spec file
2. For each requirement/acceptance criterion:
   - [ ] Is there code that implements it? (cite file:function)
   - [ ] Is there a test that verifies it? (cite file:test-name)
3. Check for drift:
   - [ ] No requirements silently dropped
   - [ ] No out-of-scope work added
   - [ ] "Out of scope" items from the spec are NOT implemented

Output a traceability table:
```
| # | Spec Requirement | Implemented (file:fn) | Tested (file:case) | Status |
```

## Checklist 1: Completeness

- [ ] Every new/modified domain file has a corresponding test file
- [ ] New behavior has tests (happy path + at least 1 error/edge case)
- [ ] If schema changed: cleanup helpers updated
- [ ] TDD ordering followed (tests written before implementation)

## Checklist 2: Project Rules Compliance

<!-- CUSTOMIZE: Adapt these to your project's core principles -->

### Domain Boundary
- [ ] ORM only imported in domain layer
- [ ] Controllers are thin shells — no business logic

### Multi-Tenancy
- [ ] Every query includes tenant filtering
- [ ] New parent-child relationships have proper FK constraints

### Idempotency
- [ ] Unique constraints on natural keys where needed
- [ ] Duplicate key errors caught and handled
- [ ] Safe under webhook retries

### Concurrency / CAS
- [ ] Conditional update results checked for count > 0
- [ ] Event writes ordered AFTER the operation they describe

### Authentication
- [ ] Correct auth method per endpoint type
- [ ] Missing auth returns 401/403, not silent bypass

### Logging & PII
- [ ] No secrets logged
- [ ] Correlation IDs included
- [ ] Failures have enough context to debug

## Checklist 3: Adversarial

For each changed file, ask:
- **Correctness:** What if X is null? What if Y times out? What if Z is called twice?
- **Design:** Why this pattern? What's the simpler alternative?
- **Completeness:** What edge cases are missing? What errors aren't handled?
- **Concurrency:** What if two requests hit this simultaneously?
- **Crash recovery:** What state is left if this fails mid-operation?

**Demand proof.** "It works" isn't enough — show the test.

## Checklist 4: AI-Smell Detection

### Circular validation (P0)
- Tests that call the same helper functions used in implementation
- Test assertions that mirror implementation logic rather than testing behavior
- All tests pass but no negative/failure cases exist

### Silent error swallowing (P0)
- Empty catch blocks
- `catch (e) { return null }` without logging
- Errors caught and converted to success responses

### Missing negative tests (P1)
- Happy path tested but no error/rejection paths
- No tests for invalid input, missing auth, wrong tenant

### Over-engineering (P2)
- Abstractions wrapping single-use functions
- Factory/strategy patterns for 1-2 variants

---

## Output Format

```
## Review Results (Branch: <branch>)

### Files Reviewed
- <file list with line counts>

### Findings

**P0 — BLOCKING (must fix before merge)**
- [P0] [Category] Description
  File: path/to/file.ts:line
  Fix: Concrete, specific action

**P1 — WARNING (should fix)**
- [P1] [Category] Description
  File: path/to/file.ts:line
  Fix: Concrete, specific action

**P2 — SUGGESTION (nice to have)**
- [P2] [Category] Description

### VERDICT: SHIP / FIX FIRST / RETHINK
```

## Verdict Criteria

- **SHIP**: Zero P0, zero P1, adversarial challenges have test coverage
- **FIX FIRST**: Any P0, or 2+ P1s, or adversarial challenge with no test
- **RETHINK**: 3+ P0s, or fundamental design violation

## Fix Line Requirement

**Every P0 and P1 finding MUST include a `Fix:` line** with a concrete, specific action. This enables automated fix loops to classify findings.
