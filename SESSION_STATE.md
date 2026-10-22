---
last-session: 2026-10-21
last-full-end: 2026-10-21
---

# Session state — session-ritual

**Scope:** the public `session-ritual` plugin (three skills, references, scripts, hook, manifests).
The author's personal extension lives in `Camarota-234/claude-config` (`ritual-extend.md`) and is not part of this repo.

## In progress

### 2.0 rollout — branch `v2.0` (since 21/10)
- Spec: `docs/superpowers/specs/2026-10-21-session-ritual-2.0-design.md`; plan: `docs/superpowers/plans/2026-10-21-session-ritual-2.0.md`, tasks 1–10 done, 11 partly (this file migrated by hand), 12 done in `claude-config` (committed there, not pushed).
- In flight: the plan's final whole-branch review and fix pass; then merge `v2.0` into `main` and push.
- Decided, not yet live: the installed plugin is still 1.3.1; nothing on this branch reaches a session until merge, `/plugin marketplace update session-ritual` and reinstall.
- Next step: after reinstall, in this repo run `/session-ritual:session-start` (no 1.x warning expected), `/session-ritual:session-checkpoint` on a dummy task, open a fresh session with that focus, then `/session-ritual:session-end --full`; log every mismatch with the spec as the first 2.0 bugs. Then push `claude-config`, `/plugin marketplace update joao-config`, `sync-global.ps1`.

## Current state
- **2.0.0 on branch `v2.0`** (21/10, `d2c362d`..): three skills (`session-start`, `session-checkpoint`, `session-end`), `references/` (files, adoption, multi-repo, branches, extension), `scripts/session-start.ps1` and `.sh` with identical output, `hooks/hooks.json` → `scripts/session-hook.sh`, README in English, CHANGELOG, MIT. `claude plugin validate .` passes clean.
- Tests green on 21/10: `tests/session-start.tests.ps1` (30 checks), `tests/session-start.tests.sh` (parity with the ps1 included), `tests/session-hook.tests.sh`.
- `origin/main` 1.4.0 (`1d3db50`) merged into `v2.0` on 22/10, manifests stay 2.0.0. Its `## A exercitar` is ported as `## To exercise` (`references/files.md`, the three skills, `tests/format-contract.tests.sh`; green 22/10).
- Installed on this PC: 1.3.1. Notebook: 1.3.0.

## To exercise
- The three 2.0 skills in a real session — **proof:** `/session-ritual:session-start`, `-checkpoint` and `-end` run after reinstall with no 1.x warning (since 21/10)
- The hook under Claude Code — **proof:** a fresh session in a repo with a STATE opens with the `# Session start by hook` block (since 21/10)
- The 1.x → 2.0 migration done by the skill — **proof:** a 1.x STATE in another repo gets the migration offer and a one-commit result (since 21/10)
- `## To exercise` itself — **proof:** a `session-end` turns a *Done, not exercised* into a line here, and a no-focus briefing prints `### To exercise (N)` (since 22/10)

## Now
1. Final review of `v2.0`, fix pass, merge into `main`, push. [1h] (measured 21/10)
2. Reinstall and exercise the three commands here, per the block above. [1h] (measured 21/10)
3. `skill-creator` evals and `/skill-doctor` before tagging 2.0.0. [2h] (measured 08/09: never run)
4. Run `session-start` once without `ritual-extend.md`, to prove nothing from the vault leaks into the base. (measured 08/09: never run)
## Blocked
- (none)

## Deferred
- Notebook still on 1.3.0 (deferred 15/10: wait for 2.0 on `main`; back when 2.0.0 is tagged)

## Debt
- (none)
