import Foundation
import AVFoundation
import CoreAudio

/// Routes live microphone audio into virtual mic devices.
///
/// The `Recording` device is always fed while the app is listening. Assistant routing is
/// exclusive: opening Claude/Codex/Llama tears down any previously-open assistant target,
/// so only one assistant device carries audio at a time.
///
/// Buffers are pushed in from the speech engine's input tap via `forward(_:)`, which runs
/// on the audio render thread. `open`/`close`/`closeAll` are expected on the main thread.
final class VirtualMicRouter: @unchecked Sendable {
    private let lock = NSLock()
    private let alwaysOnTargets: Set<MicTarget> = [.recording]

    private struct Route {
        var engine: AVAudioEngine
        var player: AVAudioPlayerNode
        var format: AVAudioFormat
    }

    // Guarded by `lock`.
    private var activeTarget: MicTarget?
    private var routes: [MicTarget: Route] = [:]
    private var rebuildsInFlight: Set<MicTarget> = []

    /// The currently-open virtual mic, or nil if all are muted.
    var openTarget: MicTarget? {
        lock.lock(); defer { lock.unlock() }
        return activeTarget
    }

    /// Open (and exclusively route audio to) a virtual mic.
    /// - Parameter inputFormat: the live mic format, used to build the render graph.
    @MainActor
    func open(_ target: MicTarget, inputFormat: AVAudioFormat?) {
        guard target.isExternalAssistant else { return }

        lock.lock()
        if activeTarget == target, routes[target]?.engine.isRunning == true {
            lock.unlock()
            return
        }
        teardownExternalRoutesLocked()
        activeTarget = target
        lock.unlock()

        if let inputFormat {
            buildEngine(for: target, format: inputFormat)
        }
    }

    /// Mute a virtual mic if it is the one currently open.
    @MainActor
    func close(_ target: MicTarget) {
        guard target.isExternalAssistant else { return }

        lock.lock()
        if activeTarget == target {
            teardownLocked(target)
            activeTarget = nil
        }
        lock.unlock()
    }

    /// Mute everything and tear down the render graph.
    @MainActor
    func closeAll() {
        lock.lock()
        teardownAllLocked()
        activeTarget = nil
        lock.unlock()
    }

    /// Push a freshly-captured mic buffer toward the open device. Audio-thread safe.
    func forward(_ buffer: AVAudioPCMBuffer) {
        lock.lock()
        var wantedTargets = alwaysOnTargets
        if let activeTarget {
            wantedTargets.insert(activeTarget)
        }

        var players: [AVAudioPlayerNode] = []
        var rebuildTargets: [MicTarget] = []

        for target in wantedTargets {
            guard let route = routes[target] else {
                rebuildTargets.append(target)
                continue
            }
            if !formatsMatch(route.format, buffer.format) || !route.engine.isRunning {
                rebuildTargets.append(target)
                continue
            }
            players.append(route.player)
        }
        lock.unlock()

        // Engine missing, stopped, or input format changed: rebuild on the main thread.
        for target in rebuildTargets {
            scheduleRebuild(for: target, format: buffer.format)
        }

        for player in players {
            guard let copy = buffer.deepCopy() else { continue }
            player.scheduleBuffer(copy, completionHandler: nil)
        }
    }

    // MARK: - Engine lifecycle (main thread)

    @MainActor
    private func buildEngine(for target: MicTarget, format: AVAudioFormat) {
        guard let deviceID = AudioDeviceLookup.deviceID(named: target.deviceName) else {
            log("virtual mic device \"\(target.deviceName)\" not found — is the RobotAudio driver installed?")
            return
        }
        guard AudioDeviceLookup.hasOutputStreams(deviceID) else {
            log("virtual mic \"\(target.deviceName)\" has no output stream to render into")
            return
        }

        let newEngine = AVAudioEngine()

        // Point the engine's output at the virtual device.
        if let outputAU = newEngine.outputNode.audioUnit {
            var dev = deviceID
            let status = AudioUnitSetProperty(
                outputAU,
                kAudioOutputUnitProperty_CurrentDevice,
                kAudioUnitScope_Global,
                0,
                &dev,
                UInt32(MemoryLayout<AudioDeviceID>.size)
            )
            if status != noErr {
                log("failed to bind engine output to \"\(target.deviceName)\" (\(status))")
                return
            }
        } else {
            log("output audio unit unavailable for \"\(target.deviceName)\"")
            return
        }

        let newPlayer = AVAudioPlayerNode()
        newEngine.attach(newPlayer)
        // Connect through the main mixer so the engine inserts any needed sample-rate /
        // channel-count conversion between the mic format and the device format.
        newEngine.connect(newPlayer, to: newEngine.mainMixerNode, format: format)

        do {
            newEngine.prepare()
            try newEngine.start()
            newPlayer.play()
        } catch {
            log("failed to start virtual-mic engine for \"\(target.deviceName)\": \(error.localizedDescription)")
            return
        }

        lock.lock()
        // Only adopt this engine if the target is still the one we want.
        if isWantedLocked(target) {
            routes[target] = Route(engine: newEngine, player: newPlayer, format: format)
        } else {
            newEngine.stop()
        }
        lock.unlock()
        log("routing mic → \"\(target.deviceName)\"")
    }

    @MainActor
    private func teardownLocked(_ target: MicTarget) {
        // Caller holds `lock`.
        if let route = routes.removeValue(forKey: target) {
            route.player.stop()
            route.engine.stop()
        }
    }

    @MainActor
    private func teardownExternalRoutesLocked() {
        // Caller holds `lock`.
        for target in routes.keys where target.isExternalAssistant {
            if let route = routes.removeValue(forKey: target) {
                route.player.stop()
                route.engine.stop()
            }
        }
    }

    @MainActor
    private func teardownAllLocked() {
        // Caller holds `lock`.
        for route in routes.values {
            route.player.stop()
            route.engine.stop()
        }
        routes.removeAll()
    }

    private func isWantedLocked(_ target: MicTarget) -> Bool {
        // Caller holds `lock`.
        alwaysOnTargets.contains(target) || activeTarget == target
    }

    private func scheduleRebuild(for target: MicTarget, format: AVAudioFormat) {
        lock.lock()
        if rebuildsInFlight.contains(target) {
            lock.unlock()
            return
        }
        rebuildsInFlight.insert(target)
        lock.unlock()

        Task { @MainActor in
            defer {
                self.lock.withLock {
                    _ = self.rebuildsInFlight.remove(target)
                }
            }
            // Still wanted? Rebuild against the new format.
            guard self.lock.withLock({ self.isWantedLocked(target) }) else { return }
            self.lock.withLock {
                self.teardownLocked(target)
            }
            self.buildEngine(for: target, format: format)
        }
    }

    private func formatsMatch(_ a: AVAudioFormat, _ b: AVAudioFormat) -> Bool {
        a.sampleRate == b.sampleRate
            && a.channelCount == b.channelCount
            && a.commonFormat == b.commonFormat
    }

    private func log(_ message: String) {
        fputs("virtual-mic: \(message)\n", stderr)
    }
}

extension AVAudioPCMBuffer {
    /// Deep copy so the buffer can outlive the tap callback (which reuses its storage).
    func deepCopy() -> AVAudioPCMBuffer? {
        guard let copy = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else {
            return nil
        }
        copy.frameLength = frameLength
        let channels = Int(format.channelCount)
        let frames = Int(frameLength)

        if let src = floatChannelData, let dst = copy.floatChannelData {
            for ch in 0..<channels {
                dst[ch].update(from: src[ch], count: frames)
            }
            return copy
        }
        if let src = int16ChannelData, let dst = copy.int16ChannelData {
            for ch in 0..<channels {
                dst[ch].update(from: src[ch], count: frames)
            }
            return copy
        }
        if let src = int32ChannelData, let dst = copy.int32ChannelData {
            for ch in 0..<channels {
                dst[ch].update(from: src[ch], count: frames)
            }
            return copy
        }
        return nil
    }
}
