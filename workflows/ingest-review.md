# Workflow: Parse Review Findings

Parse review feedback into structured, classified findings. Used internally by the PR workflow.

## Process

### 1. Accept Input

Accept output from code reviews. Normalize verdicts: SHIP/SHIP IT = pass. FIX/FIX FIRST = findings exist. RETHINK = fundamental issues.

### 2. Extract Findings (Verbatim)

For each finding:
1. **Severity:** P0/P1/P2 exactly as written. NEVER reinterpret.
2. **Category:** The bracketed category (e.g., `[Multi-tenancy]`, `[CAS]`)
3. **Description:** Verbatim finding text
4. **File reference:** `File: path/to/file.ts:line` if present
5. **Fix action:** `Fix: ...` if present
6. **Source:** Which reviewer produced this

### 3. Assign Finding IDs

Format: `F{cycle}-{dimension}-{shortname}`

Dimensions:
- MT = Multi-tenancy
- CAS = Concurrency
- AUTH = Authentication
- SEC = Security
- IDM = Idempotency
- DOM = Domain boundary
- TEST = Test coverage
- ERR = Error handling
- PERF = Performance
- STYLE = Code hygiene
- ARCH = Architecture
- SPEC = Spec adherence

### 4. Detect Contradictions

If reviewers disagree on the same code -> mark as CONTRADICTION -> always ASK_USER.

### 5. Detect Pre-Existing Findings

For each finding with a File:line reference:
1. Check if the line falls within a changed hunk in the branch diff
2. If NOT in a changed hunk -> mark as `PRE_EXISTING`
3. P0/P1 PRE-EXISTING -> ASK_USER (critical issues in touched files need human decision)
4. P2 PRE-EXISTING -> SUGGEST (informational only)

### 6. Classify Findings

**AUTO** (all must be true):
- P0 or P1, not PRE_EXISTING
- Has File: reference + concrete Fix: action
- Fix matches auto-fix allowlist
- <=3 files, <=30 lines
- Not touching test files
- <=5 total AUTO per cycle

**ASK_USER** (any of these):
- PRE_EXISTING with P0/P1
- CONTRADICTION
- No File: or no Fix:
- Vague fix action
- Touches test files
- Blast radius exceeded
- Recurring from prior cycle

**SUGGEST:**
- P2 severity
- P2 PRE_EXISTING

### 7. Handle Prior Findings (Re-Review)

When called with prior findings:
- Match by file:line and description
- Prior finding not in current output -> RESOLVED
- Prior finding still present -> keep same ID
- New finding -> new ID with current cycle number

## Output Format

```
## Parsed Review Findings (Cycle N)

### Findings
| ID | Sev | Category | File:Line | Fix Action | Class | Source |

### Summary
- AUTO: N (will be auto-fixed)
- ASK_USER: N (requires user decision)
- SUGGEST: N (informational)
- RESOLVED: N (from prior cycle)
```

## Rules

- **Severity is immutable.** Extract verbatim.
- **Finding IDs persist across cycles.**
- **Contradictions are always flagged.**
- **Classification is rules-based, not judgment.**
