# session-ritual

Ritual de início e fim de sessão para o Claude Code. Mantém o contexto de um
projeto entre sessões — sua, de um colega, ou sua em outra máquina — em dois
arquivos que vivem no próprio repositório.

| Arquivo | O que guarda |
|---|---|
| `SESSION_STATE.md` | onde o projeto está agora, pendências, o que vem a seguir (reescrito a cada sessão) |
| `SESSION_LOG.md` | o que aconteceu em cada sessão, em ordem (append-only) |

**Ao começar** ("onde paramos", "o que temos pra hoje", `/session-start`): puxa
o repo, lê os dois arquivos, roda `git status`, entrega um briefing e pergunta o
foco do dia.

**Ao encerrar** ("vamos encerrar", "terminamos por hoje", `/session-end`):
confirma em uma linha, sintetiza a sessão, reescreve o `STATE`, adiciona uma
entrada no `LOG`, e commita + faz push.

**No meio** ("marca um checkpoint", `/session-checkpoint`): acrescenta um bloco na
entrada de hoje do `LOG` e commita. Não toca o `STATE`.

O fim tem dois tamanhos: **leve** (padrão — STATE, LOG, commit) e **completo** (por
pedido — "fecha a semana" — ou quando o último completo tem mais de 7 dias). A
extensão pessoal escolhe o que roda em cada um (`## Fim leve` / `## Fim completo`).

O `STATE` tem teto de **120 linhas** e regras de dieta (travas permanentes vão para o
`CLAUDE.md`, item fechado some, evidência vira ponteiro). Detalhes no `SKILL.md`.

Na primeira sessão de um projeto, pergunta antes de criar os arquivos. Não mexe
no seu `CLAUDE.md`.

## Instalar

Dentro do Claude Code:

```
/plugin marketplace add Camarota-234/session-ritual
/plugin install session-ritual@session-ritual
```

Nada mais. Não há configuração.

## Opcional

- **graphify**: não faz parte do ritual desde a 1.2.0. Rode `/graphify` quando
  quiser o grafo.
- **Script de início**: `scripts/session-start.ps1` faz pull, status e ahead/behind
  do repo e dos repos-irmãos; a skill o chama sozinha. Serve também como hook
  `SessionStart` com `-NoPull` (só lê, não puxa).
- **Extensão pessoal**: passos que só fazem sentido para você (sincronizar um
  vault de notas, atualizar um índice fora do repo, commitar um segundo
  repositório) vão em `~/.claude/ritual-extend.md`, com seções `## Início`,
  `## Fim leve` e `## Fim completo` em linguagem natural. O ritual executa cada seção no ponto certo.
  Sem o arquivo, nada muda. Detalhes em `skills/session-ritual/SKILL.md`,
  seção "Ponto de extensão".

## Atualizar

Toda mudança em `skills/` exige bump de `version` em `.claude-plugin/plugin.json`
e `.claude-plugin/marketplace.json` — o Claude Code guarda o plugin em cache por
versão e, sem o bump, segue rodando a versão antiga sem aviso.

Para pegar uma versão nova:

```
/plugin marketplace update session-ritual
/plugin uninstall session-ritual@session-ritual
/plugin install session-ritual@session-ritual
```
