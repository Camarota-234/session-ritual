# Project in more than one repo

A product may live in two or three repositories (frontend and automation, app and infra). Each
one has its own pair of files: state lives next to the code it describes, and whoever clones
only one of them still gets an honest briefing.

What ties them together is one line at the top of each `SESSION_STATE.md`:

```markdown
**Scope:** <what this repo covers>.
**Sibling repos:** `<path>` — <what that one covers>.
```

The path goes between backticks: that is how the start script finds it and includes the
sibling in the "Repository" block. More than one sibling, more than one backtick pair on the
same line. A path in Windows form (`C:\dev\x`) is fine; the scripts convert it.

Two rules that prevent divergence:

- **Every pending item has one owner repo: the one that can close it.** A runtime item does not
  live in the panel's STATE, even if it was discovered there. Point across with one line if
  needed ("see the runtime's `## Now` item 2").
- **Never repeat the same item in both "so we don't forget".** Two copies age at different
  speeds, and the stale one is the one someone reads.

At the end of a session, rewrite the STATE of **each** repo the session touched. At the start,
read all of them: the script already brings the git state of all.
