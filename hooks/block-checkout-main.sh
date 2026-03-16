#!/bin/bash
# PreToolUse hook: Block git checkout main from feature branches
# Prevents accidental branch switches that cause merge conflicts
#
# Wiring (settings.json):
#   "PreToolUse": [{ "matcher": "Bash", "hooks": ["hooks/block-checkout-main.sh"] }]
#
# Exit codes:
#   0 = allow the tool call
#   2 = block the tool call (shows BLOCKED message to agent)

# Only check Bash tool calls
if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

# Check if the command is trying to checkout main/master
COMMAND="$TOOL_INPUT_command"
if echo "$COMMAND" | grep -qE 'git\s+checkout\s+(main|master)'; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
  if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "BLOCKED: Do not switch to main from feature branch '$CURRENT_BRANCH'."
    echo "Stay on your working branch. Ask the user if you need to switch."
    exit 2
  fi
fi

exit 0
