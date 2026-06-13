# Metal Architecture

Core concepts, object relationships, and GPU families for Apple's Metal API.

## The Metal Object Graph

Metal is organized around a small set of long-lived objects and a large set of per-frame transient objects. Understanding which are which is critical for performance.

### Long-Lived Objects (create once, reuse)

| Object | Purpose | Lifetime |
|---|---|---|
| `MTLDevice` | GPU interface — creates all other objects | App lifetime |
| `MTLCommandQueue` | Serializes command buffer submission | App lifetime |
| `MTLRenderPipelineState` | Compiled vertex + fragment shader pair | App lifetime (cache these) |
| `MTLComputePipelineState` | Compiled compute kernel | App lifetime |
| `MTLDepthStencilState` | Depth/stencil test configuration | App lifetime |
| `MTLSamplerState` | Texture sampling configuration | App lifetime |
| `MTLLibrary` | Container of compiled shader functions | App lifetime |
| `MTLHeap` | Pre-allocated GPU memory pool | App lifetime |

### Per-Frame Objects (create, encode, commit, discard)

| Object | Purpose | Lifetime |
|---|---|---|
| `MTLCommandBuffer` | Container for GPU commands | One frame |
| `MTLRenderCommandEncoder` | Encodes draw calls into a render pass | One render pass |
| `MTLComputeCommandEncoder` | Encodes dispatch calls | One compute pass |
| `MTLBlitCommandEncoder` | Encodes copy/fill operations | One blit pass |

### Resources (varying lifetimes)

| Object | Purpose | Typical Lifetime |
|---|---|---|
| `MTLBuffer` | GPU-accessible data (vertices, uniforms, etc.) | Varies — static: app lifetime, dynamic: per-frame ring buffer |
| `MTLTexture` | 2D/3D image data, render targets | Varies — loaded textures: app lifetime, render targets: app lifetime |
| `MTLFence` / `MTLEvent` | GPU-GPU synchronization | App lifetime |

## Device Selection

```swift
// Preferred: system default device (best for most apps)
guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("Metal not supported on this device")
}

// Multi-GPU: enumerate all devices (macOS only)
let devices = MTLCopyAllDevices()
// Filter by: device.isLowPower, device.isRemovable, device.supportsFamily()
```

### GPU Families

GPU families define feature availability. Always check rather than assume.

| Family | Devices | Key Features |
|---|---|---|
| Apple 7 (`.apple7`) | M1, A14+ | Lossless MSAA, sparse textures |
| Apple 8 (`.apple8`) | M2, A15+ | Mesh shaders, ray tracing improvements |
| Apple 9 (`.apple9`) | M3, A17+ | Hardware ray tracing, mesh shaders (full) |
| Mac 2 (`.mac2`) | All Apple Silicon Macs | Baseline for macOS Metal apps |
| Common 3 (`.common3`) | Broad cross-platform | Safe baseline for iOS + macOS |

```swift
if device.supportsFamily(.apple9) {
    // Use hardware ray tracing
} else if device.supportsFamily(.apple7) {
    // Fallback to compute-based ray tracing
}
```

## Command Submission Model

```
MTLCommandQueue
  │
  ├── MTLCommandBuffer #1  ──→  GPU executes
  ├── MTLCommandBuffer #2  ──→  GPU executes (in order within queue)
  └── MTLCommandBuffer #3  ──→  GPU executes
```

Key rules:
- Command buffers execute **in submission order** within a single queue
- Multiple queues have **no ordering guarantee** (use events/fences)
- A command buffer can contain **multiple encoders** (render, compute, blit) — but only one active at a time
- Call `endEncoding()` before creating the next encoder
- Call `commit()` to submit to the GPU — the command buffer is then immutable
- Use `addCompletedHandler` for CPU notification when GPU finishes

## Triple Buffering

The standard pattern for smooth frame delivery:

```
Frame N:     [CPU writes buffer 0] [GPU reads buffer 0]
Frame N+1:   [CPU writes buffer 1]         [GPU reads buffer 1]
Frame N+2:   [CPU writes buffer 2]                 [GPU reads buffer 2]
Frame N+3:   [CPU writes buffer 0] ...
```

Implementation:
```swift
let maxFramesInFlight = 3
let semaphore = DispatchSemaphore(value: maxFramesInFlight)
var currentBufferIndex = 0

func draw(in view: MTKView) {
    semaphore.wait()
    currentBufferIndex = (currentBufferIndex + 1) % maxFramesInFlight

    let commandBuffer = commandQueue.makeCommandBuffer()!
    commandBuffer.addCompletedHandler { [weak self] _ in
        self?.semaphore.signal()
    }

    // Use uniformBuffers[currentBufferIndex] for this frame's data
    updateUniforms(bufferIndex: currentBufferIndex)

    // Encode and commit...
}
```

## Render Pass Architecture

A render pass describes what to render to and how to initialize/store the targets:

```swift
let descriptor = MTLRenderPassDescriptor()

// Color attachment
descriptor.colorAttachments[0].texture = drawable.texture
descriptor.colorAttachments[0].loadAction = .clear        // or .load, .dontCare
descriptor.colorAttachments[0].storeAction = .store        // or .dontCare
descriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)

// Depth attachment
descriptor.depthAttachment.texture = depthTexture
descriptor.depthAttachment.loadAction = .clear
descriptor.depthAttachment.storeAction = .dontCare         // dontCare if not needed after pass
descriptor.depthAttachment.clearDepth = 1.0
```

Load/store actions matter for performance:
- `dontCare` for transient attachments saves memory bandwidth
- `clear` is free on tile-based GPUs (Apple Silicon) — prefer it over manual clear
- `store` must be used for anything read in subsequent passes or presented to screen

## Error Handling

Metal is a low-level API — many errors are silent or result in GPU hangs. Use these during development:

```swift
// Enable validation layer (catches API misuse)
// Set in scheme: Environment Variable MTL_DEBUG_LAYER = 1

// Enable shader validation (catches shader bugs, slower)
// Set in scheme: Environment Variable MTL_SHADER_VALIDATION = 1

// Programmatic GPU error checking
let descriptor = MTLCommandBufferDescriptor()
descriptor.errorOptions = .encoderExecutionStatus
let commandBuffer = commandQueue.makeCommandBuffer(descriptor: descriptor)!

commandBuffer.addCompletedHandler { buffer in
    if buffer.status == .error {
        print("GPU error: \(buffer.error!)")
        // Check individual encoder statuses for detailed info
    }
}
```
