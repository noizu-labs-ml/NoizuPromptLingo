# 37: TUI Profiles Screen

| Field | Value |
|-------|-------|
| ID | SCR-37 |
| Surface | tui-ratatui |
| Type | primary |
| Category | skill-manage (core) |
| Route / Entry | `skill-manage tui` → `Tab` from Catalog Browser (`Screen::Profiles`) |
| Primary Personas | P-004, P-008 |
| User Stories | US-077, US-079 |

## Description
Fourth tab in `skill-manage tui`: instead of a flat catalog of individual skills/agents/commands, lists work-type **profiles** (bundles) that can be applied in one action to enable a curated set of catalog items for a provider (US-079's "batch-enable a skill bundle").

## Entry Points
- `Tab` cycled from Catalog Browser (SCR-36), landing after Commands
- `g` shortcut (per footer help text) jumps directly to Profiles from any catalog screen

## Key Components
- Profile row list — profile name, scope/description, member count
- Stats footer — reflects `Screen::Profiles`-specific counts rather than the catalog item counts shown on SCR-36

## States
- **Loading:** n/a — profiles load synchronously with the app (`reload_profiles` on screen entry)
- **Empty:** no profiles defined — list renders empty with the same footer/help affordances

## Interactions
- `↑↓` / `j k` — move selection
- `A` — apply the selected profile's work-type bundle to the active provider (bulk-enable, US-079)
- `Tab` — next screen (back to Skills)
- `?` — Help overlay (SCR-40)
- `q` — quit

## Navigation
- **From:** SCR-36 TUI Catalog Browser (`Tab` / `g`)
- **To:** SCR-36 (Tab forward), SCR-40 Help overlay
