# Architecture Summary

**KopiGajj** -- macOS GPU-accelerated paint simulation and canvas render engine. Swift 5.9 + SwiftUI + Metal compute. Background app with global hotkey popup.

**Stage:** 0.5 (paint simulation engine + image filters + tuning UI).

## Components

- **App Core:** main.swift -> AppDelegate -> HotkeyManager (CGEventTap for Cmd+Shift+T) -> PopupWindowManager (floating NSWindow)
- **Menu Bar:** MenuBarManager (NSStatusItem + dropdown, decoupled via closures)
- **Bootstrap:** RenderingBootstrap (pre-warm Metal pipelines + textures), Version (version constants)
- **Metal Protocols:** MetalShaderCompiler (MSL string -> pipeline), MetalTextureFactory (texture allocation)
- **Paint Simulation:** PaintSimulator (5 GPU kernels: canvasInit, brushStroke, flowStep, dryStep, paintRender), PaintField (8 GPU textures, double-buffered wet layer, `BrushMode`/`BrushTip` enums), PaintShaderSource (MSL as Swift string literals, split across 6 files: Header, BrushStroke, CanvasInit, Filters, FlowDry, Render), PaintMath (color conversion)
- **Image Filters:** CanvasMetalRenderer (8 filter kernels: Kuwahara, Anisotropic Kuwahara, Pointillize, Watercolor, Oil Paint, Posterize, Bilateral, Voronoi Mosaic)
- **Canvas Rendering:** CanvasBackground (procedural textures), StrokeCard (painterly cards), ProceduralStrokes (stroke geometry)
- **Interactive Canvas:** PaintCanvasView (SwiftUI) -> PaintCanvasNSView (NSView + Metal layer), PaintCanvasControls (brush/media UI), PaintCanvasState (brush settings + sim), ColorPanelCoordinator (NSColorPanel bridge), MediaTooltips (per-media help text)
- **Tuning UI:** CanvasTuningView (layout) -> CanvasPreviewPane + CanvasTuningSliders + CanvasPaintSimPane
- **Config UI:** CanvasConfigManager (theme picker + persistence), TunableSlider (slider row with baseline + info), CanvasFilterSection (filter controls), CanvasPaintSimSection (sim controls), CanvasPopupView (demo popup)
- **Config:** CanvasConfig (flat JSON, ~30+ params), CanvasTuningState (ObservableObject), CanvasTheme (colors)

## Key Technical Decisions

- Runtime shader compilation from Swift string literals split across 6 files (no `.metal` files in SPM build)
- Absorption color model (0=transparent, higher=more opaque; Beer-Lambert for final rendering)
- Metal protocols (`MetalShaderCompiler`, `MetalTextureFactory`) for shared GPU boilerplate
- 5 media types: oil, watercolor, acrylic, pastel, highlighter (each with distinct rendering and media-specific brush tips — 16 total)
- Cross-media rejection (watercolor won't adhere to dried acrylic/oil)
- Flat JSON config encoding for backward compatibility

## Testing

9 test files + helpers: struct layout (56-byte BrushPoint), CanvasConfig Codable, enum stability, color math, Metal shader compilation, PaintCanvasState, PaintField textures, paint pipeline integration, regressions.

## Key Constraints

- macOS 14.0+ (Sonoma)
- ~1-3ms paint sim frame time on Apple Silicon
- SPM executable; Metal shaders runtime-compiled
- `.accessory` activation policy (menu bar only, no dock icon)
- BrushPoint struct must be exactly 56 bytes, matching Metal layout

## References

- [Render Pipeline](arch/render-pipeline.md) -- layer stack, kernels, textures, color model
- [Data Flow](arch/data-flow.md) -- event and config pipelines
- [Medium Behaviour](medium-behaviour.md) -- physical paint media reference
