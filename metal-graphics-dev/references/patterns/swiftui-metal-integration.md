# SwiftUI + Metal Integration

Patterns for embedding Metal rendering views inside SwiftUI applications.

## Core Pattern: NSViewRepresentable (macOS) / UIViewRepresentable (iOS)

### macOS

```swift
import SwiftUI
import MetalKit

struct MetalView: NSViewRepresentable {
    @Binding var viewModel: SceneViewModel  // SwiftUI state → renderer

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        view.device = MTLCreateSystemDefaultDevice()
        view.colorPixelFormat = .bgra8Unorm
        view.depthStencilPixelFormat = .depth32Float
        view.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        view.preferredFramesPerSecond = 60

        let renderer = Renderer(metalView: view)
        view.delegate = renderer
        context.coordinator.renderer = renderer

        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {
        // Push SwiftUI state changes to the renderer
        context.coordinator.renderer?.updateScene(viewModel)
    }

    class Coordinator {
        var renderer: Renderer?
    }
}
```

### iOS

```swift
struct MetalView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView { /* same setup */ }
    func updateUIView(_ uiView: MTKView, context: Context) { }
    // ...
}
```

### Cross-Platform Typealias

```swift
#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
typealias PlatformView = NSView
typealias PlatformViewRepresentableContext = NSViewRepresentableContext
#else
typealias ViewRepresentable = UIViewRepresentable
typealias PlatformView = UIView
typealias PlatformViewRepresentableContext = UIViewRepresentableContext
#endif
```

## State Flow: SwiftUI → Renderer

### Pattern 1: Observable Object

```swift
@Observable
class SceneViewModel {
    var cameraPosition: SIMD3<Float> = [0, 0, 5]
    var lightDirection: SIMD3<Float> = [0, -1, -1]
    var backgroundColor: Color = .black
    var selectedObjectID: Int?
}

// In Renderer:
func updateScene(_ viewModel: SceneViewModel) {
    uniforms.cameraPosition = viewModel.cameraPosition
    uniforms.lightDirection = normalize(viewModel.lightDirection)
}
```

### Pattern 2: Direct Binding for Controls

```swift
struct ContentView: View {
    @State private var viewModel = SceneViewModel()

    var body: some View {
        HSplitView {
            MetalView(viewModel: $viewModel)
                .frame(minWidth: 400)

            VStack {
                Slider(value: $viewModel.cameraPosition.z, in: 1...20) {
                    Text("Camera Distance")
                }
                ColorPicker("Background", selection: $viewModel.backgroundColor)
            }
            .frame(width: 200)
            .padding()
        }
    }
}
```

## State Flow: Renderer → SwiftUI

For picking, hit testing, or GPU readback results:

```swift
@Observable
class RenderFeedback {
    var fps: Double = 0
    var drawCallCount: Int = 0
    var hoveredObjectID: Int?
}

class Renderer: NSObject, MTKViewDelegate {
    var feedback: RenderFeedback

    func draw(in view: MTKView) {
        // ... render ...
        DispatchQueue.main.async {
            self.feedback.fps = 1.0 / deltaTime
            self.feedback.drawCallCount = self.drawCount
        }
    }
}
```

## Input Handling

### Mouse/Keyboard (macOS)

MTKView inherits from NSView, so override in a subclass or use gesture recognizers:

```swift
class InputMTKView: MTKView {
    var onMouseDown: ((NSPoint) -> Void)?
    var onMouseDragged: ((NSPoint, NSPoint) -> Void)?
    var onScrollWheel: ((CGFloat) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        onMouseDown?(location)
    }

    override func mouseDragged(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        let delta = NSPoint(x: event.deltaX, y: event.deltaY)
        onMouseDragged?(location, delta)
    }

    override func scrollWheel(with event: NSEvent) {
        onScrollWheel?(event.deltaY)
    }

    override func keyDown(with event: NSEvent) {
        // Handle WASD, arrows, etc.
    }
}
```

Wire this up in `makeNSView` instead of a plain `MTKView`.

### Touch (iOS)

```swift
class InputMTKView: MTKView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { }
}
```

## Resize Handling

MTKView calls `mtkView(_:drawableSizeWillChange:)` on resize. Update:

```swift
func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    let aspect = Float(size.width / size.height)
    projectionMatrix = matrix_perspective(fovY: Float.pi / 4, aspect: aspect, near: 0.1, far: 100)

    // Recreate depth texture at new size
    rebuildDepthTexture(width: Int(size.width), height: Int(size.height))

    // Recreate MSAA texture if using MSAA
    if sampleCount > 1 {
        rebuildMSAATexture(width: Int(size.width), height: Int(size.height))
    }
}
```

## Display Scale (Retina)

MTKView handles this automatically — `drawableSize` is in pixels (2x on Retina), `bounds` is in points. The shader sees pixel coordinates; SwiftUI sees points. Convert:

```swift
let scale = view.window?.backingScaleFactor ?? 2.0
let pixelPosition = pointPosition * Float(scale)
```

## Performance Considerations

- `updateNSView` is called on **every SwiftUI state change** — keep it cheap
- Don't recreate Metal objects in `updateNSView` — update uniforms only
- Use `isPaused = true` on MTKView if the scene is static (saves battery)
- Set `enableSetNeedsDisplay = true` and call `setNeedsDisplay()` for on-demand rendering instead of continuous 60fps
