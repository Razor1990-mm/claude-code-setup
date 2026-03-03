# Workflow: Structured Commit

Create a git commit following project conventions.

## Process

1. Run `git diff --staged` to see what's being committed
2. If nothing is staged, run `git status` and ask user what to stage
3. Generate commit message in this format:
   ```
   type: short description

   - What changed
   - Why it was needed
   ```
4. Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
5. **Ask user to confirm** before running `git commit`

## Rules

- Do NOT push to remote (unless explicitly asked)
- Do NOT amend previous commits (unless explicitly asked)
- Do NOT skip pre-commit hooks
