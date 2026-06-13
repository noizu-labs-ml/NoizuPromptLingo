# Proposed Input Architecture

## Event Flow

```
NSEvent (from CanvasMTKView)
  → InputRouter.handle(event:)
    → Tool dispatch:
        Brush/Eraser → BrushEngine.addPoint()
        Pan          → ViewportController.pan()
        Zoom         → ViewportController.zoom()
        Rotate       → ViewportController.rotate()
        Eyedropper   → ColorEngine.sample(at:)
```

## InputRouter

Maintains the active tool state. Tool selection via toolbar click or keyboard shortcut (US-036):

| Key | Tool | Behavior |
|-----|------|----------|
| B | Brush | Paint with current media |
| E | Eraser | Remove paint from active layer |
| K | Palette knife | Smudge/push existing paint |
| I | Eyedropper | Sample color from canvas |
| H | Pan (hand) | Scroll canvas |
| Z | Zoom | Click-zoom in, Alt-click zoom out |
| R | Rotate | Drag to rotate canvas |

Modifier overrides: Space+drag → Pan (any tool), Alt+click → Eyedropper (any tool), Cmd+Z → Undo.

## BrushEngine

### Stroke Lifecycle

```
mouseDown → startStroke(point, pressure)
  - Create new StrokeRecord
  - Snapshot affected region (for undo)
  - Set stroke active

mouseDragged → addPoint(point, pressure)
  - Catmull-Rom interpolation between last 4 raw points
  - Generate BrushPoint samples at spacing intervals
  - Append to frame's BrushPoint buffer

mouseUp → endStroke()
  - Flush remaining interpolation points
  - Push StrokeRecord to UndoManager
  - Mark stroke inactive
```

### Catmull-Rom Interpolation (US-023)

Maintains a sliding window of the last 4 raw input points. For each new point:
1. Compute Catmull-Rom spline through points [P0, P1, P2, P3]
2. Walk the spline from P1 to P2 at `spacing × brushSize` intervals
3. At each step, interpolate pressure, tilt, and timestamp
4. Emit a `BrushPoint` struct

This produces smooth curves even from coarse mouse input (typically 120-240 Hz).

### Pressure Sources (US-021, 022)

```swift
protocol PressureSource {
    func pressure(for event: NSEvent) -> Float
}
```

| Source | Implementation | Notes |
|--------|---------------|-------|
| Tablet | `event.pressure` directly | 0-1 from Wacom/Apple Pencil |
| Mouse | `1.0 - clamp(speed / maxSpeed, 0, 0.9)` | Slow = heavy, fast = light |
| Trackpad | `event.stage` (force touch) | Only on Force Touch trackpads |

Detection is automatic: if `event.pressure` is non-zero on first `mouseDown`, use tablet. Otherwise fall back to speed-based.

### Brush Shapes (US-030–032)

| Shape | Stamp Pattern | Key Parameters |
|-------|--------------|----------------|
| Round (soft) | Gaussian falloff from center | hardness (0 = very soft) |
| Round (hard) | Step function at radius | hardness (1 = sharp edge) |
| Flat | Oriented rectangle, pressure thins width | angle, aspect ratio |
| Fan | Multiple thin lines radiating from center | bristle count, splay |
| Dry brush | Round with stochastic holes (noise mask) | density, roughness |

## ViewportController

Extracted from current `Renderer` zoom/pan logic. Manages:

- Zoom level (0.1× to 32×), anchored to cursor
- Pan offset (canvas-space)
- Rotation angle (US-015), with 15° snap when holding Shift
- Mirror state (US-016), horizontal/vertical flip flags applied in ViewParams

All state encoded in `ViewParams` struct passed to render kernel.

## 3D Mouse Support (US-040)

SpaceMouse events mapped via IOKit HID:
- Translation X/Y → pan
- Translation Z → zoom
- Rotation (ignored for 2D canvas, reserved for future 3D view)

Operates independently of active tool — always controls viewport, never brush.

## Latency Budget (US-039)

```
Input event → render pixel: < 16ms total

Breakdown:
  NSEvent delivery:     ~1-2ms
  Interpolation:        ~0.1ms (CPU)
  Buffer upload:        ~0.1ms (shared memory, no blit)
  Deposition kernel:    ~1-2ms (GPU)
  Render kernel:        ~4-8ms (GPU)
  Present + vsync:      ~0-8ms (wait for next refresh)
```

Key: upload BrushPoint buffer as `storageModeShared` — no GPU blit needed on Apple Silicon. Deposition and render run in the same command buffer — no inter-frame delay.
