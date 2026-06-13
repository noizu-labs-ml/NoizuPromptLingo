# Architecture Decision Records

## ADR-001: Struct Buffer over Texture-Per-Property

**Context:** KopiGajj (sister project) uses separate textures per paint property. We have 8 layers per pixel with 15 fields each.

**Decision:** Single `MTLBuffer` of `VolumeLayer` structs.

**Rationale:** Simpler allocation (one buffer vs 15+ textures x 8 layers). Multi-field kernels (simulation steps that read/write most fields) benefit from locality. Trade-off: single-property sweeps lose GPU texture cache advantages.

**Revisit when:** Profiling shows cache misses dominating a hot kernel. Extract that kernel's fields to a dedicated texture.

## ADR-002: MSL as Swift String Literals

**Context:** SPM cannot compile `.metal` files (Xcode-only feature). Options: Xcode project, embed `.metal` as resources, or inline MSL in Swift strings.

**Decision:** MSL source as Swift string constants, runtime-compiled via `MTLDevice.makeLibrary(source:)`.

**Rationale:** Keeps SPM as sole build system. `MetalShaderCompilationTests` catch MSL syntax errors at test time. Modular split (header + per-kernel) keeps each file manageable.

**Trade-off:** No Xcode syntax highlighting or Metal compiler diagnostics during editing.

## ADR-003: Compute-Only Rendering

**Context:** Paint compositing is a per-pixel operation on a 2D buffer, not geometry rasterization.

**Decision:** Use compute kernels exclusively; no render pipeline (vertex/fragment shaders).

**Rationale:** Compute dispatch is simpler for image-space operations. Avoids vertex buffer management, render pass descriptors, and attachment configuration. Direct write to drawable texture.

## ADR-004: Layer-Major Buffer Layout

**Context:** Layout choices: pixel-major (all 8 layers contiguous per pixel) vs layer-major (all pixels for layer N contiguous).

**Decision:** Layer-major: `buffer[pixelIndex + layer * pixelCount]`.

**Rationale:** Rendering iterates layers back-to-front per pixel -- either layout works. But simulation kernels that operate on one layer (e.g., fluid advection on layer 2) get contiguous memory access with layer-major. Early-out on opaque layers during compositing is unaffected.

## ADR-005: @unchecked Sendable for Metal Objects

**Context:** Swift 6 strict concurrency. Metal objects (`MTLDevice`, `MTLCommandQueue`, etc.) are not inherently `Sendable`.

**Decision:** Mark `MetalEngine` and `Renderer` as `@unchecked Sendable`.

**Rationale:** Metal's command buffer model is thread-safe by design (encode on any thread, commit from any thread). Swift actors would add unnecessary overhead for GPU dispatch patterns. The singleton `MetalEngine` is initialized once and read-only thereafter.
