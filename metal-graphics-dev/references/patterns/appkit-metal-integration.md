# AppKit + Metal Integration

Manual Metal rendering with CAMetalLayer and CVDisplayLink for maximum control.

## When to Use This Over MTKView

- Custom frame pacing (variable refresh rate, frame skipping)
- Multi-window rendering with independent frame rates
- Embedding Metal in complex NSView hierarchies
- Custom input handling that conflicts with MTKView
- Need direct control over drawable acquisition timing

## Core Setup

### NSView with CAMetalLayer

```swift
import Cocoa
import Metal
import QuartzCore

class MetalLayerView: NSView {
    var metalLayer: CAMetalLayer!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var displayLink: CVDisplayLink?

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true

        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!

        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0

        layer = metalLayer

        setupDisplayLink()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        metalLayer.contentsScale = window?.backingScaleFactor ?? 2.0
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        let scale = window?.backingScaleFactor ?? 2.0
        metalLayer.drawableSize = CGSize(
            width: newSize.width * scale,
            height: newSize.height * scale
        )
    }
}
```

### CVDisplayLink

```swift
extension MetalLayerView {
    func setupDisplayLink() {
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)

        let callback: CVDisplayLinkOutputCallback = { _, _, _, _, _, userInfo -> CVReturn in
            let view = Unmanaged<MetalLayerView>.fromOpaque(userInfo!).takeUnretainedValue()
            view.render()
            return kCVReturnSuccess
        }

        CVDisplayLinkSetOutputCallback(displayLink!, callback,
            Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkStart(displayLink!)
    }

    func stopDisplayLink() {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
    }

    deinit {
        stopDisplayLink()
    }
}
```

### Render Loop

```swift
extension MetalLayerView {
    func render() {
        guard let drawable = metalLayer.nextDrawable() else { return }

        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = drawable.texture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].clearColor =
            MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)!

        // Draw calls here...

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
```

## Triple Buffering with CAMetalLayer

```swift
class MetalRenderer {
    let maxFramesInFlight = 3
    let frameSemaphore: DispatchSemaphore
    var currentBufferIndex = 0

    var uniformBuffers: [MTLBuffer] = []

    init(device: MTLDevice) {
        frameSemaphore = DispatchSemaphore(value: maxFramesInFlight)

        for _ in 0..<maxFramesInFlight {
            let buffer = device.makeBuffer(
                length: MemoryLayout<Uniforms>.size,
                options: .storageModeShared
            )!
            uniformBuffers.append(buffer)
        }
    }

    func render(layer: CAMetalLayer) {
        frameSemaphore.wait()
        currentBufferIndex = (currentBufferIndex + 1) % maxFramesInFlight

        guard let drawable = layer.nextDrawable() else {
            frameSemaphore.signal()
            return
        }

        // Update uniforms for this frame
        let uniforms = uniformBuffers[currentBufferIndex]
            .contents()
            .bindMemory(to: Uniforms.self, capacity: 1)
        uniforms.pointee = buildUniforms()

        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.addCompletedHandler { [weak self] _ in
            self?.frameSemaphore.signal()
        }

        // Encode...
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
```

## CAMetalLayer Configuration

```swift
metalLayer.maximumDrawableCount = 3          // Triple buffering (default)
metalLayer.presentsWithTransaction = false   // Async presentation (default, fastest)
metalLayer.displaySyncEnabled = true         // VSync (default on macOS)
metalLayer.allowsNextDrawableTimeout = true  // nextDrawable() can return nil if no drawable available
metalLayer.framebufferOnly = true            // Optimization: texture is render-target only

// HDR support
metalLayer.pixelFormat = .rgba16Float
metalLayer.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
metalLayer.wantsExtendedDynamicRangeContent = true

// EDR headroom
if #available(macOS 14.0, *) {
    let maxEDR = NSScreen.main?.maximumExtendedDynamicRangeColorComponentValue ?? 1.0
}
```

## Multi-Window Rendering

Each window gets its own:
- `CAMetalLayer` (different drawable sizes)
- Render pass (different clear colors, different scenes)
- Optionally its own `CVDisplayLink` (different refresh rates)

Shared across windows:
- `MTLDevice`
- `MTLCommandQueue` (thread-safe)
- `MTLRenderPipelineState` (if same shaders)
- Textures, meshes, and other static resources

```swift
class WindowRenderer {
    let metalLayer: CAMetalLayer
    weak var sharedResources: SharedResources?

    func render() {
        guard let drawable = metalLayer.nextDrawable(),
              let resources = sharedResources else { return }

        let commandBuffer = resources.commandQueue.makeCommandBuffer()!
        // Use shared pipeline states and resources
        // Render to this window's drawable
    }
}
```

## Thread Safety

CVDisplayLink fires on a **high-priority background thread**. Key rules:

- `MTLCommandQueue.makeCommandBuffer()` is thread-safe
- `CAMetalLayer.nextDrawable()` is thread-safe
- **Do not** access AppKit views or update UI from the display link thread
- Use `DispatchQueue.main.async` for any UI updates triggered by rendering
- Protect shared state between the render thread and main thread (e.g., camera from user input)

```swift
// Thread-safe camera update
class Camera {
    private let lock = NSLock()
    private var _position: SIMD3<Float> = [0, 0, 5]

    var position: SIMD3<Float> {
        get { lock.withLock { _position } }
        set { lock.withLock { _position = newValue } }
    }
}
```
