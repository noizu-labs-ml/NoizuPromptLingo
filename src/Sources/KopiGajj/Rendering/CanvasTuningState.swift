import SwiftUI
import Combine

/// Observable state for all canvas render engine parameters.
///
/// Wraps a single `CanvasConfig` as the source of truth. SwiftUI views bind
/// directly to nested properties via keypath bindings (e.g., `$tuning.config.background.textureOpacity`).
/// UI-only state (render mode, texture version) lives alongside the config.
final class CanvasTuningState: ObservableObject {

    // MARK: - Config (single source of truth)

    @Published var config: CanvasConfig = .default

    // MARK: - UI-only state (not serialized)

    @Published var simRenderMode: PaintRenderMode = .lit
    @Published var textureVersion: Int = 0

    // MARK: - Texture regen trigger

    private var textureSubs = Set<AnyCancellable>()

    init() {
        // Regenerate texture when background config changes
        $config
            .map(\.background)
            .removeDuplicates()
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.textureVersion += 1 }
            .store(in: &textureSubs)
    }

    // MARK: - Config bridge (now trivial)

    /// Snapshot current state as a serializable config.
    var asConfig: CanvasConfig { config }

    /// Load a config into the live state.
    func apply(_ newConfig: CanvasConfig) {
        config = newConfig
    }

    func resetDefaults() {
        apply(.default)
    }
}
