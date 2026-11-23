#!/usr/bin/env bash
# Agent hook: block a stop when source files were edited but no test command ran.
#
# Stop hook. Reads the session transcript and returns decision "block" so the agent
# either runs the tests or says why they do not apply (documentation, pure config,
# code the unit runner cannot reach). It blocks once per stop: when stop_hook_active
# is true the agent has already seen the reason. Fails open on any unexpected error.
#
# Configure:
#   AGENT_SOURCE_PATTERN  extended regex matching behavior-changing file paths
#   AGENT_TEST_PATTERN    extended regex matching a test command

set +e

source_pattern=${AGENT_SOURCE_PATTERN:-'(^|/)(src|app|lib)/.*\.(js|jsx|ts|tsx|mjs|cjs|py|rb|go|rs|swift|kt)$'}
test_pattern=${AGENT_TEST_PATTERN:-'(jest|vitest|pytest|go[[:space:]]+test|cargo[[:space:]]+test|(npm|pnpm|yarn|bun)[[:space:]]+(run[[:space:]]+)?test)'}

if ! command -v jq >/dev/null 2>&1; then exit 0; fi

input=$(cat)
transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // ""' 2>/dev/null)

stop_hook_active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [ "$stop_hook_active" = "true" ]; then exit 0; fi

[ -f "$transcript_path" ] || exit 0

edit_paths=$(jq -r '
  select(.message and .message.role == "assistant") |
  .message.content[]? |
  select(.type == "tool_use") |
  select(.name == "Edit" or .name == "Write" or .name == "MultiEdit") |
  .input.file_path // empty
' "$transcript_path" 2>/dev/null)

source_edits=$(printf '%s\n' "$edit_paths" | grep -cE "$source_pattern" 2>/dev/null)
source_edits=${source_edits:-0}
if [ "$source_edits" -eq 0 ]; then exit 0; fi

test_runs=$(jq -r '
  select(.message and .message.role == "assistant") |
  .message.content[]? |
  select(.type == "tool_use") |
  select(.name == "Bash") |
  .input.command // empty
' "$transcript_path" 2>/dev/null | grep -cE "$test_pattern" 2>/dev/null)
test_runs=${test_runs:-0}

if [ "$test_runs" -eq 0 ]; then
  reason="This session edited ${source_edits} source file(s) and ran no test command. AGENTS.md asks for the focused tests to run before the final answer. Run them now, or say in the final response why tests do not apply (documentation, pure config, code the unit runner cannot reach)."
  jq -nc --arg reason "$reason" '{decision: "block", reason: $reason}'
fi

exit 0
