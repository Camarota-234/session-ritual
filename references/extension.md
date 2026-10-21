# Personal extension

The ritual is the same in every project. Steps that only make sense for one person (syncing a
notes vault, updating an index outside the repo, committing a second repository) do not go
into the skills. They go into an optional, global file outside any project:

```
~/.claude/ritual-extend.md
```

with three sections, each a list of steps in natural language:

| Section | When it runs |
|---|---|
| `## Start` | in `session-start`, after reading the two files, before the briefing |
| `## End` | in `session-end`, after writing the two files, before the commit |
| `## Full end` | in `session-end --full`, at the same point — **instead of** `## End`, not in addition |

If the file does not exist, nothing happens and nothing is mentioned. A missing section is
skipped silently. `session-checkpoint` never runs the extension.

It is for **extra** steps, not for reconfiguring the base: the file names, the order of the
steps, the quotas, the section headers and the confirmation before writing do not change
through the extension.

## What the extension must not do

- Write to the repo's `CLAUDE.md` (it belongs to the repo's owner).
- Push, deploy, run test suites or anything slow in `## Start`: the start must stay cheap.
- Redefine where `SESSION_STATE.md` and `SESSION_LOG.md` live.

## Example

```markdown
## Start
- `git -C ~/notes pull --ff-only`; if it fails, note in the briefing that the notes may be stale.

## End
- If the session made an architecture decision, append it to `~/notes/<project>/decisions.md`.
- Commit and push `~/notes` if anything changed; report it next to the project push.

## Full end
- Everything in End, plus: update the project's status line in `~/notes/index.md`.
```

Section names are English only. The 1.x names (`## Início`, `## Fim leve`, `## Fim completo`,
`## Fim`) are not recognized: rename them once.
