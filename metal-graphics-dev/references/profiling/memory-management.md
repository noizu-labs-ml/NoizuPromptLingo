# Memory Management

Storage modes, synchronization, allocation strategies, and memory budgeting for Metal.

## Storage Mode Decision Tree

```
Is the data read by CPU after GPU writes?
├── YES → Is it on Apple Silicon?
│   ├── YES → storageModeShared (unified memory, no copy)
│   └── NO → storageModeManaged + synchronize blit
│
└── NO → Does CPU write to it?
    ├── YES → How often?
    │   ├── Every frame (uniforms) → storageModeShared + triple buffer
    │   ├── Occasionally → storageModeManaged (macOS) or shared (iOS)
    │   └── Once (upload) → storageModePrivate + blit from staging
    │
    └── NO (GPU only) → storageModePrivate
        └── Is it a transient render target?
            ├── YES (Apple Silicon) → storageModeMemoryless
            └── NO → storageModePrivate
```

## Storage Mode Details

### Shared

```swift
let buffer = device.makeBuffer(length: size, options: .storageModeShared)!
let ptr = buffer.contents().bindMemory(to: Float.self, capacity: count)
ptr[0] = 1.0  // CPU writes directly visible to GPU (after command buffer boundaries)
```

- **Apple Silicon:** Zero-copy — CPU and GPU see the same physical memory
- **Intel/AMD Mac:** System memory, GPU accesses via PCIe — slower for GPU-heavy reads
- **Best for:** Dynamic uniforms on Apple Silicon, CPU-GPU shared data

### Managed (macOS only)

```swift
let buffer = device.makeBuffer(length: size, options: .storageModeManaged)!

// CPU writes
let ptr = buffer.contents().bindMemory(to: Float.self, capacity: count)
ptr[0] = 1.0
buffer.didModifyRange(0..<size)  // Tell Metal the CPU changed this range

// GPU writes → CPU reads
let blit = commandBuffer.makeBlitCommandEncoder()!
blit.synchronize(resource: buffer)  // Copy GPU version to CPU-visible copy
blit.endEncoding()
```

- **Dual-copy:** CPU has one copy, GPU has another (on discrete GPU)
- **Best for:** Dynamic data on Intel/AMD Macs

### Private

```swift
let buffer = device.makeBuffer(length: size, options: .storageModePrivate)!
// Cannot access from CPU — upload via blit from staging buffer

let staging = device.makeBuffer(bytes: data, length: size, options: .storageModeShared)!
let blit = commandBuffer.makeBlitCommandEncoder()!
blit.copy(from: staging, sourceOffset: 0, to: buffer, destinationOffset: 0, size: size)
blit.endEncoding()
```

- **GPU-only memory** — fastest GPU access
- **Best for:** Static meshes, textures, lookup tables, GPU-only compute buffers

### Memoryless (Apple Silicon)

```swift
let descriptor = MTLTextureDescriptor.texture2DDescriptor(
    pixelFormat: .depth32Float, width: w, height: h, mipmapped: false
)
descriptor.storageMode = .memoryless
descriptor.usage = .renderTarget
let depthTexture = device.makeTexture(descriptor: descriptor)!
```

- **Tile memory only** — never written to main memory
- **Best for:** Depth buffers, MSAA resolve targets, transient intermediates
- **Requirement:** Load action must be `.clear` or `.dontCare`; store action must be `.dontCare` or `.multisampleResolve`

## Triple Buffering Implementation

```swift
class TripleBuffer<T> {
    private let buffers: [MTLBuffer]
    private var index = 0
    let count = 3

    init(device: MTLDevice) {
        buffers = (0..<3).map { _ in
            device.makeBuffer(length: MemoryLayout<T>.size, options: .storageModeShared)!
        }
    }

    func next() -> (buffer: MTLBuffer, pointer: UnsafeMutablePointer<T>) {
        index = (index + 1) % count
        let ptr = buffers[index].contents().bindMemory(to: T.self, capacity: 1)
        return (buffers[index], ptr)
    }
}

// Usage:
let uniformsRing = TripleBuffer<Uniforms>(device: device)

func draw(in view: MTKView) {
    semaphore.wait()
    let (buffer, ptr) = uniformsRing.next()
    ptr.pointee = currentUniforms  // Safe: GPU is done with this buffer (semaphore)

    let commandBuffer = commandQueue.makeCommandBuffer()!
    commandBuffer.addCompletedHandler { [weak self] _ in
        self?.semaphore.signal()
    }

    encoder.setVertexBuffer(buffer, offset: 0, index: 0)
    // ...
}
```

## Texture Memory

### Compressed Textures

| Format | Bits/Pixel | Platform | Quality |
|---|---|---|---|
| ASTC 4x4 | 8 | Apple Silicon (iOS, Apple Silicon Mac) | High |
| ASTC 6x6 | 3.56 | Apple Silicon | Medium |
| BC7 | 8 | macOS (all GPUs) | High |
| BC1 | 4 | macOS (all GPUs) | Low (no alpha) |

Use `MTKTextureLoader` or Asset Catalogs for automatic format selection per platform.

### Mipmap Generation

```swift
// Generate mipmaps on GPU
let blit = commandBuffer.makeBlitCommandEncoder()!
blit.generateMipmaps(for: texture)
blit.endEncoding()
```

Always use mipmaps for textures sampled at varying distances — reduces aliasing and saves bandwidth.

### Texture Usage Flags

```swift
let desc = MTLTextureDescriptor()
desc.usage = [.shaderRead]                    // Sample in shaders (most textures)
desc.usage = [.renderTarget, .shaderRead]     // Render to, then sample (post-process)
desc.usage = [.shaderRead, .shaderWrite]      // Compute read/write (image processing)
```

Don't set flags you don't need — extra flags can disable optimizations.

## Memory Debugging

### Xcode Memory Graph

Product → Profile → Allocations instrument to track Metal allocations.

### API Queries

```swift
print("Total allocated: \(device.currentAllocatedSize) bytes")

#if os(macOS)
print("Recommended max: \(device.recommendedMaxWorkingSetSize) bytes")
#endif

// Per-heap
print("Heap used: \(heap.usedSize) / \(heap.currentAllocatedSize)")
```

### Allocation Tracking Pattern

```swift
class MetalAllocTracker {
    var totalBytes: Int = 0

    func makeBuffer(device: MTLDevice, length: Int, options: MTLResourceOptions) -> MTLBuffer? {
        let buffer = device.makeBuffer(length: length, options: options)
        if buffer != nil { totalBytes += length }
        return buffer
    }

    func makeTexture(device: MTLDevice, descriptor: MTLTextureDescriptor) -> MTLTexture? {
        let texture = device.makeTexture(descriptor: descriptor)
        if let t = texture {
            let size = t.allocatedSize
            totalBytes += size
        }
        return texture
    }
}
```
