# /codex-sprint-cohesion — Cross-Spec Wiring Review (Codex)

Codex independently reviews all specs in a sprint for cross-spec wiring gaps. Different model = different blind spots. Catches producer/consumer chain breaks that the implementer model systematically misses.

**Usage:** `/codex-sprint-cohesion` or `/codex-sprint-cohesion <sprint-prefix>`

**When to run:** Alongside `/sprint-cohesion`, after all specs are written. Both reviews run, then you reconcile.

---

## Why This Exists

One real cohesion review: Claude's `/sprint-cohesion` found 1 P0 + 2 P1s. Codex found **4 additional real gaps** Claude missed entirely:
- Department write tools not setting `simulationRunId`
- A function signature missing required params
- An orphaned package.json script
- Sprint success criteria that wasn't actually achievable from the sum of specs

Different model catches different wiring gaps. **Always run both.**

---

## Process

### Step 1: Find Sprint Specs

1. Determine sprint prefix from argument or current branch (e.g., `sprint-29e` → `29e`)
2. Find all spec files: `specs/sprint-<prefix>*.md`
3. Find sprint doc: `docs/sprints/sprint-<prefix>*.md`
4. Extract the **Success** line from the sprint doc TL;DR

### Step 2: Run Codex

**CRITICAL: Pipe specs via stdin.** Codex times out when reading many files from disk on large codebases. Learned the hard way — 3 consecutive timeouts in one sprint until we switched to stdin.

```bash
cd "<project-root>" && cat specs/<sprint-prefix>*.md | codex exec --full-auto "You are reviewing <N> specs for <Sprint Name> (all pasted from stdin). Check CROSS-SPEC WIRING only:

1. Does every spec's output have a consumer in another spec or existing code?
2. Does every spec's input have a producer? If a spec queries a field, does another spec create/populate that field?
3. Are there file conflicts (same file touched by multiple specs)?
4. Can the success criteria ('<SUCCESS LINE>') be achieved from these specs?
5. Any orphaned infrastructure (built but 0 callers)?
6. Any function signatures that don't match between producer and consumer specs?

VERDICT: COHERENT / GAPS FOUND / MAJOR GAPS. Max 400 words. Be specific about which spec produces and which consumes for every gap." 2>&1 | tail -60
```

**Replace:**
- `<N>` with spec count
- `<Sprint Name>` with sprint title
- `<sprint-prefix>` with the prefix (e.g., `sprint-29e`)
- `<SUCCESS LINE>` with the sprint doc's Success criteria

Use **120-second timeout**.

### Step 3: Present Results

**Do NOT tell Codex what `/sprint-cohesion` found.** Independence is the value.

```
### /codex-sprint-cohesion Result

**Sprint:** <sprint name>
**Specs reviewed:** <count>

**Raw Codex Output:**
<unmodified Codex response>

**Codex Verdict:** COHERENT / GAPS FOUND / MAJOR GAPS

**Assessment of Codex Findings:**
- [Finding 1]: AGREE / DISAGREE — <1 sentence + action if AGREE>
- [Finding 2]: AGREE / DISAGREE — <1 sentence + action if AGREE>
...

**Gaps to fix:** <list only AGREE findings that need spec changes>
```

If running alongside `/sprint-cohesion`, add a combined verdict:

```
### Combined Cohesion Verdict

| Review | Verdict | Unique Findings |
|--------|---------|-----------------|
| /sprint-cohesion (implementer model) | <verdict> | <count> |
| /codex-sprint-cohesion (other model) | <verdict> | <count> |

**Combined:** COHERENT / GAPS FOUND / MAJOR GAPS
**Fix before implementation:** <list all agreed gaps from both reviews>
```

---

## Failure Handling

| Failure | Output | Action |
|---------|--------|--------|
| Codex CLI not installed | "SKIPPED — install with `npm i -g @openai/codex`" | `/sprint-cohesion` alone gates |
| Codex timeout (120s) | "SKIPPED — Codex timeout" | `/sprint-cohesion` alone gates |
| No specs found | "SKIPPED — no specs matching prefix" | Check prefix |
| Codex reviews wrong specs | "SKIPPED — misroute detected" | Verify stdin pipe worked |

**If Codex unavailable:** SKIPPED. `/sprint-cohesion` alone gates implementation. Never block on infrastructure.

---

## What This Skill Does NOT Do

- Does NOT re-review individual specs (that's `/codex-cto` and `/codex-spec-review`)
- Does NOT check feasibility against real code (that's `/codex-cto`)
- Does NOT replace `/sprint-cohesion` (complementary, not replacement)
- Does NOT read code files — reviews specs only (cross-spec wiring focus)

This skill answers ONE question: **"Do these specs form a working system, or are there broken wires between them?"**

---

## Workflow Integration

```
/spec (per-spec, full process)
  → /codex-spec-review (per-spec, challenges assumptions)
  → /codex-cto + /staff-review (per-spec, validates)
  → repeat for all specs
  → /sprint-cohesion + /codex-sprint-cohesion (cross-spec, run in parallel)
  → fix gaps from both reviews
  → implement
```
