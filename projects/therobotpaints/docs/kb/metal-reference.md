# Metal Reference — Patterns from KopiGajj

**Last Updated:** 2026-04-22
**Source:** `../kopigajj/` (Stage 0.5, working paint simulation engine)
**Purpose:** Proven Metal patterns to reuse in The Robot Paints

---

## Architecture Overview

KopiGajj is a working GPU-accelerated paint simulator with 5 media types, 5 brush tips, and 8 artistic filters. Its Metal implementation is the most direct reference for our project. Key facts:

- **Swift 5.9**, macOS 14+, SPM executable (not Xcode project)
- **All Metal shaders are runtime-compiled from Swift string literals** — no `.metal` files in the build
- **Compute-only pipeline** — no render pipeline, no MTKView. Results are read back to `NSImage` and drawn via `NSView.draw(_:)`
- **Two independent Metal engines**: `PaintSimulator` (5 kernels) and `CanvasMetalRenderer` (8 filter kernels)
- **Threadgroup size**: 16×16 on all kernels
- **Default texture size**: 1024×1024
- **Frame budget**: ~1-3ms per paint sim step on Apple Silicon

### Why This Matters For Us

KopiGajj's approach is proven and working. Our MPM architecture adds SPH particles and layered volumes on top of the same Metal compute foundation. We should reuse:

1. The **protocol-based Metal boilerplate** (compiler + texture factory)
2. The **runtime shader compilation** pattern (avoids SPM `.metal` headaches)
3. The **CPU → GPU data transfer** pattern (struct-per-brush-point)
4. The **double-buffered ping-pong** texture pattern
5. The **GPU → CPU readback** pipeline (texture → staging buffer → `CGImage` → `NSImage`)

---

## Pattern 1: Runtime Shader Compilation

**Problem:** SPM doesn't compile `.metal` files. Xcode does, but we use SPM.

**KopiGajj's Solution:** Store all MSL source as `static let` Swift strings. Compile at runtime via `MTLDevice.makeLibrary(source:options:)`.

### File: `MetalShaderCompiler.swift`

```swift
import Metal

protocol MetalShaderCompiler {
    var device: MTLDevice { get }
}

extension MetalShaderCompiler {
    func compileComputePipeline(source: String, functionName: String) throws -> MTLComputePipelineState {
        try Self.compileComputePipeline(device: device, source: source, functionName: functionName)
    }

    func compileComputePipelines(source: String, functionNames: [String]) throws -> [String: MTLComputePipelineState] {
        try Self.compileComputePipelines(device: device, source: source, functionNames: functionNames)
    }

    static func compileComputePipeline(device: MTLDevice, source: String, functionName: String) throws -> MTLComputePipelineState {
        let library = try device.makeLibrary(source: source, options: nil)
        guard let fn = library.makeFunction(name: functionName) else {
            throw MetalShaderError.functionNotFound(functionName)
        }
        return try device.makeComputePipelineState(function: fn)
    }

    static func compileComputePipelines(device: MTLDevice, source: String, functionNames: [String]) throws -> [String: MTLComputePipelineState] {
        let library = try device.makeLibrary(source: source, options: nil)
        var pipelines: [String: MTLComputePipelineState] = [:]
        for name in functionNames {
            guard let fn = library.makeFunction(name: name) else {
                throw MetalShaderError.functionNotFound(name)
            }
            pipelines[name] = try device.makeComputePipelineState(function: fn)
        }
        return pipelines
    }
}

enum MetalShaderError: Error {
    case functionNotFound(String)
}
```

**Key details:**
- Static variants allow use during `init` before `self` is fully initialized
- Single library compilation → multiple pipeline extraction is efficient
- Error thrown for missing function names (not a crash)

### Shader Source Organization

Shaders live as Swift string literals in an `enum PaintShaderSource`:

```
PaintShaderHeader.swift       — Shared structs (BrushPoint, params, noise, tip profiles)
PaintShaderCanvasInit.swift   — canvasInit kernel
PaintShaderBrushStroke.swift  — brushStroke kernel
PaintShaderFlowDry.swift      — flowStep + dryStep kernels
PaintShaderRender.swift       — paintRender kernel
PaintShaderFilters.swift      — 8 image filter kernels
```

Each kernel is `header + "kernel void ..."`. The header is prepended to every kernel source so each compiles independently with all shared types.

### Our Adaptation

We should follow the same pattern:
1. `ShaderHeader.swift` — shared MSL structs (VolumeLayer, SPHParticle, params)
2. `ShaderCanvasInit.swift` — canvas init kernel
3. `ShaderBrushDeposition.swift` — brush deposit kernel
4. `ShaderSPHPhysics.swift` — SPH neighbor search + physics update
5. `ShaderFluidDynamics.swift` — Eulerian grid flow/diffusion
6. `ShaderDrying.swift` — per-medium drying kinetics
7. `ShaderRender.swift` — layer compositing + lighting

---

## Pattern 2: Texture Factory

**File:** `MetalTextureFactory.swift`

```swift
import Metal

protocol MetalTextureFactory {
    var device: MTLDevice { get }
}

extension MetalTextureFactory {
    func makeTexture2D(
        width: Int, height: Int, pixelFormat: MTLPixelFormat,
        usage: MTLTextureUsage = [.shaderRead, .shaderWrite],
        storageMode: MTLStorageMode = .private
    ) -> MTLTexture? {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: pixelFormat, width: width, height: height, mipmapped: false)
        desc.usage = usage
        desc.storageMode = storageMode
        return device.makeTexture(descriptor: desc)
    }

    func makeTexture2DOrThrow(...) throws -> MTLTexture { ... }
    // + static variants for use during init
}

enum MetalTextureError: Error {
    case allocationFailed
}
```

**Pixel formats used:**

| Format | Channels | Use Case |
|--------|----------|----------|
| `rgba16Float` | 4×FP16 | Wet/solid absorption, properties, canvas props |
| `r32Float` | 1×FP32 | Height map (needs full precision) |
| `rgba8Unorm` | 4×Uint8 | Final output for display |

**Our adaptation:** We'll need additional textures for SPH (particle density maps, velocity fields) but the factory protocol is directly reusable.

---

## Pattern 3: Double-Buffered Textures (Ping-Pong)

Simulation steps read from one texture and write to another. The buffers swap after each step.

```swift
final class PaintField: MetalTextureFactory {
    var wetAbsorbTex: MTLTexture    // Buffer A
    var wetAbsorbTexB: MTLTexture   // Buffer B
    var phase: Int = 0

    var readWetAbsorb: MTLTexture  { phase % 2 == 0 ? wetAbsorbTex : wetAbsorbTexB }
    var writeWetAbsorb: MTLTexture { phase % 2 == 0 ? wetAbsorbTexB : wetAbsorbTex }

    func flip() { phase += 1 }
}
```

Each simulation step:
1. Reads from `readWetAbsorb` / `readProps`
2. Writes to `writeWetAbsorb` / `writeProps`
3. Calls `field.flip()` to swap

**Why not read-write on same texture?** A compute shader can read and write the same texture, but neighboring pixels reading stale data creates race conditions. Ping-pong ensures clean reads.

**Our adaptation:** Our SPH particle buffer and volume layer textures should use the same ping-pong pattern for flow/diffusion steps.

---

## Pattern 4: CPU → GPU Data Transfer (Brush Points)

**Swift struct (56 bytes, all flat floats):**
```swift
struct BrushPoint {
    var x: Float
    var y: Float
    var pressure: Float
    var radius: Float
    var absR: Float
    var absG: Float
    var absB: Float
    var concentration: Float
    var viscosity: Float
    var tipType: Float
    var angle: Float
    var dirX: Float
    var dirY: Float
    var wetness: Float
    static let stride = MemoryLayout<BrushPoint>.stride
}
```

**Metal struct (must match exactly):**
```metal
struct BrushPoint {
    float posX;
    float posY;
    float pressure;
    float radius;
    float absR;
    float absG;
    float absB;
    float concentration;
    float viscosity;
    float tipType;
    float angle;
    float dirX;
    float dirY;
    float wetness;
};
```

**Transfer pattern:**
```swift
let pointBuffer = device.makeBuffer(
    bytes: points,
    length: points.count * BrushPoint.stride,
    options: .storageModeShared    // CPU+GPU accessible (Apple Silicon)
)
encoder.setBuffer(pointBuffer, offset: 0, index: 0)
```

**Critical rule:** Swift and Metal struct layouts must match byte-for-byte. All-flat-floats avoids alignment padding issues. Never use `Bool`, `enum`, or nested structs that might differ between Swift and MSL.

**Small params use `setBytes`:**
```swift
var count = Int32(points.count)
var modeVal = mode.modeIndex
encoder.setBytes(&count, length: 4, index: 1)
encoder.setBytes(&modeVal, length: 4, index: 2)
```

`setBytes` copies small values directly into the command buffer — no separate `MTLBuffer` needed. Use for params under ~4KB.

---

## Pattern 5: GPU → CPU Readback (Texture to NSImage)

KopiGajj reads the output texture back to CPU for display in an `NSView`. This is the synchronous path (used when not doing live MTKView rendering):

```swift
private func readbackOutput() -> NSImage? {
    let w = field.width, h = field.height, bpr = w * 4

    // 1. Create staging texture (.managed = CPU-visible)
    guard let staging = makeTexture2D(
        width: w, height: h, pixelFormat: .rgba8Unorm,
        usage: [.shaderWrite], storageMode: .managed
    ) else { return nil }

    // 2. Blit from GPU-private to CPU-managed
    guard let buf = commandQueue.makeCommandBuffer(),
          let blit = buf.makeBlitCommandEncoder() else { return nil }
    blit.copy(from: field.outputTex, sourceSlice: 0, sourceLevel: 0,
              sourceOrigin: MTLOrigin(), sourceSize: MTLSize(width: w, height: h, depth: 1),
              to: staging, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin())
    blit.synchronize(resource: staging)  // Required on macOS
    blit.endEncoding()
    buf.commit()
    buf.waitUntilCompleted()             // Synchronous

    // 3. Read pixels from staging texture
    var pixels = [UInt8](repeating: 0, count: h * bpr)
    staging.getBytes(&pixels, bytesPerRow: bpr,
                     from: MTLRegion(origin: MTLOrigin(), size: MTLSize(width: w, height: h, depth: 1)),
                     mipmapLevel: 0)

    // 4. Create CGImage → NSImage
    guard let ctx = CGContext(data: &pixels, width: w, height: h,
                              bitsPerComponent: 8, bytesPerRow: bpr,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
          let cgImage = ctx.makeImage() else { return nil }
    return NSImage(cgImage: cgImage, size: NSSize(width: w, height: h))
}
```

**Three-step process:**
1. GPU-private texture → CPU-managed staging texture (blit copy)
2. `synchronize(resource:)` ensures GPU writes are visible to CPU
3. `getBytes` → `CGContext` → `CGImage` → `NSImage`

**Storage modes:**
- `.private` — GPU-only, fastest access. Use for simulation textures.
- `.managed` — CPU+GPU, requires `synchronize()`. Use for readback staging.
- `.shared` — CPU+GPU unified memory (Apple Silicon). Use for brush point buffers.

**Our adaptation:** For live rendering at 60fps, we should use `MTKView` (MetalKit) instead of readback — the drawable texture is written directly by the GPU. Readback is only needed for export/save. But the pattern above is essential for both.

---

## Pattern 6: Compute Dispatch

Every kernel follows the same dispatch pattern:

```swift
private let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)

private var threadgroups: MTLSize {
    MTLSize(width: (field.width + 15) / 16, height: (field.height + 15) / 16, depth: 1)
}

// In each simulation step:
encoder.setComputePipelineState(pipeline)
encoder.setTexture(field.readWetAbsorb, index: 0)
encoder.setTexture(field.readProps, index: 1)
// ... set all textures and buffers
encoder.setBytes(&params, length: MemoryLayout<SimGPUParams>.size, index: 0)
encoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
encoder.endEncoding()
```

**Boundary check in shader:**
```metal
kernel void myKernel(..., uint2 gid [[thread_position_in_grid]]) {
    int w = texture.get_width();
    int h = texture.get_height();
    if (int(gid.x) >= w || int(gid.y) >= h) return;
    // ... kernel body
}
```

The threadgroup count is ceiling-divided so it always covers the full texture. The shader itself rejects out-of-bounds threads.

---

## Pattern 7: Absorption Color Model

KopiGajj uses **absorption values** (not RGB reflectance) for paint color. This is physically correct for subtractive pigment mixing.

**Storage:** `absorption` = 0 means transparent (no pigment). Higher values = more opaque.

**Rendering (Beer-Lambert law):**
```metal
float3 visibleColor = canvasColor * exp(-absorption * concentration);
```

- High absorption + high concentration → very dark (opaque pigment blocks light)
- Low absorption → transparent (pigment doesn't absorb much)
- Multiple layers: absorptions ADD (physically correct subtractive mixing)

**Conversion (Swift-side):**
```swift
static func reflectanceToAbsorption(_ reflectance: Float) -> Float {
    -log(max(reflectance, 0.001))  // R=1 → abs=0, R=0 → abs=~7
}
```

**Why not just RGB?** Additive RGB mixing (layer A + layer B) doesn't model paint correctly. Yellow + blue paint makes green, not white. Absorption space gives:
- `absYellow + absBlue = absGreen` (subtractive mixing works naturally)
- `exp(-absYellow - absBlue)` produces the correct darkened result

**Our adaptation:** We should adopt absorption color model. It's proven in kopigajj and our voxel-architecture.md already references Beer-Lambert rendering.

---

## Pattern 8: SPM + Metal File Handling

**Package.swift:**
```swift
// swift-tools-version: 5.9
.executableTarget(
    name: "KopiGajj",
    dependencies: [],
    path: "Sources/KopiGajj",
    exclude: ["Rendering/Shaders"]  // .metal files excluded from SPM build
)
```

The `.metal` files in `Rendering/Shaders/` exist for Xcode syntax highlighting and the SwiftUI `[[ stitchable ]]` shader integration (`.layerEffect()`, etc.). They are **excluded from SPM compilation** because:
1. SPM doesn't know how to compile `.metal` files
2. All compute shaders are runtime-compiled from Swift strings
3. Including them would cause build errors

**For our project:** We should follow the same approach initially — all MSL as Swift strings. If we later want Xcode syntax highlighting for `.metal` files, add them to a `Shaders/` directory and exclude it in Package.swift.

---

## Pattern 9: Testing Metal Shaders

KopiGajj tests shader compilation explicitly:

```swift
func testMetal_allPaintKernelsCompile() throws {
    let helper = try TestMetalHelper.requireDevice()
    let device = helper.device

    let kernels: [(source: String, name: String)] = [
        (PaintShaderSource.canvasInit, "canvasInit"),
        (PaintShaderSource.brushStroke, "brushStroke"),
        (PaintShaderSource.flowStep, "flowStep"),
        (PaintShaderSource.dryStep, "dryStep"),
        (PaintShaderSource.render, "paintRender"),
    ]

    for (source, name) in kernels {
        XCTAssertNoThrow(
            try PaintSimulator.compileComputePipeline(device: device, source: source, functionName: name),
            "Failed to compile kernel: \(name)"
        )
    }
}
```

`TestMetalHelper` creates a Metal device with `XCTSkip` fallback for CI environments without GPUs.

**Our adaptation:** Write compilation tests for every kernel. This catches MSL syntax errors at test time instead of runtime crashes.

---

## Pattern 10: Synchronous vs Async GPU Work

KopiGajj uses **synchronous** GPU work (`buf.waitUntilCompleted()`) everywhere. This works because:

1. The paint simulation is not a 60fps game loop — it runs on demand
2. Each kernel is fast (~1-3ms total per frame)
3. The app renders to an `NSImage` that's displayed once

**For our app**, we need **asynchronous** rendering for the live canvas at 60fps. The pattern:

```swift
// Synchronous (KopiGajj style — for simulation steps, export)
buf.commit()
buf.waitUntilCompleted()

// Asynchronous (our style — for live rendering)
buf.addCompletedHandler { _ in
    // Update state, schedule next frame
}
buf.present(drawable)  // Present to screen
buf.commit()
```

The simulation pipeline can stay synchronous (like kopigajj). Only the final render + present needs to be async via `MTKView`.

---

## Swift 6 Concurrency Notes

KopiGajj uses Swift 5.9 without strict concurrency. For Swift 6, we need to handle:

### MetalEngine (shared singleton)

```swift
// Option A: @unchecked Sendable (Metal objects are genuinely thread-safe)
final class MetalEngine: @unchecked Sendable {
    static let shared = MetalEngine()
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let renderPipelineState: MTLRenderPipelineState
    private init() { ... }
}
```

### Renderer (MTKViewDelegate)

```swift
// Renderer is called from render thread (CVDisplayLink)
// Must be Sendable to satisfy SwiftUI's coordinator requirements
final class Renderer: NSObject, @unchecked Sendable, MTKViewDelegate {
    private let commandQueue: MTLCommandQueue
    private let renderPipelineState: MTLRenderPipelineState
    private let startTime = CFAbsoluteTimeGetCurrent()

    init(commandQueue: MTLCommandQueue, renderPipelineState: MTLRenderPipelineState) {
        self.commandQueue = commandQueue
        self.renderPipelineState = renderPipelineState
        super.init()
    }

    func draw(in view: MTKView) { ... }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
```

**Why `@unchecked Sendable`?** `MTLDevice`, `MTLCommandQueue`, and pipeline states are immutable once created and thread-safe by Metal's design. The formal `Sendable` conformance isn't declared by Apple, but it's safe.

### NSViewRepresentable

```swift
struct MetalView: NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        let engine = MetalEngine.shared
        view.device = engine.device
        view.delegate = context.coordinator
        view.colorPixelFormat = .bgra8Unorm
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.preferredFramesPerSecond = 60
        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}

    func makeCoordinator() -> Renderer {
        let engine = MetalEngine.shared
        return Renderer(
            commandQueue: engine.commandQueue,
            renderPipelineState: engine.renderPipelineState
        )
    }
}
```

---

## Key Differences: KopiGajj vs The Robot Paints

| Aspect | KopiGajj | The Robot Paints |
|--------|----------|------------------|
| Rendering | NSView + CGImage readback | MTKView live rendering (60fps) |
| Simulation | Texture-only (no particles) | MPM: texture layers + SPH particles |
| Color model | Absorption (Beer-Lambert) | Absorption (same) |
| Shader source | Swift string literals | Swift string literals (same) |
| Threading | Sync GPU + async sim dispatch | Async render + async sim |
| Brush input | NSView mouse events | NSView mouse events (same) |
| Interpolation | Catmull-Rom spline | Catmull-Rom spline (same) |
| Texture format | rgba16Float + r32Float | Same + particle density maps |
| Layers | Wet/Solid/Canvas (flat 2D) | 8-layer z-stack per pixel |
| Swift version | 5.9 | 6.0 (strict concurrency) |
| Threadgroups | 16×16 | 16×16 (same) |

---

## File Reference Map

| KopiGajj File | What It Does | Our Equivalent |
|---------------|-------------|----------------|
| `MetalShaderCompiler.swift` | Protocol: MSL source → compute pipeline | Direct reuse |
| `MetalTextureFactory.swift` | Protocol: texture allocation | Direct reuse |
| `PaintShaderHeader.swift` | Shared MSL structs + noise + tip profiles | New header with VolumeLayer, SPHParticle |
| `PaintShaderCanvasInit.swift` | Canvas texture generation kernel | New canvas init for MPM layers |
| `PaintShaderBrushStroke.swift` | Brush deposition kernel | New deposition kernel (volume + particles) |
| `PaintShaderFlowDry.swift` | Flow + drying kernels | New SPH + flow + drying kernels |
| `PaintShaderRender.swift` | Lit composite rendering kernel | New layer-stack compositor |
| `PaintField.swift` | Texture storage + BrushPoint struct | New VolumeField + SPH structs |
| `PaintSimulator.swift` | Pipeline orchestration | New MPMSimulator |
| `CanvasMetalRenderer.swift` | Image filter pipeline | Post-processing filters (future) |
| `PaintCanvasNSView.swift` | Mouse input + throttled GPU dispatch | New canvas input handler |
| `PaintCanvasView.swift` | SwiftUI wrapper | Our MetalView |
| `RenderingBootstrap.swift` | Pre-warm Metal at launch | Our app init |
| `TestMetalHelper.swift` | Metal test utilities | Direct reuse |
| `MetalShaderCompilationTests.swift` | Shader compilation tests | New test suite |

---

## Performance Data (from KopiGajj, Apple Silicon)

| Operation | Time | Notes |
|-----------|------|-------|
| Metal pipeline compile | 20-50ms | One-time, pre-warm at launch |
| Canvas init kernel | 5-10ms | One-time, cached |
| Paint sim frame (5 kernels) | 1-3ms | Per-stroke |
| Image filter pass | 1-2ms | Single kernel |
| Oil Paint filter (multi-pass) | 2-4ms | N iterations |
| GPU readback (1024×1024) | ~1ms | Blit + synchronize |
| Brush point buffer upload | <0.1ms | .storageModeShared |

**Budget:** KopiGajj targets <3ms for paint sim within a 50ms popup target. Our 60fps target gives us 16.6ms per frame — comfortable for sim + render.

---

## References

### KopiGajj Docs
- `kopigajj/docs/arch/render-pipeline.md` — Full pipeline architecture
- `kopigajj/docs/05-metal-shaders-swiftui.md` — SwiftUI shader integration ([[ stitchable ]])
- `kopigajj/docs/11-canvas-render-engine.md` — Approach comparison (8 methods evaluated)
- `kopigajj/docs/PROJ-ARCH.md` — System diagram + key decisions
- `kopigajj/docs/arch/data-flow.md` — Event pipeline

### Apple Documentation
- [Metal Programming Guide](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/) — Foundation
- [Metal Shading Language Specification (PDF)](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf) — MSL reference
- [MetalKit](https://developer.apple.com/documentation/metalkit/) — MTKView reference
- [MTLComputePipelineState](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate) — Compute pipeline

### WWDC Sessions
- [WWDC24: Create custom visual effects with SwiftUI](https://developer.apple.com/videos/play/wwdc2024/10151/) — SwiftUI shader integration
- [WWDC23: Discover Metal enhancements for A17 Pro and M3](https://developer.apple.com/videos/play/wwdc2023/10122/) — Performance features
- [WWDC22: Go bindless with Metal 3](https://developer.apple.com/videos/play/wwdc2022/10129/) — Modern Metal patterns

### Community
- [Inferno — SwiftUI Metal shaders (MIT)](https://github.com/twostraws/Inferno) — `[[ stitchable ]]` patterns
- [GPUImage3 — Metal image processing (BSD)](https://github.com/BradLarson/GPUImage3) — Production filter implementations
- [Metal by Example](https://metalbyexample.com/) — Tutorial series
