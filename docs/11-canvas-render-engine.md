# Canvas Render Engine — Oil-on-Canvas UI/UX

## Overview

The Kopigajj Canvas render engine produces the oil-painting aesthetic that differentiates the app from every other clipboard manager. Rather than styling UI components with CSS-like properties, we composite actual rendered graphics — tileable canvas textures, Metal GPU shaders, and procedurally masked stroke cards — into a layered SwiftUI view stack.

The engine must add **<3ms** to popup latency, preserving the 50ms total target (US-065).

## Problem Statement

Standard SwiftUI views produce sharp, flat rectangles. The Kopigajj design language calls for:
- Canvas-weave texture as the popup background
- Stroke cards with irregular, painterly bristle edges
- Temporal depth: recent items are vivid, older items dry and desaturated
- Search results that glow like light hitting oil paint
- Cluster halos with soft, organic boundaries

None of this is achievable with standard SwiftUI modifiers alone. We need a render pipeline that combines pre-baked assets with real-time GPU effects.

---

## Approach Comparison

Eight approaches were evaluated. The table below summarizes findings:

| # | Approach | Perf Impact | Complexity | Visual Quality | SwiftUI Native | Min macOS |
|---|----------|------------|------------|---------------|---------------|-----------|
| 1 | Core Image filters (CIFilter chains) | Low-Med | Low-Med | Low-Med | Indirect | 10.13 |
| 2 | **Metal shaders via SwiftUI** | **Very Low** | Medium | **High** | **Yes** | **14.0** |
| 3 | SpriteKit / SceneKit | Medium | High | Med-High | Partial | 11.0 |
| 4 | **Pre-rendered texture assets** | **None** | **Very Low** | High (texture) | **Yes** | Any |
| 5 | Core Graphics / Quartz | High | High | Very High | Via Canvas | Any |
| 6 | CALayer with custom drawing | Low | Low-Med | Same as #4 | Via bridge | Any |
| 7 | Third-party libraries | Varies | Low-Med | High | Indirect | Varies |
| 8 | **AI-generated asset pipeline** | **None** | Low | **Very High** | **Yes** | Any |

**Recommended**: Combine **#4 + #8** (pre-rendered AI-generated textures) with **#2** (Metal shaders via SwiftUI modifiers).

---

## Approach 1: Core Image Filters

### How It Works

Chain built-in `CIFilter`s — `CICrystallize`, `CIPointillize`, `CIComicEffect`, `CIEdges` — or write custom `CIKernel` filters in Metal Shading Language. The Kuwahara filter (available in GPUImage but not built into Core Image) is the gold standard for oil-painting abstraction.

### Code Example

**Swift 5.9+, macOS 10.13+**

```swift
import CoreImage
import CoreImage.CIFilterBuiltins

func applyPainterlyEffect(to image: CIImage) -> CIImage? {
    // Crystallize gives a faceted, stained-glass look
    let crystallize = CIFilter.crystallize()
    crystallize.inputImage = image
    crystallize.radius = 8

    guard let crystallized = crystallize.outputImage else { return nil }

    // Pointillize adds dot-based texture
    let pointillize = CIFilter.pointillize()
    pointillize.inputImage = crystallized
    pointillize.radius = 4

    return pointillize.outputImage
}
```

### Custom Kuwahara CIKernel

**Swift 5.9+, macOS 10.13+** (requires Metal Shading Language)

```swift
import CoreImage

// The CIKernel source is compiled from a .metal file
// See: Metal shader approach below for the actual kernel code
let kuwaharaKernel = try! CIKernel(functionName: "kuwahara",
                                    fromMetalLibraryData: metalLibData)

func kuwaharaFilter(image: CIImage, radius: Float) -> CIImage? {
    return kuwaharaKernel.apply(
        extent: image.extent,
        roiCallback: { _, rect in rect.insetBy(dx: CGFloat(-radius), dy: CGFloat(-radius)) },
        arguments: [image, radius]
    )
}
```

### Assessment

- **Performance**: Built-in filters are GPU-accelerated and fast. Complex chains (4+ filters) add latency. Kuwahara at radius 3 is feasible; radius 8+ gets expensive.
- **Visual quality**: Built-in filters alone produce a *stylized* look but not a convincing oil-painting effect — they tend toward posterization or halftone. Custom Kuwahara CIKernel: medium-high.
- **Verdict**: Good for processing *images within* clipboard history (thumbnails, previews). Not ideal for live UI chrome unless you snapshot-and-filter, which adds a frame of latency.

---

## Approach 2: Metal Shaders via SwiftUI Modifiers (RECOMMENDED)

### How It Works

Since macOS 14 Sonoma / iOS 17, SwiftUI exposes `.colorEffect()`, `.distortionEffect()`, and `.layerEffect()` modifiers that run Metal fragment shaders directly on any view. You write a `.metal` file with a `[[ stitchable ]]` function and SwiftUI calls it per-pixel on the GPU.

### Code Example — Basic Texture Overlay Shader

**Swift 5.9+, macOS 14.0+**

Create `CanvasTexture.metal`:

```metal
#include <metal_stdlib>
using namespace metal;

// Stitchable layer effect: composites a canvas weave texture over the view
[[ stitchable ]] half4 canvasOverlay(
    float2 position,
    SwiftUI::Layer layer,
    texture2d<half> canvasTexture [[ texture(0) ]],
    float intensity
) {
    // Sample the original view content
    half4 color = layer.sample(position);

    // Sample canvas texture (tiled)
    constexpr sampler textureSampler(address::repeat, filter::linear);
    float2 texCoord = position / float2(canvasTexture.get_width(), canvasTexture.get_height());
    half4 canvas = canvasTexture.sample(textureSampler, texCoord);

    // Blend: multiply mode gives that "painted on canvas" feel
    half4 result = color;
    result.rgb = mix(color.rgb, color.rgb * (canvas.rgb * 0.5 + 0.5), half(intensity));

    return result;
}
```

Apply in SwiftUI:

```swift
import SwiftUI

struct CanvasBackgroundModifier: ViewModifier {
    let intensity: Float

    func body(content: Content) -> some View {
        content
            .layerEffect(
                ShaderLibrary.canvasOverlay(
                    .image(Image("canvas-weave-tile")),
                    .float(intensity)
                ),
                maxSampleOffset: .zero
            )
    }
}

extension View {
    func canvasTexture(intensity: Float = 0.3) -> some View {
        modifier(CanvasBackgroundModifier(intensity: intensity))
    }
}
```

### Code Example — Kuwahara Brush-Stroke Filter

**Swift 5.9+, macOS 14.0+**

Create `Kuwahara.metal`:

```metal
#include <metal_stdlib>
using namespace metal;

// Kuwahara filter: creates oil-painting brush-stroke effect
// Divides the kernel into 4 quadrants, picks the one with lowest variance
[[ stitchable ]] half4 kuwahara(
    float2 position,
    SwiftUI::Layer layer,
    float radius
) {
    int r = int(radius);

    // Four quadrant accumulators
    half3 mean[4] = {};
    half3 sigma[4] = {};
    half count[4] = {};

    // Sample each quadrant
    for (int j = -r; j <= r; j++) {
        for (int i = -r; i <= r; i++) {
            half4 sample = layer.sample(position + float2(i, j));
            half3 c = sample.rgb;

            // Determine which quadrant(s) this sample belongs to
            // Quadrant 0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right
            if (i <= 0 && j <= 0) { mean[0] += c; sigma[0] += c * c; count[0] += 1.0; }
            if (i >= 0 && j <= 0) { mean[1] += c; sigma[1] += c * c; count[1] += 1.0; }
            if (i <= 0 && j >= 0) { mean[2] += c; sigma[2] += c * c; count[2] += 1.0; }
            if (i >= 0 && j >= 0) { mean[3] += c; sigma[3] += c * c; count[3] += 1.0; }
        }
    }

    // Find quadrant with minimum variance
    half minVariance = 1e10;
    half3 result = half3(0);

    for (int q = 0; q < 4; q++) {
        mean[q] /= count[q];
        sigma[q] = sigma[q] / count[q] - mean[q] * mean[q];
        half variance = sigma[q].r + sigma[q].g + sigma[q].b;

        if (variance < minVariance) {
            minVariance = variance;
            result = mean[q];
        }
    }

    return half4(result, layer.sample(position).a);
}
```

Apply in SwiftUI:

```swift
struct PopupContentView: View {
    var body: some View {
        VStack {
            // ... clipboard items
        }
        .layerEffect(
            ShaderLibrary.kuwahara(.float(3.0)),  // radius 3
            maxSampleOffset: CGSize(width: 3, height: 3)
        )
    }
}
```

### Code Example — Stroke Card with Bristle Edge

**Swift 5.9+, macOS 14.0+**

Create `BristleEdge.metal`:

```metal
#include <metal_stdlib>
using namespace metal;

// Distortion effect: creates irregular "bristle" edges on rounded rects
[[ stitchable ]] float2 bristleEdge(
    float2 position,
    float2 size,
    float amplitude,   // how much wobble (2-4px recommended)
    float frequency,   // how many wobbles per edge
    float seed         // varies per card for uniqueness
) {
    // Distance from center, normalized
    float2 center = size * 0.5;
    float2 d = (position - center) / center;

    // Only distort near the edges
    float edgeness = max(abs(d.x), abs(d.y));
    float edgeFactor = smoothstep(0.7, 1.0, edgeness);

    // Noise-based displacement
    float angle = atan2(d.y, d.x);
    float noise = sin(angle * frequency + seed * 17.3) * cos(angle * frequency * 0.7 + seed * 31.1);

    float2 offset = normalize(d) * noise * amplitude * edgeFactor;

    return position + offset;
}
```

Apply in SwiftUI:

```swift
struct StrokeCard: View {
    let item: ClipboardItem
    let cardSeed: Float  // unique per card

    var body: some View {
        cardContent
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .distortionEffect(
                ShaderLibrary.bristleEdge(
                    .float2(300, 80),   // card size
                    .float(2.5),        // amplitude
                    .float(12.0),       // frequency
                    .float(cardSeed)    // per-card variation
                ),
                maxSampleOffset: CGSize(width: 4, height: 4)
            )
    }
}
```

### Assessment

- **Performance**: Excellent. Simple shaders add sub-1ms. Kuwahara at radius 3-4 is feasible real-time.
- **Visual quality**: High. Full per-pixel control. Combine texture overlay + Kuwahara + bristle distortion.
- **SwiftUI integration**: Native first-class view modifiers.
- **Minimum macOS**: 14.0 Sonoma — hard floor.
- **Verdict**: **Primary recommended approach** for real-time painterly effects.

### Key References

- [WWDC24 — Create custom visual effects with SwiftUI](https://developer.apple.com/videos/play/wwdc2024/10151/)
- [How to add Metal shaders to SwiftUI views using layer effects — Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-metal-shaders-to-swiftui-views-using-layer-effects)
- [Metal Shaders in SwiftUI — Design+Code](https://designcode.io/swiftui-handbook-metal-shaders/)
- [A Beginner's Guide to Metal Shaders in SwiftUI — Medium](https://medium.com/@garejakirit/a-beginners-guide-to-metal-shaders-in-swiftui-5e98ef3cb222)

---

## Approach 3: SpriteKit / SceneKit Behind SwiftUI

### How It Works

Use `SpriteView` or `SceneView` as a background layer behind SwiftUI content. Apply `SKShader` or `SCNTechnique` for painterly post-processing.

### Code Example

**Swift 5.9+, macOS 11.0+**

```swift
import SpriteKit
import SwiftUI

class CanvasScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .clear

        // Canvas texture as background sprite
        let canvas = SKSpriteNode(imageNamed: "canvas-weave-tile")
        canvas.position = CGPoint(x: size.width / 2, y: size.height / 2)
        canvas.size = size
        canvas.blendMode = .multiply
        canvas.alpha = 0.3
        addChild(canvas)

        // Custom shader for painterly effect
        let shader = SKShader(fileNamed: "painterly.fsh")
        canvas.shader = shader
    }
}

struct CanvasBackground: View {
    var body: some View {
        SpriteView(scene: CanvasScene(size: CGSize(width: 400, height: 600)),
                   options: [.allowsTransparency])
            .ignoresSafeArea()
    }
}
```

### Assessment

- **Performance**: SpriteKit runs its own render loop (default 60fps). Memory overhead: 30-50MB for framework context.
- **Complexity**: High. Managing a scene graph and bridging coordinate systems.
- **Verdict**: Overkill. Metal shaders via SwiftUI modifiers achieve the same result more directly.

---

## Approach 4: Pre-Rendered Texture Assets (RECOMMENDED)

### How It Works

Generate oil-canvas textures offline and composite them as `Image` backgrounds in SwiftUI using blend modes.

### Code Example

**Swift 5.9+, macOS 11.0+**

```swift
import SwiftUI

struct CanvasTexturedBackground: View {
    var body: some View {
        ZStack {
            // Base warm gradient
            LinearGradient(
                colors: [Color(hex: "fbf7f1"), Color(hex: "efe8dd")],
                startPoint: .top,
                endPoint: .bottom
            )

            // Canvas weave texture (tileable, from asset catalog)
            Image("canvas-weave-tile")
                .resizable(resizingMode: .tile)
                .blendMode(.multiply)
                .opacity(0.15)

            // Subtle color wash for warmth
            RadialGradient(
                colors: [Color.indigo.opacity(0.05), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 600
            )
        }
    }
}

// Usage in popup window
struct PopupView: View {
    var body: some View {
        ZStack {
            CanvasTexturedBackground()

            VStack {
                // Clipboard items go here
            }
            .padding()
        }
        .frame(width: 400, height: 500)
    }
}
```

### Stroke Card with Texture Overlay

**Swift 5.9+, macOS 11.0+**

```swift
struct TexturedStrokeCard: View {
    let content: String
    let age: TimeInterval  // seconds since copy

    // Compute "dryness" — older items look more faded
    var dryness: Double {
        min(age / 3600.0, 1.0)  // fully dry after 1 hour
    }

    var body: some View {
        ZStack {
            // Card background with paint texture
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.78))
                .overlay(
                    Image("brush-stroke-overlay")
                        .resizable()
                        .blendMode(.softLight)
                        .opacity(0.2)
                )

            // Content
            Text(content)
                .font(.system(.body, design: .monospaced))
                .padding(14)
                .saturation(1.0 - dryness * 0.6)  // desaturate old items
                .opacity(1.0 - dryness * 0.3)      // fade old items
        }
        .shadow(color: .black.opacity(0.18), radius: 10, y: 6)
    }
}
```

### Assessment

- **Performance**: Zero runtime computation. Image blit: microseconds. Bundle cost: ~200KB-1MB per texture.
- **Complexity**: Very low for implementation. Medium for asset creation.
- **Visual quality**: High for canvas texture/grain. Gives texture but not brush-stroke abstraction on content — it's a surface treatment, not a filter.
- **Verdict**: **Strongly recommended as the base layer.** Combine with Metal shaders for the complete effect.

---

## Approach 5: Core Graphics / Quartz

### How It Works

Custom drawing in `CGContext` — programmatic brush strokes using `CGPath`, Bezier curves, randomized stroke width/opacity.

### Code Example

**Swift 5.9+, macOS 12.0+**

```swift
import SwiftUI

struct ProceduralCanvasTexture: View {
    var body: some View {
        Canvas { context, size in
            // Generate random brush strokes
            let strokeCount = 200

            for _ in 0..<strokeCount {
                let start = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
                let end = CGPoint(
                    x: start.x + CGFloat.random(in: -40...40),
                    y: start.y + CGFloat.random(in: -20...20)
                )

                var path = Path()
                path.move(to: start)

                // Bezier curve for organic stroke shape
                let control = CGPoint(
                    x: (start.x + end.x) / 2 + CGFloat.random(in: -15...15),
                    y: (start.y + end.y) / 2 + CGFloat.random(in: -15...15)
                )
                path.addQuadCurve(to: end, control: control)

                context.stroke(
                    path,
                    with: .color(.brown.opacity(Double.random(in: 0.02...0.08))),
                    lineWidth: CGFloat.random(in: 1...4)
                )
            }
        }
    }
}
```

### Assessment

- **Performance**: CPU-rendered. Drawing hundreds of strokes: ~50-200ms for a complex panel. Acceptable only if pre-rendered once and cached as a bitmap.
- **Complexity**: High. Writing a brush-stroke engine from scratch.
- **Visual quality**: Very high with enough iteration — full control over every mark.
- **Verdict**: Not recommended for real-time UI. Could be used as a **build-time tool** to generate texture assets (feeding into Approach 4).

---

## Approach 6: CALayer with Custom Drawing

### How It Works

Use `CALayer.contents` with pre-rendered textures, or subclass `CALayer` with custom `draw(in:)`.

### Code Example

**Swift 5.9+, macOS 11.0+**

```swift
import AppKit
import SwiftUI

class CanvasTextureLayer: CALayer {
    override init() {
        super.init()
        // Load canvas texture
        if let image = NSImage(named: "canvas-weave-tile") {
            self.contents = image
            self.contentsGravity = .resize
        }
        // Multiply compositing for "painted on canvas" effect
        self.compositingFilter = CIFilter(name: "CIMultiplyBlendMode")
        self.opacity = 0.15
    }

    required init?(coder: NSCoder) { fatalError() }
}

// Bridge into SwiftUI
struct CanvasLayerView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true

        let canvasLayer = CanvasTextureLayer()
        canvasLayer.frame = view.bounds
        canvasLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer?.addSublayer(canvasLayer)

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
```

### Assessment

- **Performance**: Good for static overlays — GPU-composited layers are fast.
- **Complexity**: Requires `NSViewRepresentable` bridge — more boilerplate than native SwiftUI Image overlay.
- **Verdict**: Functionally equivalent to Approach 4 but with more boilerplate. Prefer SwiftUI's native `Image` overlay.

---

## Approach 7: Third-Party Libraries

### GPUImage3

Metal-based image/video processing framework. BSD-licensed. Includes `KuwaharaFilter` and `KuwaharaRadius3Filter` (optimized).

**Repository**: [github.com/BradLarson/GPUImage3](https://github.com/BradLarson/GPUImage3)

```swift
// GPUImage3 Kuwahara usage (for reference — don't take runtime dependency)
import GPUImage

let kuwaharaFilter = KuwaharaRadius3Filter()
let output = kuwaharaFilter.filter(inputImage)
```

**Verdict**: Port the Kuwahara kernel code into a native `.metal` file for SwiftUI's `.layerEffect()`. Don't take a runtime dependency.

### Inferno

MIT-licensed Metal shaders purpose-built for SwiftUI. Includes noise, distortion, and color effects.

**Repository**: [github.com/twostraws/Inferno](https://github.com/twostraws/Inferno)

**Verdict**: Excellent reference code for writing custom SwiftUI-compatible Metal shaders. No oil-painting shader included, but the patterns are directly applicable.

### LYGIA Shader Library

Cross-platform shader library (GLSL/HLSL/Metal/WGSL). Includes Kuwahara filter implementations.

**Repository**: [lygia.xyz](https://lygia.xyz/filter/kuwahara)

**Verdict**: The Metal-compatible Kuwahara shader code can be adapted directly into a `.metal` file. Great reference, not a runtime dependency.

### MetalPetal

GPU-accelerated image processing on Metal.

**Repository**: [github.com/MetalPetal/MetalPetal](https://github.com/MetalPetal/MetalPetal)

**Verdict**: More focused on photo/video pipelines than UI effects. Low relevance.

### Filterpedia

Core Image Filter Explorer — useful for prototyping CIFilter chains.

**Repository**: [github.com/FlexMonkey/Filterpedia](https://github.com/FlexMonkey/Filterpedia)

**Verdict**: Useful for exploring what built-in CIFilters can do. Not a runtime dependency.

---

## Approach 8: AI-Generated Asset Pipeline (RECOMMENDED)

### How It Works

Use Stable Diffusion, DALL-E, Midjourney, or similar to generate seamless/tileable canvas textures at build time. Include as static assets.

### Asset Generation Guide

#### Tileable Canvas Textures

Use Stable Diffusion with the **Tiling** VAE option:

```
Prompt: "seamless tileable oil canvas texture, linen weave, warm cream color,
         subtle thread pattern, overhead flat lighting, no objects,
         texture only, 8k detail"
Negative: "text, watermark, logo, objects, shadows, perspective"
Steps: 30-40
CFG Scale: 7-9
Sampler: DPM++ 2M Karras
Size: 1024x1024
Tiling: enabled
```

#### Brush-Stroke Overlays (Transparent)

```
Prompt: "single oil paint brush stroke on transparent background,
         thick impasto texture, warm earth tones, side lighting
         showing paint thickness, isolated stroke"
Negative: "canvas, background, multiple strokes, text"
Steps: 30
Size: 512x128 (wide format for card overlays)
```

#### Painted Gradient Backgrounds

```
Prompt: "abstract oil painting gradient, warm cream to soft indigo,
         visible brushwork, gentle color transition, canvas texture,
         no objects, no figures, background only"
Negative: "sharp edges, digital, flat, objects, text"
Steps: 40
Size: 1024x1024
```

### Asset Catalog Structure

```
Assets.xcassets/
├── canvas-weave-tile.imageset/       # Tileable base texture
│   ├── canvas-weave-tile@1x.png      # 512x512
│   └── canvas-weave-tile@2x.png      # 1024x1024
├── canvas-weave-dark.imageset/       # Dark mode variant
│   ├── canvas-weave-dark@1x.png
│   └── canvas-weave-dark@2x.png
├── brush-stroke-overlay.imageset/    # Card overlay
│   ├── brush-stroke-overlay@1x.png
│   └── brush-stroke-overlay@2x.png
├── bristle-edge-mask.imageset/       # Edge mask for stroke cards
│   ├── bristle-edge-mask@1x.png
│   └── bristle-edge-mask@2x.png
└── cluster-halo-glow.imageset/       # Soft glow for clusters
    ├── cluster-halo-glow@1x.png
    └── cluster-halo-glow@2x.png
```

### Assessment

- **Performance**: Zero runtime cost — pre-baked PNGs in bundle.
- **Complexity**: Low for integration. Medium for pipeline setup.
- **Visual quality**: Very high. AI generators excel at realistic canvas/paint textures.
- **Verdict**: **Strongly recommended for the texture layer.** Pair with Metal shaders (Approach 2) for the complete effect.

---

## Recommended Architecture

### Layer Stack

```
┌─────────────────────────────────────────────────┐
│              SwiftUI View Stack                  │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  Layer 1: Canvas texture                  │  │  ← Approach 8 (zero cost)
│  │  (Image + .blendMode(.multiply))          │  │
│  ├───────────────────────────────────────────┤  │
│  │  Layer 2: UI content (strokes, clusters)  │  │  ← Normal SwiftUI views
│  │  with per-card texture overlays           │  │    + Approach 4 overlays
│  ├───────────────────────────────────────────┤  │
│  │  Layer 3: Metal shader overlay            │  │  ← Approach 2 (.layerEffect)
│  │  (Lightweight Kuwahara or brush           │  │    Subtle brush-stroke distortion
│  │   distortion, radius 2-3)                 │  │    on composited view
│  └───────────────────────────────────────────┘  │
│                                                 │
│  Total added latency: ~1-3ms (GPU)              │
│  Well within 50ms popup target                  │
└─────────────────────────────────────────────────┘
```

### Phased Implementation

| Phase | Deliverable | Latency Risk |
|-------|------------|-------------|
| **0.5a** | Canvas textures + stroke cards with bristle-edge masks. SwiftUI only, no Metal shaders. | None |
| **0.5b** | Metal `.layerEffect` Kuwahara shader (radius 3) on popup background. Port from GPUImage3/LYGIA. | ~1-3ms |
| **0.5c** (deferred) | Anisotropic Kuwahara with Voronoi brush direction for image preview thumbnails. | ~5-8ms on previews only |

### Source File Layout

```
src/
├── Sources/PasteBin/
│   ├── Rendering/
│   │   ├── Shaders/
│   │   │   ├── CanvasTexture.metal     # Canvas weave overlay
│   │   │   ├── Kuwahara.metal          # Brush-stroke abstraction
│   │   │   └── BristleEdge.metal       # Irregular edge distortion
│   │   ├── CanvasBackground.swift      # Textured background view
│   │   ├── StrokeCardStyle.swift       # Painterly card styling
│   │   └── TemporalFade.swift          # Age-based desaturation
│   └── ...
├── Assets.xcassets/
│   ├── canvas-weave-tile.imageset/
│   ├── canvas-weave-dark.imageset/
│   ├── brush-stroke-overlay.imageset/
│   └── ...
└── scripts/
    └── generate-textures.sh            # AI texture generation pipeline
```

---

## Gotchas

- **`maxSampleOffset`**: When using `.layerEffect()` or `.distortionEffect()`, you must set `maxSampleOffset` to at least the shader's kernel radius. If too small, the shader clips. If too large, performance degrades.
- **Tiling seams**: AI-generated textures may have subtle seams even with tiling mode. Always test at 2x zoom. Use Stable Diffusion's "Tiling" checkbox, not post-processing.
- **Dark mode**: Canvas textures need separate light/dark variants. The warm linen look doesn't work on dark backgrounds — use a dark slate canvas with cooler tones instead.
- **Retina**: Always provide @2x assets. The canvas weave at @1x will look blurry on Retina displays and destroy the tactile feel.
- **Metal compilation**: `[[ stitchable ]]` shaders are compiled at runtime on first use. The first popup appearance may have a ~20-50ms penalty. Mitigate by pre-warming the shader pipeline at app launch.

### Shader Pre-Warming

```swift
// Call during app initialization, before first popup
func prewarmShaders() {
    // Create a tiny offscreen view with the shader applied
    // This forces Metal to compile the shader programs
    let warmupView = Rectangle()
        .frame(width: 1, height: 1)
        .layerEffect(
            ShaderLibrary.kuwahara(.float(3.0)),
            maxSampleOffset: CGSize(width: 3, height: 3)
        )
    // Render once to trigger compilation
    let renderer = ImageRenderer(content: warmupView)
    _ = renderer.nsImage
}
```

## Performance Considerations

- Canvas texture overlay: **0ms** (just an image blit, composited by the window server)
- Bristle edge distortion: **<0.5ms** (simple math, no texture sampling)
- Kuwahara radius 3: **~1-2ms** on Apple Silicon, ~2-4ms on Intel
- Full stack (all three layers): **~1-3ms on Apple Silicon**
- Budget remaining for UI content rendering: **~46ms** of the 50ms target

## Threading

- Metal shaders run on GPU — they do not block the main thread
- Texture assets are loaded from the asset catalog on the main thread (first access only, then cached)
- Pre-warm shaders on a background queue during app launch

## Security

- AI-generated textures should be reviewed before shipping — ensure no unintended content
- Metal shaders execute in a sandboxed GPU context — no security risk from shader code

---

## References

### Official Apple Documentation
- [ShaderLibrary — Apple Developer](https://developer.apple.com/documentation/swiftui/shaderlibrary) — SwiftUI shader integration
- [Shader — Apple Developer](https://developer.apple.com/documentation/swiftui/shader) — Shader type reference
- [Metal Shading Language Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf) — Complete MSL reference
- [CIFilter — Apple Developer](https://developer.apple.com/documentation/coreimage/cifilter) — Core Image filter reference

### WWDC Sessions
- [Create custom visual effects with SwiftUI — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10151/) — Definitive guide to SwiftUI shaders
- [Discover Metal enhancements for A17 Pro and M3 — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10122/) — Metal performance features

### Community Resources
- [On Crafting Painterly Shaders — Maxime Heckel](https://blog.maximeheckel.com/posts/on-crafting-painterly-shaders/) — Anisotropic Kuwahara + Voronoi noise implementation
- [How to add Metal shaders to SwiftUI views — Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-metal-shaders-to-swiftui-views-using-layer-effects)
- [Metal Shaders in SwiftUI — Design+Code](https://designcode.io/swiftui-handbook-metal-shaders/)
- [A Beginner's Guide to Metal Shaders in SwiftUI — Medium](https://medium.com/@garejakirit/a-beginners-guide-to-metal-shaders-in-swiftui-5e98ef3cb222)

### Libraries (Reference, Not Runtime Dependencies)
- [Inferno — Metal shaders for SwiftUI (MIT)](https://github.com/twostraws/Inferno)
- [GPUImage3 — Metal image processing (BSD)](https://github.com/BradLarson/GPUImage3)
- [LYGIA — Cross-platform shader library](https://lygia.xyz/filter/kuwahara)
- [MetalPetal — GPU image processing](https://github.com/MetalPetal/MetalPetal)
- [Filterpedia — Core Image Filter Explorer](https://github.com/FlexMonkey/Filterpedia)
- [MetalCanvas — Metal shader rendering](https://github.com/NakaokaRei/MetalCanvas)

### AI Texture Generation
- [Stable Diffusion Tiling Guide — AIArty](https://www.aiarty.com/stable-diffusion-guide/stable-diffusion-tiling.htm)
- [How to Make Seamless Textures with AI — Next Diffusion](https://www.nextdiffusion.ai/tutorials/how-to-make-seamless-textures-with-ai-stable-diffusion)

### Academic
- [Kuwahara Filter — Wikipedia](https://en.wikipedia.org/wiki/Kuwahara_filter) — Algorithm overview
- Aaron Hertzmann, "Painterly Rendering with Curved Brush Strokes of Multiple Sizes" (SIGGRAPH 1998) — Foundational stroke-based rendering paper

---

## Version Notes

- **macOS 14.0 Sonoma**: SwiftUI `.colorEffect()`, `.distortionEffect()`, `.layerEffect()` introduced. Required for Metal shader approach.
- **macOS 12.0 Monterey**: SwiftUI `Canvas` view introduced. Required for Core Graphics procedural approach.
- **macOS 11.0 Big Sur**: `SpriteView` SwiftUI integration introduced.
- **macOS 10.13 High Sierra**: Custom `CIKernel` from Metal Shading Language. Required for Core Image custom kernel approach.

<!-- nav -->

---

[< Previous: UX Patterns](../spec/solution-analysis/10-ux-patterns.md) | [Table of Contents](../product-spec.md)

<!-- nav -->
