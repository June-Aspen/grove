#!/usr/bin/env bash
# Agent hook: block edits outside the agent's own worktree.
#
# Usage: worktree-boundary.sh <agent>        for example: claude, codex
#
# PreToolUse on Edit|Write. Assumes the layout in AGENTS.md: a canonical clone at <dir>
# and one worktree per agent at <dir>-<agent>. The canonical clone is found through git,
# so no path is hard-coded:
#   - edits under the canonical clone are denied (it is for fetches and worktree management);
#   - edits under another agent's worktree, <dir>-<other>, are denied;
#   - everything else is allowed, including task worktrees inside your own worktree.
# If <dir>-<agent> does not exist, this machine does not use the layout and the hook
# does nothing. Fails open on any unexpected error.
#
# Configure with AGENT_NAMES (space-separated, default "claude codex").

set +e

agent=${1:-}
if [ -z "$agent" ]; then exit 0; fi
if ! command -v jq >/dev/null 2>&1; then exit 0; fi

agents=${AGENT_NAMES:-"claude codex"}

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""' 2>/dev/null)
if [ -z "$file_path" ]; then exit 0; fi

case "$file_path" in
  /*) abs_path=$file_path ;;
  *) abs_path="${cwd:-$PWD}/$file_path" ;;
esac

# The canonical clone is the directory that holds the shared .git directory.
git_common=$(cd "${cwd:-.}" 2>/dev/null && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd)
if [ -z "$git_common" ]; then exit 0; fi
canonical=$(dirname "$git_common")
if [ ! -d "${canonical}-${agent}" ]; then exit 0; fi

deny() {
  jq -nc --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  exit 0
}

case "$abs_path" in
  "$canonical"/*)
    deny "${agent} must not edit '${abs_path}': '${canonical}' is the canonical clone. Edit from '${canonical}-${agent}' instead." ;;
esac

for other in $agents; do
  if [ "$other" = "$agent" ]; then continue; fi
  case "$abs_path" in
    "${canonical}-${other}"/*)
      deny "${agent} must not edit '${abs_path}': it is in ${other}'s worktree. Edit from '${canonical}-${agent}' instead." ;;
  esac
done

exit 0
