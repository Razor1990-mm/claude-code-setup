---
name: check-consistency
description: Cross-file string consistency checker
---

Detect hardcoded string constants that should use shared constants. Catches cross-file drift before it compounds.

<!-- CUSTOMIZE: This example uses event type strings. Adapt to your project's string constants (status enums, error codes, action types, metric names, etc.) -->

**Usage:**
- `/check-consistency <file>` — scan a specific file
- `/check-consistency --audit` — full codebase scan

## What It Checks

### 1. Hardcoded String With Existing Constant
**Violation:** A file uses a string literal when a matching constant exists.

```typescript
// WRONG: constant EVENT_APPROVED exists
eventType: "APPROVED"

// CORRECT: use the constant
eventType: EVENT_APPROVED
```

**Severity:** FAIL — must use the constant.

### 2. Hardcoded String Without Constant (Migration Candidate)
**Violation:** A file uses a string literal with no matching constant.

**Severity:** WARNING — add constant or file backlog item.

### 3. Naming Convention
**Violation:** String uses inconsistent casing (e.g., PascalCase when convention is SCREAMING_SNAKE_CASE).

**Severity:** WARNING

## Execution Logic

### Standard mode (file-scoped)

<!-- CUSTOMIZE: Replace with your constants file path -->
1. **Collect constants:** Read your constants file. Extract all exported constants and their string values.

2. **Scan the target file:** Search for hardcoded strings in relevant positions.

3. **Cross-reference each hardcoded string:**
   - If string value matches a constant -> **FAIL**
   - If no matching constant -> **WARNING**

4. **Naming convention check:** Flag inconsistent casing.

5. **Report** with file:line references.

### Audit mode (`--audit`)

Scans **all** domain files:
1. Run standard mode logic against every domain file
2. Group findings by file
3. Summary: total FAILs, total WARNINGs, files clean

## Output Format

### Standard mode — clean
```
String Consistency Check: src/domain/feature.ts

All string constants use shared constants.
No drift detected.

PASS
```

### Standard mode — findings
```
String Consistency Check: src/domain/quotes.ts

FAIL  Line 142: Use CONSTANT_NAME from constants.ts instead of "string_value"
WARN  Line 89: No constant for "new_string" — add constant or backlog item
WARN  Line 203: Naming convention — "PascalCaseValue" should be SCREAMING_SNAKE_CASE

Summary: 1 FAIL, 2 WARNINGS
```

### Audit mode
```
String Consistency Audit: src/domain/**/*.ts

Constants found: N

--- File-by-file results ---

src/domain/quotes.ts:
  FAIL  Line 142: "VALUE" — constant exists, use it
  WARN  Line 89: "NEW_VALUE" — no constant

src/domain/feature.ts:
  All strings use constants. CLEAN.

AUDIT SUMMARY
  Files scanned: N
  Files clean: N
  Files with findings: N
  Total FAILs: N
  Total WARNINGs: N

Migration candidates (no constant exists):
  "NewString" — used in file1.ts:XX, file2.ts:XX
```

## When to Auto-Trigger
- After editing any domain file
- As part of pre-commit quality gates
- Full audit mode for sprint close-out
