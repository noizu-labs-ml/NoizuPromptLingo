# MSL Reference

Metal Shading Language types, functions, qualifiers, and idioms.

## Type System

### Scalar Types

| MSL Type | Size | Swift Equivalent | Notes |
|---|---|---|---|
| `bool` | 1 byte | `Bool` | |
| `char`, `uchar` | 1 byte | `Int8`, `UInt8` | |
| `short`, `ushort` | 2 bytes | `Int16`, `UInt16` | |
| `int`, `uint` | 4 bytes | `Int32`, `UInt32` | |
| `half` | 2 bytes | `Float16` | 16-bit float, prefer for mobile |
| `float` | 4 bytes | `Float` | 32-bit float |

### Vector Types

| MSL Type | Components | Size | Swift SIMD |
|---|---|---|---|
| `float2` | 2 | 8 bytes | `SIMD2<Float>` |
| `float3` | 3 | 16 bytes (!) | `SIMD3<Float>` (padded to 16) |
| `float4` | 4 | 16 bytes | `SIMD4<Float>` |
| `packed_float3` | 3 | 12 bytes | No direct equivalent |
| `half4` | 4 | 8 bytes | `SIMD4<Float16>` |
| `int2`, `uint2` | 2 | 8 bytes | `SIMD2<Int32>` |

**Critical:** `float3` is 16-byte aligned, not 12. Use `packed_float3` in buffers to avoid padding gaps. In Swift, use explicit padding or `packed_float3`-compatible layout.

### Matrix Types

| MSL Type | Size | Swift Equivalent |
|---|---|---|
| `float4x4` | 64 bytes | `simd_float4x4` |
| `float3x3` | 48 bytes | `simd_float3x3` |
| `half4x4` | 32 bytes | — |

Matrices are **column-major** in both MSL and simd.

## Function Qualifiers

```metal
// Vertex shader — runs once per vertex
vertex VertexOut vertex_main(VertexIn in [[stage_in]], ...) { }

// Fragment shader — runs once per fragment (pixel candidate)
fragment float4 fragment_main(VertexOut in [[stage_in]], ...) { }

// Compute kernel — runs once per thread
kernel void compute_main(uint tid [[thread_position_in_grid]], ...) { }
```

## Attribute Qualifiers

### Vertex Input

| Qualifier | Purpose |
|---|---|
| `[[stage_in]]` | Assembled vertex data from vertex descriptor |
| `[[vertex_id]]` | Vertex index (0, 1, 2, ...) |
| `[[instance_id]]` | Instance index for instanced draws |
| `[[base_vertex]]` | Base vertex offset |
| `[[base_instance]]` | Base instance offset |
| `[[attribute(N)]]` | Vertex attribute at index N (inside struct) |

### Vertex Output / Fragment Input

| Qualifier | Purpose |
|---|---|
| `[[position]]` | Clip-space position (required vertex output) |
| `[[point_size]]` | Point primitive size |
| `[[flat]]` | No interpolation (flat shading) |
| `[[center_perspective]]` | Default interpolation (can omit) |
| `[[sample]]` | Per-sample interpolation (MSAA) |

### Fragment Output

| Qualifier | Purpose |
|---|---|
| `[[color(N)]]` | Output to color attachment N |
| `[[depth(any)]]` | Custom depth output |
| Return `float4` | Implicit `[[color(0)]]` |

### Resource Binding

| Qualifier | Purpose |
|---|---|
| `[[buffer(N)]]` | Buffer at index N |
| `[[texture(N)]]` | Texture at index N |
| `[[sampler(N)]]` | Sampler at index N |

### Compute Qualifiers

| Qualifier | Purpose |
|---|---|
| `[[thread_position_in_grid]]` | Global thread ID |
| `[[threadgroup_position_in_grid]]` | Threadgroup ID |
| `[[thread_position_in_threadgroup]]` | Local thread ID within group |
| `[[threads_per_threadgroup]]` | Threadgroup dimensions |
| `[[thread_index_in_threadgroup]]` | Linear index within group |
| `[[threadgroups_per_grid]]` | Grid dimensions in threadgroups |
| `[[threadgroup(N)]]` | Threadgroup memory at index N |
| `[[simdgroup_index_in_threadgroup]]` | SIMD group index |
| `[[thread_index_in_simdgroup]]` | Lane index within SIMD group |

## Address Spaces

| Qualifier | Description | Use |
|---|---|---|
| `device` | Global device memory (R/W) | Buffers, storage textures |
| `constant` | Constant memory (read-only) | Uniforms, constant data (broadcast-optimized) |
| `threadgroup` | Shared within threadgroup | Compute shared memory |
| `thread` | Per-thread private | Local variables (default) |

```metal
vertex VertexOut vertex_main(
    constant Uniforms &uniforms [[buffer(0)]],  // constant: read by all vertices
    device Vertex *vertices [[buffer(1)]]        // device: per-vertex data
) { }
```

## Built-In Functions

### Math

```metal
float3 n = normalize(normal);
float d = dot(lightDir, n);
float3 r = reflect(-lightDir, n);
float s = pow(max(dot(r, viewDir), 0.0), shininess);
float a = clamp(value, 0.0, 1.0);
float l = length(v);
float m = mix(a, b, t);     // linear interpolation
float st = smoothstep(0.0, 1.0, t);
float3 c = cross(a, b);
```

### Texture Sampling

```metal
constexpr sampler s(
    filter::linear,           // or nearest
    mip_filter::linear,       // or nearest, none
    address::repeat,          // or clamp_to_edge, clamp_to_zero, mirrored_repeat
    max_anisotropy(8)
);

float4 color = texture.sample(s, uv);
float4 color_lod = texture.sample(s, uv, level(mipLevel));
float4 color_bias = texture.sample(s, uv, bias(mipBias));
float4 color_grad = texture.sample(s, uv, gradient2d(dpdx, dpdy));
```

### Texture Read/Write (Compute)

```metal
float4 pixel = inTexture.read(uint2(x, y));
outTexture.write(pixel, uint2(x, y));
```

### Atomic Operations (Compute)

```metal
device atomic_uint *counter;
uint old = atomic_fetch_add_explicit(counter, 1, memory_order_relaxed);
```

## Common Shader Patterns

### Phong Lighting

```metal
float3 phong(float3 normal, float3 lightDir, float3 viewDir,
             float3 diffuseColor, float3 specularColor, float shininess) {
    float3 n = normalize(normal);
    float3 l = normalize(lightDir);
    float3 v = normalize(viewDir);

    float diff = max(dot(n, l), 0.0);
    float3 r = reflect(-l, n);
    float spec = pow(max(dot(r, v), 0.0), shininess);

    return diffuseColor * diff + specularColor * spec;
}
```

### Normal Mapping

```metal
float3 tangent_to_world(float3 tangentNormal, float3 N, float3 T, float3 B) {
    float3x3 TBN = float3x3(T, B, N);
    return normalize(TBN * tangentNormal);
}

// In fragment shader:
float3 normalMap = normalTexture.sample(s, in.texCoord).xyz * 2.0 - 1.0;
float3 worldNormal = tangent_to_world(normalMap, in.normal, in.tangent, in.bitangent);
```

### Screen-Space UV from Position

```metal
fragment float4 postprocess(
    float4 position [[position]],
    constant float2 &screenSize [[buffer(0)]],
    texture2d<float> sceneTexture [[texture(0)]]
) {
    float2 uv = position.xy / screenSize;
    return sceneTexture.sample(sampler(filter::linear), uv);
}
```
