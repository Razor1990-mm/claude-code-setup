---
name: codex-code-review
description: Codex production-readiness code review — Codex reads code directly, no Claude middleman
model: sonnet
---

Get an independent production-readiness review from OpenAI Codex. Codex navigates the codebase itself — Claude does NOT read or inline code.

**Usage:** `/codex-code-review` or `/codex-code-review <file>`

## Distinct Lens

| Skill | Focus |
|-------|-------|
| `/grill` | Hostile — tries to break correctness |
| `/review` | AI smell detection + completeness + spec adherence |
| `/codex-code-review` | **Production-readiness** — "will this survive a 3am incident?" |
| `/codex-pr-review` | **Strategic cohesion** — "is this a coherent unit of work?" |

## Trust Model

**CRITICAL:** Claude does NOT read the changed files. Claude does NOT inline code into the prompt. Codex navigates the codebase independently. This ensures Codex sees the real code, not Claude's version of it.

**Why:** If Claude reads and inlines code, Claude controls what Codex sees. An independent reviewer must see reality, not Claude's version of it.

## Process

### Step 1: Identify Changed Files (for reporting only)

```bash
BASE_REF="${BASE_REF:-origin/main}"
git rev-parse --verify "$BASE_REF" >/dev/null 2>&1 || BASE_REF="main"
MERGE_BASE="$(git merge-base HEAD "$BASE_REF")"
{
  git diff --name-only "$MERGE_BASE"..HEAD
  git diff --name-only
  git diff --cached --name-only
  git ls-files --others --exclude-standard
} | awk 'NF' | sort -u
```

**Do NOT read these files yourself.** This list is only for the output report.

### Step 2: Run Codex Review

```bash
cat <<'PROMPT' | codex exec --full-auto -o /tmp/codex-code-review-output.md -
You are a skeptical senior engineer doing a production-readiness review. Your job is to evaluate whether this code is safe to deploy and operable at 3am.

<!-- CUSTOMIZE: Replace with your project's invariants -->
PROJECT INVARIANTS (violations are P0):
- All database queries MUST be tenant-scoped. Fetching by ID alone = cross-tenant vulnerability.
- Event and audit log tables are append-only. Never UPDATE or DELETE.
- Auth is fail-closed. Missing credentials = 500, not silent bypass.
- Webhooks must be idempotent. Catch unique constraint violations and re-fetch.
- External API calls must have timeouts (AbortController).
- No unbounded SELECT — always LIMIT.
- Domain functions accept optional DB client parameter for transactions.
- Thin controllers, fat domain — all business logic in domain layer.

REVIEW FOCUS:
1. OBSERVABILITY — Can you debug this in production? Correlation IDs? PII redacted?
2. ERROR MESSAGES — Actionable for on-call?
3. FAILURE RECOVERY — Consistent state after crash mid-operation?
4. NAMING & READABILITY — Can a new dev onboard in 30 minutes?
5. CONTRACT CLARITY — Self-documenting signatures, types, return values?
6. DEPLOYMENT SAFETY — Backward compatible? Zero-downtime safe?
7. INVARIANT COMPLIANCE — Tenant scoping, append-only audit, fail-closed auth?
8. STRUCTURAL HEALTH — Functions <80 lines, nesting <4 levels, params <=5?

SCOPE:
- Build changed-file set using merge-base against main.
- Read changed files + 1-hop callers/imports for context.

Respond in EXACT format:

VERDICT: SHIP IT | NEEDS WORK | BLOCK
CONFIDENCE: HIGH | MEDIUM | LOW

FINDINGS:
- [P0] <critical — cite file:line>
- [P1] <important — cite file:line>
- [P2] <minor — cite file:line>
PROMPT
```

Use a **180-second timeout**.

### Step 3: Present Results

1. Show **raw Codex output** unmodified
2. Add Claude's assessment per finding

**DISMISSAL RULES (STRICT):**
- **"Out of scope" is NOT a valid dismissal.** If Codex found it in changed files, it's in scope.
- **"Pre-existing" requires proof.** Show `git blame` proving it existed before this branch.
- **P0 findings CANNOT be dismissed by Claude.** Only the user can override.
- **P1 findings need a concrete reason** to disagree — cite specific code.
- **If Claude disagrees with 3+ findings, flag to user** — may be rationalizing.
- **Default: Codex is right until proven wrong.**

## Output Format

```
### /codex-code-review Result

**Files on Branch:**
- <file list — NOT read by Claude>

**Raw Codex Output:**
<unmodified>

**Verdict:** SHIP IT / NEEDS WORK / BLOCK
**Confidence:** HIGH / MEDIUM / LOW

**Claude Assessment:**
- [Finding 1]: AGREE / DISAGREE — <1 sentence>
...

Claude agrees with verdict: YES / NO
```

## Failure Handling

**Blocking gate when standalone.** When in `/pr`, degrades gracefully with DEGRADED notice.

| Failure | Output | Action |
|---------|--------|--------|
| CLI not installed | "BLOCKED — install Codex CLI" | Block |
| Auth unavailable | "BLOCKED — run codex login" | Block |
| Timeout (180s) | "BLOCKED — retry" | Block |

## What NOT to Do

- Do NOT read changed files — Codex reads them
- Do NOT inline code into prompt
- Do NOT read .env or credentials
- Do NOT skip on failure (it's a blocker)
- Do NOT summarize Codex output — show raw
