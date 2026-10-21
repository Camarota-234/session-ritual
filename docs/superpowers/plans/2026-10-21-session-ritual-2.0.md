# session-ritual 2.0 — plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Entregar o plugin `session-ritual` 2.0.0: três skills (start, checkpoint, end), hook e scripts
embarcados em PowerShell e bash com saída idêntica, STATE com `## In progress` e quatro seções de
pendências, tudo em inglês e testado, pronto para o GitHub público.

**Architecture:** O plugin vira três skills curtas que citam uma pasta `references/` compartilhada. A
parte mecânica (pull, status, detecção de formato 1.x, branch) mora em dois scripts com um contrato de
saída único, chamados por um hook `SessionStart` do próprio plugin. O formato dos arquivos muda uma vez
(2.0) e o início oferece migrar.

**Tech Stack:** Markdown (skills), PowerShell 5.1+ e bash (scripts e testes, sem framework, no estilo
dos testes do `claude-config`), git, `claude plugin validate`.

**Spec:** `docs/superpowers/specs/2026-10-21-session-ritual-2.0-design.md`

## Global Constraints

- Idioma de skills, references, scripts, README e mensagens dos scripts: **inglês**. Plano e spec em PT-BR.
- Cabeçalhos fixos do STATE 2.0: `## In progress`, `## Current state`, `## Now`, `## Blocked`, `## Deferred`, `## Debt`. Frontmatter: `last-session`, `last-full-end`. Linhas de topo: `**Scope:**`, `**Sibling repos:**`.
- Cotas do STATE: cabeçalho 10 linhas; `## In progress` 15 linhas por bloco `###`; `## Current state` 12 bullets de até 2 linhas; `## Now` 7 itens; demais 1 linha por item; **total 80 linhas**.
- LOG: entrada `## YYYY-MM-DD — <title>`; bullets `**Summary:**` (obrigatório, 1 frase), `**Done:**`, `**Done, not exercised:**`, `**Decisions:**`, `**Pending:**`, `**Pruned:**`; sub-bloco `### checkpoint HH:MM`. Rotação mensal para `docs/sessions/YYYY-MM.md`. Entradas antigas com `Resumo`/`Pendências` continuam válidas: o início aceita os dois rótulos.
- Comandos: `/session-ritual:session-start`, `/session-ritual:session-checkpoint`, `/session-ritual:session-end` (`--full` para o completo; a spec escreveu `--completo`, vale `--full`).
- Extensão pessoal `~/.claude/ritual-extend.md`, seções 2.0: `## Start`, `## End`, `## Full end`. Sem compatibilidade com os nomes 1.x.
- Scripts: exit 0 sempre; nunca rodam testes nem sobem nada; pull só com `--ff-only`.
- Caminho da pasta compartilhada a partir de uma skill: `../../references/<file>.md` (relativo ao diretório da skill).
- Testes sem framework: `tests/*.tests.ps1` e `tests/*.tests.sh`, helper `expect`, saída `ok`/`FAIL`, exit 1 se houver falha. Não exigem rede (sempre `-NoPull`/`--no-pull`, fixtures sem remote ou com remote local em pasta).

## Review Focus

1. **STATE salvo com CRLF ou BOM (Windows).** A detecção de formato 1.x e a leitura de `last-session` e `Sibling repos` precisam funcionar com `\r` no fim da linha. Teste em T1 e T2.
2. **Branch principal que não se chama `main`** (`master`, `develop`) e HEAD destacado. A linha `Feature branch:` não pode aparecer na principal nem quebrar sem `origin/HEAD`. Teste em T1 e T2.
3. **STATE 1.x com `ultima-sessao` em vez de `last-session`.** A linha "Commits after the last `/session-end`" tem de funcionar antes da migração. Teste em T1 e T2.
4. **Hook com stdin vazio ou não-JSON** (chamado à mão) e `source` fora de `startup|compact`: sai 0, calado. Teste em T3.
5. **Caminho de repo-irmão no formato Windows (`C:\dev\x`) lido pelo `.sh`** no Git Bash: converter com `cygpath` quando existir. Teste em T2.

---

### Task 1: `session-start.ps1` no contrato 2.0, com testes

**Files:**
- Modify: `scripts/session-start.ps1`
- Create: `tests/session-start.tests.ps1`

**Interfaces:**
- Consumes: nada.
- Produces: o **contrato de saída** abaixo, que o `.sh` (T2), o hook (T3) e a skill de início (T6) usam. Parâmetros: `-Repo <path>` (default: cwd), `-NoPull`.

Contrato de saída (uma linha por item, nesta ordem; itens entre colchetes só quando a condição vale):

```
## Repository — YYYY-MM-DD HH:mm — host `NAME`

### <nome da pasta do repo>
- Path: `<abs>`
[- Not a git repository.]                      ← e para aqui
- Pull: <última linha do git pull> | **Pull failed** — <stderr numa linha> | Not run (--no-pull). | No remote.
- Branch: <nome> [— **N commit(s) ahead of remote**] [— **N commit(s) behind remote**]
[- Feature branch: STATE is owned by `<principal>`; this branch writes only its `## In progress` block and the LOG.]
- Last commit: <git log --oneline -1>
[- **STATE in 1.x format** — migrate before the briefing: see references/adoption.md.]
[- **Commits after the last `/session-end` (YYYY-MM-DD): N** — STATE may be stale:
  - <oneline> (até 5)]
- Modified files (N): / - Modified files: clean
  [- `<linha do status -s>` (até 15, depois "  - …")]
- Recent commits:
  - <oneline> (até 5)

(repete `### …` para cada repo-irmão)
```

Regras de detecção:
- Principal: `git symbolic-ref -q --short refs/remotes/origin/HEAD` sem o prefixo `origin/`; sem isso, `main` se existir, senão `master`. HEAD destacado: `Branch: (detached)`, sem linha `Feature branch:`.
- Formato 1.x: `SESSION_STATE.md` existe **e** nenhuma linha casa `^## In progress\r?$`.
- Data do último fechamento: primeira linha do frontmatter que casa `^(last-session|ultima-sessao):\s*(\d{4}-\d{2}-\d{2})`.
- Irmãos: primeira linha que casa `^\*\*(Sibling repos|Repos-irm)` ; caminhos entre crases; só os que têm `.git`.
- Ler arquivos com encoding UTF-8 e aceitar `\r` no fim de toda regex de linha.

- [ ] **Step 1: Escrever os testes que falham** em `tests/session-start.tests.ps1`, no estilo do `claude-config` (helper `Espera`→`Expect`, fixtures em `$env:TEMP`, sempre `-NoPull`). Cenários e asserções:
  - `clean repo`: saída casa `^## Repository — \d{4}-\d{2}-\d{2} \d{2}:\d{2} — host`, contém `- Branch: main`, `- Modified files: clean`, `- Pull: Not run (--no-pull).`, não contém `Feature branch`.
  - `ahead of remote`: remote local (`git clone --bare` em pasta, `git remote add origin`), um commit a mais → contém `**1 commit(s) ahead of remote**`.
  - `no remote`: contém `- No remote.`
  - `not a git folder`: contém `- Not a git repository.` e nada de `- Branch:`.
  - `STATE 1.x`: STATE com `## Próxima sessão` e sem `## In progress` → contém `**STATE in 1.x format**`.
  - `STATE 2.0`: STATE com `## In progress` → não contém `1.x format`.
  - `commits after last end (ultima-sessao)`: STATE 1.x com `ultima-sessao: 2000-01-01` e um commit → contém `Commits after the last` e `(2000-01-01): 1`.
  - `commits after last end (last-session)`: idem com `last-session`.
  - `CRLF state`: STATE 2.0 gravado com `\r\n` → não contém `1.x format` e lê `last-session`.
  - `feature branch`: `git checkout -b feat/x` → contém `Feature branch: STATE is owned by` + `main`.
  - `master as main`: repo cujo único branch é `master` → `- Branch: master`, sem `Feature branch`.
  - `detached HEAD`: `git checkout --detach` → `- Branch: (detached)`, sem `Feature branch`.
  - `sibling repos`: STATE com `**Sibling repos:** \`<irmão>\`` e também um com `**Repos-irmãos:**` → dois blocos `### `.
  - `missing repo path`: `-Repo` inexistente → contém `path does not exist`, exit 0.
- [ ] **Step 2: Rodar e ver falhar**: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\session-start.tests.ps1` → linhas `FAIL` (texto em PT-BR ainda).
- [ ] **Step 3: Reescrever `scripts/session-start.ps1`** com o contrato acima: parâmetros `[string]$Repo`, `[switch]$NoPull`; funções `Get-MainBranch($root)`, `Get-Siblings($root)`, `Get-LastSessionDate($root)`, `Test-LegacyState($root)`, `Report($root, $pull)`. Comentário de cabeçalho em inglês. Manter exit 0 e UTF-8.
- [ ] **Step 4: Rodar e ver passar**: mesmo comando → `all green`.
- [ ] **Step 5: Commit**: `git add scripts/session-start.ps1 tests/session-start.tests.ps1 && git commit -m "feat(scripts): session-start.ps1 on the 2.0 output contract, with tests"`

### Task 2: `session-start.sh` com a mesma saída, e teste de paridade

**Files:**
- Create: `scripts/session-start.sh`
- Create: `tests/session-start.tests.sh`
- Create: `tests/lib.sh` (helpers `expect`, `make_repo`, `make_state`, cleanup)

**Interfaces:**
- Consumes: contrato de T1.
- Produces: `scripts/session-start.sh [--repo <path>] [--no-pull]`, mesma saída linha a linha, exceto a linha 1 (hora e host). Função `to_posix_path` (usa `cygpath -u` se existir, senão devolve o argumento).

- [ ] **Step 1: Escrever `tests/lib.sh`** com `expect <cond-exit> <msg>` (imprime `ok`/`FAIL`, conta falhas), `make_repo <dir>` (init + commit vazio), `make_state <dir> <conteúdo>`, `finish` (remove fixtures, exit 1 se falhas).
- [ ] **Step 2: Escrever os testes que falham** em `tests/session-start.tests.sh`: os mesmos cenários de T1 (mesmos nomes), mais:
  - `windows sibling path`: STATE com `` **Sibling repos:** `C:\tmp\...` `` (convertido do fixture com `cygpath -w` quando disponível; senão o teste é pulado com `skip`) → dois blocos `### `.
  - `parity with ps1`: se `powershell` ou `pwsh` existe, roda os dois no fixture `sibling repos` e `diff <(tail -n +2 ps1) <(tail -n +2 sh)` vazio; senão `skip`.
- [ ] **Step 3: Rodar e ver falhar**: `bash tests/session-start.tests.sh` → `FAIL` por script ausente.
- [ ] **Step 4: Implementar `scripts/session-start.sh`** (`#!/usr/bin/env bash`, `set -u`, nunca `set -e`): mesmas funções de T1 em bash; `git -C`; regex via `grep -E`; `sed 's/\r$//'` ao ler o STATE.
- [ ] **Step 5: Rodar e ver passar**: `bash tests/session-start.tests.sh` → `all green` (com `parity with ps1` `ok` nesta máquina).
- [ ] **Step 6: Commit**: `git add scripts/session-start.sh tests/lib.sh tests/session-start.tests.sh && git commit -m "feat(scripts): session-start.sh with the same output as the ps1, parity test"`

### Task 3: hook `SessionStart` do plugin

**Files:**
- Create: `hooks/hooks.json`
- Create: `scripts/session-hook.sh`
- Create: `tests/session-hook.tests.sh`

**Interfaces:**
- Consumes: T1 e T2 (`--no-pull`/`-NoPull`).
- Produces: bloco no contexto da sessão com a primeira linha `# Session start by hook (<source>) — <repo>`, que a skill de início (T6) reconhece.

Comportamento do `session-hook.sh`:
- Lê stdin; extrai `source` e `cwd` com `sed -n 's/.*"source" *: *"\([^"]*\)".*/\1/p'` (idem `cwd`). Sem stdin ou sem campo: `source=startup`, `cwd=$PWD`.
- `source` fora de `startup|compact` → exit 0 calado.
- `root=$(git -C "$cwd" rev-parse --show-toplevel)`; falha ou sem `$root/SESSION_STATE.md` → exit 0 calado.
- Imprime: linha 1 acima; em `startup`, a linha `Step 1 of /session-start (script) already ran here. Still to do: read SESSION_STATE.md and the top of SESSION_LOG.md and build the briefing.`; em `compact`, `The conversation was compacted: this reloads the mechanical state. Re-read SESSION_STATE.md before continuing.`; linha vazia.
- Escolhe o script: `pwsh` ou `powershell` no PATH → `.ps1` com `-NoProfile -ExecutionPolicy Bypass -File`; senão `.sh`. `compact` adiciona `-NoPull`/`--no-pull`.
- Exit 0 sempre.

`hooks/hooks.json`:
```json
{ "hooks": { "SessionStart": [ { "matcher": "startup|compact",
  "hooks": [ { "type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/scripts/session-hook.sh\"", "timeout": 60 } ] } ] } }
```

- [ ] **Step 1: Escrever os testes que falham** em `tests/session-hook.tests.sh` (usa `tests/lib.sh`), passando o JSON por stdin e `SESSION_RITUAL_SCRIPT_DIR` apontando para `scripts/`:
  - `startup in repo with STATE`: saída começa com `# Session start by hook (startup)` e contém `## Repository —`.
  - `compact adds no-pull`: contém `(compact)`, `Re-read SESSION_STATE.md`, `Not run (--no-pull).`
  - `resume is silent`, `fork is silent`, `clear is silent`: saída vazia, exit 0.
  - `repo without STATE is silent`, `folder without git is silent`.
  - `subfolder resolves to root`: `cwd` em `sub/` → linha 1 termina com a raiz.
  - `empty stdin defaults to startup and PWD`: rodar de dentro do fixture com `< /dev/null` → cabeçalho `(startup)`.
  - `garbage stdin exits 0`: `echo lixo |` → exit 0.
- [ ] **Step 2: Rodar e ver falhar**: `bash tests/session-hook.tests.sh`.
- [ ] **Step 3: Implementar `scripts/session-hook.sh`** e criar `hooks/hooks.json`.
- [ ] **Step 4: Rodar e ver passar**: `bash tests/session-hook.tests.sh` → `all green`.
- [ ] **Step 5: Validar o manifesto com o hook**: `claude plugin validate .` → sem erro.
- [ ] **Step 6: Commit**: `git add hooks/hooks.json scripts/session-hook.sh tests/session-hook.tests.sh && git commit -m "feat(hook): SessionStart hook shipped by the plugin"`

### Task 4: `references/files.md` — templates, cotas e rotação

**Files:**
- Create: `references/files.md`

**Interfaces:**
- Produces: a fonte única do formato, citada por T5 a T8. Headings: `# Files`, `## SESSION_STATE.md` (template completo com os seis cabeçalhos e o frontmatter), `## Quotas` (tabela §6.1 da spec), `## Diet rules` (as da 1.3, traduzidas, sem o teto 120), `## Pending items` (as quatro seções, a linha `- <what is left, with the pointer> [2h] (measured DD/MM)`, os movimentos close/defer/unblock/arise da §5.3), `## In progress blocks` (regras §4: pointer not copy, 15 lines, one `###` per task, who writes/consumes/cleans), `## SESSION_LOG.md` (template de entrada e do sub-bloco checkpoint; `Summary` obrigatório; rótulos legados `Resumo`/`Pendências` aceitos na leitura), `## Monthly rotation` (§6.2: no primeiro fim de um mês novo, entradas do mês anterior vão para `docs/sessions/YYYY-MM.md` em append, no mesmo commit; o início completa com o arquivo anterior quando o LOG tem menos de duas entradas).

- [ ] **Step 1: Escrever `references/files.md`** com as seções acima, valores da spec copiados tal qual (cotas, rótulos, formato de linha). Template do STATE com um bloco de exemplo em `## In progress` (o do §4 da spec, traduzido) e um item por seção de pendências.
- [ ] **Step 2: Verificar**: `grep -c '^## ' references/files.md` = 8; `grep -n 'In progress\|Current state\|^## Now\|Blocked\|Deferred\|Debt' references/files.md` mostra os seis cabeçalhos no template; nenhuma ocorrência de `120`.
- [ ] **Step 3: Commit**: `git add references/files.md && git commit -m "docs(references): file formats, quotas, pending sections and log rotation"`

### Task 5: demais referências — adoção e migração, multi-repo, branches, extensão

**Files:**
- Create: `references/adoption.md`, `references/multi-repo.md`, `references/branches.md`, `references/extension.md`

**Interfaces:**
- Consumes: T4.
- Produces: `adoption.md` com `## First session`, `## Project that already logs sessions another way`, `## Migrating a 1.x STATE` (os seis passos da §10 da spec, com o mapeamento de cabeçalhos PT→EN: `Estado atual`→`Current state`, `Próxima sessão`→`Now`, `Pendências`→ `Now`/`Blocked`/`Deferred` conforme §10.2, `ultima-sessao`→`last-session`, `ultimo-fechamento-completo`→`last-full-end`, `Repos-irmãos`→`Sibling repos`, `Escopo deste arquivo`→`Scope`; commit `docs: SESSION_STATE.md in session-ritual 2.0 format`). `multi-repo.md` (1.3 traduzido: linha `**Sibling repos:**`, um dono por pendência, nunca repetir). `branches.md` (§7: STATE da principal; branch de feature escreve LOG e o próprio bloco; merge: principal vence em Current state e pendências, blocos entram; LOG faz merge normal). `extension.md` (§3 e §8: arquivo `~/.claude/ritual-extend.md`, seções `## Start`, `## End`, `## Full end`, quando cada uma roda, "extra steps, not reconfiguration", sem compatibilidade com nomes 1.x).

- [ ] **Step 1: Escrever os quatro arquivos.** Cada um até 80 linhas. `adoption.md` traz um exemplo antes/depois de um STATE 1.x curto (10 linhas) migrado.
- [ ] **Step 2: Verificar**: `wc -l references/*.md` todos ≤ 80 exceto `files.md`; `grep -l 'Fim leve\|Início' references/` vazio (nomes 1.x não aparecem fora da tabela de migração do `adoption.md`).
- [ ] **Step 3: Commit**: `git add references/ && git commit -m "docs(references): adoption and 1.x migration, multi-repo, branches, extension"`

### Task 6: skill `session-start`

**Files:**
- Create: `skills/session-start/SKILL.md`

**Interfaces:**
- Consumes: contrato de T1 (linhas `## Repository —`, `**STATE in 1.x format**`, `Commits after the last`, `Feature branch:`), header do hook de T3 (`# Session start by hook`), `references/files.md`, `adoption.md`, `multi-repo.md`, `branches.md`, `extension.md`.
- Produces: comando `/session-ritual:session-start`.

Frontmatter exato:
```yaml
---
name: session-start
description: "Start-of-session briefing from SESSION_STATE.md and SESSION_LOG.md: pulls, reads the persisted state and the in-progress hand-off, then either proposes the next item or dives into the declared focus. Use when the user opens a session wanting to know where things stand (\"where were we\", \"what's on today\", \"let's start\", \"/session-start\"), or names a focus in the first message of a project that has a SESSION_STATE.md. Not for mid-session questions."
---
```

Corpo (≤ 80 linhas), nesta ordem:
1. **Mechanical part.** Se o contexto tem `# Session start by hook`, usar; senão rodar o script (`.ps1` ou `.sh`, dois níveis acima: `../../scripts/`). Linha `**STATE in 1.x format**` → abrir `../../references/adoption.md` e oferecer a migração **antes** do briefing. `Feature branch:` → ler `branches.md`.
2. **Read.** STATE inteiro; `Summary`/`Resumo` e `Pending`/`Pendências` das duas últimas entradas do LOG (do repo e de cada irmão); mês novo → `docs/sessions/` anterior. Sem arquivos → `adoption.md`, "First session".
3. **In progress first.** Com foco declarado: bloco cujo título bate com o foco → o briefing **é** o bloco, apagar o bloco ao assumir (edição de uma linha, sem commit), seguir. Sem bloco que bata → passo 4.
4. **Extension**: `## Start` de `~/.claude/ritual-extend.md` se existir.
5. **Briefing.** Sem foco: template `## Briefing — <date>` com `### Repository` (saída do script, colada), `### In progress` (títulos dos blocos), `### Now` (a lista, inteira), `### Blocked that changed`; fecha propondo o primeiro de In progress ou de Now, "start there?", e espera. Com foco: `## Briefing — <date> — focus: <x>`, só o que toca o foco (linhas do script que importam, item de Now ligado, decisão recente); "not planned; goes ahead of X" se não está em Now; segue sem parar. Nos dois: `(suposta)`/`(assumed)` entra como hipótese; **Deferred não entra**; data de pendência nunca vira cobrança.
6. Não rodar testes no início.

- [ ] **Step 1: Escrever `skills/session-start/SKILL.md`** com o frontmatter e o corpo acima.
- [ ] **Step 2: Verificar**: `wc -l` ≤ 80 (sem contar o frontmatter); `grep -c 'references/' SKILL.md` ≥ 4; `claude plugin validate .` sem erro.
- [ ] **Step 3: Commit**: `git add skills/session-start && git commit -m "feat(skills): session-start skill (2.0 briefing with in-progress hand-off)"`

### Task 7: skill `session-checkpoint`

**Files:**
- Create: `skills/session-checkpoint/SKILL.md`

**Interfaces:**
- Consumes: `references/files.md` (In progress blocks, checkpoint sub-block).
- Produces: comando `/session-ritual:session-checkpoint`; bloco `### <task title> — branch \`<b>\` (since DD/MM)` em `## In progress`; sub-bloco `### checkpoint HH:MM` na entrada do dia.

Frontmatter exato:
```yaml
---
name: session-checkpoint
description: "End of a task, not of the day: writes a hand-off block to '## In progress' in SESSION_STATE.md and a checkpoint sub-block in today's SESSION_LOG.md entry, then commits without pushing. Use when the user closes a task to start another (\"close this one and let's do X\", \"pause here\", \"mark the point\", \"/session-checkpoint\"). Runs without asking when the next focus is in the same sentence. Not for ending the day (that is session-end)."
---
```

Corpo (≤ 50 linhas):
1. **Confirm or not.** Foco seguinte na mesma frase → executa; senão uma linha: `Checkpoint — closing the task "<focus>": In progress block, LOG sub-block, commit without push. OK?`. Na dúvida tarefa/dia: `End of the task or of the day?`.
2. **Synthesize** desde o último checkpoint: 2 a 5 bullets (done com evidência ou "not exercised", decision, new pending).
3. **In progress block** (formato e 15 linhas de `files.md`): plano e posição, em voo, decidido-não-no-código, próximo passo literal. **Substitui** o bloco de mesmo título; cria se não há. Não toca mais nada do STATE além de linhas de pendência já apagadas durante a sessão.
4. **LOG**: sub-bloco `### checkpoint HH:MM` com `**Done:**`/`**Pending:**` na entrada de hoje; cria `## YYYY-MM-DD — <provisional title>` se não existe.
5. **Commit** `docs: checkpoint HH:MM — <summary>`, sem push, sem extensão, nada caro.
6. Em branch de feature: igual (o bloco é da branch); ver `branches.md`.

- [ ] **Step 1: Escrever o SKILL.md.**
- [ ] **Step 2: Verificar**: `wc -l` ≤ 50; `claude plugin validate .`.
- [ ] **Step 3: Commit**: `git add skills/session-checkpoint && git commit -m "feat(skills): session-checkpoint as end-of-task with hand-off block"`

### Task 8: skill `session-end`

**Files:**
- Create: `skills/session-end/SKILL.md`

**Interfaces:**
- Consumes: `references/files.md` (cotas, rotação, Pruned), `extension.md` (`## End`, `## Full end`), `branches.md`.
- Produces: comando `/session-ritual:session-end [--full]`.

Frontmatter exato:
```yaml
---
name: session-end
description: "End of the day, or of the week with --full: rewrites SESSION_STATE.md within its quotas, absorbs today's checkpoints into the SESSION_LOG.md entry, runs the personal extension, commits and pushes. Use when the user ends the session (\"we're done for today\", \"close the session\", \"/session-end\") or the week (\"close the week\", \"--full\"). Not for finishing one task (session-checkpoint) or a function."
---
```

Corpo (≤ 100 linhas):
1. **Confirm**, dizendo qual: `Closing the day — STATE rewritten, LOG entry, extension, push. OK?` / `Closing the week (last full end on DD/MM, N days ago) — all of the day plus pruning. OK?`. Full quando pedido ou `last-full-end` ausente ou > 7 dias; decide e avisa, não pergunta qual.
2. **Synthesize**: feito / não exercitado / decisões / pendente / próximo; checkpoints do dia entram.
3. **Rewrite STATE** (`files.md`): `## In progress` mantém só blocos ainda em voo, perguntando por cada um não tocado hoje; `Current state` é foto; pendências nas quatro seções com os movimentos (fechar some; pular exige motivo; destravar volta a Now); cada item com `(measured DD/MM)`/`(assumed)` no fim; **cotas conferidas por seção antes de seguir**, e o que sai já está no LOG. `last-session` hoje; no full, `last-full-end`.
4. **Prune (full only)**: §5.4 da spec: Deferred > 4 semanas sem condição de volta, Debt, Blocked > 4 semanas, blocos de In progress sem commit há 7 dias; uma pergunta em bloco cada; o apagado vai para `**Pruned:**` na entrada.
5. **LOG entry** no topo, `**Summary:**` em uma frase, absorvendo `### checkpoint`. Nunca editar outros dias. **Monthly rotation** se o mês mudou (`files.md`).
6. **Extension**: `## End` ou `## Full end`.
7. **Branch**: em branch de feature, STATE só `In progress` próprio (`branches.md`).
8. **Commit and push**: `git pull --rebase` antes (conflito se resolve; nunca força), `git add` dos arquivos da sessão e dos dois docs, commit `<type>: <one-line summary>` + bullets, push; confirmar que subiu ou dizer o erro. Grafo/testes não fazem parte.

- [ ] **Step 1: Escrever o SKILL.md.**
- [ ] **Step 2: Verificar**: `wc -l` ≤ 100; `claude plugin validate .`.
- [ ] **Step 3: Commit**: `git add skills/session-end && git commit -m "feat(skills): session-end with quotas, pruning on --full and monthly rotation"`

### Task 9: remover a skill 1.x e subir os manifests para 2.0.0

**Files:**
- Delete: `skills/session-ritual/SKILL.md`
- Modify: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`

- [ ] **Step 1: `git rm -r skills/session-ritual`.**
- [ ] **Step 2: `plugin.json`**: `version` `2.0.0`; `description` `"Session start, checkpoint and end rituals for Claude Code: a briefing when you open, a hand-off when you switch task, a record + commit when you close — all in SESSION_STATE.md and SESSION_LOG.md inside the repo."`; `skills`: `["./skills/session-start", "./skills/session-checkpoint", "./skills/session-end"]`; `keywords` + `"handoff"`. `marketplace.json`: `version` `2.0.0` nos dois lugares, mesma `description` curta.
- [ ] **Step 3: Verificar**: `claude plugin validate .` → ok; `grep -c '2.0.0' .claude-plugin/*.json` = 3.
- [ ] **Step 4: Commit**: `git add -A .claude-plugin skills && git commit -m "chore: 2.0.0 — three skills, old single skill removed"`

### Task 10: README e CHANGELOG

**Files:**
- Modify: `README.md` (reescrito em inglês)
- Create: `CHANGELOG.md`

- [ ] **Step 1: Escrever `README.md`** (≤ 120 linhas): what it is (3 linhas); the two files (tabela); the three rituals (tabela nível/quando/escreve/git, da §3 da spec); install (`/plugin marketplace add Camarota-234/session-ritual`, `/plugin install session-ritual@session-ritual`); what the hook does and how to disable it; "How this differs from the app's fork/hand-off" (15 lines vs the whole conversation); extension file and its three sections; worktrees and branches (3 linhas, link para `references/branches.md`); upgrading from 1.x (o início oferece migrar); "Why this repo has SESSION_STATE.md and SESSION_LOG.md at its root" (dogfooding); update procedure (o de hoje); seção final `## Em português` com 10 linhas.
- [ ] **Step 2: Escrever `CHANGELOG.md`**: `## 2.0.0 — 2026-10-xx` (três skills; In progress; Now/Blocked/Deferred/Debt; cotas e teto 80; rotação mensal; hook e `.sh` embarcados; inglês; migração), depois `## 1.3.1`, `1.3.0`, `1.2.0`, `1.1.0`, `1.0.0` com 1 a 3 linhas cada, tiradas do `SESSION_LOG.md`.
- [ ] **Step 3: Verificar**: `grep -c '^## ' CHANGELOG.md` = 6; README sem `/session-start` sem prefixo (todos `/session-ritual:…`): `grep -n '`/session-' README.md` só mostra formas com `session-ritual:`.
- [ ] **Step 4: Commit**: `git add README.md CHANGELOG.md && git commit -m "docs: README in English for 2.0, CHANGELOG 1.0 to 2.0"`

### Task 11: dogfooding — migrar o STATE deste repo e ensaiar os três comandos

**Files:**
- Modify: `SESSION_STATE.md` (deste repo, para o formato 2.0)
- Modify: `SESSION_LOG.md` (entrada do dia)

- [ ] **Step 1: Reinstalar o plugin local**: `/plugin marketplace update session-ritual`, `/plugin uninstall session-ritual@session-ritual`, `/plugin install session-ritual@session-ritual` (ou apontar o marketplace para a pasta local); confirmar que `/session-ritual:session-start` aparece no menu `/`.
- [ ] **Step 2: Rodar `/session-ritual:session-start` neste repo**: o script deve imprimir `**STATE in 1.x format**` e a skill oferecer a migração; aceitar. Conferir: seis cabeçalhos presentes, `wc -l SESSION_STATE.md` ≤ 80, `last-session` no frontmatter, entrada do LOG com bullet `Migration 2.0` listando o que saiu.
- [ ] **Step 3: Rodar `/session-ritual:session-checkpoint`** com uma tarefa fictícia ("README typo") → bloco em `## In progress`, sub-bloco no LOG, commit sem push (`git log -1` mostra `docs: checkpoint`; `git status -sb` mostra `ahead`).
- [ ] **Step 4: Abrir uma sessão nova com foco "README typo"** → o briefing é só o bloco, e o bloco some do STATE.
- [ ] **Step 5: Rodar `/session-ritual:session-end --full`** → STATE dentro das cotas, entrada do dia absorveu o checkpoint, `last-full-end` hoje, push feito. Registrar no `SESSION_LOG.md` o que não saiu como a spec diz (é a primeira lista de bugs da 2.0).
- [ ] **Step 6: Commit** (feito pelo próprio `session-end`).

### Task 12: `claude-config` — o hook pessoal deixa de chamar o script do plugin; extensão com as seções 2.0

**Files (outro repo, `C:\dev\pessoal\claude-config`):**
- Modify: `scripts/session-hook.ps1` (remove o bloco que chama `session-start.ps1`; mantém pull do vault e `vault-briefing.ps1`; cabeçalho passa a `# Vault context by hook (<source>)`)
- Modify: `tests/session-hook.tests.ps1` (asserções: não contém `## Repository`; contém `## Vault`)
- Modify: `ritual-extend.md` (seções `## Start`, `## End`, `## Full end`; o passo "Em repo dentro de C:\dev isto já rodou" passa a falar só do vault; `sync-global.ps1` se ele copia o arquivo)

- [ ] **Step 1: Ajustar os testes** do hook pessoal para o novo cabeçalho e rodar: `FAIL`.
- [ ] **Step 2: Editar `session-hook.ps1`** e rodar os testes: `tudo verde`.
- [ ] **Step 3: Renomear as seções de `ritual-extend.md`** e conferir que `grep -c '^## ' ritual-extend.md` = 3 com os nomes novos; rodar `sync-global.ps1` se for o mecanismo de cópia para `~/.claude`.
- [ ] **Step 4: Abrir uma sessão em `C:\dev\avex\constance`** e conferir no contexto: um bloco `# Session start by hook` (plugin) e um `# Vault context by hook` (pessoal), sem o `## Repository` duplicado.
- [ ] **Step 5: Commit no `claude-config`**: `git commit -am "chore: personal hook no longer runs session-start.ps1 (now shipped by session-ritual 2.0); extension sections renamed"`

---

## Self-review

- **Cobertura da spec**: §3 níveis → T6–T8; §3.1 três skills → T6–T9; §4 In progress → T4, T6, T7, T8; §5 pendências e poda → T4, T8; §6.1 cotas → T4, T8; §6.2 rotação → T4, T6, T8; §6.3 referências → T4–T5; §7 branches → T1 (linha), T5, T7, T8; §8 hook e scripts → T1–T3, T12; §9 idioma → todas; §10 migração → T1 (detecção), T5 (procedimento), T6 (oferta), T11 (ensaio); §11 repo público → T3 e T9 (validate), T10, T1–T3 (testes). `skill-creator`/`/skill-doctor` da §11 ficam para depois do ensaio de T11, como tarefa de release, fora deste plano.
- **Tipos e nomes**: `--no-pull`/`-NoPull`, `# Session start by hook`, `## Repository —`, `**STATE in 1.x format**`, `Feature branch:`, `## Start/End/Full end` usados com a mesma grafia em T1, T2, T3, T6, T8, T12.
- **Review Focus**: 1 (CRLF) em T1/T2 `CRLF state`; 2 (master/detached) em T1/T2; 3 (`ultima-sessao`) em T1/T2; 4 (stdin) em T3; 5 (caminho Windows no `.sh`) em T2.
- **Proporção**: o plano não traz corpo de script nem prosa das skills; traz contrato, nomes, asserções e cotas.
