# Workflow: Explain Code, PRs, or Sprints

Explain code with reasoning-first narratives and optional visual aids.

## Modes

### Mode 1: Code Explanation

**Structure:**
1. **Simple Analogy** — Use everyday comparisons tied to system behavior
2. **Execution Path** — Show control/data flow from entrypoint to side effects
3. **Invariants and Contracts** — Preconditions, postconditions, constraints
4. **Step-by-Step Walkthrough** — Number each stage, name key function calls
5. **Failure Modes + Tests** — How it fails, how it degrades, what tests prove
6. **Related Files** — Callers and downstream dependencies (1 level deep)

### Mode 2: PR Explanation

Read everything on the current branch, then write a narrative explaining why this PR exists and why the code looks the way it does.

**Structure:**
```markdown
## PR Explanation: <branch or feature title>

### What This Does
<2-3 sentences for someone who knows the product but hasn't read the code>

### Why This Change Was Needed
<The problem or need. What was broken, missing, or suboptimal before?>

### How It Works
<Technical walkthrough. Walk through key files in logical order.>

### Decisions Made and Why
<For each significant engineering decision: what, why, alternatives, trade-offs>

### Invariants and Patterns
<Which project invariants were relevant and how they shaped the implementation>

### What This Doesn't Do
<Explicit scope boundaries. What was intentionally left out.>

### Risk and Rollback
<What could go wrong. How to roll back. Blast radius.>
```

**Writing Guidelines:**
- Write for future-you reviewing this in 6 months
- Lead with reasoning, not description ("We chose X because Y")
- Name files explicitly
- Be honest about trade-offs
- Don't pad — every section should add information beyond the diff

### Mode 3: Sprint Explanation

Generate a sprint-wide architecture explainer. Reads both specs and code, then reports where reality matches the plan and where it doesn't.

**Sections:**
1. Header + lead (sprint name, theme, purpose)
2. What this sprint does (plain English)
3. How data flows (diagram)
4. What was planned (spec summary)
5. What was shipped (verified against code)
6. Gaps found (spec claims vs code reality)
7. Things to consider (forward-looking observations)
