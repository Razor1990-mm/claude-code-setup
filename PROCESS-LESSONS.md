# Process Lessons — Battle-Tested Workflow Rules

This file distills hard-won lessons from running the spec-driven, dual-model workflow across many sprints on a real production codebase. Each rule is here because it was learned the painful way — from a recurring failure mode the user had to correct.

These lessons are agent-agnostic. They apply to Claude Code, Codex, Cursor, Windsurf, or any AI coding agent operating in a spec-driven workflow.

---

## 1. The Two-Model Principle

> **The model that writes it cannot be the only model that grades it.**

Same model writing code + tests = same blind spots. Same model writing specs + reviewing them = same blind spots. The whole reason the dual-model workflow exists is that **a single model cannot find its own blind spots**.

In practice this means:
- If model A writes the code, model B writes the killing tests for surviving Stryker mutants.
- If model A writes the spec, model B runs `/codex-spec-review` against it.
- If model A drives the `/pr` loop as fixer, model B is the reviewer (and severity is immutable — the fixer cannot relabel).

Whatever role flip you set up — Claude as implementer with Codex as reviewer, or vice versa — keep the boundary sacred. If it's ever violated, the entire pipeline reduces to circular validation, and the bugs the other model would catch ship silently.

---

## 2. Spec Phase — Non-Negotiable Rules

### Every spec gets the full process

No batch-writing, no "small slice = skip the interview." Explore → external research (docs, prior art) → interview (≥2 rounds) → write → validate. Specs that are too thin ("9 sub-detectors") are useless to an implementing agent. The interview must be self-sufficient for a cold-start implementor.

### Never skip interviews

Even for tiny slices. The reviewer model catches *technical* issues (wrong files, missing consumers); the human catches *direction* issues (PII policy, eval strategy, observability philosophy). Both are needed. The default is 2 rounds minimum. Continue beyond if the picture is incomplete.

### The validation loop is convergent, not single-pass

Run reviewer → if SIMPLIFY/RE-PLAN, fix → re-run. **Max 4 rounds.** A real example: a "World Simulator" spec took 3 rounds to reach PROCEED — round 1 caught wrong API endpoints, wrong auth, and an incompatible persistence model. Single-pass review would have shipped all 3 as day-1 implementation bugs.

### Specs design for parallelism

The TL;DR includes a `Parallelism:` line (day-1 slices, serial bottleneck, max agents). The slice table uses `Boundary` (directory-level scope) instead of exact file paths. The interview must ask "which slices can start on day 1?" — if only 1, restructure.

### Contract over implementation

Specs declare boundaries (`domain/intelligence/**`), not exact file paths. Paths are hints, not mandates. **Known Extensions** (shared files predictably touched: error exports, route registrations) are declared in-spec and in-scope from day 1. This avoids the "out of spec scope, must report blocker" trap on routine plumbing.

### Throughline check is mandatory

Every spec looks **BACKWARD** (previous 2 sprint docs — what infra was built that I should consume?) and **FORWARD** (roadmap — what future sprints depend on what I'm producing?). Surfaced as a "Throughline" section in the spec.

A real example: a simulation feature needed 3 iterations across 3 sprints because specs didn't check what previous sprints built FOR them or what future sprints need FROM them. Each spec passed individual review; the system didn't work.

### Consumer Chain section is mandatory

Every spec declares: what does this consume? what consumes its output? If either is "nothing," it's an orphan. A real example: a spec almost rebuilt a vector search feature when one already existed and was production-wired — the reviewer caught it because the implementer model never asked "who already does this?"

### Reviewer involvement is mid-spec, not just post-spec

Pull the reviewer model in during interview rounds, not only at validation. The reviewer catches systems-thinking flaws the writer misses by construction.

### Build vs Adopt is a required section

Always find ≥2 candidate approaches. External research is not optional, even for "simple" extensions. Each candidate must include a source link and a stack-fit assessment.

### Spec validation is the reviewer's day-1 job

When the reviewer model evaluates a spec, it must read the **real code** the spec references and verify file paths, function signatures, return types. The high-value catches are "this assumption is wrong because file X shows Y."

---

## 3. Sprint Cohesion — Mandatory For Multi-Spec Sprints

After ALL specs in a sprint pass individual review, run cohesion review **with both models independently**, then reconcile.

**Why dual:** Real example — one model found 1 P0 + 2 P1s; the other found 4 *additional* gaps the first missed entirely (write tools not setting `simulationRunId`, function signature mismatch, orphaned `package.json` script, unachievable success criteria). Different model = different gaps. **Always run both.**

What to check:
- Every spec output has a consumer
- Every spec input has a producer
- No orphaned infrastructure (built but 0 callers)
- Previous sprint's infra is consumed, not rebuilt or ignored
- Next sprint's dependencies are established
- Sprint success criteria is achievable from the sum of specs
- Event chains wired end-to-end across specs

Skip rule: single-spec sprints, pure refactoring, or user explicitly says "skip cohesion."

**Post-merge re-cohesion:** after merging a dependency sprint to main, re-run cohesion review on the next sprint's specs against the *real merged code* — function signatures may have shifted during implementation.

---

## 4. Implementation Phase — Hard Rules

### TDD by default

Tests first, RED-GREEN-REFACTOR. Invoke the TDD workflow as a skill — never replicate it manually. The skill enforces RED phase, depth checklist, label conventions, and the test-depth gate.

### Existing tests are sacred

If code breaks an existing test, **the code is wrong**. Never modify the test to make code pass. Report as a blocker. No exceptions — not "just updating the expected value," not "the test was outdated," not "the interface changed."

### Files outside spec scope are off-limits

If implementation requires editing a file outside the spec's declared boundary + Known Extensions, **STOP and report as blocker.** Do not silently edit.

### Mid-flight discoveries get an explicit log entry

If the spec is technically impossible (function doesn't exist, type is wrong), append a `[DISCOVERY]` entry to the spec changelog, fix the spec, continue. If the spec has a typo-level error (wrong filename, wrong field name), append a `[CORRECTION]` and continue. **3+ discoveries in one session = stop and re-plan.**

### Inline mutation testing per file

After GREEN on each domain file, run scoped mutation testing (e.g., `npm run mutate -- --mutate 'src/domain/<file>.ts'`). If <80%, write more tests before moving on. Cross-file mutation testing still runs post-PR. **TDD first, mutation second** — never skip RED-GREEN.

### Commit frequently

60–140 LOC production per commit (~300 LOC including tests is normal under TDD). One concern per commit. Uncommitted work is lost work.

### Stay on the working branch

Never `git checkout main` after committing. The only time to touch main is when the user explicitly says "merge."

### Never `--no-verify`

Pre-commit hooks are quality gates. Pre-existing failures still need fixing or an explicit user decision — never silently skipped. Suggesting `--no-verify` is a corner-cutting signal.

### Pre-commit checklist before every commit

Walk the diff against the pre-commit checklist. A real data point: in one 213-commit window, **34% were fix commits from review rework** — almost all caught by the same 9-section checklist. The top 4 sections (queries, timeouts, observability, null handling) cover 59% of historical rework.

---

## 5. Worktree Rules (Critical Operational Hazards)

### NEVER `npm install` from a worktree

Worktrees share the root repo's `node_modules` via npm workspaces. Concurrent installs from multiple worktrees corrupt the directory with `"package 2"` collision dirs. A real incident: 277 corrupted dirs, ~4GB of duplicate node_modules across 7 worktrees.

**Instead:** symlink the worktree's `node_modules` to root: `ln -s "$(git rev-parse --show-toplevel)/node_modules" node_modules`.

### Worktrees branch off the sprint branch, not main

Pattern: `main → sprint-N/name → worktree branches → merge back to sprint-N/name → PR to main`. Worktree PRs target the sprint branch, not main. The sprint branch PRs to main when the entire sprint is done.

A real incident: PRs were created targeting main instead of the sprint branch and required recovery via merging main back into the sprint branch.

### Parallel agents own exclusive files

Schema/shared bottleneck files (`schema.prisma`, `errors.ts`, `events.ts`, `testHelpers.ts`, `app.ts`) are owned by a single infrastructure agent. Schema slices are serial.

---

## 6. Test Quality Rules

Mutation testing (Stryker) proved (validated 2026-03-27) that ~45% of mutations in domain code survive when the same model wrote both the code and the tests — same blind spots.

### Ban shape-only assertions

`toHaveProperty`, `toBeDefined`, `typeof === "string"`, bare `toBeGreaterThan(0)` are banned without a paired value assertion. `toHaveProperty("severity")` passes when severity is `"BANANA"`. Every `expect` on a domain return value must assert a *specific value*: `toBe`, `toEqual`, `toContain`, `toBeCloseTo`.

### Boundary values are mandatory

Test at exactly the boundary, not safely above/below. If the code says `>=50`, test 49, 50, 51 — not 30 and 70.

### Arithmetic results pinned

No "is positive" hand-waving. If the code does `a / b * 100`, assert the exact result.

### String outputs need content assertions

`toContain()` or `toBe()`, not just type checks.

### E2E integration tests catch what unit tests miss

Mock only the DB, not internal components. A real example: 5 staging gaps that all passed unit tests in isolation. The seam between components (`step1 → step2 → step3`) was never exercised together; mock shapes had drifted from real data.

### Subagents skip TDD by default

They write production code first, then bolt tests on. When delegating implementation, **explicitly instruct RED-GREEN-REFACTOR ordering** in the prompt and verify by checking commit order in git log.

### Mutation score ≥80%

On every changed domain file. Definition-of-Done item, not optional.

---

## 7. PR Review Phase — The Adversarial Loop

### Run all three reviews in parallel

Launch the implementer's `/review` (general), `/codex-code-review` (production-readiness), and `/codex-pr-review` (strategic) in parallel after the branch is committed and pushed. Triple review was validated across 32 commits — near-zero overlap, each catches different things.

### Pass the spec path explicitly

Spec adherence checks silently skip when the path isn't passed. A real failure: a sprint had specs ignored entirely because the review pipeline never read them. If a spec exists and the review doesn't produce a traceability table, the spec path wasn't passed.

### Severity is immutable

The reviewer says P0; the fixer does not get to downgrade it to P2 because "out of scope." If found in changed files, it's in scope. Only the user may override a P0.

### Never dismiss a P0 based on assumptions

Verify against real docs/code first. A real failure: a fixer dismissed a valid P0 about library path resolution based on the assumption that paths resolved relative to cwd. They didn't. The reviewer was right. **Always verify before dismissing.**

### Allowlist only

The fixer edits only files explicitly in the allowlist for that finding. Max 5 fixes per cycle, max 3 files per fix, max 30 LOC per fix. Anything bigger needs human approval.

### Full verify after every fix cycle

Lint + typecheck + full test suite. Not just affected tests.

### Re-review after P0 fixes — every time

Don't skip. The fix for "missing setup pipeline" can introduce new gaps. Re-run both reviewers in parallel before declaring SHIP IT.

### Max 2 cycles, then human decides

Convergence beyond cycle 2 means the disagreement is structural and needs human judgment.

---

## 8. Mutation Hardening — The QA Gate

When the implementer model writes the code, **the other model writes the killing tests.**

1. After PR merges, run `npm run mutate` (full) or scoped to changed files.
2. Look at surviving mutants in: threshold logic, boundary conditions, classification/severity, arithmetic. AI-written code is weakest there.
3. The *other* model writes additional tests to kill the mutants. The "QA engineer who didn't write the code" pattern.
4. Re-run mutation testing. Target ≥80% on changed files.
5. **Run on every PR.** Not just post-sprint. The "post-sprint pass" framing is a footgun — it's the easiest gate to skip.

### Structural exemption

Surviving mutants in unawaited fire-and-forget observability calls (e.g., `writeEvent().catch()`) are excluded from the 80% target. These are observability payloads, not business logic — making them awaitable would put event writes on the critical path. **The exemption applies ONLY to this pattern.** Surviving mutants in conditionals, thresholds, classification, or any business logic branch are real gaps and must be killed.

---

## 9. Honesty And Anti-Confabulation

### Read memory files before asking or planning

Short MEMORY.md descriptions are pointers, not content. "You know this" is what users say when an agent has files listed in its system prompt but hasn't opened them and is asking questions whose answers are already saved.

### Never fabricate output from code templates

If you read a template like `severityReason: \`${d.issueType}: ${d.outcomeCount} jobs...\`` and present "DRYWALL: 5 jobs, 22.5%" as if it were observed output, you are confabulating. You did not run the code, you did not observe the string.

- **Acceptable:** "the template would produce strings shaped like X."
- **Unacceptable:** "each produces strings like Y" with concrete values.

### Tense discipline

"X produces Y" (present indicative, implies runtime fact) vs "X would produce Y when run with Z" (conditional, honest about the limit). The first is a commitment.

### Pipeline blind spots are real

Stop being overconfident. Many pipeline branches have never been exercised end-to-end. Assume a gap until you've actually run it.

### Demand proof, not vibes

Claims about correctness must be backed by tests, logs, or reproducible checks. Paste proof in full unless explicitly told to summarize.

### Three contributing factors to confabulation, watch for each

1. **Synthesis mode after long reading sessions** — after 30+ minutes of reading, the line between "what the code says" and "what it does when run" blurs. Force a reset: "I have not executed this."
2. **Pressure to produce after a greenlight** — the user approved a phase and the model felt it owed output. Better: "trace complete, need a running backend to verify the actual output — should I set it up or trust the shape?"
3. **Blending tenses** — see above.

---

## 10. Pattern Extraction Discipline

### Three questions before every fix

1. **Is this cool?** Taste gut-check. Would you be proud to show someone this solution?
2. **Does this pattern extend?** Name 2+ other places in the codebase where the same shape would apply. If you can't, it's a one-off.
3. **Is it repeatable?** If you had to do this fix 5 more times, would those instances share code or diverge?

### Extract narrow helpers before the second instance, defer opinionated abstractions until the third

Both **rushing to fix** (no extraction, duct tape compounds) AND **rushing to abstract** (premature factory based on one data point + pseudocode) are failure modes of the same shape — acting on one data point without real integration pressure.

- **Instance #1:** build the feature.
- **Before instance #2:** extract the *unambiguously shared* pieces as small composable helpers (a grounding fetcher, a bounded LLM invoker). Do NOT build a factory yet — you don't know its shape.
- **Instance #2:** build on the helpers. Add to them if they're insufficient (small additive change, no restructure).
- **Instance #3:** now look at the diff between instances #1 and #2. If a factory shape is obvious, extract it as #3 lands.

A real failure: an implementer proposed a full factory extraction after just one instance. The reviewer flagged 9 P1 findings — the factory return contract didn't fit the existing caller, the function signature assumed a parameter the target functions didn't accept, instance #2 needed something the factory didn't have. Lesson: **rushing to a factory bakes in a shape based on one data point + pseudocode for the next, and the pseudocode is always wrong because it doesn't survive contact with real APIs.**

### Red flags

- "We can abstract this later" → you'll forget or it'll compound.
- "The second one will look the same so let me copy-paste" → no, you're creating an orphan.
- "Let me write the factory now before instance #2" → you don't know the factory shape yet.
- Proposing a new enum/migration for a pattern that "needs" them → **grep first.** A real failure: an implementer proposed a `WorkerType` enum for `SYSTEM` workers; the pattern already existed as a string field with a helper function.
- Editing the top of a plan cleanly but leaving stale pseudocode in deep sections → re-read end-to-end every time.

---

## 11. Stay-In-Lane Rules

### Don't advise on business timing, sales, or GTM

The user knows the market. When asked to evaluate a technical plan, evaluate the *technical* plan — gaps, execution risks, missing features, wrong sequencing. Don't layer on "you should get a customer first" or "you need to sell before building."

### Reviewer findings strip business advice

Keep: technical gaps, execution risks, sequencing, missing features, scope cuts. Remove: business timing opinions, distribution advice, GTM strategy.

### The architecture is approved

Don't introduce new infrastructure (queues, message buses, new databases, new services, new platforms) without explicit approval. The 10x scale / Series A audit / simplest correct solution filters apply to every decision.

---

## 12. Taste Is A Separate Gate

The correctness pipeline (`/codex-cto`, `/staff-review`, `/sprint-cohesion`, `/codex-code-review`, `/codex-pr-review`) does **not** catch tasteless product. **Taste needs its own review loop with its own reference.**

- **Correctness gate** = reviewer + cohesion checks. Answers: is this right, does it wire up, is it safe.
- **Taste gate** = review against your project's voice spec + restraint check + specificity check + "kill one surface" discipline. Answers: does this feel like a person, does this have restraint, is every sentence specific and warranted.

### Voice spec is a functional contract

If your project has a voice spec with canonical sentences, **each sentence is a functional contract.** If a sentence references behavior the product cannot produce today, that sentence is pointing at a missing feature. Sanity-check user-facing surfaces against the voice spec; if a mock pattern-matches a canonical sentence, verify the backing feature exists. Otherwise it's a "voice lie."

### Taste rules

1. Every on-screen string passes the "would my product say this?" test against the voice spec.
2. Run by a human with design sense, not the reviewer model. The reviewer tells you it's correct; a designer tells you it's boring.
3. **Restraint check** — kill one surface from every mock deck before shipping. If you can't cut anything, you haven't designed yet.
4. **Specificity check** — every number, name, and timestamp must be real or plausible. "Your numbers are high" fails. "Garcia owes $47k, 23 days late" passes.
5. **One weird detail rule** — every major surface gets one authored detail a template would never produce. If you can't name the weird detail, the surface has no taste.

---

## 13. Cohesion Over Features

Every new feature must wire back to the core system. No bolted-on features. The product should feel like one cohesive system, not a collection of tools.

- Before building any new feature, ask: **what existing system does this connect to? what consumes its output?** If neither has an answer, don't build it.
- Frontend and backend for the same capability should ship in the **same sprint or consecutive sprints**, not 3 sprints apart. The "12 backend systems with no frontend" anti-pattern is real.
- **Gold-standard replication** beats reinvention. When adding a capability to multiple agents/nodes, implement it in *one* (the gold standard), verify it works, then replicate the *exact* pattern. Don't adapt or "improve" during replication.

---

## 14. Evals Gap (AI-Native Blind Spot)

It's possible to build many sprints of operational readiness without any eval infrastructure. The gap: the LLM gets treated as a black box, not a system with its own engineering discipline. Standard rules and review gates are infrastructure-shaped (multi-tenancy, idempotency, CAS, FK ordering); nothing about the intelligence layer.

**The rule:** when reviewing any spec or roadmap that involves an LLM-powered decision, ask:
- How do we know the agent is right?
- What is the eval criteria?
- What is the accuracy baseline?
If there's no answer, the spec is incomplete.

### The four required pieces for any LLM feature

1. **A golden dataset** — known-good input/output pairs, version-controlled
2. **An accuracy baseline** — measurable score on the golden dataset
3. **A regression suite** — runs on every PR that touches the prompt or model
4. **A red-team suite** — adversarial inputs designed to break the agent

Without these four, the feature ships blind. You won't know it's degrading until a customer reports a bad output.

---

## 15. The Hard-Won "Never" List

- Never modify existing tests to make code pass.
- Never `--no-verify`.
- Never `git checkout main` after committing on a feature branch.
- Never `npm install` from a worktree.
- Never branch worktrees off main (branch off the sprint branch).
- Never write sim-specific or environment-specific logic inside production domain files.
- Never add a mechanical fallback to an LLM judgment call — fail-closed.
- Never dismiss a P0 finding as "out of scope" or based on assumptions — verify first.
- Never build a feature with no consumer.
- Never present template fill-ins as observed output.
- Never advise on business timing, sales, or GTM unless explicitly asked.
- Never ship a user-facing string that pattern-matches your voice spec without verifying the backing feature exists.
- Never extract a factory abstraction before the second real instance.
- Never skip mutation testing on a PR because "we'll do it post-sprint."
- Never skip the spec interview rounds.
- Never let one model both write and grade the same code.

---

## How To Use This File

Read it once at the start of a project to internalize the workflow philosophy. Read it again whenever something feels off — there's probably a rule here that names the failure mode. The rules are not arbitrary; each one is here because the absence of it caused real damage on a real codebase, and the fix was painful enough to be worth writing down.

When in doubt: **the model that writes it cannot be the only model that grades it.**
