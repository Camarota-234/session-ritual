---
ultima-sessao: 2026-08-24
---

# Estado da sessão — session-ritual

**Escopo deste arquivo:** o plugin público `session-ritual` (skill + manifests).
A extensão pessoal do autor mora em `Camarota-234/claude-config`
(`ritual-extend.md`), e não é parte deste repo.

## Estado atual
- **v1.1.0**, com as seis melhorias de 24/08 vindas do primeiro uso real em dois
  repos de produção. v1.0.0 publicada em 16/08.
- Uma skill, dois triggers (`/session-start`, `/session-end` + linguagem natural),
  zero config.
- Ponto de extensão `~/.claude/ritual-extend.md` (seções `## Início`/`## Fim`)
  funcionando: o autor usa a mesma skill dos colegas, com o vault entrando só pela
  extensão.
- graphify condicional por presença de `graphify-out/`.
- **Exercitada de ponta a ponta em 24/08** nos repos `segurIA` e
  `seguro-mente-assistida`: adoção sobre log legado, dois STATE com fronteira
  explícita, e as entradas de fim de sessão já escritas no formato novo.

## Pendências
- **(suposta)** A `description` do frontmatter pode não aparecer na listagem de
  skills — na primeira carga apareceu só o nome. Nunca reconferido; pode ser
  truncamento da lista ou o YAML com aspas escapadas.
- **(medida)** Um `/session-start` **sem** `ritual-extend.md` nunca foi rodado —
  renomear o arquivo temporariamente é o teste de que nada do vault vaza para quem
  não tem a extensão.
- **(medida)** O `skill-creator` (evals + otimização de description) não passou
  neste repo. Combinado para depois de 2–3 usos reais; hoje foram os dois
  primeiros.

## Próxima sessão
1. Rodar a validação sem `ritual-extend.md` e ajustar o `SKILL.md` se algo vazar.
2. Conferir a description na listagem; se não estiver carregando, trocar as aspas
   escapadas por um bloco YAML `>-`.
3. Passar o `skill-creator` antes de divulgar aos colegas.
