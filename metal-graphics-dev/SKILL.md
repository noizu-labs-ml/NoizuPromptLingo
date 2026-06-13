---
name: trl-metal-graphics-dev
description: >
  Design and develop GPU-accelerated macOS applications using Apple's Metal API,
  including shader authoring, render/compute pipelines, and performance profiling.
  Use this skill when the user wants to build a Metal app, write Metal shaders,
  create GPU compute kernels, set up a Metal render pipeline, profile GPU performance,
  design a graphics application architecture, or implement real-time rendering
  — even if they don't say "Metal." Also trigger when users mention MSL, Metal
  Shading Language, GPU programming on macOS, vertex/fragment shaders for Apple
  platforms, CAMetalLayer, MTKView, compute pipelines, or graphics programming
  for iOS/visionOS.
---

# Metal Graphics Dev

Design, build, and optimize GPU-accelerated applications on Apple platforms using the Metal API.

## Overview

This skill covers the full lifecycle of Metal-based graphics and compute application development — from first triangle to production-quality renderers with advanced profiling. It provides:

- **Application architecture** — SwiftUI/AppKit integration patterns, CAMetalLayer setup, MTKView lifecycle, triple-buffering, and frame pacing
- **Shader development** — Metal Shading Language (MSL) authoring, vertex/fragment/compute functions, argument buffers, and shader compilation pipelines
- **Pipeline engineering** — Render pipeline descriptors, compute pipelines, pipeline state caching, indirect command buffers, and GPU-driven rendering
- **Memory management** — Resource heaps, buffer allocation strategies, texture management, triple-buffered uniform updates, and Metal resource storage modes
- **Performance profiling** — GPU capture frames, Xcode GPU debugger, Metal System Trace, shader profiler, and performance anti-patterns
- **Cross-platform targeting** — Shared Metal code across macOS, iOS, and visionOS with feature-set gating

## Core Philosophy

**Five Principles:**

1. **GPU-first architecture** — Design data layouts and algorithms for GPU parallelism from the start; retrofitting CPU-oriented code onto the GPU produces poor results
2. **Pipeline state is expensive, draw calls are cheap** — Minimize pipeline state changes; batch draws by material/state; use instancing aggressively
3. **Profile before optimizing** — Metal has excellent tooling (GPU capture, shader profiler, Metal System Trace); use data, not intuition
4. **Memory coherence is your responsibility** — Unlike higher-level APIs, Metal gives you direct control over synchronization, storage modes, and hazard tracking — own it
5. **Shader code is production code** — MSL files deserve the same rigor as Swift: naming conventions, modular includes, testable compute kernels, versioned pipeline caches

## When to Use This Skill

- **Starting a new Metal project** — Architecture decisions, MTKView vs CAMetalLayer, project structure
- **Writing or debugging shaders** — MSL syntax, data types, built-in functions, shader compilation errors
- **Building a render pipeline** — Descriptor setup, vertex layouts, blending, depth/stencil, MSAA
- **Implementing compute workloads** — Threadgroup sizing, shared memory, GPU-driven workflows
- **Profiling GPU performance** — Xcode GPU capture, shader profiler, identifying bottlenecks
- **Porting from OpenGL/Vulkan** — Mental model translation, API mapping, best-practice alignment
- **Integrating Metal with SwiftUI** — Representable wrappers, frame synchronization, input handling
- **Building a game engine** — ECS integration, scene graph rendering, asset pipelines, mesh loading

> For UI design and layout of the application shell around a Metal view, see **trl-user-experience-engineer** (`references/outputs/nextjs.md` or `references/outputs/svg-mockups.md`).
> For SEO and discoverability of a published graphics tool or game, see **trl-seo-guru** (`kb/01-ai-seo-complete-guide.md`).

## Metal API Architecture

### Core Object Graph

```
MTLDevice
├── MTLCommandQueue
│   └── MTLCommandBuffer
│       ├── MTLRenderCommandEncoder
│       ├── MTLComputeCommandEncoder
│       └── MTLBlitCommandEncoder
├── MTLRenderPipelineState
├── MTLComputePipelineState
├── MTLDepthStencilState
├── MTLBuffer
├── MTLTexture
└── MTLHeap
```

### Render Loop Lifecycle

```
Frame Start
  ├── Wait on semaphore (triple-buffer)
  ├── Update uniforms (CPU → shared/managed buffer)
  ├── Get next drawable (CAMetalDrawable)
  ├── Create command buffer
  │   ├── Begin render pass
  │   │   ├── Set pipeline state
  │   │   ├── Set vertex/fragment buffers & textures
  │   │   ├── Draw primitives / indexed / instanced
  │   │   └── End encoding
  │   ├── (Optional) Compute pass
  │   └── (Optional) Blit pass
  ├── Present drawable
  └── Commit command buffer
Frame End (GPU signals semaphore on completion)
```

### Storage Mode Selection

| Storage Mode | CPU Access | GPU Access | Best For |
|---|---|---|---|
| `shared` | Read/Write | Read/Write | Uniforms, small dynamic buffers (Apple Silicon) |
| `managed` | Read/Write | Read/Write | Uniforms, dynamic data (Intel/AMD — requires synchronize) |
| `private` | None | Read/Write | Textures, static meshes, GPU-only data |
| `memoryless` | None | Tile only | Transient render targets (MSAA resolve, depth) |

### Pipeline State Checklist

| Component | Key Decision | Impact |
|---|---|---|
| Vertex descriptor | Interleaved vs separate attributes | Memory bandwidth, cache efficiency |
| Pixel format | BGRA8 vs RGBA16Float vs RGB10A2 | Color precision, bandwidth, HDR support |
| Depth format | depth32Float vs depth16Unorm | Precision vs memory |
| MSAA sample count | 1, 2, 4 | Quality vs fill-rate cost |
| Blending | Alpha blend vs opaque | Overdraw cost |
| Vertex function | Complexity, attribute count | Vertex processing bottleneck |
| Fragment function | Texture samples, ALU ops | Fragment processing bottleneck |

## Metal Shading Language (MSL) Quick Reference

### Function Qualifiers

| Qualifier | Purpose | Example |
|---|---|---|
| `vertex` | Vertex shader entry point | `vertex VertexOut vertex_main(...)` |
| `fragment` | Fragment shader entry point | `fragment float4 fragment_main(...)` |
| `kernel` | Compute shader entry point | `kernel void compute_main(...)` |

### Address Space Qualifiers

| Qualifier | Meaning |
|---|---|
| `device` | Device memory (read/write) |
| `constant` | Constant memory (read-only, optimized for broadcast) |
| `threadgroup` | Shared within a threadgroup |
| `thread` | Private to a thread |

### Common Attribute Qualifiers

```metal
struct VertexIn {
    float3 position  [[attribute(0)]];
    float3 normal    [[attribute(1)]];
    float2 texCoord  [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float2 texCoord;
};

vertex VertexOut vertex_main(
    VertexIn in [[stage_in]],
    constant Uniforms &uniforms [[buffer(0)]]
) { ... }

fragment float4 fragment_main(
    VertexOut in [[stage_in]],
    texture2d<float> albedo [[texture(0)]],
    sampler samp [[sampler(0)]]
) { ... }

kernel void compute_main(
    uint tid [[thread_position_in_grid]],
    uint tgid [[threadgroup_position_in_grid]],
    uint lid [[thread_position_in_threadgroup]]
) { ... }
```

## Compute Pipeline Design

### Threadgroup Sizing

| GPU Family | Max Threadgroup Size | Max Threads/Threadgroup |
|---|---|---|
| Apple (A-series, M-series) | 1024 | 1024 |
| Mac (AMD discrete) | 1024 | 1024 |
| Common (Intel integrated) | 256-512 | Varies |

**Rules of thumb:**
- Start with `(16, 16, 1)` for 2D image processing → 256 threads, good occupancy
- Use `(256, 1, 1)` for 1D workloads (particle systems, reductions)
- Query `maxTotalThreadsPerThreadgroup` from the pipeline state — don't hardcode
- Use non-uniform threadgroups (`dispatchThreads` instead of `dispatchThreadgroups`) on Apple GPUs for simpler boundary handling

### Shared Memory Patterns

```metal
kernel void reduce_sum(
    device float *input [[buffer(0)]],
    device float *output [[buffer(1)]],
    threadgroup float *shared [[threadgroup(0)]],
    uint tid [[thread_position_in_grid]],
    uint lid [[thread_position_in_threadgroup]],
    uint tg_size [[threads_per_threadgroup]]
) {
    shared[lid] = input[tid];
    threadgroup_barrier(mem_flags::mem_threadgroup);

    for (uint s = tg_size / 2; s > 0; s >>= 1) {
        if (lid < s) {
            shared[lid] += shared[lid + s];
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
    }

    if (lid == 0) {
        output[tgid] = shared[0];
    }
}
```

## Application Integration Patterns

### SwiftUI + Metal (MTKView via UIViewRepresentable/NSViewRepresentable)

```
SwiftUI View
└── MetalViewRepresentable (NSViewRepresentable)
    └── MTKView
        └── Renderer (MTKViewDelegate)
            ├── mtkView(_:drawableSizeWillChange:)
            └── draw(in:) → render loop
```

### AppKit + CAMetalLayer (manual control)

```
NSWindow
└── NSView (wantsLayer = true)
    └── CAMetalLayer
        └── CVDisplayLink callback → render loop
            ├── nextDrawable()
            ├── encode commands
            └── present + commit
```

### Choosing Between MTKView and CAMetalLayer

| Factor | MTKView | CAMetalLayer |
|---|---|---|
| Setup complexity | Low (delegate pattern) | High (manual display link) |
| Frame pacing | Automatic | Manual (CVDisplayLink / CADisplayLink) |
| Resize handling | Automatic | Manual (layer bounds observation) |
| Multi-window | Supported | Full control |
| Custom frame rate | `preferredFramesPerSecond` | Manual timer/display link |
| Best for | Most apps, games, tools | Custom engines, multi-window editors, embedded views |

## Performance Profiling Workflow

### Step-by-Step GPU Capture

1. **Capture** — Xcode → Debug → Capture GPU Workload (or programmatic: `MTLCaptureManager`)
2. **Timeline** — Review command buffer timeline for encoder gaps and sync stalls
3. **Pipeline statistics** — Check vertex/fragment shader time, occupancy, ALU utilization
4. **Shader profiler** — Line-by-line cost breakdown in MSL source
5. **Memory** — Review allocation sizes, storage modes, heap utilization
6. **Bandwidth** — Check texture fetch patterns, buffer access patterns

### Common Performance Anti-Patterns

| Anti-Pattern | Symptom | Fix |
|---|---|---|
| Creating pipeline states per frame | CPU spike, stutter | Cache `MTLRenderPipelineState` at init |
| `synchronized` on every frame (managed mode) | CPU-GPU sync stall | Use triple buffering with semaphore |
| Excessive draw calls | CPU-bound frame | Instance, merge meshes, use ICBs |
| Large `shared` textures | Bandwidth waste | Use `private` storage + blit upload |
| Missing `endEncoding()` | Crash or corruption | Always pair begin/end |
| Threadgroup too large for shader | Silent occupancy drop | Query pipeline's `maxTotalThreadsPerThreadgroup` |

## Project Templates

### Minimal Metal App (SwiftUI + MTKView)

```
MetalApp/
├── MetalApp.swift           # @main App entry
├── ContentView.swift        # SwiftUI wrapper
├── MetalView.swift          # NSViewRepresentable / UIViewRepresentable
├── Renderer.swift           # MTKViewDelegate — render loop
├── Shaders.metal            # Vertex + fragment shaders
├── ShaderTypes.h            # Shared CPU/GPU data types (bridging header)
├── Math/
│   └── MathUtilities.swift  # Matrix/vector helpers (or use simd directly)
└── Resources/
    └── Meshes/              # Model assets
```

### Compute-Only Project

```
MetalCompute/
├── main.swift               # CLI entry, MTLDevice setup
├── ComputePipeline.swift    # Pipeline setup + dispatch
├── Kernels.metal            # Compute kernels
└── ShaderTypes.h            # Shared types
```

## Quick Start Guides

### First Triangle
1. Read [references/fundamentals/first-triangle.md](references/fundamentals/first-triangle.md) — complete walkthrough
2. Create Xcode project with Metal template (or scaffold from Project Templates above)
3. Implement `Renderer` with MTKViewDelegate
4. Write vertex/fragment shader pair in `Shaders.metal`
5. Run on macOS — verify triangle renders

### Compute Shader Workload
1. Read [references/fundamentals/compute-basics.md](references/fundamentals/compute-basics.md)
2. Create `MTLComputePipelineState` from kernel function
3. Dispatch with appropriate threadgroup sizing
4. Read back results via shared buffer or blit
5. Profile with GPU capture

### SwiftUI Integration
1. Read [references/patterns/swiftui-metal-integration.md](references/patterns/swiftui-metal-integration.md)
2. Create `NSViewRepresentable` / `UIViewRepresentable` wrapping MTKView
3. Wire up `Coordinator` as `MTKViewDelegate`
4. Pass SwiftUI state to renderer via `@Observable` or bindings
5. Handle resize and display scale changes

### Performance Investigation
1. Read [references/profiling/gpu-capture-guide.md](references/profiling/gpu-capture-guide.md)
2. Capture GPU frame in Xcode
3. Identify hotspot (vertex, fragment, compute, memory, CPU)
4. Read the relevant anti-pattern fix from Performance Anti-Patterns table
5. Apply fix, re-capture, compare

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Starting any Metal project** | `fundamentals/metal-architecture.md`, `fundamentals/first-triangle.md` |
| **Writing shaders** | `shaders/msl-reference.md`, `shaders/shader-compilation.md` |
| **Render pipeline setup** | `fundamentals/render-pipeline-deep-dive.md` |
| **Compute workloads** | `fundamentals/compute-basics.md`, `shaders/compute-patterns.md` |
| **SwiftUI integration** | `patterns/swiftui-metal-integration.md` |
| **AppKit + CAMetalLayer** | `patterns/appkit-metal-integration.md` |
| **Memory optimization** | `profiling/memory-management.md` |
| **GPU profiling** | `profiling/gpu-capture-guide.md`, `profiling/common-bottlenecks.md` |
| **Cross-platform (iOS/visionOS)** | `patterns/cross-platform-metal.md` |
| **Game engine architecture** | `outputs/game-engine-scaffold.md` |
| **Image processing app** | `outputs/image-processing-app.md` |
| **Full worked example** | `worked-example-particle-system.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-user-experience-engineer** — Design the application UI shell, controls, and chrome around Metal views
- **trl-skill-engineer** — Meta-skill used to create this skill; useful for extending it
- **trl-ai-templates** — Package Metal shader libraries or compute utilities as sellable templates
- **trl-content-publishing** — Write tutorials about Metal development to build authority

## Bundled Resources

### References

**Fundamentals** (`references/fundamentals/`):
- [metal-architecture.md](references/fundamentals/metal-architecture.md) — Core Metal object graph, device capabilities, GPU families, feature sets
- [first-triangle.md](references/fundamentals/first-triangle.md) — Complete first-triangle walkthrough with annotated code
- [render-pipeline-deep-dive.md](references/fundamentals/render-pipeline-deep-dive.md) — Pipeline descriptors, vertex layouts, blending, depth/stencil, MSAA
- [compute-basics.md](references/fundamentals/compute-basics.md) — Compute pipeline setup, threadgroup design, dispatch patterns

**Shaders** (`references/shaders/`):
- [msl-reference.md](references/shaders/msl-reference.md) — MSL types, functions, qualifiers, built-ins, and idioms
- [shader-compilation.md](references/shaders/shader-compilation.md) — Runtime vs precompiled shaders, Metal libraries, function constants
- [compute-patterns.md](references/shaders/compute-patterns.md) — Reduction, scan, sort, image processing, and simulation kernels

**Patterns** (`references/patterns/`):
- [swiftui-metal-integration.md](references/patterns/swiftui-metal-integration.md) — NSViewRepresentable patterns, state flow, resize handling
- [appkit-metal-integration.md](references/patterns/appkit-metal-integration.md) — CAMetalLayer, CVDisplayLink, manual frame pacing
- [cross-platform-metal.md](references/patterns/cross-platform-metal.md) — Shared code for macOS/iOS/visionOS, feature-set gating
- [resource-management.md](references/patterns/resource-management.md) — Heaps, argument buffers, bindless rendering, resource residency

**Profiling** (`references/profiling/`):
- [gpu-capture-guide.md](references/profiling/gpu-capture-guide.md) — Xcode GPU capture workflow, timeline reading, shader profiler
- [memory-management.md](references/profiling/memory-management.md) — Storage modes, synchronization, allocation strategies
- [common-bottlenecks.md](references/profiling/common-bottlenecks.md) — Diagnostic flowchart for vertex/fragment/compute/bandwidth bottlenecks

**Outputs** (`references/outputs/`):
- [game-engine-scaffold.md](references/outputs/game-engine-scaffold.md) — ECS + Metal renderer architecture, asset pipeline, scene graph
- [image-processing-app.md](references/outputs/image-processing-app.md) — Core Image + Metal compute hybrid for filter chains

**Worked Examples**:
- [worked-example-particle-system.md](references/worked-example-particle-system.md) — End-to-end: GPU particle system with compute update + instanced rendering

### Assets

- [project-tracker.md](assets/project-tracker.md) — Metal project development tracker
