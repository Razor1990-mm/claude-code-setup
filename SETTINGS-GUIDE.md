# Settings Guide

How to configure `settings.json` for Claude Code hooks and plugins.

## File Location

Place `settings.json` in your project's `.claude/` directory:
```
your-project/.claude/settings.json
```

## Hooks

Hooks are shell scripts that run before or after tool calls. They automate guardrails.

### PreToolUse Hooks

Run **before** a tool executes. Can block the action.

| Exit Code | Behavior |
|-----------|----------|
| `0` | Allow the tool call |
| `2` | **Block** the tool call (agent sees BLOCKED message) |
| Other | Error (tool call proceeds) |

**Example: Block checkout to main**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": ["hooks/block-checkout-main.sh"]
      }
    ]
  }
}
```

### PostToolUse Hooks

Run **after** a tool executes. Cannot block — advisory only.

**Example: Warn on domain edits missing tenant filters**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": ["hooks/check-domain-tenancy.sh"]
      }
    ]
  }
}
```

### Matcher Syntax

The `matcher` field filters which tool calls trigger the hook:

| Matcher | Matches |
|---------|---------|
| `"Bash"` | Only Bash tool calls |
| `"Edit\|Write"` | Edit OR Write tool calls |
| `"*"` | All tool calls |

### Environment Variables Available in Hooks

| Variable | Description |
|----------|-------------|
| `TOOL_NAME` | Name of the tool being called (Bash, Edit, Write, etc.) |
| `TOOL_INPUT_command` | For Bash: the command being run |
| `TOOL_INPUT_file_path` | For Edit/Write: the file being modified |
| `TOOL_INPUT_old_string` | For Edit: the string being replaced |
| `TOOL_INPUT_new_string` | For Edit: the replacement string |

## Plugins

<!-- CUSTOMIZE: Add plugins relevant to your project -->

```json
{
  "enabledPlugins": {
    "context7@claude-plugins-official": true
  }
}
```

Common plugins:
- `context7` — Library API documentation (lookup docs for any framework)
- `frontend-design` — Design system inspection and component generation
- `code-simplifier` — Automated code refactoring suggestions

## Full Example

```json
{
  "enabledPlugins": {
    "context7@claude-plugins-official": true
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": ["hooks/block-checkout-main.sh"]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": ["hooks/check-domain-tenancy.sh"]
      }
    ]
  }
}
```
