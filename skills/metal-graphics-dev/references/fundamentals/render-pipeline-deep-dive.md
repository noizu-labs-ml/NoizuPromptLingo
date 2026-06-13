# Render Pipeline Deep Dive

Comprehensive guide to configuring Metal render pipeline state objects, vertex descriptors, blending, depth/stencil, and MSAA.

## Pipeline State Object

The `MTLRenderPipelineState` is the most performance-critical object to manage correctly. It represents a fully compiled, validated combination of:
- Vertex function
- Fragment function
- Vertex descriptor (attribute layout)
- Color attachment pixel formats and blending
- Depth/stencil attachment pixel format
- Rasterization settings (sample count, alpha-to-coverage)

### Creation Pattern

```swift
let descriptor = MTLRenderPipelineDescriptor()
descriptor.label = "Main Render Pipeline"

// Shader functions
let library = device.makeDefaultLibrary()!
descriptor.vertexFunction = library.makeFunction(name: "vertex_main")
descriptor.fragmentFunction = library.makeFunction(name: "fragment_main")

// Vertex layout
descriptor.vertexDescriptor = buildVertexDescriptor()

// Color attachments
descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

// Depth
descriptor.depthAttachmentPixelFormat = .depth32Float

// MSAA
descriptor.sampleCount = 4

// Compile — this is EXPENSIVE, do it once
let pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
```

**Rule: Never create pipeline states per-frame.** Compile all pipelines during initialization or loading screens. Use a pipeline cache (dictionary keyed by material/shader combo) if you have many variants.

## Vertex Descriptors

Vertex descriptors define how vertex data is laid out in memory. Two main approaches:

### Approach 1: Interleaved (one buffer, attributes packed per-vertex)

```swift
let descriptor = MTLVertexDescriptor()

// Position: float3 at offset 0
descriptor.attributes[0].format = .float3
descriptor.attributes[0].offset = 0
descriptor.attributes[0].bufferIndex = 0

// Normal: float3 at offset 12
descriptor.attributes[1].format = .float3
descriptor.attributes[1].offset = 12
descriptor.attributes[1].bufferIndex = 0

// TexCoord: float2 at offset 24
descriptor.attributes[2].format = .float2
descriptor.attributes[2].offset = 24
descriptor.attributes[2].bufferIndex = 0

// Layout: stride of 32 bytes per vertex
descriptor.layouts[0].stride = 32
descriptor.layouts[0].stepFunction = .perVertex
```

**Pros:** Better cache locality when all attributes are read together.

### Approach 2: Separate Buffers (one buffer per attribute)

```swift
// Position buffer at index 0
descriptor.attributes[0].format = .float3
descriptor.attributes[0].offset = 0
descriptor.attributes[0].bufferIndex = 0
descriptor.layouts[0].stride = 12

// Normal buffer at index 1
descriptor.attributes[1].format = .float3
descriptor.attributes[1].offset = 0
descriptor.attributes[1].bufferIndex = 1
descriptor.layouts[1].stride = 12

// TexCoord buffer at index 2
descriptor.attributes[2].format = .float2
descriptor.attributes[2].offset = 0
descriptor.attributes[2].bufferIndex = 2
descriptor.layouts[2].stride = 8
```

**Pros:** Better when shaders don't need all attributes (shadow pass reads positions only).

### Instanced Rendering

```swift
descriptor.layouts[1].stepFunction = .perInstance
descriptor.layouts[1].stepRate = 1
// Buffer at index 1 advances once per instance instead of per vertex

// Draw call:
encoder.drawIndexedPrimitives(
    type: .triangle,
    indexCount: mesh.indexCount,
    indexType: .uint32,
    indexBuffer: mesh.indexBuffer,
    indexBufferOffset: 0,
    instanceCount: instanceCount
)
```

## Blending

Configure blending per color attachment:

### Common Blend Modes

```swift
let attachment = descriptor.colorAttachments[0]!
attachment.pixelFormat = .bgra8Unorm

// Alpha blending (standard transparency)
attachment.isBlendingEnabled = true
attachment.rgbBlendOperation = .add
attachment.alphaBlendOperation = .add
attachment.sourceRGBBlendFactor = .sourceAlpha
attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
attachment.sourceAlphaBlendFactor = .one
attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha

// Additive blending (particles, glows)
attachment.sourceRGBBlendFactor = .one
attachment.destinationRGBBlendFactor = .one

// Premultiplied alpha
attachment.sourceRGBBlendFactor = .one
attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
```

### Write Masks

```swift
// Write only RGB, not alpha
attachment.writeMask = [.red, .green, .blue]
```

## Depth and Stencil

### Depth State

```swift
let depthDescriptor = MTLDepthStencilDescriptor()
depthDescriptor.depthCompareFunction = .less  // Closer fragments win
depthDescriptor.isDepthWriteEnabled = true     // Write to depth buffer

let depthState = device.makeDepthStencilState(descriptor: depthDescriptor)!

// In render loop:
encoder.setDepthStencilState(depthState)
```

### Stencil Operations

```swift
let stencilDescriptor = MTLStencilDescriptor()
stencilDescriptor.stencilCompareFunction = .equal
stencilDescriptor.stencilFailureOperation = .keep
stencilDescriptor.depthFailureOperation = .keep
stencilDescriptor.depthStencilPassOperation = .incrementClamp

depthDescriptor.frontFaceStencil = stencilDescriptor
depthDescriptor.backFaceStencil = stencilDescriptor
```

### Depth Texture Creation

```swift
let depthDescriptor = MTLTextureDescriptor.texture2DDescriptor(
    pixelFormat: .depth32Float,
    width: Int(viewSize.width),
    height: Int(viewSize.height),
    mipmapped: false
)
depthDescriptor.storageMode = .private     // GPU-only
depthDescriptor.usage = .renderTarget

let depthTexture = device.makeTexture(descriptor: depthDescriptor)!
```

## MSAA (Multisample Anti-Aliasing)

### Setup

```swift
// Pipeline: set sample count
pipelineDescriptor.sampleCount = 4

// Create MSAA texture (render target)
let msaaDescriptor = MTLTextureDescriptor.texture2DDescriptor(
    pixelFormat: .bgra8Unorm,
    width: width,
    height: height,
    mipmapped: false
)
msaaDescriptor.textureType = .type2DMultisample
msaaDescriptor.sampleCount = 4
msaaDescriptor.storageMode = .private
msaaDescriptor.usage = .renderTarget
let msaaTexture = device.makeTexture(descriptor: msaaDescriptor)!

// Render pass: resolve MSAA to drawable
let renderPassDescriptor = MTLRenderPassDescriptor()
renderPassDescriptor.colorAttachments[0].texture = msaaTexture
renderPassDescriptor.colorAttachments[0].resolveTexture = drawable.texture
renderPassDescriptor.colorAttachments[0].loadAction = .clear
renderPassDescriptor.colorAttachments[0].storeAction = .multisampleResolve
```

### Performance Note

On Apple Silicon (tile-based GPUs), MSAA is essentially free — the resolve happens in tile memory. On discrete AMD GPUs, MSAA has real bandwidth cost proportional to sample count.

## Multiple Render Targets (MRT)

For deferred rendering / G-buffer:

```swift
// Pipeline
descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm    // Albedo
descriptor.colorAttachments[1].pixelFormat = .rgba16Float    // Normal
descriptor.colorAttachments[2].pixelFormat = .r16Float       // Depth linear

// Shader output
struct FragmentOut {
    float4 albedo   [[color(0)]];
    float4 normal   [[color(1)]];
    float  depth    [[color(2)]];
};
```

## Pipeline Variants Strategy

For a realistic renderer, you may have dozens of pipeline variants (shadow, opaque, transparent, wireframe, post-process). Manage them with a cache:

```swift
struct PipelineKey: Hashable {
    let vertexFunction: String
    let fragmentFunction: String
    let pixelFormat: MTLPixelFormat
    let sampleCount: Int
    let blendingEnabled: Bool
}

class PipelineCache {
    private var cache: [PipelineKey: MTLRenderPipelineState] = [:]
    private let device: MTLDevice
    private let library: MTLLibrary

    func pipeline(for key: PipelineKey) throws -> MTLRenderPipelineState {
        if let cached = cache[key] { return cached }
        let state = try buildPipeline(for: key)
        cache[key] = state
        return state
    }
}
```
