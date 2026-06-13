# Image Processing App

Architecture for building a Metal-accelerated image processing application combining Core Image and custom compute kernels.

## Architecture

```
Image Processing App
├── Pipeline
│   ├── ImageSource (file, camera, screen capture)
│   ├── FilterChain (ordered list of filters)
│   │   ├── Core Image Filters (built-in, 200+)
│   │   └── Custom Metal Compute Filters
│   └── Output (display, file export, clipboard)
├── UI
│   ├── Image Canvas (Metal view)
│   ├── Filter Inspector (parameter controls)
│   └── Filter Library (browse/search)
└── Engine
    ├── Core Image Context (GPU-backed)
    ├── Metal Compute Pipeline
    └── Texture Cache
```

## Core Image + Metal Integration

Core Image uses Metal internally. Use `CIContext` with your existing `MTLDevice`:

```swift
let ciContext = CIContext(
    mtlDevice: device,
    options: [
        .workingColorSpace: CGColorSpace(name: CGColorSpace.linearSRGB)!,
        .outputPremultiplied: true,
        .cacheIntermediates: true
    ]
)
```

### Render CIImage to Metal Texture

```swift
func renderToTexture(image: CIImage, texture: MTLTexture) {
    let commandBuffer = commandQueue.makeCommandBuffer()!
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

    ciContext.render(
        image,
        to: texture,
        commandBuffer: commandBuffer,
        bounds: image.extent,
        colorSpace: colorSpace
    )

    commandBuffer.commit()
}
```

## Custom Metal Compute Filters

### Filter Protocol

```swift
protocol MetalFilter {
    var name: String { get }
    var parameters: [FilterParameter] { get set }
    func apply(input: MTLTexture, output: MTLTexture, commandBuffer: MTLCommandBuffer)
}

struct FilterParameter {
    let name: String
    let type: ParameterType
    var value: Any

    enum ParameterType {
        case float(min: Float, max: Float)
        case int(min: Int, max: Int)
        case color
        case bool
    }
}
```

### Example: Gaussian Blur (Separable)

```metal
// Horizontal pass
kernel void blur_horizontal(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    constant float *weights [[buffer(0)]],
    constant int &radius [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= input.get_width() || gid.y >= input.get_height()) return;

    float4 sum = float4(0);
    for (int i = -radius; i <= radius; i++) {
        int2 coord = int2(gid) + int2(i, 0);
        coord.x = clamp(coord.x, 0, int(input.get_width()) - 1);
        sum += input.read(uint2(coord)) * weights[abs(i)];
    }
    output.write(sum, gid);
}

// Vertical pass (same kernel, swap x/y)
kernel void blur_vertical(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    constant float *weights [[buffer(0)]],
    constant int &radius [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= input.get_width() || gid.y >= input.get_height()) return;

    float4 sum = float4(0);
    for (int i = -radius; i <= radius; i++) {
        int2 coord = int2(gid) + int2(0, i);
        coord.y = clamp(coord.y, 0, int(input.get_height()) - 1);
        sum += input.read(uint2(coord)) * weights[abs(i)];
    }
    output.write(sum, gid);
}
```

### Example: Color LUT (Look-Up Table)

```metal
kernel void apply_lut(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    texture3d<float, access::sample> lut [[texture(2)]],
    constant float &intensity [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= input.get_width() || gid.y >= input.get_height()) return;

    float4 color = input.read(gid);
    constexpr sampler s(filter::linear, address::clamp_to_edge);
    float4 graded = lut.sample(s, color.rgb);
    float4 result = mix(color, graded, intensity);
    output.write(float4(result.rgb, color.a), gid);
}
```

## Filter Chain Execution

```swift
class FilterChain {
    var filters: [MetalFilter] = []
    private var pingTexture: MTLTexture?
    private var pongTexture: MTLTexture?

    func process(input: MTLTexture, output: MTLTexture, commandBuffer: MTLCommandBuffer) {
        ensurePingPong(matching: input)

        var current = input
        var target = pingTexture!

        for (index, filter) in filters.enumerated() {
            if index == filters.count - 1 {
                target = output  // Last filter writes to final output
            }
            filter.apply(input: current, output: target, commandBuffer: commandBuffer)
            swap(&current, &target)
        }
    }

    private func ensurePingPong(matching texture: MTLTexture) {
        if pingTexture?.width != texture.width || pingTexture?.height != texture.height {
            let desc = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .rgba16Float,
                width: texture.width,
                height: texture.height,
                mipmapped: false
            )
            desc.usage = [.shaderRead, .shaderWrite]
            desc.storageMode = .private
            pingTexture = texture.device.makeTexture(descriptor: desc)
            pongTexture = texture.device.makeTexture(descriptor: desc)
        }
    }
}
```

## Non-Destructive Editing

Keep the original image; recompute the filter chain on parameter changes:

```swift
class ImageDocument {
    let originalImage: MTLTexture    // Never modified
    var filterChain: FilterChain
    var outputTexture: MTLTexture    // Recomputed on changes

    func reprocess() {
        let commandBuffer = commandQueue.makeCommandBuffer()!
        filterChain.process(input: originalImage, output: outputTexture, commandBuffer: commandBuffer)
        commandBuffer.commit()
    }
}
```

## Real-Time Preview

For interactive parameter adjustment, render at reduced resolution:

```swift
func previewProcess(scale: Float = 0.5) {
    let previewWidth = Int(Float(originalImage.width) * scale)
    let previewHeight = Int(Float(originalImage.height) * scale)

    ensurePreviewTextures(width: previewWidth, height: previewHeight)

    // Downscale original → preview size
    blitDownscale(from: originalImage, to: previewInput)

    // Run filter chain at preview resolution
    filterChain.process(input: previewInput, output: previewOutput, commandBuffer: commandBuffer)

    // Display previewOutput in Metal view
}
```

Full-resolution processing runs when the user finishes adjusting (on mouse-up / slider release).
