# Common Bottlenecks

Diagnostic guide for identifying and resolving Metal performance bottlenecks.

## Quick Identification

| Symptom | Likely Bottleneck | First Check |
|---|---|---|
| Frame time increases with draw call count (not triangle count) | CPU-bound | Pipeline state changes per frame |
| Frame time increases with triangle count | Vertex-bound | Vertex shader complexity |
| Frame time increases with screen resolution | Fragment-bound | Fragment shader complexity, overdraw |
| Frame time stays high regardless of scene content | Bandwidth-bound | Texture sizes, render target count |
| Stutters every few seconds | Memory pressure | Allocation/deallocation in render loop |
| First frame is slow, rest are fine | Pipeline compilation | Cache pipeline states |

## CPU Bottlenecks

### Too Many Draw Calls

**Diagnosis:** GPU capture shows many small draw calls with gaps between them.

**Solutions (in order of effort):**
1. **Instancing** — Same mesh, different transforms: use `drawIndexedPrimitives(..., instanceCount:)`
2. **Mesh merging** — Combine static meshes with the same material into one buffer
3. **Indirect Command Buffers (ICBs)** — GPU generates draw calls, bypassing CPU entirely

```swift
// Before: 1000 draw calls
for object in objects {
    encoder.setVertexBuffer(object.mesh, offset: 0, index: 0)
    encoder.drawIndexedPrimitives(type: .triangle, ...)
}

// After: 1 instanced draw call
encoder.setVertexBuffer(mergedMesh, offset: 0, index: 0)
encoder.setVertexBuffer(instanceData, offset: 0, index: 1)
encoder.drawIndexedPrimitives(type: .triangle, ..., instanceCount: 1000)
```

### Pipeline State Changes

**Diagnosis:** GPU capture shows pipeline state switches between draw calls.

**Solutions:**
1. **Sort draws by pipeline** — Group all objects using the same material
2. **Uber-shader with function constants** — Fewer pipeline variants
3. **Reduce unique materials** — Texture atlases, material palettes

### CPU Allocation in Render Loop

**Diagnosis:** Instruments shows `malloc` or `makeBuffer` calls during rendering.

**Solutions:**
1. Pre-allocate all buffers at initialization
2. Use buffer pools / ring buffers for dynamic data
3. Never call `device.makeBuffer()` inside `draw(in:)`

## Vertex Bottlenecks

### Complex Vertex Shader

**Diagnosis:** Shader profiler shows high ALU cost in vertex function.

**Solutions:**
1. Move expensive computation to compute pre-pass
2. Reduce attribute count (do you need tangent + bitangent, or can you derive one?)
3. Use `half` precision where possible (especially on mobile)

### Too Many Vertices

**Diagnosis:** Frame time scales linearly with mesh vertex count.

**Solutions:**
1. **LOD (Level of Detail)** — Switch to simpler meshes at distance
2. **Frustum culling** — Don't submit off-screen objects (compute pre-pass)
3. **Occlusion culling** — Skip objects hidden behind others
4. **Mesh simplification** — Use fewer triangles for distant or small objects

## Fragment Bottlenecks

### Overdraw

**Diagnosis:** Fragment shader runs many more times than there are pixels.

**Solutions:**
1. **Sort opaque objects front-to-back** — Early-Z rejects hidden fragments
2. **Depth pre-pass** — Render depth-only first, then full shading with `depthCompareFunction: .equal`
3. **Reduce transparent surfaces** — Alpha blending disables early-Z

### Texture Bandwidth

**Diagnosis:** Frame time correlates with texture resolution, not shader complexity.

**Solutions:**
1. **Enable mipmaps** — Reduces bandwidth for distant textures dramatically
2. **Use compressed formats** — ASTC (Apple GPU) or BC7 (macOS) for 4:1 to 8:1 compression
3. **Reduce texture resolution** — 2048→1024 saves 75% bandwidth per sample
4. **Use texture atlases** — Reduce texture binding changes

### Complex Fragment Shader

**Diagnosis:** Shader profiler shows high per-fragment cost.

**Solutions:**
1. **Reduce texture samples** — Each `texture.sample()` has latency
2. **Use `half` precision** — Twice the throughput on Apple GPUs
3. **Precompute in lookup textures** — Trade ALU for bandwidth
4. **Simplify lighting** — Fewer lights, simpler BRDF, baked lighting for static scenes

## Bandwidth Bottlenecks

### Large Render Targets

**Diagnosis:** Frame time stays high even with simple shaders.

**Solutions:**
1. **Use memoryless storage** for transient targets (depth, MSAA resolve)
2. **Reduce render target format** — `rgba8Unorm` (4 bytes) vs `rgba16Float` (8 bytes)
3. **Reduce render target count** — Minimize G-buffer attachments
4. **Render at lower resolution** — Upscale with MetalFX or custom upsampling

### Unoptimized Load/Store Actions

**Diagnosis:** GPU capture shows unexpected texture loads/stores.

```swift
// BAD: loading previous contents when clearing
descriptor.colorAttachments[0].loadAction = .load  // Reads entire texture from memory

// GOOD: clear (free on tile-based GPU)
descriptor.colorAttachments[0].loadAction = .clear

// BAD: storing a transient depth buffer
descriptor.depthAttachment.storeAction = .store  // Writes depth to memory needlessly

// GOOD: discard transient data
descriptor.depthAttachment.storeAction = .dontCare
```

## Compute Bottlenecks

### Low Occupancy

**Diagnosis:** GPU capture shows low "thread occupancy" in compute encoder.

**Causes and fixes:**
1. **Threadgroup too large** → Query `pipelineState.maxTotalThreadsPerThreadgroup` and use that
2. **Too many registers** → Simplify shader, use `half` precision, reduce local variables
3. **Too much threadgroup memory** → Reduce shared array sizes

### Threadgroup Memory Bank Conflicts

**Diagnosis:** Threadgroup memory accesses are slow despite small data sizes.

**Fix:** Pad shared arrays to avoid multiple threads hitting the same memory bank:

```metal
// Bank conflict: threads 0,8,16,... all access bank 0
threadgroup float shared[256];
float val = shared[lid * 8];  // Strided access = bank conflicts

// Fix: sequential access
float val = shared[lid];  // Each thread accesses a different bank
```

## Quick Wins Checklist

- [ ] All pipeline states created at initialization (not per-frame)
- [ ] Triple buffering with semaphore for dynamic uniforms
- [ ] `storageModePrivate` for all GPU-only resources
- [ ] `storageModeMemoryless` for transient render targets (Apple Silicon)
- [ ] `loadAction: .clear` instead of `.load` where possible
- [ ] `storeAction: .dontCare` for transient attachments
- [ ] Mipmaps enabled for all sampled textures
- [ ] Opaque objects sorted front-to-back
- [ ] No allocations inside the render loop
- [ ] Validation layer enabled during development (`MTL_DEBUG_LAYER=1`)
