# GPU Capture Guide

Step-by-step workflow for capturing and analyzing Metal GPU frames in Xcode.

## Setup

### Enable GPU Frame Capture

1. **Xcode Scheme Settings:** Product → Scheme → Edit Scheme → Run → Options
2. Set "GPU Frame Capture" to **Metal**
3. Set "Metal API Validation" to **Enabled** (catches API errors)

### Environment Variables (Debug scheme)

| Variable | Value | Purpose |
|---|---|---|
| `MTL_DEBUG_LAYER` | `1` | Enable Metal debug layer |
| `MTL_SHADER_VALIDATION` | `1` | Validate shader execution (slower, catches more bugs) |
| `GPU_FRAME_CAPTURE_BACKEND` | `1` | Enable programmatic capture |

## Capture Methods

### Method 1: Xcode UI

1. Run app in Debug mode
2. Navigate to the frame you want to capture
3. Click the camera icon in Xcode's debug bar (or Debug → Capture GPU Workload)
4. Wait for capture to complete — app pauses

### Method 2: Programmatic Capture

```swift
func captureFrame() {
    let captureManager = MTLCaptureManager.shared()
    let captureDescriptor = MTLCaptureDescriptor()
    captureDescriptor.captureObject = device
    captureDescriptor.destination = .developerTools  // Send to Xcode
    // Or: .gpuTraceDocument for saving to file

    do {
        try captureManager.startCapture(with: captureDescriptor)
    } catch {
        print("Capture failed: \(error)")
    }

    // Render the frame you want to capture...
    renderOneFrame()

    captureManager.stopCapture()
}
```

### Method 3: Metal System Trace (Instruments)

For multi-frame analysis (frame pacing, CPU/GPU overlap):
1. Open Instruments (Product → Profile or Cmd+I)
2. Choose "Metal System Trace" template
3. Record for a few seconds
4. Analyze timeline for gaps, stalls, and bottleneck patterns

## Reading the GPU Capture

### Overview Tab

- **Summary bar:** Total GPU time, encoder count, draw/dispatch count
- **Performance Issues:** Xcode flags common problems automatically

### Timeline View

```
Command Buffer
├── Render Encoder 1 (Shadow Pass)     [████████░░]  2.1ms
├── Compute Encoder (SSAO)             [███░░░░░░░]  0.8ms
├── Render Encoder 2 (Main Pass)       [████████████████]  4.2ms
└── Render Encoder 3 (Post-Process)    [██░░░░░░░░]  0.5ms
                                        Total: 7.6ms
```

Look for:
- **Gaps between encoders** → CPU bottleneck (CPU isn't feeding GPU fast enough)
- **One encoder dominates** → Shader bottleneck in that pass
- **All encoders proportional** → Bandwidth or fill-rate limited

### Per-Encoder Analysis

Click an encoder to see:
- **Draw calls** — count, primitive type, vertex count
- **State changes** — pipeline switches, buffer binds, texture binds
- **Shader statistics** — instruction count, register usage, occupancy

### Shader Profiler

Double-click a draw call → Shader Profiler:
- **Per-line cost** — cycle count per MSL line
- **Bottleneck type** — ALU, memory, synchronization
- **Occupancy** — how many threads the GPU can run simultaneously

## Diagnostic Flowchart

```
Start: Frame time > budget (16.6ms for 60fps)
│
├── Is GPU time < CPU time?
│   ├── YES → CPU bottleneck
│   │   ├── Too many draw calls? → Batch, instance, use ICBs
│   │   ├── Pipeline state creation in render loop? → Cache at init
│   │   └── Complex scene graph traversal? → Optimize data structures
│   │
│   └── NO → GPU bottleneck
│       ├── Vertex-bound? (vertex shader time dominant)
│       │   ├── Too many vertices? → LOD, culling
│       │   └── Complex vertex shader? → Simplify, move to compute
│       │
│       ├── Fragment-bound? (fragment shader time dominant)
│       │   ├── Overdraw? → Sort front-to-back for opaque, reduce transparency
│       │   ├── Texture-heavy? → Smaller textures, fewer samples, mipmaps
│       │   └── Complex fragment math? → Simplify, use lookup textures
│       │
│       ├── Bandwidth-bound? (high memory throughput)
│       │   ├── Large textures? → Compress (ASTC/BC), use mipmaps
│       │   ├── Uncompressed render targets? → Use memoryless where possible
│       │   └── Random access patterns? → Improve locality
│       │
│       └── Compute-bound? (compute encoder time dominant)
│           ├── Threadgroup too large? → Query maxTotalThreadsPerThreadgroup
│           ├── Low occupancy? → Reduce register pressure
│           └── Shared memory bottleneck? → Reduce bank conflicts
```

## Common Issues and Fixes

### Black Screen

1. Check render pass descriptor — is the drawable texture attached?
2. Check clear color — are you clearing to black and not drawing?
3. Check vertex positions — are they in NDC range (-1 to 1)?
4. Check pipeline state — does the pixel format match?
5. Check `present(drawable)` and `commit()` are called

### Flickering

1. Missing triple buffering — CPU overwriting buffer GPU is reading
2. Missing depth test — z-fighting between overlapping surfaces
3. Race condition in multi-threaded rendering

### Validation Errors

```
MTLDebugRenderCommandEncoder: Fragment function fragment_main has
texture binding at index 0 which does not have a valid texture bound.
```

Fix: Ensure all textures referenced by the shader are bound before drawing.

## Performance Counters (Metal 3+)

```swift
let counterSets = device.counterSets
// Available: timestamp, stageUtilization, statisticSet

let counterBuffer = device.makeCounterSampleBuffer(
    descriptor: MTLCounterSampleBufferDescriptor()
)

renderEncoder.sampleCounters(
    sampleBuffer: counterBuffer!,
    sampleIndex: 0,
    barrier: true
)
```

Read counters after GPU completion for per-encoder performance data.
