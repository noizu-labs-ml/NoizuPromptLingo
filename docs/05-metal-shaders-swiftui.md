# Metal Shaders in SwiftUI

**Last Updated:** 2026-03-25
**Min Swift Version:** 5.9
**Min macOS Version:** 14.0

## Quick Summary

SwiftUI on macOS 14+ provides three view modifiers — `.colorEffect()`, `.distortionEffect()`, and `.layerEffect()` — that execute Metal fragment shaders directly on any view. Shaders are written in `.metal` files using `[[ stitchable ]]` functions. For Kopigajj, these enable the oil-on-canvas aesthetic: canvas texture overlays, Kuwahara brush-stroke filters, and bristle-edge distortions — all GPU-accelerated at sub-3ms cost.

## Key APIs

| API | Purpose | File Location |
|-----|---------|---------------|
| `ShaderLibrary` | Auto-generated namespace for all `.metal` `[[ stitchable ]]` functions | SwiftUI framework |
| `.colorEffect(_:isEnabled:)` | Per-pixel color transformation (no position access) | View modifier |
| `.distortionEffect(_:maxSampleOffset:isEnabled:)` | Per-pixel position displacement | View modifier |
| `.layerEffect(_:maxSampleOffset:isEnabled:)` | Full layer sampling (blur, convolution, texture overlay) | View modifier |
| `Shader` | Represents a compiled Metal function with arguments | SwiftUI framework |
| `Shader.Argument` | Typed argument: `.float()`, `.float2()`, `.color()`, `.image()` | SwiftUI framework |

## Code Examples

### Minimal Color Effect

**Swift 5.9+, macOS 14.0+**

`Desaturate.metal`:
```metal
#include <metal_stdlib>
using namespace metal;

// Desaturate based on "age" — older clipboard items look drier
[[ stitchable ]] half4 desaturate(
    float2 position,
    half4 color,
    float amount  // 0.0 = full color, 1.0 = grayscale
) {
    half luminance = dot(color.rgb, half3(0.299, 0.587, 0.114));
    half3 gray = half3(luminance);
    half3 result = mix(color.rgb, gray, half(amount));
    return half4(result, color.a);
}
```

Usage in SwiftUI:
```swift
Text("some clipboard content")
    .colorEffect(ShaderLibrary.desaturate(.float(0.5)))
```

### Distortion Effect (Bristle Edges)

**Swift 5.9+, macOS 14.0+**

`Wobble.metal`:
```metal
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] float2 wobble(
    float2 position,
    float amplitude,
    float frequency
) {
    float offset = sin(position.y * frequency) * amplitude;
    return float2(position.x + offset, position.y);
}
```

Usage:
```swift
RoundedRectangle(cornerRadius: 18)
    .distortionEffect(
        ShaderLibrary.wobble(.float(2.0), .float(0.1)),
        maxSampleOffset: CGSize(width: 2, height: 0)
    )
```

### Layer Effect (Texture Overlay)

**Swift 5.9+, macOS 14.0+**

`CanvasOverlay.metal`:
```metal
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 canvasOverlay(
    float2 position,
    SwiftUI::Layer layer,
    texture2d<half> canvasTex [[ texture(0) ]],
    float intensity
) {
    half4 color = layer.sample(position);

    constexpr sampler s(address::repeat, filter::linear);
    float2 uv = position / float2(canvasTex.get_width(), canvasTex.get_height());
    half4 canvas = canvasTex.sample(s, uv);

    color.rgb = mix(color.rgb, color.rgb * (canvas.rgb * 0.5 + 0.5), half(intensity));
    return color;
}
```

Usage:
```swift
VStack { /* content */ }
    .layerEffect(
        ShaderLibrary.canvasOverlay(
            .image(Image("canvas-weave-tile")),
            .float(0.3)
        ),
        maxSampleOffset: .zero
    )
```

### Kuwahara Filter (Oil Paint Effect)

**Swift 5.9+, macOS 14.0+**

`Kuwahara.metal`:
```metal
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 kuwahara(
    float2 position,
    SwiftUI::Layer layer,
    float radius
) {
    int r = int(radius);
    half3 mean[4] = {};
    half3 sigma[4] = {};
    half count[4] = {};

    for (int j = -r; j <= r; j++) {
        for (int i = -r; i <= r; i++) {
            half4 s = layer.sample(position + float2(i, j));
            half3 c = s.rgb;

            if (i <= 0 && j <= 0) { mean[0] += c; sigma[0] += c * c; count[0] += 1.0; }
            if (i >= 0 && j <= 0) { mean[1] += c; sigma[1] += c * c; count[1] += 1.0; }
            if (i <= 0 && j >= 0) { mean[2] += c; sigma[2] += c * c; count[2] += 1.0; }
            if (i >= 0 && j >= 0) { mean[3] += c; sigma[3] += c * c; count[3] += 1.0; }
        }
    }

    half minVar = 1e10;
    half3 result = half3(0);

    for (int q = 0; q < 4; q++) {
        mean[q] /= count[q];
        sigma[q] = sigma[q] / count[q] - mean[q] * mean[q];
        half v = sigma[q].r + sigma[q].g + sigma[q].b;
        if (v < minVar) { minVar = v; result = mean[q]; }
    }

    return half4(result, layer.sample(position).a);
}
```

Usage:
```swift
someView
    .layerEffect(
        ShaderLibrary.kuwahara(.float(3.0)),
        maxSampleOffset: CGSize(width: 3, height: 3)  // must match radius
    )
```

### Shader Argument Types

```swift
// Available argument types for Shader functions
ShaderLibrary.myShader(
    .float(1.0),                           // float
    .float2(CGPoint(x: 100, y: 200)),      // float2
    .color(.red),                           // half4 color
    .image(Image("texture")),              // texture2d<half>
    .boundingRect,                          // float4 (view bounds)
    .colorArray([.red, .blue, .green])     // device const half4*
)
```

## Implementation Notes

### Gotchas

- **`maxSampleOffset` is critical**: For `.layerEffect()` and `.distortionEffect()`, the `maxSampleOffset` parameter tells SwiftUI how far your shader samples from the current position. Set it to at least your kernel radius. Too small → clipped output. Too large → wasted GPU work.
- **First-frame compilation penalty**: `[[ stitchable ]]` shaders compile at runtime on first use (~20-50ms). Pre-warm at app launch to avoid hitching on first popup.
- **No `#include` across .metal files**: Each `.metal` file in SwiftUI shader context is compiled independently. Shared utility functions must be duplicated or placed in the same file.
- **Texture coordinate space**: In `.layerEffect()`, `position` is in the view's local coordinate space (points, not pixels). For tiling textures, divide by texture dimensions.
- **Alpha handling**: Always preserve the alpha channel from `layer.sample()`. Returning wrong alpha causes transparency bugs.

### Pre-Warming Shaders

```swift
// Call in AppDelegate.applicationDidFinishLaunching(_:)
func prewarmCanvasShaders() {
    DispatchQueue.global(qos: .utility).async {
        let warmup = Rectangle()
            .frame(width: 1, height: 1)
            .layerEffect(
                ShaderLibrary.kuwahara(.float(3.0)),
                maxSampleOffset: CGSize(width: 3, height: 3)
            )
        let renderer = ImageRenderer(content: warmup)
        _ = renderer.nsImage  // triggers Metal compilation
    }
}
```

### Performance Considerations

| Shader | Complexity | Latency (Apple Silicon) | Latency (Intel) |
|--------|-----------|------------------------|-----------------|
| Color effect (desaturate) | O(1) per pixel | <0.1ms | <0.2ms |
| Distortion (wobble) | O(1) per pixel | <0.1ms | <0.2ms |
| Texture overlay | O(1) per pixel + texture sample | <0.5ms | <1ms |
| Kuwahara radius 3 | O(49) per pixel (7×7 kernel) | ~1-2ms | ~2-4ms |
| Kuwahara radius 5 | O(121) per pixel (11×11 kernel) | ~3-5ms | ~5-10ms |

**Rule of thumb**: Keep total shader cost under 3ms for Kopigajj's 50ms popup target.

### Threading

- Shader compilation: can be triggered from any thread (Metal handles internally)
- Shader execution: GPU — does not block main thread
- `ImageRenderer` for pre-warming: use a background queue

## References

### Official Documentation
- [ShaderLibrary — Apple Developer](https://developer.apple.com/documentation/swiftui/shaderlibrary)
- [Shader — Apple Developer](https://developer.apple.com/documentation/swiftui/shader)
- [View.colorEffect — Apple Developer](https://developer.apple.com/documentation/swiftui/view/coloreffect(_:isenabled:))
- [View.distortionEffect — Apple Developer](https://developer.apple.com/documentation/swiftui/view/distortioneffect(_:maxsampleoffset:isenabled:))
- [View.layerEffect — Apple Developer](https://developer.apple.com/documentation/swiftui/view/layereffect(_:maxsampleoffset:isenabled:))
- [Metal Shading Language Specification (PDF)](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)

### WWDC Sessions
- [Create custom visual effects with SwiftUI — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10151/) — Primary reference for SwiftUI shader integration
- [Bring your machine learning and AI models to Apple silicon — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10159/) — Metal performance on Apple Silicon

### Tutorials & Articles
- [How to add Metal shaders to SwiftUI views — Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-metal-shaders-to-swiftui-views-using-layer-effects) — Step-by-step tutorial
- [Metal Shaders in SwiftUI — Design+Code](https://designcode.io/swiftui-handbook-metal-shaders/) — Interactive course
- [A Beginner's Guide to Metal Shaders in SwiftUI — Medium](https://medium.com/@garejakirit/a-beginners-guide-to-metal-shaders-in-swiftui-5e98ef3cb222) — Beginner-friendly walkthrough
- [On Crafting Painterly Shaders — Maxime Heckel](https://blog.maximeheckel.com/posts/on-crafting-painterly-shaders/) — Advanced Kuwahara + Voronoi techniques

### Libraries (Reference Code)
- [Inferno — SwiftUI Metal shaders (MIT)](https://github.com/twostraws/Inferno) — Noise, distortion, color effects. Best reference for `[[ stitchable ]]` patterns
- [GPUImage3 — Metal image processing (BSD)](https://github.com/BradLarson/GPUImage3) — Production Kuwahara implementation to port
- [LYGIA — Cross-platform shader library](https://lygia.xyz/filter/kuwahara) — Kuwahara variants in Metal-compatible syntax

## Version Notes

- **macOS 14.0 Sonoma (2023)**: `.colorEffect()`, `.distortionEffect()`, `.layerEffect()` introduced. `[[ stitchable ]]` attribute added to Metal Shading Language.
- **macOS 15.0 Sequoia (2024)**: Performance improvements to shader compilation. Additional `Shader.Argument` types.
- **Swift 5.9**: Required for `ShaderLibrary` auto-generation from `.metal` files.

See also: [`03-swiftui-popup.md`](../spec/api-reference/03-swiftui-popup.md) for popup window lifecycle, [`11-canvas-render-engine.md`](11-canvas-render-engine.md) for full render engine architecture

<!-- nav -->

---

[< Previous: SwiftUI View Lifecycle](../spec/api-reference/04-swiftui-view-lifecycle.md) | [Table of Contents](../product-spec.md)

<!-- nav -->
