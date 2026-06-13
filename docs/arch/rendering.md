# Rendering Pipeline

## Compute-Only Architecture

All rendering uses compute shaders dispatched with 16x16 threadgroups and ceiling-division grid sizing. No vertex/fragment shaders are used.

## Kernels

### canvasInit (one-shot)

Source: `Shaders/ShaderCanvasInit.swift`

Generates the canvas material properties texture using layered 2D noise:
- Warp and weft thread pattern via directional noise at different frequencies
- Writes absorbency, roughness, porosity, sizing to rgba16Float texture
- Runs once on first frame

### volumeInit (one-shot)

Source: `Shaders/ShaderVolumeInit.swift`

Zero-fills the entire VolumeLayer buffer. Each thread handles one pixel across all 8 layers.

### render (per-frame)

Source: `Shaders/ShaderRender.swift`

Per-drawable-pixel compositor:

1. **View transform** -- fit-to-window scale * zoom, offset by pan, maps drawable pixel to canvas coordinate
2. **Out-of-bounds** -- checkerboard pattern for pixels outside canvas
3. **Canvas base** -- warm white (0.95, 0.93, 0.88) modulated by roughness texture and diffuse lighting from roughness-derived normals
4. **Layer compositing** -- back-to-front (layer 7 -> 0), skipping transparent layers:
   - Depth-derived normal maps (central differences on neighbor depth values)
   - Lambertian diffuse + Blinn-Phong specular (exponent from gloss field)
   - Over-operator blending with early-out on fully opaque layers
5. **Tone mapping** -- Reinhard (`rgb / (1 + rgb)`) + gamma 2.2
6. **Pixel grid** -- at zoom > 8x, draws grid lines with fade-in alpha

## Lighting Model

- Directional light (user-adjustable X/Y/Z sliders)
- Per-layer impasto normals from depth gradient
- Canvas weave normals from roughness gradient
- Ambient + diffuse + specular per layer
- Specular power: `gloss * 128 + 16`

## Resource Flow

```
Renderer.draw(in:)
  |
  +-- [first frame only]
  |     canvasInit -> canvasPropsTexture
  |     volumeInit -> volumeLayersBuffer
  |
  +-- [every frame]
        render(volumeLayersBuffer, canvasPropsTexture) -> drawable.texture
        present(drawable)
```
