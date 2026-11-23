---
name: start-task
description: Run the start-of-task checklist before writing code. Use when the user starts a new task, picks up a different task, switches branches, or resumes after a break; when handing work to or from another agent; when the checkout is on `develop` and meaningful work is about to begin. Confirms the working directory, updates `develop`, reads the worklog, creates a focused task branch, and adds a one-line worklog row.
---

# Start-of-task checklist

Before writing any code:

1. **Confirm the working directory.** You should be in your own agent worktree (see "Working Directories" in `AGENTS.md`) or in a task worktree under it. If you are in the canonical clone or another agent's worktree, stop before editing.
2. **Run `git status --short --branch`.** Know what is already modified or staged before touching anything.
3. **Read `docs/WORKLOG.md`.** It holds only active and parked work, one line per task. Look for a row that overlaps the task. If there is one, either take it over and record the handoff, or pick a different scope. History is in `docs/worklog/<YYYY-MM>.md`; do not read it now, search it when you need a past record.
4. **Archive merged rows.** For each Current Work row with a PR number, check GitHub, for example `gh pr view <number> --json state,mergedAt`. Move a merged row to the top of Completed in `docs/worklog/<YYYY-MM>.md` (the month it finished) with the merge date and a short note. Do not delete it.
5. **Update the base.** `git fetch origin develop`. If you are on `develop`, `git pull --ff-only origin develop`.
6. **Create a focused task branch.** `git checkout -b <agent>/<area>-<short-task>`. If the checkout is on another session's branch or holds someone else's uncommitted work, leave it as it is and add a task worktree (below). One branch is one task.
7. **Add a worklog row** at the top of Current Work: one line of about 300 characters following the Entry Template, naming the agent and the machine (for example `Claude Code on <machine>`) so other sessions can tell who is who. Put detail in the PR body, not the row.
8. **Push early.** `git push -u origin <branch>`, and open a draft PR when the work has shape.

## Task worktree when the checkout is busy

Several sessions often share one agent checkout, and switching its branch pulls work out from under them. Start the task in its own worktree instead:

1. From your agent checkout:
   ```bash
   git fetch origin develop
   git worktree add -b <agent>/<area>-<task> .worktrees/<name> origin/develop
   ```
   Use another base when the task needs one, such as the commit a released build was made from. The new branch starts out tracking `origin/develop`, so push it with `git push -u origin <branch>`.
2. If `git status` in the agent checkout lists `.worktrees/`, add that line to `.git/info/exclude` in the canonical clone.
3. **Dependencies.** A new worktree has none. For a Node project, if a sibling worktree has an identical lockfile (`cmp <sibling>/package-lock.json package-lock.json` prints nothing), clone its install: `cp -Rc <sibling>/node_modules ./node_modules`. On macOS (APFS) this is a copy-on-write clone that takes seconds. Otherwise run `npm ci`.
4. Work, commit and push from the task worktree only. Leave the shared checkout's branch and files as they were.

## zsh traps

These have produced wrong answers in agent-run shells on macOS:

- Never name a loop variable `path`. It is tied to `PATH`, so every command in the loop fails with "command not found".
- `"$ref:src/file.js"` and `$H:refs/...` are read as modifiers (`:s`, `:r`), so the result errors or is silently cut short. Write `"${ref}:src/file.js"` and `${H}:refs/heads/...`.
- An unquoted variable holding several paths is passed as one word. Use an array: `F=(a b c)`, then `$F`.
- A word starting with `=` expands to a command path, so `echo =====` fails. Quote it.
