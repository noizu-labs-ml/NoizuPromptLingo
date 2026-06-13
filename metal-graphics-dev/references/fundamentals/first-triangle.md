# First Triangle

Complete walkthrough: from empty project to a colored triangle rendered with Metal and SwiftUI.

## Prerequisites

- macOS 13+ with Xcode 15+
- Any Mac with Metal support (all Apple Silicon, most Intel Macs from 2012+)

## Step 1: Project Structure

```
FirstTriangle/
├── FirstTriangleApp.swift    # SwiftUI app entry
├── ContentView.swift         # SwiftUI host
├── MetalView.swift           # NSViewRepresentable wrapper
├── Renderer.swift            # MTKViewDelegate — the render loop
├── Shaders.metal             # Vertex + fragment shaders
└── ShaderTypes.h             # Shared CPU/GPU types (bridging header)
```

## Step 2: Shared Types (ShaderTypes.h)

This header is included by both Swift (via bridging header) and Metal (via `#include`).

```c
#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef struct {
    simd_float2 position;
    simd_float4 color;
} Vertex;

#endif
```

Set up the bridging header in Build Settings → Swift Compiler → Objective-C Bridging Header.

## Step 3: Shaders (Shaders.metal)

```metal
#include <metal_stdlib>
#include "ShaderTypes.h"
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertex_main(
    uint vertexID [[vertex_id]],
    constant Vertex *vertices [[buffer(0)]]
) {
    VertexOut out;
    out.position = float4(vertices[vertexID].position, 0.0, 1.0);
    out.color = vertices[vertexID].color;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}
```

## Step 4: Renderer (Renderer.swift)

```swift
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer

    init(metalView: MTKView) {
        device = metalView.device!
        commandQueue = device.makeCommandQueue()!

        // Triangle vertices (NDC: -1 to 1)
        let vertices: [Vertex] = [
            Vertex(position: SIMD2<Float>( 0.0,  0.5), color: SIMD4<Float>(1, 0, 0, 1)),
            Vertex(position: SIMD2<Float>(-0.5, -0.5), color: SIMD4<Float>(0, 1, 0, 1)),
            Vertex(position: SIMD2<Float>( 0.5, -0.5), color: SIMD4<Float>(0, 0, 1, 1)),
        ]
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Vertex>.stride * vertices.count,
            options: .storageModeShared
        )!

        // Pipeline state
        let library = device.makeDefaultLibrary()!
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        descriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        descriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat

        pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
        super.init()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!

        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
```

## Step 5: Metal View Wrapper (MetalView.swift)

```swift
import SwiftUI
import MetalKit

struct MetalView: NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        view.device = MTLCreateSystemDefaultDevice()
        view.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.colorPixelFormat = .bgra8Unorm

        let renderer = Renderer(metalView: view)
        view.delegate = renderer
        context.coordinator.renderer = renderer

        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var renderer: Renderer?
    }
}
```

## Step 6: SwiftUI Host (ContentView.swift)

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalView()
            .frame(minWidth: 400, minHeight: 300)
    }
}
```

## Step 7: App Entry (FirstTriangleApp.swift)

```swift
import SwiftUI

@main
struct FirstTriangleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## What You Should See

A colored triangle (red top, green bottom-left, blue bottom-right) against a dark background. The colors interpolate smoothly across the triangle — this is the GPU's rasterizer interpolating the per-vertex colors.

## Common Gotchas

| Problem | Cause | Fix |
|---|---|---|
| Black screen | Missing `present(drawable)` or `commit()` | Check render loop — both are required |
| Crash on launch | `MTLCreateSystemDefaultDevice()` returns nil | Running on unsupported hardware or simulator |
| Triangle doesn't appear | Vertex positions outside NDC range (-1 to 1) | Check coordinate values |
| Colors are wrong | BGRA vs RGBA pixel format mismatch | Ensure `colorPixelFormat` matches shader output |
| View doesn't resize | Missing `drawableSizeWillChange` handling | Implement if using projection matrices |
| Renderer deallocated | `Coordinator` doesn't hold strong reference | Store renderer in coordinator |

## Next Steps

1. Add a uniform buffer for transforms (model-view-projection matrix)
2. Load a mesh from a file (MDLMesh or custom OBJ loader)
3. Add depth testing for 3D rendering
4. Implement triple buffering for smooth animation
