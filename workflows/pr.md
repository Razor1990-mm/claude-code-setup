# Workflow: Automated PR Review-Fix Loop

Orchestrate the full BUILD -> REVIEW -> FIX loop. Commit, run reviews, parse findings, auto-fix what's safe, ask the user about the rest, and re-review until convergence or max cycles.

## Anti-Gaming Principle

**The AI agent is the fixer, NOT the triage arbiter.** Severity comes from reviewer output verbatim. The agent CANNOT downgrade, reinterpret, dismiss, or relabel severity.

---

## Process

### Phase 1: PUBLISH

1. Check current branch is NOT `main`. Abort if on main.
2. If there are staged changes, commit them.
3. **Diff-size pre-flight:** Check total LOC changed. If >400 lines, warn: "Large diff. Consider splitting into smaller PRs for better review quality." Do not block.
4. Push the branch to origin.
5. Create a draft PR if none exists, or update existing PR.

### Phase 2: REVIEW (Cycle 1)

Run code reviews. Use multiple reviewers if available (e.g., different AI models or perspectives):
1. Completeness + adversarial review (see `review.md`)
2. Production-readiness review
3. Strategic coherence review

Collect all outputs.

### Phase 3: PARSE

Parse review output into structured findings:
- Unique IDs (format: `F{cycle}-{dimension}-{shortname}`)
- Verbatim severity (P0/P1/P2) — NEVER reinterpreted
- File:line references where available
- Fix actions where available

See `ingest-review.md` for the full parsing workflow.

### Phase 4: VERDICT CHECK

If ALL reviewers say SHIP:
- Post summary as PR comment
- Output: "All reviewers: SHIP. PR ready for human review."
- DONE.

If ANY findings exist, proceed to Phase 5.

### Phase 5: CLASSIFY (Rules-Based, Not Judgment)

#### AUTO-FIX (must meet ALL conditions):
- Severity is P0 or P1
- Has a `File:` reference with line number
- Has a concrete `Fix:` action
- Fix matches the **Auto-Fix Allowlist** (below)
- Blast radius: <=3 files AND <=30 lines changed
- Does NOT require modifying a test file
- Does NOT require a prohibited pattern
- Total auto-fixes this cycle: <=5

#### ASK_USER (any of these triggers):
- Architectural findings or scope questions
- Agent disagrees with the finding
- Finding requires test file modification
- Finding is recurring (same ID from prior cycle)
- Inter-reviewer contradiction
- Blast radius >3 files or >30 lines
- Fix action is missing or vague

#### SUGGEST (collected, presented at end):
- P2 findings

### Phase 6: ASK USER (if any ASK_USER findings)

Present findings to the user with context. Wait for direction.

### Phase 7: FIX (auto-fixable findings, max 5)

For each AUTO finding:
1. Read the target file fully
2. Apply the fix following the Fix: action
3. Track: finding ID -> file:line -> change description

### Phase 8: VERIFY

After ALL fixes:
<!-- CUSTOMIZE: Your actual verify commands -->
1. Run linter
2. Run type checker
3. Run full test suite (not just affected)

If verify fails: STOP. Present failure to user. Do NOT commit broken code.

### Phase 9: PUBLISH FIXES

1. Stage fixed files
2. Commit with finding IDs in message
3. Push to origin

### Phase 10: RE-REVIEW

Re-run ONLY reviewers that had findings. Include prior findings for tracking.

### Phase 11: CONVERGENCE CHECK

- All findings resolved + SHIP -> DONE
- Finding appears 2nd consecutive cycle -> ASK_USER (not converging)
- New findings -> classify and loop
- Cycle count reaches 3 -> STOP

### Phase 12: LOOP EXIT (max 3 cycles)

Post PR comment with full fix history. Present remaining findings to user.

---

## Auto-Fix Allowlist (Exhaustive)

<!-- CUSTOMIZE: Adapt to your project's common findings -->

| Pattern | Description | Example Fix |
|---------|-------------|-------------|
| Missing tenant filter | Query without tenant scoping | Add tenant ID to where clause |
| Unused import | Import not referenced | Remove the import line |
| Missing typed error throw | Returns null instead of throwing | Add `throw new NotFoundError(...)` |
| Missing CAS count check | Conditional update result not checked | Add `if (result.count === 0) throw ...` |
| Missing timeout | External API call without timeout | Add timeout/AbortController |

**If a finding's fix doesn't match one of these -> ASK_USER.**

---

## Prohibited Fix Patterns

Auto-fix MUST NEVER use any of these:
- Lint suppression comments to hide warnings
- Delete or modify existing test assertions
- Add empty catch blocks or swallow errors
- Move code between files to "hide" it from reviewers
- Add TODO/FIXME comments as a "fix"
- Wrap problematic code in try/catch that returns a default value

---

## Structural Rules

1. **Severity is immutable.** Reviewers set it. The fixer cannot change it.
2. **Finding IDs persist across cycles.** Same issue = same ID.
3. **Blast radius caps.** Single fix: max 3 files, 30 lines. Cycle total: max 5 auto-fixes.
4. **Test files are off-limits.** Any fix touching a test file -> ASK_USER.
5. **Convergence detection.** Same finding in 2+ cycles -> ASK_USER.
6. **Full test suite after every fix cycle.** Not just affected tests.
7. **Fix history is visible.** Logged per cycle + posted as PR comment.
