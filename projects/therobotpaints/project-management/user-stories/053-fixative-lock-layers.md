# US-053: Fixative Application to Lock Charcoal/Pastel Layers

**As a** plein air sketch artist,
**I want to** apply a simulated fixative spray to lock charcoal or pastel layers in place,
**So that** I can safely work over a completed dry-media layer without disturbing it, matching the role fixative plays in traditional mixed-media workflows.

## Personas
- **Primary:** P7 Priya Sharma — she applies fixative to charcoal sketches before adding watercolor washes; the lock behavior is workflow-critical
- **Also relevant:** P3 Lena Vasquez, P4 James Whitfield

## Acceptance Criteria
- [ ] A fixative tool applies a region-based lock to charcoal and pastel particles in the selected area or entire canvas
- [ ] Fixed particles cannot be displaced by smudge tools, eraser strokes, or subsequent dry-media deposition
- [ ] Fixed particles remain reactive to watercolor or other wet media applied over them (absorption is not blocked by fixative unless explicitly configured)
- [ ] Fixative application is irreversible within a session (undo history allows reversal, but there is no "un-fix" tool)
- [ ] A visual indicator (subtle texture shift or overlay toggle) shows which regions are fixed versus unfixed

## Notes
Fixative locking is implemented as a boolean flag per particle or a fixed-layer bitmask in the VolumeLayer. Wet-media reactivity of fixed particles depends on the cross-media rules defined per media type; fixative itself does not alter those rules, only prevents mechanical displacement.
