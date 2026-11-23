---
name: triage-prod-logs
description: Pull and analyze production diagnostics from the backend logs and the error tracker. Use when the user reports a production issue, freeze, error, or crash; when a screenshot shows a timestamp; when investigating "just happened" or "broken in prod"; before starting non-trivial feature work (24-hour baseline scan). Picks the timeframe and sources from the report and runs the log collector.
---

# Production log triage

<!--
This skill needs one thing from your project: a command that pulls production logs for a time window into an ignored local folder and exits nonzero when a source fails. Replace `<logs command>` with yours, and replace the source names with the ones your stack has (for example your error tracker's events and your backend's function, auth, storage and realtime logs). Delete this comment when done.
-->

Use this skill whenever work needs production context: before a non-trivial feature, and during any incident.

## Credentials

**Run the collector first. Do not stop because a local env file is missing.** It should take credentials in this order:

1. Explicit environment values, then the worktree's ignored `.env.local`.
2. An owner-only file in the home directory, shared across worktrees: `~/.config/<project>/production-diagnostics.env` (directory mode 0700, file mode 0600).
3. The logins the vendor CLIs already hold.

Use read-only tokens with the smallest scope that can read logs. Never commit these files. Do not search other checkouts for credential files, and do not route tokens through wrapper scripts.

A run with missing credentials or a failed source exits nonzero. An empty result is not proof of a healthy system. Only when the collector itself reports missing credentials, say so plainly and continue with the best local evidence.

## Picking the timeframe

Match the report to the smallest useful window:

- **Screenshot with a visible timestamp:** convert the local time to UTC, and pull about 30 minutes either side.
- **"Just happened":** the last 2 hours.
- **Deploy regression:** from the publish time through the report time.
- **Background job, push or upload:** function logs, storage logs and error-tracker events.
- **Auth or session:** auth logs, edge or gateway logs, and error-tracker events.
- **Realtime or messaging:** realtime logs, function logs, and error-tracker events.
- **UI freeze or stuck screen:** error-tracker events, plus the logs for any backend workflow the screen shows.

Use exact absolute timestamps in notes. Keep raw output local. Never paste unsanitized production metadata into a public issue or PR.

## Commands

Baseline before non-trivial feature work (last 24 hours):

```bash
<logs command> --hours 24 --grep "error|failed|stall|timeout|crash"
```

Incident window from a screenshot or report:

```bash
<logs command> --from <start-iso> --to <end-iso> --grep "<terms from the report>"
```

## After running

1. Skim the summary and the filtered output for fresh errors, stalls, failed jobs, backend limits and repeated retries. An error tracker usually returns the latest event per issue, which is a sample and not every occurrence. Read the breadcrumbs: a step missing from the trail is evidence that the step before it threw.
2. If the logs show an active production problem unrelated to the requested work, create or update an issue with:
   - the timeframe in UTC, plus the user's local time zone when useful;
   - the app version or release id;
   - the error-tracker issue and event ids;
   - the log sources queried;
   - the user-visible symptom;
   - the most likely subsystem, and your confidence;
   - which additional logs would raise that confidence.
3. Mention the issue in `docs/WORKLOG.md` or the PR notes before continuing the feature work.
