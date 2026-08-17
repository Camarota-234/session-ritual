---
name: session-ritual
description: "Ritual de início e fim de sessão para manter o contexto de um projeto entre sessões do Claude Code, em dois arquivos no próprio repo (SESSION_STATE.md e SESSION_LOG.md). Use SEMPRE que o usuário abrir a sessão querendo saber onde parou — \"o que temos pra hoje\", \"onde paramos\", \"me atualiza\", \"vamos começar\", \"/session-start\" — e SEMPRE que sinalizar que a sessão acabou — \"vamos encerrar\", \"fecha a sessão\", \"terminamos por hoje\", \"registra essa sessão\", \"/session-end\". Não use para \"finalizar\" uma tarefa ou função isolada — só o começo e o fim da sessão inteira."
---

# session-ritual

Dois rituais, um arquivo. O de **início** lê o que ficou registrado e entrega um
briefing antes de qualquer trabalho. O de **fim** registra o que aconteceu e
commita, para a próxima sessão (sua ou de um colega, nesta ou em outra máquina)
começar de onde esta parou.

Tudo mora em dois arquivos na raiz do projeto:

| Arquivo | O que é | Como muda |
|---|---|---|
| `SESSION_STATE.md` | onde o projeto está agora e o que vem a seguir | **reescrito** a cada fim de sessão |
| `SESSION_LOG.md` | o que aconteceu em cada sessão, em ordem | **append-only**, uma entrada por sessão |

Separar os dois evita que o estado atual se perca no meio do histórico e que o
histórico seja reescrito por engano. Nunca mexa no `CLAUDE.md` do projeto: ele
é do dono do repo, e o ritual não precisa dele.

## Início (`/session-start`)

Execute em sequência, sem pedir confirmação, e só depois pergunte o foco.

1. **Sincronizar.** Se o repo tiver remote, `git pull --ff-only`. Se falhar
   (divergência, sem rede), não interrompa: anote no briefing que o repo pode
   estar desatualizado e siga.
2. **Ler o contexto persistido.** `SESSION_STATE.md` inteiro e as últimas duas
   entradas de `SESSION_LOG.md`. Se nenhum dos dois existir, é a primeira
   sessão neste projeto — veja "Primeira sessão" abaixo.
3. **Estado do repositório.** `git status` e `git log --oneline -5`. Anotar
   branch, último commit, arquivos modificados. Não rode a suíte de testes
   aqui: custa tempo em toda sessão para dizer, quase sempre, que o repo está
   como foi deixado — e ela vai rodar de qualquer forma ao encostar no código.
   Se a última sessão fechou com teste vermelho, isso está no `SESSION_LOG.md`.
4. **Extensão.** Se `~/.claude/ritual-extend.md` existir, execute os passos da
   seção `## Início` dele (ver "Ponto de extensão").
5. **Briefing.** Apresente e pare:

   ```
   ## Briefing — [data de hoje]

   ### Repositório
   - Branch: ...
   - Último commit: ...
   - Arquivos modificados: ... (ou "limpo")

   ### Planejado para esta sessão
   [seção "Próxima sessão" do SESSION_STATE.md, resumida se longa]

   ### Pendências e histórico relevante
   [pendências do SESSION_STATE.md + o que das últimas entradas do LOG impacta hoje]
   ```

   > "Tem algum foco específico para hoje, ou seguimos a ordem do planejado?"

   Aguarde a resposta antes de qualquer trabalho.

### Primeira sessão

Sem `SESSION_STATE.md` nem `SESSION_LOG.md`: apresente só o estado do
repositório e pergunte:

> "Este projeto ainda não tem registro de sessões. Quer que eu crie
> `SESSION_STATE.md` e `SESSION_LOG.md` para manter o contexto entre sessões?"

Se sim, crie os dois com os templates da seção "Formato dos arquivos", com o
que der para inferir do repo (README, último commit) — sem inventar pendências.

## Fim (`/session-end`)

### Confirmar antes de escrever

Este ritual dispara por linguagem natural, e "vamos finalizar" pode ser sobre
uma tarefa, não sobre a sessão. Antes de tocar em qualquer arquivo ou rodar
git, confirme em uma linha:

> "Fechando a sessão — vou atualizar SESSION_STATE.md e SESSION_LOG.md e
> commitar. Confirma?"

Se o usuário só quis encerrar uma tarefa, pare aqui.

### Passos

1. **Sintetizar.** Antes de escrever, monte internamente: o que foi feito
   (features, fixes, refactors), decisões tomadas (escolhas e trade-offs que
   não são óbvios pelo código), o que ficou pendente, e o que vem a seguir.
2. **Reescrever `SESSION_STATE.md`.** Estado atual com o que foi entregue,
   pendências atualizadas (remova o que fechou, adicione o que surgiu),
   próxima sessão com o plano. É uma foto do agora, não um diário: se algo
   não é mais verdade, some.
3. **Adicionar entrada em `SESSION_LOG.md`.** No topo do arquivo, uma entrada
   com data, feito, decisões e pendências — bullets de uma linha, escaneável.
   Nunca edite entradas antigas.
4. **Grafo (opcional).** Se existir `graphify-out/` na raiz e arquivos de
   código mudaram nesta sessão, rode `graphify update .`. Se a pasta não
   existir, pule em silêncio — o projeto não usa graphify e não precisa saber
   que ele existe.
5. **Extensão.** Se `~/.claude/ritual-extend.md` existir, execute os passos da
   seção `## Fim` dele.
6. **Commit e push.** `git pull --rebase` primeiro (outra máquina pode ter
   subido algo; se conflitar, resolva antes — nunca push forçado). Depois
   `git add` nos arquivos da sessão (código + os dois docs) e commit:

   ```
   [tipo]: [resumo em uma linha do que foi feito]

   [bullets dos principais itens, se houver mais de um]
   ```

   Push para a branch atual. Ao terminar, confirme em uma linha que subiu. Se
   o push falhar, diga qual foi o erro — não afirme que a sessão fechou.

## Ponto de extensão

O ritual acima é o mesmo em qualquer projeto. Passos que só fazem sentido para
uma pessoa (sincronizar um vault de notas, atualizar um índice fora do repo,
commitar um segundo repositório) não entram aqui — vão num arquivo opcional,
global, fora de qualquer projeto:

```
~/.claude/ritual-extend.md
```

com duas seções, `## Início` e `## Fim`, cada uma com passos em linguagem
natural. O ritual executa a seção correspondente no ponto marcado acima —
depois de ler o contexto (início) e depois de escrever os docs, antes do commit
(fim). Se o arquivo não existir, nada acontece e nada é mencionado.

É para passos **extras**, não para reconfigurar a base: os nomes dos arquivos,
a ordem dos passos e a confirmação antes de escrever não mudam por extensão.

## Formato dos arquivos

`SESSION_STATE.md`:

```markdown
# Estado da sessão — <nome do projeto>

## Estado atual
- <o que está funcionando / entregue, em bullets>

## Pendências
- <o que está aberto, com contexto suficiente para retomar>

## Próxima sessão
- <o que fazer em seguida, em ordem>
```

`SESSION_LOG.md` (entradas mais recentes no topo):

```markdown
# Log de sessões — <nome do projeto>

## AAAA-MM-DD — <título curto da sessão>
- **Feito:** ...
- **Decisões:** ... (só o que não é óbvio pelo código; omitir se não houve)
- **Pendências:** ...
```
