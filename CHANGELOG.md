# Changelog

## 2026-11-11
- feat(npl): spec wave 1 — `conventions/*.yaml`: component `aliases:` on 12 pumps (cot/ref/rubric/… heal dead ids), `section_aliases: {fences: prompt-sections}` in npl.yaml, instructional entries confirmed slug-stable; catalog fixes (pumps `<npl-ref>` tag + runtime-flags `thread:` examples + `best-practice` type, syntax examples use real section types + bogus `require:` dropped on highlight/attention, special-sections stray `"` removed, declarations `specialist` regex + NPL@1.0 examples, artifact syntax fenced to match examples, todo-task ` | ` spacing, media prefixes reframed tool-backed); fences purged from CLAUDE/AGENTS/README/docs/agents, agents corpus repointed to canonical `NPLLoad` expressions (check-npl-ids 0 errors / 0 warnings), deployment surfaces synced to the repointed corpus (`.claude/agents/`, `.codex/agents/`, `commands/` + `.claude/commands/`, `.agents/skills/`), `scripts/check-conventions-parity.sh` added and `backend/priv/conventions/` re-synced
- feat(tools): Accords/Trinity compliance detector — `tools/accords_compliance/` (stdlib-only pure detection core + Claude Code Stop-hook wiring, recursion guard, per-session cooldown, optional env-gated decision-model confirmation); verbatim Accords/Trinity protocol reference at `docs/reference/protocols/`; 9-variant calibration harness ported to pytest (`tests/test_accords_compliance.py`, 44 tests) (#113)

## 2026-10-28
- docs: add AGENT-README.md (agent orientation)

## 2026-10-26
- feat(analytics): enable GA4 gtag via chart values (`analytics.ga.measurementId: G-ZZHF0T39QD`) — PR #109
- docs: doc-sweep (pointers-check, layout, arch, schema, threat-model) — seeded .meta/pointers.yaml with 9 entry anchors (#112); arch Elixir version corrected to ~> 1.18; schema Ecto-migration lists gained browser-capture + prompt-builder/showcase (2026-09); layout + threat-model verified current, no changes needed

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
