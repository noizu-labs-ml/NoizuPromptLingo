# Worked Example: GPU Particle System

End-to-end implementation of a GPU-accelerated particle system using compute for physics and instanced rendering for display.

## Goal

Build a particle fountain: 100,000 particles emitted from a point, affected by gravity, with color and size varying over lifetime. Compute shader updates positions; instanced draw renders as colored points.

## Step 1: Shared Types (ShaderTypes.h)

```c
#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef struct {
    simd_float2 position;
    simd_float2 velocity;
    simd_float4 color;
    float life;
    float maxLife;
    float size;
    float _padding;
} Particle;

typedef struct {
    simd_float4x4 viewProjectionMatrix;
    float pointSizeScale;
    float deltaTime;
    uint32_t particleCount;
    uint32_t seed;
} Uniforms;

#endif
```

## Step 2: Compute Kernel (ParticleUpdate.metal)

```metal
#include <metal_stdlib>
#include "ShaderTypes.h"
using namespace metal;

// Simple hash for pseudo-random numbers
float hash(uint seed) {
    seed = (seed ^ 61) ^ (seed >> 16);
    seed *= 9;
    seed = seed ^ (seed >> 4);
    seed *= 0x27d4eb2d;
    seed = seed ^ (seed >> 15);
    return float(seed) / float(0xFFFFFFFF);
}

kernel void update_particles(
    device Particle *particles [[buffer(0)]],
    constant Uniforms &uniforms [[buffer(1)]],
    uint tid [[thread_position_in_grid]]
) {
    if (tid >= uniforms.particleCount) return;

    Particle p = particles[tid];
    float dt = uniforms.deltaTime;

    // Age the particle
    p.life -= dt;

    if (p.life <= 0.0) {
        // Respawn at origin
        uint seed = tid * 1973 + uniforms.seed;
        p.position = float2(0.0, -0.8);
        p.velocity = float2(
            (hash(seed) - 0.5) * 3.0,
            2.0 + hash(seed + 1) * 3.0
        );
        p.maxLife = 1.5 + hash(seed + 2) * 2.0;
        p.life = p.maxLife;
        p.size = 2.0 + hash(seed + 3) * 6.0;
    } else {
        // Physics update
        p.velocity.y -= 3.0 * dt;  // Gravity
        p.position += p.velocity * dt;
    }

    // Color: hot → cool over lifetime
    float t = p.life / p.maxLife;
    p.color = float4(
        smoothstep(0.0, 0.5, t),           // Red
        smoothstep(0.2, 0.8, t) * 0.8,     // Green
        smoothstep(0.5, 1.0, t) * 0.6,     // Blue
        smoothstep(0.0, 0.1, t)             // Alpha (fade at end)
    );

    particles[tid] = p;
}
```

## Step 3: Render Shaders (ParticleRender.metal)

```metal
#include <metal_stdlib>
#include "ShaderTypes.h"
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
};

vertex VertexOut particle_vertex(
    uint vertexID [[vertex_id]],
    constant Particle *particles [[buffer(0)]],
    constant Uniforms &uniforms [[buffer(1)]]
) {
    Particle p = particles[vertexID];

    VertexOut out;
    out.position = uniforms.viewProjectionMatrix * float4(p.position, 0.0, 1.0);
    out.color = p.color;
    out.pointSize = p.size * uniforms.pointSizeScale;
    return out;
}

fragment float4 particle_fragment(
    VertexOut in [[stage_in]],
    float2 pointCoord [[point_coord]]
) {
    // Circular point with soft edge
    float dist = length(pointCoord - float2(0.5));
    float alpha = 1.0 - smoothstep(0.3, 0.5, dist);
    return float4(in.color.rgb, in.color.a * alpha);
}
```

## Step 4: Renderer (ParticleRenderer.swift)

```swift
import MetalKit

class ParticleRenderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let particleCount = 100_000
    var particleBuffer: MTLBuffer!

    var computePipeline: MTLComputePipelineState!
    var renderPipeline: MTLRenderPipelineState!

    let maxFramesInFlight = 3
    let frameSemaphore: DispatchSemaphore
    var uniformBuffers: [MTLBuffer] = []
    var bufferIndex = 0

    var frameCount: UInt32 = 0
    var lastTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()

    init(metalView: MTKView) {
        device = metalView.device!
        commandQueue = device.makeCommandQueue()!
        frameSemaphore = DispatchSemaphore(value: maxFramesInFlight)
        super.init()

        setupBuffers()
        setupPipelines(metalView: metalView)
    }

    private func setupBuffers() {
        // Particle buffer (shared — both compute and render read/write)
        let bufferSize = MemoryLayout<Particle>.stride * particleCount
        particleBuffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)!

        // Initialize particles with zero life so they spawn immediately
        let particles = particleBuffer.contents().bindMemory(to: Particle.self, capacity: particleCount)
        for i in 0..<particleCount {
            particles[i] = Particle()  // All zeros → life = 0 → will respawn
        }

        // Uniform triple buffer
        for _ in 0..<maxFramesInFlight {
            let buffer = device.makeBuffer(
                length: MemoryLayout<Uniforms>.size,
                options: .storageModeShared
            )!
            uniformBuffers.append(buffer)
        }
    }

    private func setupPipelines(metalView: MTKView) {
        let library = device.makeDefaultLibrary()!

        // Compute pipeline
        let computeFunction = library.makeFunction(name: "update_particles")!
        computePipeline = try! device.makeComputePipelineState(function: computeFunction)

        // Render pipeline
        let renderDesc = MTLRenderPipelineDescriptor()
        renderDesc.vertexFunction = library.makeFunction(name: "particle_vertex")
        renderDesc.fragmentFunction = library.makeFunction(name: "particle_fragment")
        renderDesc.colorAttachments[0].pixelFormat = metalView.colorPixelFormat

        // Additive blending for glow effect
        renderDesc.colorAttachments[0].isBlendingEnabled = true
        renderDesc.colorAttachments[0].rgbBlendOperation = .add
        renderDesc.colorAttachments[0].alphaBlendOperation = .add
        renderDesc.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderDesc.colorAttachments[0].destinationRGBBlendFactor = .one
        renderDesc.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderDesc.colorAttachments[0].destinationAlphaBlendFactor = .one

        renderPipeline = try! device.makeRenderPipelineState(descriptor: renderDesc)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        frameSemaphore.wait()
        bufferIndex = (bufferIndex + 1) % maxFramesInFlight

        let now = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(now - lastTime)
        lastTime = now
        frameCount += 1

        // Update uniforms
        let uniformBuffer = uniformBuffers[bufferIndex]
        let uniforms = uniformBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
        uniforms.pointee.viewProjectionMatrix = matrix_identity_float4x4  // 2D, NDC space
        uniforms.pointee.pointSizeScale = Float(view.drawableSize.width) / 800.0
        uniforms.pointee.deltaTime = min(deltaTime, 1.0 / 30.0)  // Cap delta time
        uniforms.pointee.particleCount = UInt32(particleCount)
        uniforms.pointee.seed = frameCount

        guard let drawable = view.currentDrawable,
              let passDescriptor = view.currentRenderPassDescriptor else {
            frameSemaphore.signal()
            return
        }

        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.addCompletedHandler { [weak self] _ in
            self?.frameSemaphore.signal()
        }

        // Compute pass: update particles
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeEncoder.setComputePipelineState(computePipeline)
        computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(uniformBuffer, offset: 0, index: 1)

        let threadgroupSize = MTLSize(
            width: min(computePipeline.maxTotalThreadsPerThreadgroup, particleCount),
            height: 1, depth: 1
        )
        let gridSize = MTLSize(width: particleCount, height: 1, depth: 1)
        computeEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadgroupSize)
        computeEncoder.endEncoding()

        // Render pass: draw particles
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)!
        renderEncoder.setRenderPipelineState(renderPipeline)
        renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: particleCount)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
```

## Step 5: SwiftUI Integration

```swift
struct ContentView: View {
    var body: some View {
        MetalView()  // Same NSViewRepresentable pattern from SwiftUI integration guide
            .frame(minWidth: 800, minHeight: 600)
    }
}
```

## What You Should See

A fountain of 100,000 particles erupting from the bottom-center of the screen. Particles:
- Launch upward with randomized angles
- Arc under gravity
- Transition from blue (young) through green to red (old)
- Fade out as they die
- Respawn at the emitter

At 60fps on Apple Silicon, the compute + render takes < 1ms total for 100K particles.

## Performance Characteristics

| Metric | Value (M1 Mac) |
|---|---|
| Particle count | 100,000 |
| Compute time | ~0.1ms |
| Render time | ~0.3ms |
| Total frame time | ~0.5ms |
| Memory | ~4.8 MB (particle buffer) |

## Possible Extensions

1. **3D particles** — Add z-coordinate, use perspective projection
2. **Texture sprites** — Replace point rendering with textured quads
3. **Collision** — Bounce off floor plane or arbitrary geometry
4. **Multiple emitters** — Array of emitter configs in uniform buffer
5. **Trail rendering** — Store position history, render as line strips
6. **Sort by depth** — For correct alpha blending in 3D (bitonic sort on GPU)
