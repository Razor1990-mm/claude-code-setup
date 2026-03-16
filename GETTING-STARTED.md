# Getting Started (From Zero)

Never used AI coding tools before? This guide walks you through everything — from installing VS Code to running your first AI-assisted feature.

---

## Step 1: Install VS Code

If you don't have VS Code yet:

1. Go to [code.visualstudio.com](https://code.visualstudio.com/)
2. Download for your OS (Mac / Windows / Linux)
3. Install and open it

**Already using VS Code?** Skip to Step 2.

---

## Step 2: Install Node.js (if you don't have it)

Most AI coding tools need Node.js. Check if you have it:

```bash
node --version
```

If you get "command not found":

1. Go to [nodejs.org](https://nodejs.org/)
2. Download the **LTS** version (not Current)
3. Install it
4. Restart your terminal, then verify: `node --version`

---

## Step 3: Install Your AI Coding Tools

This workflow uses **two AI tools working together** — Claude Code as your primary coding agent, and Codex as an independent reviewer. This dual-model setup is what gives you adversarial code review: two different AI models reviewing the same code from different angles, catching different categories of issues.

### Why two tools?

| Tool | Role | What it catches |
|------|------|----------------|
| **Claude Code** (Anthropic) | Primary agent — writes specs, code, tests, fixes | Spec adherence, architecture, test gaps, AI smells |
| **Codex** (OpenAI) | Independent reviewer — reads code directly | Multi-tenancy violations, unbounded queries, PII leaks, crash risks |

Validated across 32+ review-fix commits: **near-zero overlap** between what Claude catches and what Codex catches. Using only one tool means entire categories of bugs slip through.

### 3A: Install Claude Code (Required)

Claude Code is your primary coding agent. It runs in your terminal, reads your codebase, writes code, runs commands, and creates PRs.

**Install:**
```bash
npm install -g @anthropic-ai/claude-code
```

**Log in:**
```bash
claude
```

This opens a browser window to sign in with your Anthropic account. You need one of:
- [Claude Pro subscription](https://claude.ai/settings/billing) ($20/mo) — simplest option
- [Claude Team or Enterprise](https://claude.ai/settings/billing) — for teams
- [Anthropic API key](https://console.anthropic.com/) — pay-per-use

**Using an API key instead of subscription:**
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
claude
```

Add this to your shell profile so it persists:
```bash
# Mac (zsh)
echo 'export ANTHROPIC_API_KEY="sk-ant-YOUR-KEY-HERE"' >> ~/.zshrc
source ~/.zshrc

# Linux (bash)
echo 'export ANTHROPIC_API_KEY="sk-ant-YOUR-KEY-HERE"' >> ~/.bashrc
source ~/.bashrc
```

**Verify it works:**
```bash
cd your-project
claude
# Type: "What does this project do?"
# Claude reads your codebase and explains it
```

### 3B: Install Codex (Required for full workflow)

Codex is OpenAI's coding agent. In this workflow, it acts as an **independent reviewer** — it reads your code directly (Claude never feeds it code) and reviews from a production-readiness perspective.

**Install:**
```bash
npm install -g @openai/codex
```

**Log in:**
```bash
codex login
```

This opens a browser to sign in with your OpenAI account. You need an [OpenAI API key](https://platform.openai.com/api-keys) (pay-per-use, no subscription required).

**Using an API key directly:**
```bash
export OPENAI_API_KEY="sk-..."
```

Add to your shell profile:
```bash
# Mac
echo 'export OPENAI_API_KEY="sk-YOUR-KEY-HERE"' >> ~/.zshrc
source ~/.zshrc

# Linux
echo 'export OPENAI_API_KEY="sk-YOUR-KEY-HERE"' >> ~/.bashrc
source ~/.bashrc
```

**Verify it works:**
```bash
cd your-project
codex "What files are in this project?"
```

### 3C: Verify Both Tools

Run this to confirm both are installed:
```bash
claude --version && codex --version && echo "Both tools ready!"
```

If either fails, re-run the install step for that tool.

### What each tool costs

| Tool | Pricing | Typical cost |
|------|---------|-------------|
| **Claude Code** | Pro subscription $20/mo, or API (~$3-15/1M tokens depending on model) | $20/mo flat, or ~$0.50-2.00 per feature with API |
| **Codex** | API pay-per-use (~$2-10/1M tokens depending on model) | ~$0.05-0.30 per review |

The Codex reviews are cheap — they only read code and produce findings. Claude does the heavy lifting (spec writing, implementation, fixing).

### Alternative: Using Cursor or Windsurf instead of Claude Code

If you prefer a GUI editor over the terminal:

**Cursor** (VS Code fork with AI):
1. Go to [cursor.com](https://cursor.com/) and download
2. Sign in (free tier available, Pro $20/mo)
3. Use `Cmd+K` / `Ctrl+K` to chat with AI
4. You can still install Codex separately for the review workflows

**Windsurf** (Codeium's editor):
1. Go to [codeium.com/windsurf](https://codeium.com/windsurf) and download
2. Sign in with Codeium account
3. Use the Cascade panel for AI coding
4. You can still install Codex separately for the review workflows

**Note:** The workflows in this repo are optimized for Claude Code's `/command` system. With Cursor or Windsurf, you'll paste workflow contents manually instead of using slash commands.

---

## Step 4: Install This Setup

Open your terminal, navigate to your project, and run:

```bash
cd your-project
bash <(curl -s https://raw.githubusercontent.com/Razor1990-mm/claude-code-setup/main/setup.sh)
```

It will:
1. **Detect** your project type (language, framework, ORM)
2. **Ask** which AI tool you're using and how complex your setup should be
3. **Download** the right rules, workflows, and templates into your project

### What the complexity tiers mean

| Tier | What you get | Best for |
|------|-------------|----------|
| **Solo** | Rules + 17 workflows | Individual dev, learning the system |
| **Team** | + templates + memory system | Small team, sprint planning |
| **Full** | + agents + hooks + Codex integration | Multi-agent, production workflow |

**If you're just starting, pick Solo.** You can always upgrade later.

---

## Step 5: Customize for Your Project

After setup, you'll have files with `<!-- CUSTOMIZE -->` markers. These are the spots where you fill in your project's specifics.

Find them:
```bash
grep -r "CUSTOMIZE" .claude/ --include="*.md"
```

The most important ones to fill in:

| File | What to customize |
|------|------------------|
| `CLAUDE.md` | Project name, description, directory structure, tech stack |
| `rules/code-patterns.md` | Your ORM methods, error codes, tenant field name |
| `rules/testing.md` | Test file paths, test commands, framework |
| `rules/security.md` | Your auth patterns (Bearer, OAuth, API keys, etc.) |

**You don't have to customize everything right now.** The defaults work for most TypeScript/Node projects. Customize as you go.

---

## Step 6: Try Your First Commands

### With Claude Code

Open your terminal in your project directory:

```bash
claude
```

Then try these commands (type them in the Claude Code session):

| Command | What it does |
|---------|-------------|
| `/spec` | Interviews you about a feature, researches your codebase, writes a spec |
| `/explain src/index.ts` | Explains a file with diagrams and analogies |
| `/review` | Reviews your current branch changes |
| `/fix` | Paste an error, Claude fixes it automatically |
| `/commit` | Creates a structured git commit |
| `/audit` | Runs security + quality audit on your changes |

**Your first feature — the full flow:**

```
1. claude                          # Start Claude Code
2. /spec                           # "I want to add user authentication"
   → Claude interviews you (2+ rounds)
   → Claude writes a spec to specs/auth.md

3. /tdd-workflow                   # Claude writes failing tests first
4. (write production code)         # Make the tests pass
5. /commit                         # Commit your work

6. /pr                             # Claude creates PR + runs review
   → Auto-fixes safe issues
   → Asks you about anything complex
```

### With Cursor

1. Open your project in Cursor
2. Press `Cmd+K` (Mac) or `Ctrl+K` (Windows)
3. Paste the content of any workflow file (e.g., `workflows/review.md`) and ask Cursor to follow it

### With Codex

```bash
cd your-project
codex "Review the changes on this branch for production readiness"
```

---

## Step 7: Understand the Workflow

The core loop is simple:

```
PLAN → BUILD (tests first) → REVIEW → SHIP
```

Here's when to use each workflow:

### "I'm building something new"
1. `/spec` — Plan it (Claude interviews you, researches codebase)
2. `/tdd-workflow` — Write tests first
3. Write code to make tests pass
4. `/commit` — Commit at logical boundaries
5. `/pr` — Create PR with automated review

### "I have a bug"
1. Paste the error into Claude
2. `/fix` — Claude finds and fixes it
3. `/commit`

### "I want a code review"
- `/review` — Comprehensive review (completeness, AI smells, spec adherence)
- `/grill` — Hostile review (tries to break your code)
- `/audit` — Security + quality checklist

### "I don't understand this code"
- `/explain src/path/to/file.ts` — Explains with diagrams
- `/explain pr` — Explains the whole PR as a narrative

---

## Common Questions

### "Do I need a paid subscription?"

**Claude Code:** Yes. Requires Claude Pro ($20/mo), Team, or Enterprise. Or an Anthropic API key (pay-per-use).

**Cursor:** Free tier available with limited AI usage. Pro is $20/mo for unlimited.

**Codex:** Requires an OpenAI API key (pay-per-use).

### "Do I need both Claude AND Codex?"

Yes, for the full workflow. The dual-model review (Claude reviews + Codex reviews) is what gives this system its power — two different AI models catch different categories of bugs with near-zero overlap. Claude alone will miss production-readiness issues (unbounded queries, PII leaks, multi-tenancy violations). Codex alone can't write specs, implement features, or fix code. You need both.

The **Solo** tier installs the workflows without Codex integration, so you *can* start with just Claude Code and add Codex later — but you'll be missing the adversarial review layer until you do.

### "What languages/frameworks does this work with?"

Any. The workflows are language-agnostic. The rules have `<!-- CUSTOMIZE -->` markers for language-specific patterns (ORM methods, test commands, file paths). Most examples use TypeScript/Node, but the principles apply everywhere.

### "What if I'm not using multi-tenancy?"

Remove or ignore the multi-tenancy sections in `code-patterns.md` and skip the `check-tenancy.md` workflow. The setup script detects this and tells you.

### "Can I use this with an existing project?"

Yes. Run the setup script in your project root. It adds a `.claude/` directory (or equivalent) without touching your existing code.

### "What's the minimum I need to be productive?"

1. Install Claude Code + Codex (Steps 3A and 3B)
2. Run the setup script with **Solo** tier (Step 4)
3. Fill in `CLAUDE.md` with your project description (Step 5)
4. Start using `/spec`, `/fix`, `/commit`, and `/review` (Step 6)

That gets you the core workflow. Everything else (templates, memory, agents, hooks) can be added later.

---

## Troubleshooting

### "claude: command not found"
```bash
npm install -g @anthropic-ai/claude-code
```
If that fails, you may need `sudo`:
```bash
sudo npm install -g @anthropic-ai/claude-code
```

### "Permission denied" when running setup.sh
```bash
bash setup.sh
# or
chmod +x setup.sh && ./setup.sh
```

### "ANTHROPIC_API_KEY not set"
```bash
export ANTHROPIC_API_KEY="sk-ant-YOUR-KEY"
```
Get your key from [console.anthropic.com](https://console.anthropic.com/).

### "The setup script didn't detect my project"
Make sure you're running it from your project root (where `.git` or `package.json` lives):
```bash
cd /path/to/your/project
bash <(curl -s https://raw.githubusercontent.com/Razor1990-mm/claude-code-setup/main/setup.sh)
```

### "Claude isn't reading my rules"
Check that your `CLAUDE.md` is at the project root and `.claude/rules/` exists:
```bash
ls CLAUDE.md
ls .claude/rules/
```

---

## Next Steps

Once you're comfortable with the basics:

- **Read `PLAYBOOK.md`** — The full development workflow, stage by stage
- **Try `/grill`** — Get brutally honest feedback on your code
- **Try `/audit`** — Run a security + quality audit before PRs
- **Upgrade to Team tier** — Add sprint planning templates and memory
- **Upgrade to Full tier** — Add multi-agent delegation and Codex dual-review
- **Go parallel** — Run multiple agents in separate windows with git worktrees (see "Multi-Agent Parallel Work" in `PLAYBOOK.md`)
