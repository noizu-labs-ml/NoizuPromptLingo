# The Robot Paints

A physics-based paint simulator for macOS using Metal.

## Building

### Using Swift Package Manager

```bash
swift build
swift run
```

### Using Xcode (Recommended)

```bash
swift package generate-xcodeproj
open TheRobotPaints.xcodeproj
```

## Requirements

- macOS 14.0+
- Xcode 16+ (for Metal development)
- Apple Silicon recommended (unified memory architecture)

## Project Status

**Phase: Foundation**

- ✅ Swift package scaffold
- ✅ SwiftUI basic app
- ✅ Blank window rendering
- ⏳ Metal rendering context (next steps)
- ⏳ Compute shader pipeline (next steps)

## Development Roadmap

See `docs/planning.md` for detailed implementation plan.

## Quick Start

1. Clone repository
2. Run `swift build`
3. Run `swift run` to launch app
4. You'll see a blank black window with title text

## Next Steps

1. Set up Xcode project for easier Metal development
2. Add MetalKit view to main window
3. Create basic Metal device and command queue
4. Write first compute shader
5. Implement basic render pipeline

## Hardware Requirements

**Minimum**: M1 or Intel Mac with Metal support
**Recommended**: M2+ for optimal GPU performance
**Optimal**: M3 Max/Pro for high-resolution canvas simulation