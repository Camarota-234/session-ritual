---
ultima-sessao: 2026-09-28
ultimo-fechamento-completo: 2026-09-28
---

# Estado da sessão — session-ritual

**Escopo deste arquivo:** o plugin público `session-ritual` (skill + script + manifests).
A extensão pessoal do autor mora em `Camarota-234/claude-config`
(`ritual-extend.md`), e não é parte deste repo.

## Estado atual
- **v1.3.0** (28/09), cinco mudanças sobre a 1.2.0, todas vindas de ler o FGSD
  (`VancheeZze/FGSD`) contra os STATE/LOG reais da Avex:
  - **Início com foco declarado**: primeira mensagem com foco não tem parada; o
    briefing encolhe para o que toca o foco e diz se ele estava planejado. Sem foco, o
    briefing propõe o item 1 de "Próxima sessão" em vez de perguntar em aberto.
  - **Script detecta trabalho depois do último `/session-end`**: compara
    `ultima-sessao` com `git log --since` e imprime os commits que o STATE não conhece.
    Testado em 28/09: Constance (nenhum commit depois, linha ausente), pasta sem git,
    e este repo após o commit da 1.3.0 (deve mostrar 1).
  - **Pendência que fecha sai do STATE na hora** (seção "Durante a sessão"); o
    checkpoint leva as linhas apagadas junto, sem reescrever o resto.
  - **Bullet `Resumo` obrigatório em cada entrada do LOG**, e o início lê só `Resumo`
    e `Pendências` das duas últimas entradas (entrada antiga sem `Resumo`: 10 linhas).
  - **Data em pendência é contexto, não cobrança**: `(desde DD/MM)` e
    `(aguardando <quem>)`; a regra dos 14/28 dias saiu. Ordem de "Próxima sessão" manda.
- A 1.2.0 fechou sessões reais no Constance (10/09, dois repos) — pendência de 08/09
  fechada.

## Pendências
- **(medida, desde 08/09)** `/session-start` **sem** `ritual-extend.md` nunca foi
  rodado — renomear o arquivo temporariamente é o teste de que nada do vault vaza.
- **(medida, desde 08/09)** `skill-creator` (evals + description) não passou neste repo.
- **(suposta, desde 16/08)** A `description` do frontmatter pode não aparecer inteira
  na listagem de skills.
- **(medida, desde 28/09)** A 1.3.0 está instalada (cache `1.3.0`, reinstalada em
  28/09) mas não abriu nem fechou sessão real pela skill: o fechamento de 28/09 seguiu
  o `SKILL.md` à mão, porque a sessão nasceu com a 1.2.0 carregada. O modo "foco
  declarado" e o `Resumo` no LOG só se provam em uso.

## Próxima sessão
1. Usar a 1.3.0 nos repos da Avex (já reinstalada); anotar se o briefing com foco
   ficou curto demais e se o aviso de commits depois do fechamento disparou certo.
2. Rodar a validação sem `ritual-extend.md`.
3. Passar o `skill-creator` antes de divulgar aos colegas.
