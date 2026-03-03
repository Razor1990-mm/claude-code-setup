# Workflow: Generate Tests

Generate tests that match existing project patterns and support TDD.

## Usage

Provide a file path or comma-separated file list.

## Output Requirements

For each input file:
- **Detected type**: Unit test or integration test (based on file location)
- **Suggested test location**: Following project conventions
- **Run command**: Exact command to run the tests
- **Test plan**: MUST-COVER categories + key comprehensive cases
- **Starter scaffold**: Minimal (outline more cases instead of dumping large code blocks)

### Guardrails

- Prefer **test-plan bullets** over large generated code
- If the scaffold would be long, emit a **short stub** + a checklist of additional tests
- Do not invent new dependencies; use existing test framework patterns

## Test Placement

<!-- CUSTOMIZE: Adapt to your project structure -->

**Unit tests** (colocated with domain):
- Domain logic: `src/domain/__tests__/[module].test.ts`

**Integration tests** (separate, gated):
- DB-gated: `src/__tests__/[feature].db.test.ts`
- Route: `src/__tests__/[feature].route.test.ts`

## MUST-COVER Checklist

Every test generation output should include these categories unless explicitly N/A:

- **Happy path**: core behavior works
- **Input validation**: missing/invalid inputs rejected safely
- **Failure modes**: downstream errors/timeouts handled safely
- **Idempotency/retry safety**: when relevant (webhooks, unique keys)
- **Security/PII**: no secrets/PII leaked in logs/events

See `rules/testing.md` for the full A-H category system.
