#!/usr/bin/env bash
# Agent hook: remind the agent when it committed on a task branch without touching the worklog.
#
# Stop hook. Gives the reminder as additionalContext, so the agent can update the
# worklog or decide the commit was too small to need it. It speaks once per stop:
# when stop_hook_active is true the agent has already seen it. Fails open on any
# unexpected error.
#
# Configure:
#   AGENT_WORKLOG         path of the worklog as it appears in edits (default docs/WORKLOG.md)
#   AGENT_BRANCH_PATTERN  extended regex matching task branches (default '^(claude|codex)/')

set +e

worklog=${AGENT_WORKLOG:-docs/WORKLOG.md}
branch_pattern=${AGENT_BRANCH_PATTERN:-'^(claude|codex)/'}

if ! command -v jq >/dev/null 2>&1; then exit 0; fi

input=$(cat)
transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // ""' 2>/dev/null)
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""' 2>/dev/null)

stop_hook_active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [ "$stop_hook_active" = "true" ]; then exit 0; fi

[ -f "$transcript_path" ] || exit 0
[ -n "$cwd" ] || exit 0

branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
if ! printf '%s' "$branch" | grep -qE "$branch_pattern"; then exit 0; fi

commits=$(jq -r '
  select(.message and .message.role == "assistant") |
  .message.content[]? |
  select(.type == "tool_use") |
  select(.name == "Bash") |
  .input.command // empty
' "$transcript_path" 2>/dev/null | grep -cE '(^|[[:space:]&;|])git[[:space:]]+commit([[:space:]]|$)' 2>/dev/null)
commits=${commits:-0}
if [ "$commits" -eq 0 ]; then exit 0; fi

worklog_edits=$(jq -r '
  select(.message and .message.role == "assistant") |
  .message.content[]? |
  select(.type == "tool_use") |
  select(.name == "Edit" or .name == "Write" or .name == "MultiEdit") |
  .input.file_path // empty
' "$transcript_path" 2>/dev/null | grep -cF "$worklog" 2>/dev/null)
worklog_edits=${worklog_edits:-0}

if [ "$worklog_edits" -eq 0 ]; then
  context="This session made ${commits} commit(s) on '${branch}' and did not update ${worklog}. AGENTS.md asks for the worklog to be updated when starting, pausing, handing off or finishing a task. Add or update your row before wrapping up, or skip it if this was a trivial follow-up commit."
  jq -nc --arg context "$context" '{hookSpecificOutput: {hookEventName: "Stop", additionalContext: $context}}'
fi

exit 0
