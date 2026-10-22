---
ultima-sessao: 2026-10-22
ultimo-fechamento-completo: 2026-10-21
---

# Estado da sessão — session-ritual

**Escopo deste arquivo:** o plugin público `session-ritual` (skill + script + manifests).
A extensão pessoal do autor mora em `Camarota-234/claude-config`
(`ritual-extend.md`), e não é parte deste repo.

## Estado atual
- **v1.4.0** (22/10): seção `## A exercitar` no STATE — o que foi entregue e nunca
  rodou, cada item com a prova que o fecha; sai na hora em que a prova acontece; o
  briefing sem foco lista a seção com contagem, o com foco só o que o foco pode provar.
  `id` saiu do `marketplace.json`; `claude plugin validate .` passou sem aviso (22/10).
  Item 1 da rodada de melhorias de 15/10 (lista no STATE do `claude-config`).
- **v1.3.1** (15/10, `9f5cece`): o passo 1 do início usa a saída de um hook
  `SessionStart` quando ela já está no contexto (bloco `## Repositório — <data>`). O
  hook é da extensão pessoal (`claude-config`, `session-hook.ps1`).
- **v1.3.0** (28/09, `1190a43`): início com foco declarado ou propondo o item 1;
  script avisa de commits depois do último `/session-end`; pendência fechada sai na
  hora; `Resumo` obrigatório no LOG; data em pendência é contexto, não cobrança.
  Fim pela skill 1.3.x rodou em 15/10 (três repos); início com foco declarado rodou
  em 22/10 (sessão desta versão: briefing curto, sem parada).
- **Licença MIT e topics** (21/10, `a015ddf`), conferido pela API do GitHub.

## A exercitar
- `/session-start` **sem** `ritual-extend.md` — **prova:** com o arquivo renomeado, o
  briefing sai sem nenhuma linha do vault nem do hook pessoal (desde 08/09).
- Passo 1 pulado pelo hook (1.3.1) — **prova:** sessão aberta num repo de `C:\dev` cujo
  briefing cola o bloco `## Repositório` do hook sem rodar o `session-start.ps1` de
  novo (desde 15/10).
- Seção `## A exercitar` (1.4.0) — **prova:** um fim de sessão pela skill 1.4.0 num repo
  da Avex que migra um *não exercitado* para cá, e um briefing sem foco que lista a
  seção com a contagem (desde 22/10).

## Pendências
- **(medida, desde 08/09)** `skill-creator` (evals + description) não passou neste repo.
- **(suposta, desde 16/08)** A `description` do frontmatter pode não aparecer inteira
  na listagem de skills.
- **(medida, desde 15/10)** O notebook segue na 1.3.0.

## Próxima sessão
1. Abrir uma sessão nova (o autor vai testar em seguida, 22/10) e conferir se a 1.4.0
   carregou e se o briefing mostra `### A exercitar (N)`.
2. Seguir a rodada de 15/10 no `claude-config`: rotação do `SESSION_LOG.md` por mês,
   passo "o que a sessão gerou fora do repo?" no fim leve, enxugar o `SKILL.md`
   (435 linhas; adoção e multi-repo para `references/`).
3. Passar o `skill-creator` antes de divulgar aos colegas.
