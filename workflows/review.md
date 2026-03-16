---
name: review
description: Consolidated PR review — completeness, compliance, adversarial, AI-smell detection
model: sonnet
---

Run a comprehensive review on current branch changes. Combines completeness checks, project compliance, adversarial code review, and AI-smell detection into one pass.

**Usage:** `/review` or `/review path/to/file.ts`

## Process

1. **Identify changes**: Build changed-file set using merge-base against `BASE_REF` (default `origin/main`, fallback `main`) including branch commits + unstaged/staged + untracked files. If a specific file is provided, review that file only.
2. **Read every changed file fully** (not just diffs) — understand full context
3. **Run all checks below** against each file
4. **Produce findings + verdict**

---

## Checklist 0: Spec Adherence

If a spec file exists in `specs/` for this work:
1. Read the spec file
2. For each requirement/acceptance criterion:
   - [ ] Is there code that implements it? (cite file:function)
   - [ ] Is there a test that verifies it? (cite file:test-name)
3. For each constraint (tenancy, idempotency, CAS, security):
   - [ ] Is the constraint enforced in the implementation?
4. Check for drift:
   - [ ] No requirements silently dropped
   - [ ] No out-of-scope work added
   - [ ] "Out of scope" items are NOT implemented

**Output a traceability table:**
```
| # | Spec Requirement | Implemented (file:fn) | Tested (file:case) | Status |
```

If no spec file exists, note "No spec found — skipping adherence check" and proceed.

## Checklist 1: Completeness

- [ ] Every new/modified domain file has a corresponding test file
- [ ] New behavior has tests (happy path + at least 1 error/edge case)
- [ ] Manual verification steps documented
- [ ] If schema changed: cleanup helpers updated, tenant checks passed
- [ ] TDD ordering followed (check commit history if available)

## Checklist 2: Project Compliance

<!-- CUSTOMIZE: Adapt these to match your project's rules -->

### Domain Boundary
- [ ] ORM/database client only imported in domain layer
- [ ] Controllers are thin shells — no business logic, no DB queries
- [ ] New capabilities expressed as domain functions first

### Multi-Tenancy
- [ ] Every query includes tenant filtering (never fetch by ID alone)
- [ ] New parent-child relationships have composite tenant FKs

### Idempotency
- [ ] Unique constraints on natural keys where needed
- [ ] Duplicate key errors caught and handled (re-fetch instead of crash)
- [ ] Safe under webhook/retry scenarios

### Concurrency / CAS
- [ ] `updateMany()` results checked for `count > 0`
- [ ] Event writes ordered AFTER the operation they describe
- [ ] DB client parameter passed through to inner domain calls

### Authentication
- [ ] Correct auth method per endpoint type
- [ ] Missing auth returns 401/403, not silent bypass
- [ ] Middleware order matches project documentation

### Logging & PII
- [ ] No secrets logged (auth headers, tokens, full phone numbers)
- [ ] Correlation IDs included
- [ ] Failures have enough context to debug

## Checklist 3: Adversarial (Grill Posture)

For each changed file, ask:
- **Correctness:** What if X is null? What if Y times out? What if Z is called twice?
- **Design:** Why this pattern? What's the simpler alternative?
- **Completeness:** What edge cases are missing? What errors aren't handled?
- **Concurrency:** What if two requests hit this simultaneously?
- **Crash recovery:** What state is left if this fails mid-operation?
- **Network failure:** What if the external API is down?

**Demand proof.** "It works" isn't enough — show the test.

## Checklist 4: AI-Smell Detection

### Circular validation (P0)
- Tests that call the same helper functions used in implementation
- Test assertions that mirror implementation logic rather than testing behavior
- Mock setups that encode implementation assumptions
- All tests pass but no negative/failure cases exist

### Silent error swallowing (P0)
- Empty catch blocks
- `catch (e) { return null }` without logging
- Errors caught and converted to success responses

### Missing negative tests (P1)
- Happy path tested but no error/rejection paths
- No tests for invalid input, missing auth, wrong tenant

### CAS pattern compliance (P1)
- `updateMany` calls without count checks
- State transitions without optimistic concurrency

### Inline cleanup anti-pattern (P1)
- Test files with inline `deleteMany` chains instead of centralized cleanup
- Inline cleanup with wrong FK ordering

### Over-engineering (P2)
- Abstractions wrapping single-use functions
- Factory/strategy patterns for 1-2 variants

### Code hygiene (P2)
- Unused imports, unused variables
- Dead code, commented-out code
- Console.log in production code

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
  Fix: Concrete, specific action (MANDATORY on every P0)

**P1 — WARNING (should fix)**
- [P1] [Category] Description
  File: path/to/file.ts:line
  Fix: Concrete, specific action (MANDATORY on every P1)

**P2 — SUGGESTION (nice to have)**
- [P2] [Category] Description

### Adversarial Challenges (prove these work)
- [C1] `file.ts:42` — How does this handle concurrent calls?
- [C2] `file.ts:87` — What if the API returns 500?

### VERDICT: SHIP / FIX FIRST / RETHINK

P0: N | P1: N | P2: N | Challenges: N
```

## Verdict Criteria

- **SHIP**: Zero P0, zero P1, all adversarial challenges have test coverage
- **FIX FIRST**: Any P0, or 2+ P1s, or adversarial challenge with no test
- **RETHINK**: 3+ P0s, or fundamental design violation (wrong auth, missing tenancy, no tests)

## Fix Line Requirement

**Every P0 and P1 finding MUST include a `Fix:` line** with a concrete, specific action. This enables the `/pr` automated review-fix loop to classify findings for auto-fix vs user intervention.

- Good: `Fix: Change findById to findByIdAndOrg with { where: { id, orgId } }`
- Good: `Fix: Add if (result.count === 0) throw new OrderNotFoundError(...) after updateMany`
- Bad: `Fix: Handle this properly` (too vague — /pr classifies as ASK_USER)
- Bad: (no Fix: line — /pr classifies as ASK_USER)

Findings without a concrete `Fix:` line are routed to the user for manual resolution.
