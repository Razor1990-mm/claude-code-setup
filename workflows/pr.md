---
name: pr
description: Automated review-fix loop — commit, push, review, fix, verify, re-review (max 3 cycles)
model: opus
---

Orchestrate the full BUILD -> REVIEW -> FIX loop. Commit staged changes, run all three reviews, parse findings, auto-fix what's safe, ask the user about the rest, and re-review until convergence or max cycles.

**Usage:** `/pr` (from a feature branch with staged or committed changes)

### Expected Runtime & Cost

| Scenario | Wall Time | Claude Tokens | Codex Tokens | When |
|----------|-----------|---------------|--------------|------|
| **Happy path** (SHIP cycle 1) | ~5-8 min | ~30-60K | ~50-100K | Clean implementation, no findings |
| **1 fix cycle** (SHIP cycle 2) | ~10-15 min | ~80-120K | ~150-200K | Findings exist, Claude fixes them |
| **Worst case** (2 full cycles) | ~15-20 min | ~120-180K | ~200-300K | Multiple findings, some recurring |

**Token strategy:** Codex reviews (cheap tokens). Claude orchestrates, fixes, and verifies (expensive but reliable). Reviewers don't fix, fixer doesn't review.

---

## Role Separation Principle

**Codex reviews. Claude fixes.** Reviewers don't fix their own findings. The fixer doesn't review its own work. This separation prevents closed feedback loops and keeps each role honest.

**Anti-gaming:** Severity comes from reviewer output verbatim. Claude CANNOT downgrade, reinterpret, dismiss, or relabel severity.

---

## Process

### Phase 1: PUBLISH

1. Check current branch is NOT `main`. Abort if on main.
2. If there are staged changes, commit them (via `/commit` skill).
3. **Diff-size pre-flight:** Check total LOC changed against main. If >400 lines, warn: "Large diff. Consider splitting." Do not block.
4. Push the branch to origin.
5. If no PR exists, create one (draft) using `gh pr create --draft`.
6. If PR already exists, push updates.

### Phase 2: REVIEW (Cycle 1)

Run all three reviews (invoke each via Skill tool — NEVER simulate):

1. `/review` — Claude: completeness + adversarial + spec adherence
2. `/codex-code-review` — Codex: production-readiness
3. `/codex-pr-review` — Codex: strategic coherence + spec adherence

**Codex timeout:** Each Codex invocation has a 60-second soft timeout. If exceeded, log and proceed. If BOTH unavailable, degrade to Claude-only review and add `DEGRADED: Codex reviews unavailable.` to the PR comment.

### Phase 3: PARSE

Run `/ingest-review` on the combined review output. This produces:
- Structured findings with unique IDs (format: `F{cycle}-{dimension}-{shortname}`)
- Verbatim severity (P0/P1/P2) — NEVER reinterpreted
- File:line references and Fix: actions where available

### Phase 4: VERDICT CHECK

If ALL reviewers say SHIP: post summary as PR comment, DONE.
If ANY findings exist, proceed to Phase 5.

### Phase 5: CLASSIFY (Rules-Based, Not Judgment)

#### AUTO-FIX (must meet ALL conditions):
- Severity is P0 or P1
- Has `File:` reference with line number
- Has concrete `Fix:` action matching the **Auto-Fix Allowlist** (below)
- Blast radius: <=3 files AND <=30 lines changed
- Does NOT require modifying a test file or using a prohibited pattern
- Total auto-fixes this cycle: <=5. Overflow goes to ASK_USER.

#### ASK_USER (any of these triggers):
- Architectural findings or scope questions
- Claude disagrees with the finding
- Finding requires test file modification
- Finding is recurring (same ID in prior cycle)
- Inter-reviewer contradiction
- Blast radius >3 files or >30 lines
- >5 auto-fixable findings (overflow)
- Changes outside spec scope
- Fix would use a prohibited pattern
- Fix: action is missing or vague
- Severity is P2

#### SUGGEST (collected, presented at end):
- P2 findings — presented after loop completes. No auto-action.

### Phase 6: ASK USER (if any ASK_USER findings)

Present via AskUserQuestion with finding ID, severity, file:line, both reviewer perspectives (if contradiction), and why it couldn't be auto-fixed.

### Phase 7: FIX (Claude applies fixes)

**Batch all AUTO fixes in one pass.** Don't fix-verify-fix-verify sequentially.

### Phase 8: VERIFY

<!-- CUSTOMIZE: Replace with your project's commands -->
1. Run linter
2. Run type checker
3. Run full test suite (not just affected)
4. If ANY fix touched domain files: run integration/DB-gated tests

If verify fails: STOP. Present failure. Do NOT commit broken code.

### Phase 9: PUBLISH FIXES

Stage, commit with finding IDs in message, push.

### Phase 10: RE-REVIEW

Re-run ONLY reviewers that had findings. Include templated re-review prompt:
```
PRIOR FINDINGS (from cycle {N}):
{finding IDs + descriptions}

For each: mark RESOLVED, re-raise with SAME ID, or note partial fix.
New findings get new IDs.
```

### Phase 11: CONVERGENCE CHECK

- All resolved + SHIP → DONE
- Same finding ID in 2 consecutive cycles → ASK_USER (not converging)
- New findings → classify and loop (Phase 5)
- Cycle count reaches 3 → STOP, present to user

### Phase 12: LOOP EXIT

Post PR comment with full fix history. Present P2 suggestions. **PRE-EXISTING backlog prompt:** If pre-existing findings surfaced, ask user to add to backlog.

---

## Auto-Fix Allowlist (Exhaustive)

<!-- CUSTOMIZE: Add/remove patterns specific to your codebase -->

| Pattern | Description | Example Fix |
|---------|-------------|-------------|
| Missing tenant filter | Query fetches by ID without tenant scoping | Add tenant ID to where clause |
| Unused import | Import not referenced | Remove the import line |
| Missing typed error throw | Domain function returns null instead of throwing | Add `throw new XNotFoundError(...)` |
| Missing CAS count check | `updateMany` not checked for count===0. **GUARD:** Skip if JSDoc has `DESIGN DECISION (CAS exception)`. | Add count check + throw |
| Missing AbortController timeout | External API call without timeout | Add AbortController |

---

## Prohibited Fix Patterns

- `// eslint-disable` or `@ts-ignore`
- Delete or modify existing test assertions
- Empty catch blocks or swallowed errors
- Move code between files to hide from reviewer
- `TODO`/`FIXME` comments as a "fix"
- try/catch returning default values

---

## Structural Rules

1. Severity is immutable
2. Finding IDs persist across cycles
3. Blast radius caps: 3 files, 30 lines per fix; 5 auto-fixes per cycle
4. Test files are off-limits for auto-fix
5. Same finding in 2+ cycles → ASK_USER
6. Inter-reviewer contradictions → ASK_USER
7. Re-review uses templated prompts
8. Full diff re-review (not just fixed files)
9. Full test suite after every fix cycle
10. Fix history visible in PR comment
