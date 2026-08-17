# Estado da sessão — session-ritual

## Estado atual
- v1.0.0 publicada em `Camarota-234/session-ritual` e instalada localmente via marketplace próprio.
- Uma skill, dois triggers (`/session-start`, `/session-end` + linguagem natural), zero config.
- Ponto de extensão `~/.claude/ritual-extend.md` (seções `## Início`/`## Fim`) funcionando: o autor usa a mesma skill dos colegas, com o vault entrando só pela extensão.
- graphify condicional por presença de `graphify-out/`.

## Pendências
- Validar no uso real: um `/session-start` **sem** `ritual-extend.md` (renomear temporariamente) para garantir que nada de vault vaza; e um `/session-end` num projeto migrado com o extend ativo.
- Confirmar que a `description` do frontmatter aparece na listagem de skills (na primeira carga apareceu só o nome — pode ser truncamento da lista ou o YAML com aspas escapadas).
- Migrar os projetos ativos do autor sob demanda: `HISTORICO.md` → `SESSION_LOG.md`, seções "Estado atual"/"Próxima sessão" do `CLAUDE.md` → `SESSION_STATE.md`.

## Próxima sessão
- Rodar as duas validações acima e ajustar o SKILL.md se algo vazar ou não disparar.
- Se a description não estiver carregando, trocar as aspas escapadas por um bloco YAML `>-`.
- Depois de 2–3 usos reais: passar o `skill-creator` (evals + otimização de description) antes de divulgar aos colegas.
