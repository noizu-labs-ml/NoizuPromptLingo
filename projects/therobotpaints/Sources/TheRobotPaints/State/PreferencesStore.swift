import SwiftUI

final class PreferencesStore: @unchecked Sendable {
    @AppStorage("simpleMode") var simpleMode = false
    @AppStorage("simulationQuality") var simulationHalfRate = false
    @AppStorage("backgroundColor") var backgroundColorHex = "333333"
    @AppStorage("maxParticles") var maxParticles = 500_000
    @AppStorage("autoSaveInterval") var autoSaveInterval = 300
    @AppStorage("pressureGamma") var pressureGamma: Double = 1.5
    @AppStorage("mouseMaxSpeed") var mouseMaxSpeed: Double = 1500.0
}
