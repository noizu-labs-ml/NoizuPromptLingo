import Foundation

/// One-shot rendering pre-warm called during app launch.
///
/// Eagerly initialises the canvas texture and Metal compute pipeline so the
/// first popup open doesn't pay the ~5-10 ms setup cost.
enum RenderingBootstrap {

    /// Pre-warm canvas texture and Metal renderer.  Safe to call more than
    /// once (subsequent calls are no-ops inside the singletons).
    static func prewarm() {
        // Canvas texture (~5-10 ms, avoids hitch on first popup)
        _ = CanvasTextureGenerator.shared.texture()

        // Metal compute pipeline (compiles shader source at runtime)
        _ = CanvasMetalRenderer.shared
    }
}
