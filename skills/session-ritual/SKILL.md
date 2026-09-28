---
name: session-ritual
description: "Ritual de início e fim de sessão para manter o contexto de um projeto entre sessões do Claude Code, em dois arquivos no próprio repo (SESSION_STATE.md e SESSION_LOG.md). Use SEMPRE que o usuário abrir a sessão querendo saber onde parou — \"o que temos pra hoje\", \"onde paramos\", \"me atualiza\", \"vamos começar\", \"/session-start\" —, SEMPRE que sinalizar que a sessão acabou — \"vamos encerrar\", \"fecha a sessão\", \"terminamos por hoje\", \"registra essa sessão\", \"/session-end\", \"fecha a semana\" —, e SEMPRE que pedir para marcar o ponto no meio da sessão — \"marca um checkpoint\", \"registra até aqui\", \"/session-checkpoint\". Não use para \"finalizar\" uma tarefa ou função isolada — só o começo, o meio marcado e o fim da sessão inteira."
---

# session-ritual

Três rituais, dois arquivos. O de **início** lê o que ficou registrado e entrega um
briefing antes de qualquer trabalho. O **checkpoint** marca o ponto no meio do dia sem
pagar o fim. O de **fim** registra o que aconteceu e commita — leve por padrão,
completo por pedido ou por data — para a próxima sessão (sua ou de um colega, nesta ou
em outra máquina) começar de onde esta parou.

Tudo mora em dois arquivos na raiz do repo (um par por repo — ver "Projeto em
mais de um repo"):

| Arquivo | O que é | Como muda |
|---|---|---|
| `SESSION_STATE.md` | onde o projeto está agora e o que vem a seguir | **reescrito** a cada fim de sessão, dentro de um teto de 120 linhas |
| `SESSION_LOG.md` | o que aconteceu em cada sessão, em ordem | **append-only**, uma entrada por sessão |

Separar os dois evita que o estado atual se perca no meio do histórico e que o
histórico seja reescrito por engano. **O ritual não escreve no `CLAUDE.md`** — ele
é do dono do repo, e nenhum dos passos de início ou fim precisa dele. Duas exceções,
as duas com autorização de quem mantém o repo: a adoção do ritual num repo que já
registrava sessões de outro jeito (troca as referências ao formato antigo uma vez), e
**mover** uma trava permanente do STATE para o `CLAUDE.md` (ver "Regras de dieta").

## Início (`/session-start`)

Execute em sequência, sem pedir confirmação. Há dois modos, e a primeira mensagem
decide qual: **foco declarado** (o usuário já disse o que quer fazer — "hoje é o Pix",
"vamos no bug do login") e **sem foco** ("o que temos", "onde paramos"). Os passos 1 a
3 são iguais nos dois; só o briefing muda.

1. **Parte mecânica, por script.** Rodar, com o caminho do repo atual:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "<pasta do plugin>\scripts\session-start.ps1" -Repo <repo>
   ```

   `<pasta do plugin>` é a raiz deste plugin — dois níveis acima deste `SKILL.md`
   (`…\session-ritual\scripts\session-start.ps1`). O script faz `git pull --ff-only`,
   `git status -sb` com ahead/behind e os últimos commits — do repo atual **e de cada
   repo-irmão** declarado na linha `**Repos-irmãos:**` do `SESSION_STATE.md`. A saída
   é a seção "Repositório" do briefing, pronta: colar, não reescrever.

   O script também compara `ultima-sessao` do frontmatter do `SESSION_STATE.md` com o
   histórico do repo. Se há commits **depois** do último fechamento, imprime a linha
   "Commits depois do último `/session-end`". Isso significa que houve trabalho que o
   STATE não conhece (terminal fechado sem ritual, sessão de outra máquina): o
   briefing repete a linha e trata "Próxima sessão" como possivelmente defasada.

   Se o pull falhar (divergência, sem rede), o script não interrompe: a linha "Pull
   falhou" entra no briefing como está. Se o script não existir ou o PowerShell não
   estiver disponível, fazer à mão, por repo: `git pull --ff-only`, `git status -sb`
   (anotando **quantos commits a branch está à frente ou atrás do remote** — commit
   local não enviado costuma ser trabalho de outra máquina ou de uma sessão paralela,
   e passa despercebido se não for dito em voz alta), `git log --oneline -5`.

   Não rode a suíte de testes aqui: custa tempo em toda sessão para dizer, quase
   sempre, que o repo está como foi deixado — e ela vai rodar de qualquer forma ao
   encostar no código. Se a última sessão fechou com teste vermelho, isso está no
   `SESSION_LOG.md`.
2. **Ler o contexto persistido.** `SESSION_STATE.md` inteiro e, das últimas duas
   entradas de `SESSION_LOG.md`, o bullet **Resumo** e o bullet **Pendências** — do
   repo atual e de cada repo-irmão. O resto da entrada só se o foco do dia tocar nela
   (entrada antiga sem `Resumo`: ler as primeiras 10 linhas). Se nenhum dos dois
   arquivos existir, é a primeira sessão neste projeto — veja "Primeira sessão" abaixo.
3. **Extensão.** Se `~/.claude/ritual-extend.md` existir, execute os passos da seção
   `## Início` dele (ver "Ponto de extensão").
4. **Briefing.** Depende do modo.

   **Sem foco** — apresente e pare:

   ```
   ## Briefing — [data de hoje]

   ### Repositório
   [saída do script, um sub-bloco por repo]

   ### Planejado para esta sessão
   [seção "Próxima sessão" do SESSION_STATE.md, resumida se longa]

   ### Pendências e histórico relevante
   [pendências do SESSION_STATE.md + o que das últimas entradas do LOG impacta hoje]
   ```

   Feche propondo, não perguntando em aberto: o item 1 de "Próxima sessão" é o foco
   sugerido, e a pergunta é só "começo por aí?". Aguarde a resposta antes de qualquer
   trabalho.

   **Foco declarado** — não há parada. O briefing encolhe para o que toca o foco:

   ```
   ## Briefing — [data de hoje] — foco: [o que o usuário pediu]
   - [linhas do script que importam: pull falhou, commits depois do último fechamento,
     ahead/behind, arquivos modificados. Repo limpo e em dia = uma linha]
   - [o que do STATE e do LOG toca o foco: pendência ligada, decisão recente, evidência]
   - [se o foco não está em "Próxima sessão": "não estava planejado; entra na frente de
     X" — uma frase, sem pedir justificativa]
   ```

   E segue direto para o trabalho. O que não toca o foco não entra: o STATE inteiro
   foi lido e está em contexto para quando precisar.

   **Nos dois modos, pendência marcada como suposta entra como hipótese, não como
   fato** — "consta que X está quebrado, não medido" e não "X está quebrado". Se
   ela for definir o trabalho do dia, o primeiro passo é confirmá-la, e isso é
   mais barato que planejar em cima de um risco que não existe.

   **O briefing não cobra prazo.** Data de pendência é contexto para retomar, não
   gatilho: nada de "está aberta há N dias". Quem decide a ordem é a lista de
   "Próxima sessão".

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

O caminho vai entre crases: é assim que o script do início o encontra e inclui o
irmão no bloco "Repositório". Mais de um irmão, mais de um par crase–caminho na mesma
linha.

Duas regras que evitam a divergência:

- **Cada pendência tem um repo dono: o que consegue fechá-la.** Pendência do
  runtime não mora no STATE do painel, mesmo que tenha sido descoberta lá.
- **Nada de repetir a mesma pendência nos dois** "para não esquecer". Duas cópias
  envelhecem em velocidades diferentes, e a mais desatualizada é a que alguém lê.

No fim da sessão, reescreva o STATE de **cada** repo que a sessão tocou. No
início, leia o de todos — o script já traz o estado Git de todos.

## Durante a sessão

Uma regra só: **pendência que fecha, sai do STATE na hora.** Quando o trabalho da
sessão resolve uma linha de "Pendências" (com evidência, não por intenção), apague a
linha naquele momento, em edição de uma linha, sem commit próprio — o checkpoint ou o
`/session-end` seguinte commita. Não reescreva mais nada do STATE nesse momento: o
resto é do fim de sessão. O fim fica mais barato porque parte do STATE já está certo,
e um terminal fechado sem ritual perde menos.

## Checkpoint (`/session-checkpoint`)

Para a sessão que se divide em partes no mesmo dia — a conversa migrou de assunto, o
terminal vai fechar por uma hora, ou uma entrega fechou e vale marcar o ponto sem pagar
o fim de sessão inteiro. Confirme em uma linha:

> "Marcando checkpoint — vou acrescentar um bloco na entrada de hoje do SESSION_LOG.md
> e commitar. Confirma?"

Depois:

1. **Sintetizar o trecho** desde o último checkpoint (ou desde o início): 2 a 5
   bullets — feito (com evidência ou "não exercitado"), decisão, pendência nova.
2. **Escrever no `SESSION_LOG.md`.** Se a entrada de hoje já existe no topo, acrescentar
   ao fim dela um sub-bloco:

   ```markdown
   ### checkpoint HH:MM
   - **Feito:** ...
   - **Pendências:** ...
   ```

   Se não existe, criar a entrada do dia (`## AAAA-MM-DD — <título provisório>`) só com
   esse sub-bloco.
3. **Commit** dos arquivos da sessão e do LOG: `docs: checkpoint HH:MM — <resumo>`.
   Push é opcional aqui; é obrigatório no fim.

**O checkpoint não reescreve o `SESSION_STATE.md`** (só leva junto as linhas de
pendência já apagadas durante a sessão), **não roda extensão e não roda nada caro.** No `/session-end` seguinte, a entrada do dia é reescrita **absorvendo** os
checkpoints: os sub-blocos `### checkpoint` somem e o conteúdo vira os bullets normais
da entrada. Nenhum checkpoint sobrevive a um fim de sessão.

## Fim (`/session-end`)

Há dois tamanhos de fim, e o **leve é o padrão**. O completo só roda por pedido ou por
data — nunca por reflexo.

### Confirmar antes de escrever

Este ritual dispara por linguagem natural, e "vamos finalizar" pode ser sobre uma
tarefa, não sobre a sessão. Antes de tocar em qualquer arquivo ou rodar git, confirme
em uma linha, dizendo qual dos dois vai rodar e por quê:

> "Fechando a sessão (leve) — vou atualizar SESSION_STATE.md e SESSION_LOG.md e
> commitar. Confirma?"

> "Fechando a sessão (completo — último completo em DD/MM, há N dias) — STATE, LOG,
> extensão completa e commit. Confirma?"

Se o usuário só quis encerrar uma tarefa, pare aqui.

### Qual dos dois

**Completo** quando qualquer um vale:

- o usuário pediu — "fecha a semana", "fechamento completo", `/session-end --completo`;
- o frontmatter do `SESSION_STATE.md` não tem `ultimo-fechamento-completo`, ou a data
  tem **mais de 7 dias**.

Senão, **leve**. Diga qual gatilho disparou na confirmação. Não pergunte "leve ou
completo?" — decida e avise.

### Passos

1. **Sintetizar.** Antes de escrever, monte internamente: o que foi feito (features,
   fixes, refactors), decisões tomadas (escolhas e trade-offs que não são óbvios pelo
   código), o que ficou pendente, e o que vem a seguir. Se há checkpoints na entrada de
   hoje, eles entram nesta síntese.

   **Separe o que foi verificado do que só foi escrito.** Código commitado, teste
   verde e feature exercitada em produção não são a mesma coisa, e o registro que os
   mistura produz um projeto que parece pronto e nunca rodou. Cada item do que foi
   feito carrega a evidência que tem — teste rodado, query conferida, tela aberta, id
   da execução — ou a ausência dela, dita com todas as letras: *entregue, não
   exercitado*.

2. **Reescrever `SESSION_STATE.md`** dentro das **regras de dieta** (ver "Formato dos
   arquivos"). Estado atual com o que foi entregue, pendências atualizadas (remova o
   que fechou, adicione o que surgiu), próxima sessão com o plano. É uma foto do agora,
   não um diário: se algo não é mais verdade, some. Atualize `ultima-sessao` no
   frontmatter; no fim completo, também `ultimo-fechamento-completo`.

   **Toda pendência sai marcada com como foi estabelecida** — medida (com o que a
   mediu) ou suposta. Risco herdado que ninguém conferiu é hipótese, e escrevê-lo como
   fato faz a próxima sessão gastar o dia consertando o que não está quebrado — ou,
   pior, confiar num risco mal descrito que esconde o verdadeiro. Pendência nova
   também leva a data em que surgiu, `(desde DD/MM)`, como contexto para retomar.
   Pendência que espera terceiro (cliente, fornecedor) leva `(aguardando <quem>)`, e
   isso é tudo: a data não vira cobrança em lugar nenhum do ritual.

   **Conferir o teto antes de seguir:** `wc -l SESSION_STATE.md` ≤ 120. Passou, cortar
   agora — o que sair já está no LOG.

3. **Entrada em `SESSION_LOG.md`.** No topo do arquivo, uma entrada com data, resumo,
   feito, decisões e pendências. **O primeiro bullet é sempre `Resumo`, uma frase:** é
   o que o início da próxima sessão lê; o resto da entrada pode ser tão longo quanto a
   sessão merecer, porque só é lido quando o foco do dia pede. Se a entrada de hoje já
   existe (por checkpoint ou por uma parte anterior), reescrevê-la absorvendo os
   sub-blocos `### checkpoint`. Nunca edite entradas de outros dias.
4. **Extensão.** Se `~/.claude/ritual-extend.md` existir: no fim leve, executar a seção
   `## Fim leve`; no completo, `## Fim completo`. Arquivo antigo que só tem `## Fim` é
   tratado como `## Fim completo` (e o leve não roda extensão nenhuma).
5. **Commit e push.** `git pull --rebase` primeiro (outra máquina pode ter subido algo;
   se conflitar, resolva antes — nunca push forçado). Depois `git add` nos arquivos da
   sessão (código + os dois docs) e commit:

   ```
   [tipo]: [resumo em uma linha do que foi feito]

   [bullets dos principais itens, se houver mais de um]
   ```

   Push para a branch atual. Ao terminar, confirme em uma linha que subiu. Se o push
   falhar, diga qual foi o erro — não afirme que a sessão fechou.

**O grafo de código não faz parte do ritual.** Projeto que usa graphify roda
`/graphify` quando quer o grafo atualizado — é caro, e o fim de sessão não é o lugar.

## Ponto de extensão

O ritual acima é o mesmo em qualquer projeto. Passos que só fazem sentido para uma
pessoa (sincronizar um vault de notas, atualizar um índice fora do repo, commitar um
segundo repositório) não entram aqui — vão num arquivo opcional, global, fora de
qualquer projeto:

```
~/.claude/ritual-extend.md
```

com três seções, cada uma com passos em linguagem natural:

| Seção | Quando roda |
|---|---|
| `## Início` | depois de ler o contexto, antes do briefing |
| `## Fim leve` | no fim leve, depois de escrever os docs, antes do commit |
| `## Fim completo` | no fim completo, no mesmo ponto — **no lugar** do leve, não além dele |

Arquivo antigo que só tem `## Fim` continua funcionando: vale como `## Fim completo`,
e o fim leve não roda extensão. Se o arquivo não existir, nada acontece e nada é
mencionado.

É para passos **extras**, não para reconfigurar a base: os nomes dos arquivos, a ordem
dos passos, o teto do STATE e a confirmação antes de escrever não mudam por extensão.

## Formato dos arquivos

`SESSION_STATE.md`:

```markdown
---
ultima-sessao: AAAA-MM-DD
ultimo-fechamento-completo: AAAA-MM-DD
---

# Estado da sessão — <nome do projeto>

**Escopo deste arquivo:** <o que este repo cobre>.
**Repos-irmãos:** `<caminho>` — <o que cobre>.   (só se houver; o caminho entre crases)

## Estado atual
- <o que está funcionando, com o ponteiro da evidência: execução, commit, query>
- <o que foi entregue e **nunca exercitado**, dito assim>

## Pendências
- <o que está aberto, com contexto para retomar, marcado (medida) ou (suposta), (desde DD/MM), e (aguardando <quem>) se depende de terceiro>

## Próxima sessão
- <o que fazer em seguida, em ordem — a ordem aqui manda, não a data da pendência>
```

### Regras de dieta do STATE

O STATE é lido inteiro no início de toda sessão e reescrito inteiro no fim de toda
sessão. Cada linha a mais custa duas vezes — e um STATE que ninguém consegue reconferir
é onde a pendência falsa sobrevive. Por isso:

- **Teto: 120 linhas.** Passou, a sessão corta antes de commitar. O que sai já está no
  LOG do dia em que aconteceu.
- **Trava que não muda não mora aqui.** Regra permanente do projeto ("nunca chamar X
  direto", "sempre `$('Nó')`, nunca `$json`") vai para o `CLAUDE.md` do repo. Mover
  uma trava do STATE para o `CLAUDE.md` é a **segunda exceção** à regra de que o ritual
  não escreve lá — é mover, não criar, e ainda pede autorização de quem mantém o repo.
- **Item fechado some.** Nada de `~~riscado~~` nem "RESOLVIDO em DD/MM": a história
  está no LOG.
- **Evidência vira ponteiro.** "Provado na execução 9924, commit `ad35279`", e não o
  relato da execução. O relato mora no LOG.
- **Pendência que perdeu o contexto sai.** Não é por idade: é quando ela não está
  mais em "Próxima sessão" e ninguém sabe dizer o que falta. Vira linha em "Dívida"
  do `CLAUDE.md` ou entrada de decisão, conforme o caso. A data `(desde DD/MM)`
  fica só para quem retoma saber de quando é o contexto.
- **Estado é o que é verdade hoje.** Evento marcado não é evento ocorrido: "a reunião
  é em 27/08" entra em "Próxima sessão", nunca em "Estado atual" como se já tivesse
  acontecido.

**Data no frontmatter, e nunca "hoje" no corpo.** Um estado sem data não tem como
ser desmentido, e "entregue nesta sessão" vira mentira na semana seguinte sem que
uma linha mude. Escreva a data absoluta: "entregue em 24/08", não "entregue hoje".

`SESSION_LOG.md` (entradas mais recentes no topo):

```markdown
# Log de sessões — <nome do projeto>

## AAAA-MM-DD — <título curto da sessão>
- **Resumo:** <uma frase: o que a sessão mudou no projeto — é o que o início lê>
- **Feito:** ... (com a evidência: teste rodado, query conferida, id da execução)
- **Feito, não exercitado:** ... (entregue sem prova de que roda; omitir se não houve)
- **Decisões:** ... (só o que não é óbvio pelo código; omitir se não houve)
- **Pendências:** ... (cada uma marcada como medida ou suposta, com a data em que surgiu)
```

Entre um fim de sessão e outro, a entrada do dia pode carregar sub-blocos
`### checkpoint HH:MM` (ver "Checkpoint"). Eles são absorvidos no `/session-end`.
