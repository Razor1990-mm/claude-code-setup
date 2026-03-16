#!/usr/bin/env bash
set -euo pipefail

# AI Dev Setup — One-liner installer
# Usage: bash <(curl -s https://raw.githubusercontent.com/Razor1990-mm/claude-code-setup/main/setup.sh)

REPO_URL="https://raw.githubusercontent.com/Razor1990-mm/claude-code-setup/main"
VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
  echo ""
  echo -e "${BOLD}========================================${NC}"
  echo -e "${BOLD}  AI Dev Setup v${VERSION}${NC}"
  echo -e "${BOLD}========================================${NC}"
  echo ""
}

print_step() {
  echo -e "${BLUE}[${1}]${NC} ${2}"
}

print_success() {
  echo -e "${GREEN}  ✓${NC} ${1}"
}

print_skip() {
  echo -e "${YELLOW}  →${NC} ${1}"
}

print_error() {
  echo -e "${RED}  ✗${NC} ${1}"
}

# -------------------------------------------------------------------
# Step 1: Detect project type
# -------------------------------------------------------------------

detect_project() {
  print_step "1/4" "Detecting project type..."

  LANG="unknown"
  FRAMEWORK="unknown"
  ORM="unknown"
  HAS_MULTI_TENANCY="false"

  # Language detection
  if [ -f "package.json" ]; then
    LANG="typescript"
    # Framework detection
    if grep -q '"next"' package.json 2>/dev/null; then
      FRAMEWORK="nextjs"
    elif grep -q '"express"' package.json 2>/dev/null; then
      FRAMEWORK="express"
    elif grep -q '"fastify"' package.json 2>/dev/null; then
      FRAMEWORK="fastify"
    elif grep -q '"react"' package.json 2>/dev/null; then
      FRAMEWORK="react"
    fi
    # ORM detection
    if grep -q '"prisma"' package.json 2>/dev/null || [ -f "prisma/schema.prisma" ]; then
      ORM="prisma"
    elif grep -q '"drizzle-orm"' package.json 2>/dev/null; then
      ORM="drizzle"
    elif grep -q '"typeorm"' package.json 2>/dev/null; then
      ORM="typeorm"
    fi
  elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then
    LANG="python"
    if grep -q "django" requirements.txt 2>/dev/null || grep -q "django" pyproject.toml 2>/dev/null; then
      FRAMEWORK="django"
      ORM="django-orm"
    elif grep -q "fastapi" requirements.txt 2>/dev/null || grep -q "fastapi" pyproject.toml 2>/dev/null; then
      FRAMEWORK="fastapi"
    elif grep -q "flask" requirements.txt 2>/dev/null || grep -q "flask" pyproject.toml 2>/dev/null; then
      FRAMEWORK="flask"
    fi
    if grep -q "sqlalchemy" requirements.txt 2>/dev/null || grep -q "sqlalchemy" pyproject.toml 2>/dev/null; then
      ORM="sqlalchemy"
    fi
  elif [ -f "go.mod" ]; then
    LANG="go"
    if grep -q "gin-gonic" go.mod 2>/dev/null; then
      FRAMEWORK="gin"
    elif grep -q "fiber" go.mod 2>/dev/null; then
      FRAMEWORK="fiber"
    fi
  elif [ -f "Cargo.toml" ]; then
    LANG="rust"
    if grep -q "actix-web" Cargo.toml 2>/dev/null; then
      FRAMEWORK="actix"
    elif grep -q "axum" Cargo.toml 2>/dev/null; then
      FRAMEWORK="axum"
    fi
  elif [ -f "Gemfile" ]; then
    LANG="ruby"
    if grep -q "rails" Gemfile 2>/dev/null; then
      FRAMEWORK="rails"
      ORM="activerecord"
    fi
  fi

  # Multi-tenancy detection (look for common patterns)
  if grep -rq "orgId\|tenantId\|tenant_id\|org_id\|organization_id" src/ 2>/dev/null || \
     grep -rq "orgId\|tenantId\|tenant_id\|org_id" prisma/ 2>/dev/null || \
     grep -rq "orgId\|tenantId\|tenant_id\|org_id" app/ 2>/dev/null; then
    HAS_MULTI_TENANCY="true"
  fi

  echo -e "  Language:       ${BOLD}${LANG}${NC}"
  echo -e "  Framework:      ${BOLD}${FRAMEWORK}${NC}"
  echo -e "  ORM:            ${BOLD}${ORM}${NC}"
  echo -e "  Multi-tenancy:  ${BOLD}${HAS_MULTI_TENANCY}${NC}"
  echo ""
}

# -------------------------------------------------------------------
# Step 2: Ask questions
# -------------------------------------------------------------------

ask_questions() {
  print_step "2/4" "Quick setup questions..."
  echo ""

  # Agent type
  echo -e "  ${BOLD}Which AI agent are you using?${NC}"
  echo "  1) Claude Code"
  echo "  2) Cursor"
  echo "  3) Codex (OpenAI)"
  echo "  4) Windsurf"
  echo "  5) Other / Multiple"
  read -rp "  Choice [1]: " AGENT_CHOICE
  AGENT_CHOICE="${AGENT_CHOICE:-1}"
  echo ""

  case "$AGENT_CHOICE" in
    1) AGENT="claude-code" ;;
    2) AGENT="cursor" ;;
    3) AGENT="codex" ;;
    4) AGENT="windsurf" ;;
    *) AGENT="generic" ;;
  esac

  # Team size / complexity
  echo -e "  ${BOLD}Project complexity?${NC}"
  echo "  1) Solo dev — minimal setup (rules + workflows)"
  echo "  2) Small team — standard setup (+ templates + memory)"
  echo "  3) Multi-agent — full setup (+ agents + hooks + Codex integration)"
  read -rp "  Choice [1]: " COMPLEXITY_CHOICE
  COMPLEXITY_CHOICE="${COMPLEXITY_CHOICE:-1}"
  echo ""

  case "$COMPLEXITY_CHOICE" in
    1) COMPLEXITY="solo" ;;
    2) COMPLEXITY="team" ;;
    3) COMPLEXITY="full" ;;
    *) COMPLEXITY="solo" ;;
  esac

  # Codex CLI check (for full setup)
  HAS_CODEX="false"
  if [ "$COMPLEXITY" = "full" ]; then
    if command -v codex &>/dev/null; then
      HAS_CODEX="true"
      print_success "Codex CLI detected"
    else
      print_skip "Codex CLI not found — Codex workflows will be included but won't run until installed"
    fi
  fi
}

# -------------------------------------------------------------------
# Step 3: Download and install
# -------------------------------------------------------------------

download_file() {
  local remote_path="$1"
  local local_path="$2"
  local dir
  dir=$(dirname "$local_path")
  mkdir -p "$dir"
  if curl -sfL "${REPO_URL}/${remote_path}" -o "$local_path" 2>/dev/null; then
    print_success "$local_path"
  else
    print_error "Failed to download: $remote_path"
  fi
}

install_files() {
  print_step "3/4" "Installing files..."
  echo ""

  # Determine target directory based on agent
  case "$AGENT" in
    claude-code)
      TARGET=".claude"
      RULES_DIR=".claude/rules"
      COMMANDS_DIR=".claude/commands"
      TEMPLATES_DIR=".claude/templates"
      AGENTS_DIR=".claude/agents"
      MEMORY_DIR=".claude/memory"
      ;;
    cursor)
      TARGET=".cursor"
      RULES_DIR=".cursor/rules"
      COMMANDS_DIR=".cursor/commands"
      TEMPLATES_DIR="templates"
      AGENTS_DIR="agents"
      MEMORY_DIR="memory"
      ;;
    *)
      TARGET=".ai"
      RULES_DIR="rules"
      COMMANDS_DIR="workflows"
      TEMPLATES_DIR="templates"
      AGENTS_DIR="agents"
      MEMORY_DIR="memory"
      ;;
  esac

  # --- CORE (always installed) ---

  echo "  Core rules:"
  download_file "rules/code-patterns.md" "${RULES_DIR}/code-patterns.md"
  download_file "rules/workflow.md" "${RULES_DIR}/workflow.md"
  download_file "rules/testing.md" "${RULES_DIR}/testing.md"
  download_file "rules/security.md" "${RULES_DIR}/security.md"
  download_file "rules/templates.md" "${RULES_DIR}/templates.md"
  echo ""

  echo "  Core workflows:"
  for wf in spec.md tdd-workflow.md review.md pr.md grill.md audit.md \
            security.md staff-review.md fix.md commit.md backlog.md \
            test-gen.md explain.md ingest-review.md check-tenancy.md \
            check-consistency.md sprint-closeout.md; do
    download_file "workflows/${wf}" "${COMMANDS_DIR}/${wf}"
  done
  echo ""

  # --- TEAM (templates + memory) ---

  if [ "$COMPLEXITY" = "team" ] || [ "$COMPLEXITY" = "full" ]; then
    echo "  Templates:"
    download_file "templates/sprint-spec.md" "${TEMPLATES_DIR}/sprint-spec.md"
    download_file "templates/work-order.md" "${TEMPLATES_DIR}/work-order.md"
    echo ""

    echo "  Memory system:"
    download_file "memory/README.md" "${MEMORY_DIR}/README.md"
    download_file "memory/MEMORY.md" "${MEMORY_DIR}/MEMORY.md"
    download_file "memory/example-user.md" "${MEMORY_DIR}/example-user.md"
    download_file "memory/example-feedback.md" "${MEMORY_DIR}/example-feedback.md"
    echo ""
  fi

  # --- FULL (agents + hooks + Codex + settings) ---

  if [ "$COMPLEXITY" = "full" ]; then
    echo "  Codex integration:"
    download_file "workflows/codex-cto.md" "${COMMANDS_DIR}/codex-cto.md"
    download_file "workflows/codex-code-review.md" "${COMMANDS_DIR}/codex-code-review.md"
    download_file "workflows/codex-pr-review.md" "${COMMANDS_DIR}/codex-pr-review.md"
    download_file "workflows/codex-cto-parallel.md" "${COMMANDS_DIR}/codex-cto-parallel.md"
    download_file "workflows/audit-full.md" "${COMMANDS_DIR}/audit-full.md"
    echo ""

    echo "  Agent definitions:"
    download_file "agents/README.md" "${AGENTS_DIR}/README.md"
    download_file "agents/cto.md" "${AGENTS_DIR}/cto.md"
    download_file "agents/backend-lead.md" "${AGENTS_DIR}/backend-lead.md"
    download_file "agents/frontend-lead.md" "${AGENTS_DIR}/frontend-lead.md"
    download_file "agents/qa-eng.md" "${AGENTS_DIR}/qa-eng.md"
    download_file "agents/security-eng.md" "${AGENTS_DIR}/security-eng.md"
    download_file "agents/devops-eng.md" "${AGENTS_DIR}/devops-eng.md"
    echo ""

    if [ "$AGENT" = "claude-code" ]; then
      echo "  Hooks & settings:"
      mkdir -p ".claude/hooks"
      download_file "hooks/block-checkout-main.sh" ".claude/hooks/block-checkout-main.sh"
      download_file "hooks/check-domain-tenancy.sh" ".claude/hooks/check-domain-tenancy.sh"
      chmod +x .claude/hooks/*.sh 2>/dev/null || true
      download_file "settings.json" ".claude/settings.json"
      download_file "SETTINGS-GUIDE.md" ".claude/SETTINGS-GUIDE.md"
      echo ""
    fi
  fi

  # --- Project-level CLAUDE.md (if Claude Code and doesn't exist) ---

  if [ "$AGENT" = "claude-code" ] && [ ! -f "CLAUDE.md" ]; then
    echo "  Project config:"
    download_file "rules/project.md" "CLAUDE.md"
    echo ""
  fi
}

# -------------------------------------------------------------------
# Step 4: Post-install
# -------------------------------------------------------------------

post_install() {
  print_step "4/4" "Post-install..."
  echo ""

  # Count CUSTOMIZE markers
  CUSTOMIZE_COUNT=$(grep -r "CUSTOMIZE" "${TARGET}/" --include="*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ -f "CLAUDE.md" ]; then
    CLAUDE_COUNT=$(grep -c "CUSTOMIZE" "CLAUDE.md" 2>/dev/null || echo 0)
    CUSTOMIZE_COUNT=$((CUSTOMIZE_COUNT + CLAUDE_COUNT))
  fi

  echo -e "${GREEN}${BOLD}Setup complete!${NC}"
  echo ""
  echo "  Files installed to: ${BOLD}${TARGET}/${NC}"
  echo ""

  if [ "$CUSTOMIZE_COUNT" -gt 0 ]; then
    echo -e "  ${YELLOW}${BOLD}Action needed:${NC} ${CUSTOMIZE_COUNT} sections need customization."
    echo "  Find them with:"
    echo ""
    echo -e "    ${BOLD}grep -r 'CUSTOMIZE' ${TARGET}/ --include='*.md'${NC}"
    if [ -f "CLAUDE.md" ]; then
      echo -e "    ${BOLD}grep 'CUSTOMIZE' CLAUDE.md${NC}"
    fi
    echo ""
  fi

  echo "  Next steps:"
  echo "  1. Fill in <!-- CUSTOMIZE --> sections for your project"
  if [ "$AGENT" = "claude-code" ]; then
    echo "  2. Copy global-preferences.md to ~/.claude/CLAUDE.md"
    echo "  3. Run /spec to start your first feature"
  elif [ "$AGENT" = "cursor" ]; then
    echo "  2. Copy global-preferences.md to Cursor > Settings > Rules for AI"
    echo "  3. Reference workflows from your .cursorrules file"
  elif [ "$AGENT" = "codex" ]; then
    echo "  2. Reference workflows from your AGENTS.md file"
    echo "  3. Run codex exec to start your first feature"
  else
    echo "  2. Copy global-preferences.md to your agent's global config"
    echo "  3. Reference workflows from your agent's project config"
  fi

  if [ "$HAS_MULTI_TENANCY" = "false" ]; then
    echo ""
    echo -e "  ${YELLOW}Tip:${NC} No multi-tenancy detected. You can remove the"
    echo "  multi-tenancy sections from code-patterns.md and check-tenancy.md"
    echo "  if your project doesn't need them."
  fi

  echo ""
  echo -e "  ${BOLD}Docs:${NC} https://github.com/Razor1990-mm/claude-code-setup"
  echo ""
}

# -------------------------------------------------------------------
# Main
# -------------------------------------------------------------------

main() {
  print_header

  # Check we're in a project root
  if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "pyproject.toml" ] && [ ! -f "go.mod" ] && [ ! -f "Cargo.toml" ] && [ ! -f "Gemfile" ]; then
    print_error "No project detected in current directory."
    echo "  Run this from your project root (where .git or package.json lives)."
    exit 1
  fi

  detect_project
  ask_questions
  install_files
  post_install
}

main "$@"
