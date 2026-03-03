# Workflow: Cross-File String Consistency

Detect hardcoded string constants that should use shared constants. Catches cross-file drift before it compounds.

<!-- CUSTOMIZE: This example uses event type strings. Adapt to your project's string constants (status enums, error codes, action types, etc.) -->

## What It Checks

### 1. Hardcoded String With Existing Constant
**Violation:** A file uses a string literal when a matching constant exists.
```
// WRONG: constant EVENT_APPROVED exists
eventType: "APPROVED"

// CORRECT: use the constant
eventType: EVENT_APPROVED
```
**Severity:** FAIL

### 2. Hardcoded String Without Constant
**Violation:** A file uses a string literal with no matching constant.
**Severity:** WARNING — add constant or file backlog item.

### 3. Naming Convention
**Violation:** String uses inconsistent casing (e.g., PascalCase when convention is SCREAMING_SNAKE_CASE).
**Severity:** WARNING

## Process

### Standard mode (file-scoped)
1. Read the constants file. Extract all exported constants and their string values.
2. Scan the target file for hardcoded strings in relevant positions.
3. Cross-reference: matching constant exists -> FAIL. No constant -> WARNING.
4. Check naming convention.
5. Report with file:line references.

### Audit mode (full codebase)
1. Run standard logic against every relevant source file
2. Group findings by file
3. Summary: total FAILs, total WARNINGs, files clean

## Output Format

```
String Consistency Check: <file>

FAIL  Line 142: Use CONSTANT_NAME instead of "string_value"
WARN  Line 89: No constant for "new_string" — add constant or backlog

Summary: N FAIL, N WARNINGS
```

## When to Run
- After editing domain files
- As part of pre-commit quality gates
- Full audit mode for sprint close-out
