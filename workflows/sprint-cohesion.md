# /sprint-cohesion — Cross-Spec Coherence Review

Validates that all specs in a sprint form a working system together. Catches the #1 cause of integration failures: specs that pass individual review but don't connect.

**Usage:** `/sprint-cohesion` or `/sprint-cohesion <sprint-doc-path>`

**When to run:** After ALL specs for a sprint are written and individually validated, BEFORE starting implementation. This is the gate between "specs done" and "implementation starts."

---

## Why This Exists

A real example: a simulation feature needed 3 iterations across 3 sprints because specs were validated individually but nobody checked cross-spec wiring. Departments were built but the simulation never called them. Infrastructure was created with 0 callers. Each spec passed review in isolation; the system didn't work.

**Always pair with `/codex-sprint-cohesion`** — different model, different blind spots. Run both, reconcile findings.

---

## Process

### Step 1: Gather All Specs

1. Find the sprint doc in `docs/sprints/` matching the current branch or user-specified path
2. Read the sprint doc's slice table — extract all slice titles
3. Find all spec files in `specs/` that belong to this sprint (match by sprint number or name)
4. Read each spec file completely

### Step 2: Build the Integration Map

For each spec, extract:
- **PRODUCES:** What does this spec create? (new domain functions, new models, new routes, new events, new data)
- **CONSUMES:** What does this spec need from other specs or existing code? (functions it calls, data it reads, events it listens for)
- **FILES TOUCHED:** Full file list from each spec

Build an integration matrix:

```
| Spec | Produces | Consumed By |
|------|----------|-------------|
| 29E.1 | WorkOrderOutcome, Call, Correction seed data | 29E.4 (day loop needs seeded data), 29E.5 (correction generator reads outcomes) |
| 29E.2 | Event scanning | 29E.5 (corrections trigger event scanning) |
```

### Step 2b: Systems Check

Read your project's infrastructure overview (e.g., `docs/architecture/INFRASTRUCTURE.md`). For each spec, verify:
- If the spec builds a queue → is it using the existing queue pattern?
- If the spec builds an agent → is it using the existing agent framework?
- If the spec adds analysis → is it using existing reasoning/analysis primitives?
- If the spec adds learning → is it wiring the existing correction/feedback retrieval?
- If the spec emits events → is it using the existing event system?
- If the spec does LLM calls → is it using the existing tracing/observability layer?

**Red flags:**
- Spec builds a new in-memory queue when a real queue exists
- Spec builds a custom agent loop when a framework exists
- Spec builds custom scheduling when a heartbeat worker exists
- Spec builds parallel event dispatch when a dispatcher exists

### Step 3: Look BACKWARD (Previous Sprints)

Read the previous 2 sprint docs (`docs/sprints/`). For each:
- What infrastructure was built?
- Is the current sprint USING it?
- If not — WHY NOT? Is it intentional (out of scope) or an oversight?

**Red flags:**
- Previous sprint built a function with 0 callers that THIS sprint should be calling
- Previous sprint's success criteria included something this sprint was supposed to consume
- Functions exist in `domain/` (or equivalent) that match this sprint's problem but aren't referenced in any spec

### Step 4: Look FORWARD (Roadmap)

Read the roadmap. For the NEXT sprint after this one:
- What does it expect to exist?
- Is this sprint setting it up correctly?
- Are there assumptions about data models, APIs, or infrastructure that this sprint should establish?

### Step 5: Check for Orphans and Gaps

**Orphan check (within sprint):** For every PRODUCES entry, verify at least one spec (or existing code) CONSUMES it. Infrastructure with 0 consumers is an orphan — either the sprint is missing a spec or the infrastructure shouldn't be built.

**Cross-sprint orphan check (previous 2 sprints):** For each spec in the current sprint, check: does this spec's output have a consumer OUTSIDE its own files? Specifically:
- Read exports from the previous 2 sprints' touched files
- For each exported function/type: grep for imports across the codebase (excluding the file's own test)
- Flag any export that has fewer consumers than expected — e.g., a search function only called by its test, a state field only populated but never read downstream, a reasoning type that produces outputs no agent consumes
- This is NOT "zero callers" — it's "does the output reach its intended consumer?" A function with 1 caller (its tool wrapper) but no agent using that tool is still an orphan.

**Gap check:** For every CONSUMES entry, verify the producer exists — either in another spec or in the current codebase. If neither, the spec has an unmet dependency.

**File conflict check:** Do any specs touch the same file? If yes, are they aware of each other? Concurrent modifications to a shared file from two specs = merge conflict.

**Event chain check:** Trace event flows across specs. If spec A emits `EVENT_X` and spec B subscribes to it — are the event payloads compatible? Is the dispatch mechanism wired?

### Step 6: Verify Sprint Success Criteria

Read the sprint doc's TL;DR "Success" line. Can this outcome be achieved by the sum of all specs? Walk through the end-to-end flow that would demonstrate success, citing which spec handles each step.

If any step in the success flow has no spec covering it — that's a P0 gap.

### Step 7: Check Learning Loop (if applicable)

For sprints that involve LLM agents or simulation:
- What does the system LEARN from this sprint's work?
- Are corrections/outcomes/insights vectorized or fed back?
- If an agent runs 100 times, is run 100 better than run 1? Which spec ensures this?

---

## Output Format

```
## /sprint-cohesion Result

**Sprint:** <sprint name>
**Specs reviewed:** <count>

### Integration Matrix

| Spec | Produces | Consumed By | Status |
|------|----------|-------------|--------|
| <spec> | <outputs> | <consumers> | WIRED / ORPHANED / PARTIAL |

### Backward Check (Previous Sprints)

| Previous Sprint | Infrastructure Built | Used by This Sprint? | Status |
|-----------------|---------------------|---------------------|--------|
| <sprint> | <what was built> | YES / NO — <which spec uses it or why not> | OK / GAP |

### Forward Check (Roadmap)

| Next Sprint | Expects | This Sprint Provides? | Status |
|-------------|---------|----------------------|--------|
| <sprint> | <dependency> | YES / NO — <which spec or why not> | OK / GAP |

### Orphans Found
- <spec.slice> produces <X> — 0 consumers found. **Action:** <add consumer or cut the work>

### Gaps Found
- <spec.slice> consumes <X> — no producer exists. **Action:** <add spec or wire existing code>

### File Conflicts
- <file> touched by <spec A> and <spec B>. **Risk:** <merge conflict / ordering dependency>

### Event Chain Verification
- <event> emitted by <spec A>, consumed by <spec B>. **Status:** WIRED / BROKEN — <why>

### Success Criteria Walkthrough
1. <step> — covered by <spec> ✓
2. <step> — covered by <spec> ✓
3. <step> — **NOT COVERED** — gap

### Learning Loop Check
- System learns: YES / NO / PARTIAL
- <what's learned, what's not>

### VERDICT: COHERENT / GAPS FOUND / MAJOR GAPS

**COHERENT:** All specs connect. Start implementation.
**GAPS FOUND:** Addressable gaps listed above. Fix before implementation.
**MAJOR GAPS:** Sprint design is incomplete. Missing specs or fundamental wiring issues.
```

---

## When NOT to Run

- Sprint has only 1 spec (no cross-spec integration to check)
- Sprint is pure refactoring with no new infrastructure
- User explicitly says "skip cohesion"

## Relationship to Other Skills

| Skill | When | What it checks |
|-------|------|---------------|
| `/spec` | Per-spec | Individual spec quality + throughline |
| `/sprint-cohesion` | After all specs | Cross-spec wiring + orphans + gaps |
| `/codex-sprint-cohesion` | Same time as above | Independent second opinion (different model) |
| `/sprint-closeout` | After implementation | Did we build what we said? |
| `/codex-cto` | Per-spec | Feasibility against real code |
| `/staff-review` | Per-spec | Engineering quality + filters |
