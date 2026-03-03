# Workflow: Code Audit

Multi-dimensional audit on current branch changes: security, rules compliance, cost, and code hygiene.

## Scope

Scans files changed on current branch (merge-base vs main). Filters to code files.

## What It Checks

1. **Multi-Tenancy** — tenant filtering on all queries (P0 security)
2. **Security** — Auth, injection, secrets, data exposure
3. **Rules Compliance** — project rules (domain boundary, idempotency, tests)
4. **Cost** — Resource limits, timeouts, unbounded operations
5. **Code Hygiene** — Hardcoded values, type safety, edge case coverage

### Code Hygiene Checks

**Hardcoded values:**
- Magic numbers > 1 outside const/type definitions
- Raw string literals matching status patterns ("PENDING", "APPROVED")
- Hardcoded timeouts instead of named constants
- Hardcoded URLs/paths that should be env vars

**Type safety:**
- `as any` usage without justifying comment
- Type assertions without null check
- Implicit `any` from untyped imports

**Edge case indicators:**
- Functions handling arrays with no empty-array test
- Nullable params with no null-handling test
- Numeric inputs with no boundary test

## Process

1. Get changed files on branch
2. Filter to code files (exclude docs, configs)
3. Run tenancy validator on changed domain files
4. If schema changed: validate cleanup ordering
5. Run security checklist
6. Run rules compliance checks
7. Run cost checklist (resource limits, timeouts, unbounded ops)
8. Run code hygiene checks
9. Aggregate, deduplicate, sort by severity

## Output Format

```
## Audit Results (Branch: <branch>)

### Files Scanned
- <file list>

### Summary
| Category | Pass | Fail | Warn |
|----------|------|------|------|
| Multi-Tenancy | N | N | N |
| Security | N | N | N |
| Compliance | N | N | N |
| Cost | N | N | N |
| Code Hygiene | N | N | N |

### BLOCKING (must fix before merge)
**[Category] Issue** (severity)
  File: path:line
  Fix: Concrete action

### WARNINGS (should fix)
...

### PASSED
- [Category] What passed
```

## Important: Audit vs. Proof Gates

**Audit is a review checklist, not a replacement for proof gates:**
- Run audit to catch issues before PR
- Do NOT skip proof gates (lint, typecheck, tests)
- Do NOT skip TDD proof (RED -> GREEN output)
