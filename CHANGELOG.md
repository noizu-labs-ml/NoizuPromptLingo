# Changelog

## 2026-10-26
- feat(analytics): enable GA4 gtag via chart values (`analytics.ga.measurementId: G-ZZHF0T39QD`) — PR

## 2026-10-18
- chore(chart): dedupe duplicate image `tag:` keys in helm/npl-mcp/values.yaml — stale sha-5441c35 lines under backend/frontend.image (each bump-chart append relied on last-key-wins) and the unused top-level npl-mcp.image stanza removed; helm template output byte-identical before/after (#105)
- feat(api): W7 :mcp_key_optional plane extended to personas index + ticket show — org-scoped GETs accept a valid MCP API key (owner-context 200 path), anonymous/JWT behavior unchanged (#99) → main (#100)
- feat(frontend): /app/<orgId>/npl-conventions is public for all orgs — proxy exempts the path from the token gate (public cache, Vary: Cookie); page already degrades gracefully for anonymous visitors (#102)
- feat(auth): Google + GitHub SSO beside Authentik — sign-in buttons only (no local passwords), env-gated providers advertised via GET /api/v1/auth/config; navbar mounts the tobor-kit noizu-auth console (dropdown sign-in / modal signup) with plain-anchor fallback (#102)

## 2026-10-17
- fix(frontend): /keyboard — symbol picker loads the v3 unicode-db (chars tuples + descriptions map) with group filter + search + clipboard fallback; page restyled onto --pg-* dark-mode tokens (WCAG AA); Markdown/SemText syntax toggle with insert palette (#95) → stage (#96) → main (#97)
- fix(frontend): home copy names the agent platform agent-kit, links agentonomi.com, drops tobor from prose (#95) → stage (#96) → main (#97)
- feat(frontend): /reference grouped tag sidebar (sticky desktop, collapsible mobile); /reference/npl-declaration gains both syntax forms + YAML examples (#95) → stage (#96) → main (#97)
- feat(frontend): /reference — NPL tag reference (20 npl-* tags, attributes, examples) linking to semtext.dev rendered-form pages (#91) → stage (#92) → main (#93)
- feat(frontend): add annotate page-comments widget to root layout (site-wide, prompt-lingo) (#87) → stage (#88) → main (#89)

## 2026-10-13
- chore(auth): replace retired auth.noizu.com references with auth.derobot.is (#86)
