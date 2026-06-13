# Compute Patterns

Reusable GPU compute patterns: reduction, scan, sort, image processing, and particle simulation.

## Pattern 1: Parallel Reduction (Sum, Min, Max)

Two-phase approach: threadgroup-level reduction, then final reduction across groups.

### Phase 1: Per-Threadgroup Reduction

```metal
kernel void reduce_sum_phase1(
    device float *input [[buffer(0)]],
    device float *partialSums [[buffer(1)]],
    constant uint &count [[buffer(2)]],
    threadgroup float *shared [[threadgroup(0)]],
    uint tid [[thread_position_in_grid]],
    uint lid [[thread_position_in_threadgroup]],
    uint gid [[threadgroup_position_in_grid]],
    uint groupSize [[threads_per_threadgroup]]
) {
    shared[lid] = (tid < count) ? input[tid] : 0.0;
    threadgroup_barrier(mem_flags::mem_threadgroup);

    for (uint stride = groupSize / 2; stride > 0; stride >>= 1) {
        if (lid < stride) {
            shared[lid] += shared[lid + stride];
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
    }

    if (lid == 0) {
        partialSums[gid] = shared[0];
    }
}
```

### Phase 2: Final Reduction

Dispatch a single threadgroup over `partialSums` from phase 1.

### Swift Dispatch

```swift
let groupSize = 256
let groupCount = (dataCount + groupSize - 1) / groupSize

// Phase 1: N elements → groupCount partial sums
let partialBuffer = device.makeBuffer(length: groupCount * MemoryLayout<Float>.size, options: .storageModePrivate)!

encoder.setComputePipelineState(reducePhase1Pipeline)
encoder.setBuffer(inputBuffer, offset: 0, index: 0)
encoder.setBuffer(partialBuffer, offset: 0, index: 1)
encoder.setBytes(&dataCount, length: 4, index: 2)
encoder.setThreadgroupMemoryLength(groupSize * MemoryLayout<Float>.size, index: 0)
encoder.dispatchThreadgroups(
    MTLSize(width: groupCount, height: 1, depth: 1),
    threadsPerThreadgroup: MTLSize(width: groupSize, height: 1, depth: 1)
)

// Phase 2: groupCount partial sums → 1 result
encoder.setComputePipelineState(reducePhase2Pipeline)
encoder.setBuffer(partialBuffer, offset: 0, index: 0)
encoder.setBuffer(resultBuffer, offset: 0, index: 1)
// ... dispatch single group
```

## Pattern 2: Prefix Sum (Scan)

Builds cumulative sums — foundational for stream compaction, radix sort, and histogram equalization.

### Hillis-Steele (Inclusive Scan, Simple)

```metal
kernel void inclusive_scan(
    device float *data [[buffer(0)]],
    constant uint &count [[buffer(1)]],
    threadgroup float *shared [[threadgroup(0)]],
    uint tid [[thread_position_in_grid]],
    uint lid [[thread_position_in_threadgroup]],
    uint groupSize [[threads_per_threadgroup]]
) {
    shared[lid] = (tid < count) ? data[tid] : 0.0;
    threadgroup_barrier(mem_flags::mem_threadgroup);

    for (uint offset = 1; offset < groupSize; offset <<= 1) {
        float val = (lid >= offset) ? shared[lid - offset] : 0.0;
        threadgroup_barrier(mem_flags::mem_threadgroup);
        shared[lid] += val;
        threadgroup_barrier(mem_flags::mem_threadgroup);
    }

    if (tid < count) {
        data[tid] = shared[lid];
    }
}
```

## Pattern 3: Image Convolution (Stencil)

2D convolution with shared memory tiling for cache efficiency.

```metal
constant int KERNEL_SIZE = 3;
constant int HALF_KERNEL = KERNEL_SIZE / 2;
constant int TILE_SIZE = 16;  // Must match threadgroup size
constant int PADDED_SIZE = TILE_SIZE + KERNEL_SIZE - 1;

kernel void convolve_3x3(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    constant float *kernel [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]],
    uint2 lid [[thread_position_in_threadgroup]],
    uint2 groupId [[threadgroup_position_in_grid]]
) {
    threadgroup float4 tile[PADDED_SIZE][PADDED_SIZE];

    // Load tile with halo (border pixels for convolution)
    int2 baseCoord = int2(groupId) * TILE_SIZE - HALF_KERNEL;

    for (int dy = lid.y; dy < PADDED_SIZE; dy += TILE_SIZE) {
        for (int dx = lid.x; dx < PADDED_SIZE; dx += TILE_SIZE) {
            int2 coord = baseCoord + int2(dx, dy);
            coord = clamp(coord, int2(0), int2(input.get_width()-1, input.get_height()-1));
            tile[dy][dx] = input.read(uint2(coord));
        }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);

    if (gid.x >= input.get_width() || gid.y >= input.get_height()) return;

    // Convolve from shared memory
    float4 sum = float4(0);
    for (int ky = 0; ky < KERNEL_SIZE; ky++) {
        for (int kx = 0; kx < KERNEL_SIZE; kx++) {
            sum += tile[lid.y + ky][lid.x + kx] * kernel[ky * KERNEL_SIZE + kx];
        }
    }

    output.write(sum, gid);
}
```

## Pattern 4: Particle Update

GPU-driven particle physics with compute, rendered with instanced draw.

```metal
struct Particle {
    float2 position;
    float2 velocity;
    float life;
    float size;
};

kernel void update_particles(
    device Particle *particles [[buffer(0)]],
    constant float &deltaTime [[buffer(1)]],
    constant uint &count [[buffer(2)]],
    uint tid [[thread_position_in_grid]]
) {
    if (tid >= count) return;

    Particle p = particles[tid];

    // Physics
    p.velocity.y -= 9.8 * deltaTime;  // Gravity
    p.position += p.velocity * deltaTime;
    p.life -= deltaTime;

    // Respawn dead particles
    if (p.life <= 0.0) {
        p.position = float2(0.0);
        p.velocity = float2(
            (fract(sin(float(tid) * 12.9898) * 43758.5453) - 0.5) * 4.0,
            3.0 + fract(sin(float(tid) * 78.233) * 43758.5453) * 2.0
        );
        p.life = 1.0 + fract(sin(float(tid) * 45.164) * 43758.5453);
    }

    particles[tid] = p;
}
```

## Pattern 5: GPU-Driven Rendering (Indirect Commands)

Use compute to generate draw commands, avoiding CPU round-trips.

```metal
struct MTLDrawIndexedPrimitivesIndirectArguments {
    uint indexCount;
    uint instanceCount;
    uint indexStart;
    int  baseVertex;
    uint baseInstance;
};

kernel void cull_and_generate_draws(
    device MTLDrawIndexedPrimitivesIndirectArguments *draws [[buffer(0)]],
    device atomic_uint *drawCount [[buffer(1)]],
    constant float4 *frustumPlanes [[buffer(2)]],
    device BoundingSphere *objects [[buffer(3)]],
    constant uint &objectCount [[buffer(4)]],
    uint tid [[thread_position_in_grid]]
) {
    if (tid >= objectCount) return;

    BoundingSphere sphere = objects[tid];

    // Frustum culling
    bool visible = true;
    for (int i = 0; i < 6; i++) {
        float dist = dot(frustumPlanes[i].xyz, sphere.center) + frustumPlanes[i].w;
        if (dist < -sphere.radius) {
            visible = false;
            break;
        }
    }

    if (visible) {
        uint drawIndex = atomic_fetch_add_explicit(drawCount, 1, memory_order_relaxed);
        draws[drawIndex] = /* ... build indirect draw args ... */;
    }
}
```

Swift side uses `drawIndexedPrimitives(type:indexType:indexBuffer:indexBufferOffset:indirectBuffer:indirectBufferOffset:)` to consume the generated commands.

## Pattern 6: Histogram

```metal
kernel void histogram_256(
    texture2d<float, access::read> input [[texture(0)]],
    device atomic_uint *histogram [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= input.get_width() || gid.y >= input.get_height()) return;

    float4 color = input.read(gid);
    uint luminance = uint(clamp(dot(color.rgb, float3(0.299, 0.587, 0.114)) * 255.0, 0.0, 255.0));
    atomic_fetch_add_explicit(&histogram[luminance], 1, memory_order_relaxed);
}
```
