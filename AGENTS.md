# <PROJECT> Agent Operating Rules

<!--
How to use this template (delete this comment when you are done):
- Replace everything in <angle brackets>.
- Delete every section that does not apply. A rule nobody needs still costs context in every session.
- This file assumes an integration branch named `develop` and a release branch named `main`. If you only have `main`, replace `develop` with `main` throughout.
- Keep this file under 200 lines. Step-by-step procedures belong in skills. Rules that must never be broken belong in hooks (`scripts/agent-hooks/`).
-->

This repository is worked on by people and by AI coding agents, sometimes several at once and on more than one machine. GitHub, pull requests and `docs/WORKLOG.md` are the shared source of truth.

## Product And Team Ethos

<One or two sentences: who the product serves and what it helps them do.>

- **Start with the person's outcome.** Identify the need behind the request and the observable improvement that would satisfy it. Counts of features, passing tests or closed tickets do not establish user value on their own.
- **Judge the whole experience.** Follow the affected journey from the person's action to a result they can use, including interruptions, recovery, accessibility and performance. If tests pass but the reported experience still fails, investigate the gap and improve the checks.
- **Keep the promises made about data.** Treat privacy, security and transparency as product requirements. Check what is actually collected, sent, stored and deleted before making a claim about it. Never imply a protection that has not been established.
- **Strengthen human agency.** Preserve people's meaning, give them understandable choices, and give them a way to correct mistakes.
- **Choose simple, durable solutions.** Prefer the smallest coherent change that meets the real need and stays maintainable. Avoid shortcuts that pass hidden problems to users or to the next teammate. Raise adjacent issues instead of silently expanding the task.
- **Act as a responsible teammate.** Preserve others' work. Separate what was implemented, tested, observed and still assumed. Own mistakes and repair them. Leave handoffs that the next session can act on.

## Existing UI Copy

Keep the copy in existing designs unless the user asks for a change. Do not add, remove or rewrite UI text as part of a bug fix, performance improvement, refactor or visual adjustment. A new feature may include the copy needed to explain and use that feature, and nothing more.

## Platform Compatibility

<Delete this section if you ship on one platform. Otherwise list yours here, for example iOS, Android, web, desktop.>

- Before implementing, identify the impact on each platform, on shared code, native code, dependencies and build configuration. Say why an unaffected platform is isolated; a platform check in the code is not proof on its own.
- Share business logic and data contracts. Keep platform differences in small adapters or platform-specific files.
- Treat dependency, lockfile, build-config and plugin changes as affecting every platform until shown otherwise.
- Keep saved data readable across clients and versions. Version any format change and keep older clients working.
- Report evidence per platform: what was built, on which device or OS, and which checks passed, failed or were not run. Never claim one platform works from another platform's results. A bundle export or a mocked unit test does not establish device behavior.
- A cross-platform feature is not finished while one platform's behavior is unaddressed. State what remains, with an owner and a next step.

## Skills

Procedures live in skills under `.claude/skills/`, mirrored at `.agents/skills/` for tools that read that path. Only each skill's description loads at session start; the body loads when the skill is used. When a workflow is not spelled out in this file, check the skills first.

- `start-task`: start-of-task checklist (directory check, update `develop`, read the worklog, create the branch, add a worklog row).
- `supabase-migration`: claiming, generating, testing and applying database migrations.
- `triage-prod-logs`: pulling production logs for an incident, or a baseline scan before feature work.
- `<your-skill>`: <one line>.

Keep the two copies identical. A small test that compares the two directories catches drift.

## Hooks

The rules that must not be broken are enforced by the scripts in `scripts/agent-hooks/`: no commits on a protected branch, no edits outside your own worktree, tests before finishing a code change, and a reminder to update the worklog. When a hook stops you, the rule applies to what you were doing. Fix the cause; do not work around the hook.

## Working Directories

Each machine keeps one clone and one worktree per agent:

| Directory | Role | Branch prefix |
| --- | --- | --- |
| `~/<repo>` | Canonical clone. Stays on `develop`. Fetches, status checks and worktree management only; no code edits. | none |
| `~/<repo>-claude` | Claude's worktree. | `claude/` |
| `~/<repo>-codex` | Codex's worktree. | `codex/` |

- One agent per working directory. If you are in another agent's worktree or on its branch, stop before editing.
- If your checkout is on another session's branch or holds someone else's uncommitted work, do not switch it. Add a task worktree (see the `start-task` skill).
- Each worktree has its own dependencies. Install per worktree when the lockfile changes.
- Only one agent runs a shared local service (dev server, bundler, local database) at a time, unless ports and ownership are written in the worklog.
- Claim database migrations in the worklog before generating files. One agent generates or edits migrations at a time.
- Cloud and sandboxed sessions have a different layout. Work in the checkout you were given, on the branch you were assigned, and follow every other rule here.

## Branch Rules

- Never commit directly to `develop` or `main`.
- Name branches `<agent>/<area>-<short-task>`, for example `claude/onboarding-copy-pass` or `codex/sync-retry`.
- One branch is one focused task, owned by one session at a time. Record any handoff in the worklog.
- Do not mix commits from different agents on one branch unless the user asks.
- Push early, and open a draft PR when the work has shape.
- Before merge: update from the latest `origin/develop`, run the relevant checks, and describe the risk areas in the PR.
- Merge only when CI passes on the PR's latest commit. Never bypass a required check with an admin merge. If CI fails on a test the PR does not touch, record the failure and the run link in the PR and tell <owner> instead of re-running until it passes.

## Coordination Rules

- Update `docs/WORKLOG.md` when starting meaningful work, pausing, handing off or finishing.
- Keep each task to one Current Work line of about 300 characters: date, agent and machine, branch and PR, state, next step. Edit only your own row. Release records, test results and handoff detail go in the PR body, not in the worklog.
- Before adding a row, opening or updating a PR, or giving a final answer, check whether any Current Work row with a PR number has merged. GitHub is the source of truth.
- Archive a finished row instead of deleting it: move it to the top of Completed in `docs/worklog/<YYYY-MM>.md`, with the date and a short merge note. Do not read that folder at task start; search it when you need a past record or decision.
- When two PRs conflict in the worklog, keep both rows, and archive any whose PR has merged.
- Never revert another session's work unless the user asks for that specific revert.
- Commit or stash work in progress before switching branches. Stashes do not travel between machines; if another machine needs the work, put it on a branch and push it.
- Recommend deleting a branch only after GitHub shows its PR merged. Delete another agent's branch only with the user's approval or a recorded handoff.
- Never run destructive Git commands (`git reset --hard`, `git checkout -- <path>`, force-push) unless the user asks for that exact action.

## Releases

<Delete this section until the project ships. Link your release policy here if you have one.>

- A release needs the user to name the exact target in this session, for example "publish to production 1.4.2". A passing build or a finished validation does not authorize a release.
- Verify what is live and what users have installed before choosing a target. A built or uploaded candidate is not proof that it is publicly available.
- Support a small, named set of targets: the current test build, the current production version, and critical fixes for the previous production version. Do not update every historical version by default.
- Test the exact commit you ship. Any later commit means testing and building again.
- Record the previous artifact and the rollback steps before publishing. If the target already serves the tested change, verify it instead of publishing a duplicate.
- Documentation-only changes need no release.

## Review And Safety

- Prefer small PRs over broad mixed changes. Use `.github/pull_request_template.md`.
- Call out migrations, native code, config changes and feature flags in the PR description.
- Keep unfinished risky behavior behind a flag or out of `develop`.
- Never commit secrets. Never paste unsanitized production data, tokens or user content into issues, PRs or support requests.

## Testing Discipline

Run the unit tests for every behavior-changing edit before the final answer or PR, without waiting to be asked. Behavior-changing means anything that can alter runtime behavior: functions, hooks, services, state, parsing, storage, auth, navigation, side effects.

- New code ships with tests in the same PR: the happy path and at least one failure mode for anything with non-trivial logic.
- Follow the existing layout (`src/services/foo.js` goes with `src/services/__tests__/foo.test.js`) and the mocking patterns of the neighbouring tests. Extend an existing test file instead of adding a parallel one.
- Run the focused tests first: `<focused test command>`. Run the full suite (`<full test command>`) when touching shared services, auth, storage, navigation, data processing or migrations, or when the focused target is unclear.
- Never hide a failure, weaken an assertion or special-case a fixture to get a pass.
- When you add logging or diagnostics on a new code path, assert in its test that the log fires with the right scope and key fields.
- Exceptions, stated in the PR: pure config changes, documentation, native code the unit runner cannot reach, and pure rendering with no logic. An exception waives the unit test only; still run the build, device or manual check that applies. A planned check is not a completed check.

## Before Final Answer

State:

- The branch.
- What changed.
- Which tests and checks ran, and which did not, with the reason.
- Anything not completed.
- Whether changes are committed, pushed or only staged, and whether a push or PR is waiting on the user.
- Whether the worklog was updated.
