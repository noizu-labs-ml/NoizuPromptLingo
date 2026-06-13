# Compute Basics

Setting up and dispatching Metal compute pipelines for GPU-parallel workloads.

## When to Use Compute

- Image processing (filters, convolutions, tone mapping)
- Particle simulation (physics update step)
- Data-parallel algorithms (sort, reduce, scan, histogram)
- Machine learning inference (custom layers)
- GPU-driven rendering (frustum culling, indirect draw generation)
- Post-processing effects (bloom, depth of field, SSAO)

## Compute Pipeline Setup

```swift
let library = device.makeDefaultLibrary()!
let function = library.makeFunction(name: "my_kernel")!
let pipelineState = try device.makeComputePipelineState(function: function)

// Query limits from the compiled pipeline
let maxThreads = pipelineState.maxTotalThreadsPerThreadgroup
let threadExecutionWidth = pipelineState.threadExecutionWidth
```

## Dispatch Patterns

### Pattern 1: dispatchThreads (Non-Uniform — Apple GPUs)

Preferred on Apple Silicon. The GPU handles boundary threads automatically.

```swift
let encoder = commandBuffer.makeComputeCommandEncoder()!
encoder.setComputePipelineState(pipelineState)
encoder.setBuffer(inputBuffer, offset: 0, index: 0)
encoder.setBuffer(outputBuffer, offset: 0, index: 1)

let gridSize = MTLSize(width: dataCount, height: 1, depth: 1)
let threadgroupSize = MTLSize(
    width: min(pipelineState.maxTotalThreadsPerThreadgroup, dataCount),
    height: 1,
    depth: 1
)

encoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadgroupSize)
encoder.endEncoding()
```

### Pattern 2: dispatchThreadgroups (Uniform — All GPUs)

Required for non-Apple GPUs. You must handle boundary checking in the shader.

```swift
let threadgroupSize = MTLSize(width: 256, height: 1, depth: 1)
let threadgroupCount = MTLSize(
    width: (dataCount + 255) / 256,
    height: 1,
    depth: 1
)

encoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
```

```metal
kernel void my_kernel(
    device float *input [[buffer(0)]],
    device float *output [[buffer(1)]],
    constant uint &count [[buffer(2)]],
    uint tid [[thread_position_in_grid]]
) {
    if (tid >= count) return;  // Boundary check required for uniform dispatch
    output[tid] = input[tid] * 2.0;
}
```

### Pattern 3: 2D Grid (Image Processing)

```swift
let gridSize = MTLSize(width: textureWidth, height: textureHeight, depth: 1)
let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)

encoder.setTexture(inputTexture, index: 0)
encoder.setTexture(outputTexture, index: 1)
encoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadgroupSize)
```

```metal
kernel void image_filter(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= input.get_width() || gid.y >= input.get_height()) return;

    float4 color = input.read(gid);
    // Process color...
    output.write(color, gid);
}
```

## Threadgroup Sizing Guidelines

| Workload Shape | Recommended Size | Rationale |
|---|---|---|
| 1D array | `(256, 1, 1)` | Fills SIMD lanes efficiently |
| 2D image | `(16, 16, 1)` | 256 threads, square for 2D locality |
| 2D image (wide) | `(32, 8, 1)` | Better for row-major access patterns |
| 3D volume | `(8, 8, 4)` | 256 threads in 3D |

Always check: `threadgroupSize.width * height * depth <= pipelineState.maxTotalThreadsPerThreadgroup`

## Shared Memory (Threadgroup Memory)

Use threadgroup memory for data reused across threads in the same group.

### Allocation

Two approaches:

**Static (in shader):**
```metal
kernel void my_kernel(...) {
    threadgroup float shared[256];
    // ...
}
```

**Dynamic (from Swift):**
```swift
encoder.setThreadgroupMemoryLength(256 * MemoryLayout<Float>.size, index: 0)
```

```metal
kernel void my_kernel(
    threadgroup float *shared [[threadgroup(0)]],
    // ...
) { }
```

### Synchronization

```metal
// Wait for all threads in group to reach this point AND for threadgroup memory to be visible
threadgroup_barrier(mem_flags::mem_threadgroup);

// Wait for device memory writes to be visible
threadgroup_barrier(mem_flags::mem_device);

// Wait for all memory
threadgroup_barrier(mem_flags::mem_threadgroup | mem_flags::mem_device);
```

## Buffer Management for Compute

### Input Buffer (CPU → GPU)

```swift
// For data that changes every frame: shared storage, triple-buffered
let buffer = device.makeBuffer(length: dataSize, options: .storageModeShared)!
let ptr = buffer.contents().bindMemory(to: MyStruct.self, capacity: count)
// Write data through ptr...

// For static data: private storage + blit upload
let staging = device.makeBuffer(bytes: data, length: dataSize, options: .storageModeShared)!
let gpuBuffer = device.makeBuffer(length: dataSize, options: .storageModePrivate)!

let blit = commandBuffer.makeBlitCommandEncoder()!
blit.copy(from: staging, sourceOffset: 0, to: gpuBuffer, destinationOffset: 0, size: dataSize)
blit.endEncoding()
```

### Output Buffer (GPU → CPU)

```swift
// Shared: GPU writes, CPU reads (Apple Silicon — efficient)
let outputBuffer = device.makeBuffer(length: resultSize, options: .storageModeShared)!

commandBuffer.addCompletedHandler { _ in
    let results = outputBuffer.contents().bindMemory(to: Float.self, capacity: count)
    // Read results...
}

// Managed (macOS with discrete GPU): need synchronize
let blit = commandBuffer.makeBlitCommandEncoder()!
blit.synchronize(resource: outputBuffer)
blit.endEncoding()
```

## Compute + Render Integration

A common pattern: compute pass prepares data, render pass draws it.

```swift
// Compute pass: update particle positions
let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
computeEncoder.setComputePipelineState(updatePipeline)
computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
computeEncoder.dispatchThreads(...)
computeEncoder.endEncoding()

// Render pass: draw particles as points
let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
renderEncoder.setRenderPipelineState(drawPipeline)
renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)  // Same buffer!
renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: particleCount)
renderEncoder.endEncoding()
```

Within a single command buffer, Metal guarantees that the compute pass completes before the render pass begins (sequential encoder ordering).
