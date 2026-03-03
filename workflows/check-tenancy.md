# Workflow: Multi-Tenancy Validator

Scan domain files for missing tenant filters — critical P0 security issues.

<!-- CUSTOMIZE: This workflow assumes multi-tenancy with an orgId field. Adapt the field name and query patterns to your ORM. -->

## What It Checks

### 1. Queries Must Include Tenant Filter
```
// WRONG:
await db.entity.findUnique({ where: { id } });

// CORRECT:
await db.entity.findFirst({ where: { id, orgId } });
```

### 2. All List Queries Must Filter by Tenant
```
// WRONG:
await db.entity.findMany({ where: { status: 'ACTIVE' } });

// CORRECT:
await db.entity.findMany({ where: { status: 'ACTIVE', orgId } });
```

### 3. Updates/Deletes Must Be Tenant-Scoped
```
// WRONG:
await db.entity.update({ where: { id }, data: { ... } });

// CORRECT:
await db.entity.updateMany({ where: { id, orgId }, data: { ... } });
```

## Process

### Standard mode (file-scoped)
1. Read the specified file
2. Search for database operations (find, update, delete, create)
3. For each operation, check if tenant filter is in the where clause
4. Report violations with line numbers
5. Check for cross-tenant test cases

### Schema mode (if schema changed)
1. Parse schema, build FK dependency graph
2. Validate cleanup helper matches canonical ordering
3. Scan test files for inline cleanup with wrong ordering
4. Check composite FK coverage

## Output Format

```
Multi-Tenancy Validation: <file>

All queries include tenant filtering.
No cross-tenant violations found.

--- OR ---

Multi-Tenancy Violations Found: <file>

Line 45: findUnique without tenant filter
  Fix: Use findFirst with tenant ID

Line 89: findMany missing tenant filter
  Fix: Add tenant ID to where clause
```

## When to Run
- After editing any domain file
- Before commits that modify domain files
- After schema changes (schema mode)
- Before PRs that touch domain logic
