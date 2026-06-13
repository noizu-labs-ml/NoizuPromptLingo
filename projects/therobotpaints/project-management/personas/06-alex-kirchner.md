# Alex Kirchner — Technical Artist / Shader Developer

**Type:** Secondary  
**Age:** 30 | **Location:** Berlin, Germany  
**Occupation:** Technical artist at VFX studio, side projects in procedural art  
**Platform:** Mac Pro M2 Ultra, multiple displays  

> "I want to fork the simulation. Give me the shader source and let me write my own media type."

## Goals

- Study and modify the paint simulation for custom procedural effects
- Build novel media types (magnetic paint, reactive pigments, non-Newtonian fluids)
- Use the app as a testbed for fluid simulation research
- Integrate custom compute kernels without rebuilding the full app

## Frustrations

- Commercial paint apps are black boxes — can't inspect or modify the simulation
- Writing a paint sim from scratch takes months; wants a working foundation to extend
- Most open-source paint tools (MyPaint, Krita) use CPU-based engines, not GPU compute
- Metal documentation is sparse for non-trivial compute patterns

## Usage Context

- Reads shader source before reading the UI
- Would modify `ShaderHeader.swift` and add new kernel files
- Wants to visualize intermediate simulation state (velocity fields, pressure)
- Cares about struct layout, memory alignment, and dispatch efficiency

## Key Features He'd Use

- MSL source as Swift strings (inspectable, modifiable)
- VolumeLayer struct (extensible data model)
- MetalEngine pipeline compiler (test new kernels quickly)
- Shader compilation tests (catch MSL errors early)

## Design Implications

- Architecture must stay modular: one kernel per file, clean interfaces
- Debug visualization modes (wetness heatmap, velocity arrows, layer depth) are high value
- Plugin or extension point for custom media types
- Documentation of struct layouts, buffer conventions, and dispatch patterns matters
