---
name: check-tenancy
description: Multi-tenancy validator — scan for missing tenant filters
---

Scan domain files for missing tenant filters — critical P0 security issues.

<!-- CUSTOMIZE: This workflow assumes multi-tenancy with an orgId field. Adapt the field name, query patterns, and ORM methods to your stack. -->

**Usage:**
- `/check-tenancy <file>` — scan a specific domain file
- `/check-tenancy --schema` — schema blast radius mode

## What It Checks

### 1. Queries Must Include Tenant Filter

```typescript
// WRONG:
await db.entity.findUnique({ where: { id } });

// CORRECT:
await db.entity.findFirst({ where: { id, orgId } });
```

### 2. All List Queries Must Filter by Tenant

```typescript
// WRONG:
await db.entity.findMany({ where: { status: 'ACTIVE' } });

// CORRECT:
await db.entity.findMany({ where: { status: 'ACTIVE', orgId } });
```

### 3. Updates/Deletes Must Be Tenant-Scoped

```typescript
// WRONG:
await db.entity.update({ where: { id }, data: { ... } });

// CORRECT:
await db.entity.updateMany({ where: { id, orgId }, data: { ... } });
```

### 4. Creates Must Include Tenant ID

```typescript
// WRONG:
await db.entity.create({ data: { name } });

// CORRECT:
await db.entity.create({ data: { name, orgId } });
```

### 5. Schema Blast Radius (FK Dependency Graph)

**Triggered when:** Schema file is in the diff, OR `--schema` flag is used.

Validates the FK dependency graph — the ordering of delete operations in test cleanup code.

**What it does:**

1. **Parse FK graph** from schema:
   - Read all relation directives to build parent-child map
   - Identify ON DELETE actions (Cascade, SetNull, Restrict, NoAction)
   - Compute topological sort (canonical delete ordering)

2. **Validate cleanup helper**:
   - Verify every model appears in the cleanup function
   - Verify delete order matches topological sort
   - Report any missing models or ordering violations

3. **Scan test files for inline cleanup**:
   - Search test files for inline delete calls
   - Verify ordering against FK graph
   - Flag files that should use the centralized cleanup helper instead

### 6. Composite Tenant FK Coverage

Verify that every parent-child FK relationship with tenant ID has a composite tenant FK:
- Check for composite unique constraints on parent models
- Cross-reference against composite FK count

## Execution Logic

### Standard mode (file-scoped)
1. Read the specified file
2. Search for ORM operations (find, update, delete, create)
3. For each operation, check if tenant filter is in the where clause
4. Report violations with line numbers
5. Check for cross-tenant test cases

### Schema mode (blast radius)
1. Read schema, build FK dependency graph
2. Compute canonical delete ordering (topological sort)
3. Validate cleanup helper matches canonical ordering
4. Scan ALL test files for inline delete patterns
5. Check composite FK coverage

## Output Format

### Standard mode
```
Multi-Tenancy Validation: src/domain/jobs.ts

All queries include tenant filtering.
No cross-tenant violations found.

--- OR ---

Multi-Tenancy Violations Found: src/domain/jobs.ts

Line 45: findUnique without tenant filter
  Fix: Use findFirst with tenant ID

Line 89: findMany missing tenant filter
  Fix: Add tenant ID to where clause

No cross-tenant tests found
  Recommendation: Add test with different tenant IDs to verify isolation
```

### Schema blast radius mode
```
Schema Blast Radius Analysis

FK Dependency Graph: N models, N composite tenant FKs
Canonical delete ordering: [topological sort list]

Cleanup Helper Validation:
  All N models present
  Ordering matches canonical sort

Inline Cleanup Audit:
  N files with inline delete patterns

  VIOLATIONS (wrong ordering):
  - test-file.test.ts:60 — deletes Parent before Child
    Fix: Move Child delete before Parent delete

  WARNINGS (should use centralized helper):
  - N files with 5+ inline deletes — migrate to cleanup helper

Composite FK Coverage:
  N/N FKs present
```

## When to Auto-Trigger
- After editing any domain file
- Before commits that modify domain files
- After schema changes (auto-triggers schema blast radius mode)
- Before PRs that touch domain logic or schema
