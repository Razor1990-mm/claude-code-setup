# Template Rules

These apply to all files. Enforces template usage for structured deliverables.

## Specs (Primary Planning Artifact)

Before starting any feature, hardening, or refactor work, MUST:
1. Run `/spec` (or `/spec --type hardening` or `/spec --type refactor`)
2. Spec is saved to `specs/<name>.md`
3. `/codex-cto` + `/staff-review` validate
4. `/clear` and implement in a fresh session

## Work Orders

Before creating any work order or delegation to a specialist agent, MUST:
1. Read `templates/work-order.md`
2. Follow the template structure exactly
3. Include all REQUIRED sections (Context Gathered, Requirements, Must-Cover Invariants, Must-Cover Tests, Files You May Touch, Proof Commands)

Incomplete work orders missing required sections MUST be rejected by reviewers.

## Sprint Specs

Before creating or updating any sprint spec (`specs/sprint-*.md`), MUST:
1. Read `templates/sprint-spec.md`
2. Follow the template structure, hard caps, and checklist
3. Include a TL;DR block (exactly 10 lines)

**PRD Policy:** Standalone PRDs are reserved for multi-sprint strategic features only. Sprint-scoped work uses the Sprint Spec format — no separate PRD or tech spec.

## Sprint Close-Out

Before closing a sprint, verify all items in the Sprint Close-Out Gate checklist from `templates/sprint-spec.md`.
