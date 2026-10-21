---
name: session-checkpoint
description: "End of a task, not of the day: writes a hand-off block to '## In progress' in SESSION_STATE.md and a checkpoint sub-block in today's SESSION_LOG.md entry, then commits without pushing. Use when the user closes a task to start another (\"close this one and let's do X\", \"pause here\", \"mark the point\", \"/session-checkpoint\"). Runs without asking when the next focus is in the same sentence. Not for ending the day (that is session-end)."
---

# session-checkpoint

The cheap end: of a task, not of the day. It leaves the next session a 15-line hand-off instead
of a cold start. Formats: `../../references/files.md` ("In progress blocks", "SESSION_LOG.md").

## 1. Confirm, or not

- The next focus is in the same sentence ("close this one and let's do X") → run, no question.
- Otherwise, one line: `Checkpoint — closing the task "<focus>": In progress block, LOG
  sub-block, commit without push. OK?`
- Unsure whether the user means the task or the day → `End of the task or of the day?` and stop.

## 2. Synthesize

Since the last checkpoint (or the start), 2 to 5 bullets: done (with evidence, or "not exercised"), decisions, new pending items. Verified apart from merely written.

## 3. The In-progress block

In `SESSION_STATE.md`, section `## In progress`, one `###` block for this task:

```markdown
### <task title> — branch `<branch>` (since DD/MM)
- Plan: <file>, task N of M.            (pointer: plan, spec, LOG entry — never a copy)
- In flight: <file>, <failing test>, <command that reproduces>.
- Decided in conversation, not yet in code: <...>.
- Next step: <the literal first action of the next session>.
```

**Up to 15 lines.** It **replaces** the block with the same title; creates it if absent; leaves
other blocks alone (parallel sessions). Nothing else in the STATE is touched, except pending
lines already deleted during the session. On a feature branch, same (`../../references/branches.md`).

## 4. The LOG sub-block

In today's entry of `SESSION_LOG.md`, at its end:

```markdown
### checkpoint HH:MM
- **Done:** ...
- **Pending:** ...
```

No entry today yet: create `## YYYY-MM-DD — <provisional title>` with only this sub-block; `session-end` absorbs it later.

## 5. Commit

`git add` the session's files and the two docs; commit `docs: checkpoint HH:MM — <summary>`.
**No push, no extension, nothing slow.** One line back: what was written, and that the next
session with this focus opens on the block.
