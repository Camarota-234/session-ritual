# Changelog

## 2.0.1 — 2026-10-22

- **Files kept outside the repo:** a `**Session files:** `<folder>`` line in `CLAUDE.local.md` (or
  `CLAUDE.md`) moves the STATE and the LOG there, for repos shared with a team. Script, hook and
  skills follow it; `session-end` and `session-checkpoint` commit only that folder's repo and never
  touch the project repo. `session-end` also migrates a 1.x STATE it meets, through `adoption.md`.
- **Fixes found by the new tests:** `session-start.sh` did not recognize a worktree (`.git` is a file
  there); `session-start.ps1` printed PowerShell error noise on a failed pull and a leading space on the
  `Pull:` line.
- Version bump so `/plugin update` picks the change up (the cache is keyed by version).

## 2.0.0 — 2026-10-21

Breaking: the `SESSION_STATE.md` format changed. `session-start` detects a 1.x file and offers
the migration (`references/adoption.md`).

- **Three skills, one per command:** `/session-ritual:session-start`, `/session-ritual:session-checkpoint`,
  `/session-ritual:session-end` (`--full` for the weekly close). In 1.x those were phrases in one
  skill's description, never commands.
- **Checkpoint is the end of a task, with a hand-off:** it writes a block to the new
  `## In progress` section of the STATE (plan position, what is in flight, the literal next step,
  up to 15 lines) and commits without pushing. The next start with that focus reads the block
  and nothing else.
- **`## To exercise` (from 1.4.0, as `## A exercitar`):** what was delivered and never ran gets
  its own STATE section, each item with the proof that closes it (an observation, not a task).
  `session-end` fills it from the LOG's *Done, not exercised*; the line leaves when the proof
  happens; the briefing lists it (all of it without a focus, only what the focus can prove with one).
  Quota: 6 items. A 1.4.0 STATE migrates with the rest (`references/adoption.md`).
- **Pending items by what to do with them:** `## Now` (ordered, up to 7), `## Blocked`,
  `## Deferred` (skipping requires a reason), `## Debt`. `## Next session` is gone (it is `## Now`).
  `(measured)` / `(assumed)` stays, at the end of the line.
- **Quotas per section** replace the 120-line cap: 80 lines in all. **Monthly rotation** of the LOG
  into `docs/sessions/YYYY-MM.md`.
- **Pruning on `--full`:** deferred and blocked items older than 4 weeks, debt, stale in-progress blocks.
- **Branches and worktrees:** the STATE belongs to the main branch; a feature branch writes only
  its in-progress block and the LOG (`references/branches.md`).
- **Hook and scripts shipped by the plugin:** `hooks/hooks.json` runs `scripts/session-hook.sh` on
  `startup` and `compact`; `session-start.ps1` and `session-start.sh` print the same output and are
  tested (`tests/`).
- **English** throughout; section headers of the two files are fixed in English.
- Personal extension sections renamed: `## Start`, `## End`, `## Full end`.

## 1.3.1 — 2026-10-15

- The start uses the output of a `SessionStart` hook when it is already in context, instead of
  running the script again.

## 1.3.0 — 2026-09-28

- Start with a declared focus has no stop; without a focus, the briefing proposes item 1.
- The script lists commits made after the last `/session-end` (STATE possibly stale).
- A closed item leaves the STATE at once. `Resumo` bullet required in every LOG entry; the start
  reads only `Resumo` and `Pendências` of the last two entries.
- Dates on pending items are context, not nags: `(desde DD/MM)`, `(aguardando <quem>)`.

## 1.2.0 — 2026-09-08

- Light end by default; full end on request or every 7 days. `/session-checkpoint`.
- `scripts/session-start.ps1`: pull, status with ahead/behind, last commits, sibling repos.
- STATE diet: 120-line cap, permanent rules go to `CLAUDE.md`, closed items disappear.
- Extension file with `## Início`, `## Fim leve`, `## Fim completo`. Graphify out of the ritual.

## 1.1.0 — 2026-08-24

- Adopting a repo that already logs sessions another way; one live log at the end.
- Projects in more than one repo: `**Repos-irmãos:**` line, one owner per pending item.
- `ultima-sessao` in the frontmatter; pending items marked measured or assumed; `Feito` carries
  evidence and `Feito, não exercitado` what has none.

## 1.0.0 — 2026-08-16

- First release: start and end rituals over `SESSION_STATE.md` and `SESSION_LOG.md`, extension
  point in `~/.claude/ritual-extend.md`.
