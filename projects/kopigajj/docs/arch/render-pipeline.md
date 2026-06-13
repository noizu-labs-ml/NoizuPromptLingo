# Render Pipeline

## Overview

KopiGajj has two independent Metal compute pipelines: a **paint simulation engine** (`PaintSimulator`) for physically-based paint on canvas, and an **image filter pipeline** (`CanvasMetalRenderer`) for artistic post-processing. Both conform to `MetalShaderCompiler` and `MetalTextureFactory` protocols. All shaders are runtime-compiled from Swift string literals in `PaintShaderSource`.

## Paint Simulation Layer Stack

```
+-----------------------------------------------------+
|  Output (rgba8Unorm)                                 |  <- final composited RGBA
+-----------------------------------------------------+
|  Wet layer (double-buffered, rgba16Float)            |  <- active paint: flows,
|  wetAbsorb A/B + props A/B                           |     diffuses, mixes
+-----------------------------------------------------+
|  Solid layer (rgba16Float)                           |  <- dried/cured paint
|  solidAbsorbTex                                      |     immobile
+-----------------------------------------------------+
|  Canvas (r32Float + rgba16Float)                     |  <- height relief +
|  heightTex + canvasPropsTex                          |     material properties
+-----------------------------------------------------+
```

## GPU Textures (PaintField)

| Texture | Format | Purpose |
|---------|--------|---------|
| `wetAbsorbTex` / `wetAbsorbTexB` | rgba16Float | Wet pigment absorption RGB + concentration A (double-buffered) |
| `solidAbsorbTex` | rgba16Float | Dried pigment absorption RGB + concentration A |
| `propsTex` / `propsTexB` | rgba16Float | R=wetness, G=hardness, B=viscosity, A=mediaType (double-buffered) |
| `heightTex` | r32Float | Canvas relief + total paint thickness |
| `canvasPropsTex` | rgba16Float | R=absorbency, G=roughness, B=porosity (immutable after init) |
| `outputTex` | rgba8Unorm | Final rendered RGBA |

Double-buffered textures ping-pong via `PaintField.flip()`. Always read from `readWetAbsorb`/`readProps`, write to `writeWetAbsorb`/`writeProps`.

## Paint Simulation Kernels

| Kernel | Function | Purpose |
|--------|----------|---------|
| 1 | `canvasInit` | Generate procedural canvas surface: height relief, thread texture, material properties |
| 2 | `brushStroke` | Deposit pigment from `BrushPoint` into wet layer. Media-specific deposition logic |
| 3 | `flowStep` | Simulate wet paint flow and diffusion across neighboring texels |
| 4 | `dryStep` | Transfer wet paint to solid layer over time; increase hardness |
| 5 | `paintRender` | Composite all layers into final RGBA output with lighting |

## BrushPoint Struct

56 bytes, must match Metal layout exactly. 14 flat floats:

`posX, posY, pressure, radius, absR, absG, absB, concentration, viscosity, tipType, angle, dirX, dirY, wetness`

Defined in both `PaintField.swift` (Swift) and `PaintShaderSource.header` (Metal). Changes to one must be mirrored in the other.

## Absorption Color Model

Paint uses **absorption values** (0 = transparent, higher = more opaque pigment), not reflectance RGB. This is physically correct for subtractive pigment mixing.

Final rendering converts absorption to visible color via Beer-Lambert: `visibleColor = canvasColor * exp(-absorption * concentration)`

## Media-Specific Rendering (paintRender)

5 media types, each with distinct compositing:

| Media | Index | Rendering Model |
|-------|-------|----------------|
| Oil | 0 | Coverage-based compositing, broad specular (exp 24), high coverage floor at solidConc > 0.05 |
| Watercolor | 1 | Pure Beer-Lambert absorption through canvas, no coverage layer |
| Acrylic | 2 | Coverage-based (10x multiplier), tight specular (exp 48), stipple at brush edges (coverage 0.02-0.35) |
| Pastel | 3 | Coverage-based (8x multiplier), default specular |
| Highlighter | 4 | Screen blend -- bright translucent overlay like a real marker |

### Notable Behaviors

- **Asymptotic watercolor absorption** -- each stroke moves absorption toward a saturation limit (`pigmentAbsorb * 3.5`) with diminishing returns. Prevents light pigments (pink, yellow) from going to black.
- **Cross-media rejection** -- watercolor cannot adhere to dried acrylic or oil surfaces. The `crossMediaReject` flag causes watercolor to deposit only water (no pigment) on incompatible surfaces.
- **Acrylic stipple** -- at brush stroke edges (coverage 0.02-0.35), a noise-based stipple creates splotchy rather than smooth falloff, mimicking real bristle behavior.
- **Canvas texture bleed-through** -- thin paint reveals canvas texture; opaque media block it faster via media-specific coverage multipliers.

## Image Filter Kernels (CanvasMetalRenderer)

8 artistic post-processing filters, each a separate compute kernel:

| Filter | Notes |
|--------|-------|
| Kuwahara | Oil-painting brush abstraction |
| Anisotropic Kuwahara | Direction-aware variant |
| Pointillize | Dot-pattern decomposition |
| Watercolor | Soft-edge watercolor effect |
| Oil Paint | Multi-pass ping-pong rendering |
| Posterize | Color quantization |
| Bilateral | Edge-preserving smooth |
| Voronoi Mosaic | Cell-based decomposition |

`CanvasMetalRenderer` is a singleton (`.shared`). Oil Paint uses multi-pass ping-pong rendering; all others are single-pass.

## Metal Protocols

| Protocol | Provides |
|----------|---------|
| `MetalShaderCompiler` | `compileComputePipeline(source:functionName:)` and batch variant. Wraps `MTLDevice.makeLibrary(source:)` -> `MTLFunction` -> `MTLComputePipelineState` |
| `MetalTextureFactory` | `makeTexture2D(width:height:pixelFormat:)` and throwing variant. Common texture descriptor setup |

Both provide static variants usable before `self` is fully initialized (for use in `init`).

## Render Modes (paintRender)

| Mode | Value | Output |
|------|-------|--------|
| Lit | 0 | Full lit color composite |
| Height | 1 | Height map grayscale |
| Wetness | 2 | Wetness/hardness/concentration channels |
| Normals | 3 | Surface normal visualization |
| Solid Only | 4 | Solid layer visible color |
| Wet Only | 5 | Wet layer visible color |
| Media Map | 6 | Diagnostic: color-coded per media type |

## Performance

| Component | Budget | Notes |
|-----------|--------|-------|
| Metal pipeline compile | ~20-50ms one-time | Pre-warmed at launch via `RenderingBootstrap` |
| Canvas init kernel | ~5-10ms one-time | Procedural generation, cached |
| Paint sim frame (5 kernels) | ~1-3ms | On Apple Silicon, within budget |
| Filter pass | ~1-2ms | Single-pass; Oil Paint ~2-4ms (multi-pass) |

Default texture size: 1024x1024. Threadgroup size: 16x16.
