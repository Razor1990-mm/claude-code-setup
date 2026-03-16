#!/bin/bash
# PostToolUse hook: Auto-warn on domain file edits missing tenant filters
# Non-blocking (async warning) — does NOT stop the edit, just alerts
#
# Wiring (settings.json):
#   "PostToolUse": [{ "matcher": "Edit|Write", "hooks": ["hooks/check-domain-tenancy.sh"] }]
#
# <!-- CUSTOMIZE: Update DOMAIN_PATH and FIND_METHOD to match your project -->

# Only check Edit and Write tool calls
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

# Configure these for your project
DOMAIN_PATH="src/domain/"          # <!-- CUSTOMIZE: Path to domain layer -->
FIND_METHOD="findUnique"           # <!-- CUSTOMIZE: ORM method that fetches by ID -->
TENANT_FIELD="orgId"               # <!-- CUSTOMIZE: Your tenant scoping field -->

FILE_PATH="$TOOL_INPUT_file_path"

# Only check domain files
if ! echo "$FILE_PATH" | grep -q "$DOMAIN_PATH"; then
  exit 0
fi

# Check for findUnique/findById without orgId
if grep -n "$FIND_METHOD" "$FILE_PATH" 2>/dev/null | grep -v "$TENANT_FIELD" | head -5; then
  echo ""
  echo "WARNING: $FILE_PATH may have queries missing '$TENANT_FIELD' filter."
  echo "Every domain query must be tenant-scoped. Run /check-tenancy to validate."
  echo ""
fi

# Always exit 0 — this is advisory, not blocking
exit 0
