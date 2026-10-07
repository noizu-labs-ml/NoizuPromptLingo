# Threat Model Summary — NoizuPromptLingo

Condensed companion to [THREAT-MODEL.md](THREAT-MODEL.md).

## Posture

Public, mostly-unauthenticated corpus service (NPL syntax MCP `/mcp`, read-only VFS `/vfs`, public REST + prompt-builder) with a signed-in conventions admin (Authentik OIDC) and inherited tobor admin gateways still routed. Crown jewels: Infisical secrets, OAuth AS signing keys, MCP API keys, data stores, LLM spend.

## Boundaries

Internet → edge (nginx / K8s ingress, TLS) → Phoenix process → Postgres/Redis/Weaviate/S3/LLM providers; OAuth AS tokens and companion tools (local machines) cross the outer boundary.

## Register (12 entries)

5 mitigated · 4 partial · 1 open · 2 accepted. Highlights:

- **T-003 (High, mitigated)** — prompt-builder LLM abuse capped by IP+session rate/budget config
- **T-006 (High, OPEN)** — inherited custom/set/mock MCP gateways still publicly routed; decide keep-or-disable post-split
- Partials: bare `/mcp` and `/vfs` lack per-client quotas (T-001/T-002); curl-to-bash installer has no signature pinning (T-007)
- Site-approval OAuth token (`sub=site:npl`) asserts no user identity (T-004, changeset 085)

## Residual risk

Open endpoints accept bandwidth/CPU abuse (corpus is public by intent); inherited PBAC enforcement assumed carried over, not re-audited for the syntax-only deployment. Out of scope: agent-kit-mcp internals, local-only Python fleet.
