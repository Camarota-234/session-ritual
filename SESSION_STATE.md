---
last-session: 2026-10-22
last-full-end: 2026-10-21
---

# Session state — session-ritual

**Scope:** the public `session-ritual` plugin (three skills, references, scripts, hook, manifests).
The author's personal extension lives in `Camarota-234/claude-config` (`ritual-extend.md`) and is not part of this repo.

## In progress

### 2.0 rollout — exercise it, on `main` (since 21/10)
- Spec: `docs/superpowers/specs/2026-10-21-session-ritual-2.0-design.md`; plan: `docs/superpowers/plans/2026-10-21-session-ritual-2.0.md`, tasks 1–12 done (this file migrated by hand; `claude-config` pushed 22/10).
- Live on this PC since 22/10: `v2.0` fast-forwarded into `main` and pushed, marketplaces updated, plugin 2.0.0 installed (needs a restart to load), `sync-global.ps1` run. Not tagged: `skill-creator` first.
- Next step: in a fresh session in this repo run `/session-ritual:session-start` (no 1.x warning expected), `/session-ritual:session-checkpoint` on a dummy task, open a fresh session with that focus, then `/session-ritual:session-end --full`; log every mismatch with the spec as the first 2.0 bugs.

## Current state
- **2.0.0 on `main`** (22/10, `56805e6`; built 21/10 from `d2c362d`): three skills (`session-start`, `session-checkpoint`, `session-end`), `references/` (files, adoption, multi-repo, branches, extension), `scripts/session-start.ps1` and `.sh` with identical output, `hooks/hooks.json` → `scripts/session-hook.sh`, README in English, CHANGELOG, MIT. `claude plugin validate .` passes clean.
- Tests green on 21/10: `tests/session-start.tests.ps1` (30 checks), `tests/session-start.tests.sh` (parity with the ps1 included), `tests/session-hook.tests.sh`.
- `origin/main` 1.4.0 (`1d3db50`) merged into `v2.0` on 22/10, manifests stay 2.0.0. Its `## A exercitar` is ported as `## To exercise` (`references/files.md`, the three skills, `tests/format-contract.tests.sh`; green 22/10).
- Two gaps found on 22/10 in the open Avex sessions (four repos still on a 1.x STATE, one keeping its files in the vault) closed in the same day: `session-end` migrates a 1.x STATE through `adoption.md`; a `**Session files:** `<folder>`` line in `CLAUDE.local.md`/`CLAUDE.md` moves the STATE and LOG (script `.ps1`/`.sh`, hook, three skills, `files.md` "Where the files live"; tests green).
- Installed on this PC: 2.0.1 (22/10, bumped because the plugin cache is keyed by version). Notebook: 1.3.0.

## To exercise
- The three 2.0 skills in a real session — **proof:** `/session-ritual:session-start`, `-checkpoint` and `-end` run after reinstall with no 1.x warning (since 21/10)
- The hook under Claude Code — **proof:** a fresh session in a repo with a STATE opens with the `# Session start by hook` block (since 21/10)
- The 1.x → 2.0 migration done by the skill — **proof:** a 1.x STATE in another repo gets the migration offer and a one-commit result (since 21/10)
- `session-end` on a 1.x STATE — **proof:** in a repo still on 1.x, `/session-ritual:session-end` migrates it and the day's commit carries the 2.0 file (since 22/10)
- `**Session files:**` in `avex-connect-hub` — **proof:** `/session-ritual:session-start` there prints `- Session files:` with the vault folder and creates no `SESSION_*.md` in the repo; `session-end` commits only the vault (since 22/10)
- `## To exercise` itself — **proof:** a `session-end` turns a *Done, not exercised* into a line here, and a no-focus briefing prints `### To exercise (N)` (since 22/10)

## Now
1. Restart, then exercise the three commands here, per the block above. [1h] (measured 22/10)
2. Update the notebook (marketplace, plugin, `sync-global.ps1`) and migrate its repos' STATEs. [1h] (measured 22/10)
3. `skill-creator` evals and `/skill-doctor` before tagging 2.0.0. [2h] (measured 08/09: never run)
4. Run `session-start` once without `ritual-extend.md`, to prove nothing from the vault leaks into the base. (measured 08/09: never run)
5. `/code-review` on the 22/10 diff (`56805e6..03fb840`), not run. [30min] (measured 22/10)

## Blocked
- (none)

## Deferred
- (none)

## Debt
- (none)
