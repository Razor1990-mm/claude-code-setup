# Testing Rules

TDD philosophy, test categories, and depth checklist.

## Circular Validation Warning

Tests prove **internal consistency**, not external correctness. Implementation and tests can both be wrong consistently:
- Implementation: "Signature verified" / Test: "Mock signature passes" / Reality: Real signature fails

**The fix:** Unit/integration tests verify domain logic, transactions, multi-tenancy. **Manual validation** is required for external integrations before production.

**Red flags (AI-generated code):**
- "All tests pass" but no real external system tested
- "Auth works" but only tested with dev fallback headers
- High test coverage but zero external system integration

## Existing Tests Are Sacred (HARD RULE)

**NEVER modify existing tests to make new code pass.** If your implementation breaks an existing test, the implementation is wrong — not the test. Tests define the contract; the code must satisfy them.

- If an existing test fails after your change: **revert your change and fix the implementation.**
- If you believe an existing test is genuinely wrong: **STOP. Report as BLOCKER.** Do not "fix" the test yourself.
- **No exceptions.** Not "just updating the expected value." Not "the test was outdated." Not "the interface changed." BLOCKER.

## TDD Workflow

Write tests first. Always.

**When TDD applies:** Domain logic, API endpoints, state machines, multi-tenancy enforcement, idempotency behavior.
**When TDD doesn't apply:** Exploratory spikes, pure refactoring with existing coverage, documentation-only, trivial one-liners.

### Condensed Example

<!-- CUSTOMIZE: Adapt to your language/framework -->
```typescript
// RED — write the test first
describe('ensureRecordReady', () => {
  it('should throw when record missing required field', async () => {
    const record = await createTestRecord({ address: null });
    await expect(
      ensureRecordReady(record.id, TEST_ORG_ID)
    ).rejects.toThrow('Record missing required field: address');
  });
});
// Run → FAIL (proves test catches errors)

// GREEN — write the production code
export async function ensureRecordReady(
  recordId: string, orgId: string, db: DbClient = defaultClient
): Promise<Record> {
  const record = await db.record.findFirst({ where: { id: recordId, orgId } });
  if (!record) throw new NotFoundError(recordId);
  if (!record.address)
    throw new ValidationError('Record missing required field: address');
  return record;
}
// Run → PASS
```

## Test Layout

<!-- CUSTOMIZE: Adapt paths to your project structure -->

**Unit tests** (colocated with domain code):
- Pure domain logic, no database. Deterministic, fast.
- Use mocks when needed.
- Example: validation rules, business logic, pure functions.

**Integration tests** (separate directory or gated by env var):
- Real database client, no mocks.
- Test DB constraints, idempotency, concurrency, webhooks, multi-tenancy.
- Example: unique constraint handling, transaction isolation, tenant filtering.

**Decision guide:**
- Idempotency/retries/webhooks → Integration (mocks can't catch real constraint behavior)
- Concurrency/races → Integration (need real transaction isolation)
- Multi-tenancy → Integration (need real tenant filtering)
- Pure validation/calculation → Unit test

## MUST-COVER Test Categories (A-H)

Every implementation MUST have tests for applicable categories:

| Cat | Name | Given | Expect |
|-----|------|-------|--------|
| A | Happy path | Valid inputs, normal conditions | Correct output, expected side effects |
| B | Input validation | Null, undefined, empty string, wrong type | Throws ValidationError, no side effects |
| C | Idempotency* | Duplicate delivery, same idempotency key | No duplicate writes, safe replay |
| D | Concurrency* | Two requests at once, out-of-order events | Deterministic result, one winner |
| E | Failure modes | Downstream fails, times out, disconnects | Graceful degradation, safe state |
| F | Observability | A path that logs | Structured fields present, no PII |
| G | Security* | Bypass attempt, missing auth, invalid token | Deny with safe error, no data leak |
| H | Compatibility* | Old payload format, old client version | Backwards compat or safe failure |

*Categories marked with * apply conditionally.

### A: Happy Path Sub-Patterns

Every domain function must cover at least A-MIN + A-TYP + A-SIDE + A-RETURN:

| ID | Sub-Pattern | Description |
|----|-------------|-------------|
| A-MIN | Minimal valid input | Smallest payload that should succeed |
| A-TYP | Typical input | Representative real-world payload |
| A-MAX | Maximal valid input | Largest valid payload (required when function accepts numeric or array inputs) |
| A-SIDE | Side-effect verification | Verify ALL side effects: events created, logs written, related records updated |
| A-RETURN | Return shape contract | Assert exact return shape, never just `toBeDefined()` |

### B: Input Validation Sub-Patterns

| ID | Sub-Pattern | When Required |
|----|-------------|---------------|
| B-ENUM | Enum coverage | Function accepts enum param → test valid values + 1 invalid |
| B-BOUNDS | Numeric boundaries | Function accepts number → test 0, boundary, boundary+1 |
| B-STRING | String edge cases | Function accepts string → test empty, whitespace-only |

### D: Concurrency Sub-Patterns

| ID | Pattern | When Required |
|----|---------|---------------|
| D-PARALLEL | Two identical calls via Promise.all → same ID, exactly 1 side effect | Function has duplicate-key handling or CAS guard |
| D-TXISO | Transaction rollback: fail mid-transaction → verify partial writes rolled back | Function uses database transactions |
| D-CAS | Compare-and-swap: call with stale state → expect conflict error | Function uses conditional updates |

### E: Failure Mode Sub-Patterns

| ID | Sub-Pattern | When Required |
|----|-------------|---------------|
| E-DOWNSTREAM | Mock external dependency to throw/timeout, verify safe state | Function calls external service |
| E-TIMEOUT | Abort mid-execution, verify clean exit | Function uses timeouts or AbortController |
| E-EXHAUSTED | Max retries exceeded, verify clear error | Function has retry logic |
| E-LEAK | Error response contains no internals | Function returns errors to external callers |

### G: Security Sub-Patterns

**G-AUTH: Fail-Closed Auth** (for auth-protected endpoints):

| ID | Pattern | Expected |
|----|---------|----------|
| G-AUTH-1 | Missing credentials entirely | 401 (not 500, not silent bypass) |
| G-AUTH-2 | Invalid/malformed credentials | 401 or 403 |
| G-AUTH-3 | Missing config env var | 500 (config error, fail-closed) |
| G-AUTH-4 | Expired credentials | 401 |

**G-MT: Multi-Tenancy** (for tenant-scoped endpoints, at least 2 required):

| ID | Pattern | Expected |
|----|---------|----------|
| G-MT-1 | Cross-tenant READ | 404, no existence leak |
| G-MT-2 | Cross-tenant LIST | Returns only own tenant's records |
| G-MT-3 | Cross-tenant MUTATION | 404, no state change |
| G-MT-4 | Response verification | response.orgId matches request |

## Test Depth Checklist (Before Shipping)

**Mandatory (every domain function):**
- [ ] A-MIN: Minimal valid input tested
- [ ] A-TYP: Typical input tested
- [ ] A-SIDE: All side effects verified
- [ ] A-RETURN: Exact return shape asserted
- [ ] B: At least one invalid input per required parameter

**Conditional (check if applicable):**
- [ ] A-MAX: Maximal valid input (if numeric/array params)
- [ ] B-ENUM: Valid + invalid enum values (if enum params)
- [ ] B-BOUNDS: Boundary values (if numeric params with thresholds)
- [ ] C-DUP: Duplicate call idempotency (if duplicate-key handling)
- [ ] D-PARALLEL: Race condition (if CAS or duplicate-key guard)
- [ ] D-TXISO: Transaction rollback (if transactions used)
- [ ] E-DOWNSTREAM: External dependency failure (if external calls)
- [ ] E-LEAK: Error response sanitized (if errors returned to callers)
- [ ] G-MT: At least 2 multi-tenancy patterns (if tenant-scoped)
- [ ] G-AUTH: Fail-closed auth (if auth middleware)

**Label convention:** Use `[CAT-ID]` prefix in test descriptions for grepability:
```typescript
it("[A-MIN] creates record with minimal input", ...)
it("[D-TXISO] rolls back on mid-transaction failure", ...)
it("[E-DOWNSTREAM] handles timeout from external service", ...)
```

## Touch-It-Test-It Policy

| File status | Requirement |
|---|---|
| New domain file | Full depth checklist (no exceptions) |
| Modified domain file with no existing tests | Add A-TYP + B + G-MT-1 minimum |
| Unmodified domain file | No requirement. Track for future coverage. |

## Test Cleanup

<!-- CUSTOMIZE: Adapt to your ORM's FK behavior -->

When deleting test data, **order matters**. FK constraints require children deleted before parents. Use a centralized cleanup helper as the single source of truth for delete ordering.

**Rules:**
1. Use a centralized cleanup function for full tenant cleanup
2. If cleaning up a subset, respect FK ordering (children before parents)
3. When adding a new model, add it to the cleanup function at the correct depth
