# Branches and worktrees

The app and the user create feature branches and worktrees often. Without a rule, each one
grows its own `SESSION_STATE.md`, and the merge conflicts on the two files that are supposed to
tell the truth.

## The rule

- **The STATE belongs to the main branch** (`main`, `master`, or what `origin/HEAD` points to).
  Only `session-end` on the main branch rewrites it whole.
- **On a feature branch or worktree**, `session-checkpoint` and `session-end` write:
  - the LOG (the day's entry, as usual);
  - their **own block** in `## In progress` (title ending with the branch name);
  - nothing in `## Current state`, `## To exercise`, `## Now`, `## Blocked`, `## Deferred`, `## Debt`.
- The start script prints, on a feature branch, the line
  `- Feature branch: STATE is owned by <main>; this branch writes only its ## In progress block and the LOG.`
  The briefing repeats it in one line and the session follows it.

## On merge

- `SESSION_STATE.md`: conflicts in `## Current state`, `## To exercise` and the pending sections resolve **in favor
  of the main branch**. The branch's `## In progress` block comes in (or is deleted, if the merge
  finished the task).
- `SESSION_LOG.md`: entries are appended at the top; a conflict is both sides kept, newest first.
- After the merge, the next `session-end` on main rewrites the STATE with what the branch
  delivered: that is where "delivered, not exercised" items from the branch enter `## To exercise`.

## Why

One STATE per repo is what makes the briefing honest for whoever opens the repo on main. A
branch that rewrote `## Now` would be planning for a tree that is not the one the next session
will see.
