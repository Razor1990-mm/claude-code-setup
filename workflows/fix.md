# Workflow: Autonomous Bug Fix

Fix a bug from pasted error output. Works autonomously — no hand-holding.

## Input

User pastes one of:
- Stack traces
- CI output (lint, typecheck, test failures)
- Docker/container logs
- Browser console errors
- Any error message

## Process: Parse -> Locate -> Fix -> Verify

### 1. PARSE
Extract from the error:
- File path and line number
- Error type/code
- Root cause hypothesis

### 2. LOCATE
Find the bug:
- Read the referenced file
- Read surrounding context (callers, callees)
- Understand why it's failing

### 3. FIX
Make the minimal change:
- Fix the root cause, not the symptom
- Don't refactor unrelated code
- Keep the change as small as possible

### 4. VERIFY
Confirm the fix:
- Run the relevant test(s)
- Run typecheck if types changed
- Run lint if new code added

## Rules

- **Don't ask clarifying questions** unless the error is truly ambiguous
- **Don't explain at length** — just fix it
- **Don't over-fix** — solve this bug, not all bugs
- **Do verify** — a fix without verification isn't done

## Output Format

```
## Fix Applied

**Error:** <brief description>
**Root cause:** <why it failed>
**Fix:** <what was changed>

### Changes Made
- `file.ts:42` — Added null check
- `file.ts:45` — Added early return

### Verification
- [x] Test passes
- [x] Typecheck passes
```

## When to Ask for Help

Only ask if:
- Multiple unrelated errors in the output
- Error references code that doesn't exist
- Fix requires architectural decision
