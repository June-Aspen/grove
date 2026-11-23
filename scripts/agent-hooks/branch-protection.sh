#!/usr/bin/env bash
# Agent hook: block git commit, add and push on a protected branch.
#
# PreToolUse on Bash. Reads the hook JSON on stdin and prints a deny decision when the
# command would stage, commit or push while a protected branch is checked out.
# Fails open: any unexpected error exits 0 with no output, so a broken hook never
# blocks unrelated work.
#
# Configure with AGENT_PROTECTED_BRANCHES (space-separated, default "main master develop").

set +e

protected=${AGENT_PROTECTED_BRANCHES:-"main master develop"}

if ! command -v jq >/dev/null 2>&1; then exit 0; fi

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""' 2>/dev/null)

# Only inspect git commit/add/push invocations.
if ! printf '%s' "$cmd" | grep -qE '(^|[[:space:]&;|])git[[:space:]]+(commit|add|push)([[:space:]]|$)'; then
  exit 0
fi

branch=$(git -C "${cwd:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -z "$branch" ]; then exit 0; fi

for name in $protected; do
  if [ "$branch" = "$name" ]; then
    reason="Refusing this git command on protected branch '${branch}'. Create or switch to a task branch first (see Branch Rules in AGENTS.md)."
    jq -nc --arg reason "$reason" \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
    exit 0
  fi
done

exit 0
