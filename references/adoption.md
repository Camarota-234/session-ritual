# Adoption

Three situations `session-start` meets, and what to do in each. Formats are in `files.md`.

## First session

No `SESSION_STATE.md` and no `SESSION_LOG.md`: show only the repository block and ask:

> "This project has no session record yet. Shall I create `SESSION_STATE.md` and
> `SESSION_LOG.md` to keep context between sessions?"

If yes, create both from the templates in `files.md`, with what the repo gives (README, last
commit): `## Current state` with one or two bullets, `## Now` empty or with what the user said
in the first message. **Never invent pending items.**

## Project that already logs sessions another way

A repo may have a `HISTORY.md`, a `CHANGELOG` of sessions, or a "Next session" section inside
`CLAUDE.md`. It is adoption, not a first session, and it has one right outcome:

**When you finish, exactly ONE live log exists.** Keeping the old log alongside `SESSION_LOG.md`
writes the same session twice, at different granularities, and nothing says which is right.

- **Old log → rename** (`git mv`, which keeps blame) and continue in the new format. Old entries
  stay as they are, with a one-line note at the top saying until when the format was different.
  This is the default.
- **Old entries long and still consulted:** give each a summary (`**Summary:**`, `**Done:**`,
  `**Pending:**`) at the top, **keeping the original text below**.
- **State scattered in `CLAUDE.md`** ("Current state", "Next session"): copy it into
  `SESSION_STATE.md`; in `CLAUDE.md` **delete nothing** (it belongs to the repo's owner) and leave a
  one-line pointer to the new file, with the maintainer's OK.

In every case, update references to the old name in the repo's end-of-session instructions
(`CLAUDE.md`), or the next session writes to the wrong file.

## Migrating a 1.x STATE

The script prints `**STATE in 1.x format**` when `SESSION_STATE.md` exists and has no
`## In progress` header. Offer the migration **before the briefing**, once per repo, in one line:
"STATE is in the 1.x format; migrate it to 2.0 now? (one commit)". With a yes:

| 1.x | 2.0 |
|---|---|
| `ultima-sessao:` | `last-session:` |
| `ultimo-fechamento-completo:` | `last-full-end:` |
| `**Escopo deste arquivo:**` | `**Scope:**` |
| `**Repos-irmãos:**` | `**Sibling repos:**` |
| `## Estado atual` | `## Current state` |
| `## A exercitar` (1.4.0) | `## To exercise` (`**prova:**` → `**proof:**`, `(desde DD/MM)` → `(since DD/MM)`; up to 6, the rest → `## Deferred`) |
| `## Próxima sessão` | `## Now` (same order, up to 7; the rest → `## Deferred` with reason "cut in the 2.0 migration") |
| `## Pendências` with `(aguardando …)` | `## Blocked` as `(waiting on <who>: <condition>)` |
| `## Pendências`, also listed in Próxima sessão | already in `## Now`; do not duplicate |
| `## Pendências`, the rest | `## Deferred` with `(deferred <today>: 2.0 migration)` and no return condition |
| `(desde DD/MM)` | removed in `## Now`/`## Blocked`; kept as the date in `## Deferred` |
| `(medida DD/MM)` / `(suposta)` | `(measured DD/MM)` / `(assumed)`, moved to the end of the line |
| sub-headings inside Pendências (`### Segurança` …) | dropped; the grouping word may stay as a prefix on the line |

Then: `## In progress` is born empty; check the quotas (`files.md`) and move what does not fit
to the day's LOG entry under a `**Migration 2.0:**` bullet; commit
`docs: SESSION_STATE.md in session-ritual 2.0 format`. The LOG is **not** rewritten: old entries
keep `Resumo`/`Pendências`, which the reading rules accept.

Before and after, on a short STATE:

```markdown
## Estado atual                          ## Current state
- Login no ar (exec 912)                 - Login live (exec 912)
## Pendências                            ## Now
- Pix quebrado (suposta, desde 03/10)    1. Confirm Pix is broken (assumed)
- Logo (aguardando cliente)              ## Blocked
## Próxima sessão                        - Logo (waiting on client: the file)
1. Confirmar o Pix                       ## Deferred
                                         (none)
```
