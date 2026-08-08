---
id: M4
name: "Growth Studio & Discovery"
sequence: 4
depends_on: [M3]
lanes: 4
stories: [US-029, US-030, US-031, US-032, US-033, US-034, US-035, US-036, US-065, US-066, US-067, US-068, US-069, US-070, US-071, US-072]
---

# M4 — Growth Studio & Discovery

This milestone delivers the applied-productivity surfaces that run on a configured platform: the
**growth/creative studio** (campaigns and ad groups, generated ad-copy variants, landing-page
drafts, domain tracking, competitor and keyword research, and published creative assets) and the
**discovery** surface (list/search/semantic tool discovery, tool definition and contextual help,
the NPL glyph codex, wiki search, and custom-field ticket filtering). It is sequenced after M3
because creative generation consumes the LLM and media provider config frozen there, and wiki
search consumes the M2 wiki content and recall interface.

## Entry criteria

- M3's exit criteria are met — an LLM provider and a media provider are configurable, and the
  provider-config contract from `M3/L3.A` is merged.
- The M2 semantic-recall interface (`domains/memory` over pgvector) and wiki content are available
  for the discovery lane to index.

## Exit criteria

- `mix compile --warnings-as-errors` and `npm run build` both exit 0.
- A campaign with an ad group can be created, ad-copy variants generated and approved/rejected, and
  a creative asset generated and its active output published — demonstrated by
  `frontend/e2e/studio.spec.ts` passing (exit 0). Generation uses a configured media provider from
  M3 (media path exercised, not stubbed).
- Tools can be listed, searched by keyword and by semantic intent, and a tool's full definition and
  contextual help retrieved — demonstrated by `frontend/e2e/search.spec.ts` passing (exit 0).
- The NPL glyph codex and wiki keyword search return results over seeded content, and tickets can
  be filtered by custom field values.
- All 16 stories assigned to this milestone have their acceptance criteria checked off.

## Transition checklist

- [ ] `backend/` compiles clean; `frontend/` builds clean
- [ ] `studio.spec.ts` and `search.spec.ts` pass (exit 0)
- [ ] Creative generation exercises a real configured media provider
- [ ] Glyph-codex, wiki-search, and ticket-filter return results over seeded content
- [ ] All 16 stories' acceptance criteria met
- [ ] M5's Entry criteria reviewed and satisfied

## Worker lanes

### L4.A — Studio & Search Contracts
- **Zone / exclusive paths:** `backend/priv/repo/migrations/` (campaign/asset/market tables +
  search indexes), `frontend/src/types/{campaigns,studio,search}.ts`,
  `frontend/src/config/selectors/{campaigns,studio,search}.ts`, and the media-generation-job spec.
- **Mission:** Freeze the campaign/creative schema, the media-generation job contract, and the
  tool-discovery contract before the feature lanes start.
- **Tasks:**
  - T4.A.1 — [contract] Migrations + schema for campaigns, ad groups, ad copy, landing pages,
    competitors, keywords, domains, and asset entries/outputs.
  - T4.A.2 — [contract] The media-generation job contract (consuming M3's media-provider config) and
    the tool-discovery contract (catalog, search, definition, help, summary).
  - T4.A.3 — [contract] `data-cy` selectors for the studio and search screens.
- **Stories delivered:** none — enablement only.
- **Contracts:** provides the generation-job + discovery contracts. Consumes M3's provider-config
  contract. Consumed by L4.B, L4.C, L4.D.

### L4.B — Growth & Creative Studio
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/domains/{campaigns,market,assets}/`,
  `marketing_content.ex`, `media/transform.ex`, web campaign/asset/media controllers, and
  `frontend/src/app/{campaigns,studio,assets}/`.
- **Mission:** The full-stack campaign + creative-asset vertical (this is the media-on generation
  surface).
- **Tasks:**
  - T4.B.1 — `M` Create a campaign with an ad group (US-029); generate ad-copy variants (US-030);
    approve/reject a variant (US-031); generate and publish a creative asset (US-036).
  - T4.B.2 — `S` Generate a landing-page draft (US-032); research competitors for a market segment
    (US-034); research and track keywords (US-035).
  - T4.B.3 — `C` Track a domain name against a campaign (US-033).
- **Stories delivered:** US-029, US-030, US-031, US-032, US-033, US-034, US-035, US-036.
- **Contracts:** consumes M3's media/LLM provider config and L4.A generation-job contract. Its
  published assets are indexed by L4.C.

### L4.C — Search & Discovery
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/tools/` (catalog, tool_search,
  tool_definition, tool_help, tool_summary, mcp_overview, npl_load, npl_spec),
  `domains/unicode_codex/`, the wiki-search read path, web `npl_controller.ex`, and
  `frontend/src/app/{search,tools,codex}/`.
- **Mission:** The full-stack tool/glyph/wiki discovery vertical over the M2 recall interface.
- **Tasks:**
  - T4.C.1 — `M` List all tools on an MCP server (US-065); search tools by keyword (US-066); search
    tools by semantic intent (US-067).
  - T4.C.2 — `S` Get a tool's full definition (US-068); search the NPL glyph codex (US-070); search
    the wiki by keyword (US-071); filter tickets by custom field values (US-072).
  - T4.C.3 — `C` Get contextual help for a tool (US-069).
- **Stories delivered:** US-065, US-066, US-067, US-068, US-069, US-070, US-071, US-072.
- **Contracts:** consumes L4.A discovery contract, M2 recall interface (supports US-067), M2 wiki
  content (supports US-071), and M1 tickets (supports US-072).

### L4.D — Studio & Search QA & Integration
- **Zone / exclusive paths:** `frontend/e2e/{studio,search}.spec.ts`,
  `backend/test/noizu_prompt_lingua/{campaigns,market,assets,tools,unicode_codex}/`.
- **Mission:** Prove generation and discovery compose, keyed to frozen selectors.
- **Tasks:**
  - T4.D.1 — [contract] Write `studio.spec.ts` and `search.spec.ts` against L4.A selectors + stub.
  - T4.D.2 — Backend test asserting a generated asset's active output is retrievable and indexed.
- **Stories delivered:** none — enablement only.
- **Contracts:** consumes L4.A selectors + sibling outputs.

## Cross-lane integration tasks

- **T4.X.1** (owned by L4.D) — Generate a creative asset (L4.B) using an M3-configured media
  provider, publish its active output, then find that asset and its parent campaign via search
  (L4.C) — proving the studio→index→discovery flow composes end-to-end with a real provider.
