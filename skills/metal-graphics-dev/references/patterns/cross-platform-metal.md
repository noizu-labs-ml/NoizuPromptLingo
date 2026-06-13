# Cross-Platform Metal

Sharing Metal code across macOS, iOS, and visionOS.

## Platform Abstraction Layer

### Type Aliases

```swift
#if os(macOS)
import AppKit
typealias PlatformColor = NSColor
typealias PlatformImage = NSImage
typealias PlatformViewController = NSViewController
#elseif os(iOS) || os(visionOS)
import UIKit
typealias PlatformColor = UIColor
typealias PlatformImage = UIImage
typealias PlatformViewController = UIViewController
#endif
```

### ViewRepresentable Abstraction

```swift
#if os(macOS)
struct MetalView: NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView { makeMetalView(context: context) }
    func updateNSView(_ view: MTKView, context: Context) { updateMetalView(view, context: context) }
}
#else
struct MetalView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView { makeMetalView(context: context) }
    func updateUIView(_ view: MTKView, context: Context) { updateMetalView(view, context: context) }
}
#endif

// Shared implementation
extension MetalView {
    func makeMetalView(context: Context) -> MTKView {
        let view = MTKView()
        view.device = MTLCreateSystemDefaultDevice()
        // ... shared setup ...
        return view
    }

    func updateMetalView(_ view: MTKView, context: Context) {
        // ... shared update logic ...
    }
}
```

## Storage Mode Differences

| Mode | macOS (Apple Silicon) | macOS (Intel/AMD) | iOS | visionOS |
|---|---|---|---|---|
| `shared` | Available | Available | Available | Available |
| `managed` | Available | Available (preferred for dynamic) | Not available | Not available |
| `private` | Available | Available | Available | Available |
| `memoryless` | Available | Not available | Available | Available |

### Conditional Storage Mode

```swift
func optimalStorageMode(for usage: BufferUsage) -> MTLResourceOptions {
    switch usage {
    case .dynamicUniform:
        #if os(macOS)
        if device.hasUnifiedMemory {
            return .storageModeShared  // Apple Silicon Mac
        } else {
            return .storageModeManaged  // Intel/AMD Mac
        }
        #else
        return .storageModeShared  // iOS, visionOS
        #endif

    case .staticMesh, .texture:
        return .storageModePrivate  // All platforms

    case .transientRenderTarget:
        #if os(macOS)
        if device.hasUnifiedMemory {
            return [.storageModeMemoryless]  // Apple Silicon
        } else {
            return .storageModePrivate
        }
        #else
        return [.storageModeMemoryless]
        #endif
    }
}
```

## GPU Family Feature Gating

```swift
struct GPUCapabilities {
    let device: MTLDevice

    var supportsRayTracing: Bool {
        device.supportsFamily(.apple9)  // M3, A17+
    }

    var supportsMeshShaders: Bool {
        device.supportsFamily(.apple8)  // M2, A15+ (partial)
    }

    var maxBufferLength: Int {
        device.maxBufferLength  // Varies by device
    }

    var supportsNonUniformThreadgroups: Bool {
        device.supportsFamily(.apple4)  // All modern Apple GPUs
    }

    var supports32BitMSAA: Bool {
        device.supportsFamily(.apple7)
    }

    var supportsLosslessMSAA: Bool {
        device.supportsFamily(.apple7)  // Free MSAA on Apple Silicon
    }
}
```

## Shader Conditional Compilation

MSL supports preprocessor defines set from Swift:

```swift
let constants = MTLFunctionConstantValues()

var isAppleGPU = device.supportsFamily(.apple1)
constants.setConstantValue(&isAppleGPU, type: .bool, index: 0)

var hasRayTracing = device.supportsFamily(.apple9)
constants.setConstantValue(&hasRayTracing, type: .bool, index: 1)
```

Or use compiler flags:

```swift
let options = MTLCompileOptions()
options.preprocessorMacros = [
    "TARGET_MACOS": NSNumber(value: 1),
    "MAX_LIGHTS": NSNumber(value: 8)
]
let library = try device.makeLibrary(source: source, options: options)
```

## Input Abstraction

```swift
protocol InputHandler {
    func handlePanGesture(translation: SIMD2<Float>, state: GestureState)
    func handleZoom(delta: Float)
    func handleRotation(delta: SIMD2<Float>)
}

enum GestureState {
    case began, changed, ended
}

#if os(macOS)
extension Renderer {
    func handleMouseDragged(deltaX: CGFloat, deltaY: CGFloat) {
        inputHandler.handleRotation(delta: SIMD2<Float>(Float(deltaX), Float(deltaY)))
    }

    func handleScrollWheel(deltaY: CGFloat) {
        inputHandler.handleZoom(delta: Float(deltaY))
    }
}
#elseif os(iOS)
extension Renderer {
    func handlePinch(scale: CGFloat) {
        inputHandler.handleZoom(delta: Float(scale - 1.0))
    }

    func handlePan(translation: CGPoint) {
        inputHandler.handleRotation(delta: SIMD2<Float>(Float(translation.x), Float(translation.y)))
    }
}
#endif
```

## visionOS Considerations

- Metal rendering works inside `ImmersiveSpace` via `CompositorServices`
- Standard Metal rendering in a window uses the same `MTKView` pattern as iOS
- `CompositorServices` provides per-eye rendering for immersive content
- Passthrough and spatial anchoring require ARKit integration alongside Metal

```swift
// visionOS immersive rendering (simplified)
import CompositorServices

struct ImmersiveView: ImmersiveSpace {
    var body: some ImmersiveSpaceContent {
        CompositorLayer(configuration: ContentStageConfiguration()) { layerRenderer in
            let renderer = ImmersiveRenderer(layerRenderer: layerRenderer)
            renderer.startRenderLoop()
        }
    }
}
```

## Project Organization for Cross-Platform

```
Shared/
├── Renderer.swift           # Platform-independent render logic
├── Shaders.metal            # All shaders (MSL is cross-platform)
├── ShaderTypes.h            # Shared types
├── Camera.swift             # Camera math
└── MeshLoader.swift         # Asset loading

macOS/
├── MetalView+macOS.swift    # NSViewRepresentable
├── InputHandler+macOS.swift # Mouse/keyboard
└── App+macOS.swift          # macOS app entry

iOS/
├── MetalView+iOS.swift      # UIViewRepresentable
├── InputHandler+iOS.swift   # Touch/gesture
└── App+iOS.swift            # iOS app entry

visionOS/
├── MetalView+visionOS.swift
└── ImmersiveRenderer.swift
```

Use Xcode's target membership to include shared files in all targets and platform-specific files only in their respective targets.
