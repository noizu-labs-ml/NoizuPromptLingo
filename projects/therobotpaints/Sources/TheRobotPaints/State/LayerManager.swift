import Foundation
import Observation

@Observable
final class LayerManager: @unchecked Sendable {
    var activeLayer: Int = 0
    var visibility: UInt8 = 0xFF

    struct LayerInfo: Sendable {
        var name: String = ""
        var mediaType: MediaType = .watercolor
        var hasContent: Bool = false
        var isWet: Bool = false
        var maxDepth: Float = 0
    }

    var layers: [LayerInfo] = (0..<VolumeLayer.layerCount).map { i in
        LayerInfo(name: "Layer \(i + 1)")
    }

    func isVisible(_ index: Int) -> Bool {
        (visibility >> index) & 1 == 1
    }

    func toggleVisibility(_ index: Int) {
        visibility ^= UInt8(1 << index)
    }

    func setActive(_ index: Int) {
        guard index >= 0, index < VolumeLayer.layerCount else { return }
        activeLayer = index
    }

    func clearLayer(_ index: Int) {
        guard index >= 0, index < VolumeLayer.layerCount else { return }
        layers[index].hasContent = false
        layers[index].isWet = false
        layers[index].maxDepth = 0
    }
}

struct LayerState: Sendable {
    var activeLayer: UInt32 = 0
    var visibilityMask: UInt32 = 0xFF
    var _pad0: UInt32 = 0
    var _pad1: UInt32 = 0
}
