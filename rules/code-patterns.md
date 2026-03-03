# Code Patterns

Implementation patterns for correctness, safety, and maintainability.

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

<!-- CUSTOMIZE: Adapt the error code to your ORM (P2002 for Prisma, 23505 for raw PostgreSQL, etc.) -->
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

## Concurrency / Compare-and-Swap Pattern

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

Not all count=0 results are bugs. **Competitive state transitions** must throw on count=0. **Cleanup / terminal-state handlers** (e.g., marking a record FAILED after an error) may log and return because:

1. The original error is the important signal
2. count=0 means the entity was deleted concurrently, which is a valid terminal state

**Requirements for adding a CAS exception:**
1. Document the rationale in a code comment
2. A test must prove count=0 resolves without throwing
3. Track exceptions in a table for auditability

## Multi-Tenancy Query Pattern

<!-- CUSTOMIZE: Remove this section if you don't have multi-tenancy -->

Never trust ID alone. Always include the tenant identifier:
```typescript
// WRONG: allows cross-tenant access
await db.entity.findUnique({ where: { id } });

// CORRECT: always include tenant scope
await db.entity.findFirst({ where: { id, orgId } });
```

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
If a modification would push a function over a threshold, refactor first.
