---
name: codex-pr-review
description: Codex CTO-level strategic PR review — cohesion, completeness, architectural consistency
model: sonnet
---

Get an independent strategic PR review from OpenAI Codex. Unlike tactical reviews, this asks: **is this a coherent, complete, well-factored unit of work that sets good precedent?**

**Usage:** `/codex-pr-review` or `/codex-pr-review <spec-path>`

## Distinct Lens

| Skill | Question | Overlap |
|-------|----------|---------|
| `/review` (Claude) | Completeness + adversarial + AI smells + spec adherence | COMPLEMENTARY |
| `/codex-code-review` | Will this survive 3am? | MINIMAL |
| `/codex-pr-review` | **Coherent, complete, well-factored, faithful to spec?** | UNIQUE strategic lens |

## Trust Model

**CRITICAL:** Claude does NOT read changed files or inline code. Codex navigates independently.

## Process

### Step 1: Identify Specs

- Check `specs/` for a matching feature spec
- Check `docs/sprints/` for active sprint spec
- If none found: set to "NONE"

### Step 2: Get Changed Files (for reporting only)

Same merge-base command as `/codex-code-review`. Do NOT read files yourself.

### Step 3: Run Codex Review

```bash
cat <<'PROMPT' | codex exec --full-auto -o /tmp/codex-pr-review-output.md -
You are a skeptical CTO doing a strategic PR review. Your job is NOT to break code or check compliance. Your job is to evaluate whether this PR forms a COHERENT, COMPLETE, WELL-FACTORED unit of work.

<!-- CUSTOMIZE: Replace with your project context -->
PROJECT CONTEXT:
- <Your project description>
- Architecture: thin controllers, fat domain
- Multi-tenant: every query must be tenant-scoped
- Append-only audit trail

SPEC PATH: <INSERT_SPEC_PATH_OR_NONE>

If a spec path is provided, read it first. Extract requirements, acceptance criteria, constraints, and out-of-scope items.

SCOPE: Build changed-file set using merge-base against main. Read changed files + 1-hop context.

Review against these 8 dimensions:

DIMENSION 1: SLICE COHESION
- Coherent unit or grab-bag? Could it split into smaller PRs?
- Unrelated changes smuggled in?

DIMENSION 2: REQUIREMENT COMPLETENESS
- Each spec requirement has implementing code?
- Each criterion has a test? Any IOUs (TODO, "future sprint")?

DIMENSION 3: ARCHITECTURAL CONSISTENCY
- Follows existing patterns or introduces new ones?
- New patterns justified?

DIMENSION 4: INTEGRATION SAFETY
- Signature changes? All callers updated?
- Schema changes needing migration?

DIMENSION 5: SYSTEM-LEVEL RISK
- Blast radius if buggy? Silent failure or loud?
- Rollback complexity?

DIMENSION 6: DATA SAFETY
- Queries tenant-scoped? Logs leak PII?
- State changes produce audit entries?

DIMENSION 7: TEST QUALITY
- Tests test behavior or mirror implementation?
- Edge cases? Error paths?

DIMENSION 8: SPEC ADHERENCE
- Requirements implemented? Constraints enforced?
- Anything silently dropped? Scope creep?

Respond in EXACT format:

VERDICT: SHIP IT | REWORK | REJECT

PER-DIMENSION VERDICTS:
D1-D8 with status each

[If spec found:]
SPEC ADHERENCE TABLE:
| # | Requirement | Implemented (file:fn) | Tested (file:case) | Status |

FINDINGS:
- [P0/P1/P2] <description — cite file:line>

RATIONALE:
<2-3 sentences>
PROMPT
```

Use a **180-second timeout**.

### Step 4: Present Results

1. Show **raw Codex output** unmodified
2. Claude assessment per finding
3. Flag inter-skill verdict conflicts

**DISMISSAL RULES:** Same as `/codex-code-review` — "out of scope" invalid, "pre-existing" needs proof, P0s only user can override, Codex right until proven wrong.

## Verdict Criteria

| Verdict | When |
|---------|------|
| **SHIP IT** | Zero P0, all dimensions healthy, no IOUs |
| **REWORK** | P0s exist but approach is sound |
| **REJECT** | 3+ dimensions at worst level, >50% requirements missing |

## Failure Handling

Same as `/codex-code-review` — blocking when standalone, degrades in `/pr` with DEGRADED notice.

## When to Run

- In `/pr` pipeline alongside other reviews
- Especially when: 3+ domain files touched, multiple slices, new patterns, shared infrastructure changes
