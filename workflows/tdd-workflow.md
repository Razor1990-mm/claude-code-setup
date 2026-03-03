# Workflow: TDD (RED Phase Only)

Enforce RED-first TDD by writing failing tests before any production code is touched. This workflow handles the RED phase only — it does NOT write production code.

## Usage

Provide a file path, a description, or a `file::function` target.

- RED phase only. Does NOT write production code.
- Does NOT modify existing tests. Existing test cases are sacred.

---

## 1. Pre-flight Checks (BLOCKING)

Before writing any tests, check whether production code for the target feature already exists.

### If input is a description (not a file path):
- Resolve to a concrete file path by searching the codebase. If ambiguous, ask the user.

### If production code already exists:
Check whether the specific functions/behavior being tested are already implemented.

**If the target behavior is already implemented**, STOP and present:

```
BLOCKER: Production code already exists for this target.

Options:
1. PROCEED — I'm testing NEW behavior (delta) in this file, not the existing code
2. REVERT — I wrote code first by mistake. I'll revert, then re-run TDD workflow
3. RETROACTIVE — I need tests for existing code (not TDD)
```

Wait for the user to choose before continuing.

---

## 2. Test Plan

For the target, determine:
- **Test type**: Unit test or integration test (see `rules/testing.md` for decision guide)
- **Test file location**: Following project conventions
- **Run command**: The exact command to run the tests
- **MUST-COVER categories**: Apply the Test Depth Checklist from `rules/testing.md`

Output a checklist:

```
Test Depth Checklist:
[x] A-MIN  — Minimal valid input
[x] A-TYP  — Typical input
[x] A-SIDE — Side-effect verification
[x] A-RETURN — Return shape contract
[x] B      — Invalid input (missing required fields, null)
[ ] A-MAX  — N/A (no numeric/array params)
[x] C-DUP  — Idempotency (duplicate-key handling present)
[ ] D-PARALLEL — N/A (no CAS guard)
[x] E-DOWNSTREAM — External API call present
[ ] G-AUTH — N/A (domain function, not route)
[x] G-MT   — Multi-tenancy (tenant-scoped queries)
```

Each unchecked item must have a justification for why it's N/A.

---

## 3. Write Test File

Write complete test bodies with real assertions.

### Structure
- Use `[CAT-ID]` label convention in test descriptions: `it("[A-MIN] creates with minimal input", ...)`
- Import from the production file path even if it doesn't exist yet (this is intentional — causes RED)
- Group tests in a `describe` block named after the target function or feature

### What NOT to write
- No `it.todo()` stubs — write complete test bodies with real assertions
- No placeholder assertions like `expect(result).toBeDefined()` — assert exact shapes
- No production code — only test code

---

## 4. Run Tests — Capture RED Proof

Run the tests using the appropriate command.

### Valid RED (expected — proceed):
- Module not found (production file doesn't exist yet)
- Function not exported / not a function
- Assertion failures (function exists but returns wrong values)

### Invalid RED (fix and re-run):
- Syntax errors in the test file itself
- Import typos (wrong path for test helpers, etc.)
- All tests pass (means production code already implements this — go back to pre-flight)

---

## 5. Output

### RED PROOF block:

Paste the full test output showing failures. Do not summarize.

```
RED PROOF:
──────────
<full test runner output with failures>
──────────
```

### GREEN PHASE handoff:

```
GREEN PHASE — Handoff Instructions
───────────────────────────────────
Target file: <production file path>
Test file:   <test file path>
Run command: <exact command to run tests>

Rules:
- Do NOT modify the test file
- Do NOT add new tests
- Write minimal code to make all <N> tests green
- Run the test command above to verify GREEN
```

---

## 6. Pipeline Integration

```
TDD RED → writes tests
    |
    v
Write production code (GREEN) — make tests pass
    |
    v
Commit → lint + typecheck + affected tests
    |
    v
PR → review-fix loop (when ready)
```
