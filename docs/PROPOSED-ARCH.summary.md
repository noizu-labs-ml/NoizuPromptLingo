# Proposed Architecture -- Summary

Target architecture for TheRobotPaints derived from 100 user stories across 7 personas. Extends current 3-kernel renderer into a full paint application.

## What's New (vs Current)

- **Input pipeline** — BrushEngine (Catmull-Rom interpolation, tablet/mouse/trackpad pressure), InputRouter (tool dispatch), ViewportController (extracted zoom/pan/rotate)
- **5-phase simulation** — Deposition → SPH Physics → Particle-to-Volume → Grid Fluid → Drying
- **5 media types** — Watercolor, oil, acrylic, charcoal, pastel via MediaTypeProtocol
- **UI shell** — Toolbar, layer panel, color panel (absorption-aware), brush panel, status bar, simple/full mode toggle
- **File I/O** — Native .trp format (raw volume + metadata), PNG/TIFF export, autosave
- **Debug viz** — Wetness heatmap, velocity field, depth heightmap as alternative compositor passes
- **Extensibility** — MediaTypeProtocol for custom media, shader hot-reload for dev

## New Data Structures

- BrushPoint (32B) — interpolated stroke sample
- BrushParams (64B) — active brush configuration
- SPHParticle (48B) — fluid dynamics particle
- SpatialHashCell (8B) — neighbor lookup
- StrokeRecord (var) — undo unit
- CanvasPreset — named paper types

## Memory Budget

1080p: ~710 MB GPU (up from ~630 MB). 4K: ~2.8 GB.

## Key Decisions

- Stroke-granularity undo (matches painter mental model)
- Protocol-based media types (extensible without core changes)
- Simple/Full mode (serves hobbyist and professional)
- Absorption color picker (shows predicted visible color)
- Speed-based mouse pressure (inverse speed mapping)
- Native binary .trp format (preserves all VolumeLayer state)
- Simulation half-rate option (30 Hz sim + 60 Hz render for 4K)

## Migration: 7 Phases

1. Brush Input (US-021–040) — critical path
2. Watercolor Sim (US-041–044, 054–056)
3. Multi-Layer UI (US-061–068, 088, 092)
4. Oil + Acrylic (US-045–049)
5. Charcoal + Pastel (US-050–053, 057)
6. File I/O + Export (US-081–087)
7. Polish + Extensibility (US-089–100)

## Overflow Docs

- `arch/proposed-components.md` — Module map + component interactions
- `arch/proposed-data-model.md` — New struct layouts + memory + file format
- `arch/proposed-simulation.md` — 5-phase kernel dispatch + per-phase details
- `arch/proposed-input.md` — Event flow, brush engine, pressure sources, latency budget
- `arch/proposed-ui.md` — Window layout, panel specs, shortcuts, dark chrome, accessibility
- `arch/proposed-decisions.md` — 9 ADRs with rationale and trade-offs
