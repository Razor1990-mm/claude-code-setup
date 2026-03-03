# Work Order Template

Use this when delegating a bounded slice of work to a specialist agent. Core value: tight scope, explicit file boundaries, invariant floor.

**Note:** Implementing agents already inherit TDD workflow, testing rules, and quality gates from your project rules. Do NOT restate those rules here — just reference the scope and boundaries.

## Template

```text
========================
WORK ORDER: <SLICE ID> — <SLICE TITLE>
========================

FILES YOU MAY TOUCH (ONLY THESE):
- <ALLOWLIST OF FILE PATHS>

DO NOT TOUCH:
- <OUT-OF-SCOPE AREAS>

REQUIREMENTS:
1) <REQUIREMENT 1>
2) <REQUIREMENT 2>
3) Output contract:
   - Input: <INPUT TYPE>
   - Output: <OUTPUT TYPE SHAPE>

MUST-COVER INVARIANTS (missing any = blocker):
- INV-1: <INVARIANT>
- INV-2: <INVARIANT>
- INV-3: <INVARIANT>
(Each must map to at least one test.)

WIRE-IN (MINIMAL):
- Entrypoint: <FILE + FUNCTION>
- Parse/validate: <WHAT>
- Call: <DOMAIN FUNCTION>

EDGE CASES:
- <EDGE CASE>
- If enum/status involved: enumerate ALL values + expected behavior
- If nullable field involved: specify null vs empty vs missing

STOP CONDITIONS:
- If you discover <OUT-OF-SCOPE THING>, STOP and report as blocker
- If any existing test breaks, STOP — fix the code, not the test

PROOF COMMANDS:
- <e.g., npm test>
- <e.g., npm run lint>
```

## Optional Sections (include only when applicable)

Add these ONLY when the slice actually needs them. Do not include with "N/A".

```text
API/ENV CONTRACT:
- Endpoints: <method path auth>
- Env vars: <name=default>
- Idempotency keys: <format>

ROLLBACK / KILL SWITCH:
- External effects: <what side effects occur>
- Kill switch: <how to disable>

LATENCY CONSTRAINTS:
- Webhook timeouts: <max duration>
- Request timeouts: <timeout value>

STATE MODEL:
- Initial: <STATE>
- Transitions: <STATE> -> <STATE> on <EVENT>
- Terminal: <STATE>
```

## Prep Checklist (for work order creator, not the implementer)

Before writing a work order:
- [ ] Read the sprint doc + slice reference
- [ ] Read 3-10 relevant source files
- [ ] Identify existing patterns to follow (cite file + function)
- [ ] Verify integration points (what existing code this connects to)
- [ ] Resolve open questions (don't delegate ambiguity)

## Example

```text
WORK ORDER: SLICE 1C — Enforce session ordering

FILES YOU MAY TOUCH (ONLY THESE):
- src/services/session.ts
- src/services/__tests__/session.test.ts
- src/server.ts

DO NOT TOUCH:
- src/api/*

REQUIREMENTS:
1) Implement pure session state machine: WAITING_FOR_START -> STARTED -> STOPPED
2) Reject operations before start
3) Reject duplicate start
4) Accept stop and close

MUST-COVER INVARIANTS:
- INV-1: Operation before START throws SessionNotStartedError
- INV-2: Duplicate START throws DuplicateStartError
- INV-3: STOP after STOPPED is idempotent (no-op, no throw)

EDGE CASES:
- CLOSE received in any state: always accepted (cleanup)

STOP CONDITIONS:
- If you need to buffer payloads, STOP (Slice 1D)

PROOF COMMANDS:
- npm test
```
