import Foundation
import AVFoundation
import AudioToolbox
import CoreAudio
import Speech

enum SpeechEngineStartResult: Sendable {
    case started(String)
    case alreadyRunning
    case failed(String)
}

protocol SpeechEngineDelegate: AnyObject, Sendable {
    @MainActor func speechEngine(_ engine: SpeechEngine, didReceivePartial text: String)
    @MainActor func speechEngine(_ engine: SpeechEngine, didFinalize text: String)
    @MainActor func speechEngine(_ engine: SpeechEngine, didReceiveRecognitionError message: String)
}

final class SpeechEngine: @unchecked Sendable {
    private let audioEngine = AVAudioEngine()
    private let recognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var restartTimer: Timer?
    private var tapInstalled: Bool = false
    private let onDevice: Bool
    private let inputDeviceId: String?
    private let verbose: Bool
    private var didReportFirstRecognitionCallback: Bool = false
    private(set) var isRunning: Bool = false

    weak var delegate: SpeechEngineDelegate?

    init(locale: String = "en-US", onDevice: Bool = true, inputDeviceId: String? = nil, verbose: Bool = false) {
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale))!
        self.onDevice = onDevice
        self.inputDeviceId = inputDeviceId
        self.verbose = verbose
    }

    @discardableResult
    func start() -> SpeechEngineStartResult {
        guard !isRunning else { return .alreadyRunning }
        isRunning = true
        do {
            let inputDescription = try startRecognition()
            return .started(inputDescription)
        } catch {
            isRunning = false
            cleanupAudio()
            let message = error.localizedDescription
            fputs("error: failed to start audio: \(message)\n", stderr)
            return .failed(message)
        }
    }

    func stop() {
        isRunning = false
        cleanupAudio()
    }

    private func startRecognition() throws -> String {
        cleanupAudio(keepRunning: true)

        let inputNode = audioEngine.inputNode
        let inputDescription = try configureInputDeviceIfNeeded(on: inputNode)
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = onDevice
        self.recognitionRequest = request

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if !self.didReportFirstRecognitionCallback {
                self.didReportFirstRecognitionCallback = true
                Task { @MainActor [weak self] in
                    guard let self, self.isRunning else { return }
                    self.delegate?.speechEngine(self, didReceiveRecognitionError: "Speech recognizer callback received")
                }
            }

            if let result {
                let transcript = result.bestTranscription.formattedString
                let isFinal = result.isFinal

                if self.verbose {
                    fputs("  [partial] \(transcript.lowercased())\n", stderr)
                }

                Task { @MainActor [weak self] in
                    guard let self, self.isRunning else { return }
                    if isFinal {
                        self.delegate?.speechEngine(self, didFinalize: transcript)
                    } else {
                        self.delegate?.speechEngine(self, didReceivePartial: transcript)
                    }
                }
            }

            if let error {
                let message = error.localizedDescription
                Task { @MainActor [weak self] in
                    guard let self, self.isRunning else { return }
                    self.delegate?.speechEngine(self, didReceiveRecognitionError: message)
                    self.stop()
                }
            }

            if error == nil, result?.isFinal ?? false {
                Task { @MainActor [weak self] in
                    guard let self, self.isRunning else { return }
                    self.scheduleRestart()
                }
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        tapInstalled = true

        audioEngine.prepare()
        try audioEngine.start()
        return "\(inputDescription), \(Int(recordingFormat.sampleRate)) Hz, \(Int(recordingFormat.channelCount)) channel(s)"
    }

    private func scheduleRestart() {
        restartTimer?.invalidate()
        restartTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.restart()
            }
        }
    }

    private func restart() {
        guard isRunning else { return }
        cleanupAudio(keepRunning: true)

        do {
            _ = try startRecognition()
        } catch {
            fputs("error: failed to restart: \(error.localizedDescription)\n", stderr)
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    self?.restart()
                }
            }
        }
    }

    private func cleanupAudio(keepRunning: Bool = false) {
        restartTimer?.invalidate()
        restartTimer = nil
        audioEngine.stop()
        if tapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        if !keepRunning {
            isRunning = false
        }
    }

    private func configureInputDeviceIfNeeded(on inputNode: AVAudioInputNode) throws -> String {
        guard let inputDeviceId, !inputDeviceId.isEmpty else { return "system default input" }
        guard let audioUnit = inputNode.audioUnit else { return "system default input" }

        var deviceId = AudioDeviceID(0)
        var deviceSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var deviceUid = inputDeviceId as CFString
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDeviceForUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let lookupStatus = withUnsafePointer(to: &deviceUid) { uidPointer in
            AudioObjectGetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &address,
                UInt32(MemoryLayout<CFString>.size),
                uidPointer,
                &deviceSize,
                &deviceId
            )
        }
        guard lookupStatus == noErr else { return "configured input lookup failed (\(lookupStatus)); using system default input" }

        var selectedDeviceId = deviceId
        let setStatus = AudioUnitSetProperty(
            audioUnit,
            kAudioOutputUnitProperty_CurrentDevice,
            kAudioUnitScope_Global,
            0,
            &selectedDeviceId,
            UInt32(MemoryLayout<AudioDeviceID>.size)
        )
        guard setStatus == noErr else { return "configured input select failed (\(setStatus)); using system default input" }
        return "configured input \(inputDeviceId)"
    }
}
