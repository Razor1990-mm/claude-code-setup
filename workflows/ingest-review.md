---
name: ingest-review
description: Parse review output into structured findings with IDs and classification
model: sonnet
---

Parse review feedback from `/review`, `/codex-code-review`, and `/codex-pr-review` into structured, classified findings. Used internally by `/pr` and available standalone.

**Usage:** `/ingest-review` (then paste review output), or called internally by `/pr`

---

## Process

### 1. Accept Input

Accept output from any combination of:
- `/review` (Claude) — verdict: SHIP / FIX FIRST / RETHINK
- `/codex-code-review` (Codex) — verdict: SHIP IT / FIX / RETHINK
- `/codex-pr-review` (Codex) — verdict: SHIP IT / FIX / RETHINK

Normalize verdicts: SHIP = SHIP IT = pass. FIX FIRST = FIX = findings exist. RETHINK = fundamental issues.

### 2. Extract Findings (Verbatim)

For each finding in each review output:

1. **Severity:** Extract P0/P1/P2 exactly as written. NEVER reinterpret or reclassify.
2. **Category:** Extract the bracketed category (e.g., `[Multi-tenancy]`, `[CAS]`, `[AI-smell]`)
3. **Description:** The finding text, verbatim
4. **File reference:** `File: path/to/file.ts:line` if present
5. **Fix action:** `Fix: ...` if present
6. **Source:** Which reviewer produced this finding (claude-review / codex-code / codex-pr)

### 3. Assign Finding IDs

Format: `F{cycle}-{dimension}-{shortname}`

- `cycle`: Current review cycle number (1, 2, 3)
- `dimension`: Short dimension code from category:
  - MT = Multi-tenancy
  - CAS = Concurrency/CAS
  - AUTH = Authentication/Authorization
  - SEC = Security
  - IDM = Idempotency
  - DOM = Domain boundary
  - TEST = Test coverage
  - ERR = Error handling
  - PERF = Performance/Resource
  - STYLE = Code hygiene/style
  - ARCH = Architecture
  - SPEC = Spec adherence
  - AI = AI-smell
- `shortname`: 2-4 word slug (e.g., `orgId`, `countCheck`, `unusedImport`)

Example: `F1-MT-orgId`, `F2-CAS-countCheck`, `F1-STYLE-unusedImport`

### 4. Detect Inter-Reviewer Contradictions

Compare findings across reviewers for the same file:line or same code concern.

- If Claude says SHIP but Codex flags a P0/P1 on the same code -> mark both as CONTRADICTION
- If Codex says SHIP IT but Claude flags a P0/P1 -> mark both as CONTRADICTION
- Contradictions ALWAYS go to ASK_USER in the `/pr` loop

### 5. Detect Pre-Existing Findings (Anti-Cascade)

**Purpose:** Prevent scope cascades where reviewers flag pre-existing issues in adjacent code, creating pressure to expand scope mid-PR.

For each finding that has a `File:line` reference:
1. Compute merge-base: `MERGE_BASE=$(git merge-base HEAD "${BASE_REF:-origin/main}")` (fallback: `main`)
2. Run `git diff $MERGE_BASE -- <file>` to get the changed line ranges in the current diff
3. Check if the finding's line number falls WITHIN a changed hunk (added/modified lines)
4. If the line is NOT in any changed hunk, mark the finding as `PRE_EXISTING`

**PRE_EXISTING findings:**
- **P0/P1 PRE-EXISTING -> ASK_USER.** Critical issues in touched files deserve human attention.
- **P2 PRE-EXISTING -> SUGGEST.** Low-severity pre-existing issues are informational only.
- Tag with `[PRE-EXISTING]` in the output table

**Verification:** `git diff $MERGE_BASE -- <file>` is the source of truth. Not `git blame`, not heuristics.

### 6. Classify Findings

Classify each finding for the `/pr` loop:

**AUTO** — All of these must be true:
- P0 or P1 severity
- NOT marked PRE_EXISTING
- Has File: reference with line number
- Has Fix: action that is concrete and specific
<!-- CUSTOMIZE: Define your auto-fix allowlist -->
- Fix matches the auto-fix allowlist (e.g., tenant filter, unused import, typed error, CAS count, AbortController)
- Would affect <=3 files and <=30 lines
- Does NOT touch test files
- Not a CONTRADICTION
- Total AUTO findings this cycle <=5

**ASK_USER** — Any of these:
- PRE_EXISTING with P0 or P1 severity
- CONTRADICTION between reviewers
- No File: reference or no Fix: action
- Fix action is vague
- Doesn't match auto-fix allowlist
- Would touch test files
- Blast radius >3 files or >30 lines
- Recurring finding (same ID from prior cycle)
- Architectural / scope concern

**SUGGEST** — Any of these:
- P2 severity (not a CONTRADICTION)
- P2 PRE_EXISTING finding

### 7. Handle Prior Findings (Re-Review Mode)

When called with a prior findings list (from `/pr` cycle N+1):
- Match current findings against prior finding IDs by file:line and description
- If a prior finding is NOT present in current output -> mark as RESOLVED
- If a prior finding IS still present -> keep the SAME finding ID (persistent)
- If a new finding appears -> assign new ID with current cycle number

---

## Output Format

```
## Parsed Review Findings (Cycle {N})

### Sources
- /review (Claude): {verdict}
- /codex-code-review: {verdict}
- /codex-pr-review: {verdict}

### Contradictions
{list of contradictions with both reviewer perspectives, or "None"}

### Findings

| ID | Sev | Category | File:Line | Fix Action | Class | Source |
|----|-----|----------|-----------|------------|-------|--------|
| F1-MT-orgId | P0 | Multi-tenancy | domain/quotes.ts:42 | Add orgId to where | AUTO | claude-review |
| F1-ARCH-pattern | P1 | Architecture | domain/dispatch.ts:15 | (vague) | ASK_USER | codex-pr |
| F1-STYLE-import | P2 | Code hygiene | routes/ops.ts:3 | Remove unused | SUGGEST | claude-review |

### Summary
- AUTO: {count} (will be auto-fixed by /pr)
- ASK_USER: {count} (requires user decision)
- SUGGEST: {count} (informational)
- PRE-EXISTING: {count} (in unchanged lines)
- RESOLVED: {count} (from prior cycle)

### Resolved From Prior Cycle
{list of resolved finding IDs, or "N/A — first cycle"}
```

---

## Rules

- **Severity is immutable.** Extract verbatim from reviewer output. NEVER downgrade, reinterpret, or dismiss.
- **Finding IDs persist across cycles.** Same issue = same ID. New issues = new ID.
- **Contradictions are always flagged.** Two reviewers disagreeing on the same code = always ASK_USER.
- **Classification is rules-based.** Follow the decision tree above mechanically. No judgment calls.
- **When called by /pr:** Skip the "Approve?" prompt. Return structured output directly.
- **When called standalone:** Present findings and ask "Proceed with fixes? [Y/n]"
