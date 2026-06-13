# Resource Management

Heaps, argument buffers, bindless rendering, and resource residency patterns.

## Metal Heaps

Heaps are pre-allocated GPU memory pools. Benefits:
- Faster allocation (no system call per resource)
- Aliasing: multiple resources can share the same memory if they don't overlap in time
- Better memory tracking and budgeting

### Creating a Heap

```swift
// Calculate required size
let textureDesc = MTLTextureDescriptor.texture2DDescriptor(
    pixelFormat: .rgba8Unorm,
    width: 1024, height: 1024, mipmapped: true
)
let textureSize = device.heapTextureSizeAndAlign(descriptor: textureDesc)

let bufferSize = device.heapBufferSizeAndAlign(length: 1024 * 1024, options: .storageModePrivate)

// Create heap
let heapDesc = MTLHeapDescriptor()
heapDesc.size = textureSize.size + bufferSize.size + 4096  // alignment padding
heapDesc.storageMode = .private
heapDesc.cpuCacheMode = .defaultCache

let heap = device.makeHeap(descriptor: heapDesc)!
```

### Allocating from Heap

```swift
let texture = heap.makeTexture(descriptor: textureDesc)!
let buffer = heap.makeBuffer(length: bufferSize.size, options: .storageModePrivate)!
```

### Aliasing (Temporal Reuse)

```swift
// Shadow map and bloom buffer never used simultaneously
let shadowMap = heap.makeTexture(descriptor: shadowDesc)!

// Later, after shadow pass is complete:
shadowMap.makeAliasable()  // Allow heap to reuse this memory

let bloomBuffer = heap.makeTexture(descriptor: bloomDesc)!  // May overlap shadow memory
```

## Argument Buffers

Argument buffers pack multiple resources into a single buffer, reducing CPU overhead for resource binding.

### Declaration (MSL)

```metal
struct MaterialResources {
    texture2d<float> albedo;
    texture2d<float> normal;
    texture2d<float> roughness;
    sampler textureSampler;
    float4 baseColor;
    float metallic;
};

fragment float4 fragment_main(
    VertexOut in [[stage_in]],
    constant MaterialResources &material [[buffer(0)]]
) {
    float4 albedo = material.albedo.sample(material.textureSampler, in.texCoord);
    float4 normalMap = material.normal.sample(material.textureSampler, in.texCoord);
    // ...
}
```

### Encoding (Swift)

```swift
let encoder = fragmentFunction.makeArgumentEncoder(bufferIndex: 0)
let argumentBuffer = device.makeBuffer(length: encoder.encodedLength, options: .storageModeShared)!

encoder.setArgumentBuffer(argumentBuffer, offset: 0)
encoder.setTexture(albedoTexture, index: 0)
encoder.setTexture(normalTexture, index: 1)
encoder.setTexture(roughnessTexture, index: 2)
encoder.setSamplerState(sampler, index: 3)

// Set scalar values via buffer
let ptr = argumentBuffer.contents().advanced(by: encoder.offset(for: 4))
ptr.storeBytes(of: SIMD4<Float>(1, 0, 0, 1), as: SIMD4<Float>.self)

// Bind
renderEncoder.setFragmentBuffer(argumentBuffer, offset: 0, index: 0)

// Make resources resident (required for argument buffer textures)
renderEncoder.useResource(albedoTexture, usage: .read, stages: .fragment)
renderEncoder.useResource(normalTexture, usage: .read, stages: .fragment)
renderEncoder.useResource(roughnessTexture, usage: .read, stages: .fragment)
```

## Bindless Rendering

Bind all textures once, index into them per-draw. Eliminates per-draw texture binding overhead.

### Material Table Pattern

```metal
struct Material {
    uint albedoIndex;
    uint normalIndex;
    uint roughnessIndex;
    float metallic;
};

fragment float4 fragment_main(
    VertexOut in [[stage_in]],
    constant Material &material [[buffer(0)]],
    array<texture2d<float>, 128> textures [[texture(0)]],
    sampler s [[sampler(0)]]
) {
    float4 albedo = textures[material.albedoIndex].sample(s, in.texCoord);
    float4 normal = textures[material.normalIndex].sample(s, in.texCoord);
    // ...
}
```

### Swift Side

```swift
// Bind all textures in the array
for (index, texture) in allTextures.enumerated() {
    renderEncoder.setFragmentTexture(texture, index: index)
}

// Per-draw: only bind the material buffer
renderEncoder.setFragmentBytes(&material, length: MemoryLayout<Material>.size, index: 0)
renderEncoder.drawIndexedPrimitives(...)
```

## Resource Residency

When using argument buffers or heaps, you must explicitly declare which resources the GPU will access:

```swift
// Individual resources
renderEncoder.useResource(texture, usage: .read, stages: .fragment)
renderEncoder.useResource(buffer, usage: .read, stages: .vertex)

// All resources in a heap
renderEncoder.useHeap(heap, stages: [.vertex, .fragment])

// Usage flags
// .read — texture sampling, buffer reading
// .write — render targets, storage textures, buffer writes
// .sample — same as .read for textures
```

Forgetting `useResource` when using argument buffers is a common source of GPU hangs or black textures.

## Memory Budget Management

```swift
// Query available memory
let recommendedMaxMemory = device.recommendedMaxWorkingSetSize  // macOS only
let currentAllocatedSize = device.currentAllocatedSize

// Budget strategy
func canAllocate(bytes: Int) -> Bool {
    #if os(macOS)
    return device.currentAllocatedSize + bytes < device.recommendedMaxWorkingSetSize
    #else
    // iOS: use os_proc_available_memory() as a general guide
    return true
    #endif
}
```

## Texture Streaming Pattern

For large scenes, stream textures in/out of GPU memory:

```swift
class TextureStreamer {
    let heap: MTLHeap
    var loadedTextures: [String: MTLTexture] = [:]
    var lruOrder: [String] = []

    func requestTexture(_ name: String) -> MTLTexture? {
        if let tex = loadedTextures[name] {
            // Move to front of LRU
            lruOrder.removeAll { $0 == name }
            lruOrder.insert(name, at: 0)
            return tex
        }

        // Evict LRU if over budget
        while heap.usedSize > budgetLimit, let evict = lruOrder.popLast() {
            loadedTextures[evict]?.makeAliasable()
            loadedTextures.removeValue(forKey: evict)
        }

        // Load from disk via blit
        return loadAndUploadTexture(name)
    }
}
```
