# session-ritual 2.0 — desenho

Data: 2026-10-21. Autor: João Guilherme, com Claude.
Estado: **aprovada em 21/10** (decisões da §12 fechadas). Substitui o desenho implícito
do `SKILL.md` 1.3.1. Plano em `docs/superpowers/plans/2026-10-21-session-ritual-2.0.md`.

## 1. Por que uma 2.0

A 1.x foi desenhada para um terminal por dia: uma sessão, um fechamento. O uso real em
outubro de 2026, medido nos nove repos da Avex, é outro:

| Medida | Valor |
|---|---|
| Sessões do app no `arkora-painel`, 17/09 a 21/10 | 30 |
| Entradas de LOG num só dia (06/10, arkora-painel) | 8 |
| Commits que tocam o `SESSION_LOG.md` em 20 dias (arkora-painel) | 47 |
| Usos do `/session-checkpoint` nos repos da Avex | 0 |
| Briefings no formato `## Briefing — <data>` em outubro | 4 |
| STATEs em 112, 119, 119 linhas (teto 120) | 3 de 9 |
| `SESSION_LOG.md` do arkora-painel | 3.980 linhas, 94 entradas |

O que isso diz:

- **A unidade virou tarefa, não dia.** Cada sessão do app fecha com o ritual inteiro
  (STATE reescrito, entrada, extensão, dois commits, dois pushes), oito vezes num dia.
- **O checkpoint não serve à dor que existe.** A dor é *começar* a sessão seguinte fria,
  não *registrar* a anterior. O checkpoint só gravava LOG.
- **Pendências confundem.** A marcação atual (`medida/suposta`, `desde`, `aguardando`)
  responde "é verdade?" e "de quando?", não "o que faço com isso agora?". Prioridade,
  dificuldade e dependência não têm lugar; pular não é um ato.
- **O teto do STATE é cumprido por compressão, não por poda.** Pendências "paradas
  desde 19/08" sobrevivem porque a regra "perdeu o contexto, sai" não tem gatilho.
- **Worktree não tem regra.** `constance-flow-dash-retirada` é um worktree com STATE e
  LOG próprios, já divergentes da `main`.
- **Leve e completo são iguais no plugin base.** A diferença mora toda na extensão
  pessoal; para quem instala sem extensão, "completo" não faz nada a mais.

O que **está** funcionando e a 2.0 preserva: estado no repo, foto (STATE) separada de
diário (LOG), feito separado de verificado, pendência medida separada de suposta,
`Resumo` em toda entrada (100% desde 28/09), hook que injeta o estado mecânico.

## 2. Objetivos e não-objetivos

Objetivos:

1. Fim de tarefa barato, com handoff embutido, para a sessão seguinte começar quente.
2. Pendências organizadas por **o que fazer com elas**, com pular como ato explícito.
3. Docs menores por construção (cotas por seção, rotação do LOG), não por disciplina.
4. Plugin instalável do zero em qualquer máquina: hook e script vêm junto, em
   PowerShell e bash, em inglês.
5. Regra para branch e worktree.

Não-objetivos:

- Mudar o par de arquivos ou a separação STATE/LOG.
- Cobrança por prazo, persona, coaching. Continua fora (decisão de 28/09).
- Grafo, testes de suíte, deploy no ritual. Continuam fora.
- Compatibilidade de leitura com o formato 1.x no `SKILL.md`: o início **detecta** o
  formato antigo e **oferece migrar**; não lê os dois.

## 3. Três níveis

| Nível | Comando | Unidade | Escreve | Git |
|---|---|---|---|---|
| **Checkpoint** | `/session-checkpoint` | tarefa | sub-bloco `### checkpoint` na entrada do dia do LOG; **substitui o seu bloco** em `## Em andamento` do STATE | commit, sem push |
| **Fim** | `/session-end` | dia | absorve os checkpoints, reescreve o STATE inteiro, entrada do LOG, extensão `## End` | commit + push |
| **Completo** | `/session-end --full` ou 7 dias | semana | tudo do Fim + **poda** (§5.4) + extensão `## Full end` | commit + push |

Seções da extensão pessoal na 2.0, em inglês como o resto: `## Start`, `## End`,
`## Full end`. Sem compatibilidade com `## Início` / `## Fim leve` / `## Fim completo`.

Os nomes ficam os de hoje (decisão de 21/10). Muda o que cada um faz e o texto da
confirmação, que passa a dizer a unidade.

### 3.1 Uma skill por comando

Conferido na doc em 21/10: skill de plugin vira o comando `/<plugin>:<skill>`, e uma
skill tem **um** comando. Na 1.x há uma skill só (`session-ritual`), então
`/session-start`, `/session-end` e `/session-checkpoint` nunca existiram como comandos:
o que dispara é a frase na `description`, e o comando real é
`/session-ritual:session-ritual`. Na 2.0 o plugin passa a ter **três skills**:

```
skills/
  session-start/SKILL.md        /session-ritual:session-start
  session-checkpoint/SKILL.md   /session-ritual:session-checkpoint
  session-end/SKILL.md          /session-ritual:session-end   (--completo por argumento ou frase)
references/                     compartilhado, citado pelos três por ${CLAUDE_PLUGIN_ROOT}/references/
```

Ganhos além do comando funcionar: cada disparo carrega só o seu ritual (o início não
precisa das regras do fim), e a `description` de cada uma fica curta e específica, o
que melhora o gatilho por linguagem natural. Custo: regras comuns (os dois arquivos,
cotas, Em andamento) moram em `references/files.md` e são citadas, não repetidas.

A confirmação passa a dizer a unidade:

> "Checkpoint — fecho a tarefa *<foco>*: bloco em Em andamento, sub-bloco no LOG, commit sem push. Confirma?"
> "Fechando o dia — STATE reescrito, entrada do LOG, extensão, push. Confirma?"
> "Fechando a semana (último completo em DD/MM) — tudo do dia mais poda de pendências. Confirma?"

Gatilhos em linguagem natural: "fecha essa e vamos para X", "pausa aqui", "marca o
ponto" → checkpoint. "terminamos por hoje", "fecha a sessão" → fim. "fecha a semana" →
completo. Na dúvida entre checkpoint e fim, a skill pergunta em uma linha: "é fim da
tarefa ou do dia?".

O **fim leve/completo da 1.x vira fim/completo**, e a diferença no plugin base passa a
existir: a poda (§5.4) é do completo.

## 4. Handoff: `## Em andamento`

Seção nova no STATE, a primeira depois do cabeçalho. Um `###` por tarefa em voo:

```markdown
## Em andamento

### Atendimento, fase 1 — branch `feat/atendimento` (desde 21/10)
- Plano: `docs/superpowers/plans/2026-10-20-atendimento-experiencia.md`, task 7 de 18.
- Em voo: `src/components/Atendimento/Lista.tsx` com o teste RED de ordenação; `npm test -- Lista` reproduz.
- Decidido na conversa, ainda não no código: fixar a lista é por usuário, não por corretora.
- Próximo passo: fazer o teste passar; depois task 8 (pede o "pode", toca `lead_atribuicoes`).
```

Regras:

- **Ponteiro, não cópia.** Plano, spec, entrada do LOG e commit já existem; o bloco diz
  onde parou dentro deles e qual é o próximo passo literal. **Até 15 linhas por bloco.**
  Bloco que quer crescer é sinal de plano faltando ou tarefa que devia fechar.
- **Quem escreve:** o checkpoint. Substitui o bloco de mesmo título; cria se não existe.
  Vários blocos coexistem (sessões paralelas no mesmo repo).
- **Quem consome:** o início com foco declarado lê `Em andamento` **antes de tudo**. Se há
  bloco cujo título bate com o foco, **o briefing é esse bloco e mais nada**, e a sessão
  **apaga o bloco ao assumir** (edição de uma linha, sem commit próprio). Sem bloco que
  bata, o início segue o fluxo normal.
- **Quem limpa:** o fim do dia reescreve o STATE e **mantém só os blocos ainda em voo**,
  perguntando por cada um que não foi tocado no dia. O completo apaga blocos sem
  commit na branch há mais de 7 dias, avisando.
- Sem foco declarado, o briefing lista os títulos de `Em andamento` acima de `Agora` e
  propõe o primeiro.

O que **não** é: não substitui o fork ou o hand-off do app, que carregam a conversa
inteira. O bloco carrega 15 linhas. O README diz isso.

## 5. Pendências

### 5.1 Seções

`## Pendências` e `## Próxima sessão` da 1.x são substituídas por quatro seções:

| Seção | O que entra | Quem lê |
|---|---|---|
| `## Agora` | o que fazer em seguida, **ordenado**, até 7 itens | o briefing, inteira |
| `## Bloqueadas` | `(aguardando <quem>: <condição que destrava>)` | o briefing só diz quais mudaram |
| `## Adiadas` | pulada de propósito: `(adiada DD/MM: <motivo>; volta quando <condição>)` | ninguém, até a condição |
| `## Dívida` | sem contexto para retomar, uma linha cada | o completo, para podar |

Prioridade é a **posição em Agora**. Não há rótulo de prioridade.

### 5.2 Linha

```markdown
- <o que falta, com o ponteiro para retomar> [2h] (medida 20/10)
```

- `[2h]`, `[dia]`, `[semana]`: esforço estimado, **só em Agora**, opcional.
- `(medida DD/MM)` / `(suposta)`: mantido, **no fim da linha**. É o que menos pesa na
  hora de escolher, mas continua obrigatório: suposta entra no briefing como hipótese.
- `(desde DD/MM)` sai de Agora e Bloqueadas: a data de origem está no LOG. Fica só em
  Adiadas, como `(adiada DD/MM)`.

### 5.3 Movimentos

- **Fechar:** some na hora (regra "Durante a sessão" da 1.3, mantida).
- **Pular:** "deixa isso para depois" move de Agora para Adiadas **com motivo**. A skill
  não aceita adiar sem motivo; a condição de volta é opcional.
- **Destravar:** Bloqueada cuja condição foi satisfeita volta para Agora, na posição que o
  usuário disser; sem resposta, última.
- **Surgir:** pendência nova nasce em Agora (se vai ser feita) ou em Adiadas (se não).
  Nada nasce em Dívida.

### 5.4 Poda (só no completo)

1. Adiadas há mais de 4 semanas sem condição de volta: lista e pergunta uma vez, em
   bloco: "apago estas N?". Apagadas vão para a entrada do LOG do dia, bullet `Podadas`.
2. Dívida: mesma pergunta. O que fica, fica.
3. Bloqueadas com mais de 4 semanas: pergunta se ainda está sendo aguardada.
4. Blocos de Em andamento sem commit há 7 dias (§4).

Isso dá à regra "pendência que perdeu o contexto sai" o gatilho que faltava, sem virar
cobrança por idade no briefing diário.

## 6. Tamanho dos docs

### 6.1 STATE: cotas por seção

| Seção | Cota |
|---|---|
| cabeçalho (frontmatter, escopo, repos-irmãos) | 10 linhas |
| `## Em andamento` | 15 por bloco |
| `## Estado atual` | 12 bullets |
| `## Agora` | 7 itens |
| `## Bloqueadas`, `## Adiadas`, `## Dívida` | 1 linha por item |
| **total** | **80 linhas** (era 120) |

Cota por seção é verificável com `grep -c`; teto global não diz onde cortar. O fim do
dia confere e corta antes do commit; o que sai já está no LOG.

### 6.2 LOG: rotação mensal

- `SESSION_LOG.md` guarda **só o mês corrente**. No primeiro fim de sessão de um mês
  novo, as entradas do mês anterior vão para `docs/sessions/AAAA-MM.md` (criado se não
  existe), com `git mv` nunca: é append no arquivo do mês e corte no LOG, no mesmo commit.
- O início não muda: continua lendo `Resumo` e `Pendências` das duas últimas entradas.
  Se o LOG tem menos de duas (mês novo), completa com as últimas do arquivo anterior.
- Formato da entrada não muda. Comprimento da entrada continua livre: só é lido quando
  o foco pede.
- Entrada antiga sem `Resumo` continua valendo a regra das 10 linhas.

### 6.3 Três SKILL.md curtos e referências

```
skills/
  session-start/SKILL.md        ≤ 80 linhas: hook ou script, leitura, Em andamento, briefing (com/sem foco)
  session-checkpoint/SKILL.md   ≤ 50 linhas: confirmação, bloco Em andamento, sub-bloco no LOG, commit
  session-end/SKILL.md          ≤ 100 linhas: confirmação, síntese, STATE com cotas, entrada, extensão, poda, push
references/
  files.md            templates completos do STATE e do LOG, cotas, rotação
  adoption.md         primeira sessão; projeto que já registra sessões de outro jeito; migração 1.x → 2.0
  multi-repo.md       repos-irmãos
  branches.md         branch e worktree (§7)
  extension.md        ritual-extend.md e suas seções
```

A doc recomenda `SKILL.md` abaixo de 500 linhas e lembra que o corpo fica no contexto
a sessão inteira. Cada skill diz quando abrir cada referência. O que entra no contexto
por disparo cai de 3.400 palavras para o ritual que foi chamado. A `description` de cada
skill: uma frase do que faz e os gatilhos em lista; o limite de truncagem na listagem é
1.536 caracteres somando `description` e `when_to_use`.

## 7. Branch e worktree

- O STATE é **da branch principal**. Só o fim do dia e o completo na principal o
  reescrevem inteiro.
- Em branch de feature ou worktree: checkpoint e fim escrevem o LOG e o **próprio bloco**
  de `Em andamento`; não tocam Estado atual nem as seções de pendências.
- No merge para a principal, **STATE da principal vence** nos conflitos de
  `Estado atual`/pendências; blocos de `Em andamento` da branch entram. O LOG faz merge
  normal (entradas são append).
- O script de início imprime a branch e, se não é a principal, a linha "branch de
  feature: STATE só por Em andamento".

## 8. Hook e scripts no plugin

Conferido na doc em 21/10 (`code.claude.com/docs/en/hooks.md` e
`plugins/manifest-reference.md`): plugin traz hooks em `hooks/hooks.json` na raiz, com
o mesmo formato do `settings.json`; o caminho do plugin é `${CLAUDE_PLUGIN_ROOT}`
(muda a cada update, não guardar estado nele); o hook recebe `source` e `cwd` em JSON
no stdin; `source` pode ser `startup`, `resume`, `clear`, `compact` **ou `fork`**.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|compact",
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/session-hook.sh" }
        ]
      }
    ]
  }
}
```

- O plugin passa a trazer o hook `SessionStart` que hoje mora no `claude-config`:
  em `startup` e `compact`, se o `cwd` está num repo com `SESSION_STATE.md`, imprime a
  saída do script de início (pull só em `startup`). Sem STATE, não imprime nada.
  `fork` e `resume` não disparam: a conversa já carrega o contexto.
- No Windows o hook precisa chamar o `.ps1`; o `hooks.json` não escolhe por SO. Saída
  (§12.5): `session-hook.sh` fino que detecta `pwsh`/`powershell` e delega ao `.ps1`;
  sem PowerShell, roda o `session-start.sh`.
- `scripts/session-start.ps1` e `scripts/session-start.sh` com **a mesma saída**, linha
  a linha, para o `SKILL.md` descrever um formato só. O hook escolhe pelo SO.
- O script ganha: detecção de formato 1.x (linha "STATE no formato 1.x: migrar, ver
  references/adoption.md"), branch atual e aviso de branch de feature (§7).
- A extensão pessoal do autor (`ritual-extend.md`) fica só com o `vault-briefing` no
  início e o vault no fim. O hook do `claude-config` deixa de chamar o `session-start.ps1`.

## 9. Idioma

Skill, references, scripts e README em **inglês** (decisão de 21/10). README com uma
seção em PT-BR no fim. Os arquivos que a skill escreve nos repos (`SESSION_STATE.md`,
`SESSION_LOG.md`) seguem o idioma que o usuário usa: os cabeçalhos de seção são
**fixos em inglês** (`## In progress`, `## Now`, `## Blocked`, `## Deferred`, `## Debt`,
`## Current state`), porque o script e as cotas dependem deles; o conteúdo é livre.

Fechado em §12.1: só inglês nos cabeçalhos.

## 10. Versão e migração

**2.0.0.** Mudança de formato do STATE é quebra. O início detecta STATE 1.x (ausência de
`## Em andamento`/`## In progress` e presença de `## Próxima sessão`) e oferece migrar,
uma vez por repo:

1. `## Próxima sessão` → `## Now` (mesma ordem, até 7; o resto vai para Deferred com
   motivo "cortado na migração 2.0").
2. `## Pendências`: `(aguardando …)` → Blocked; o resto → Now (se também estava em
   Próxima sessão) ou Deferred (motivo "migração 2.0", sem condição de volta).
3. `(desde DD/MM)` → removido ou vira `(adiada DD/MM)` conforme a seção.
4. `## Em andamento` nasce vazio.
5. Cotas conferidas; o que sobra sai para a entrada do LOG do dia, bullet `Migração 2.0`.
6. Commit `docs: SESSION_STATE.md no formato session-ritual 2.0`.

Repos do autor (9 na Avex, 4 pessoais): migrados um por sessão, no primeiro início.
`avex-connect-hub` (STATE no vault, 137 linhas) migra à mão.

Manifests: `version` 2.0.0 nos dois; README "Atualizar" continua valendo.

## 11. Repo público

- `LICENSE` MIT (já está).
- `CHANGELOG.md` com 1.0 a 2.0, separado do `SESSION_LOG.md` pessoal.
- `tests/`: scripts de teste sem framework, no estilo dos do `claude-config`
  (`*.tests.ps1` e `*.tests.sh`, helper `expect`, exit 1 com falha), mesmo conjunto de
  cenários nos dois (repo limpo, ahead/behind, sem remote, pasta sem git, STATE 1.x,
  branch de feature, `master`, HEAD destacado, CRLF, repos-irmãos) e um teste de
  paridade que difere a saída dos dois scripts. O hook com teste de `source` e `cwd`.
  Descartado: Pester e bats, porque adicionam dependência e os testes existentes do
  autor já são sem framework.
- `skill-creator` (evals e description) e `/skill-doctor` antes da tag 2.0.0.
- README: o que é, instalar, os três níveis em três linhas, os dois arquivos, "por que
  há SESSION_STATE/LOG na raiz deste repo" (dogfooding), diferença para fork/hand-off
  do app, extensão, atualizar. Seção PT-BR no fim.
- `description` do frontmatter reescrita: uma frase do que é, gatilhos em lista curta.

## 12. Decisões fechadas em 21/10

1. **Cabeçalhos de seção nos repos só em inglês.** O script e as cotas dependem deles;
   o conteúdo das linhas é livre. A migração 1.x → 2.0 renomeia os cabeçalhos.
2. **Rotação do LOG por mês**, não por tamanho. Previsível e sem contagem.
3. **Cota de `Current state`: 12 bullets de até 2 linhas.** Bullet que precisa de mais
   vira ponteiro para o LOG.
4. **Checkpoint executa direto quando o foco seguinte vem na mesma frase** ("fecha essa
   e vamos para X"); confirma em uma linha quando não vem.
5. **Hook no Windows por `session-hook.sh` fino** que detecta `pwsh`/`powershell` e
   delega ao `.ps1`. Exige Git Bash no Windows, que vem com o Git. Descartado: `.cmd`
   ao lado, porque o `hooks.json` não escolhe por SO e dois comandos rodariam.
6. **Nome do plugin fica `session-ritual`**; comando longo (`/session-ritual:session-end`)
   aceito, porque o gatilho principal é a frase. Descartado: renomear para `ritual`,
   que mudaria instalação e repo público.

## 13. Fora desta spec

- O plano de implementação (ordem das tarefas, o que dá para fazer em paralelo).
- Mudanças no `claude-config` além de tirar o `session-start.ps1` do hook.
- Migração dos repos da Avex: é uso, não desenvolvimento.
