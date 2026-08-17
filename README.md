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

- **graphify**: se o projeto tiver `graphify-out/` na raiz, o ritual de fim
  roda `graphify update .` quando houve mudança de código. Sem a pasta, o passo
  é pulado em silêncio.
- **Extensão pessoal**: passos que só fazem sentido para você (sincronizar um
  vault de notas, atualizar um índice fora do repo, commitar um segundo
  repositório) vão em `~/.claude/ritual-extend.md`, com seções `## Início` e
  `## Fim` em linguagem natural. O ritual executa cada seção no ponto certo.
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
