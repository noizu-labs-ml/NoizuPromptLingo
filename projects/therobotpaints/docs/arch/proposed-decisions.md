# Proposed Architecture Decision Records

## ADR-P01: Stroke-Granularity Undo

**Context:** Undo could operate at sub-stroke level (per-sample), stroke level, or time-interval level. Painters expect undo to remove one deliberate mark.

**Decision:** Each complete stroke (mouseDown → mouseUp) is a single undo unit.

**Rationale:** Matches the mental model of physical painting ("I want to remove that last brushstroke"). Sub-stroke undo would be confusing; time-based undo would split gestures unpredictably.

**Implementation:** On `mouseDown`, snapshot the affected canvas region (lazy — only the bounding box of the stroke). On undo, restore the snapshot. Delta snapshots keep memory reasonable.

**Stories:** US-033, US-034

## ADR-P02: Protocol-Based Media Types

**Context:** The app supports 5 built-in media. User story US-099 requires extensibility for custom media. Options: enum switch, protocol, or scripting language.

**Decision:** Swift `MediaTypeProtocol` with MSL source strings that compile at registration time.

**Rationale:** Protocols are idiomatic Swift. MSL strings are the existing shader pattern. No runtime scripting overhead. Custom media can be distributed as Swift packages that provide protocol conformances.

**Trade-off:** Custom media authors need Metal/MSL knowledge. No visual shader editor.

**Stories:** US-099

## ADR-P03: Simple/Full Mode Split

**Context:** Personas range from Suki (hobbyist, wants minimal UI) to Lena (concept artist, wants every parameter). One UI cannot satisfy both without compromise.

**Decision:** Two modes toggled via Cmd+Shift+S. Simple hides panels and advanced controls. Full shows everything.

**Rationale:** Better than progressive disclosure (which creates middle ground that satisfies neither). Binary switch is clear and discoverable. Simple mode still accesses all media types — it just hides tuning parameters.

**Implementation:** SwiftUI `@AppStorage("simpleMode")` drives conditional view rendering. No separate view hierarchies — same views with visibility flags.

**Stories:** US-089

## ADR-P04: Absorption Color Picker

**Context:** Standard RGB pickers produce colors that look wrong under Beer-Lambert absorption. Users would pick "yellow" and get something else on canvas.

**Decision:** Custom color picker that shows absorption values AND predicted visible appearance. Users interact with visible color; the picker reverse-maps to absorption space.

**Rationale:** All paint simulation uses absorption color. If the picker shows raw absorption, only technical users (Alex) would understand it. Showing predicted appearance with a small absorption readout serves both audiences.

**Trade-off:** Reverse-mapping from visible to absorption has multiple solutions (metamerism). Use a perceptually uniform mapping — accept that it won't match every physical pigment.

**Stories:** US-072

## ADR-P05: Speed-Based Pressure for Mouse

**Context:** Most users don't own drawing tablets. Without pressure data, brush strokes are uniform and lifeless. Options: constant pressure, speed-based simulation, or force touch.

**Decision:** Inverse speed mapping: `pressure = 1.0 - clamp(speed / maxSpeed, 0, 0.9)`. Slow strokes are heavy; fast strokes are light.

**Rationale:** Matches physical intuition (pressing harder slows your hand). Simple to implement. Good enough for Suki (hobbyist) and adequate for Priya (sketch). Force Touch trackpad used when available.

**Trade-off:** Fundamentally different from real pressure — can't do fast heavy strokes or slow light ones. Acceptable for non-tablet users.

**Stories:** US-022

## ADR-P06: Native Binary File Format (.trp)

**Context:** Options: custom binary, open format (OpenRaster), or image-with-metadata (TIFF+JSON).

**Decision:** Custom binary format (`.trp`) containing raw VolumeLayer buffer, CanvasProps texture, and JSON metadata.

**Rationale:** Must preserve all 15 fields per VolumeLayer including wetness, velocity, and age — no standard image format stores this. Binary dump is fastest for save/load (memcpy-equivalent). JSON metadata section keeps it partially inspectable.

**Trade-off:** Not interoperable with other paint apps. Export to PNG/TIFF covers that need.

**Stories:** US-081, US-082

## ADR-P07: Canvas Paper Presets + Custom Sliders

**Context:** James (educator) needs named presets ("Arches Cold Press") for teaching. Alex (technical) needs raw parameter control. Options: presets only, sliders only, or both.

**Decision:** Preset dropdown + "Custom" option that reveals sliders. Presets are editable and saveable.

**Rationale:** Presets serve 80% use case (pick a paper, paint). Sliders serve the 20% who want fine control. Users can create custom presets from slider values — educator can prepare presets for students.

**Stories:** US-069, US-070

## ADR-P08: Simulation Half-Rate Option

**Context:** SPH physics is the most expensive GPU phase. At 4K with many particles, it may exceed the 16ms frame budget.

**Decision:** Offer a "simulation quality" preference: Full (60 Hz sim + 60 Hz render) or Half (30 Hz sim + 60 Hz render). The render kernel runs every frame; simulation phases run every other frame.

**Rationale:** Paint physics is visually acceptable at 30 Hz — fluid motion is slow enough that 33ms timesteps are not jarring. Rendering at 60 Hz keeps viewport interaction smooth.

**Implementation:** Frame counter modulo 2 gates simulation encoder dispatch. Timestep `dt` doubles on simulation frames.

**Stories:** US-009, US-010

## ADR-P09: Debug Viz as Alternative Compositor Passes

**Context:** Debug visualization (wetness heatmap, velocity arrows, depth heightmap) could be separate windows, overlays, or alternative render modes.

**Decision:** Alternative compositor passes that replace the standard render kernel. Toggled via menu or Cmd+1/2/3.

**Rationale:** Same GPU resources, same viewport transform, no additional windows. The heatmap/arrow rendering is a different compositor kernel reading the same VolumeLayer buffer. Easy to implement and visually clear.

**Trade-off:** Can't see debug and final render simultaneously. Acceptable — the split-view feature (US-017) could pair debug + render views in the future.

**Stories:** US-095, US-096, US-097
