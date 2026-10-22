---
name: session-end
description: "End of the day, or of the week with --full: rewrites SESSION_STATE.md within its quotas, absorbs today's checkpoints into the SESSION_LOG.md entry, runs the personal extension, commits and pushes. Use when the user ends the session (\"we're done for today\", \"close the session\", \"/session-end\") or the week (\"close the week\", \"--full\"). Not for finishing one task (session-checkpoint) or a function."
---

# session-end

Two sizes, and **the day is the default**. `--full` runs on request or by date, never by
reflex. Formats, quotas and rules: `../../references/files.md`.

## 1. Confirm before writing

This skill fires on natural language, and "let's wrap up" may be about a task. Before touching
any file or running git, confirm in one line, saying which size and why:

> `Closing the day — STATE rewritten, LOG entry, extension, push. OK?`
> `Closing the week (last full end on DD/MM, N days ago) — all of the day plus pruning. OK?`

**Full** when the user asked ("close the week", `--full`) or when the STATE's `last-full-end` is
missing or older than 7 days. Decide and say which trigger fired; do not ask "day or week?".
If the user only meant a task, point to `session-checkpoint` and stop.

## 2. Synthesize

Before writing, assemble: what was done (features, fixes, refactors), decisions (choices and
trade-offs not obvious from the code), what is left, what comes next. Today's `### checkpoint`
sub-blocks enter this synthesis.

**Separate what was verified from what was only written.** Committed code, a green test and a
feature exercised in production are not the same thing. Each done item carries its evidence
(test run, query checked, screen opened, execution id) or its absence, said in full: *delivered,
not exercised*.

## 3. Rewrite SESSION_STATE.md

A photo of now, not a diary: if something is no longer true, it is gone. In this order:

- `## In progress`: keep only the blocks still in flight. For each block not touched today,
  ask in one batched question whether it stays. Blocks of tasks finished today are deleted.
- `## Current state`: what works, each with the pointer to its evidence. 12 bullets of up to
  2 lines; a longer bullet becomes a pointer to the LOG.
- `## To exercise`: each `**Done, not exercised:**` item of today's entry becomes a line with
  its **proof**. A line whose proof happened today leaves, and its evidence goes to `## Current
  state` as a pointer. 6 items; an empty section is left out.
- Pending items, in the four sections, using the moves from `files.md`: a closed item
  disappears; "leave it for later" goes to `## Deferred` **with a reason**; an unblocked item
  returns to `## Now` where the user says; a new item is born in `## Now` or `## Deferred`.
  Every line ends with `(measured DD/MM)` or `(assumed)`. `## Now` is ordered and has up to 7.
- Frontmatter: `last-session` = today; on `--full`, also `last-full-end`.
- **Check the quotas before going on** (header 10, block 15, Current state 12, To exercise 6,
  Now 7, one line each elsewhere, 80 in all). Over: cut now; what leaves is already in the LOG.

On a feature branch, only this repo's `## In progress` block and the LOG are written
(`../../references/branches.md`). With sibling repos, rewrite the STATE of each repo the
session touched (`../../references/multi-repo.md`).

## 4. Prune (`--full` only)

One batched question per group, "delete these N?", and the deleted lines go to the day's entry
under `**Pruned:**`:

1. `## Deferred` items older than 4 weeks with no return condition.
2. `## Debt`, all of it: what the user keeps, stays.
3. `## Blocked` items older than 4 weeks: still waiting?
4. `## In progress` blocks whose branch has no commit for 7 days.

This is the one place where age counts. The daily briefing never nags by date.

## 5. The LOG entry

At the top of `SESSION_LOG.md`, today's entry: `## YYYY-MM-DD — <short title>`, with
`**Summary:**` (required, one sentence: it is what the next start reads), `**Done:**`,
`**Done, not exercised:**`, `**Decisions:**`, `**Pending:**`, and `**Pruned:**` on `--full`.
If today's entry exists (checkpoints, an earlier part), rewrite it **absorbing** the
`### checkpoint` sub-blocks. Never edit other days' entries.

**Month changed since the previous entry?** Do the monthly rotation (`files.md`): the previous
month's entries move to `docs/sessions/YYYY-MM.md`, in this same commit.

## 6. Extension

If `~/.claude/ritual-extend.md` exists: run `## End` on a day's end, `## Full end` on `--full`
(`../../references/extension.md`). Missing file or section: nothing happens, nothing is said.

## 7. Commit and push

`git pull --rebase` first (another machine may have pushed; a conflict is resolved, never
force-pushed). Then `git add` the session's files (code + the two docs, and `docs/sessions/`
on rotation) and commit:

```
<type>: <one-line summary of what was done>

<bullets of the main items, if more than one>
```

Push to the current branch. Confirm in one line that it went up. If the push fails, say the
error; do not claim the session is closed.

Not part of the ritual: the test suite (the repo's own rules decide), the code graph, deploys.
