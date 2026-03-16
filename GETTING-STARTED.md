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

## Step 3: Pick Your AI Coding Tool

This repo works with any AI agent. Here's how to set up each one:

### Option A: Claude Code (Recommended)

Claude Code runs in your terminal. It reads your codebase, writes code, runs commands, and creates PRs.

**Install:**
```bash
npm install -g @anthropic-ai/claude-code
```

**Log in:**
```bash
claude
```

This opens a browser window to sign in with your Anthropic account. You need a [Claude Pro, Team, or Enterprise subscription](https://claude.ai/settings/billing), or an [Anthropic API key](https://console.anthropic.com/).

**Using an API key instead:**
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
claude
```

You can add this to your `~/.zshrc` (Mac) or `~/.bashrc` (Linux) so it persists:
```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-YOUR-KEY-HERE"' >> ~/.zshrc
source ~/.zshrc
```

**Verify it works:**
```bash
cd your-project
claude
# Type: "What does this project do?"
# Claude reads your codebase and explains it
```

### Option B: Cursor

Cursor is a VS Code fork with AI built in.

1. Go to [cursor.com](https://cursor.com/) and download it
2. Install and open it
3. Sign in with your Cursor account (free tier available)
4. Open your project folder
5. Use `Cmd+K` (Mac) or `Ctrl+K` (Windows) to chat with AI

### Option C: Codex (OpenAI)

Codex is OpenAI's terminal-based coding agent.

**Install:**
```bash
npm install -g @openai/codex
```

**Log in:**
```bash
codex login
```

This opens a browser to sign in with your OpenAI account. You need an [OpenAI API key](https://platform.openai.com/api-keys).

**Using an API key instead:**
```bash
export OPENAI_API_KEY="sk-..."
codex
```

### Option D: Windsurf

1. Go to [codeium.com/windsurf](https://codeium.com/windsurf) and download it
2. Install and open it
3. Sign in with your Codeium account
4. Open your project folder
5. Use the Cascade panel for AI-assisted coding

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

No. The **Solo** tier works with just one tool. Codex integration (dual-model review) is only in the **Full** tier and is optional — it adds a second AI reviewer for adversarial tension, but it's not required.

### "What languages/frameworks does this work with?"

Any. The workflows are language-agnostic. The rules have `<!-- CUSTOMIZE -->` markers for language-specific patterns (ORM methods, test commands, file paths). Most examples use TypeScript/Node, but the principles apply everywhere.

### "What if I'm not using multi-tenancy?"

Remove or ignore the multi-tenancy sections in `code-patterns.md` and skip the `check-tenancy.md` workflow. The setup script detects this and tells you.

### "Can I use this with an existing project?"

Yes. Run the setup script in your project root. It adds a `.claude/` directory (or equivalent) without touching your existing code.

### "What's the minimum I need to be productive?"

1. Install Claude Code (Step 3A)
2. Run the setup script with **Solo** tier (Step 4)
3. Fill in `CLAUDE.md` with your project description (Step 5)
4. Start using `/spec`, `/fix`, `/commit`, and `/review` (Step 6)

That's it. Everything else is optional and can be added later.

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
