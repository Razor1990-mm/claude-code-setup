# Workflow: Add to Backlog

Add an agent-ready item to the product backlog.

## Agent-Ready Format

Every backlog item must include enough context that an agent can start implementing in under 5 minutes — no 20-minute exploration phase. The key fields are **entry point** and **fix approach**.

## Process

1. **Gather info from user.** If not provided, ask for:
   - Title (short description)
   - Priority: P0 (production blocker), P1 (next sprint), P2 (backlog), P3 (future)
   - What it is and why it matters

2. **Fill in agent-ready fields.** Use codebase knowledge to fill in:
   - **Entry point** — the specific file + function where the change starts
   - **Files** — all files likely to be touched
   - **Fix approach** — how to fix it (1-3 sentences). If unknown, write "Needs exploration: <specific question>"
   - **Acceptance criteria** — how you know it's done (testable statement)
   - **Pattern to follow** — if an existing pattern applies, cite it
   - **Complexity** — S / M / L

3. **Read current backlog** to find the right section

4. **Append using this format:**

```markdown
### [Title]

**What:** 1-2 sentence description.
**Why:** What breaks or improves.
**Entry point:** `src/domain/file.ts` (`functionName`)
**Files:** `path/to/file1.ts`, `path/to/file2.ts`, `path/to/__tests__/file1.test.ts`
**Fix approach:** How to fix it. Reference patterns if applicable.
**Acceptance criteria:** Testable statement of "done."
**Pattern to follow:** (if applicable)
**Complexity:** S / M / L
**Source:** Where this came from (sprint review, code review finding, user request)
```

5. **Show the addition and confirm with user before saving**

## What Makes an Item "Agent-Ready"

An agent can always find files and read code. What costs 20 minutes is figuring out:
- **WHERE to start** — the entry point (file + function)
- **WHAT approach to take** — the fix approach + which pattern to follow

If you can fill in those two fields, the item is agent-ready.
