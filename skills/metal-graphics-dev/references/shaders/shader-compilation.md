# Shader Compilation

Runtime vs precompiled shaders, Metal libraries, function constants, and pipeline caching.

## Compilation Pipeline

```
.metal source → Metal Compiler → .metallib binary → MTLLibrary → MTLFunction → MTLPipelineState
```

### Runtime Compilation (Development)

```swift
// Default library: compiled from all .metal files in the Xcode target
let library = device.makeDefaultLibrary()!

// From source string (slow — avoid in production)
let library = try device.makeLibrary(source: mslSource, options: nil)

// From file URL
let library = try device.makeLibrary(filepath: "/path/to/shaders.metallib")

// From data
let library = try device.makeLibrary(data: metalLibData)
```

### Precompiled Libraries (Production)

Precompile `.metal` files to `.metallib` for faster load times:

```bash
# Compile to AIR (Apple Intermediate Representation)
xcrun -sdk macosx metal -c Shaders.metal -o Shaders.air

# Link AIR to metallib
xcrun -sdk macosx metallib Shaders.air -o Shaders.metallib

# Multiple files
xcrun -sdk macosx metal -c A.metal -o A.air
xcrun -sdk macosx metal -c B.metal -o B.air
xcrun -sdk macosx metallib A.air B.air -o Combined.metallib
```

Xcode automatically compiles and bundles `.metallib` into the app.

## Function Constants

Specialize shaders at pipeline creation time without recompiling from source. Like C++ template parameters for shaders.

### Declaration (MSL)

```metal
constant bool useNormalMap [[function_constant(0)]];
constant int lightCount [[function_constant(1)]];
constant bool enableShadows [[function_constant(2)]];

fragment float4 fragment_main(VertexOut in [[stage_in]], ...) {
    float3 normal = in.normal;

    if (useNormalMap) {
        // This entire block is compiled out when useNormalMap = false
        normal = sampleNormalMap(in.texCoord);
    }

    float3 lighting = float3(0);
    for (int i = 0; i < lightCount; i++) {
        lighting += calculateLight(i, normal, ...);
        if (enableShadows) {
            lighting *= calculateShadow(i, ...);
        }
    }

    return float4(lighting, 1.0);
}
```

### Specialization (Swift)

```swift
let constants = MTLFunctionConstantValues()

var useNormalMap = true
constants.setConstantValue(&useNormalMap, type: .bool, index: 0)

var lightCount: Int32 = 4
constants.setConstantValue(&lightCount, type: .int, index: 1)

var enableShadows = false
constants.setConstantValue(&enableShadows, type: .bool, index: 2)

let function = try library.makeFunction(name: "fragment_main", constantValues: constants)
```

**When to use function constants:**
- Toggling features on/off (normal mapping, shadows, fog)
- Setting loop bounds known at pipeline creation time
- Branching on material type without uber-shader runtime branching
- Reducing register pressure by eliminating dead code paths

## Pipeline Caching

### Binary Archives (Metal 3+)

Serialize compiled pipeline states to disk for instant loading:

```swift
// Create archive
let archiveDescriptor = MTLBinaryArchiveDescriptor()
let archive = try device.makeBinaryArchive(descriptor: archiveDescriptor)

// Add pipeline to archive
try archive.addRenderPipelineFunctions(descriptor: pipelineDescriptor)

// Serialize to disk
let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("pipeline-cache.metallib")
try archive.serialize(to: url)

// Load from disk (subsequent launches)
let loadDescriptor = MTLBinaryArchiveDescriptor()
loadDescriptor.url = url
let cachedArchive = try device.makeBinaryArchive(descriptor: loadDescriptor)

// Create pipeline with cached archive
let pipelineDescriptor = MTLRenderPipelineDescriptor()
pipelineDescriptor.binaryArchives = [cachedArchive]
// ... set up descriptor ...
let pipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
```

### Async Pipeline Compilation

For many pipeline variants, compile asynchronously:

```swift
device.makeRenderPipelineState(descriptor: descriptor) { pipelineState, error in
    if let pipeline = pipelineState {
        self.pipelineCache[key] = pipeline
    }
}
```

## Shader Includes and Organization

### Metal Headers

```metal
// Common.h — shared types and utilities
#ifndef Common_h
#define Common_h

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewProjectionMatrix;
    float3 cameraPosition;
};

inline float3 srgb_to_linear(float3 color) {
    return pow(color, float3(2.2));
}

#endif

// Shaders.metal
#include "Common.h"
#include "Lighting.h"

vertex VertexOut vertex_main(...) { }
fragment float4 fragment_main(...) { }
```

### Organization Pattern

```
Shaders/
├── ShaderTypes.h         # CPU/GPU shared types (bridging header)
├── Common.h              # Metal-only common utilities
├── Lighting.h            # Lighting functions
├── Noise.h               # Noise functions
├── Vertex.metal          # Vertex shaders
├── Fragment.metal         # Fragment shaders
├── Compute.metal          # Compute kernels
└── PostProcess.metal      # Post-processing shaders
```

All `.metal` files in the target are compiled into a single default library. Use `#include` for shared headers.
