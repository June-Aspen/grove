@AGENTS.md

## Claude

<!-- The first line of this file imports AGENTS.md, so the shared rules live in one file and cannot drift apart. Keep only Claude-specific notes below, and delete the ones that do not match how you run Claude. -->

- In the rules above you are the Claude agent: branch prefix `claude/`, worktree `~/<repo>-claude`.
- **Sandboxed desktop sessions.** If the sandbox has no GitHub credentials, or cannot see the canonical clone's `.git` directory, prepare the changes and give the user the exact `git push` or PR command to run in their own terminal.
- **Cloud sessions.** The container is temporary. Commit and push to the assigned branch before finishing; unpushed work is lost with the container.
