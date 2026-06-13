# TheRobotPaints — User Stories

100 user stories organized by domain, each referencing applicable [personas](../personas/README.md).

## Canvas, Viewport & Rendering (001-020)

| # | Story | Primary Persona |
|---|-------|-----------------|
| [001](001-zoom-to-cursor.md) | Zoom to cursor position | P1 Maya, P3 Lena |
| [002](002-pan-canvas.md) | Pan canvas with scroll/trackpad | P7 Priya |
| [003](003-reset-view-fit.md) | Reset view to fit canvas | P5 Suki |
| [004](004-pixel-grid-overlay.md) | Pixel grid overlay at high zoom | P1 Maya |
| [005](005-adjustable-light-direction.md) | Adjustable light direction for impasto | P2 David |
| [006](006-canvas-texture-visibility.md) | Canvas texture visibility | P1 Maya, P4 James |
| [007](007-checkerboard-out-of-bounds.md) | Checkerboard for out-of-bounds | P3 Lena |
| [008](008-tone-mapping-hdr.md) | Tone mapping for HDR paint values | P6 Alex |
| [009](009-60fps-apple-silicon.md) | 60 FPS on Apple Silicon | P7 Priya |
| [010](010-4k-canvas-no-frame-drops.md) | 4K canvas without frame drops | P3 Lena |
| [011](011-retina-hidpi-support.md) | Retina/HiDPI display support | P1 Maya |
| [012](012-window-resize-responsive-canvas.md) | Window resize with responsive scaling | P5 Suki |
| [013](013-fullscreen-mode.md) | Fullscreen mode | P3 Lena, P7 Priya |
| [014](014-dark-chrome-ui.md) | Dark chrome UI | P3 Lena |
| [015](015-canvas-rotation.md) | Canvas rotation for stroke angles | P1 Maya |
| [016](016-mirror-flip-view.md) | Mirror/flip view for composition | P2 David |
| [017](017-split-view-zoom-levels.md) | Split view comparing zoom levels | P1 Maya |
| [018](018-reference-image-panel.md) | Reference image panel | P3 Lena |
| [019](019-customizable-background-color.md) | Customizable background color | P1 Maya |
| [020](020-gpu-memory-indicator.md) | GPU memory usage indicator | P6 Alex |

## Brush, Stroke & Input (021-040)

| # | Story | Primary Persona |
|---|-------|-----------------|
| [021](021-pressure-sensitive-brush-strokes.md) | Pressure-sensitive brush strokes | P1 Maya |
| [022](022-mouse-trackpad-speed-pressure.md) | Mouse/trackpad speed-based pressure | P5 Suki |
| [023](023-catmull-rom-stroke-interpolation.md) | Catmull-Rom stroke interpolation | P7 Priya |
| [024](024-brush-size-adjustment.md) | Brush size adjustment | P1 Maya |
| [025](025-brush-opacity-flow-control.md) | Brush opacity/flow control | P1 Maya |
| [026](026-brush-preview-cursor.md) | Brush preview cursor | P2 David |
| [027](027-eraser-tool.md) | Eraser tool | P3 Lena |
| [028](028-palette-knife-smudge-tool.md) | Palette knife / smudge tool | P2 David |
| [029](029-dry-brush-effect.md) | Dry brush effect | P2 David |
| [030](030-round-brush-soft-hard-edge.md) | Round brush (soft/hard edge) | P1 Maya |
| [031](031-flat-brush-directional-marks.md) | Flat brush with directional marks | P2 David |
| [032](032-fan-brush-blending-texture.md) | Fan brush for blending | P2 David |
| [033](033-brush-stroke-undo.md) | Brush stroke undo | P2 David |
| [034](034-brush-stroke-redo.md) | Brush stroke redo | P3 Lena |
| [035](035-continuous-stroke-recording-replay.md) | Stroke recording for replay | P4 James |
| [036](036-quick-tool-switching-keyboard.md) | Quick tool switching (keyboard) | P3 Lena |
| [037](037-recent-brushes-quick-access-panel.md) | Recent brushes quick-access | P3 Lena |
| [038](038-custom-brush-parameter-presets.md) | Custom brush presets | P1 Maya |
| [039](039-sub-16ms-input-to-pixel-latency.md) | Sub-16ms input-to-pixel latency | P7 Priya |
| [040](040-3d-mouse-spacemouse-canvas-navigation.md) | 3D mouse canvas navigation | P6 Alex |

## Paint Physics, Media & Simulation (041-060)

| # | Story | Primary Persona |
|---|-------|-----------------|
| [041](041-watercolor-wet-on-wet-flow.md) | Watercolor wet-on-wet flow | P1 Maya |
| [042](042-watercolor-granulation.md) | Watercolor granulation on rough canvas | P1 Maya |
| [043](043-watercolor-backrun.md) | Watercolor backrun | P1 Maya |
| [044](044-watercolor-edge-darkening.md) | Watercolor edge darkening | P1 Maya, P4 James |
| [045](045-oil-thixotropic-viscosity.md) | Oil thixotropic viscosity | P2 David |
| [046](046-oil-impasto-depth-buildup.md) | Oil impasto depth buildup | P2 David |
| [047](047-oil-slow-drying.md) | Oil slow drying | P2 David |
| [048](048-acrylic-water-resist-cured.md) | Acrylic water-resist once cured | P3 Lena |
| [049](049-acrylic-two-phase-drying.md) | Acrylic two-phase drying | P3 Lena |
| [050](050-charcoal-particulate-deposition.md) | Charcoal particulate deposition | P7 Priya |
| [051](051-charcoal-smudge-blend.md) | Charcoal smudge and blend | P7 Priya |
| [052](052-pastel-powder-layering.md) | Pastel powder layering | P3 Lena |
| [053](053-fixative-lock-layers.md) | Fixative to lock charcoal/pastel | P3 Lena |
| [054](054-beer-lambert-color-mixing.md) | Beer-Lambert absorptive color mixing | P2 David |
| [055](055-sph-fluid-dynamics.md) | SPH particle fluid dynamics | P6 Alex |
| [056](056-paint-drying-kinetics.md) | Paint drying kinetics | P4 James |
| [057](057-cross-media-rejection.md) | Cross-media rejection | P3 Lena |
| [058](058-wet-on-dry-controlled-edge.md) | Wet-on-dry controlled edge | P1 Maya |
| [059](059-surface-tension-paint-flow.md) | Surface tension effects | P6 Alex |
| [060](060-instant-dry-shortcut.md) | Instant-dry shortcut | P7 Priya |

## Layers, Canvas Properties & Color (061-080)

| # | Story | Primary Persona |
|---|-------|-----------------|
| [061](061-layer-panel-state-overview.md) | Layer panel with state indicators | P1 Maya |
| [062](062-layer-visibility-toggle.md) | Layer visibility toggle | P3 Lena |
| [063](063-active-layer-selection.md) | Active layer selection | P1 Maya |
| [064](064-layer-paint-state-indicators.md) | Layer paint state indicators | P1 Maya |
| [065](065-layer-media-type-indicator.md) | Layer media type indicator | P3 Lena |
| [066](066-layer-opacity-adjustment.md) | Layer opacity adjustment | P3 Lena |
| [067](067-flatten-visible-layers.md) | Flatten visible layers | P3 Lena |
| [068](068-clear-single-layer.md) | Clear a single layer | P2 David |
| [069](069-canvas-paper-type-presets.md) | Canvas paper type presets | P4 James |
| [070](070-custom-canvas-material-properties.md) | Custom canvas material properties | P6 Alex |
| [071](071-canvas-size-selection.md) | Canvas size selection | P3 Lena |
| [072](072-color-picker-absorption-aware-preview.md) | Color picker (absorption-aware) | P2 David |
| [073](073-color-palette-panel.md) | Color palette panel | P1 Maya |
| [074](074-eyedropper-tool.md) | Eyedropper tool | P1 Maya |
| [075](075-color-mixing-preview.md) | Color mixing preview | P2 David |
| [076](076-color-history.md) | Color history | P7 Priya |
| [077](077-layer-thumbnail-preview.md) | Layer thumbnail preview | P3 Lena |
| [078](078-layer-reorder-drag.md) | Layer reorder via drag | P3 Lena |
| [079](079-cross-layer-bleed-through.md) | Cross-layer bleed-through | P1 Maya |
| [080](080-layer-depth-visualization-mode.md) | Layer depth visualization | P6 Alex |

## UI, Export, Accessibility & Developer (081-100)

| # | Story | Primary Persona |
|---|-------|-----------------|
| [081](081-save-painting-native-format.md) | Save to native format | P1 Maya |
| [082](082-open-load-saved-painting.md) | Open/load saved paintings | P4 James |
| [083](083-auto-save-configurable-intervals.md) | Auto-save | P5 Suki |
| [084](084-export-png-canvas-resolution.md) | Export PNG at canvas resolution | P7 Priya |
| [085](085-export-png-custom-resolution.md) | Export PNG at custom resolution | P1 Maya |
| [086](086-export-tiff-print-production.md) | Export TIFF for print | P1 Maya |
| [087](087-new-canvas-creation-dialog.md) | New canvas creation dialog | P3 Lena |
| [088](088-collapsible-tool-panels.md) | Collapsible tool panels | P7 Priya |
| [089](089-simple-mode-toggle.md) | Simple mode toggle | P5 Suki |
| [090](090-keyboard-shortcut-customization.md) | Keyboard shortcut customization | P3 Lena |
| [091](091-preferences-window.md) | Preferences window | P6 Alex |
| [092](092-toolbar-primary-tools.md) | Toolbar with primary tools | P5 Suki |
| [093](093-status-bar-canvas-info.md) | Status bar with canvas info | P6 Alex |
| [094](094-screen-recording-integration.md) | Screen recording for teaching | P4 James |
| [095](095-wetness-heatmap-debug-visualization.md) | Wetness heatmap debug viz | P6 Alex |
| [096](096-velocity-field-debug-visualization.md) | Velocity field debug viz | P6 Alex |
| [097](097-layer-depth-debug-visualization.md) | Layer depth debug viz | P6 Alex |
| [098](098-shader-hot-reload.md) | Shader hot-reload | P6 Alex |
| [099](099-plugin-extension-custom-media.md) | Plugin/extension for custom media | P6 Alex |
| [100](100-accessibility-keyboard-only-painting.md) | Keyboard-only painting workflow | P5 Suki |

## Persona Coverage Summary

| Persona | Stories (count) | Domains |
|---------|---------------:|---------|
| P1 Maya Chen | ~28 | Brush, watercolor, layers, color, export |
| P2 David Okafor | ~18 | Brush, oil physics, impasto, color mixing |
| P3 Lena Vasquez | ~22 | 4K perf, multi-media, layers, fast workflow |
| P4 James Whitfield | ~8 | Teaching, recording, paper presets, drying |
| P5 Suki Tanaka | ~8 | Simple mode, trackpad, auto-save, accessibility |
| P6 Alex Kirchner | ~14 | Debug viz, shader dev, extensibility, GPU |
| P7 Priya Sharma | ~10 | Latency, charcoal, compact UI, quick export |
