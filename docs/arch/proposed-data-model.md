# Proposed Data Model

## New Structures

### BrushPoint (32 bytes)

Produced by Catmull-Rom interpolation between raw input samples. Uploaded to GPU for deposition kernel.

| Field | Type | Purpose |
|-------|------|---------|
| position_x/y | Float | Canvas-space coordinate |
| pressure | Float | 0-1, from tablet or simulated |
| tilt_x/y | Float | Stylus tilt (0 for mouse) |
| size | Float | Brush radius at this point |
| timestamp | Float | Monotonic time for velocity calc |
| _padding | Float | Alignment to 32 bytes |

### BrushParams (64 bytes)

Active brush configuration. Passed as shader constant to deposition kernel.

| Field | Type | Purpose |
|-------|------|---------|
| size | Float | Base radius (pixels) |
| opacity | Float | 0-1 stroke opacity |
| flow | Float | 0-1 paint flow rate |
| hardness | Float | 0-1 edge falloff |
| mediaType | UInt32 | Enum: watercolor, oil, acrylic, charcoal, pastel |
| shapeType | UInt32 | Enum: round, flat, fan |
| color_r/g/b/o | half4 | Absorption color |
| angle | Float | Brush rotation |
| spacing | Float | Stamp spacing (fraction of size) |
| scatter | Float | Random offset per stamp |
| _padding | 12B | Alignment to 64 bytes |

### SPHParticle (48 bytes)

Lagrangian particle for fluid dynamics. Managed in a GPU buffer with a free-list.

| Field | Type | Purpose |
|-------|------|---------|
| position_x/y | Float | Canvas-space position |
| velocity_x/y | Float | Current velocity |
| color_rgba | half4 | Absorption color |
| radius | half | Influence radius |
| mass | half | Particle mass |
| local_density | half | Computed each frame |
| rest_density | half | Target density |
| viscosity | half | Resistance to flow |
| smoothing_length | half | SPH kernel width |
| wetness | half | Current moisture |
| life | half | Remaining lifetime (retires when dry) |
| layer_index | UInt8 | Which volume layer |
| flags | UInt8 | State bits |
| _padding | UInt16 | Alignment to 48 bytes |

### SpatialHashCell (8 bytes)

For SPH neighbor search. Grid of cells covering canvas, each storing offset + count into sorted particle array.

| Field | Type | Purpose |
|-------|------|---------|
| offset | UInt32 | Start index in sorted particle array |
| count | UInt32 | Number of particles in cell |

### StrokeRecord (variable)

CPU-side undo unit. Not uploaded to GPU.

```swift
struct StrokeRecord {
    let brushParams: BrushParams
    let points: [BrushPoint]
    let targetLayer: Int
    let volumeSnapshot: Data?  // optional pre-stroke state for undo
}
```

### CanvasPreset

Named paper type configurations.

```swift
struct CanvasPreset: Codable {
    let name: String           // "Arches Cold Press", "Fabriano Hot Press"
    let absorbency: Float      // 0-1
    let roughness: Float       // 0-1
    let porosity: Float        // 0-1
    let sizing: Float          // 0-1
    let noiseFrequency: Float  // Weave pattern scale
    let noiseAmplitude: Float  // Weave pattern intensity
}
```

## Memory Budget (Proposed, 1080p / 2048x1536)

| Component | Size | Notes |
|-----------|------|-------|
| Volume layers (8 × 32B) | ~563 MB | Existing |
| Canvas props texture | ~24 MB | Existing |
| SPH particles (500K max) | ~24 MB | New |
| Spatial hash grid | ~3 MB | New |
| Ping-pong textures (2 × rgba16Float) | ~48 MB | New |
| Brush point buffer (4K points) | ~128 KB | New |
| Render targets + debug textures | ~48 MB | Extended |
| Undo stack (10 stroke snapshots) | ~5.5 GB worst case | CPU-side, lazy |
| **GPU total** | **~710 MB** | |

4K (4096×3072): ~2.8 GB GPU. Undo snapshots are the dominant memory concern — use lazy delta snapshots (only store modified regions) to keep practical cost under 500 MB.

## File Format (.trp)

```
[Header: 64 bytes]
  magic: "TRP1"           (4B)
  version: UInt32          (4B)
  canvasWidth: UInt32      (4B)
  canvasHeight: UInt32     (4B)
  layerCount: UInt32       (4B)
  canvasPresetHash: UInt32 (4B)
  metadataOffset: UInt64   (8B)
  reserved: 32B

[Volume Layer Data: width * height * 8 * 32 bytes]
  Raw VolumeLayer buffer, layer-major order

[Canvas Props Data: width * height * 8 bytes]
  Raw rgba16Float texture data

[Metadata: JSON]
  Canvas preset name, brush presets used, creation date, layer names
```
