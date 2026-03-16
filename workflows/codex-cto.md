---
name: codex-cto
description: Codex CTO advisor — plan review + implementation review (plan adherence, test quality)
model: sonnet
---

Codex CTO advisor with two modes. Codex reads files directly — Claude does NOT inline code.

**Usage:**
- `/codex-cto` or `/codex-cto <plan-path>` — **Plan review** (before implementation)
- `/codex-cto review` — **Implementation review** (after implementation, before pre-commit)

## Distinct Lenses (No Overlap)

| Checkpoint | Skill | Question |
|---|---|---|
| Plan phase | `/codex-cto` | Will this plan work given the real code? |
| Post-implementation | `/codex-cto review` | Did the implementation match the plan? Are tests thorough? |
| Pre-commit | `/codex-code-review` | Is this production-ready? (3am incident survival) |
| Pre-PR | `/codex-pr-review` | Is this strategically coherent? (8 dimensions) |

## Trust Model

**CRITICAL:** Claude does NOT read the referenced code files. Claude does NOT inline code into the prompt. Codex navigates the codebase independently. This ensures Codex sees the real code, not Claude's version of it.

Claude's only job: identify the plan file path, compose the instructions prompt (invariants, review focus, output format), and tell Codex where the plan is. Codex reads the plan, extracts referenced file paths, reads those files, and reviews.

**Why:** If Claude reads and inlines code, Claude controls what Codex sees. Claude could hallucinate, omit, or frame code. An independent reviewer must see reality.

---

## Mode 1: Plan Review (`/codex-cto` or `/codex-cto <path>`)

Runs alongside `/staff-review` before implementation for non-trivial plans.

### Step 1: Find the Plan File Path

Look for the plan in:
1. Provided argument path
2. The plan file path from system-reminder
3. Most recent plan discussed in conversation

Note the path. **Do NOT read the plan file yourself.**

### Step 2: Run Codex

```bash
codex exec --json --full-auto -o /tmp/codex-cto-output.md "$(cat <<'PROMPT'
You are the CTO advisor reviewing a plan BEFORE implementation begins. Your job is to validate feasibility, check file boundaries, verify invariant coverage, and find gaps. You have full filesystem access — read the plan and the code it references.

<!-- CUSTOMIZE: Replace these with your project's invariants -->
PROJECT INVARIANTS (violations are P0):
- All database queries MUST be tenant-scoped (multi-tenancy). Never fetch by ID alone.
- Composite tenant FKs: every parent-child relationship needs tenant-scoped FK.
- Idempotency: catch unique constraint violations and re-fetch for creates.
- CAS pattern: all updateMany for state transitions MUST check result.count and throw.
- Event and audit log tables are append-only. Never UPDATE or DELETE.
- Auth is fail-closed. Missing credentials = 500, not silent bypass.
- Thin controllers, fat domain — all business logic in domain layer.
- Domain functions accept optional DB client parameter for transactions.
- TDD required: RED phase (failing test) before GREEN phase (passing implementation).
- Existing tests are sacred — never modify to make code pass.

INSTRUCTIONS:
1. Read the plan file at: <INSERT_PLAN_PATH>
2. Extract every file path mentioned in the plan
3. Read each of those files from the filesystem
4. Also read key imports and callers (1 level deep) for integration context
5. If the plan references schema changes, read the schema file
6. Read templates/work-order.md to check plan completeness
7. Do NOT read .env files, node_modules/, or credential files

REVIEW FOCUS:
1. FEASIBILITY — Will this plan work given the actual code?
2. FILE BOUNDARIES — Does the plan list ALL files that need changing?
3. INVARIANT COVERAGE — For each invariant, does the plan address it?
4. ACCEPTANCE CRITERIA — Are there testable criteria (given/when/then)?
5. WORK ORDER COMPLETENESS — Does the plan cover required sections?
6. HIDDEN ASSUMPTIONS — What does this plan take for granted?
7. INTEGRATION RISKS — Does this play well with existing code?
8. ALTERNATIVE APPROACHES — Is there a simpler way?

Respond in this EXACT format:

VERDICT: PROCEED | SIMPLIFY | RE-PLAN
CONFIDENCE: HIGH | MEDIUM | LOW

FEASIBILITY CONCERNS:
- [P0] <plan will fail because of X — cite file:line>
- [P1] <plan has risk Y — cite file:line>
- [P2] <plan could be simpler — cite existing code>

FILE BOUNDARY VALIDATION:
- Files plan says to touch: <list>
- Files that actually need touching: <list>
- Missing files: <any the plan forgot>
- Unnecessary files: <any not needed>

INVARIANT COVERAGE CHECK:
- [ ] Multi-tenancy — applicable? addressed? Y/N
- [ ] Idempotency — applicable? addressed? Y/N
- [ ] CAS pattern — applicable? addressed? Y/N
- [ ] Composite tenant FKs — applicable? addressed? Y/N
- [ ] Append-only audit trail — applicable? addressed? Y/N
- [ ] Fail-closed auth — applicable? addressed? Y/N
- [ ] DB client parameter — applicable? addressed? Y/N
- [ ] TDD — test plan included? Y/N

ACCEPTANCE CRITERIA GAPS:
- <criteria the plan should include but doesn't>

WORK ORDER COMPLETENESS:
- [ ] Context gathered
- [ ] Requirements numbered
- [ ] Must-cover invariants with test mappings
- [ ] Must-cover tests (categories or justified N/A)
- [ ] Proof commands
- [ ] Files-you-may-touch matches actual needs

HIDDEN ASSUMPTIONS:
- <assumption — and whether it's true>

ALTERNATIVE APPROACHES:
- <simpler alternative, if any>

For every finding, cite the specific file and line.
PROMPT
)"
```

**Important:** Replace `<INSERT_PLAN_PATH>` with the actual plan file path before running.

Use a **240-second timeout**.

### Session Resume (for re-runs after SIMPLIFY/RE-PLAN)

When Codex returns SIMPLIFY or RE-PLAN, use session resume to preserve context:

```bash
SESSION_ID=$(echo "$ROUND1_OUTPUT" | head -1 | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['thread_id'])")
codex exec resume "$SESSION_ID" --full-auto "<same prompt with updated PLAN_PATH>" > /tmp/codex-cto-output.md 2>&1
```

If session resume fails, fall back to a fresh `codex exec`.

### Step 3: Present Results

1. Show the **raw Codex output** unmodified
2. Add Claude's assessment: agree or disagree with each concern
3. If running alongside `/staff-review` and verdicts conflict, flag prominently

## Output Format

```
### /codex-cto Result (Advisory)

**Plan Reviewed:** <plan file path>

**Raw Codex Output:**
<unmodified Codex response>

**Verdict:** PROCEED / SIMPLIFY / RE-PLAN / SKIPPED
**Confidence:** HIGH / MEDIUM / LOW

**Claude Assessment:**
- [Concern 1]: AGREE / DISAGREE — <1 sentence>
...

**File Boundary Check:** PASS / GAPS FOUND
**Invariant Coverage:** COMPLETE / GAPS FOUND

Claude agrees with verdict: YES / NO
```

## Failure Handling

| Failure | Output | Action |
|---------|--------|--------|
| Codex CLI not installed | "SKIPPED — Codex CLI not installed" | Continue |
| Codex auth unavailable | "SKIPPED — Codex authentication unavailable" | Continue |
| Timeout (240s) | "SKIPPED — Codex API timeout" | Continue |
| No plan found | "SKIPPED — No plan file found" | Continue |

**If Codex unavailable:** `/codex-cto` is SKIPPED. `/staff-review` alone gates planning. Never blocked by infrastructure issues.

**When Codex runs:** Verdict is blocking — SIMPLIFY/RE-PLAN blocks until revised. User can override.

## What NOT to Do

- Do NOT read the plan file yourself — Codex reads it
- Do NOT read referenced code files — Codex reads them
- Do NOT inline code into the prompt
- Do NOT read .env or credentials
- Do NOT block on Codex failure
- Do NOT summarize Codex output — show raw, then assess separately

---

## Mode 2: Implementation Review (`/codex-cto review`)

Runs after implementation, before `/pr`. Compares what was built against what was planned.

### Step 1: Find the Plan File Path

Same as Mode 1. If no plan found → SKIP.

### Step 2: Run Codex

Same trust model — Codex reads the plan and changed files independently. Review focuses on:
1. PLAN ADHERENCE — Did implementation match the plan?
2. ACCEPTANCE CRITERIA — Are all planned criteria met?
3. INVARIANT COMPLIANCE — Are invariants correctly implemented?
4. PLAN DRIFT — Any unplanned changes or shortcuts?
5. TDD & TEST QUALITY — Are tests thorough?

Output format: VERDICT: APPROVE | REVISE | ESCALATE with plan adherence check, acceptance criteria check, and test quality assessment.

### Step 3: Present Results

1. Show raw Codex output unmodified
2. Add Claude's assessment
3. On REVISE: list specific items to fix before `/pr`
4. On ESCALATE: surface to user immediately
