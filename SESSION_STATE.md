---
ultima-sessao: 2026-09-08
ultimo-fechamento-completo: 2026-09-08
---

# Estado da sessão — session-ritual

**Escopo deste arquivo:** o plugin público `session-ritual` (skill + script + manifests).
A extensão pessoal do autor mora em `Camarota-234/claude-config`
(`ritual-extend.md`), e não é parte deste repo.

## Estado atual
- **v1.2.0** (08/09), três mudanças sobre a 1.1.0 de 24/08:
  - **fim leve por padrão** (STATE, LOG, extensão leve, commit); **fim completo** por
    pedido ou quando `ultimo-fechamento-completo` passa de 7 dias. Graphify saiu do
    ritual.
  - **`/session-checkpoint`**: sub-bloco `### checkpoint HH:MM` na entrada do dia do
    LOG, commit, STATE intocado; absorvido no `/session-end` seguinte.
  - **`scripts/session-start.ps1`** faz pull, `status -sb`, ahead/behind e últimos
    commits do repo e dos repos-irmãos (lidos da linha `**Repos-irmãos:**`). Testado
    em 08/09 em quatro cenários (repo com irmão, repo com pull, pasta sem git, caminho
    inexistente).
  - **Regras de dieta do STATE**: teto de 120 linhas, trava permanente vai ao
    `CLAUDE.md`, item fechado some, evidência vira ponteiro.
- Extensão com três seções (`## Início`, `## Fim leve`, `## Fim completo`); arquivo
  antigo só com `## Fim` vale como completo.
- Exercitada de ponta a ponta na 1.1.0 (24/08, dois repos do SegurIA). A 1.2.0 ainda
  **não** fechou nenhuma sessão real.

## Pendências
- **(medida)** A 1.2.0 nunca rodou um `/session-end` real — a primeira sessão nos
  repos da Avex é o teste.
- **(medida)** `/session-start` **sem** `ritual-extend.md` nunca foi rodado — renomear
  o arquivo temporariamente é o teste de que nada do vault vaza para quem não tem a
  extensão.
- **(medida)** `skill-creator` (evals + description) não passou neste repo. Combinado
  para depois de 2–3 usos reais da 1.2.0.
- **(suposta)** A `description` do frontmatter pode não aparecer inteira na listagem
  de skills — nunca reconferido desde 16/08.

## Próxima sessão
1. Usar a 1.2.0 por uma semana nos repos da Avex e anotar o que doeu (o teto de 120
   apertou? o checkpoint foi usado? o completo disparou na data certa?).
2. Rodar a validação sem `ritual-extend.md`.
3. Passar o `skill-creator` antes de divulgar aos colegas.
