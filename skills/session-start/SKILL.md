---
name: session-start
description: "Start-of-session briefing from SESSION_STATE.md and SESSION_LOG.md: pulls, reads the persisted state and the in-progress hand-off, then either proposes the next item or dives into the declared focus. Use when the user opens a session wanting to know where things stand (\"where were we\", \"what's on today\", \"let's start\", \"/session-start\"), or names a focus in the first message of a project that has a SESSION_STATE.md. Not for mid-session questions."
---

# session-start

Run the steps in order, without asking. Two modes, decided by the first message: **declared
focus** ("today is the Pix", "let's do the login bug") and **no focus** ("what's on", "where
were we"). Steps 1 to 4 are the same; only the briefing changes. Formats: `../../references/files.md`.

## 1. Mechanical part

If the context already has a block starting with `# Session start by hook`, use it and go to
step 2: running the script again only repeats the pull. Otherwise run it for the current repo
(`../../scripts/session-start.ps1 -Repo <repo>` on Windows, `../../scripts/session-start.sh --repo <repo>`
elsewhere) and paste its output as the "Repository" section. Do not rewrite it. Then act on
its lines:

- `**STATE in 1.x format**` → open `../../references/adoption.md`, section "Migrating a 1.x
  STATE", and offer the migration **before** the briefing. With a yes, migrate and commit;
  then continue with the migrated file.
- `Feature branch:` → read `../../references/branches.md`; the briefing repeats the line.
- `**Commits after the last /session-end**` → the STATE may be stale; say so, and treat `## Now`
  as possibly outdated.
- `**Pull failed**` → enters the briefing as is; do not retry.
- `Session files:` → STATE and LOG live in that folder (`files.md`): read them there, create nothing in the repo.

No STATE and no LOG, or a repo that logs another way: `adoption.md`. Never run the test suite here.

## 2. Read

`SESSION_STATE.md` whole, for the current repo and each sibling (`../../references/multi-repo.md`).
From `SESSION_LOG.md`, only the `**Summary:**` and `**Pending:**` bullets of the two most recent
entries (1.x labels, entries with no summary, a short LOG in a new month: `files.md`, "Reading
rules"). The rest of an entry only when the focus touches it.

## 3. In progress first

With a declared focus, look at `## In progress`: a `###` block whose title matches **is the
briefing, and nothing else**. Delete it from the STATE as you take the task over (a one-line
edit, no commit of its own) and start working. No match: step 4. Without a focus, the block
titles go to the top of the briefing (step 5).

## 4. Extension

If `~/.claude/ritual-extend.md` exists, run its `## Start` (`../../references/extension.md`);
no file or section: nothing happens, nothing is said.

## 5. Briefing

**No focus** — present and stop:

```
## Briefing — <date>
### Repository
<script output, one sub-block per repo>
### In progress
<block titles, or "none">
### Now
<the `## Now` list, whole, in order>
### Blocked that changed
<blocked items whose condition looks met, or "none">
### To exercise (N)
<each `## To exercise` item with its proof, one line; omit if empty>
```

Close by proposing, not asking open-ended: the first In-progress block, or else item 1 of
`## Now`, and the question is just "start there?". Wait for the answer before any work.

**Declared focus** — no stop. The briefing shrinks to what touches the focus:

```
## Briefing — <date> — focus: <what the user asked>
- <script lines that matter: pull failed, commits after the last end, ahead/behind, modified files. Clean and up to date = one line>
- <what in the STATE and the LOG touches the focus: the `## Now` item, a recent decision, evidence>
- <if the focus is not in `## Now`: "not planned; goes ahead of <item 1>" — one sentence, no justification asked>
- <a `## To exercise` item the focus can prove in passing, with its proof>
```

Then go straight to the work; what does not touch the focus does not enter the briefing.

In both modes: an `(assumed)` item enters as a hypothesis, never a fact (if it defines the day's
work, confirming it is step one). `## Deferred` never enters. A date is context, never a nag.
