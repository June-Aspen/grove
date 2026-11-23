# grove

A starting set of instruction files, skills and hooks for building a product with AI coding agents (Claude Code, Codex and similar), including several agents at once and on more than one machine.

## What is here

| Path | Purpose | When an agent sees it |
| --- | --- | --- |
| `AGENTS.md` | The shared rules: ethos, branches, coordination, testing, releases. | Every session |
| `CLAUDE.md` | Imports `AGENTS.md` and adds Claude-only notes, so no rule is written twice. | Every Claude session |
| `docs/WORKLOG.md` | A one-line-per-task board of active work. Finished rows move to `docs/worklog/<YYYY-MM>.md`. | At the start of a task |
| `.claude/skills/start-task/` | Start-of-task checklist, task worktrees, shell traps. | On demand |
| `.claude/skills/supabase-migration/` | Claiming, generating and applying migrations. | On demand |
| `.claude/skills/triage-prod-logs/` | Production log triage. Needs a log-pulling command of your own. | On demand |
| `scripts/agent-hooks/` | Four hooks that enforce the rules that must not be broken. | On every matching action |
| `.claude/settings.json`, `.codex/hooks.json` | Wire the hooks into Claude Code and Codex. | n/a |
| `.github/pull_request_template.md` | Where test evidence and risk areas get written down. | When a PR is opened |

## Setting it up

1. Copy the files into the root of your repository, keeping the paths.
2. Replace everything in `<angle brackets>` and delete the template comments.
3. Delete every section and skill your project does not need yet. One platform: drop "Platform Compatibility". Nothing released: drop "Releases". One agent on one machine: cut "Working Directories" down to the rows you use.
4. Make the hooks executable (`chmod +x scripts/agent-hooks/*.sh`) and install `jq`. See `scripts/agent-hooks/README.md`.
5. If you use Codex or another tool that reads `.agents/skills/`, copy `.claude/skills/` there and keep the two identical.

## How to grow it

These files are a structure to fill in. The rules that end up mattering most are specific to your project, and you can only write those as you go.

- **Keep the always-loaded file short.** `AGENTS.md` loads into every session. Aim for under 200 lines of facts an agent cannot work out from the code: branch names, commands, where things live, what must be checked before a release.
- **Write each rule once.** `CLAUDE.md` imports `AGENTS.md`. Two hand-synced copies drift, and then each agent follows different rules.
- **Put procedures in skills.** When an agent gets a multi-step job wrong twice, write the correct steps into a skill, including the command that failed and why. A skill costs one line of context until it is used.
- **Put hard limits in hooks.** For anything that must never happen, such as a commit on `main` or finishing a code change without running tests, a hook blocks it every time.
- **Keep the worklog to one line per task.** Agents read it at the start of every task. Detail belongs in the pull request, and history in the monthly archive.
- **Prune.** Remove a rule when the tooling starts enforcing it, or when it describes a setup you no longer use. Stale and contradictory instructions make the good ones less reliable.

## License

MIT. See `LICENSE`. Use it, change it and share it, including in commercial work.

## Credit

The hooks are the Daisy Agent Management Network (DAMN), named as a thank-you to [Daisy Hollman](https://www.linkedin.com/in/daisy-hollman) of Anthropic, whose talk on Claude Code they grew from. She has not reviewed or endorsed this kit. See `scripts/agent-hooks/README.md`.
