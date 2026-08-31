# 34: Empty State

| Field | Value |
|-------|-------|
| ID | CMP-34 |
| Category | Feedback & Indicators |
| Surfaces | web, cli-ink |
| Used In | SCR-01, SCR-02, SCR-03, SCR-09, SCR-10, SCR-11, SCR-16, SCR-23, SCR-24, SCR-25 |

## Description
The shared "nothing here yet" pattern across every list-backed screen: illustration/icon (web) or plain text row (cli-ink) plus contextual guidance — search suggestions (US-082), first-run guidance pointing at Settings, or a call to action ("save a prompt from a thread").

## Size Variants

| Variant | Use Case |
|---------|---------|
| No-query browse empty | First-run / nothing indexed yet |
| Search-empty | Query returned zero results, with relaxation suggestions |
| Scoped empty | Empty within a filtered/scoped context (e.g. orphaned project, US-083) |

## Props / Configuration
- `message` — primary empty-state text
- `suggestions` — optional list of relaxation/next-step actions
- `cta` — optional call-to-action link (e.g. to Settings, to a save action)

## Interactions
- CTA navigates to the relevant remediation screen
