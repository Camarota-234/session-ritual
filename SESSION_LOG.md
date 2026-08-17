# Log de sessões — session-ritual

## 2026-08-16 — Nasce o plugin: extração do ritual genérico do claude-config
- **Feito:** SKILL.md (Início/Fim, ponto de extensão, templates), manifests v1.0.0, README; repo público criado e pushado; instalado localmente. No `claude-config`: `session-start`/`session-end` removidas, `ritual-extend.md` criado (vault: pull, decisoes.md, export do grafo, dois commits, `update-index --refresh`), `vault-export.py` movido para `scripts/`, `global-CLAUDE.md` e README ajustados, bump 2.0.0.
- **Decisões:** repo/marketplace próprios em vez de segundo plugin no claude-config; extend global em `~/.claude/ritual-extend.md` em vez de por projeto; vault fora da base (não configurável); sem detecção de `HISTORICO.md` legado — projetos migram. Detalhes em `C:\vault\pessoal\session-ritual\decisoes.md`.
- **Erros:** o push do `claude-config` bateu em 4 commits da outra máquina (v1.4.2, session-end com export do grafo e stat cache) que a versão em cache 1.2.0 não tinha; resolvido no rebase levando tudo para o extend.
- **Pendências:** validar sem/com extend; checar description na listagem; migrar projetos sob demanda.
