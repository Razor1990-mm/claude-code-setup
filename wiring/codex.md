# Wiring Guide: OpenAI Codex

How to set up this rule system for [OpenAI Codex](https://openai.com/index/codex/).

## Project Structure

Codex uses `AGENTS.md` at the project root, plus optional `AGENTS.md` files in subdirectories for scoped instructions:

```
your-project/
├── AGENTS.md                    # ← Main project instructions (rules/project.md)
├── workflows/                   # ← Workflow prompts (copy entire directory)
│   ├── spec.md
│   ├── tdd-workflow.md
│   ├── review.md
│   ├── pr.md
│   ├── grill.md
│   ├── audit.md
│   └── ... (16 files total)
├── src/
│   ├── AGENTS.md                # ← Optional: src-specific rules
│   └── domain/
│       └── AGENTS.md            # ← Optional: domain-specific rules
├── specs/
│   └── sprint-01-title.md
└── templates/
    ├── sprint-spec.md
    └── work-order.md
```

## Setup Steps

### 1. Create AGENTS.md (project rules)

Copy `rules/project.md` as the base, then append additional rules:

```bash
cat rules/project.md > AGENTS.md
echo -e "\n---\n" >> AGENTS.md
cat rules/workflow.md >> AGENTS.md
echo -e "\n---\n" >> AGENTS.md
cat rules/code-patterns.md >> AGENTS.md
echo -e "\n---\n" >> AGENTS.md
cat rules/testing.md >> AGENTS.md
echo -e "\n---\n" >> AGENTS.md
cat rules/security.md >> AGENTS.md
```

### 2. Copy workflows (the key ingredient)

These are the structured prompts that drive the development process. Copy the entire directory:

```bash
cp -r workflows/ your-project/workflows/
```

### 3. Reference workflows from AGENTS.md

Add this section to the bottom of your `AGENTS.md`:

```markdown
## Available Workflows

When asked to perform these tasks, read the corresponding workflow file for detailed instructions:

| Task | Workflow File |
|------|--------------|
| Write a spec | `workflows/spec.md` |
| Write tests first (TDD) | `workflows/tdd-workflow.md` |
| Code review | `workflows/review.md` |
| PR review-fix loop | `workflows/pr.md` |
| Adversarial review | `workflows/grill.md` |
| Security audit | `workflows/security.md` |
| Full audit | `workflows/audit.md` |
| Staff review a plan | `workflows/staff-review.md` |
| Sprint closeout | `workflows/sprint-closeout.md` |
| Fix a bug from error output | `workflows/fix.md` |
| Generate tests | `workflows/test-gen.md` |
| Add to backlog | `workflows/backlog.md` |
| Explain code/PR/sprint | `workflows/explain.md` |
| Check multi-tenancy | `workflows/check-tenancy.md` |
| Check string consistency | `workflows/check-consistency.md` |
| Commit with format | `workflows/commit.md` |

To use a workflow: "Run the spec workflow" or "Follow workflows/review.md to review this code"
```

### 4. Copy templates

```bash
mkdir -p templates
cp templates/sprint-spec.md templates/
cp templates/work-order.md templates/
```

### 5. Customize

Search for `<!-- CUSTOMIZE -->` and fill in project details:
```bash
grep -r "CUSTOMIZE" . --include="*.md"
```

## Alternative: Scoped AGENTS.md Files

For larger projects, use subdirectory `AGENTS.md` files instead of one large file:

```
your-project/
├── AGENTS.md                  # rules/project.md (core instructions + workflow table)
├── workflows/                 # All 16 workflow files
├── src/
│   ├── AGENTS.md              # rules/code-patterns.md
│   └── __tests__/
│       └── AGENTS.md          # rules/testing.md
└── src/routes/
    └── AGENTS.md              # rules/security.md
```

Subdirectory `AGENTS.md` files are additive — they don't override the root.

## How Workflows Work with Codex

Codex doesn't have a `/command` system like Claude Code. Instead:

1. **Workflows live as markdown files** in your repo
2. **AGENTS.md references them** in the table above
3. **You tell Codex which workflow to follow**: "Follow the TDD workflow to add tests for this function" or "Run the review workflow on my changes"
4. **Codex reads the file** and follows the structured instructions

This gives you the same structured development process without needing agent-specific command infrastructure.

## Key Differences from Claude Code

| Feature | Claude Code | Codex |
|---------|-------------|-------|
| Instruction file | `CLAUDE.md` + `.claude/rules/` | `AGENTS.md` (root + subdirs) |
| Scoped rules | Frontmatter `paths:` | Subdirectory `AGENTS.md` files |
| Custom commands | `.claude/commands/` (invoked with `/name`) | Workflow files (referenced by path) |
| Memory | Auto-memory directory | Not supported — use AGENTS.md |
| Global config | `~/.claude/CLAUDE.md` | Not supported (project-level only) |

## Tips

- Keep the most critical rules (project structure, core principles, security) at the top of AGENTS.md
- Use markdown headers liberally — Codex navigates by heading structure
- The workflow reference table in AGENTS.md is the key bridge — it tells Codex where to find detailed instructions
- When starting a new feature, say: "Read workflows/spec.md and interview me for a spec"
- For code review: "Read workflows/review.md and review my changes on this branch"
