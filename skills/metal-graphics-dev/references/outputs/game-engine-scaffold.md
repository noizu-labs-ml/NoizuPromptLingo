# Game Engine Scaffold

Architecture guide for building a Metal-based game engine with ECS, scene graph, and asset pipeline.

## Architecture Overview

```
Game Engine
├── Core
│   ├── ECS (Entity-Component-System)
│   ├── Scene Graph
│   ├── Event System
│   └── Time / Frame Clock
├── Rendering
│   ├── Renderer (Metal backend)
│   ├── Material System
│   ├── Mesh System
│   ├── Camera
│   └── Lighting
├── Assets
│   ├── Texture Loader
│   ├── Mesh Loader (OBJ, glTF)
│   ├── Shader Manager
│   └── Asset Cache
├── Input
│   ├── Keyboard / Mouse (macOS)
│   ├── Touch / Gesture (iOS)
│   └── Game Controller
└── Physics (optional)
    ├── Collision Detection
    └── Rigid Body Dynamics
```

## ECS Architecture

### Components

```swift
protocol Component {}

struct TransformComponent: Component {
    var position: SIMD3<Float> = .zero
    var rotation: simd_quatf = .init(angle: 0, axis: [0, 1, 0])
    var scale: SIMD3<Float> = .one

    var modelMatrix: simd_float4x4 {
        let t = simd_float4x4(translation: position)
        let r = simd_float4x4(rotation)
        let s = simd_float4x4(scale: scale)
        return t * r * s
    }
}

struct MeshComponent: Component {
    var meshID: MeshID
    var materialID: MaterialID
    var visible: Bool = true
}

struct LightComponent: Component {
    enum LightType { case directional, point, spot }
    var type: LightType
    var color: SIMD3<Float> = .one
    var intensity: Float = 1.0
    var range: Float = 10.0       // point/spot
    var innerAngle: Float = 0.5   // spot
    var outerAngle: Float = 0.8   // spot
}

struct CameraComponent: Component {
    var fovY: Float = Float.pi / 4
    var nearPlane: Float = 0.1
    var farPlane: Float = 100.0
    var isActive: Bool = false
}
```

### Entity and World

```swift
typealias EntityID = UInt32

class World {
    private var nextID: EntityID = 0
    private var transforms: [EntityID: TransformComponent] = [:]
    private var meshes: [EntityID: MeshComponent] = [:]
    private var lights: [EntityID: LightComponent] = [:]
    private var cameras: [EntityID: CameraComponent] = [:]

    func createEntity() -> EntityID {
        let id = nextID
        nextID += 1
        return id
    }

    func addComponent<T: Component>(_ component: T, to entity: EntityID) {
        // Type-switch to appropriate storage
    }

    func entitiesWith<A: Component, B: Component>(_ a: A.Type, _ b: B.Type) -> [(EntityID, A, B)] {
        // Join query across component stores
    }
}
```

### Systems

```swift
protocol System {
    func update(world: World, deltaTime: Float)
}

class RenderSystem: System {
    let renderer: Renderer

    func update(world: World, deltaTime: Float) {
        // Collect renderables
        let renderables = world.entitiesWith(TransformComponent.self, MeshComponent.self)
            .filter { $0.2.visible }

        // Sort by material (minimize pipeline switches)
        let sorted = renderables.sorted { $0.2.materialID < $1.2.materialID }

        // Submit to renderer
        renderer.beginFrame()
        for (_, transform, mesh) in sorted {
            renderer.submit(meshID: mesh.meshID, materialID: mesh.materialID, modelMatrix: transform.modelMatrix)
        }
        renderer.endFrame()
    }
}
```

## Render Pipeline Design

### Multi-Pass Rendering

```
Pass 1: Shadow Map
  └── Depth-only render to shadow texture

Pass 2: G-Buffer (Deferred)
  ├── Attachment 0: Albedo (RGBA8)
  ├── Attachment 1: Normal (RGBA16F)
  ├── Attachment 2: Material (RGBA8: metallic, roughness, ao, ?)
  └── Depth: Depth32F

Pass 3: Lighting (Full-screen quad)
  └── Read G-Buffer + Shadow Map → Output lit color

Pass 4: Forward Transparent
  └── Render transparent objects with blending

Pass 5: Post-Processing
  ├── Bloom
  ├── Tone Mapping
  └── FXAA
```

### Material System

```swift
struct Material {
    var pipelineKey: PipelineKey
    var albedoTexture: MTLTexture?
    var normalTexture: MTLTexture?
    var metallicRoughnessTexture: MTLTexture?
    var baseColor: SIMD4<Float> = .one
    var metallic: Float = 0.0
    var roughness: Float = 0.5
}

class MaterialLibrary {
    private var materials: [MaterialID: Material] = [:]
    private var pipelineCache: PipelineCache

    func bind(materialID: MaterialID, encoder: MTLRenderCommandEncoder) {
        guard let material = materials[materialID] else { return }

        let pipeline = try! pipelineCache.pipeline(for: material.pipelineKey)
        encoder.setRenderPipelineState(pipeline)
        encoder.setFragmentTexture(material.albedoTexture, index: 0)
        encoder.setFragmentTexture(material.normalTexture, index: 1)
        encoder.setFragmentTexture(material.metallicRoughnessTexture, index: 2)

        var params = MaterialParams(
            baseColor: material.baseColor,
            metallic: material.metallic,
            roughness: material.roughness
        )
        encoder.setFragmentBytes(&params, length: MemoryLayout<MaterialParams>.size, index: 0)
    }
}
```

## Asset Pipeline

### Mesh Loading (Model I/O)

```swift
import ModelIO

class MeshLoader {
    let device: MTLDevice
    let allocator: MTKMeshBufferAllocator

    init(device: MTLDevice) {
        self.device = device
        allocator = MTKMeshBufferAllocator(device: device)
    }

    func loadOBJ(url: URL) throws -> [MTKMesh] {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(
            name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0
        )
        vertexDescriptor.attributes[1] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0
        )
        vertexDescriptor.attributes[2] = MDLVertexAttribute(
            name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: 24, bufferIndex: 0
        )
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 32)

        let asset = MDLAsset(url: url, vertexDescriptor: vertexDescriptor, bufferAllocator: allocator)
        return try MTKMesh.newMeshes(asset: asset, device: device).metalKitMeshes
    }
}
```

### Texture Loading

```swift
import MetalKit

class TextureLoader {
    let loader: MTKTextureLoader

    init(device: MTLDevice) {
        loader = MTKTextureLoader(device: device)
    }

    func load(name: String) throws -> MTLTexture {
        let options: [MTKTextureLoader.Option: Any] = [
            .textureUsage: MTLTextureUsage.shaderRead.rawValue,
            .textureStorageMode: MTLStorageMode.private.rawValue,
            .generateMipmaps: true
        ]
        return try loader.newTexture(name: name, scaleFactor: 1.0, bundle: nil, options: options)
    }
}
```

## Project Template

```
GameEngine/
├── Sources/
│   ├── App/
│   │   ├── GameApp.swift              # @main entry
│   │   ├── GameView.swift             # Metal view wrapper
│   │   └── GameScene.swift            # Scene setup
│   ├── Core/
│   │   ├── World.swift                # ECS world
│   │   ├── Components.swift           # All component types
│   │   └── Systems.swift              # System protocol + implementations
│   ├── Rendering/
│   │   ├── Renderer.swift             # Metal render loop
│   │   ├── RenderPasses.swift         # Multi-pass pipeline
│   │   ├── MaterialLibrary.swift      # Material management
│   │   ├── MeshLibrary.swift          # Mesh storage
│   │   ├── PipelineCache.swift        # Pipeline state caching
│   │   └── Camera.swift               # Camera + projection
│   ├── Assets/
│   │   ├── MeshLoader.swift           # OBJ/glTF loading
│   │   ├── TextureLoader.swift        # Texture loading
│   │   └── AssetCache.swift           # LRU cache
│   └── Input/
│       ├── InputManager.swift         # Unified input abstraction
│       └── CameraController.swift     # Orbit/fly camera
├── Shaders/
│   ├── ShaderTypes.h                  # Shared CPU/GPU types
│   ├── Common.h                       # MSL utilities
│   ├── Lighting.h                     # PBR lighting functions
│   ├── GBuffer.metal                  # G-buffer pass shaders
│   ├── DeferredLighting.metal         # Lighting pass
│   ├── Shadow.metal                   # Shadow map generation
│   ├── Forward.metal                  # Forward transparent pass
│   └── PostProcess.metal              # Post-processing effects
└── Resources/
    ├── Meshes/
    └── Textures/
```
