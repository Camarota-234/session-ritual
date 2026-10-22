# session-ritual

Start, checkpoint and end rituals for Claude Code. They keep a project's context between
sessions — yours, a colleague's, yours on another machine — in two files that live in the
repository itself.

| File | What it holds |
|---|---|
| `SESSION_STATE.md` | where the project is now: what is in progress, what works, what to do next (rewritten at each end) |
| `SESSION_LOG.md` | what happened in each session, newest first (append-only) |

## The three rituals

| Ritual | Unit | What it does | Git |
|---|---|---|---|
| `/session-ritual:session-start` | opening | pulls, reads the two files, briefs you — or, if your first message names a focus, reads the matching hand-off block and dives in | pull |
| `/session-ritual:session-checkpoint` | end of a **task** | writes a 15-line hand-off block to `## In progress` and a sub-block in today's LOG entry | commit, no push |
| `/session-ritual:session-end` | end of the **day** (`--full`: the week) | rewrites the STATE within its quotas, writes the LOG entry, runs your extension, commits and pushes; `--full` also prunes stale items | commit + push |

They also fire on natural language: "where were we", "close this one and let's do X", "we're
done for today", "close the week".

Pending items live in four sections by what to do with them: `## Now` (ordered, up to 7),
`## Blocked` (waiting on someone), `## Deferred` (skipped on purpose, with a reason), `## Debt`.
Every done item carries its evidence or says *delivered, not exercised* — and that goes to a
`## To exercise` section, each item with the proof that closes it, until someone sees it run.
Every pending item says whether it was *measured* or *assumed*. A date is context, never a nag.

## Install

Inside Claude Code:

```
/plugin marketplace add Camarota-234/session-ritual
/plugin install session-ritual@session-ritual
```

Nothing else. In a project with no session files yet, the start asks before creating them.
The ritual never writes to your `CLAUDE.md`.

## The hook

The plugin ships a `SessionStart` hook (`hooks/hooks.json` → `scripts/session-hook.sh`). On
`startup` and `compact`, inside a repo that has `SESSION_STATE.md`, it prints the repository
block (pull, branch, ahead/behind, commits since the last end, 1.x-format warning) into the
session context, so the start never depends on the model remembering to run a script. On
Windows it delegates to `session-start.ps1` under Git Bash; elsewhere it runs `session-start.sh`.
Both print the same output. To disable it, remove the `SessionStart` entry from your settings'
plugin hooks, or uninstall the plugin.

## How this differs from the app's fork and hand-off

The desktop app can fork a session or hand a task to a new one: that carries the whole
conversation. A checkpoint carries 15 lines: where you are in the plan, what is in flight, what
was decided but not yet coded, the literal next step. Use the app when the next session needs
the conversation; use the checkpoint when it needs the state.

## Branches and worktrees

The STATE belongs to the main branch. A feature branch or worktree writes only its own
`## In progress` block and the LOG; on merge, the main branch's STATE wins. Details in
`references/branches.md`.

## A repo that is not yours

For a repo shared with a team, keep the two files in a folder of your own and declare it in the
repo's untracked `CLAUDE.local.md`: ``**Session files:** `<folder>` ``. The script, the hook and the
three skills read and write there, commit only that folder's repo, and leave the project repo
alone. See `references/files.md`, "Where the files live".

## Personal extension

Steps that only make sense for you (sync a notes vault, update an index outside the repo,
commit a second repository) go in `~/.claude/ritual-extend.md`, with sections `## Start`,
`## End` and `## Full end`. The ritual runs each at the right point; without the file, nothing
changes. See `references/extension.md`.

## Upgrading from 1.x

The start script detects a 1.x `SESSION_STATE.md` and the start offers to migrate it, once per
repo, in one commit. Old LOG entries are not rewritten. Mapping in `references/adoption.md`.
Rename the sections of your extension file to `## Start`, `## End`, `## Full end`.

## Why this repo has SESSION_STATE.md and SESSION_LOG.md at its root

The plugin is developed with its own ritual. The two files are a live example of the format.

## Updating

Any change under `skills/`, `references/`, `scripts/` or `hooks/` needs a version bump in
`.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`: Claude Code caches the
plugin by version and keeps running the old one otherwise. To get a new version:

```
/plugin marketplace update session-ritual
/plugin uninstall session-ritual@session-ritual
/plugin install session-ritual@session-ritual
```

Tests: `bash tests/session-start.tests.sh`, `bash tests/session-hook.tests.sh`,
`bash tests/format-contract.tests.sh`, and
`powershell -NoProfile -ExecutionPolicy Bypass -File tests\session-start.tests.ps1`.

## Em português

Ritual de início, checkpoint e fim de sessão para o Claude Code, em dois arquivos no próprio
repositório: `SESSION_STATE.md` (onde o projeto está agora, reescrito a cada fim) e
`SESSION_LOG.md` (o que aconteceu em cada sessão, só acrescenta). O **checkpoint** fecha uma
tarefa e deixa um bloco de 15 linhas em `## In progress` para a próxima sessão começar quente,
sem push. O **fim** fecha o dia: reescreve o STATE dentro das cotas, escreve a entrada do LOG,
roda a sua extensão, commita e faz push; `--full` fecha a semana e poda o que envelheceu.
Pendências ficam em `## Now` (ordenada), `## Blocked`, `## Deferred` (pular exige motivo) e
`## Debt`. Os cabeçalhos dos arquivos são fixos em inglês; o conteúdo pode ser em qualquer
língua. Quem vem da 1.x: o início detecta o formato antigo e oferece a migração.
