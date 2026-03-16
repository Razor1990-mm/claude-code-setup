# Code Patterns

These patterns apply to all files. Root CLAUDE.md has the principles; this file has the implementation patterns.

## Database Client Parameter

<!-- CUSTOMIZE: Adapt to your ORM (Prisma, Drizzle, TypeORM, etc.) -->

**Composable domain functions** accept an optional database client parameter. Defaults to the singleton; pass a transaction client when needed:
```typescript
async function ensureRecord(id: string, db: DbClient = defaultClient) { ... }
```

**Transaction roots** (functions that create their own transaction) do NOT accept the db parameter. Adding it would cause nested transactions with different semantics.

## Typed Errors

Domain throws specific errors: `NotFoundError`, `ValidationError`, `ConflictError`, etc.
Controllers catch typed errors and map to HTTP status. Unexpected errors propagate as 500.

## Error Response Format

```json
{ "error": "Short message", "code": "ERROR_CODE", "details": {} }
```
- 400: Validation errors (include field details)
- 401: Auth failures (don't leak token existence)
- 404: Resource not found
- 500: Internal errors (log details, return generic message)

## Resource & Cost (Runaway Prevention)

| Issue | Rule |
|-------|------|
| External API calls | Must have timeouts (AbortController or equivalent) |
| Pagination | Must have MAX_LIMIT cap, not just default |
| Loops over external data | Must have max iteration limits |
| Database queries | No unbounded SELECT; always LIMIT |
| N+1 queries | Never query inside a loop |
| Retries | Exponential backoff + max attempts cap |
| WebSocket connections | Max concurrent limit + cleanup on close |

## Immutability

- Treat request payloads as immutable — don't mutate in place
- Return new objects over modifying shared references
- No mutable singletons for state (multi-instance reality)

## Idempotency Pattern

Catch unique constraint violations and re-fetch instead of failing:

<!-- CUSTOMIZE: Adapt error code to your ORM (P2002 for Prisma, 23505 for raw PostgreSQL, etc.) -->
```typescript
try {
  return await db.model.create({ ... });
} catch (error) {
  if (isDuplicateKeyError(error)) {
    return await db.model.findUnique({ ... }); // Re-fetch existing
  }
  throw error;
}
```
Use unique constraints on natural keys. Handle conflicts explicitly. Test idempotency: call twice, verify no duplicates.

## Concurrency / Compare-and-Swap (CAS) Pattern

All update operations used for state transitions MUST check the result count. Silent count=0 means the row vanished between read and write:

```typescript
// WRONG: silent no-op if entity deleted concurrently
await db.entity.updateMany({
  where: { id, status: "PENDING" },
  data: { status: "APPROVED" },
});

// CORRECT: fail-closed on concurrent deletion
const result = await db.entity.updateMany({
  where: { id, status: "PENDING" },
  data: { status: "APPROVED" },
});
if (result.count === 0) {
  throw new NotFoundError(`Entity ${id} not found or already transitioned`);
}
```

### CAS Exceptions: Cleanup / Terminal-State Handlers

Not all count=0 results are bugs. **Competitive state transitions** (e.g., PENDING -> APPROVED) must throw on count=0 because a silent no-op means lost work. **Cleanup / terminal-state handlers** (e.g., marking a record FAILED after an error) should log and return because:

1. The original error is the important signal — throwing from the cleanup handler masks it.
2. count=0 means the entity was deleted concurrently, which is a valid terminal state.
3. Callers `await` cleanup but treat the result as advisory.

<!-- CUSTOMIZE: Track your CAS exceptions here -->
**Requirements for adding a CAS exception:**
1. Document the rationale in a code comment (e.g., `DESIGN DECISION (CAS exception)`)
2. A test must prove count=0 resolves without throwing
3. Track exceptions in a table for auditability:

| Function | File | Why | Test |
|----------|------|-----|------|
| (example) `setFailed()` | `domain/processor.ts` | Best-effort terminal state; count=0 = deleted concurrently | INV-EMB11 |

## Multi-Tenancy Query Pattern

<!-- CUSTOMIZE: Remove this section if you don't have multi-tenancy -->

Never trust ID alone. Always include the tenant identifier:
```typescript
// WRONG: allows cross-tenant access
await db.entity.findUnique({ where: { id } });

// CORRECT: always include tenant scope
await db.entity.findFirst({ where: { id, orgId } });
```

### Multi-Tenancy Exceptions: Operational Tooling

Some operational scripts intentionally query across all tenants. These are NOT application request-path code. Each exception must have a DESIGN DECISION comment and an entry in this table.

<!-- CUSTOMIZE: Track your multi-tenancy exceptions here -->
| Function | File | Why | Test |
|----------|------|-----|------|
| (example) `validateDataCompatibility` | `scripts/migration-preflight.ts` | Pre-migration check must verify across ALL tenants | T5/T6 |

**Requirements for adding a new exception:**
1. JSDoc on the function must include `DESIGN DECISION (multi-tenancy exception)` with rationale
2. A test must prove the cross-tenant query is intentional and returns the correct shape
3. Add to the table above

## Composite Tenant FK Pattern

<!-- CUSTOMIZE: Remove if not using multi-tenancy or if your ORM handles this automatically -->

DB-level defense against cross-tenant data linkage. Every parent-child relationship uses a composite FK so the database rejects cross-tenant writes even if domain code has a bug.

**Step 1: Schema** — Add unique constraint on [id, orgId] to parent models:
```prisma
model Parent {
  id    String @id @default(cuid())
  orgId String
  @@unique([id, orgId])
}
```

**Step 2: Raw SQL migration** — Add composite FK:
```sql
-- For RESTRICT / CASCADE / NO ACTION:
ALTER TABLE "Child" ADD CONSTRAINT "Child_parentId_orgId_tenant_fk"
  FOREIGN KEY ("parentId", "orgId") REFERENCES "Parent"("id", "orgId")
  ON DELETE <match existing FK action> ON UPDATE CASCADE;

-- For SET NULL: MUST use column-specific syntax (parentId is nullable, orgId is NOT NULL):
ALTER TABLE "Child" ADD CONSTRAINT "Child_parentId_orgId_tenant_fk"
  FOREIGN KEY ("parentId", "orgId") REFERENCES "Parent"("id", "orgId")
  ON DELETE SET NULL ("parentId") ON UPDATE CASCADE;
```

**Critical rules:**
- ON DELETE action MUST match the existing simple FK's action
- **SET NULL FKs MUST use column-specific syntax:** `ON DELETE SET NULL ("fkColumn")` — never bare `SET NULL` on composite FKs
- Composite FKs are managed via raw SQL, never auto-generated by the ORM
- ORM migrations may drop composite FKs — always verify after migration changes
- New child models MUST include orgId and a composite tenant FK

**Naming convention:** `{ChildTable}_{fkColumn}_orgId_tenant_fk`

## Pattern Preferences

- **Decorator:** For cross-cutting concerns (logging, retries)
- **Factory:** When object creation has branching
- **Avoid:** Mutable singletons, hidden event chains

## Structural Complexity Bounds

When writing new code, target these thresholds:
- Functions: <80 lines of logic (excluding type definitions and docs)
- Parameters: <=5 (use an options object if you need more)
- Nesting: <=4 levels (extract early returns or helper functions)
- Cyclomatic complexity: <=12 (split into sub-functions at decision points)

When modifying existing code that exceeds these bounds, do not make it worse.

## Test Cleanup Ordering

<!-- CUSTOMIZE: Adapt to your ORM's FK behavior -->

When deleting test data, **order matters**. FK constraints require children deleted before parents. Use a centralized cleanup helper as the single source of truth for delete ordering. See `rules/testing.md` for details.
