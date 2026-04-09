---
name: mock
description: Research-driven UI mock process. Gathers references, explores 3 directions, low-fi → pixels, with a reference comparison gate.
---

# /mock — Research-Driven UI Mock Process

Build a UI mock the same way `/spec` builds a spec: research first, multiple directions, validation gates. Stops the "shoot fish in a barrel" failure mode of iterating without research.

**Usage:** `/mock <surface-name>` (e.g., `/mock home`, `/mock brief`, `/mock map`)

---

## Why This Exists

Drawing without research = rebuild loops with no convergence. Three rebuilds of the same surface in one session can fail to converge because each iteration is a fresh guess against memory, not against references.

The lesson: **research → directions → low-fi → pixels → reference comparison gate**. In that order. Skip none.

---

## Process

### Phase 1 — Define the surface (1 round)

Use AskUserQuestion to lock:

1. **Surface name** (filename slug — e.g., `home`, `brief`, `map`)
2. **Job-to-be-done** in one sentence — what is the user trying to do on this surface?
3. **The user** — who they are, what they care about, what they're moving from
4. **Success feeling** — when they open this surface, what should the room feel like? (e.g., "the bridge of my operation," "a morning paper," "a war room")
5. **Anti-feels** — what it must NOT feel like (e.g., "consumer chatbot," "settings panel," "marketing site")

Save these to `mocks/_research/<surface>-brief.md`.

### Phase 2 — Reference gathering (parallel subagents)

Spawn 4 parallel Explore subagents (use a cheap model — haiku-tier). Each gets a different reference family:

| Subagent | Family | What to extract |
|---|---|---|
| A | **Operations & data platforms** — Palantir Foundry/Gotham, Bloomberg Terminal, Mission Control UIs, Splunk, Datadog | Density, multi-pane coordination, mono labels, status indicators, the "trading desk" feel |
| B | **Modern AI ops UIs** — ChatGPT Enterprise, Claude Projects, Linear, Mercury, Ramp, Pilot, Notion AI | Conversation patterns, side peek/record patterns, command palette, calm/dense balance |
| C | **The user's native software** — whatever industry-specific tools the user comes from (e.g., Procore for construction, Epic for healthcare, Bloomberg for finance) | What they expect, what they hate, what they trust, native vocabulary |
| D | **Aesthetic gold standards** — Stripe Dashboard, Linear, Figma, Apple, Vercel, Cron, Things | Type, color, geometry, spacing, restraint, signature visual moves |

Each subagent's output:
- 6–10 specific references (URLs, screenshots, named patterns)
- Pattern extraction: layout grid, type hierarchy, color discipline, density, signature moves
- Anti-pattern catalog: what to avoid from this family
- 3–5 sentences synthesizing the family's DNA

Combine all 4 outputs into `mocks/_research/<surface>-references.md`.

### Phase 2.5 — Interview round (ask the user questions)

After research lands but BEFORE drawing directions, interview the user on the tensions and unknowns the research surfaced. This is the equivalent of `/spec`'s interview phase — and for the same reason: research surfaces questions the user hadn't thought about, and answering them prevents the "it doesn't feel right" loop.

**MANDATORY: use the AskUserQuestion tool for every question.** Never dump a markdown list of open-ended questions. Every question must be a multiple-choice AskUserQuestion with 3–5 concrete options the user can click. The options themselves encode the research — each option references a pattern, a trade-off, or a specific reference so the user is picking between real choices, not writing from scratch. Always include a "None of these / describe your own" option as the last choice.

Ask as many questions as needed. 5 minimum, no maximum. Better to ask 12 quick multiple-choice questions than 3 long-form ones. Group questions by topic (cross-surface, then per-surface).

Good questions:
- **Resolve tensions** the research found (e.g., "Family A says ops software never uses serifs; Family D says serif headlines are the considered-design move. Which wins for the H1?")
- **Pressure-test the brief** (e.g., "Is the home page live-refreshing or a snapshot?")
- **Probe interaction patterns** (e.g., "When the user clicks a mention, does it open in side peek, or does it replace the active pane?")
- **Cross-surface coordination** (e.g., "Is the KPI strip shared across surfaces, or per-surface?")
- **Existing wiring** (e.g., "We had a working API. Does the new design need to match its data shape?")
- **Anti-feels check** (e.g., "One research family pushed this toward a trading-desk aesthetic — is that OK, or does it cross into 'feels alien to the user'?")

Write answers to `mocks/_research/<surface>-interview.md`.

Iterate: if the user's answers reveal the brief was wrong, go back to Phase 1. Don't write directions against a wrong brief.

### Phase 3 — Direction phase (3 distinct variants)

Write 3 thesis variants for the surface in `mocks/_research/<surface>-directions.md`:

For each variant:
- **Name** (e.g., "Bridge", "Document", "Conversation as Surface")
- **One-paragraph thesis**
- **2–3 anchor references** from Phase 2
- **Signature moves** (3–5 specific UI choices that define this direction)
- **Trade-offs** (what it gains, what it sacrifices)
- **ASCII layout sketch** (low-fi)

Use AskUserQuestion to let the user pick A/B/C — or remix.

### Phase 4 — Low-fi wireframe

Build the chosen direction at LOW FIDELITY first:
- ASCII boxes with labels OR rough HTML with placeholder text and borders
- NO pixel polish, NO type/color refinement
- The point: validate the layout, hierarchy, density, content slots BEFORE pixel time

Save to `mocks/_wireframes/<surface>.html`.

**Gate:** Show the wireframe to the user. They approve the layout before pixels. Iterate until they say "go to pixels."

#### Multi-surface sprints: batch wireframe first

For sprints that ship 3+ new surfaces, **wireframe the full set at low-fi BEFORE pixel-passing any of them.** This is the sanctioned pattern for cross-surface design work.

Why: cross-surface patterns (shared shell, KPI strip behavior, center command pane, side peek, Cmd+K overlay) only reveal themselves when you can see every surface side-by-side at low-fi. Pixel-passing one surface before the others are drawn locks in design decisions that won't hold up.

**Batch flow:**
1. Run Phases 1–3 (brief, research, interview, directions) per surface — or share research across surfaces if the family is the same
2. Build low-fi wireframes for every surface in the sprint (parallel, one HTML file each)
3. Build a single `_wireframes/index.html` that shows thesis + links for every surface, so the user can walk the whole system in one pass
4. User reviews the WHOLE SET together — cross-surface inconsistencies become obvious
5. Iterate at low-fi until the whole system holds
6. **Only then** start pixel pass, surface by surface (Phase 5+)

This swaps the default "sequential full cycle per surface" for "batch wireframe, then sequential pixel pass." Use it whenever the sprint touches 3+ primary surfaces.

### Phase 5 — Pixel pass

Build the approved wireframe in real HTML:
- Apply your locked design system (tokens, spacing scale, type ramp)
- Reuse shell components (sidebar, topbar) consistently
- Use real plausible data (real-feeling names, numbers, timestamps — not "Sarah Johnson AC repair $1,450" placeholders)
- Save to `mocks/<surface>.html`

Screenshot at 1440×900 and 1920×1200.

### Phase 6 — Reference comparison gate (the missing gate)

Before showing the user, run an honest gap analysis:

For each anchor reference from Phase 3:
- Side-by-side: my mock vs. the reference
- Honest answer to **"Does mine have the [gravitas/density/restraint/calm] of [reference]?"**
- If no — fix it before showing the user
- Document the gap and the fix in `mocks/_research/<surface>-gap-analysis.md`

This is the step that gets skipped most often. Don't skip it.

### Phase 7 — User review walk-through

Show the user the screenshots. Walk through:
- What you built
- Which reference it draws from for each major decision
- What you're proud of
- What you're unsure about

User marks problems → fix → re-screenshot → repeat. **Max 2 cycles.** If still not landing after 2 cycles, go back to Phase 3 (the direction was wrong, not the execution).

### Phase 8 — Sign-off

When user signs off:
- Save final mock to `mocks/<surface>.html`
- Save signature moves to `mocks/_research/<surface>-signature-moves.md` so the React build can replicate them
- Update `mocks/_research/INDEX.md` with the surface, references used, and direction chosen

---

## Hard Rules

- **Never skip Phase 2.** No drawing before research.
- **Never skip Phase 3.** Always 3 directions, never 1.
- **Never skip Phase 4.** Always low-fi before pixels.
- **Never skip Phase 6.** Always run the reference comparison gate honestly.
- **2 cycles max in Phase 7.** If not converging, the problem is upstream — go back to Phase 3.
- **Use real plausible data.** No "Sarah Johnson AC repair $1,450" placeholders. Real names, real numbers, real timestamps.
- **Apply the locked design system.** No reinventing tokens, no off-spec colors.

## File Layout

```
mocks/
├── _research/
│   ├── INDEX.md
│   ├── <surface>-brief.md          # Phase 1 output
│   ├── <surface>-references.md     # Phase 2 output
│   ├── <surface>-interview.md      # Phase 2.5 output
│   ├── <surface>-directions.md     # Phase 3 output
│   ├── <surface>-gap-analysis.md   # Phase 6 output
│   └── <surface>-signature-moves.md # Phase 8 output
├── _wireframes/
│   └── <surface>.html              # Phase 4 output
└── <surface>.html                  # Phase 5+ output (final)
```

## When to Use

- Any new surface
- Any major rework of an existing surface that isn't a small fix
- When the user says "doesn't feel right" twice in a row — that's the signal to restart from Phase 1
