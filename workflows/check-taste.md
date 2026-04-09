# /check-taste — Frontend Taste Validator

## Purpose

Frontend specs and mocks pass correctness review (CTO, staff-review, cohesion) but ship hollow. This skill is the **taste gate**: validates that a frontend spec or mock would actually feel like the product you set out to build, not like generic AI ops software.

This is NOT a correctness review. It's a lens. Correctness review asks "is this right." This asks "does this feel authored, does it have restraint, would a real user feel like they got something made for them."

## Usage

```
/check-taste <spec-file>
/check-taste specs/sprint-32-conversation-shell.md
/check-taste docs/mocks/home-v1.md
```

Target can be:
- A spec file (`specs/*.md`)
- A mock doc
- A markdown file with example copy / UI strings
- An HTML mock (will extract visible strings)

## Reference Documents (read these first, every run)

Before checking anything, you MUST load:

1. **Your project's voice spec** — typically `docs/design/voice.md` or similar. The canonical sentences, tone principles, anti-patterns. This is the ground truth.
2. **Any feedback memory** about voice-as-contract — sentences referencing unbuilt features are blockers, not copy.
3. **Any feedback memory** about taste being a separate gate — the discipline this skill enforces.

If the voice spec is missing, STOP and report — the skill cannot run without it. Taste is not a vibe; it's measured against a written reference.

## What It Checks

### 1. Voice compliance — every user-facing string

Extract every visible string from the target doc (dialogue, button labels, empty states, error messages, toast copy, placeholder text, loading states, example chat messages). For each string, judge against the canonical sentences in the voice spec.

**Flag as VIOLATION:**
- Exclamation points outside of genuine alarms
- "Great!", "Awesome!", "Happy to help", "I hope this helps", "Let me know if you need anything else"
- "I'm just an AI, but...", "As your AI assistant..."
- "Here is a summary of..."
- Emojis anywhere in user-facing copy (unless your project explicitly allows them)
- Numbered lists when a sentence would do
- Uptalk phrasing ("Would you like me to...?")
- Any sentence that could plausibly come from ChatGPT's default voice
- Generic empty states ("No items yet", "Nothing to show")
- Generic loading states ("Loading...")
- Sycophantic acknowledgments ("Great question!", "Good point!")

**Flag as WEAK (not a violation but tasteless):**
- Strings that are grammatically correct but texture-free ("Your numbers are high")
- Copy without real numbers, names, or timestamps when the context would naturally provide them
- Strings that don't sound like the persona locked in your voice spec
- Missing the warm anticipatory beat (the moment that signals you've already noticed, already handled, already protected the user from themselves)

### 2. Voice-as-contract check

For every string that references the agent's knowledge or action, verify the backing feature exists or is explicitly scoped.

If the spec contains a string whose backing capability isn't built AND the spec doesn't explicitly scope it: **BLOCKER**. This is a voice lie and it will ship hollow.

**Examples of claim-shapes that imply unbuilt features:**

| String pattern | Required capability |
|---|---|
| "I noticed you've [done X repeatedly]..." | Pattern detection + learning loop |
| "You asked me last week to..." | Persistent user directives across sessions |
| "I drafted a nudge in your voice..." | Tone-conditioned drafting |
| "Before you ask: [proactive action]" | Event monitoring + anticipation |
| "[Personal context] is tomorrow at 6" | Calendar integration / non-work context |
| "I'm going to stop suggesting X and default to Y" | Confirmed learning application |
| "[Agent] learned X this week" | Visible teaching loop |

For each match, verify the backing capability exists. If not built and not scoped → BLOCKER.

### 3. Restraint check

Count the number of distinct surfaces, pages, panels, tabs, or sections the spec proposes.

**Flag as VIOLATION:**
- More than 4 top-level surfaces in a single frontend spec (restraint is taste)
- Any surface whose purpose can't be named in one sentence
- Any surface that exists "for completeness" rather than for a specific user job
- Dashboards with more than 8 cards on the primary view
- Tabs within tabs
- Any UI element that exists because "users might want to..." (speculation, not observed need)

**Ask the spec:** "If I had to kill one surface, which would it be?" If the spec can't name one, the spec hasn't chosen — it's listed.

### 4. Specificity check

Taste lives in specifics. Scan for:

**Flag as WEAK:**
- Placeholder copy like "Lorem ipsum" or "Example text here" in user-facing surfaces (acceptable in layout-only diagrams, not in voice-bearing mocks)
- Vague numbers ("your receivables are high" vs "Garcia owes $47k, 23 days late")
- Generic names ("Customer A", "Job 1") instead of plausible real-world names
- Missing timestamps on time-sensitive copy
- Aggregate statements without evidence ("sales are down") when the real product would cite sources

### 5. "One weird detail" check

For each major surface the spec proposes, find the **one authored detail** that a template wouldn't produce. This is the taste marker: the thing that makes it feel like it was made by someone, not generated.

Examples of acceptable weird details:
- A specific way the agent signs off at end of day
- A particular micro-interaction when a learning gets confirmed
- An unusual empty state that has character ("Quiet morning. Three on the books, nothing flagged.")
- A sentence only this product would say
- A visual moment that surprises (not flourish for flourish's sake, but a moment of character)

**Flag as WEAK:** Any major surface where you cannot name the one weird detail. If you can't name it, it doesn't exist, and the surface has no taste.

### 6. Anticipation check (the "already handled" move)

The agent should feel like it has already handled things before the user arrives. Scan the spec for:

**Flag as VIOLATION:**
- Surfaces whose primary affordance is "click to take action" without any "already handled" beats
- Morning briefs that lead with open tasks instead of closed ones
- Dashboards that show state without showing what the agent did about it
- Empty states that don't acknowledge the agent's presence ("No new items" vs "Quiet so far. I'm watching.")
- Any surface where the user opens it and the experience is "here's your work" rather than "here's what I've already moved on"

**The rule:** Every surface should have at least one "already handled" beat visible in the first 3 seconds. If the spec doesn't show one, it's software, not a coworker.

### 7. Voice consistency

Whatever persona your voice spec locks (formal, casual, regional, gendered, era-specific), check that every string holds it.

**Flag as WEAK:**
- Copy that drifts to gender-neutral corporate voice when the persona is specific
- Copy that drifts in register (too formal vs too casual relative to the spec)
- Any string that wouldn't work if you imagined the persona reading it aloud

## Output Format

Produce a structured report, grouped by severity:

```
## Taste Check Report

**Target:** <file path>
**Reference:** <voice spec path> (loaded)
**Verdict:** BLOCK | CONDITIONAL | PASS

---

### BLOCKERS (must fix before ship)

1. [VOICE LIE] Line 42: "I noticed you've been overriding my markup..."
   - Claim: pattern-detected learning
   - Backing capability: NOT BUILT
   - Fix: either scope the prerequisite, or rewrite to match current capability

2. [ANTI-PATTERN] Line 108: "Great! Your quote has been sent!"
   - Violates: no exclamation points outside alarms, no "Great!"
   - Suggested rewrite: "Quote's out. Henderson has it."

### VIOLATIONS (fix before review)

...

### WEAK (taste debt, address if possible)

...

### WHAT THIS SPEC GETS RIGHT

(Name the 1-3 things that actually have taste. Be specific.)

### THE ONE WEIRD DETAIL TEST

For each major surface, name its weird detail. If you can't: flag it.

- Home / Morning Brief: <weird detail, or MISSING>
- Schedule view: <weird detail, or MISSING>
- ...

### RESTRAINT CHECK

Surfaces proposed: N
Could cut: <name the one that should go, or say "none — the spec has restraint">

### THE READ-ALOUD TEST

Read the spec's example copy out loud in the locked persona's voice.
- Lines that work: N
- Lines that read as generic AI: N
- Lines that read as software: N

### OVERALL VERDICT

One paragraph. Does this feel like the product you set out to build, or does it feel like another ops dashboard with a character skin? Be direct. If it's hollow, say it's hollow.
```

## When to Run

- **Before plan/CTO review on any frontend spec.** Taste check first, correctness check second. A correct-but-tasteless spec is a waste of a CTO review.
- **Before mocks are drawn.** Run on the spec that will drive the mocks. The mocks will inherit the taste (or lack of it) from the spec.
- **After mocks land, before implementation.** Run on the mock deck itself or the HTML.

## When NOT to Run

- Backend specs (no user-facing surfaces)
- Infrastructure or platform specs
- Pure refactor specs
- Internal debug views (though you should still run it occasionally — even debug UIs can have character)

## Calibration

This skill is intentionally opinionated. If it flags something the founder actively wants, override with explicit rationale in the spec. The default posture is **restrictive**: block on voice lies, flag anything generic, demand one weird detail per surface.

Taste is not democratic. The check is not a vote. If the spec doesn't feel like the product you locked in the voice spec, say so and propose the fix.

## Anti-patterns for this skill itself

- Do NOT soften findings to be collaborative. "This is fine but could be better" is useless. Say "this is software, rewrite it."
- Do NOT skip the voice-as-contract check. Voice lies are blockers, not suggestions.
- Do NOT accept "we'll polish the copy later." Copy IS the product. Placeholder copy in a voice-bearing spec means the spec hasn't been designed yet.
- Do NOT run this skill without loading the voice spec first. If the file is missing, report it and stop.
