---
name: tdd-workflow
description: TDD workflow - write failing tests (RED phase only)
model: opus
---

Enforce RED-first TDD by writing failing tests before any production code is touched. This skill handles the RED phase only — it does NOT write production code.

## Usage

```
/tdd-workflow src/domain/orders.ts
/tdd-workflow "order processing pipeline"
/tdd-workflow src/domain/orders.ts::processOrder
```

- Accepts a file path, a description, or a `file::function` target.
- RED phase only. Does NOT write production code.
- Does NOT modify existing tests. Existing `it()` blocks are sacred.

---

## 1. Pre-flight Checks (BLOCKING)

Before writing any tests, check whether production code for the target feature already exists.

### If input is a description (not a file path):
- Resolve to a concrete file path by searching the codebase. If ambiguous, ask the user.

### If production code already exists:
Check whether the specific functions/behavior being tested are already implemented (not just whether the file exists — new functions in an existing file are fine).

**If the target behavior is already implemented**, STOP and present:

```
BLOCKER: Production code already exists for this target.

Options:
1. PROCEED — I'm testing NEW behavior (delta) in this file, not the existing code
2. REVERT — I wrote code first by mistake. I'll revert, then re-run /tdd-workflow
3. USE /test-gen — I need retroactive tests for existing code (not TDD)
```

Wait for the user to choose before continuing.

### If production code does NOT exist (or user chose PROCEED):
Continue to Section 2.

---

## 2. Test Plan (invoke /test-gen)

Invoke `/test-gen <target>` via the Skill tool to get:
- Type detection (unit test, DB-gated integration test, route test, component test, etc.)
- Test file location
- Run command
- MUST-COVER test plan

Then apply the **Test Depth Checklist** (see Section 7 below) to filter applicable categories. Output a checklist:

```
Test Depth Checklist:
[x] A-MIN  — Minimal valid input
[x] A-TYP  — Typical input
[x] A-SIDE — Side-effect verification (Events created)
[x] A-RETURN — Return shape contract
[x] B      — Invalid input (missing tenant ID, null required fields)
[ ] A-MAX  — N/A (no numeric/array params)
[x] C-DUP  — Idempotency (unique constraint handling present)
[ ] D-PARALLEL — N/A (no CAS guard)
[x] E-DOWNSTREAM — External API call present
[ ] G-AUTH — N/A (domain function, not route)
[x] G-MT   — Multi-tenancy (tenant-scoped queries)
```

Each `[ ]` must have a justification for why it's N/A.

---

## 3. Write Test File

Write complete test bodies with real assertions. Follow these rules:

### Structure
- Use `[CAT-ID]` label convention in `it()` descriptions: `it("[A-MIN] creates with minimal input", ...)`
- Import from the production file path even if it doesn't exist yet (this is intentional — causes RED)
- Group tests in a `describe` block named after the target function or feature

### Patterns
- Follow existing patterns from reference files listed in `/test-gen` output
- For DB-gated tests: use centralized cleanup helpers, never inline `deleteMany`
- Use existing test helpers where applicable

### Existing test files
- If a test file already exists with existing tests: **append** a new `describe` block
- NEVER modify existing `it()` blocks — they are sacred

### What NOT to write
- No `it.todo()` stubs — write complete test bodies with real assertions
- No placeholder assertions like `expect(result).toBeDefined()` — assert exact shapes
- No production code — only test code

---

## 4. Run Tests — Capture RED Proof

<!-- CUSTOMIZE: Replace with your project's test commands -->
Run the tests using the appropriate command:

```bash
# Unit tests
npm test -- --reporter=verbose <test-file>

# DB-gated tests
RUN_DB_TESTS=1 npm test -- --reporter=verbose <test-file>

# Frontend tests
npm run test:frontend -- --reporter=verbose <test-file>
```

### Valid RED (expected — proceed to output):
- Module not found (production file doesn't exist yet)
- Function not exported / not a function
- Assertion failures (function exists but returns wrong values)

### Invalid RED (fix and re-run):
- Syntax errors in the test file itself
- Import typos (wrong path for test helpers, etc.)
- All tests pass (means production code already implements this — go back to pre-flight)

Fix any invalid RED issues and re-run until you get a valid RED result.

---

## 5. Write Marker + Output

### Write `.tdd-red-phase` marker file in project root:

```
tdd-red-phase
timestamp: <ISO 8601>
target: <production file path>
test-file: <test file path>
test-count: <number of test cases written>
categories: A-MIN,A-TYP,A-SIDE,...
```

### Output RED PROOF block:

Paste the full test output showing failures. Do not summarize.

```
RED PROOF:
──────────
<full test runner output with failures>
──────────
```

### Output GREEN PHASE handoff:

```
GREEN PHASE — Handoff Instructions
───────────────────────────────────
Target file: <production file path>
Test file:   <test file path>
Run command: <exact command to run tests>

Rules:
- Do NOT modify the test file
- Do NOT add new tests
- Write minimal code to make all <N> tests green
- Run the test command above to verify GREEN
```

---

## 6. Pipeline Integration

This skill fits into the TDD pipeline as follows:

```
/tdd-workflow (RED) → writes tests + .tdd-red-phase marker
      |
      v
write production code (GREEN) — make tests pass
      |
      v
/commit → git hook runs lint + typecheck + tests
      |
      v
/pr → automated review-fix loop (when ready for PR)
```

The `.tdd-red-phase` marker records that TDD was followed for the current feature.

---

## 7. Test Sub-Pattern Reference

### A: Happy Path Sub-Patterns

Every domain function must cover at least A-MIN + A-TYP + A-SIDE + A-RETURN:

| ID | Sub-Pattern | Description |
|----|-------------|-------------|
| A-MIN | Minimal valid input | Smallest payload that should succeed. For 1-2 param functions, A-MIN and A-TYP may be the same test. |
| A-TYP | Typical input | Representative real-world payload |
| A-MAX | Maximal valid input | Largest valid payload. Required when function accepts numeric or array inputs. |
| A-SIDE | Side-effect verification | Verify ALL side effects: Events created, audit logs written, related records updated. Not just the return value. |
| A-RETURN | Return shape contract | Assert exact return shape (`result.status === "APPROVED"`), never just `toBeDefined()` |

### B: Input Validation Sub-Patterns

| ID | Sub-Pattern | When Required |
|----|-------------|---------------|
| B-ENUM | Enum coverage | Function accepts enum param -> test at least 2 valid values + 1 invalid string |
| B-BOUNDS | Numeric boundaries | Function accepts number -> test 0, boundary value, boundary+1 |
| B-STRING | String edge cases | Function accepts string -> test empty, whitespace-only, max-length if defined |

### D: Concurrency Sub-Patterns

| ID | Pattern | Test Shape | When Required |
|----|---------|------------|---------------|
| D-PARALLEL | Two identical calls | `Promise.all([fn(args), fn(args)])` -> both resolve, same ID, exactly 1 Event | Function has unique constraint handling or CAS guard |
| D-TXISO | Transaction rollback | Make step N fail inside transaction -> verify steps 1..N-1 NOT persisted | Function uses DB transactions or multi-step DB writes |
| D-CAS | Compare-and-swap | Call fn, then call again with stale state -> expect conflict error | Function uses `updateMany` with state guard in `where` |

**D-PARALLEL template:**
```typescript
it("[D-PARALLEL] concurrent calls produce exactly one record", async () => {
  const [r1, r2] = await Promise.all([
    createOrFetch({ orgId, key }),
    createOrFetch({ orgId, key }),
  ]);
  expect(r1.id).toBe(r2.id); // Same record
  // Verify no duplicate side effects
});
```

**D-TXISO template:**
```typescript
it("[D-TXISO] rolls back all writes when step fails mid-transaction", async () => {
  await expect(fnWithTransaction(inputThatFailsAtStep2)).rejects.toThrow();
  const records = await db.entity.count({ where: { ... } });
  expect(records).toBe(0); // Step 1 writes rolled back
});
```

### E: Failure Mode Sub-Patterns

| Code Type | Error Type | Safe State | Test Assertion |
|-----------|-----------|-----------|----------------|
| Webhook handler | Known-bad input | Returns 200 + fail-closed response + logs warning | `expect(res.status).toBe(200)` |
| Webhook handler | Unexpected error | Returns 500 + generic message (triggers retry) | `expect(res.status).toBe(500)` |
| Domain function | Any error | Throws typed error (never generic Error) | `rejects.toThrow(SpecificError)` |
| Domain function with DB | Any error | Throws typed error + no partial writes | Same + verify zero new records |
| External API caller | Downstream failure | Throws typed error or failure result + no runaway retries | `result.success === false` |
| State machine transition | Invalid transition | Stays at current state | Entity state unchanged |

| ID | Sub-Pattern | When Required |
|----|-------------|---------------|
| E-DOWNSTREAM | Mock external dependency to throw/timeout, verify safe state | Function calls another service or external API |
| E-TIMEOUT | Abort AbortController mid-execution, verify clean exit | Function uses AbortController or retry helpers |
| E-EXHAUSTED | Max retries exceeded, verify clear error (not hang) | Function has retry logic |
| E-LEAK | Error response contains no internals | Function returns error responses to external callers |

### F: Observability Sub-Patterns

| ID | Sub-Pattern | Assertion |
|----|-------------|-----------|
| F-EVENT | Event written with required fields | `expect.objectContaining({ orgId, entityType, entityId, eventType })` |
| F-AUDIT | Audit log has actor + action | `expect.objectContaining({ orgId, actorId, action })` |
| F-NO-PII | No PII in payloads or logs | Include canary values in input. Verify none appear in event payloads, audit entries, OR console output. |
| F-CORR | Correlation ID propagated | If function accepts correlationId, verify it reaches event metadata |

### G-AUTH: Fail-Closed Auth Sub-Patterns

| ID | Pattern | Expected |
|----|---------|----------|
| G-AUTH-1 | Missing credentials entirely | 401 (not 500, not silent bypass) |
| G-AUTH-2 | Invalid/malformed credentials | 401 or 403 |
| G-AUTH-3 | Missing config env var | 500 (config error, fail-closed) |
| G-AUTH-4 | Expired credentials | 401 |

### G-MT: Multi-Tenancy Sub-Patterns

For tenant-scoped endpoints, **at least 2 required** from:

| ID | Pattern | Expected |
|----|---------|----------|
| G-MT-1 | Cross-tenant READ | 404, no existence leak |
| G-MT-2 | Cross-tenant LIST | Returns only own tenant's records |
| G-MT-3 | Cross-tenant MUTATION | 404, no state change |
| G-MT-4 | Response verification | response.orgId matches request |

### Test Depth Checklist (RED Phase Gate)

Before handing off to GREEN, verify applicable items are covered:

**Mandatory (every domain function):**
- [ ] A-MIN: Minimal valid input tested
- [ ] A-TYP: Typical input tested
- [ ] A-SIDE: All side effects verified
- [ ] A-RETURN: Exact return shape asserted (no `toBeDefined()`)
- [ ] B: At least one invalid input per required parameter

**Conditional (check if applicable):**
- [ ] A-MAX: Maximal valid input (if numeric/array params exist)
- [ ] B-ENUM: 2 valid + 1 invalid (if enum params exist)
- [ ] B-BOUNDS: 0, boundary, boundary+1 (if numeric params with thresholds)
- [ ] C-DUP: Duplicate call idempotency (if unique constraint handling exists)
- [ ] D-PARALLEL: Promise.all race (if unique constraint or CAS guard exists)
- [ ] D-TXISO: Transaction rollback (if transactions used)
- [ ] E-DOWNSTREAM: External dependency failure (if external calls made)
- [ ] E-TIMEOUT: AbortController abort (if AbortController used)
- [ ] E-LEAK: Error response sanitized (if function returns errors to external callers)
- [ ] F-NO-PII: Canary string PII check (if function writes events/audit logs)
- [ ] G-MT: At least 2 of G-MT-1/2/3/4 (if function accepts orgId or queries tenant-scoped tables)
- [ ] G-AUTH: Fail-closed auth (if function is behind auth middleware)

**Label convention:** Use `[CAT-ID]` prefix in `it()` descriptions for grepability.
