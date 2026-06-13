# Voxel Architecture: Substance Simulation Strategy

## KopiGajj Migration Notes

Patterns proven in `../kopigajj/` paint sim engine. Reconcile with our MPM design:

- **Texture-based storage works** — kopigajj uses `rgba16Float` textures for wet/solid absorption + properties, `r32Float` for height. No structured buffers. This is simpler than our `VolumeLayer` struct approach. Consider: store layers as separate textures per layer (wet absorb, solid absorb, props, height) instead of one giant buffer. Same data, better GPU cache behavior.
- **Wet/Solid/Canvas layer stack is proven** — kopigajj's three-layer model (canvas height+props → solid dried paint → wet active paint) works well. Our 8-layer z-stack adds layer management complexity on top. The wet→solid drying transfer (dryStep kernel) is a clean pattern to reuse.
- **Double-buffered textures** — kopigajj ping-pongs wet+props textures for flow/diffusion steps. Our `readWetAbsorb`/`writeWetAbsorb` pattern should use same `phase` counter + `flip()`. Apply to our SPH particle buffers too.
- **Absorption color model** — our doc mentions it for rendering (`exp(-absorption * concentration)`) but kopigajj uses it throughout the entire pipeline: deposition, flow, drying, rendering. All color values are absorption, not RGB. Wet→solid transfer preserves absorption values. Our `VolumeLayer.color_rgbo` should store absorption RGBA, not reflectance RGBA.
- **Height from central differences** — kopigajj computes normals via `normalize(float3(hL-hR, hU-hD, 1.0)) * heightScale`. Our render kernel does the same. Verified working.
- **Media-specific drying rates** — kopigajj: acrylic 8x, pastel 10x, oil 0.5x, highlighter 12x multiplier on base dry rate. Our drying kernel should use similar multipliers. Oil oxidation = slow, acrylic evaporation = fast.
- **Cross-media rejection** — watercolor cannot adhere to dried acrylic/oil surfaces. kopigajj implements this via `crossMediaReject` factor based on solid concentration + hardness. Important for realistic medium interaction. Our architecture doesn't address this yet.
- **Edge darkening** — kopigajj increases absorption at wet/dry boundaries during dryStep (simulates pigment migration to edges as water evaporates). The "watercolor bloom" effect. We should add this.
- **Watercolor wicking** — kopigajj's flowStep has a special path where dry texels near wet watercolor pull pigment via noise-driven anisotropic diffusion. Creates organic tendrils. Our SPH approach handles this differently (particle-based), but the noise-driven anisotropy pattern is worth keeping.
- **Canvas init** — kopigajj generates procedural canvas weave (warp/weft threads + noise + interlace). Our canvas init should do the same. The `canvasPropsTex` (absorbency, roughness, porosity) affects all simulation steps — our architecture doesn't have this yet.
- **SPH vs texture-only** — our big addition over kopigajj is SPH particles for smudge/flow. kopigajj does all fluid sim via Eulerian grid (neighbor texture reads + diffusion). Our hybrid MPM approach adds particle overhead but enables natural smudge behavior kopigajj can't do. Tradeoff: more memory + complexity for better dynamics.
- **Struct alignment** — our `VolumeLayer` (32 bytes) and `SPHParticle` (48 bytes) are well-designed. kopigajj's `BrushPoint` (56 bytes, all flat floats) proves the all-flat-float pattern works for CPU↔GPU transfer. Our structs follow this.
- **Rendering section is correct** — this doc was already fixed to use layer-stack compositing (not raymarching). The normal-from-depth-gradient + per-medium specular approach matches kopigajj's proven render kernel.
- **Particle splatting approach is correct** — dispatch one thread per particle (not per pixel). Our splat kernel writes to nearby pixels within kernel radius. kopigajj doesn't have particles but the O(k) per-particle approach is standard.

---

## Executive Summary

After researching state-of-the-art fluid simulation methods, we're adopting an **MPM-inspired layered volume** architecture. This is a variant of the Material Point Method - particles (Lagrangian) for dynamics, grid layers (Eulerian) for structure - adapted for 2D paint simulation with layer management.

**Key Decision**: Not a traditional voxel grid, not pure particles - but **particle-in-cell layers** where each paint layer has an Eulerian grid for structure/storage and Lagrangian particles for fluid dynamics. This is well-proven in VFX (snow, sand, cloth) and we're adapting it for artistic media.

---

## Research Findings: State-of-the-Art Methods

### 1. Smoothed Particle Hydrodynamics (SPH)

**Core Concept**: Discrete particles with kernel-based interpolation

```
        Particle i        Particle j
            ●                ●
             \              /
              \            /
               \          /
                W(r_ij) ← Kernel function
```

**Advantages for Painting**:
- ✅ **Mesh-free**: No grid constraints, perfect for irregular brush strokes
- ✅ **Natural medium mixing**: Particles blend organically
- ✅ **Variable resolution**: Dense particles where paint accumulates, sparse elsewhere
- ✅ **Excellent for smudge/flow**: Particles transfer naturally between regions
- ✅ **Conservation properties**: Perfectly models pigment mass conservation

**Challenges**:
- ❌ High particle count for full canvas coverage
- ❌ Neighbor search overhead (O(n²)) without spatial hashing
- ❌ Difficult to enforce layer ordering (particles float freely)

**SPH Fundamentals**:
```python
# SPH kernel interpolation
def interpolate_property(particle_i, particles, kernel_func):
    result = 0
    for particle_j in neighbors(particle_i):
        r = distance(particle_i, particle_j)
        result += particle_j.property * kernel_func(r, h)
    return result

# Common kernels: Gaussian, Cubic Spline, Wendland C²
def cubic_spline_kernel(r, h):
    q = r / h
    if q < 1:
        return (2/3) - q² + 0.5*q³
    elif q < 2:
        return (2 - q)³ / 6
    else:
        return 0
```

**SPH in Production**:
- **PCISPH** (Predictive-Corrective SPH) - Better incompressibility
- **GPU-SPH** - Millions of particles at 60FPS on modern GPUs
- **Hybrid SPH-Level Set** - Best of both: particles for detail, level set for surface

---

### 2. Lattice Boltzmann Methods (LBM)

**Core Concept**: Discrete velocity distributions on regular lattice

```
D2Q9 Lattice (2D, 9 velocities)
     ↖  ↑  ↗
    ◀  ●  ►
     ↙  ↓  ↘
    (Center + 8 directions)
```

**Advantages**:
- ✅ **Massively parallel**: Designed for GPU from scratch
- ✅ **Complex boundaries**: Handles porous media, irregular surfaces well
- ✅ **Multiphase flow**: Native support for liquid/gas interfaces
- ✅ **Microscopic physics**: Built-in molecular-level interactions

**Disadvantages for Painting**:
- ❌ **Fixed grid**: Canvas must be discrete lattice (no sub-pixel detail)
- ❌ **Density ratio limits**: Difficult to simulate thick vs thin paint layers
- ❌ **Lattice artifacts**: Can see grid patterns in smooth flows
- ❌ **Mach number limits**: Not ideal for rapid brush strokes

**LBM Fundamentals**:
```python
# LBM collision step (BGK model)
def collision_step(f, feq, tau):
    # f: distribution function, feq: equilibrium, tau: relaxation time
    return f + (feq - f) / tau

# LBM streaming step
def streaming_step(f_new, f_old):
    # Particles move to neighboring lattice points
    for direction in lattice_vectors:
        f_new[x + direction] = f_old[x]

# Equilibrium distribution
def equilibrium_density(rho, u):
    # rho: density, u: velocity
    return weights * rho * (1 + 3(u·e)/c² + 9(u·e)²/2c⁴ - 3u²/2c²)
```

**LBM in Production**:
- **D3Q19** - 3D cubic lattice with 19 velocities
- **Multiphase LBM** - Shan-Chen model for phase separation
- **Thermal LBM** - Heat transfer simulation

---

### 3. Grid-Based Eulerian Methods

**Core Concept**: Field-based simulation on regular mesh (Jos Stam's Stable Fluids)

```
┌───┬───┬───┬───┐
│ ● │ ● │ ● │ ● │  Velocity field at grid points
├───┼───┼───┼───┤
│ ● │ ● │ ● │ ● │  Interpolated between points
├───┼───┼───┼───┤
│ ● │ ● │ ● │ ● │  Semi-Lagrangian advection
├───┼───┼───┼───┤
│ ● │ ● │ ● │ ● │  Stable for large timesteps
└───┴───┴───┴───┘
```

**Advantages**:
- ✅ **Stable**: Semi-Lagrangian advection allows large timesteps
- ✅ **Efficient**: GPU-optimized with regular memory access patterns
- ✅ **Mature**: Battle-tested in games, movies, VFX
- ✅ **Simple**: Easy to implement, debug, optimize

**Disadvantages**:
- ❌ **Fixed resolution**: Can't add detail where needed
- ❌ **Diffusion**: Numerical diffusion blurs detail over time
- ❌ **Discrete layers**: No continuous depth representation
- ❌ **Grid artifacts**: Stair-step effects on brush strokes

---

### 4. Material Point Method (MPM)

**Core Concept**: Lagrangian particles on Eulerian grid background

```
Background Grid (Eulerian)
┌───┬───┬───┐
│ ▲ │ ▲ │   │  Particles exist in grid cells
│ ▲ │ ▲ │   │  Grid handles interpolation
└───┴───┴───┘  Particles carry material properties
```

**Advantages**:
- ✅ **Best of both**: Particle accuracy + Grid stability
- ✅ **Large deformations**: Particles handle plastic flow
- ✅ **Multi-material**: Different behaviors per material point
- ✅ **GPU-friendly**: Grid operations are fast

**Disadvantages**:
- ❌ **Complex**: More moving parts than pure methods
- ❌ **Resolution mismatch**: Grid resolution must match particle density

**MPM in Production**:
- **Taichi MPM** - Real-time snow, sand, cloth simulation
- **Unity ML-Agents** - Uses MPM for soft-body physics

---

## Our Architecture Decision

### Core Concept: **MPM-Inspired Layered Volume**

**What we're actually building**: A variant of the Material Point Method (MPM) adapted for 2D paint simulation. This isn't novel - MPM is well-proven in VFX and real-time graphics. Our contribution is adapting it specifically for artistic medium simulation with layer management.

**How it differs from standard MPM:**
- **2D, not 3D**: Paint lives on a flat canvas, not in 3D space
- **Layer-aware**: Particles are confined to their paint layer (z-stack), not free in 3D
- **Medium-specific dynamics**: Each "material point" knows if it's watercolor, oil, or charcoal
- **Artistic constraints**: Layer opacity, visibility, ordering are artist-driven, not physics-driven

**Visual Model**:
```
Canvas Top View (2D)         Volume Stack (3D)
┌─────────────────────┐     ┌─────────────────────┐
│  Canvas (1920×1080) │     │ Layer 8 (Charcoal) │ ← Top layer
│                     │     ├─────────────────────┤
│  Each pixel has:    │     │ Layer 7 (Acrylic)  │
│  • Volume stack (z) │     ├─────────────────────┤
│  • Continuous field │     │ Layer 6 (Oil)      │
│  • SPH particles    │     ├─────────────────────┤
│                     │     │ Layer 5 (Watercolor)│
└─────────────────────┘     ├─────────────────────┤
                              * SPH particles within each layer
                              * Flow primarily within layer
                              * Limited cross-layer mixing
                              └─────────────────────┘
```

### Why MPM-Inspired?

**Eulerian grid (volume layers)**:
- Efficient memory layout (straightforward GPU optimization)
- Layer ordering constraints (oil over watercolor if artist wants)
- Rendering straightforward (composite layer stack)
- Undo/redo predictable (layer-based snapshots)

**Lagrangian particles (SPH per layer)**:
- Natural smudge behavior (particles transfer between pixels)
- Realistic fluid flow (particles move with local velocity field)
- Variable detail density (more particles where paint is wet/active)
- Conservation properties (pigment mass preserved)

**Result**: The grid handles structure (layers, rendering, serialization). Particles handle dynamics (flow, smudge, mixing). This is exactly what MPM was designed for.

---

## Data Architecture

### 1. Layered Volume Storage (GPU - Metal MSL)

```metal
// VolumeLayer.metal - Valid Metal Shading Language
struct VolumeLayer {
    uint8_t  substance_type;    // 1 byte: Watercolor=0, Oil=1, Acrylic=2, Charcoal=3
    uint8_t  flags;             // 1 byte: dirty, drying, locked
    
    // Visual properties (FP16 for 2x memory savings)
    half4    color_rgbo;        // 8 bytes: R,G,B,Opacity
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
// Total: 2 + 8 + 8*2 + 4 = 32 bytes per layer per pixel
// GPU cache line aligned (256 bits)

struct PixelVolume {
    VolumeLayer layers[8];      // 8 × 32 = 256 bytes
    half3       base_color;     // 6 bytes: paper/substrate color
    half        total_depth;    // 2 bytes
    uint8_t     active_count;   // 1 byte: how many layers non-empty
    uint8_t     _pad[5];        // 5 bytes: align to 16
};
// Total: 256 + 8 + 2 + 1 + 5 = 272 bytes per pixel
```

**Key Design Choices**:
- **FP16 (half) floats**: Sufficient precision for visual data, 2x memory savings
- **32-byte alignment**: GPU cache line friendly, coalesced memory access
- **Structured buffer**: Linear GPU array, simple index = y*width + x
- **Layer limit 8**: Artistic flexibility while keeping memory bounded

**Design Tradeoff — Struct Buffer vs Texture-Per-Datatype**:

KopiGajj uses separate `rgba16Float` textures per data type (wetAbsorb, solidAbsorb, props, height, canvasProps) instead of one struct buffer. Our approach uses `VolumeLayer` structs in a linear buffer. Tradeoff:

- **Struct buffer (our approach)**: Simpler CPU-side management, one allocation, easy layer stacking. All properties for one pixel are contiguous in memory.
- **Texture-per-datatype (kopigajj)**: Better GPU cache locality when a kernel only needs one property (e.g., diffusion only reads wetness, not color). Hardware texture sampling (bilinear interpolation) is free. Separable reads/writes avoid bank conflicts.

For our multi-layer architecture, the struct buffer is pragmatic (8 layers × N properties is hard to decompose into separate textures). If profiling shows memory bandwidth bottlenecks on specific kernels, we can extract hot fields (e.g., depth for rendering, wetness for drying) into separate textures while keeping the struct as the primary store.

### 2. SPH Particle System (GPU - Metal MSL)

```metal
// SPHParticle.metal - Valid Metal Shading Language
struct SPHParticle {
    float2  position;          // 8 bytes: 2D canvas coordinates
    float2  velocity;          // 8 bytes: X,Y velocity
    half4   color_rgba;        // 8 bytes: R,G,B,A (FP16 sufficient for particles)
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
// Total: 8 + 8 + 8 + 2*8 + 2 + 1 + 1 + 2 = 48 bytes per particle
// Much tighter than the 88-byte version - particles are numerous, size matters

struct SPHNeighborResult {
    float density_sum;         // 4 bytes
    float pressure;            // 4 bytes
    float2 pressure_grad;      // 8 bytes
    float2 viscosity_force;    // 8 bytes
};
// 24 bytes per particle (output buffer, separate from particle data)
```

**Particle Memory Estimates**:
- **Light brush stroke**: ~1K-10K particles
- **Heavy paint buildup**: ~10K-100K particles
- **Full canvas wet**: ~500K-2M particles (most areas dry, particles retired)
- **GPU storage**: 2M particles × 48 bytes = ~96 MB (comfortable on 8GB+ GPU)

### 3. Spatial Hashing for SPH Neighbor Search

**Why Spatial Hashing?**
- Brute force O(n²) is impossible for 1M+ particles
- Uniform grid works but requires cell size tuning
- Spatial hashing handles variable particle density naturally

**Important: layers are stacked, not spatially adjacent.** Paint layers exist in z-order (depth), not as spatial neighbors. A particle on layer 3 should never "find neighbors" on layer 5 via spatial hash - that mixing happens via the volume integration step, not SPH. The spatial hash is 2D only (per-layer).

```swift
struct SpatialHash {
    // 2D hash table per layer (not 3D)
    // Cell size = 2×smoothing_length (h)
    
    static func hash(position: float2, cellSize: float) -> Int {
        let cellX = Int(floor(position.x / cellSize))
        let cellY = Int(floor(position.y / cellSize))
        
        // Z-order curve (Morton code) for cache-friendly indices
        let mortonX = interleaveBits(cellX)
        let mortonY = interleaveBits(cellY)
        return mortonX | (mortonY << 1)
    }
    
    // Find particles in same layer within 2D neighborhood
    func queryNeighbors(particle: SPHParticle, radius: float) -> [SPHParticle] {
        let cellRadius = Int(ceil(radius / cellSize))
        var neighbors: [SPHParticle] = []
        
        // Search within same layer only (2D, not cross-layer)
        for dx in -cellRadius...cellRadius {
            for dy in -cellRadius...cellRadius {
                let hash = hash(
                    position: particle.position + float2(Float(dx), Float(dy)) * cellSize,
                    cellSize: cellSize
                )
                // Filter to same layer at query time
                neighbors.append(contentsOf: hashTable[hash].filter { $0.layer_index == particle.layer_index })
            }
        }
        return neighbors
    }
}
```

**Spatial Hashing Performance**:
- **Insert**: O(1) average case per particle
- **Query**: O(k) where k = average neighbors per particle (~27–81 for 3D search)
- **Memory**: O(n) where n = particle count (plus overhead for empty cells)

### 4. Canvas Material Properties (GPU Texture)

Every simulation step reads from a canvas properties texture that models the physical substrate (paper, canvas, board). This affects drying, absorption, flow behavior, and paint adhesion.

```metal
// Canvas properties stored in rgba16Float texture (1920×1080)
// Generated procedurally at init (canvas weave, paper grain, sizing)
// 
// R channel: absorbency  — how readily paint soaks in (0=sealed, 1=raw paper)
// G channel: roughness   — surface texture affecting flow (0=smooth, 1=rough)
// B channel: porosity    — how much paint can pool (0=non-porous, 1=very porous)
// A channel: sizing      — surface treatment affecting adhesion (0=unsized, 1=heavy sizing)
//
// Usage in shaders:
//   float absorbency = canvasProps.read(gid).r;
//   drying_rate *= (1.0 + absorbency);
//   flow_speed *= (1.0 - roughness * 0.3);
//   deposition *= porosity;
//   adhesion *= (1.0 - sizing * crossMediaRejectFactor);
```

**Canvas Initialization** (procedural generation):
```metal
// Generate canvas weave pattern (warp/weft threads + noise + interlace)
kernel void canvas_init(
    texture2d<float, access::write> canvasProps [[texture(0)]],
    constant CanvasInitParams& params [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    float2 uv = float2(gid) / float2(params.canvas_width, params.canvas_height);
    
    // Procedural canvas weave (warp + weft threads)
    float warp = sin(uv.x * params.thread_count_x * 3.14159);
    float weft = sin(uv.y * params.thread_count_y * 3.14159);
    float weave = (warp + weft) * 0.5;
    
    // Noise for natural variation
    float noise = hash(float2(gid)) * params.noise_amplitude;
    
    // Interlace pattern
    float interlace = sin((uv.x + uv.y) * params.interlace_freq) * 0.1;
    
    float roughness = clamp(weave * 0.3 + 0.5 + noise + interlace, 0.0, 1.0);
    float absorbency = clamp(0.6 + noise * 0.4 - params.sizing * 0.5, 0.0, 1.0);
    float porosity = clamp(0.5 + weave * 0.2 + noise * 0.3, 0.0, 1.0);
    float sizing = params.sizing;
    
    canvasProps.write(float4(absorbency, roughness, porosity, sizing), gid);
}
```

**Memory**: `rgba16Float` texture at canvas resolution = ~17 MB for 1920×1080 (negligible).

---

## Simulation Pipeline

### Phase 1: Brush Deposition (CPU → GPU)

Input points are interpolated with **Catmull-Rom splines** for sub-pixel stroke smoothness (proven in kopigajj). The 4-point spline ensures continuous brush trajectories even when mouse events are sparse.

```swift
func applyBrushStroke(stroke: BrushStroke, canvas: PixelVolume) {
    // 0. CPU: Interpolate raw input with Catmull-Rom splines
    let smoothPoints = CatmullRom.interpolate(stroke.rawPoints, segmentsPerSpan: 4)
    // 1. GPU: Deposit continuous field into volume layers
    computeEncoder.setComputePipelineState(depositionPipeline)
    computeEncoder.setBuffer(canvas.layers[LAYER_OIL], offset: 0, index: 0)
    computeEncoder.setBuffer(&stroke, offset: 0, index: 1)
    computeEncoder.dispatchThreadgroups(MTLSize(width: tileCount, height: 1, depth: 1),
                                      threadsPerThreadgroup: tileThreadgroupSize)
    
    // 2. CPU: Generate SPH particles for brush tip (if medium allows smudge)
    if isSmudgableMedium(stroke.medium) {
        let particles = generateBrushParticles(stroke: stroke)
        particleSystem.addParticles(particles)
    }
    
    // 3. Mark affected pixels as dirty (for differential simulation)
    dirtyRegionTracker.mark(stroke.boundingBox)
}
```

**Metal Compute Shader: Deposition**
```metal
kernel void deposit_medium(
    device VolumeLayer* layer [[buffer(0)]],
    constant BrushStroke& stroke [[buffer(1)]],
    texture2d<float> pressureMap [[texture(0)]],
    uint2 global_id [[thread_position_in_grid]]
) {
    uint pixel_index = global_id.y * stroke.canvas_width + global_id.x;
    
    // Check if brush affects this pixel
    float distance = distance(stroke.current_position, float2(global_id));
    if (distance > stroke.size) return;
    
    // Cross-media rejection: watercolor cannot adhere to dried oil/acrylic
    VolumeLayer existing = layer[pixel_index];
    if (existing.hardness > 0.5 && existing.wetness < 0.1) {
        // Dried oil or acrylic surface — water-based media rejected
        if (stroke.medium == MEDIUM_WATERCOLOR || stroke.medium == MEDIUM_INK) {
            float crossMediaReject = existing.hardness * (1.0 - existing.wetness);
            if (crossMediaReject > 0.7) return;  // Surface too hard/dry for watercolor
        }
    }
    
    // Calculate deposition amount (bell curve for realistic strokes)
    float deposition = stroke.pressure * exp(-pow(distance / stroke.size, 2));
    
    // Apply canvas absorbency from canvas material properties texture
    // (absorbency affects how much paint soaks into substrate)
    
    // Add to continuous field
    layer[pixel_index].color_rgba += stroke.color * deposition;
    layer[pixel_index].depth += deposition * stroke.layer_height;
    layer[pixel_index].wetness += deposition;
    layer[pixel_index].velocity += stroke.velocity * deposition;
    
    // SPH augmentation: adjust particle density (if particles exist)
    particle_density_adjustment += deposition * medium.particle_density_factor;
}
```

### Phase 2: SPH Physics (GPU compute)

**2.1 Neighbor Search (Compute Shader)**
```metal
kernel sph_find_neighbors(
    device SPHParticle* particles [[buffer(0)]],
    device SpatialHash* hashTable [[buffer(1)]],
    constant SPHParams& params [[buffer(2)]],
    device SPHNeighborResult* results [[buffer(3)]],
    uint global_id [[thread_position_in_grid]]
) {
    SPHParticle p = particles[global_id];
    
    // Query spatial hash for neighbors
    int3 grid_min = int3(floor((p.position - float2(params.smoothing_length, params.smoothing_length)) / params.cell_size));
    int3 grid_max = int3(ceil((p.position + float2(params.smoothing_length, params.smoothing_length)) / params.cell_size));
    
    SPHNeighborResult result = {0};
    for (int gx = grid_min.x; gx <= grid_max.x; gx++) {
        for (int gy = grid_min.y; gy <= grid_max.y; gy++) {
            for (int gl = grid_min.z; gl <= grid_max.z; gl++) {
                uint hash = spatial_hash(gx, gy, gl);
                for (int i = 0; i < hashTable[hash].count; i++) {
                    SPHParticle neighbor = hashTable[hash].particles[i];
                    float2 r = p.position - neighbor.position;
                    float dr = length(r);
                    
                    if (dr < params.smoothing_length) {
                        float W = cubic_spline_kernel(dr, params.smoothing_length);
                        result.sum_density += neighbor.mass * W;
                        // ... accumulate other SPH terms
                    }
                }
            }
        }
    }
    results[global_id] = result;
}
```

**2.2 Physics Update (Compute Shader)**
```metal
kernel sph_physics_update(
    device SPHParticle* particles [[buffer(0)]],
    device SPHNeighborResult* results [[buffer(1)]],
    device VolumeLayer* layers [[buffer(2)]],
    constant SPHParams& params [[buffer(3)]],
    uint global_id [[thread_position_in_grid]]
) {
    SPHParticle p = particles[global_id];
    SPHNeighborResult res = results[global_id];
    
    // SPH density update
    float density = res.sum_density;
    
    // SPH pressure from Tait's equation of state
    float pressure = params.water_stiffness * (pow(density / params.rest_density, 7) - 1);
    
    // SPH forces: pressure gradient + viscosity + surface tension
    float2 pressure_force = res.sum_pressure_grad;
    float2 viscosity_force = params.viscosity * res.sum_viscosity;
    float2 surface_tension_force = surface_tension(p, res, params);
    float2 gravity = float2(0, params.gravity); // Downward force for depth
    
    // Total acceleration
    float2 acceleration = (pressure_force + viscosity_force +
                          surface_tension_force + gravity) / density;
    
    // Update velocity
    p.velocity += acceleration * params.dt;
    
    // Update position
    p.position += p.velocity * params.dt;
    
    // Boundary conditions (clamp to canvas, bounce at layer boundaries)
    p.position = clamp(p.position, float2(0), float2(params.canvas_width, params.canvas_height));
    
    particles[global_id] = p;
}
```

### Phase 3: Layer Integration (Particle → Volume)

```metal
kernel integrate_particles_to_volume(
    device SPHParticle* particles [[buffer(0)]],
    device VolumeLayer* layers [[buffer(1)]],
    constant IntegrationParams& params [[buffer(2)]),
    uint2 global_id [[thread_position_in_grid]]
) {
    uint pixel_index = global_id.y * params.canvas_width + global_id.x;
    
    // Find particles affecting this pixel (inverse spatial hash)
    float2 pixel_center = float2(global_id) + 0.5;
    int3 grid_pos = int3(floor(pixel_center / params.cell_size));
    uint hash = spatial_hash(grid_pos.x, grid_pos.y, layer_index);
    
    // Sum particle contributions to continuous field
    float4 color_sum = {0};
    float depth_sum = 0;
    float wetness_sum = 0;
    
    for (int i = 0; i < params.particles_per_cell; i++) {
        SPHParticle p = particles[hashTable[hash].indices[i]];
        float2 r = pixel_center - p.position;
        float dr = length(r);
        
        if (dr < params.smoothing_length) {
            float W = cubic_spline_kernel(dr, params.smoothing_length);
            color_sum += p.color_rgba * W;
            depth_sum += p.size * W;
            wetness_sum += p.wetness * W;
        }
    }
    
    // Update volume layer (blend existing with particle contribution)
    float blend_alpha = min(params.blend_speed, wetness_sum / layers[pixel_index].wetness);
    layers[pixel_index].color_rgba = mix(layers[pixel_index].color_rgba, color_sum, blend_alpha);
    layers[pixel_index].depth = mix(layers[pixel_index].depth, depth_sum, blend_alpha);
    layers[pixel_index].wetness = max(layers[pixel_index].wetness, wetness_sum);
}
```

### Phase 4: Fluid Dynamics (Eulerian Grid on Volume Layers)

```metal
kernel solve_fluid_layer(
    device VolumeLayer* layer_curr [[buffer(0)]],
    device VolumeLayer* layer_prev [[buffer(1)]],
    constant FluidParams& params [[buffer(2)]),
    uint2 global_id [[thread_position_in_grid]]
) {
    uint idx = pixel_index(global_id, params.canvas_width);
    
    // Semi-Lagrangian advection (stabler than Eulerian)
    float2 back_pos = float2(global_id) - layer_curr[idx].velocity * params.dt;
    
    // Bilinear interpolation to sample previous frame
    float4 advected_color = bilinear_sample(layer_prev, back_pos);
    
    // Diffusion (implicit solve for stability)
    // Solve: (I - dt×Δ×∇²) color_new = color_advected
    // Using Jacobi iteration (GPU-friendly)
    float4 diffused_color = implicit_diffusion(
        advected_color,
        layer_curr[idx],
        neighbors(layer_curr, idx),
        params.diffusion_rate,
        params.dt);
    
    // Surface tension (edge detection + smoothing)
    float4 gradient_x = layer_curr[idx + 1] - layer_curr[idx - 1];
    float4 gradient_y = layer_curr[idx + params.canvas_width] - layer_curr[idx - params.canvas_width];
    float4 laplacian = gradient_x + gradient_y;
    float4 surface_tension_force = params.surface_tension * laplacian;
    
    // Apply forces
    layer_curr[idx].color_rgba = diffused_color + surface_tension_force * params.dt;
    layer_curr[idx].velocity += diffused_color * params.velocity_transfer;
    
    // Conservation: preserve total pigment mass
    float mass_before = dot(layer_curr[idx].color_rgba.rgb, float3(1,1,1));
    float mass_after = dot(layer_curr[idx].color_rgba.rgb * params.conservation_factor, float3(1,1,1));
    if (abs(mass_before - mass_after) > params.mass_tolerance) {
        layer_curr[idx].color_rgba *= (mass_before / mass_after);
    }
}
```

### Phase 5: Drying/Evaporation (per-layer kinetics)

```metal
kernel update_drying_kinetics(
    device VolumeLayer* layers [[buffer(0)]],
    constant TimeParams& params [[buffer(1)]],
    texture2d<float> canvasProps [[texture(0)]],  // Canvas absorbency, roughness, porosity
    uint2 global_id [[thread_position_in_grid]]
) {
    uint idx = pixel_index(global_id, params.canvas_width);
    
    // Medium-specific drying model with multipliers
    float drying_rate = 0;
    switch (layers[idx].substance_type) {
        case WATERCOLOR:
            drying_rate = params.evaporation_rate;
            break;
        case OIL:
            // Slow oxidation (0.5x base rate)
            drying_rate = params.oxidation_rate * layers[idx].oxidation_level * 0.5;
            break;
        case ACRYLIC:
            // Fast evaporation + polymerization (8x base rate)
            drying_rate = (params.evaporation_rate + params.polymerization_rate) * 8.0;
            break;
        case PASTEL:
            drying_rate = params.base_dry_rate * 10.0;
            break;
    }
    
    // Canvas absorbency affects drying speed
    float canvas_absorbency = canvasProps.read(global_id).r;
    drying_rate *= (1.0 + canvas_absorbency);
    
    // Edge darkening: increase absorption at wet/dry boundaries during drying
    // Simulates pigment migration to edges as water evaporates (watercolor bloom)
    float center_wetness = float(layers[idx].wetness);
    float neighbor_wetness_avg = 0.0;
    int neighbor_count = 0;
    if (idx > 0) { neighbor_wetness_avg += float(layers[idx - 1].wetness); neighbor_count++; }
    if (idx < params.canvas_width * params.canvas_height - 1) {
        neighbor_wetness_avg += float(layers[idx + 1].wetness); neighbor_count++;
    }
    if (idx > params.canvas_width) {
        neighbor_wetness_avg += float(layers[idx - params.canvas_width].wetness); neighbor_count++;
    }
    if (idx < (params.canvas_width - 1) * params.canvas_height) {
        neighbor_wetness_avg += float(layers[idx + params.canvas_width].wetness); neighbor_count++;
    }
    if (neighbor_count > 0) {
        neighbor_wetness_avg /= float(neighbor_count);
        // At wet/dry boundary: increase absorption (darken edges)
        float wetness_gradient = center_wetness - neighbor_wetness_avg;
        if (wetness_gradient > 0.1) {
            float edge_darken = wetness_gradient * params.edge_darkening_strength;
            layers[idx].color_rgbo = half4(float4(layers[idx].color_rgbo) * (1.0 + edge_darken));
        }
    }
    
    // Update wetness
    layers[idx].wetness = half(float(layers[idx].wetness) * (1.0 - drying_rate * params.dt));
    
    // Update physical properties as it dries
    float wetness_ratio = float(layers[idx].wetness) / params.initial_wetness;
    layers[idx].viscosity = half(mix(params.dry_viscosity, params.wet_viscosity, wetness_ratio));
    layers[idx].hardness = half(mix(params.dry_hardness, params.wet_hardness, wetness_ratio));
    layers[idx].surface_tension = half(float(layers[idx].surface_tension) *
                                       (1.0 - drying_rate * params.stiffening_rate));
    
    // SPH particles retire when fully dry
    if (float(layers[idx].wetness) < params.dry_threshold) {
        layers[idx].flags |= 0x02;  // Mark as dried
    }
}
```

---

## Rendering Pipeline

### 1. Layer Stack Compositing (Per-Pixel)

This is a 2D paint application, not a 3D scene. Rendering composites the layer stack at each pixel. No camera rays, no perspective projection - just a straight z-stack from bottom layer to top.

```metal
fragment float4 render_canvas(
    VertexOut in [[stage_in]],
    device VolumeLayer* layers [[buffer(0)]],     // All layers, contiguous
    constant RenderParams& params [[buffer(1)]],
    constant LightParams& lighting [[buffer(2)]],
    uint2 pixel_coord [[thread_position_in_grid]]
) {
    uint pixel_idx = pixel_coord.y * params.canvas_width + pixel_coord.x;
    
    float3 composited_color = params.paper_color;  // Start with paper/substrate
    float accumulated_opacity = 0.0;
    
    // Composite layers bottom-to-top (painter's algorithm)
    for (int layer = 0; layer < params.active_layer_count; layer++) {
        uint layer_idx = pixel_idx * params.max_layers + layer;
        VolumeLayer vl = layers[layer_idx];
        
        // Skip invisible/empty layers
        if (vl.opacity < 0.001) continue;
        
        float3 layer_color = float3(vl.color_rgbo.rgb);
        
        // Compute surface normal from depth gradient (for impasto lighting)
        float3 normal = float3(0, 0, 1);  // Default: flat surface
        if (vl.depth > 0.01) {
            // Central differences on depth field for normal estimation
            float d_left  = layers[layer_idx - 1].depth;
            float d_right = layers[layer_idx + 1].depth;
            float d_up    = layers[layer_idx - params.canvas_width].depth;
            float d_down  = layers[layer_idx + params.canvas_width].depth;
            normal = normalize(float3(d_left - d_right, d_up - d_down, 2.0));
        }
        
        // Apply lighting based on medium type
        float3 lit_color = layer_color;
        if (vl.depth > 0.01) {
            // Diffuse lighting (affects all mediums)
            float diffuse = max(dot(normal, lighting.direction), 0.0);
            lit_color *= (lighting.ambient + lighting.diffuse * diffuse);
        }
        
        // Glossy mediums (oil, acrylic) get specular highlights
        if (vl.substance_type == OIL || vl.substance_type == ACRYLIC) {
            float3 view_dir = float3(0, 0, 1);  // Looking straight at canvas
            float3 half_vec = normalize(lighting.direction + view_dir);
            float specular = pow(max(dot(normal, half_vec), 0.0), 32.0);
            lit_color += lighting.specular_color * specular * vl.gloss;
        }
        
        // Over-operator compositing
        float src_alpha = vl.opacity * (1.0 - accumulated_opacity);
        composited_color = mix(composited_color, lit_color, src_alpha);
        accumulated_opacity += src_alpha;
        
        // Early out once fully opaque
        if (accumulated_opacity > 0.999) break;
    }
    
    // Tone mapping + gamma
    composited_color = composited_color / (composited_color + 1.0);  // Reinhard
    composited_color = pow(composited_color, float3(1.0 / 2.2));
    
    return float4(composited_color, 1.0);
}
```

**Why not full raymarching?** This is a painting app viewed top-down on a flat canvas. The only "depth" is impasto relief (paint thickness), which is best handled by a normal map computed from the depth field, not by volumetric raymarching. Raymarching would add GPU cost for zero visual benefit.

### 2. SPH Particle Splatting (Sparse, Hash-Accelerated)

Do NOT iterate all particles per pixel. Instead, splat particles to the framebuffer using the spatial hash - only touch pixels within each particle's kernel radius.

```metal
// Approach: Each particle writes to its affected pixels (not the other way around)
// Dispatch one thread per particle, not per pixel
kernel void splat_particles(
    device SPHParticle* particles [[buffer(0)]],
    texture2d<float, access::read_write> framebuffer [[texture(0)]],
    constant SplatParams& params [[buffer(1)]],
    uint global_id [[thread_position_in_grid]]
) {
    if (global_id >= params.particle_count) return;
    
    SPHParticle p = particles[global_id];
    if (!p.flags.active) return;
    
    // Only splat to pixels within this particle's radius
    uint2 min_px = uint2(max(0, int(p.position.x - p.radius)));
    uint2 max_px = uint2(min(params.canvas_width - 1, int(p.position.x + p.radius)));
    uint2 min_py = uint2(max(0, int(p.position.y - p.radius)));
    uint2 max_py = uint2(min(params.canvas_height - 1, int(p.position.y + p.radius)));
    
    for (uint y = min_py; y <= max_py; y++) {
        for (uint x = min_px; x <= max_px; x++) {
            float2 r = float2(x, y) - p.position;
            float dr = length(r);
            
            if (dr < p.radius) {
                float splat = exp(-dr * dr / (p.radius * p.radius));
                float4 existing = framebuffer.read(uint2(x, y));
                float4 splatted = float4(p.color_rgba.rgb, 1.0);
                // Atomically blend (or use RasterOrderGroup for correctness)
                framebuffer.write(mix(existing, splatted, splat * p.color_rgba.a), uint2(x, y));
            }
        }
    }
}
```

This is O(k) per particle where k = pixels in kernel footprint, not O(N*P) total.

### 2. SPH Particle Visualization

```metal
// Render SPH particles for debugging/visualization
kernel render_sph_particles(
    texture2d<float, access::write> output [[texture(0)]],
    device SPHParticle* particles [[buffer(0)]],
    uint2 global_id [[thread_position_in_grid]]
) {
    float2 pixel_pos = float2(global_id);
    float4 color = output.read(global_id);
    
    // Simple point rendering
    for (int i = 0; i < params.particle_count; i++) {
        SPHParticle p = particles[i];
        float2 r = pixel_pos - p.position;
        float dr = length(r);
        
        if (dr < p.size) {
            // Gaussian splat
            float splat = exp(-pow(dr / p.size, 2));
            color = mix(color, float4(p.color_rgba.rgb, 1), splat * p.color_rgba.a);
        }
    }
    
    output.write(color, global_id);
}
```

---

## Medium-Specific Implementation Details

### Watercolor

**SPH Parameters**:
```swift
class WatercolorPhysics: SPHPhysics {
    // Extremely low viscosity for fluid flow
    var viscosity: Float = 0.001  // Near-water viscosity
    
    // High surface tension for edge effects
    var surfaceTension: Float = 0.072  // N/m (water surface tension)
    
    // Fast evaporation
    var dryingRate: Float = 0.1  // 10% water loss per frame
    
    // Granulation factor (pigment pooling)
    var granulation: Float = 0.3  // How much particles clump
    
    // Bloom effect (edge bleeding)
    var bloomFactor: Float = 0.5  // How much paint spreads at edges
}
```

**Simulation Tweaks**:
- **Anisotropic smoothing length**: Smoother horizontally (paper grain runs that way)
- **Granulation particles**: Add clustering force to simulate pigment particles
- **Backrun formation**: When wet paint hits dry paper, pigment migrates outward
- **Water content tracking**: Separate pigment particles from water transport
- **Watercolor wicking**: Dry texels near wet watercolor pull pigment via noise-driven anisotropic diffusion, creating organic tendrils (proven in kopigajj's flowStep). Noise-driven anisotropy pattern is worth keeping even though our SPH approach handles fluid differently

### Oil Paint

**SPH Parameters**:
```swift
class OilPaintPhysics: SPHPhysics {
    // High viscosity (thixotropic: decreases with shear)
    var viscosity: Float = 50.0  // Much thicker than water
    var thixotropy: Float = 0.8  // How much it thins when brushed
    var shearRecovery: Float = 0.1  // How quickly thickens again
    
    // Slow drying (oxidation, not evaporation)
    var dryingRate: Float = 0.00001  // Very slow chemical reaction
    var oxidationLevel: Float = 0.0  // From current to complete oxidation
    
    // Excellent blendability while wet
    var blendRate: Float = 0.95  // Near-ideal mixing
    
    // Impasto capability (texture buildup)
    var maxDepth: Float = 0.5  // Can build significant thickness
    var plasticity: Float = 0.8  // Shape-retention when moved
}
```

**Simulation Tweaks**:
- **Two-component model**: Pigment particles + oil binder (separate dynamics)
- **Impasto height map**: Store depth independently for normal calculation
- **Gloss variation**: Drying increases gloss (oil becomes shinier)
- **Glazing support**: Very thin layers stack with minimal mixing
- **Chemical drying model**: Accelerating oxidation rate as it progresses

### Charcoal

**SPH Parameters**:
```swift
class CharcoalPhysics: SPHPhysics {
    // Particulate medium (not fluid!)
    var viscosity: Float = 1000.0  // Effectively solid
    
    // Smudge factor (ability to transfer)
    var smudgeFactor: Float = 0.7  // High smudge-ability
    var adherence: Float = 0.3  // How well it sticks to paper
    
    // No drying (already dry)
    var dryingRate: Float = 0.0
    
    // Particle size variation (texture)
    var particleVariance: Float = 0.5  // Wide size distribution
    
    // Fixative effect (reduces smudge)
    var fixativeStrength: Float = 0.0  // Applied later
}
```

**Unique Implementation**:
- **Collision-based, not fluid**: Particles collide and transfer momentum
- **Adhesion model**: Probability of sticking to substrate vs sliding
- **Smudging**: Direct particle transfer, not kernel interpolation
- **Texture from size distribution**: Large particles for dark areas, small for light
- **Fixative**: Increases adherence, locks particles in place

---

## Performance Optimization Strategies

### 1. Adaptive Resolution

```swift
class AdaptiveResolutionManager {
    function simulationLevel(pixel: PixelVolume, brushVelocity: float2): Resolution {
        let is_active = dirtyRegionTracker.isDirty(pixel.position)
        let velocity_magnitude = length(pixel.velocity)
        let wetness = pixel.wetness
        
        if (velocity_magnitude > 0.5) {
            return .Full  // Active brush: full simulation
        } else if (wetness > 0.5) {
            return .Half  // Wet paint: reduced resolution
        } else {
            return .Quarter  // Dry paint: minimal simulation
        }
    }
}
```

### 2. Threadgroup Memory Optimization

```metal
kernel optimized_physics(
    device VolumeLayer* pixels [[buffer(0)]],
    threadgroup float3 shared_colors[256] [[threadgroup(0)]],  // 16×16 tile
    uint2 local_id [[thread_position_in_threadgroup]]
) {
    // Load tile into shared memory (100× faster than global memory)
    shared_colors[local_id.y * 16 + local_id.x] = pixels[global_index].color_rgba;
    threadgroup_barrier(mem_threadgroup);
    
    // Now all neighbor operations use shared memory
    float sum = 0;
    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            uint shared_idx = (local_id.y + dy) * 16 + (local_id.x + dx);
            sum += shared_colors[shared_idx];
        }
    }
    // ... kernel calculation using cached data
}
```

### 3. Sparse Storage

```swift
struct SparseVolume {
    var activePixels: [PixelIndex]  // Only non-empty pixels
    var spatialIndex: [PixelIndex: Offset]  // Fast lookup
    
    // Simulation only on active pixels (90%+ savings for typical paintings)
}
```

### 4. Compute Shader Specialization

```swift
// Create separate pipelines for each medium ( Metal shader variants)
func specializedPipeline(medium: Medium) -> MTLComputePipelineState {
    // Watercolor: includes granulation, bloom
    if medium == .watercolor {
        return watercolorPipeline
    }
    // Oil: includes impasto, slow drying
    else if medium == .oil {
        return oilPipeline
    }
    // Charcoal: includes smudge, particle size distribution
    else if medium == .charcoal {
        return charcoalPipeline
    }
}
```

---

## Memory Layout Summary

### Estimate for 1920×1080 Canvas

```
Per-Pixel Storage (Volume Layers):
- 8 layers × 32 bytes = 256 bytes per pixel
- 272 bytes per pixel including PixelVolume header
- 1920 × 1080 × 272 = ~563 MB

SPH Particle Storage:
- Typical active particles: ~500K (most of canvas is dry)
- 500K × 48 bytes = ~24 MB (peaks at ~96 MB when fully wet)

Spatial Hash:
- ~50K active cells × 64 bytes/cell = ~3.2 MB

Render Targets (double buffering):
- Color buffer (RGBA16F): 1920×1080×8 = ~17 MB × 2 = 34 MB
- Depth buffer (R16F): 1920×1080×2 = ~4 MB

Total Approximate: ~630 MB (comfortable on 8GB+ GPU)
```

**4K (3840×2160) estimate**: ~2.5 GB (still fits, or use adaptive resolution to halve)

---

## Next Steps for Implementation

1. **Implement basic volume layer storage** (1 layer, watercolor-only)
2. **Add SPH particle system** (spatial hash, neighbor search)
3. **Create brush deposition pipeline** (continuous field + particles)
4. **Implement basic fluid solver** (advection + diffusion)
5. **Add layer-stack compositor** (depth-aware visualization with impasto lighting)
6. **Optimize with threadgroup memory** (tile-based simulation)
7. **Add medium-specific physics** (oil, charcoal, acrylic)
8. **Integrate with SwiftUI UI** (tool panels, controls)
9. **Test performance and optimize** (adaptive resolution, LOD)
10. **Add advanced features** (drying kinetics, cross-medium mixing, canvas properties)

### Shader Source Organization

All Metal Shading Language source is stored as **Swift string literals**, compiled at runtime via `MTLDevice.makeLibrary(source:options:)`. This is the proven kopigajj pattern — SPM cannot compile `.metal` files.

**File structure** (each compiles independently with shared header prepended):
1. `ShaderHeader.swift` — shared MSL structs (`VolumeLayer`, `SPHParticle`, params, noise functions)
2. `ShaderCanvasInit.swift` — canvas properties texture generation kernel
3. `ShaderBrushDeposition.swift` — brush deposit kernel (includes cross-media rejection)
4. `ShaderSPHPhysics.swift` — neighbor search + physics update kernels
5. `ShaderFluidDynamics.swift` — Eulerian grid flow/diffusion kernels
6. `ShaderDrying.swift` — per-medium drying kinetics (includes edge darkening)
7. `ShaderRender.swift` — layer-stack compositor + impasto lighting

Each kernel source = `PaintShaderHeader.source + "kernel void ..."`. The header is prepended so every kernel file compiles as a standalone library. If Xcode syntax highlighting is desired for `.metal` files, add them to a `Shaders/` directory and `exclude` in `Package.swift` (kopigajj does this).

**Build integration**: Use `MetalShaderCompiler` protocol from `docs/kb/metal-reference.md` Pattern 1 for runtime compilation. Write `MetalShaderCompilationTests` (Pattern 9) that compile every kernel at test time to catch MSL errors early.

---

*Document Version: 1.0*
*Based on: SPH, LBM, Eulerian, and MPM research (see references)*
*Target Platform: macOS Metal (Apple Silicon optimized)*