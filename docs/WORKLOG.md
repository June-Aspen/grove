# <PROJECT> Worklog

The shared board for active work by every agent session on every machine. Read it before starting work. It stays small on purpose.

- **One line per task**, about 300 characters at most: date, agent and machine, branch and PR, state, next step. Release records, test results and handoff detail go in the PR body, not here.
- **Edit only your own row.** Add new rows at the top of Current Work. When resolving a conflict here, keep every other row as it is.
- **Archive when done.** When a task's PR merges or the task ends, move its row to the top of Completed in `docs/worklog/<YYYY-MM>.md` (the month it finished; start the file if it is new) with a short merge note. Do it in the finishing PR, or as the next agent who notices. Check GitHub first, for example `gh pr view <number> --json state,mergedAt`.
- **History** is in `docs/worklog/`, one file per month, newest first. Do not read it at task start; search it when you need a past record or decision, for example `grep -rn '#123' docs/worklog/`.

## Current Work

## Parked Or Retained

Branches, stashes and drafts kept on purpose. Do not delete, merge or publish them without the owner's OK.

## Entry Template

Current Work or Parked row:

```md
- YYYY-MM-DD | <Agent> on <machine> | `<branch>` #<PR> | <In progress / In review / Blocked / Waiting on <owner>> | Next: <one step>
```

Archive row, at the top of Completed in `docs/worklog/<YYYY-MM>.md`:

```md
- YYYY-MM-DD | #<PR> `<branch>` | <one-sentence summary> | Merged to `develop` at <commit>
```

For a handoff, write in the PR body (not here): the branch, whether all work is pushed, the tests and checks already run, the files or flows most likely to conflict, and the exact next step for the receiving session.
