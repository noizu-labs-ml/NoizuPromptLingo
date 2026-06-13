# Component Implementation Sequence

Prioritized build order for the 76 components in tobornalp.com. Organized into 7 tiers — each tier's components can be built in parallel, but a tier must complete before the next begins (dependency constraint).

---

## Dependency Graph (Components That Block Others)

```
badge ──────────────► item-card ──────► kanban-column
                    ► project-card
                    ► agent-card
                    ► okr-node
                    ► template-card
                    ► time-block-card ► daily-timeline
                    ► deploy-summary
                    ► linked-items-section
                    ► approval-chain-display ► deploy-summary

health-indicator ──► project-card
progress-bar ──────► project-card
                   ► okr-node
stale-indicator ──► okr-node
notification-badge ► sidebar-nav
error-budget-gauge ► slo-card

confidence-score ──► ai-suggestion-list
                   ► anomaly-cluster-card
                   ► duplicate-suggestion-panel
                   ► ai-failure-analysis
accept-reject-controls ► ai-suggestion-list
rationale-popover ─► ai-suggestion-list

rich-text-editor ──► ai-draft-editor
voice-capture-button ► inline-metadata-input ► quick-capture-overlay
                     ► quick-capture-overlay
```

---

## Usage Heatmap (Top 20 Most-Referenced Components)

| # | Component | Screens | Depended On By |
|---|-----------|---------|----------------|
| 1 | filter-bar | 17 | — |
| 2 | badge | 11 | 9 components |
| 3 | rich-text-editor | 10 | 1 component |
| 4 | data-table | 9 | — |
| 5 | ai-suggestion-list | 9 | — |
| 6 | metric-card | 9 | — |
| 7 | item-card | 8 | 1 component |
| 8 | priority-sorted-list | 8 | — |
| 9 | activity-timeline | 8 | — |
| 10 | time-series-chart | 8 | — |
| 11 | wizard-stepper | 8 | — |
| 12 | health-indicator | 7 | 1 component |
| 13 | rationale-popover | 7 | 1 component |
| 14 | accept-reject-controls | 7 | 1 component |
| 15 | progress-bar | 6 | 2 components |
| 16 | split-panel | 6 | — |
| 17 | collapsible-panel | 6 | — |
| 18 | export-dialog | 6 | — |
| 19 | confirmation-modal | 5 | — |
| 20 | confidence-score | 5 | 4 components |

---

## Implementation Tiers

### Tier 0 — Atomic Indicators (no dependencies, highest reuse)

The foundation. Every other tier depends on at least one of these. All are low complexity — small, stateless, render-only.

| # | Component | Complexity | Screens | Est. |
|---|-----------|------------|---------|------|
| 45 | **badge** | low | 11 | 2h |
| 03 | **health-indicator** | low | 7 | 1h |
| 04 | **progress-bar** | low | 6 | 2h |
| 44 | **confidence-score** | low | 5 | 1h |
| 48 | **notification-badge** | low | 2 | 1h |
| 47 | **stale-indicator** | low | 4 | 1h |
| 51 | **risk-flag** | low | 3 | 1h |
| 46 | **conflict-warning** | low | 7 | 1h |
| 49 | **offline-sync-indicator** | low | 1 | 1h |
| 10 | **streak-counter** | low | 2 | 1h |
| 16 | **countdown-timer** | low | 2 | 1h |
| 57 | **output-rating-widget** | low | 2 | 2h |

**12 components · ~15h · Unblocks: Tiers 1-6**

---

### Tier 1 — Cards + Core Navigation (depends on Tier 0 atomics)

Cards are the primary content unit — nearly every screen uses at least one. Navigation components have no dependencies and unlock screen assembly.

| # | Component | Complexity | Deps | Screens | Est. |
|---|-----------|------------|------|---------|------|
| 18 | **item-card** | medium | badge | 8 | 4h |
| 07 | **metric-card** | low | — | 9 | 2h |
| 19 | **project-card** | medium | health-indicator, progress-bar, badge | 1 | 3h |
| 20 | **agent-card** | medium | badge | 2 | 3h |
| 24 | **okr-node** | medium | progress-bar, badge, stale-indicator | 2 | 3h |
| 25 | **template-card** | low | badge | 3 | 2h |
| 50 | **approval-chain-display** | medium | badge | 2 | 3h |
| 55 | **accept-reject-controls** | low | — | 7 | 2h |
| 53 | **rationale-popover** | low | — | 7 | 2h |
| 27 | **filter-bar** | medium | — | 17 | 4h |
| 26 | **sidebar-nav** | medium | notification-badge | 5 | 4h |
| 28 | **tab-bar** | low | — | 5 | 2h |
| 29 | **breadcrumb** | low | — | 4 | 1h |
| 30 | **split-panel** | medium | — | 6 | 3h |
| 32 | **collapsible-panel** | low | — | 6 | 2h |
| 33 | **swimlane-toggle** | low | — | 1 | 1h |

**16 components · ~45h · Unblocks: Tiers 2-6**

---

### Tier 2 — Lists, Tables, and Core Inputs (depends on cards)

Container components that hold Tier 1 cards. Core form inputs needed by nearly every creation/edit screen.

| # | Component | Complexity | Deps | Screens | Est. |
|---|-----------|------------|------|---------|------|
| 01 | **priority-sorted-list** | medium | — | 8 | 4h |
| 11 | **kanban-column** | medium | item-card | 2 | 4h |
| 74 | **data-table** | high | — | 9 | 8h |
| 75 | **grouped-list** | low | — | 4 | 2h |
| 02 | **activity-timeline** | medium | — | 8 | 4h |
| 76 | **linked-items-section** | medium | badge | 6 | 3h |
| 35 | **search-input** | medium | — | 7 | 3h |
| 38 | **tag-input** | low | — | 6 | 2h |
| 37 | **date-picker** | medium | — | 4 | 4h |
| 43 | **voice-capture-button** | medium | — | 2 | 3h |
| 39 | **inline-metadata-input** | medium | voice-capture-button | 2 | 4h |
| 31 | **wizard-stepper** | medium | — | 8 | 3h |
| 73 | **action-items-editor** | medium | — | 5 | 4h |
| 69 | **methodology-selector** | low | — | 1 | 2h |

**14 components · ~50h · Unblocks: Tiers 3-6**

---

### Tier 3 — Complex Inputs + AI Assist (depends on Tiers 1-2)

The heavy input components and the AI suggestion pipeline. These unlock the AI-powered screens that differentiate the product.

| # | Component | Complexity | Deps | Screens | Est. |
|---|-----------|------------|------|---------|------|
| 34 | **rich-text-editor** | high | — | 10 | 12h |
| 52 | **ai-suggestion-list** | high | accept-reject-controls, rationale-popover, confidence-score | 9 | 8h |
| 36 | **rule-builder** | high | — | 3 | 8h |
| 41 | **capacity-adjuster** | medium | — | 1 | 3h |
| 42 | **weight-slider** | medium | — | 2 | 3h |
| 40 | **permission-matrix** | high | — | 3 | 6h |
| 58 | **ai-failure-analysis** | medium | confidence-score | 3 | 4h |
| 56 | **agent-activity-feed** | high | — | 2 | 6h |

**8 components · ~50h · Unblocks: Tiers 4-6**

---

### Tier 4 — Composite Components + Overlays (depends on Tier 3)

Higher-order components built from Tier 3 primitives. Modals and overlays that orchestrate multi-step interactions.

| # | Component | Complexity | Deps | Screens | Est. |
|---|-----------|------------|------|---------|------|
| 54 | **ai-draft-editor** | high | rich-text-editor | 9 | 6h |
| 60 | **quick-capture-overlay** | medium | inline-metadata-input, voice-capture-button | 1 | 4h |
| 61 | **duplicate-suggestion-panel** | medium | confidence-score | 2 | 3h |
| 59 | **confirmation-modal** | medium | — | 5 | 3h |
| 62 | **export-dialog** | medium | — | 6 | 4h |

**5 components · ~20h · Unblocks: Tiers 5-6**

---

### Tier 5 — Visualizations (can parallel with Tier 3-4 if no deps)

Chart and graph components. These are self-contained — they don't depend on other app components, only on chart libraries. Could be parallelized with Tiers 3-4 by a separate dev stream.

| # | Component | Complexity | Deps | Screens | Est. |
|---|-----------|------------|------|---------|------|
| 05 | **time-series-chart** | high | — | 8 | 8h |
| 14 | **error-budget-gauge** | medium | — | 1 | 4h |
| 08 | **dependency-graph** | high | — | 4 | 10h |
| 17 | **score-distribution-chart** | medium | — | 3 | 4h |
| 06 | **heatmap-grid** | medium | — | 1 | 4h |
| 13 | **uptime-bar** | low | — | 2 | 2h |
| 15 | **pipeline-stage-indicator** | medium | — | 3 | 3h |
| 09 | **version-diff-viewer** | medium | — | 5 | 6h |

**8 components · ~41h · Unblocks: Tier 6 (slo-card needs error-budget-gauge)**

---

### Tier 6 — Domain-Specific Composites (all deps satisfied)

Screen-specific components that combine multiple lower-tier pieces. Most are used by 1-3 screens. Build on demand as screens are implemented.

| # | Component | Complexity | Deps | Screens | Est. |
|---|-----------|------------|------|---------|------|
| 23 | **slo-card** | medium | error-budget-gauge | 1 | 3h |
| 22 | **anomaly-cluster-card** | high | confidence-score | 1 | 4h |
| 21 | **environment-card** | medium | — | 1 | 3h |
| 63 | **time-block-card** | medium | badge | 1 | 3h |
| 64 | **daily-timeline** | high | time-block-card | 1 | 6h |
| 12 | **gantt-bar** | high | — | 1 | 6h |
| 65 | **rotation-calendar** | medium | — | 1 | 4h |
| 66 | **checklist-runner** | medium | — | 4 | 4h |
| 67 | **incident-service-lanes** | high | — | 1 | 8h |
| 68 | **deploy-summary** | medium | badge, approval-chain-display | 4 | 4h |
| 70 | **five-whys-editor** | medium | — | 1 | 4h |
| 71 | **visual-flow-editor** | high | — | 1 | 10h |
| 72 | **version-selector** | medium | — | 5 | 3h |

**13 components · ~62h · Terminal tier**

---

## Summary

| Tier | Name | Components | Est. Hours | Cumulative |
|------|------|------------|------------|------------|
| 0 | Atomic Indicators | 12 | 15h | 15h |
| 1 | Cards + Navigation | 16 | 45h | 60h |
| 2 | Lists, Tables, Inputs | 14 | 50h | 110h |
| 3 | Complex Inputs + AI | 8 | 50h | 160h |
| 4 | Composites + Overlays | 5 | 20h | 180h |
| 5 | Visualizations | 8 | 41h | 221h |
| 6 | Domain-Specific | 13 | 62h | 283h |
| **Total** | | **76** | **~283h** | |

## Parallelization Opportunities

- **Tier 5 (Visualizations)** has zero dependencies on Tiers 3-4. A second dev stream can start these as soon as Tier 0 completes.
- **Tier 6** components are screen-specific. Build them just-in-time as screens are implemented rather than all at once.
- Within any tier, all components can be built in parallel.

## Critical Path

The longest dependency chain determines minimum calendar time:

```
badge (T0) → item-card (T1) → kanban-column (T2) — 10h
badge (T0) → project-card (T1) — 5h
confidence-score (T0) → ai-suggestion-list (T3) — 9h
rich-text-editor (T3) → ai-draft-editor (T4) — 18h  ← longest
voice-capture-button (T2) → inline-metadata-input (T2) → quick-capture-overlay (T4) — 11h
error-budget-gauge (T5) → slo-card (T6) — 7h
time-block-card (T6) → daily-timeline (T6) — 9h (within-tier dependency)
```

**Critical path: Tier 0 atomics → Tier 3 rich-text-editor → Tier 4 ai-draft-editor = ~30h sequential minimum.**

## Recommendation

Ship Tiers 0-2 first (~110h). That gives you every card, every navigation pattern, every list container, every basic input, and every indicator. You can assemble 80% of the screens from those 42 components alone. Tiers 3-6 add depth (AI, visualizations, domain logic) but aren't needed for initial screen scaffolding.
