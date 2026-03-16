---
name: codex-cto-parallel
description: Run Codex CTO plan reviews in parallel for multiple spec/plan files, then consolidate verdicts
model: sonnet
---

Run `/codex-cto` style plan review across multiple files concurrently and return one consolidated report.

**Usage:**
- `/codex-cto-parallel specs/sprint-*.md`
- `/codex-cto-parallel specs/feature-auth.md specs/feature-billing.md`

## Inputs

1. Resolve arguments as file globs
2. Keep only existing markdown files
3. If no files match, return `SKIPPED — no matching plan/spec files`

## Parallel Execution

For each resolved file, run one independent Codex CTO review in parallel (same rubric as `/codex-cto` plan mode).

<!-- CUSTOMIZE: Replace invariants with your project's -->
```bash
codex exec --json --full-auto "$(cat <<'PROMPT'
You are the CTO advisor reviewing a plan BEFORE implementation begins.
Read this plan file and evaluate feasibility, file boundaries, invariant coverage, and acceptance criteria.

PLAN_FILE: <INSERT_PLAN_PATH>

PROJECT INVARIANTS (P0):
- Tenant-scoped queries (multi-tenancy)
- Idempotency (unique constraint catch-and-refetch)
- CAS updateMany count checks
- Append-only event/audit logs
- Fail-closed auth
- Thin controllers / fat domain
- Existing tests are sacred

Return EXACT format:
VERDICT: PROCEED | SIMPLIFY | RE-PLAN
CONFIDENCE: HIGH | MEDIUM | LOW
FEASIBILITY CONCERNS:
- [P0/P1/P2] ...
FILE BOUNDARY VALIDATION:
- Files plan says to touch: ...
- Files that actually need touching: ...
- Missing files: ...
- Unnecessary files: ...
INVARIANT COVERAGE CHECK:
- [ ] ...
ACCEPTANCE CRITERIA GAPS:
- ...
HIDDEN ASSUMPTIONS:
- ...
ALTERNATIVE APPROACHES:
- ...
PROMPT
)"
```

Replace `<INSERT_PLAN_PATH>` with each file path.

## Consolidation Output

After all parallel reviews finish, output:

1. **Per-file verdict table:**
   | File | Verdict | Confidence | P0s | P1s |
   |------|---------|------------|-----|-----|

2. **Blockers summary:** All P0s grouped by file

3. **Merge recommendation:**
   - `ALL CLEAR` if all PROCEED
   - `HOLD` if any SIMPLIFY/RE-PLAN

## Rules

- Do not modify code
- Include each file's raw reviewer output
- If one review fails (timeout/auth), continue others and mark `SKIPPED`
- Default timeout per file: 240s
