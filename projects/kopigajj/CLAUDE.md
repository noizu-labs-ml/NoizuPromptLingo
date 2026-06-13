# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**KopiGajj** is a macOS menu-bar app built with Swift 5.9 + SwiftUI + Metal. It started as a clipboard manager but has pivoted to a **GPU-accelerated paint simulation and canvas render engine**. The app runs as a background accessory (`.accessory` activation policy) with a global hotkey (Cmd+Shift+T) that opens a floating tuning window.

**Current stage:** 0.5 — Canvas Render Engine (v0.2.0)
**Platform:** macOS 14+ only (Sonoma)
**Bundle ID:** `com.keithbrings.KopiGajj`

---

## Build & Run

| Goal | Command | Notes |
|------|---------|-------|
| Build (SPM) | `cd src && swift build` | Compiles Swift only; Metal shaders are runtime-compiled |
| Build app bundle | `./build-app.sh` | Runs `swift build`, creates `build/KopiGajj.app` with Info.plist |
| Run app bundle | `open build/KopiGajj.app` | Requires Accessibility permissions for global hotkey |
| Run executable directly | `src/.build/debug/KopiGajj` | Same permissions requirement |

**No test target exists yet.** `swift test` will fail — there are no test targets in `Package.swift`.

**Version** is defined in `src/Sources/KopiGajj/Version.swift` — single source of truth, also read by `build-app.sh` via grep.

---

## Architecture

### App Lifecycle

```
main.swift → NSApplication → AppDelegate
  ├── HotkeyManager     — CGEventTap for Cmd+Shift+T (blocks event from other apps)
  ├── PopupWindowManager — NSWindow (floating, .titled) hosting CanvasTuningView
  ├── MenuBarManager     — NSStatusItem with dropdown (Show/About/Quit)
  └── RenderingBootstrap — Pre-warms Metal pipeline + canvas texture at launch
```

`AppDelegate` sets `NSApp.setActivationPolicy(.accessory)` — the app has no dock icon, only a menu bar item.

### Rendering Pipeline (Metal Compute)

The core rendering system has two independent Metal pipelines:

**1. Paint Simulation** (`PaintSimulator`) — physically-based paint on canvas:
- 5 GPU kernels: `canvasInit` → `brushStroke` → `flowStep` → `dryStep` → `paintRender`
- Three-layer architecture: Canvas (height+material) → Solid (dried paint) → Wet (active, double-buffered)
- `PaintField` owns all GPU textures (8 total: wet absorb A/B, solid absorb, props A/B, height, canvas props, output)
- Supports 4 brush media (oil/watercolor/acrylic/pastel) and 5 tip types (round/flat/filbert/fan/knife)

**2. Image Filters** (`CanvasMetalRenderer`) — artistic post-processing:
- 8 GPU kernels: Kuwahara, Anisotropic Kuwahara, Pointillize, Watercolor, Oil Paint, Posterize, Bilateral, Voronoi Mosaic
- Oil Paint uses multi-pass ping-pong rendering
- Singleton (`CanvasMetalRenderer.shared`)

**Critical: Shaders are runtime-compiled from Swift string literals** in `PaintShaderSource`, not from `.metal` files. The `Package.swift` excludes `Rendering/Shaders/` from SPM — that directory is for Xcode-only `.metal` files if any exist.

### Metal Protocols

Two protocols extract reusable Metal boilerplate:
- `MetalShaderCompiler` — compiles MSL source strings into `MTLComputePipelineState`
- `MetalTextureFactory` — creates `MTLTexture` with common configurations

Both `PaintSimulator` and `CanvasMetalRenderer` conform to these.

### Configuration System

`CanvasConfig` is a `Codable` struct composed of 4 sub-configs:
- `BackgroundConfig` — canvas texture, impasto marks, wash opacity
- `StrokeCardConfig` — card appearance, jagged edges, shadows
- `PaintSimConfig` — simulation parameters (flow, dry, lighting, media multipliers)
- `FilterConfig` — which filter, radius, extra params

**Flat JSON encoding** — despite the nested Swift structs, JSON keys are flat (no nesting) for backward compatibility with saved theme files. Custom `init(from:)` tolerates missing keys by falling back to defaults.

Themes are saved as JSON in `~/.config/kopigajj/themes/`. Stroke history in `~/.config/kopigajj/paint-state/`.

### UI Architecture (SwiftUI)

```
CanvasTuningView          — Main split view (left: preview/paint, right: sliders)
  ├── CanvasPreviewPane    — Rendered canvas preview
  ├── PaintCanvasView      — Interactive painting (wraps PaintCanvasNSView)
  ├── CanvasTuningSliders  — Parameter sliders grouped by sub-config
  ├── CanvasPaintSimPane   — Paint simulation controls & multi-mode preview
  ├── CanvasConfigManager  — Theme picker, save/load/delete
  └── TunableSlider        — Reusable slider with reset-to-baseline
```

State management:
- `CanvasTuningState` (ObservableObject) — wraps `CanvasConfig` as single source of truth, plus UI-only state
- `PaintCanvasState` (ObservableObject) — brush settings, sim controls, time simulation for interactive painting

### GPU Struct Alignment

`BrushPoint` must be exactly 56 bytes and match the Metal `BrushPoint` layout field-for-field. If you add/remove/reorder fields, update both the Swift struct in `PaintField.swift` and the Metal struct in `PaintShaderSource.header`.

---

## Key Conventions

- **Runtime shader compilation:** All Metal shaders live as Swift string literals in `PaintShaderSource`. To add a new kernel, add the MSL source there and register the function name in the appropriate renderer.
- **Absorption color model:** Paint uses absorption values (0 = transparent, higher = more opaque), not reflectance RGB. This is physically correct for subtractive pigment mixing.
- **Double-buffering:** Wet layer textures ping-pong via `PaintField.flip()`. Always read from `readWetAbsorb`/`readProps` and write to `writeWetAbsorb`/`writeProps`.
- **Config uses `Double`, Metal uses `Float`:** Config sub-structs use `Double` for SwiftUI binding compatibility. Convert to `Float` at the Metal API boundary.
- **Temp files:** Use `.tmp/` (project-scoped), not `/tmp/`.

---

## Subagent Delegation

**Default behavior:** Prefer dispatching work to `npl-foreman` (background) or specialized subagents (`npl-tasker-*`, `Explore`, etc.) rather than blocking the main thread — unless the task is trivial (< 1 tool call) or requires immediate back-and-forth with the user.

### `@subagents` flag

The user can set delegation policy anywhere in a message. **Latest occurrence wins** — scan the full conversation and apply the most recent value.

| Flag | Behavior |
|------|----------|
| `@subagents=auto` | **(default when no flag present)** Use judgment. Prefer subagents for multi-step, multi-file, or research-heavy work. Handle simple single-file edits or quick lookups on the main thread. |
| `@subagents=always` | Route **every** task through foreman or subagents, even trivial ones. Main thread only relays results and asks clarifying questions. |
| `@subagents=ask` | Before delegating, confirm with the user: describe what you'd send to a subagent and ask approval. If denied, execute on main thread. |
| `@subagents=avoid` | Stay on the main thread unless a task is clearly too large (5+ files, deep research). If you do delegate, explain why. |
| `@subagents=never` | All work on main thread. Do not spawn any subagents. |

### Delegation guidelines

- **Foreman first:** For multi-step implementation or refactoring, launch `npl-foreman` in the background. It self-loads context and can request tasker dispatch.
- **Taskers for parallel lookups:** Use `npl-tasker-haiku` for simple greps/reads, `npl-tasker-sonnet` for moderate analysis, `npl-tasker-opus` for architectural review.
- **Explore for codebase questions:** When the user asks "how does X work" or "find all uses of Y", dispatch an `Explore` agent rather than running 10 greps on the main thread.
- **Stay on main thread for:** Single-file edits, quick answers from memory, config changes, git operations, and anything where subagent round-trip latency would be slower than just doing it.
- **Always relay results:** The user cannot see subagent output directly. Summarize findings or confirm completion in the main thread response.

---

## User Data Locations

| Data | Path |
|------|------|
| Theme configs | `~/.config/kopigajj/themes/*.json` |
| Stroke history | `~/.config/kopigajj/paint-state/*.json` |

---

## Response Protocol

### Assumptions Table

Open every response with a markdown table of assumptions (columns: open question, assumption, consequence).

### Reflection Block

End every response with:

```
<pb-block type="reflection">
[one issue per line, emoji prefix, < 80 chars each]
</pb-block>
```

Emoji indicators: `✅` Verified, `🐛` Bug, `🔒` Security, `⚠️` Pitfall, `🚀` Improvement, `🧩` Edge Case, `📝` TODO, `🔄` Refactor, `❓` Question. Always include at least one `✅`.
