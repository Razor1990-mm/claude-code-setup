---
name: spec
description: Write an upfront spec for a feature, hardening task, or refactor
---

Write a spec interactively using AskUserQuestion, then save to `specs/<name>.md`.

**Usage:** `/spec` or `/spec --type hardening` or `/spec --type refactor`

---

## Step 0: Parse Arguments + Select Posture

Parse `$ARGUMENTS` for `--type feature|hardening|refactor` (default: feature). No mode flags — every spec gets the full process.

**Before doing anything else, ask the user to pick a posture:**

Use AskUserQuestion with this prompt:

```
What posture should I take for this spec?

1. DREAM BIG — Find the 10-star version. Push scope UP. "What would make this 10x better for 2x the effort?"
2. HOLD SCOPE — Your scope is accepted. Make it bulletproof. Catch every failure mode, edge case, and test gap.
3. STRIP TO ESSENTIALS — Find the minimum viable version. Cut everything that isn't the core outcome.

Pick 1, 2, or 3 (default: 2 — Hold Scope):
```

**Commit to the chosen posture for the entire spec.** Do not silently drift. If DREAM BIG, do not argue for less work. If STRIP, do not sneak scope back in.

---

## Spec Process

1. **Explore codebase**: Spawn an Explore agent (haiku) to map the relevant domain area BEFORE asking the user anything:
   - Existing domain functions, patterns, and data flows related to the problem area
   - Similar features already built (how was the analogous problem solved?)
   - Current schema models, relationships, and constraints involved
   - Test coverage for the area
   - Output: a "Prior Art" brief — "here's how the codebase currently handles related problems"
2. **External research**: Use WebSearch and Context7 to find how production systems solve this:
   - Search for established frameworks, libraries, or patterns relevant to this problem
   - Check if dependencies already in your project have built-in features for this (use Context7 to query their docs)
   - Search for architecture patterns used at similar scale
   - Output: 2-5 candidate approaches with source links, labeled "build custom" vs "adopt existing"
   - **Quality gate**: Each candidate must include: (a) source link, (b) whether it fits this codebase's stack, (c) 1-line fit assessment. Generic blog posts without actionable specifics do NOT count.
3. **Interview**: Use AskUserQuestion. **Present Prior Art + External Research findings as the first message.** Minimum 2 rounds mandatory.
   - Round 1: Present findings + gather core requirements. Ask: "Given what exists in the codebase and what's available externally, which direction do you want to go?"
   - Round 2: Scope boundaries, edge cases, architecture decision, Build vs Adopt call
   - Continue beyond 2 rounds if the picture is still incomplete.
   - **Posture shapes the interview**: DREAM BIG → actively suggest expansions and "what if we also...". HOLD SCOPE → focus on edge cases and failure modes. STRIP → challenge every requirement with "do we actually need this for v1?"
4. **Write spec**: Use the template below. Save to `specs/<name>.md`
5. **Validate**: Run `/codex-cto` (feasibility) and `/staff-review` (design quality) in parallel.
6. **Done**: "Spec validated. Ready to implement."

---

## Interview Questions (adapt to type)

**Feature:**
- What problem does this solve? Why now?
- Given what already exists in the codebase and what's available externally, which approach fits best?
- What's the acceptance criteria? (specific, testable)
- What's explicitly out of scope?
- Which external systems are involved?

**Hardening:**
- Which area/invariant are you hardening?
- What's the current state? (existing coverage, known gaps)
- Are there framework-level solutions we're not using?
- What specific invariants must hold after this work?

**Refactor:**
- What code are you refactoring and why?
- What patterns does the rest of the codebase use for this?
- Is there an established pattern or library that does this better?
- What's the target structure?
- Which existing tests must still pass?

---

## Spec Template

```markdown
# <Type>: <name>

## Prior Art
What already exists in the codebase for this problem area. File:line references.
- Existing patterns: <how similar problems are solved today>
- Related domain functions: <list with signatures>
- Related models: <schema models involved>

## External Research
What frameworks, libraries, and patterns exist externally.
Each candidate must have: source link + stack fit assessment + actionable specifics.
- <Approach 1>: <description> — <source link> — Fits: YES/NO because <reason>
- <Approach 2>: <description> — <source link> — Fits: YES/NO because <reason>

## Build vs Adopt Decision
| Option | Pros | Cons | Effort |
|--------|------|------|--------|
| Build custom | <pros> | <cons> | <S/M/L> |
| Adopt <framework/library> | <pros> | <cons> | <S/M/L> |
| Extend existing pattern | <pros> | <cons> | <S/M/L> |

**Chosen:** <option> — <1 sentence why>

## Problem
What's broken or missing. Why now.

## Requirements
- Acceptance criteria (testable, specific)
- Edge cases to handle
- What's explicitly out of scope

## Control Flow Design
How the solution is structured. Pick ONE and justify against alternatives:

| Pattern | When to use | Fits this problem? |
|---------|-------------|-------------------|
| Single domain function | Pure data transform, no side effects | Yes/No — why |
| Pipeline (sequential steps) | Multi-step, explicit ordering, clear I/O per step | Yes/No — why |
| State machine | Entity lifecycle with guarded transitions | Yes/No — why |
| Deterministic workflow | External calls, retries, timeouts, compensation | Yes/No — why |
| Framework feature | Solved by existing dependency | Yes/No — why |

**Chosen:** <pattern> — <1 sentence why this over the alternatives>

## Design
- Entry points (files + functions)
- Data flow (which tables, which domain functions)
- External systems touched

## Files Touched
| File | Change | Why |
|------|--------|-----|
| `domain/foo.ts` | Modify | Add new function |
| `domain/__tests__/foo.test.ts` | Create | Tests for new function |

## Constraints
<!-- CUSTOMIZE: Adapt these constraint categories to your project -->
- Multi-tenancy: which queries need org/tenant scoping
- Idempotency: which operations could retry
- CAS patterns: which state transitions need optimistic concurrency
- Security: auth pattern, PII considerations
- Events: which event types are used/created

## Stop Conditions
- If any existing test breaks, STOP — fix the code, not the test
- If you need to modify a file outside the Files Touched table, STOP and report as blocker

## Verification
- Test cases (input -> expected output)
- Manual verification steps
- What "done" looks like
```

---

## Spec Quality Checks (before saving)

- Every requirement is testable (not vague like "improve performance")
- Entry points reference real files (read them to verify)
- Constraints section addresses multi-tenancy if domain files are touched
- At least 2 test cases in Verification (1 happy path, 1 failure)
- Out-of-scope section is non-empty (forces explicit scoping)
- **Prior Art section references real files with line numbers** (not vague descriptions)
- **Files Touched table is complete** — every file you plan to touch is listed
- External Research has at least 2 candidate approaches with source links and fit assessments
- Build vs Adopt decision has a clear winner with justification
- Control Flow Design table has all 5 patterns evaluated with Yes/No + reason

## Session Sizing

- Target: 200-400 LOC **production code** per spec (TDD adds ~2-3x test code on top)
- If a spec would need >4 implementation commits, split into two specs
- The `/pr` review-fix loop typically adds 1 fix commit — plan for N+1 total commits
- Typical session: 2-4 implementation commits + 1 review-fix commit
