---
name: supabase-migration
description: Generate, edit, or review Supabase migrations safely when more than one agent or session works on the repository. Use when about to create files in `supabase/migrations/`, when editing existing migrations, when reviewing migration safety, when the user asks for a schema change, or when a feature needs new tables, columns, RLS policies, or stored procedures. Claims migration ownership in the worklog first so two sessions do not generate colliding files; covers generation, conventions, database tests, and applying a migration to production.
---

# Supabase migration discipline

Migrations need more coordination than any other part of the repository: two sessions can each generate a timestamped file, and the files collide when the work overlaps. The rule is: **claim migrations in `docs/WORKLOG.md` before generating files. One agent generates or edits migrations at a time.**

Commands below use `--linked`, which works through Supabase CLI v3. The CLI reference marks it deprecated and removed in v4 in favour of `--remote`. Check `supabase --version`, and on v4 confirm the replacement with `--help` before running anything against production.

## Before generating

1. **Read Current Work in `docs/WORKLOG.md`.** If another session has a row touching `supabase/migrations/`, stop, then wait or coordinate through the worklog.
2. **Add or update your Current Work row** with the migration scope, for example "add `<table>` table and RLS policies". Keep it short.
3. **Update your base** so you can see every migration already merged: `git fetch origin develop`.

## Generation

Run the Supabase CLI from the worktree root. Let the CLI name the file (`YYYYMMDDHHMMSS_<slug>.sql`) so timestamps stay monotonic:

```bash
supabase migration new <slug>
```

## Writing the migration

- Match the SQL style of the most recent migrations: indentation, comments, column naming.
- For a destructive change (`DROP COLUMN`, `ALTER TYPE` and similar), include a data migration in the same PR if existing rows are affected.
- For an RLS change, include the policy SQL and check that the policy name is unique.
- Never put real production data, tokens or user identifiers in a migration file. Use placeholders in seed-style data.

## Testing

Database tests should run locally with no network and no production data:

```bash
<database test command>
```

## Deploying

- Local development: `supabase migration up` against the local stack, or `supabase db reset` (destructive).
- Hosted projects: deploys are not automatic. In the PR, list which migrations and which `supabase functions deploy` function names must run. Repeat the deploy step in the PR's test plan and in the worklog row so it is not forgotten after merge.

### Applying a migration to production

First compare histories: `supabase migration list --linked`. If production's history matches the repository, `supabase db push --dry-run` shows what a push would apply.

If the histories have drifted (repo versions missing in production, versions with no repo file, versions from unmerged branches), do not use `supabase db push`. The dry run stops and suggests `supabase migration repair --status reverted ...` and `supabase db pull`. Run neither: they rewrite history that other sessions rely on.

Instead, apply one migration at a time, each with the user's explicit go-ahead for that migration:

1. Link this worktree (a new worktree is not linked): `supabase link --project-ref <project-ref>`. `supabase migration list --linked` and `supabase db query --linked "<sql>"` read production with the CLI credentials.
2. Before replacing a function, read production's definition (`select prosrc from pg_proc where proname = '<name>'`) and compare it byte for byte with the repository definition the migration was written from. Look for other migrations that touch the same object on every branch: `git log --all --oneline -S'<object>' -- supabase/migrations`.
3. Apply the exact file once: `supabase db query --linked -f supabase/migrations/<file>.sql`. Read the result back (definition, columns, policies) and check grants, for example with `has_function_privilege`.
4. Record only that version: `supabase migration repair --linked --status applied <version>`.
5. `supabase unlink`. In the worklog and the PR, record the time, the file's SHA-256, the rollback SQL, and that `develop` lacks the file until the PR merges.

## Safety checklist before merge

- The migration was applied locally and the app runs against the new schema.
- Each new RLS policy was tested from at least one user's perspective.
- The schema change lives only under `supabase/migrations/`.
- The worklog row names the migration file or scope.
- A risky change (`DROP`, `ALTER TYPE` on a populated column, an RLS rewrite) is called out in the PR description.
