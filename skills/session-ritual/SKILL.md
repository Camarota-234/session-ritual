---
name: session-ritual
description: "Ritual de início e fim de sessão para manter o contexto de um projeto entre sessões do Claude Code, em dois arquivos no próprio repo (SESSION_STATE.md e SESSION_LOG.md). Use SEMPRE que o usuário abrir a sessão querendo saber onde parou — \"o que temos pra hoje\", \"onde paramos\", \"me atualiza\", \"vamos começar\", \"/session-start\" — e SEMPRE que sinalizar que a sessão acabou — \"vamos encerrar\", \"fecha a sessão\", \"terminamos por hoje\", \"registra essa sessão\", \"/session-end\". Não use para \"finalizar\" uma tarefa ou função isolada — só o começo e o fim da sessão inteira."
---

# session-ritual

Dois rituais, um arquivo. O de **início** lê o que ficou registrado e entrega um
briefing antes de qualquer trabalho. O de **fim** registra o que aconteceu e
commita, para a próxima sessão (sua ou de um colega, nesta ou em outra máquina)
começar de onde esta parou.

Tudo mora em dois arquivos na raiz do repo (um par por repo — ver "Projeto em
mais de um repo"):

| Arquivo | O que é | Como muda |
|---|---|---|
| `SESSION_STATE.md` | onde o projeto está agora e o que vem a seguir | **reescrito** a cada fim de sessão |
| `SESSION_LOG.md` | o que aconteceu em cada sessão, em ordem | **append-only**, uma entrada por sessão |

Separar os dois evita que o estado atual se perca no meio do histórico e que o
histórico seja reescrito por engano. **O ritual não escreve no `CLAUDE.md`** — ele
é do dono do repo, e nenhum dos passos de início ou fim precisa dele. A única
exceção é a adoção do ritual num repo que já registrava sessões de outro jeito,
que troca as referências ao formato antigo uma vez, com autorização de quem
mantém o repo.

## Início (`/session-start`)

Execute em sequência, sem pedir confirmação, e só depois pergunte o foco.

1. **Sincronizar.** Se o repo tiver remote, `git pull --ff-only`. Se falhar
   (divergência, sem rede), não interrompa: anote no briefing que o repo pode
   estar desatualizado e siga.
2. **Ler o contexto persistido.** `SESSION_STATE.md` inteiro e as últimas duas
   entradas de `SESSION_LOG.md`. Se nenhum dos dois existir, é a primeira
   sessão neste projeto — veja "Primeira sessão" abaixo. Se o `SESSION_STATE.md`
   declarar **repos-irmãos** (ver "Projeto em mais de um repo"), repetir os
   passos 1 a 3 em cada um deles antes de montar o briefing.
3. **Estado do repositório.** `git status -sb` e `git log --oneline -5`. Anotar
   branch, último commit, arquivos modificados e, do `-sb`, **quantos commits a
   branch está à frente ou atrás do remote** — commit local não enviado costuma
   ser trabalho de outra máquina ou de uma sessão paralela, e passa despercebido
   se não for dito em voz alta. Não rode a suíte de testes
   aqui: custa tempo em toda sessão para dizer, quase sempre, que o repo está
   como foi deixado — e ela vai rodar de qualquer forma ao encostar no código.
   Se a última sessão fechou com teste vermelho, isso está no `SESSION_LOG.md`.
4. **Extensão.** Se `~/.claude/ritual-extend.md` existir, execute os passos da
   seção `## Início` dele (ver "Ponto de extensão").
5. **Briefing.** Apresente e pare:

   ```
   ## Briefing — [data de hoje]

   ### Repositório
   - Branch: ... (e "N commits à frente/atrás do remote", se houver)
   - Último commit: ...
   - Arquivos modificados: ... (ou "limpo")
   [uma linha por repo, se o projeto tiver mais de um]

   ### Planejado para esta sessão
   [seção "Próxima sessão" do SESSION_STATE.md, resumida se longa]

   ### Pendências e histórico relevante
   [pendências do SESSION_STATE.md + o que das últimas entradas do LOG impacta hoje]
   ```

   **Pendência marcada como suposta entra no briefing como hipótese, não como
   fato** — "consta que X está quebrado, não medido" e não "X está quebrado". Se
   ela for definir o trabalho do dia, o primeiro passo é confirmá-la, e isso é
   mais barato que planejar em cima de um risco que não existe.

   > "Tem algum foco específico para hoje, ou seguimos a ordem do planejado?"

   Aguarde a resposta antes de qualquer trabalho.

### Primeira sessão

Sem `SESSION_STATE.md` nem `SESSION_LOG.md`: apresente só o estado do
repositório e pergunte:

> "Este projeto ainda não tem registro de sessões. Quer que eu crie
> `SESSION_STATE.md` e `SESSION_LOG.md` para manter o contexto entre sessões?"

Se sim, crie os dois com os templates da seção "Formato dos arquivos", com o
que der para inferir do repo (README, último commit) — sem inventar pendências.

### Projeto que já registra sessões em outro formato

Um repo pode já ter um `HISTORICO.md`, um `CHANGELOG` de sessões ou uma seção
"Próxima sessão" dentro do `CLAUDE.md`. Não é "primeira sessão": é adoção, e ela
tem uma saída certa e duas erradas.

**Ao terminar, tem que existir UM log vivo.** Manter o log antigo recebendo
entradas ao lado do `SESSION_LOG.md` parece conservador e é o pior dos mundos: a
mesma sessão passa a ser escrita duas vezes, em granularidades diferentes, e nada
diz qual das duas está certa quando divergem.

- **Log antigo → renomear** (`git mv`, que preserva o blame) e seguir no formato
  novo daqui em diante. As entradas antigas ficam como estão, com uma nota de uma
  linha no topo dizendo até quando o formato era outro. É a saída padrão.
- **Se as entradas antigas forem longas e ainda consultadas**, dar a cada uma um
  resumo em Feito / Decisões / Pendências no topo, **preservando o texto original
  abaixo**. Custa uma sessão e devolve um arquivo que o início da sessão consegue
  ler em bullets.
- **Estado espalhado no `CLAUDE.md`** (seções "Estado atual", "Próxima sessão"):
  o conteúdo é copiado para o `SESSION_STATE.md`, e no `CLAUDE.md` **não se apaga
  nada** — ele é do dono do repo. Deixe um aviso de uma linha apontando para o
  arquivo novo, com autorização de quem mantém o repo.

Em qualquer das saídas, atualize as referências ao nome antigo nas instruções de
fim de sessão do `CLAUDE.md` — senão a próxima sessão escreve no arquivo errado.

## Projeto em mais de um repo

Um produto pode viver em dois ou três repositórios (frontend e automação, app e
infra). Cada um tem o seu par de arquivos — estado mora junto do código que ele
descreve, e quem clona só um deles ainda recebe um briefing honesto.

O que amarra os dois é uma linha no topo de cada `SESSION_STATE.md`:

```markdown
**Escopo deste arquivo:** <o que este repo cobre>.
**Repos-irmãos:** `<caminho>` — <o que aquele cobre>.
```

Duas regras que evitam a divergência:

- **Cada pendência tem um repo dono: o que consegue fechá-la.** Pendência do
  runtime não mora no STATE do painel, mesmo que tenha sido descoberta lá.
- **Nada de repetir a mesma pendência nos dois** "para não esquecer". Duas cópias
  envelhecem em velocidades diferentes, e a mais desatualizada é a que alguém lê.

No fim da sessão, reescreva o STATE de **cada** repo que a sessão tocou. No
início, leia o de todos.

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

   **Separe o que foi verificado do que só foi escrito.** Código commitado, teste
   verde e feature exercitada em produção não são a mesma coisa, e o registro que
   os mistura produz um projeto que parece pronto e nunca rodou. Cada item do que
   foi feito carrega a evidência que tem — teste rodado, query conferida, tela
   aberta, id da execução — ou a ausência dela, dita com todas as letras:
   *entregue, não exercitado*.

2. **Reescrever `SESSION_STATE.md`.** Estado atual com o que foi entregue,
   pendências atualizadas (remova o que fechou, adicione o que surgiu),
   próxima sessão com o plano. É uma foto do agora, não um diário: se algo
   não é mais verdade, some. Atualize `ultima-sessao` no frontmatter na mesma
   edição.

   **Toda pendência sai marcada com como foi estabelecida** — medida (com o que a
   mediu) ou suposta. Risco herdado que ninguém conferiu é hipótese, e escrevê-lo
   como fato faz a próxima sessão gastar o dia consertando o que não está
   quebrado — ou, pior, confiar num risco mal descrito que esconde o verdadeiro.

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
---
ultima-sessao: AAAA-MM-DD
---

# Estado da sessão — <nome do projeto>

**Escopo deste arquivo:** <o que este repo cobre>.
**Repos-irmãos:** <caminho> — <o que cobre>.   (só se houver)

## Estado atual
- <o que está funcionando, com a evidência que tem>
- <o que foi entregue e **nunca exercitado**, dito assim>

## Pendências
- <o que está aberto, com contexto para retomar, marcado (medida) ou (suposta)>

## Próxima sessão
- <o que fazer em seguida, em ordem>
```

**Data no frontmatter, e nunca "hoje" no corpo.** Um estado sem data não tem como
ser desmentido, e "entregue nesta sessão" vira mentira na semana seguinte sem que
uma linha mude. Escreva a data absoluta: "entregue em 24/08", não "entregue hoje".

`SESSION_LOG.md` (entradas mais recentes no topo):

```markdown
# Log de sessões — <nome do projeto>

## AAAA-MM-DD — <título curto da sessão>
- **Feito:** ... (com a evidência: teste rodado, query conferida, id da execução)
- **Feito, não exercitado:** ... (entregue sem prova de que roda; omitir se não houve)
- **Decisões:** ... (só o que não é óbvio pelo código; omitir se não houve)
- **Pendências:** ... (cada uma marcada como medida ou suposta)
```
