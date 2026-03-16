---
name: explain
description: Explain code with diagrams and analogies
---

Explain code or an entire PR with visual aids, reasoning, and narrative.

**Usage:**
- `/explain <file-or-function>` — **Code mode**: explain a specific file or function
- `/explain pr` — **PR mode**: explain the full branch as a narrative

---

## Mode 1: Code Explanation (`/explain <file>`)

### Structure

1. **Simple Analogy**
   - Use everyday comparisons tied to system behavior
   <!-- CUSTOMIZE: Add domain-specific analogies if helpful -->

2. **ASCII Flow Diagram**
   - Show data/control flow visually
   - Keep it readable (80 chars wide max)

3. **Step-by-Step Walkthrough**
   - Number each step
   - Show what happens at each stage

4. **Common Gotchas**
   - Edge cases to watch for
   - Easy mistakes to make

5. **Related Files** (1 level deep)
   - Callers and downstream dependencies

---

## Mode 2: PR Explanation (`/explain pr`)

Read everything on the current branch, then write a narrative explaining **why** this PR exists and **why** the code looks the way it does.

### Step 1: Gather Context

Run these in parallel:

```bash
BASE_REF="${BASE_REF:-origin/main}"
git rev-parse --verify "$BASE_REF" >/dev/null 2>&1 || BASE_REF="main"
MERGE_BASE="$(git merge-base HEAD "$BASE_REF")"

# All changed files
{
  git diff --name-only "$MERGE_BASE"..HEAD
  git diff --name-only
  git diff --cached --name-only
  git ls-files --others --exclude-standard
} | awk 'NF' | sort -u

# Commit history on this branch
git log --oneline "$MERGE_BASE"..HEAD

# Branch name
git branch --show-current
```

Also check for:
- **Plan file**: look in system-reminder for plan path — read it if it exists
- **Sprint doc**: check `specs/` for active context referenced by branch name

### Step 2: Read Changed Files

Read every file in the diff to understand the actual implementation. Also read key imports and callers (1 level deep) for integration context.

### Step 3: Write the Narrative

```markdown
## PR Explanation: <branch name or feature title>

### What This Does
<2-3 sentences for someone who knows the product but hasn't read the code.>

### Why This Change Was Needed
<The problem or need. What was broken, missing, or suboptimal before?>

### How It Works
<Technical walkthrough. Walk through key files in logical order.>

### Decisions Made and Why
<For each significant engineering decision:>
- **Decision**: What was chosen
- **Why**: The reasoning
- **Alternatives considered**: What else could have been done
- **Trade-offs accepted**: What was given up

### Invariants and Patterns
<Which project invariants were relevant and how they shaped the implementation.>

### What This Doesn't Do
<Explicit scope boundaries. What was intentionally left out.>

### Risk and Rollback
<What could go wrong. How to roll back. Blast radius.>
```

### Writing Guidelines

- **Write for future-you reviewing this PR in 6 months.**
- **Lead with reasoning, not description.** "We chose X because Y" beats "X was implemented."
- **Name files explicitly.**
- **Be honest about trade-offs.**
- **Reference the plan file** if one exists — note where implementation matches or deviates.
- **Don't pad.** Every section should add information beyond the diff.

### What NOT to Do

- Do NOT just describe what the code does — the diff already shows that
- Do NOT list every file changed without explaining why
- Do NOT include implementation details obvious from reading the code
- Do NOT add sections that say "N/A" — skip them instead

---

## Mode 3: Sprint Explanation

Generate a sprint-wide architecture explainer. Reads both specs and code, then reports where reality matches the plan and where it doesn't.

**Sections:**
1. Header + lead (sprint name, theme, purpose)
2. What this sprint does (plain English)
3. How data flows (diagram)
4. What was planned (spec summary)
5. What was shipped (verified against code)
6. Gaps found (spec claims vs code reality)
7. Things to consider (forward-looking observations)
