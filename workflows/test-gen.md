---
name: test-gen
description: Generate tests for a function or module
model: sonnet
---

Generate tests that match existing project patterns and support strict TDD (RED -> GREEN proof).

## Usage

- Single file: `/test-gen src/domain/jobs.ts`
- Multi-file list: `/test-gen --files src/domain/jobs.ts,src/domain/executor.ts`

**Non-goals (intentionally removed):**
- No sprint doc parsing
- No "auto-find the active sprint doc"
- No huge multi-page example outputs

## Output Requirements

For each input file (or each file in `--files`):
- **Detected type**: one of the types below
- **Suggested test location**: repo-relative path
- **Run command**: exact command to run the tests
- **Test plan**: MUST-COVER + any key comprehensive cases
- **Starter scaffold**: minimal (keep it small; outline more cases instead of dumping 500+ LOC)

### Guardrails (to prevent overbake)

- Prefer **test-plan bullets** over large generated code
- If the scaffold would be long, emit a **short stub** + a checklist of additional tests
- Multi-file mode should output:
  - A **unified test plan** first
  - Then **per-file** sections
- Do not invent new dependencies; use existing test framework patterns

## Type Detection (path-based)

<!-- CUSTOMIZE: Adapt paths and types to your project structure -->

### Backend
- `src/domain/**` -> **UNIT_TEST**
- `src/routes/**` -> **ROUTE_INTEGRATION_TEST** (check middleware chain for auth type)
- `src/__tests__/**` -> **DB_GATED_TEST** (requires env flag)

### Frontend
- `src/pages/**` -> **PAGE_COMPONENT_TEST**
- `src/components/**` -> **COMPONENT_TEST**
- `src/api/**` -> **API_CLIENT_TEST**
- `src/utils/**` -> **UTILITY_TEST**

## Test Placement Matrix

<!-- CUSTOMIZE: Adapt paths to your project structure -->

### Backend
- Unit tests: `src/domain/__tests__/[module].test.ts`
- DB-gated integration: `src/__tests__/[feature]-db.test.ts`
- Route integration: `src/__tests__/[feature]-route.test.ts`

### Frontend
- Pages: `src/pages/__tests__/[Page].test.tsx`
- Components: `src/components/__tests__/[Component].test.tsx`
- API: `src/api/__tests__/[client].test.ts`
- Utils: `src/utils/__tests__/[util].test.ts`

## MUST-COVER Checklist (default)

Every `/test-gen` output should include these categories unless explicitly N/A:

- **Happy path**: core behavior works
- **Input validation**: missing/invalid inputs are rejected safely
- **Failure modes**: downstream errors/timeouts handled safely (no crashes)
- **Idempotency/retry safety**: when relevant (webhooks, jobs, DB unique keys)
- **Security/PII**: no secrets/PII leaked (esp. logs/events)

See `rules/testing.md` for the full A-H category system.

## Test Cleanup Rules

<!-- CUSTOMIZE: Adapt to your ORM and cleanup patterns -->

**Always use a centralized cleanup helper for DB-gated tests.** Do NOT generate inline delete chains.

```typescript
import { cleanupTestData } from "./testHelpers.js";

afterAll(async () => {
  await cleanupTestData([TENANT_A.orgId, TENANT_B.orgId]);
});
```

If partial cleanup is needed between tests, the ordering MUST follow FK dependency constraints (children before parents).

## References

<!-- CUSTOMIZE: Point to your project's canonical test examples -->

Use existing test files as canonical examples (don't invent new styles):
- Backend integration patterns: `src/__tests__/integration-db.test.ts`
- Route test patterns: `src/__tests__/feature-route.test.ts`
- Frontend component tests: `src/components/__tests__/Example.test.tsx`
