# Agent hooks

Four small scripts that enforce the rules in `AGENTS.md` that must not be broken. Instruction files are guidance, and an agent can miss a line. A hook runs every time.

Together they are the Daisy Agent Management Network, DAMN for short.

## Credit

The name is a thank-you to [Daisy Hollman](https://www.linkedin.com/in/daisy-hollman) of Anthropic. This hooks system was built after its author listened to her talk "Beyond the Basics with Claude Code" (2026-05-26).

Daisy Hollman has not reviewed or endorsed these scripts. Any mistakes in them are the author's.

## Scripts

All four read the hook JSON on stdin and **fail open**: a missing `jq`, unreadable input or a git error exits silently with code 0, so a broken hook never blocks unrelated work. They are guard rails for a cooperative agent, not a security boundary.

| Script | Event | What it does | Configure with |
| --- | --- | --- | --- |
| `branch-protection.sh` | `PreToolUse` on `Bash` | Denies `git commit`, `git add` and `git push` while a protected branch is checked out. | `AGENT_PROTECTED_BRANCHES` (default `main master develop`) |
| `worktree-boundary.sh <agent>` | `PreToolUse` on `Edit\|Write` | Denies edits under the canonical clone and under another agent's worktree. Finds the canonical clone through git; does nothing on a machine without `<clone>-<agent>` worktrees. | `AGENT_NAMES` (default `claude codex`) |
| `tests-ran-check.sh` | `Stop` | Blocks the stop when source files were edited and no test command ran. The agent runs the tests or says why they do not apply. | `AGENT_SOURCE_PATTERN`, `AGENT_TEST_PATTERN` |
| `worklog-reminder.sh` | `Stop` | Reminds the agent when it committed on a task branch without updating the worklog. | `AGENT_WORKLOG` (default `docs/WORKLOG.md`), `AGENT_BRANCH_PATTERN` |

The two `Stop` hooks speak once per stop. Claude Code sets `stop_hook_active` in the hook input when it is already continuing because of a stop hook; the scripts check it, so an agent with a valid reason to skip is not sent back again and again.

## Setup

1. Copy `scripts/agent-hooks/` into your repository and make the scripts executable: `chmod +x scripts/agent-hooks/*.sh`.
2. Install `jq` (1.6 or later) and make sure `git` and `bash` are on the path.
3. Claude Code: copy `.claude/settings.json`, or merge its `hooks` block into yours. Project hooks run once the workspace is trusted.
4. Codex: copy `.codex/hooks.json`. Codex asks you to trust project hooks before it runs them, and asks again when a script changes. Hook support differs between versions, so check that yours reads this file.
5. Set the variables in the table where your project differs, for example a source pattern for your language or a different worklog path.

## Trying one by hand

```bash
echo '{"tool_input":{"command":"git commit -m test"},"cwd":"'"$PWD"'"}' | scripts/agent-hooks/branch-protection.sh
```

On a protected branch this prints a deny decision. On a task branch it prints nothing.
