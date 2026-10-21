# Files

The single source for the format of the two files the ritual writes. The three skills cite
this file; they do not repeat it. Section headers and bullet labels below are **fixed** (the
scripts and the quotas depend on them); the text inside each line is free, in any language.

## SESSION_STATE.md

A photo of now, rewritten by `session-end`. Never a diary.

```markdown
---
last-session: 2026-10-21
last-full-end: 2026-10-16
---

# Session state — <project>

**Scope:** <what this repo covers>.
**Sibling repos:** `<path>` — <what it covers>.   (only if any; the path between backticks)

## In progress

### <task title> — branch `<branch>` (since DD/MM)
- Plan: `docs/superpowers/plans/<file>.md`, task 7 of 18.
- In flight: `src/x.ts` with the RED test for ordering; `npm test -- x` reproduces.
- Decided in conversation, not yet in code: pinning is per user, not per company.
- Next step: make the test pass; then task 8 (needs the go-ahead: touches `assignments`).

## Current state
- <what works, with the pointer to its evidence: execution id, commit, query>
- <what was delivered and **never exercised**, said that way>

## Now
1. <what to do next, in order — position is the priority> [2h] (measured 20/10)
2. <...>

## Blocked
- <what is waiting> (waiting on <who>: <the condition that unblocks it>)

## Deferred
- <what was skipped on purpose> (deferred DD/MM: <reason>; back when <condition>)

## Debt
- <one line, no context needed to understand it>
```

Date in the frontmatter, never "today" in the body: write "delivered on 24/08", not "delivered
today". An event scheduled is not an event that happened: "the meeting is on 27/08" goes to
`## Now`, never to `## Current state`.

## Quotas

The STATE is read whole at every start and rewritten whole at every end. Each line costs
twice. `session-end` checks these before committing; what is cut is already in the LOG.

| Section | Quota |
|---|---|
| header (frontmatter, title, Scope, Sibling repos) | 10 lines |
| `## In progress` | 15 lines per `###` block |
| `## Current state` | 12 bullets, each up to 2 lines |
| `## Now` | 7 items |
| `## Blocked`, `## Deferred`, `## Debt` | 1 line per item |
| **whole file** | **80 lines** |

## Diet rules

- **A rule that never changes does not live here.** A permanent project rule ("never call X
  directly") belongs in the repo's `CLAUDE.md`. Moving one there is the only time the ritual
  touches `CLAUDE.md`, and it still asks the repo's maintainer first.
- **A closed item disappears.** No `~~strikethrough~~`, no "RESOLVED on DD/MM": the history is
  in the LOG. When work during the session closes an item, delete its line right then, in a
  one-line edit, with no commit of its own.
- **Evidence becomes a pointer.** "Proven in execution 9924, commit `ad35279`", not the story
  of the execution. The story lives in the LOG.
- **A bullet that needs more than 2 lines becomes a pointer** to the LOG entry that has it.

## Pending items

Four sections, by what to do with the item, not by what kind of item it is:

| Section | What goes in | Who reads it |
|---|---|---|
| `## Now` | what to do next, **ordered**, up to 7 | the briefing, whole |
| `## Blocked` | `(waiting on <who>: <condition>)` | the briefing only says which ones changed |
| `## Deferred` | skipped on purpose: `(deferred DD/MM: <reason>; back when <condition>)` | nobody, until the condition |
| `## Debt` | no context left to resume it, one line each | `--full`, to prune |

Priority is the **position in `## Now`**. There is no priority label.

A line: `- <what is left, with the pointer to resume> [2h] (measured 20/10)`.

- `[2h]`, `[day]`, `[week]`: effort estimate, **only in `## Now`**, optional.
- `(measured DD/MM)` / `(assumed)`: how the item was established, **at the end of the line**.
  Required. An assumed item enters the briefing as a hypothesis, never as a fact: "the STATE
  says X is broken, not measured". If it will define the day's work, confirming it is step one.
- No "since DD/MM" in `## Now` or `## Blocked`: the date of origin is in the LOG. Only
  `## Deferred` carries a date, as `(deferred DD/MM)`.

Moves:

- **Close:** the line disappears at once (see Diet rules).
- **Defer:** "leave this for later" moves the item from `## Now` to `## Deferred` **with a
  reason**. The skill does not accept a deferral without one; the return condition is optional.
- **Unblock:** a blocked item whose condition was met goes back to `## Now`, at the position the
  user says; with no answer, last.
- **Arise:** a new item is born in `## Now` (if it will be done) or `## Deferred` (if not).
  Nothing is born in `## Debt`.
- **Prune** (`session-end --full` only): Deferred older than 4 weeks with no return condition,
  Debt, Blocked older than 4 weeks, and In-progress blocks with no commit on their branch for 7
  days. One batched question each ("delete these N?"); what is deleted goes to the day's LOG entry
  under `**Pruned:**`. A date is never a nag in the daily briefing; pruning is where age counts.

## In progress blocks

The hand-off between two sessions. One `###` per task in flight, first section after the header.

- **Pointer, not copy.** The plan, the spec, the LOG entry and the commit already exist; the
  block says where you stopped inside them and the literal next step. **Up to 15 lines.** A block
  that wants to grow is a plan missing or a task that should have ended.
- **Who writes it:** `session-checkpoint`. It replaces the block with the same title; creates it
  if absent. Several blocks coexist (parallel sessions on the same repo).
- **Who consumes it:** `session-start` with a declared focus reads `## In progress` **before
  anything else**. A block whose title matches the focus **is** the briefing; the session deletes
  the block when it takes the task over (a one-line edit, no commit of its own).
- **Who cleans it:** `session-end` keeps only the blocks still in flight, asking about each one
  not touched that day. `--full` deletes blocks with no commit on their branch for 7 days, saying so.
- Without a declared focus, the briefing lists the block titles above `## Now` and proposes the first.

It is not the app's fork or hand-off, which carry the whole conversation. A block carries 15 lines.

## SESSION_LOG.md

Append-only, newest entry on top. What happened in each session.

```markdown
# Session log — <project>

## 2026-10-21 — <short title of the session>
- **Summary:** <one sentence: what the session changed in the project — this is what the start reads>
- **Done:** ... (with the evidence: test run, query checked, execution id)
- **Done, not exercised:** ... (delivered without proof that it runs; omit if none)
- **Decisions:** ... (only what is not obvious from the code; omit if none)
- **Pending:** ... (each one measured or assumed, with the date it appeared)
- **Pruned:** ... (only on --full, if any)

### checkpoint 14:30
- **Done:** ...
- **Pending:** ...
```

- `**Summary:**` is **required** and one sentence. The rest can be as long as the session deserves:
  it is only read when the day's focus asks for it.
- Between two ends, the day's entry may carry `### checkpoint HH:MM` sub-blocks. `session-end`
  rewrites the entry **absorbing** them: the sub-blocks disappear and their content becomes the
  normal bullets. No checkpoint survives a session end.
- Never edit entries from other days.

## Reading rules

What `session-start` reads, and nothing more:

- `SESSION_STATE.md` whole.
- From the two most recent LOG entries, the `**Summary:**` and `**Pending:**` bullets only.
  Entries written by 1.x carry `**Resumo:**` and `**Pendências:**`; read those as the same
  thing. An entry with no summary bullet: its first 10 lines.
- The rest of an entry only when the day's focus touches it.

## Monthly rotation

`SESSION_LOG.md` keeps **only the current month**. On the first `session-end` of a new month:

1. Append the previous month's entries, in their order, to `docs/sessions/YYYY-MM.md` (create the
   file with the title `# Session log — <project> — YYYY-MM` if absent). Append; never `git mv`.
2. Cut them from `SESSION_LOG.md`.
3. Same commit as the session end.

`session-start` does not change: when the LOG has fewer than two entries (new month), it completes
the reading with the last entries of the previous month's file. The entry format does not change.
