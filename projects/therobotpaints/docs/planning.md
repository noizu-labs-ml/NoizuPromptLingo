# The Robot Paints - Physics Simulator Planning

## KopiGajj Migration Notes

Proven patterns from `../kopigajj/` (working paint sim, Stage 0.5). Polish before implementation:

- **Runtime shader compilation** — all MSL as Swift string literals, compiled via `MTLDevice.makeLibrary(source:)`. SPM can't build `.metal` files. If we want Xcode syntax highlighting, add `.metal` files to a `Shaders/` dir and `exclude` in Package.swift (kopigajj does this). See `docs/kb/metal-reference.md` Pattern 1.
- **MetalShaderCompiler + MetalTextureFactory protocols** — extract all Metal boilerplate. Both `PaintSimulator` and `CanvasMetalRenderer` conform to them. Static variants allow use during `init`. Direct reuse. See Pattern 1 & 2.
- **Absorption color model** — store absorption (0=transparent) not RGB. Rendering via Beer-Lambert: `visibleColor = canvasColor * exp(-absorption * concentration)`. Subtractive mixing works naturally. We reference this in voxel-architecture.md but planning.md still shows `interface PaintLayer { color: {r,g,b} }` — needs updating to absorption model. See Pattern 7.
- **Double-buffered textures** — ping-pong read/write for flow and diffusion steps. `readWetAbsorb` / `writeWetAbsorb` computed properties with `phase` counter. Our MPM layers need the same. See Pattern 3.
- **CPU→GPU transfer** — `BrushPoint` struct: all flat floats, 56 bytes. Swift and Metal layouts must match byte-for-byte. Use `.storageModeShared` for brush buffers, `setBytes()` for small params. Our `SPHParticle` struct follows same rule. See Pattern 4.
- **GPU→CPU readback** — blit to `.managed` staging texture → `synchronize()` → `getBytes()` → `CGContext` → `NSImage`. KopiGajj uses this for all display (no MTKView). We'll use MTKView for live rendering but need readback for export. See Pattern 5.
- **Threadgroup 16×16** — ceiling-div threadgroups, boundary check in shader. Same for us. See Pattern 6.
- **Synchronous sim dispatch** — kopigajj calls `buf.waitUntilCompleted()` per step. Works for on-demand sim (~1-3ms). Our 60fps live render needs async (`buf.present(drawable)` + `buf.commit()`), but sim steps can stay sync. See Pattern 10.
- **Test pattern** — `MetalShaderCompilationTests` compiles every kernel at test time. Catches MSL errors without running the app. `TestMetalHelper` with `XCTSkip` fallback. Direct reuse. See Pattern 9.
- **Swift 6** — kopigajj uses Swift 5.9 (no strict concurrency). We need `@unchecked Sendable` on `MetalEngine` and `Renderer` since Metal objects are thread-safe but lack formal conformance. `Package.swift` needs `swift-tools-version: 6.0`. See metal-reference.md "Swift 6 Concurrency Notes".
- **Rendering approach** — this doc still mentions "raymarching through volume" and "camera rays". Our architecture doc corrected this: 2D canvas, top-down, layer-stack compositing with normal-mapped impasto lighting. This doc's rendering section needs the same fix.
- **Pixel metadata** — this doc uses TypeScript `interface PaintLayer` pseudocode. Should be rewritten as actual Metal MSL structs matching voxel-architecture.md's `VolumeLayer` (32 bytes, FP16).
- **Memory estimates** — this doc says ~1.2 GB for 1080p, 4.8 GB for 4K. Architecture doc corrected to ~630 MB / ~2.5 GB using FP16. Update these.
- **Catmull-Rom interpolation** — kopigajj interpolates brush points with Catmull-Rom splines for sub-pixel continuity. We should adopt this for brush input smoothing.
- **Shader source organization** — kopigajj splits into `PaintShaderHeader.swift` (shared structs) + per-kernel files (header + kernel). Each compiles independently. We should follow: `ShaderHeader.swift` + per-kernel extensions.

---

## Project Overview

An advanced physics paint simulator that realistically models different artistic mediums by simulating fluid dynamics, texture interactions, and medium-specific behaviors. The core innovation is a **2D canvas with per-pixel layer stacks** where each pixel carries rich metadata about its physical properties across multiple paint layers.

**Platform Strategy**: Native macOS Metal application first, then web migration. Metal provides:
- Full GPU compute capability without browser limitations
- Direct access to unified memory (Apple Silicon)
- Metal Performance Shaders for optimized compute
- Real-time performance impossible in browsers
- Foundation for eventual web port (compute shaders map well to WebGPU)

### Core Value Proposition

- **Realistic medium simulation**: Watercolors flow, oils blend, charcoal smudges
- **Physics-based interactions**: Mediums interact according to real-world physics
- **Native performance**: Metal GPU compute for real-time simulation at 60 FPS
- **Real-time feedback**: Immediate visual and physical response to brush strokes

---

## Technical Architecture

### Core Concept: 2D Canvas with Per-Pixel Layer Stacks

Each pixel on the 2D canvas maintains a **layer stack** (z-depth ordering, not 3D space). Rendering composites these layers back-to-front with impasto lighting from depth-derived normal maps.

```
┌─────────────────────────────────────────────────────┐
│  Canvas (2D Grid, top-down view)                     │
│  ┌───────────────────────────────────────────────┐  │
│  │ Pixel[i][j]                                  │  │
│  │  • Layer Stack (z-order depth, up to 8)      │  │
│  │  • Each layer: Substance + Physical Props     │  │
│  │  • Physics simulation per pixel               │  │
│  │  • Neighbor interactions for flow/blend       │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  Rendering: composite layers back-to-front           │
│  Normal maps from depth gradient for impasto light   │
└─────────────────────────────────────────────────────┘
```

### Pixel Metadata Structure

Each pixel maintains a **layer stack** representing paint layers in z-order. Each layer in the stack is a `VolumeLayer` (32 bytes, FP16):

```metal
// VolumeLayer — 32 bytes per layer per pixel (Metal Shading Language)
struct VolumeLayer {
    uint8_t  substance_type;    // 1 byte: Watercolor=0, Oil=1, Acrylic=2, Charcoal=3
    uint8_t  flags;             // 1 byte: dirty, drying, locked
    half4    color_rgbo;        // 8 bytes: R,G,B,Opacity (FP16)
    half     depth;             // 2 bytes: layer thickness
    half     wetness;           // 2 bytes: moisture level
    half     viscosity;         // 2 bytes: resistance to flow
    half     hardness;          // 2 bytes: dryness rigidity
    half     velocity_x;        // 2 bytes: flow velocity X
    half     velocity_y;        // 2 bytes: flow velocity Y
    half     surface_tension;   // 2 bytes: edge behavior
    half     age;               // 2 bytes: time since deposition
    half     gloss;             // 2 bytes: specular intensity (oil/acrylic)
    half2    _padding;          // 4 bytes: align to 32 bytes
};
// Total: 32 bytes, GPU cache line aligned (256 bits)

struct PixelVolume {
    VolumeLayer layers[8];      // 8 × 32 = 256 bytes
    half3       base_color;     // 6 bytes: paper/substrate color
    half        total_depth;    // 2 bytes
    uint8_t     active_count;   // 1 byte: how many layers non-empty
    uint8_t     _pad[5];        // 5 bytes: align to 16
};
// Total: 272 bytes per pixel
```

Color values use the **absorption model** (Beer-Lambert): `visibleColor = canvasColor * exp(-absorption * concentration)`. Higher absorption = more opaque pigment. See `docs/kb/metal-reference.md` Pattern 7.

### SPH Particle Structure

Smudge/flow dynamics use SPH particles (48 bytes):

```metal
// SPHParticle — 48 bytes per particle (Metal Shading Language)
struct SPHParticle {
    float2  position;          // 8 bytes: 2D canvas coordinates
    float2  velocity;          // 8 bytes: X,Y velocity
    half4   color_rgba;        // 8 bytes: R,G,B,A (FP16)
    half    radius;            // 2 bytes: splat/kernel radius
    half    mass;              // 2 bytes: for SPH density calculation
    half    local_density;     // 2 bytes: SPH kernel density sum
    half    rest_density;      // 2 bytes: target density for pressure calc
    half    viscosity;         // 2 bytes: inherited from medium
    half    smoothing_length;  // 2 bytes: interaction radius (h)
    half    wetness;           // 2 bytes: remaining moisture
    half    life;              // 2 bytes: age (retire when dry)
    uint8_t layer_index;       // 1 byte: which paint layer this belongs to
    uint8_t flags;             // 1 byte: active, pinned, retiring
    uint16_t _padding;         // 2 bytes: alignment
};
// Total: 48 bytes per particle
```

---

## Physics Simulation Engine

### Simulation Pipeline

```
Brush Input → Deposit Medium → Update Pixel State → 
Calculate Forces (gravity, surface tension, diffusion) → 
Update Velocities → Advect/Transport →
Blend/Mix Layers → Evaporate/Dry → Render
```

### GPU Computation Strategy

All simulation runs on GPU via Metal compute shaders:

**Primary: Custom Metal Compute Pipeline**
- Direct MTLBuffer storage for pixel metadata arrays
- Separate compute passes for each simulation phase
- Threadgroup memory for neighbor access caching
- Metal Performance Shaders for common operations (diffusion, blur)

**Rendering: Metal Render Pipeline**
- Fragment shader composites layer stack per-pixel (2D canvas, top-down view)
- Normal maps from depth gradient via central differences for impasto lighting
- Per-medium specular highlights (oil gloss, acrylic sheen)
- Over-operator compositing (painter's algorithm, back-to-front)
- MPSImage for post-processing (tone mapping, bloom)

### Simulation Steps (Per Frame)

**1. Brush Deposition Phase**
- Map mouse/touch/tablet input to canvas coordinates
- Interpolate raw input points with Catmull-Rom splines for sub-pixel stroke smoothness
- Determine brush size, pressure, velocity along the smoothed curve
- Deposit medium into affected pixels
- Set initial moisture and velocity based on brush dynamics

**2. Physics Calculation Phase (Metal Compute Shader)**
```metal
// Simplified simulation kernel (valid Metal Shading Language)
kernel void simulate_physics(
    device VolumeLayer* layers [[buffer(0)]],
    constant SimParams& params [[buffer(1)]],
    uint2 global_id [[thread_position_in_grid]]
) {
    uint idx = global_id.y * params.canvas_width + global_id.x;
    
    VolumeLayer layer = layers[idx];
    
    // Calculate forces from neighbors (central differences)
    float2 flow_force = float2(0.0);
    float2 diffusion = float2(0.0);
    if (idx > 0 && idx < params.canvas_width * params.canvas_height - 1) {
        float dL = float(layers[idx - 1].depth);
        float dR = float(layers[idx + 1].depth);
        float dU = float(layers[idx - params.canvas_width].depth);
        float dD = float(layers[idx + params.canvas_width].depth);
        flow_force = float2(dR - dL, dD - dU) * params.flow_strength;
    }
    
    // Update velocity with forces
    layer.velocity_x = half(float(layer.velocity_x) + flow_force.x * params.dt);
    layer.velocity_y = half(float(layer.velocity_y) + flow_force.y * params.dt);
    
    // Evaporate moisture
    float wetness = float(layer.wetness) * (1.0 - params.drying_rate * params.dt);
    layer.wetness = half(max(wetness, 0.0));
    
    layers[idx] = layer;
}
```

**3. Rendering Phase**
- Composite layer stack at each pixel (painter's algorithm, back-to-front)
- Compute final color using absorption model (Beer-Lambert) and over-operator
- Compute surface normals from depth gradient for impasto lighting
- Per-medium specular highlights (oil gloss, acrylic sheen)
- Tone mapping (Reinhard) + gamma correction
- Render to drawable texture via MetalKit MTKView

---

## Painting Medium Behaviors

### Watercolor

**Physical Characteristics:**
- High flow when wet, low viscosity
- Transparent layers, additive color mixing
- Surface tension creates edge effects (blooms, backruns)
- Granulation as pigments pool
- Rapid drying (evaporation)

**Simulation Priorities:**
- Flowing dynamics based on moisture gradient
- Edge diffusion and backrun formation
- Layer transparency via absorption color model (Beer-Lambert)
- Granular pigment pooling
- Water content tracking

### Oil Paint

**Physical Characteristics:**
- Very slow drying (oxidation, not evaporation)
- High viscosity, low flow
- Impasto capability (texture buildup)
- Glossy reflections
- Excellent blendability while wet

**Simulation Priorities:**
- Slow drying kinetics
- Thixotropic behavior (viscosity changes with movement)
- Layer blending and mixing
- Texture/depth accumulation
- Specular highlights (gloss)

### Acrylic

**Physical Characteristics:**
- Fast drying (water evaporation)
- Polymerizes to form permanent film
- Can be transparent or opaque
- Less flexible than oil, can crack if applied too thick
- Can act as water-resist when dry

**Simulation Priorities:**
- Quick water evaporation
- Polymerization dynamics
- Layer stacking with minimal blending once dry
- Opacity control
- Surface tension effects

### Charcoal

**Physical Characteristics:**
- Dry medium, no liquid component
- Particulate behavior
- Smudges and transfers easily
- High texture
- Matte finish

**Simulation Priorities:**
- Particle deposition based on pressure
- Smudging mechanics
- Transfer between pixels
- Texture simulation
- Fixative effects (reduces smudging)

### Pastel

**Physical Characteristics:**
- Powder-based, soft binder
- Can be built up in layers
- Blends by mixing powder
- Fragile, easily smeared

**Simulation Priorities:**
- Powder accumulation
- Layer mixing without liquid
- Additive color blending
- Surface texture simulation

---

## Tech Stack Recommendations

### Platform: Native macOS (Metal First)

**Why Metal First?**
- Direct GPU command buffer control (no browser overhead)
- Unified memory architecture on Apple Silicon (zero-copy)
- Metal Performance Shaders (MPS) for optimized compute primitives
- No WebGL/WebGPU size or capability limitations
- Can use Metal's **programmable blending**, **tessellation**, and **deferred rendering**
- Easier to debug with Metal Performance HUD and Xcode tools

### Core Framework: Swift + Metal

**Primary Choice: Swift 6 with Metal Framework**
- Swift 6 strict concurrency (`@unchecked Sendable` for Metal objects)
- Metal Shading Language (MSL) for GPU compute + graphics
- MetalKit for window management and view setup (MTKView)
- Accelerate framework for CPU fallback physics

**Architecture Benefits:**
```swift
// Main simulation loop (Swift 6 concurrency)
// Metal objects (MTLDevice, MTLCommandQueue, pipelines) are thread-safe
// but lack formal Sendable conformance — use @unchecked Sendable
final class PhysicsEngine: @unchecked Sendable {
    private let commandQueue: MTLCommandQueue
    private let simPipelines: [String: MTLComputePipelineState]
    private let renderPipeline: MTLRenderPipelineState
    
    func simulate(frame: Int, drawable: CAMetalDrawable) {
        guard let buf = commandQueue.makeCommandBuffer() else { return }
        
        // Stage 1: Brush deposition (CPU → GPU buffer)
        applyBrushStroke(stroke: currentStroke, encoder: buf)
        
        // Stage 2: Physics simulation (GPU compute, synchronous per step)
        runComputePass(pipelines: simPipelines, commandBuffer: buf)
        
        // Stage 3: Rendering (GPU, async present for 60fps)
        runRenderPass(renderPipeline: renderPipeline, drawable: drawable, commandBuffer: buf)
        
        buf.present(drawable)
        buf.commit()
    }
}
```

### UI Framework

**Primary Choice: SwiftUI**
- Modern, declarative UI for tool panels and controls
- Metal view integration via `MetalView` wrapper
- Reactive state management with `@Observable`
- Great for complex tool parameter tweaking

**Alternative: UIKit**
- More control over complex views
- Better for very large canvas management
- Established pattern with MetalKit

### Build & Development

- **Package Manager**: Swift Package Manager (SPM)
- **Build System**: Xcode 16+
- **Debugging**: Metal Performance HUD, Xcode GPU Frame Capture
- **Profiling**: Instruments (Time Profiler, Allocations, Metal System Trace)

### Testing

- **Unit Tests**: XCTest for CPU-side physics logic
- **Metal Shader Testing**: Custom test harness with Metal shader validation
- **Performance Tests**: Instruments-based GPU profiling
- **Visual Regression Tests**: Automated screenshot comparison for render correctness

---

### Future Web Migration Path

When porting to web:
- **Metal Compute Pass** → **WebGPU Compute Shader** (direct mapping)
- **Metal Shading Language** → **WGSL** (conceptual translation, syntax differences)
- **MTLBuffer** → **GPUBuffer** (similar API)
- **MTLRenderPipeline** → **RenderPipeline** (similar pipeline state)

The Metal-first approach validates the compute architecture, making web port just a syntax translation, not a redesign.

---

## Implementation Phases (Metal-Enhanced)

### Phase 1: Core Metal Framework (Weeks 1-2)
**Goal**: Basic Metal rendering and compute pipeline foundation

- [ ] Set up macOS app project (Swift 6 + SwiftUI + MetalKit)
- [ ] Create Metal device and command queue setup
- [ ] Implement basic MTKView with double buffering
- [ ] Write first compute shader (simple clear operation)
- [ ] Create base GPU buffer management system
- [ ] Implement basic render pipeline (solid color quad)
- [ ] Add Metal Performance HUD for debugging
- [ ] Set up Xcode build scheme with Metal validation

**Deliverable**: Working Metal rendering context with compute shader support

### Phase 2: Watercolor Physics Foundation (Weeks 3-4)
**Goal**: Realistic watercolor simulation with flow and diffusion

- [ ] Design pixel metadata structure (single-layer prototype)
- [ ] Create GPU buffer layout for pixel state
- [ ] Implement brush deposition (CPU to GPU buffer update)
- [ ] Write watercolor diffusion compute shader (threadgroup caching)
- [ ] Semi-Lagrangian advection for water flow
- [ ] Surface tension and edge bloom effects
- [ ] Basic layer-stack compositing with impasto lighting
- [ ] Swift UI: Brush selector, color picker, size slider

**Deliverable**: Interactive watercolor canvas with realistic flow

### Phase 3: Multi-Layer Volume (Weeks 5-6)
**Goal**: 3D pixel stacks with depth and layer management

- [ ] Implement layered pixel structure (8-layer stacks)
- [ ] Add layer mixing/blending compute shader with threadgroup memory
- [ ] Texture-tiled pixel data storage for cache locality
- [ ] Depth accumulation and impasto texture
- [ ] Layer-stack compositor with depth-derived normal maps
- [ ] Additive blending for transparent layers
- [ ] Layer management UI (visibility, opacity, reordering)
- [ ] Smart layer merging (consolidate dry layers)

**Deliverable**: Fully layered paint system with depth effects

### Phase 4: Advanced Media Physics (Weeks 7-9)
**Goal**: Oil, acrylic, charcoal with distinct behaviors

#### Week 7: Oil Paint
- [ ] Slow drying kinetics (oxidation model)
- [ ] Thixotropic viscosity (shear-thinning behavior)
- [ ] Layer blending with pigment mixing
- [ ] Impasto texture accumulation (normal maps)
- [ ] Gloss/specular rendering (physically based)
- [ ] Glazing techniques (thin transparent layers)

#### Week 8: Acrylic
- [ ] Fast water evaporation (2-phase drying)
- [ ] Polymerization dynamics
- [ ] Layer stacking without blending (once dry)
- [ ] Water-resist layering
- [ ] Matte finish vs gloss finish

#### Week 9: Charcoal & Pastel
- [ ] Particle deposition system (CPU-side particle tracking)
- [ ] Smudge physics (velocity-based transfer)
- [ ] Particle adhesion and texture simulation
- [ ] Pastel powder accumulation
- [ ] Fixative mechanics (固化 simulation)
- [ ] Matte rendering with micro-surface detail

**Deliverable**: Complete multi-medium system with 5+ media

### Phase 5: Advanced Simulation (Weeks 10-12)
**Goal**: Push physical realism to maximum

#### Week 10: Fluid Dynamics Enhancement
- [ ] MPS-accelerated convolution for diffusion
- [ ] Adaptive time stepping (CFL condition)
- [ ] Multi-scale simulation (coarse + fine grids)
- [ ] Implicit integration for stiff systems
- [ ] Subgrid-scale modeling (turbulence)

#### Week 11: Medium Interactions
- [ ] Cross-medium physics rules (oil vs watercolor)
- [ ] Solubility modeling (what dissolves what)
- [ ] Absorption simulation (paper substrate)
- [ ] Backrun formation (water re-wetting dry areas)
- [ ] Surface preparation effects (gesso, sizing)

#### Week 12: Lighting & Materials
- [ ] Physically based rendering (PBR) for oil gloss
- [ ] Subsurface scattering for watercolor translucency
- [ ] Ambient occlusion for impasto shadows
- [ ] Specular highlights with Fresnel effects
- [ ] Custom environment mapping for lighting

### Phase 6: Performance Optimization (Weeks 13-14)
**Goal**: 60 FPS at 4K canvas resolution

#### Week 13: GPU Optimization
- [ ] Sparse textures for 16K+ canvas support
- [ ] Heap-based memory pools
- [ ] Indirect dispatch for dirty regions
- [ ] Tile-based LOD (dynamic resolution)
- [ ] MPS framework integration for common kernels
- [ ] GPU-driven workload culling

#### Week 14: CPU Optimization & Profiling
- [ ] Swift 6 concurrency (@unchecked Sendable for Metal objects, no actors)
- [ ] Brush stroke preprocessing pipeline
- [ ] Instruments profiling and bottleneck removal
- [ ] Unified memory zero-copy optimization
- [ ] Background file loading
- [ ] Power management (thermal throttling awareness)

### Phase 7: UX & Polish (Weeks 15-16)
**Goal**: Production-ready application

#### Week 15: Features
- [ ] Undo/redo system with state snapshots
- [ ] Save/load (custom binary format with compression)
- [ ] Export to TIFF, PNG, Procreate format
- [ ] Canvas panning and zooming (infinite canvas)
- [ ] Custom panel configurations
- [ ] Keyboard shortcuts and gestures

#### Week 16: Testing & Polish
- [ ] Comprehensive instrument profiling
- [ ] Memory leak detection
- [ ] Edge case handling (out-of-memory, GPU reset)
- [ ] UI animations and polish
- [ ] Documentation and tutorials
- [ ] Beta testing with artists

**Deliverable**: Production-ready macOS app (App Store ready)

### Phase 8: Web Migration (Weeks 17+)
**Goal**: Port to web (browsers)

- [ ] Extract simulation logic into Metal WGSL translation layer
- [ ] Implement WebGPU compute shader port
- [ ] WebAssembly fallback for CPU simulation
- [ ] Progressive web app (PWA) setup
- [ ] Browser-specific optimizations
- [ ] Web accessibility and mobile support

**Deliverable**: Web version with Metal feature fallback

---

## Performance Considerations (Metal-Optimized)

### Challenge: Per-Pixel Compute Cost

**Problem**: Simulating physics for every pixel (e.g., 1920×1080 = 2M pixels) is expensive.

**Metal-Optimized Solutions:**

1. **Unified Memory Architecture (Apple Silicon)**
   - Zero-copy between CPU and GPU
   - Shared memory eliminates staging buffers
   - CPU can pre-process brush strokes directly in GPU-accessible memory
   - `MTLStorageModeShared` buffers accessed by both CPU and GPU

2. **Progressive Resolution**
   - Simulate physics at 1/4 or 1/8 resolution
   - Upscale using Metal Performance Shaders (`MPSImageGaussianBlur`, `MPSImageLanczosScale`)
   - Real-time resolution switching based on brush velocity
   - **Metal advantage**: Hardware-accelerated scaling at zero cost

3. **Dirty Region Tracking with Compute Indirect**
   - Maintain "active tiles" buffer (e.g., 64×64 pixel tiles)
   - Only dispatch compute workgroups for active tiles
   - `MTLDispatchThreadgroupsIndirectArguments` for dynamic GPU-side work dispatch
   - **Metal advantage**: Indirect dispatch allows GPU to cull work itself

4. **Metal Performance Shaders (MPS)**
   - `MPSCNNConvolution` for diffusion kernels
   - `MPSImageGradient` for moisture gradient calculation
   - `MPSMatrixMultiplication` for layer blending
   - **Metal advantage**: Optimized kernels by Apple, tuned for each GPU

5. **Tile-Based Compute**
   - Split canvas into tiles (e.g., 16×16 threadgroups)
   - Each tile computes independently using threadgroup memory
   - Minimize global memory access by keeping neighbor data in `threadgroup` shared memory
   - **Metal feature**: `threadgroup` memory with explicit control (unlike WebGL)

### Memory Management

**Pixel State Size Calculation (FP16)**:
```
Per pixel (approximate, FP16 half-precision):
- VolumeLayer: 8 layers × 32 bytes = 256 bytes
- PixelVolume header: ~16 bytes
Total: ~272 bytes per pixel

Full HD canvas: 1920×1080 × 272 bytes ≈ 563 MB
SPH particles: ~500K × 48 bytes ≈ 24 MB (typical active)
Render targets: ~51 MB
Working buffers: ~48 MB
Grand total: ~630 MB (FP16, comfortable on 8GB+ GPU)

4K canvas: ~2.5 GB (fits, or use adaptive resolution)
```

**Metal Memory Strategies**:

1. **Unified Memory Optimization**
   - Use `MTLStorageModeShared` for buffers CPU needs to access
   - Use `MTLStorageModePrivate` for GPU-only buffers (faster GPU access)
   - `MTLResourceOptions` with ` hazardTrackingMode` for safety
   - **Metal advantage**: Direct memory mapping, no staging buffers needed

2. **Compressed Texture Storage**
   - ASTC (Adaptive Scalable Texture Compression) for final render
   - BC7 for intermediate render targets
   - Hardware compression/decompression is transparent
   - **Metal advantage**: Full hardware compression support

3. **Memory Pools & Heaps**
   - `MTLHeap` for allocating multiple textures/buffers from single memory block
   - Reduces allocation overhead and fragmentation
   - Automatic heap compaction with `MTLHeap.createTexture(view:)`
   - **Metal feature**: Explicit heap management (not available in WebGL)

4. **Sparse Textures (Metal 2)**
   - `MTLTexture.storageMode = .sparse` for huge canvases
   - Load/unload canvas regions on demand
   - Perfect for 8K+ canvases with panning
   - **Metal advantage**: Sparse textures not available in WebGL/WebGPU yet

5. **Lazy Loading of Tile State**
   - Only load/allocate tiles around the viewport
   - Background tiles rendered to CPU memory, swap out as needed
   - 16K canvas limited only by disk space, not RAM
   - **Metal advantage**: Direct control over memory allocation

### No Browser Constraints

**Metal Advantages**:
- **No memory limit** beyond system RAM (vs 2-4GB browser tab limit)
- **Direct GPU access**—no browser overhead or sandbox
- **Full compute capability**—no WebGPU validation or safety checks
- **Custom pipeline state**—can use any Metal feature, not just WebGPU subset
- **Direct debugging**—Metal Performance HUD shows real GPU timing, not averaged stats

---

## Data Structures & Algorithms (Metal-Enhanced)

### Pixel Storage on GPU

**Storage Buffer Layout** (FP16, aligned for Metal, see VolumeLayer struct above):

```metal
// See VolumeLayer struct in Pixel Metadata section above
// 32 bytes per layer, FP16 throughout, GPU cache line aligned
// Structured buffer: linear GPU array, index = y * width + x
// PixelVolume header: 16 bytes (base_color, total_depth, active_count)
```

**Swizzle-Packed Version** (for 16K+ canvases):
```metal
// Packed for memory efficiency — matches VolumeLayer but FP16 throughout
// Already using FP16 in VolumeLayer struct (half4 color_rgbo, half depth, etc.)
// 32 bytes per layer is already compact. For extreme memory pressure,
// consider texture-per-datatype instead of struct buffers (see kopigajj pattern)

// Metal advantage: half precision gives 2x memory savings with
// sufficient precision for visual properties
```

### Advanced Memory Layouts (Metal-Exclusive)

**Texture-Tiled Data Structure**:
```metal
// Store pixel data in 2D texture instead of linear buffer
// Better cache locality for neighbor access patterns
texture2d<PixelData> pixelDataTexture [[texture(0)]];

// Access with built-in texture sampling hardware
PixelData pixel = pixelDataTexture.read(uint2(x, y));

// Metal advantage: Texture cache is larger and faster than buffer cache
// Hardware bilinear interpolation free for sub-pixel sampling
```

**Depth Field for Impasto Lighting**:
```metal
// Depth stored per layer in structured buffer (not 3D texture)
// Normals computed on-the-fly from central differences
device VolumeLayer* layers [[buffer(0)]];

// Central differences for surface normal estimation
float dL = layers[idx - 1].depth;
float dR = layers[idx + 1].depth;
float dU = layers[idx - canvas_width].depth;
float dD = layers[idx + canvas_width].depth;
float3 normal = normalize(float3(dL - dR, dU - dD, 2.0));

// Metal advantage: Structured buffer gives cache-friendly access
// Normal computation is trivial — no 3D texture or raymarching needed
```

### Neighbor Access Pattern (Threadgroup Memory Optimization)

**8-Connected Neighbor Offsets with Threadgroup Caching**:
```metal
// Compute shader: Simulation.metal (valid Metal Shading Language)
kernel void simulate_physics(
    device VolumeLayer* layers [[buffer(0)]],
    constant SimParams& params [[buffer(1)]],
    uint2 global_id [[thread_position_in_grid]],
    uint2 local_id [[thread_position_in_threadgroup]],
    threadgroup float shared_depth[18][18] [[threadgroup(0)]]
) {
    // Load this pixel and neighbors into threadgroup memory
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            int2 neighbor_pos = int2(global_id) + int2(x, y);
            uint2 shared_pos = uint2(local_id) + uint2(x + 1, y + 1);
            
            neighbor_pos = clamp(neighbor_pos, int2(0),
                                 int2(params.canvas_width - 1, params.canvas_height - 1));
            
            uint nidx = uint(neighbor_pos.y) * params.canvas_width + uint(neighbor_pos.x);
            shared_depth[shared_pos.y][shared_pos.x] = float(layers[nidx].depth);
        }
    }
    
    threadgroup_barrier(mem_flags::mem_threadgroup);
    
    // Compute using cached data (~100x faster than global memory)
    float center = shared_depth[local_id.y + 1][local_id.x + 1];
    float north  = shared_depth[local_id.y][local_id.x + 1];
    float south  = shared_depth[local_id.y + 2][local_id.x + 1];
    float east   = shared_depth[local_id.y + 1][local_id.x + 2];
    float west   = shared_depth[local_id.y + 1][local_id.x];
    
    // Normal from central differences
    float3 normal = normalize(float3(west - east, north - south, 2.0));
    // ... compute physics using cached neighbor data
}
```

**Metal Advantage**: Explicit threadgroup memory with `threadgroup_barrier()` — no equivalent in WebGL/WebGPU (WGSL is more limited).

### Advanced Fluid Dynamics (Metal-Exclusive Features)

**1. MPS-Accelerated Diffusion**:
```metal
// Instead of manual convolution, use Metal Performance Shaders
// MPSConvolutionDescriptor pre-optimized by Apple for each GPU
let diffusionKernel = MPSConvolutionDescriptor(kernelWidth: 3,
                                             kernelHeight: 3,
                                             inputFeatureChannels: 1,
                                             outputFeatureChannels: 1,
                                             neuronFilter: nil)
diffusionKernel.kernelWeights = create_laplacian_kernel()
diffusionKernel.biasTerms = [0.0]

// Run in one function call - hardware optimized
mpsConvolution.encode(commandBuffer: commandBuffer,
                     sourceTexture: moistureTexture,
                     destinationTexture: outputTexture)
```

**2. Adaptive Time Stepping**:
```metal
// Variable time step based on CFL condition for stability
// Reduction kernel: each threadgroup finds local max, then atomically reduces
kernel void compute_max_velocity(
    device VolumeLayer* layers [[buffer(0)]],
    device atomic<float>* max_velocity [[buffer(1)]],
    constant SimParams& params [[buffer(2)]],
    uint2 global_id [[thread_position_in_grid]]
) {
    uint idx = global_id.y * params.canvas_width + global_id.x;
    float2 vel = float2(float(layers[idx].velocity_x), float(layers[idx].velocity_y));
    float speed = length(vel);
    
    // Atomic max reduction across all pixels
    float current = atomic_load_explicit(max_velocity, memory_order_relaxed);
    while (speed > current) {
        if (atomic_compare_exchange_weak_explicit(
                max_velocity, &current, speed,
                memory_order_relaxed, memory_order_relaxed)) {
            break;
        }
    }
}

// CFL condition: dt <= dx / v_max (computed on CPU after reduction)
```

**3. Multi-Scale Simulation (Pyramid Approach)**:
```metal
// Simulate at multiple resolutions simultaneously
// Coarse grid (1/8 resolution) for global fluid dynamics
// Fine grid (full resolution) for detailed brush interactions
texture2d<float> coarse_grid [[texture(0)]];   // 1/8 resolution
texture2d<float> fine_grid [[texture(1)]];     // Full resolution

// Metal advantage: Multiple texture reads/writes in same shader
// Can upsample coarse result and add fine-grain details in one pass
```

**4. Implicit Integration for Stability**:
```metal
// Instead of explicit Euler (unstable for stiff systems)
// Use Jacobi iteration on GPU for implicit diffusion solve
// (I - dt * diffusion * ∇²) color_new = color_old
kernel void jacobi_iteration(
    device VolumeLayer* layers_curr [[buffer(0)]],
    device VolumeLayer* layers_prev [[buffer(1)]],
    constant JacobiParams& params [[buffer(2)]],
    uint2 global_id [[thread_position_in_grid]]
) {
    uint idx = global_id.y * params.canvas_width + global_id.x;
    
    float4 center = float4(float4(layers_prev[idx].color_rgbo));
    float4 left   = float4(float4(layers_prev[idx - 1].color_rgbo));
    float4 right  = float4(float4(layers_prev[idx + 1].color_rgbo));
    float4 up     = float4(float4(layers_prev[idx - params.canvas_width].color_rgbo));
    float4 down   = float4(float4(layers_prev[idx + params.canvas_width].color_rgbo));
    
    float4 laplacian = left + right + up + down - 4.0 * center;
    float4 result = (center + params.dt * params.diffusion_rate * laplacian)
                    / (1.0 + 4.0 * params.dt * params.diffusion_rate);
    
    layers_curr[idx].color_rgbo = half4(result);
}
```

**5. Layer-Stack Compositing with Impasto Lighting** (for depth-aware rendering):
```metal
// 2D canvas rendering: composite layer stack, not raymarching
fragment float4 render_canvas(
    VertexOut in [[stage_in]],
    device VolumeLayer* layers [[buffer(0)]],
    constant RenderParams& params [[buffer(1)]],
    constant LightParams& lighting [[buffer(2)]],
    uint2 pixel_coord [[thread_position_in_grid]]
) {
    uint pixel_idx = pixel_coord.y * params.canvas_width + pixel_coord.x;
    
    float3 composited_color = params.paper_color;
    float accumulated_opacity = 0.0;
    
    for (int layer = 0; layer < params.active_layer_count; layer++) {
        uint layer_idx = pixel_idx * params.max_layers + layer;
        VolumeLayer vl = layers[layer_idx];
        
        if (vl.opacity < 0.001) continue;
        
        float3 layer_color = float3(vl.color_rgbo.rgb);
        
        // Normal from depth gradient (central differences) for impasto
        float3 normal = float3(0, 0, 1);
        if (vl.depth > 0.01) {
            float dL = layers[layer_idx - 1].depth;
            float dR = layers[layer_idx + 1].depth;
            float dU = layers[layer_idx - params.canvas_width].depth;
            float dD = layers[layer_idx + params.canvas_width].depth;
            normal = normalize(float3(dL - dR, dU - dD, 2.0));
        }
        
        // Diffuse lighting
        float diffuse = max(dot(normal, lighting.direction), 0.0);
        float3 lit_color = layer_color * (lighting.ambient + lighting.diffuse * diffuse);
        
        // Specular for glossy mediums
        if (vl.substance_type == OIL || vl.substance_type == ACRYLIC) {
            float3 view_dir = float3(0, 0, 1);
            float3 half_vec = normalize(lighting.direction + view_dir);
            float specular = pow(max(dot(normal, half_vec), 0.0), 32.0);
            lit_color += lighting.specular_color * specular * vl.gloss;
        }
        
        // Over-operator compositing
        float src_alpha = vl.opacity * (1.0 - accumulated_opacity);
        composited_color = mix(composited_color, lit_color, src_alpha);
        accumulated_opacity += src_alpha;
        
        if (accumulated_opacity > 0.999) break;
    }
    
    composited_color = composited_color / (composited_color + 1.0);
    composited_color = pow(composited_color, float3(1.0 / 2.2));
    return float4(composited_color, 1.0);
}
```

**Metal Advantage**: Direct per-pixel compositing with normal-mapped impasto lighting. No raymarching overhead — the depth information is used purely for surface normal estimation, which is a simple central-differences gradient on the depth field.

---

## User Interface Design

### Canvas Layout

```
┌─────────────────────────────────────────────────────────────┐
│  Header: The Robot Paints                             [?] [≡] │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────┐  Tool Bar:                                      │
│  │ Tools   │  [Brush][Smudge][Eraser][Blend][Lift][Water]   │
│  │  ├ 🖌️   │                                                  │
│  │  ├ 🖍️   │  ┌──────────────────────────────────────────┐  │
│  │  ├ 💧   │  │                                          │  │
│  │  └ 🧪   │  │                                          │  │
│  │         │  │                                          │  │
│  │ Layers  │  │           CANVAS                          │  │
│  │  □ L1   │  │                                          │  │
│  │  □ L2   │  │                                          │  │
│  │  □ L3   │  │                                          │  │
│  │  □ L4   │  │                                          │  │
│  │         │  │                                          │  │
│  │ Medium: │  │                                          │  │
│  │ [Water  │  │                                          │  │
│  │  Color] │  │                                          │  │
│  │ [Oil]   │  │                                          │  │
│  │ [Acryl] │  │                                          │  │
│  │ [Charc] │  │                                          │  │
│  └─────────┘  └──────────────────────────────────────────┘  │
│                                                              │
│  Properties:                                                 │
│  Size: [=====|=====]  Opacity: [=======|==]  Wetness: [====]│
│  Flow: [===|=======]  Blend: [=======|==]  Hardness: [====]│
├─────────────────────────────────────────────────────────────┤
│  Zoom: [−] 100% [+]  Undo ↩  Redo ↪  Save 💾  Export 📤     │
└─────────────────────────────────────────────────────────────┘
```

### Interaction Patterns

**Brush Dynamics**:
- **Pressure-sensitive**: If tablet pen, vary opacity/flow by pressure
- **Velocity-based**: Fast strokes = thinner, slower = thicker (realistic)
- **Tilt**: Affects brush shape (if supported by hardware)
- **Mouse wheel**: Adjust brush size

**Tool Behaviors**:
- **Brush**: Deposit medium
- **Smudge**: Move existing medium velocity
- **Eraser**: Remove medium layers
- **Blend**: Mix layers without adding new paint
- **Lift**: Reduce opacity of top layer
- **Water**: Add moisture to blend existing paint

**Keyboard Shortcuts**:
- `[` / `]`: Decrease/increase brush size
- `B`: Brush tool
- `S`: Smudge tool
- `E`: Eraser tool
- `Cmd+Z`: Undo
- `Cmd+Shift+Z`: Redo
- `Cmd+S`: Save

### Responsive Design

**Desktop**: Full-width canvas with side panels
**Tablet**: Collapsible panels, gesture-based controls
**Mobile**: Bottom tool bar, simplified canvas controls

---

## File Structure

```
projects/therobotpaints/
├── Package.swift                          # SPM manifest (swift-tools-version: 6.0)
├── Sources/
│   └── TheRobotPaints/                    # Main module
│       ├── App.swift                      # SwiftUI app entry
│       ├── Models/                        # Swift data models
│       │   ├── PixelState.swift          # VolumeLayer + PixelVolume types
│       │   ├── SPHParticle.swift         # SPH particle type (CPU-side)
│       │   ├── BrushSettings.swift       # Brush configuration
│       │   ├── MediumTypes.swift         # Medium enums & properties
│       │   └── SimulationConfig.swift    # Physics parameters
│       ├── Views/                         # SwiftUI views
│       │   ├── MainView.swift            # Root view (split view)
│       │   ├── CanvasView.swift          # Metal rendering view (MTKView wrapper)
│       │   ├── Tools/
│       │   │   ├── ToolBar.swift         # Tool selector
│       │   │   ├── BrushControls.swift   # Brush property sliders
│       │   │   └── MediumPicker.swift    # Medium selector
│       │   ├── Layers/
│       │   │   ├── LayerPanel.swift      # Layer list
│       │   │   └── LayerInspector.swift  # Layer properties
│       │   └── Utilities/
│       │       ├── Header.swift
│       │       ├── StatusBar.swift
│       │       └── ZoomControls.swift
│       ├── Rendering/                     # Metal rendering
│       │   ├── MetalEngine.swift         # @unchecked Sendable Metal device + queue
│       │   ├── Renderer.swift            # @unchecked Sendable MTKViewDelegate
│       │   ├── MetalView.swift           # NSViewRepresentable wrapper
│       │   └── Pipelines/
│       │       └── RenderPipelineState.swift
│       ├── Simulation/                    # Metal compute engines
│       │   ├── MPMSimulator.swift        # Simulation orchestration
│       │   ├── BrushDeposition.swift     # Stroke processing (CPU→GPU)
│       │   ├── SPHSystem.swift           # Particle system management
│       │   └── DryingKinetics.swift      # Per-medium drying models
│       ├── Shaders/                       # .metal files (excluded from SPM, for Xcode highlighting)
│       │   ├── ShaderHeader.swift        # Shared MSL structs as Swift string literals
│       │   ├── ShaderCanvasInit.swift    # Canvas init kernel source
│       │   ├── ShaderBrushDeposition.swift
│       │   ├── ShaderSPHPhysics.swift
│       │   ├── ShaderFluidDynamics.swift
│       │   ├── ShaderDrying.swift
│       │   └── ShaderRender.swift        # Layer-stack compositor source
│       ├── Protocols/                     # Reusable Metal protocols (from kopigajj)
│       │   ├── MetalShaderCompiler.swift # Runtime MSL compilation
│       │   └── MetalTextureFactory.swift # Texture allocation
│       ├── State/                         # App state management
│       │   └── CanvasStore.swift         # @Observable state store
│       ├── FileIO/                        # Save/load functionality
│       │   ├── CanvasSerializer.swift    # Binary serialization
│       │   ├── LayerExporter.swift       # Image export
│       │   └── Compression.swift         # Compression utilities
│       └── Utils/                         # Utilities
│           ├── Profiler.swift            # Performance profiling
│           └── MetalLogger.swift         # Metal error logging
├── Tests/
│   └── TheRobotPaintsTests/
│       ├── MetalShaderCompilationTests.swift  # Compile every kernel at test time
│       ├── PhysicsTests.swift                 # CPU-side physics tests
│       ├── TestMetalHelper.swift              # Metal device + XCTSkip fallback
│       └── SerializationTests.swift           # Save/load tests
├── docs/
│   ├── planning.md                  # This file
│   ├── voxel-architecture.md        # Architecture details
│   ├── voxel-quick-reference.md     # Diagram quick reference
│   └── kb/
│       ├── metal-reference.md       # Metal patterns from kopigajj
│       └── web-gpu.md               # WebGPU migration reference
├── design/
│   └── (UI mockups, interaction flows)
└── README.md
```

---

## Success Metrics (Metal-Enhanced)

### Technical Performance
- **60 FPS** at 4K canvas resolution (Apple Silicon)
- **< 16ms** response time to brush strokes (1 frame latency)
- **< 4 GB** total memory for 4K canvas (FP16 unified memory efficiency)
- **256 MPixel/s** simulation throughput (millions of pixels per second)
- **Real-time layer-stack compositing** with impasto lighting through 8-layer volume stacks
- **16K canvas support** with sparse textures and tiling
- **Sub-2GB** RAM usage for idle state (efficient memory pooling)

### Simulation Fidelity
- **Watercolor**: Accurate granulation, backruns, edge blooms, flow patterns
- **Oil Paint**: Realistic drying kinetics (weeks to months), impasto accumulation, gloss variation
- **Acrylic**: Two-phase drying (evaporation + polymerization), water-resist layering
- **Charcoal**: Particle smudge physics, transfer between strokes, fixative effects
- **Cross-medium**: 90%+ accuracy in medium interaction rules vs real-world behavior

### User Experience
- **Intuitive** medium switching with instantly recognizable behavior differences
- **Realistic** simulation that traditional artists say "this feels like real painting"
- **Performant** for 8+ hour painting sessions without performance degradation
- **Accessible** to both digital and traditional artists (minimal learning curve)
- **Responsive** UI with 60fps animations even during heavy simulation

### Adoption (macOS App Store)
- **5,000** downloads in first month
- **50,000** monthly active users (6-month target)
- **4.5/5** average App Store rating
- **65%**+ user retention after first week
- **Featured in "New & Noteworthy"** section

 Recognition
- **WWDC Student Challenge** finalist or winner
- **Apple Design Award** nomination
- **Featured in MacStories, MacRumors, and Apple design blogs**

### Technical Benchmarks
- **Compute shader** throughput: 500+ billion operations/second on M3 Max
- **Memory bandwidth**: >400 GB/s effective usage (near metal bandwidth limits)
- **GPU utilization**: 85%+ on typical workloads (minimal CPU bottleneck)
- **Shader compilation**: <100ms cold start (precompiled libraries)

---

## Risks & Mitigations (Metal-Specific)

| Risk | Impact | Mitigation |
|------|--------|------------|
| Metal API complexity leads to bugs | High | Extensive unit testing, Instruments profiling, gradual feature rollout |
| Unified memory memory pressure on large canvases | Medium | Sparse textures, heap pools, memory budget monitoring, progressive loading |
| Compute shader divergence reduces performance | High | Threadgroup optimization, SIMD-friendly algorithms, MPS framework integration |
| GPU thermal throttling on sustained workloads | Medium | Adaptive quality based on thermal state, background work throttling, low-power mode |
| Apple Silicon vs Intel GPUs performance variance | Medium | Conditional code paths, device capability detection, performance testing on both |
| Metal API changes between macOS versions | Medium | Minimum macOS 14+ requirement, conditional compilation for newer features |
| Impasto lighting performance at high resolution | High | LOD system for depth gradient, skip normal computation on flat regions, adaptive lighting detail |
| Complex UI distracts from painting experience | Medium | Collapsible panels, keyboard shortcuts, customizable workspaces, simplified default mode |
| Shader compilation time on app launch | Medium | Precompiled Metal libraries, async compilation, progressive feature loading |
| Subtle simulation bugs not caught in testing | High | Artist beta testing program, visual regression tests, comparison photos with real media |

---

## Open Questions (Metal-Specific)

1. **Canvas Size Limits**: With sparse textures, practical limit is 16K+. Should we support infinite canvas with dynamic loading, or cap at 32K? What's the UX tradeoff for canvas paging?

2. **Simulation Fidelity**: What's the minimum physics timestep for stability? 1/60s vs adaptive sub-stepping? At what resolution does simulation fidelity saturate for visual realism?

3. **Cross-Medium Physics**: What are the physical rules for incompatible media mixing? (e.g., oil won't mix with water-based paint, but can be layered over). Need research on real-world art medium compatibility.

4. **Undo/Redo Strategy**: With complex physics, full state snapshots are memory-heavy. Should we use:
   - Command pattern (store brush strokes, re-simulate)?
   - Hybrid (snapshots every N strokes + commands for increments)?
   - Delta-compression between states?

5. **Web Migration Timing**: When to start web port? After Phase 4 (core features stable) or Phase 6 (performance optimized)? How much Metal-to-WebGPU translation overhead?

6. **File Format**: Custom binary format with:
   - Compression level balance?
   - Schema versioning for backward compatibility?
   - Partial loading (lazy layer metadata)?
   - Encryption for DRM (if App Store distribution)?

7. **Metal 3 & Lighting**: Should we integrate Metal 3 features for:
    - Real-time impasto shadow refinement?
    - Environment mapping for oil gloss reflections?
    - Or stick with central-differences normal maps + Blinn-Phong for cross-device compatibility?

8. **Performance Targets**: Minimum requirements? Should we support:
   - Intel Macs (reduced simulation fidelity)?
   - M1 as baseline (good but not M3 performance)?
   - Require M2+ for optimal experience?

9. **Collaboration Features**: iCloud sync for saved canvases:
   - Full resolution vs thumbnail-only on cloud?
   - Conflict resolution for simultaneous edits?
   - Version history with cloud storage limits?

10. **Integration with Other Apps**: Should we support:
    - Import from Procreate, Photoshop, etc.?
    - Export to standard formats (PSD, TIFF with layers)?
    - Inter-process communication with other macOS creative apps?

---

## References & Inspiration (Metal-Focused)

### Academic Papers
- **"Stable Fluids"** - Jos Stam (1999) - Foundation for fluid simulation
- **"Real-Time Fluid Dynamics for Games"** - Jos Stam (2003)
- **"Physically Based Fluid Animation for Games"** - Bridson & Müller (2014)
- **"Adaptive Time Stepping for Fluid Simulation"** - Fedkiw et al. (2001)
- **"Screen-Space Fluid Rendering"** - van der Laan et al. (2009)

### Metal-Specific Resources
- **Metal Programming Guide** - Apple's official documentation
- **Metal Shading Language Specification** - MSL language reference
- **Metal Performance Shaders Framework** - Optimized compute kernels
- **Metal System Trace Guide** - GPU profiling and optimization
- **Apple GPU Architecture whitepapers** - Unified memory details

### Books
- **"GPU Pro 7"** - Advanced rendering techniques
- **"Fluid Simulation for Computer Graphics"** - Robert Bridson
- **"Introduction to 3D Game Programming with DirectX 12/ Metal"** - Frank Luna
- **"Physically Based Rendering"** - Matt Pharr (relevant for PBR lighting)

### Existing Software (For User Research)
- **Procreate** - Apple Pencil integration, custom brush engine, layer management
- **Corel Painter** - Real-world medium simulation (watercolor, oils, etc.)
- **Krita** - Open-source brush engine, color blending modes
- **Adobe Fresco** - Live watercolor simulation, vector/raster hybrid
- **Rebelle 7** - Watercolor simulation focus, real-time fluid dynamics

### Metal Examples & Sample Code
- **Metal Sample Code** - Apple's official Metal examples
- **Metal Compute Shader Playground** - Interactive compute shader development
- **Apple WWDC Sessions** - "Optimizing Metal Apps" video series
- **Metal GPU Capture** - Xcode GPU frame capture and analysis tool

### Academic Art Medium Research
- **"The Physics of Watercolor Painting"** - Various academic papers on pigment flow
- **"Oil Paint Drying Kinetics"** - Chemistry of paint oxidation
- **"Digital Brush Engines for Natural Media"** - CG conference papers

### Community & Forums
- **Metal Forums** - Apple developer forums for Metal questions
- **Graphics Programming Discord** - Advanced graphics discussion
- **r/GraphicsProgramming** - Reddit community for graphics algorithms

---

## Next Steps

### Immediate Actions (Week 1)

1. **Environment Setup**
   - Install Xcode 16+ with Metal APIs
   - Create macOS app project scaffold
   - Set up SwiftUI + MetalKit integration
   - Configure Metal Performance HUD

2. **Technical Validation**
   - Prototype basic metal compute shader (simple pixel clear)
   - Test threadgroup memory cache performance
   - Verify unified memory zero-copy on Apple Silicon
   - Create basic rendering pipeline (solid color quad)

3. **Performance Baseline**
   - Benchmark buffer creation/destruction costs
   - Measure compute shader dispatch overhead
   - Profile memory bandwidth with Instruments
   - Establish performance targets for different GPU types

4. **UX Research**
   - Interview 3-5 traditional artists about painting workflow
   - Test Procreate/Rebelle for UI patterns analysis
   - Identify pain points in existing digital painting apps
   - Define medium-specific control requirements

5. **Architecture MVP**
   - Design pixel metadata structure (single-layer prototype)
   - Implement GPU buffer management system
   - Create basic brush deposition (CPU to GPU)
   - Build simple UI (SwiftView with color picker)

### Metal-Only Research Tasks

1. **Unified Memory Optimization**
   - Research `MTLStorageMode` best practices
   - Test `MTLHeaps` for memory pool efficiency
   - Benchmark shared vs private buffer performance
   - Profile `MTLResourceOptions` with varying configurations

2. **Threadgroup Memory Strategies**
   - Determine optimal tile size (8×8, 16×16, 32×32)
   - Profile L1 cache hit rates
   - Test shared memory vs global memory patterns
   - Optimize threadgroup barrier placement

3. **MPS Framework Integration**
   - Evaluate `MPSCNNConvolution` for diffusion
   - Test `MPSImageGaussianBlur` for smoothing
   - Profile `MPSMatrixMultiplication` for layer blending
   - Compare custom kernels vs MPS performance

4. **Sparse Texture Feasibility**
   - Test Metal 2 sparse texture support
   - Benchmark lazy tile loading performance
   - Design memory budgeting system for 16K+ canvases
   - Implement tile eviction strategy

5. **Layer-Stack Compositor Prototypes**
    - Test compositing performance through 8-layer stacks
    - Profile depth-gradient normal computation overhead
    - Experiment with per-medium specular models
    - Test impasto lighting quality at various depth resolutions

---

## Advanced Metal Techniques (Beyond Web Capabilities)

### 1. **Dual Compute Pipeline**

Run two separate compute pipelines simultaneously for maximum throughput:

```swift
// Pipeline A: Fluid dynamics (coarse grid)
computePassA.encodeToCommandBuffer(commandBuffer: commandBuffer)
computePassA.setBuffer(coarseGridBuffer, offset: 0, index: 0)
computePassA.dispatchThreadgroups(
    MTLSize(width: coarseGridWidth, height: coarseGridHeight, depth: 1),
    threadsPerThreadgroup: MTLSize(width: 16, height: 16, depth: 1)
)

// Pipeline B: Detail simulation (fine grid) - overlapped with A
computePassB.encodeToCommandBuffer(commandBuffer: commandBuffer)
computePassB.setBuffer(fineGridBuffer, offset: 0, index: 0)
computePassB.dispatchThreadgroups(
    MTLSize(width: fineGridWidth, height: fineGridHeight, depth: 1),
    threadsPerThreadgroup: MTLSize(width: 16, height: 16, depth: 1)
)

// Metal advantage: Overlapping compute passes maximizes GPU utilization
```

### 2. **GPU-Driven Brush Processing**

Offload entire brush stroke preprocessing to GPU:

```metal
// Compute shader: BrushPreprocess.metal
kernel void preprocess_brush(
    texture2d<float, access::write> stroke_mask [[texture(0)]],
    constant BrushStroke& stroke [[buffer(0)]],
    texture2d<float> base_canvas [[texture(1)]],
    uint2 global_id [[thread_position_in_grid]]
) {
    // Calculate brush pressure curve on GPU
    float pressure = calculate_pressure_curve(stroke, global_id);
    
    // Apply velocity-based thickness on GPU
    float thickness = calculate_thickness_from_velocity(stroke, global_id);
    
    // Compute brush shape (tilt from tablet if available)
    float brush_shape = compute_brush_shape(stroke, global_id, pressure);
    
    // Write stroke mask directly to GPU texture
    stroke_mask.write(brush_shape * thickness, global_id);
}
```

**Metal advantage**: No CPU-GPU synchronization for brush preprocessing

### 3. **Event-Based Synchronization**

Fine-grained GPU work synchronization:

```swift
// Stage 1: Physics simulation
let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
computeEncoder.setComputePipelineState(simulationPipeline)
computeEncoder.dispatchThreadgroups(...)
computeEncoder.endEncoding()

// Create GPU event for synchronization
let physicsCompleteEvent = device.makeEvent()!
commandBuffer.encodeSignalEvent(physicsCompleteEvent, value: 1)

// Stage 2: Rendering (waits for physics to complete)
let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: ...)!
commandBuffer.encodeWaitForEvent(physicsCompleteEvent, value: 1)
renderEncoder.setRenderPipelineState(renderPipeline)
renderEncoder.drawPrimitives(...)
renderEncoder.endEncoding()

// Stage 3: Post-processing (can overlap Stage 2 on different GPU cores)
let postProcessEncoder = commandBuffer.makeComputeCommandEncoder()!
postProcessEncoder.setComputePipelineState(postProcessPipeline)
postProcessEncoder.dispatchThreadgroups(...)
postProcessEncoder.endEncoding()

// Metal advantage: Event-based sync is more efficient than pipeline barriers
```

### 4. **Indirect Dispatch for Dynamic Work**

GPU-driven workload culling:

```metal
// Pass 1: Mark active tiles (dirty region detection)
kernel void mark_active_tiles(
    device TileState* tiles [[buffer(0)]],
    constant BrushStroke& stroke [[buffer(1)]],
    device uint* active_tile_count [[buffer(2)]],
    uint2 global_id [[thread_position_in_grid]]
) {
    TileState tile = tiles[global_id.x];
    
    // Check if brush affected this tile
    bool is_active = check_brush_intersection(tile, stroke);
    
    if (is_active) {
        // Atomically increment active tile count
        uint index = atomic_fetch_add_explicit(active_tile_count, 1, memory_order_relaxed);
        tiles[index].is_active = true;
    }
}

// Pass 2: Only simulate active tiles
kernel void simulate_active_tiles(
    device PixelData* pixels [[buffer(0)]],
    constant SimParams& params [[buffer(1)]],
    constant uint* active_tiles [[buffer(2)]],
    uint2 global_id [[thread_position_in_grid]]
) {
    uint tile_index = active_tiles[global_id.x];
    // Only simulate pixels in active tiles
    PixelData pixel = pixels[tile_index];
    // ... simulation logic
}
```

```swift
// Indirect dispatch from GPU
let dispatchBuffer = device.makeBuffer(length: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.size)!
computeEncoder.setBuffer(dispatchBuffer, offset: 0, index: 0)
computeEncoder.setBuffer(pixelBuffer, offset: 0, index: 1)
computeEncoder.dispatchThreadgroupsIndirect(buffer: dispatchBuffer, bufferOffset: 0)
```

**Metal advantage**: GPU decides what work to do, no CPU roundtrip

### 5. **Texture Slicing for Multi-Resolution**

Process canvas at multiple resolutions in a single texture:

```metal
// Single texture with multiple resolution slices
texture2d_array<float, access::read_write> multi_res_canvas [[texture(0)]];

// Slice 0: Full resolution
// Slice 1: 1/2 resolution
// Slice 2: 1/4 resolution

kernel void multi_scale_sim(
    texture2d_array<float, access::read_write> canvas [[texture(0)]]
) {
    uint2 gid = uint2(global_id.x, global_id.y);
    
    // Simulate at full resolution
    simulate_full_res(canvas, gid, slice: 0);
    
    // Simulate at 1/2 resolution (every 2nd pixel)
    if (gid.x % 2 == 0 && gid.y % 2 == 0) {
        simulate_half_res(canvas, gid / 2, slice: 1);
    }
    
    // Simulate at 1/4 resolution (every 4th pixel)
    if (gid.x % 4 == 0 && gid.y % 4 == 0) {
        simulate_quarter_res(canvas, gid / 4, slice: 2);
    }
}
```

**Metal advantage**: One texture, multiple resolution passes, zero-copy between scales

**5. Compute-Centric Layer Compositing**

Use compute shaders for rendering instead of graphics pipeline:

```metal
// Compute shader: ComputeRender.metal
kernel void render_to_texture(
    texture2d<float, access::write> output [[texture(0)]],
    device VolumeLayer* layers [[buffer(0)]],
    constant RenderParams& params [[buffer(1)]],
    constant LightParams& lighting [[buffer(2)]],
    uint2 global_id [[thread_position_in_grid]]
) {
    uint pixel_idx = global_id.y * params.canvas_width + global_id.x;
    
    float3 composited_color = params.paper_color;
    float accumulated_opacity = 0.0;
    
    // Composite layers back-to-front (painter's algorithm)
    for (int layer = 0; layer < params.active_layer_count; layer++) {
        uint layer_idx = pixel_idx * params.max_layers + layer;
        VolumeLayer vl = layers[layer_idx];
        if (vl.opacity < 0.001) continue;
        
        float3 layer_color = float3(vl.color_rgbo.rgb);
        
        // Impasto normal from depth gradient
        float3 normal = float3(0, 0, 1);
        if (vl.depth > 0.01) {
            float dL = layers[layer_idx - 1].depth;
            float dR = layers[layer_idx + 1].depth;
            float dU = layers[layer_idx - params.canvas_width].depth;
            float dD = layers[layer_idx + params.canvas_width].depth;
            normal = normalize(float3(dL - dR, dU - dD, 2.0));
        }
        
        float diffuse = max(dot(normal, lighting.direction), 0.0);
        float3 lit_color = layer_color * (lighting.ambient + lighting.diffuse * diffuse);
        
        float src_alpha = vl.opacity * (1.0 - accumulated_opacity);
        composited_color = mix(composited_color, lit_color, src_alpha);
        accumulated_opacity += src_alpha;
        if (accumulated_opacity > 0.999) break;
    }
    
    composited_color = composited_color / (composited_color + 1.0);
    output.write(float4(pow(composited_color, float3(1.0 / 2.2)), 1.0), global_id);
}
```

**Metal advantage**: More flexible than graphics pipeline, can implement custom rendering techniques

### 7. **Heaps for Texture Pooling**

Efficient memory management for render targets:

```swift
// Create texture heap for render targets (256MB total)
let heapDescriptor = MTLHeapDescriptor()
heapDescriptor.size = 256 * 1024 * 1024  // 256MB
heapDescriptor.storageMode = .private
let renderHeap = device.makeHeap(descriptor: heapDescriptor)!

// Create textures from heap
let depthTextureDescriptor = MTLTextureDescriptor()
depthTextureDescriptor.width = 4096
depthTextureDescriptor.height = 4096
depthTextureDescriptor.usage = [.renderTarget, .shaderRead]
let depthTexture = renderHeap.makeTexture(descriptor: depthTextureDescriptor)!

let compositeTextureDescriptor = MTLTextureDescriptor()
compositeTextureDescriptor.width = 4096
compositeTextureDescriptor.height = 4096
compositeTextureDescriptor.usage = [.renderTarget, .shaderRead]
let compositeTexture = renderHeap.makeTexture(descriptor: compositeTextureDescriptor)!

// Metal advantage: Single memory allocation, no fragmentation, automatic heap compaction
```

These Metal-specific techniques demonstrate why we're building metal-first: full GPU control, advanced synchronization, and capabilities that don't exist or are severely limited in web contexts.

---

*This document will evolve as the project progresses. Updated: 2026-04-22 - Metal-first architecture*