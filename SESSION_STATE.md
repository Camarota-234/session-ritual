---
ultima-sessao: 2026-10-21
ultimo-fechamento-completo: 2026-10-21
---

# Estado da sessão — session-ritual

**Escopo deste arquivo:** o plugin público `session-ritual` (skill + script + manifests).
A extensão pessoal do autor mora em `Camarota-234/claude-config`
(`ritual-extend.md`), e não é parte deste repo.

## Estado atual
- **Licença MIT e topics** (21/10, commit `chore: licença MIT`): `LICENSE` na raiz,
  `"license": "MIT"` no `plugin.json`, seis topics no GitHub (`claude-code`,
  `claude-code-skill`, `ai-agents`, `developer-tools`, `productivity`, `powershell`).
  Conferido pela API (`license: MIT`) e por `claude plugin validate .` (passou).
- **v1.3.1** (15/10, `9f5cece`): o passo 1 do início usa a saída de um hook
  `SessionStart` quando ela já está no contexto (bloco `## Repositório — <data>`), em vez
  de rodar o script de novo. O hook é da extensão pessoal (`claude-config`,
  `session-hook.ps1`); o plugin só reconhece a saída. Instalada no pc em 15/10.
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
- **(medida, desde 28/09)** O fim pela skill 1.3.x rodou em 15/10 (cache `1.3.1`,
  três repos: um completo, dois leves). O início com "foco declarado" e o passo 1
  pulado pelo hook ainda não foram vistos numa sessão real.
- **(medida, desde 15/10)** O notebook segue na 1.3.0.
- **(medida, desde 21/10)** `claude plugin validate .` avisa campo desconhecido `id` em
  `marketplace.json:3` (ignorado ao carregar). Tirar na próxima versão.

## Próxima sessão
1. Usar a 1.3.0 nos repos da Avex (já reinstalada); anotar se o briefing com foco
   ficou curto demais e se o aviso de commits depois do fechamento disparou certo.
2. Rodar a validação sem `ritual-extend.md`.
3. Passar o `skill-creator` antes de divulgar aos colegas.
