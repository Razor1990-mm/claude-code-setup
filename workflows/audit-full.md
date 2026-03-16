---
name: audit-full
description: Run full audit on entire codebase
model: sonnet
---

Run a comprehensive audit on the **entire codebase** combining security, project compliance, and cost checks.

**Usage:** `/audit-full`

For branch-only changes, use `/audit`.

## Scope

<!-- CUSTOMIZE: Replace with your project's source paths -->
Scans all code files in the repository:
- `src/**/*.ts`
- `src/**/*.tsx`

**Excludes:**
- `node_modules/`
- `dist/`, `build/`
- `**/__tests__/**`
- `*.test.ts`, `*.spec.ts`

## What It Runs

1. **Multi-Tenancy** — tenant filtering on all queries (P0 security)
2. **Security** — Auth, injection, secrets, data exposure
3. **Compliance** — Project rules compliance (domain boundary, idempotency, tests)
4. **Cost** — Resource limits, timeouts, unbounded operations

## Process

1. Glob all code files (excluding tests, build artifacts)
2. Launch sub-audits **in parallel** using the Task tool:
   - Agent 1: `/check-tenancy` on all domain files (P0)
   - Agent 2: `/security` checklist on all files
   - Agent 3: `/review` checklist on all files
   - Agent 4: Cost checklist (resource limits, timeouts, unbounded operations)
3. Collect results from all agents
4. Aggregate and deduplicate findings
5. Sort by severity (P0 tenancy first, then blocking, then warnings)

## Output Format

```
## Full Codebase Audit

### Coverage
- Total: <N> files scanned

### Summary
| Category | Pass | Fail | Warn |
|----------|------|------|------|
| Multi-Tenancy | N | N | N |
| Security | N | N | N |
| Compliance | N | N | N |
| Cost | N | N | N |

### BLOCKING (must fix)
- [Category] Description (severity)
  File: path:line
  Fix: action

### WARNINGS (should fix)
- [Category] Description (severity)
  File: path:line
  Fix: action

### PASSED (sample)
- [Category] What's working well
```

## When to Run

- Before major releases
- After large refactors
- Quarterly health check
- When onboarding to understand codebase state
