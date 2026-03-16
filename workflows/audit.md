---
name: audit
description: Run full audit on current branch changes
model: sonnet
---

Run a comprehensive audit on **current branch/sprint changes** combining security, rules review, and cost checks.

**Usage:** `/audit`

For full codebase scan, use `/audit-full`.

## Scope

Scans files changed on current branch using merge-base vs `BASE_REF` (default `origin/main`, fallback `main`) plus current working-tree changes:
- `git diff --name-only "$MERGE_BASE"..HEAD` + unstaged/staged/untracked union
- Filters to code files (`.ts`, `.tsx`, `.js`, `.jsx`)

## What It Runs

<!-- CUSTOMIZE: Adapt categories to your project's priorities -->
1. **Multi-Tenancy** — tenant filtering on all queries (P0 security)
2. **Security** — Auth, injection, secrets, data exposure
3. **Rules Compliance** — project rules (domain boundary, idempotency, tests)
4. **Cost** — Resource limits, timeouts, unbounded operations
5. **Code Hygiene** — Hardcoded values, `as any` usage, edge case coverage

### Code Hygiene Checks

**Hardcoded values:**
- Magic numbers > 1 outside const/type definitions
- Raw string literals matching status patterns (`"PENDING"`, `"APPROVED"`)
- Hardcoded timeouts (raw `5000` instead of `TIMEOUT_MS`)
- Hardcoded URLs/paths that should be env vars

**Type safety:**
- `as any` usage without justifying comment
- Type assertions (`as SomeType`) without null check
- Implicit `any` from untyped imports

**Edge case indicators:**
- Functions handling arrays with no empty-array test
- Nullable params with no null-handling test
- Numeric inputs with no boundary test (0, negative, max)

## Process

1. Get changed files on branch using merge-base (`BASE_REF` default `origin/main`, fallback `main`) + unstaged/staged/untracked union
2. Filter to code files (exclude docs, configs, tests)
3. **Run `/check-tenancy` on changed domain files** (P0 — multi-tenancy violations)
4. **If schema changed**: Run `/check-tenancy --schema` (schema blast radius mode — validates cleanup ordering)
5. Run `/security` checklist on changed files
6. Run `/review` checklist on changed files
7. Run cost checklist on changed files (resource limits, timeouts, unbounded operations)
8. Run Code Hygiene checks on changed files
9. Aggregate and deduplicate findings
10. Sort by severity

## Output Format

<!-- CUSTOMIZE: Replace example paths with your project structure -->
```
## Audit Results (Branch: feature/xyz)

### Files Scanned
- src/domain/dashboard.ts
- src/controllers/dashboard.ts

### Summary
| Category | Pass | Fail | Warn |
|----------|------|------|------|
| Multi-Tenancy | 5 | 0 | 0 |
| Security | 12 | 1 | 2 |
| Compliance | 8 | 0 | 1 |
| Cost | 10 | 2 | 0 |
| Code Hygiene | 6 | 1 | 2 |

### BLOCKING (must fix before merge)

**[Security] Missing auth check** (HIGH)
  File: src/routes/api.ts:45
  Fix: Add auth middleware

**[Cost] Unbounded loop** (HIGH)
  File: src/domain/sync.ts:89
  Fix: Add iteration limit

### WARNINGS (should fix)

**[Compliance] Missing test coverage**
  File: src/domain/feature.ts
  Fix: Add test for edge case X

**[Code Hygiene] `as any` without justification**
  File: src/domain/jobs.ts:42
  Fix: Add type annotation or justifying comment

### PASSED
- [Security] Auth required on all protected endpoints
- [Security] Parameterized queries used
- [Compliance] Domain boundary respected
- [Compliance] Idempotency patterns correct
- [Cost] Pagination limits enforced
```

## When to Run

- Before creating PRs
- End of sprint
- After major refactors

## Important: Audit vs. Proof Gates

**`/audit` is a review checklist, not a replacement for proof gates:**
- Run `/audit` to catch issues before PR
- Do NOT skip proof gates (lint, typecheck, tests)
- Do NOT skip TDD proof checkpoint (RED -> GREEN output)

**Workflow:**
1. Write tests first (TDD RED phase)
2. Implement feature (TDD GREEN phase)
3. Run proof gates (lint, typecheck, test)
4. Run `/audit` (review + security + cost)
5. Create PR with proof output + audit results
