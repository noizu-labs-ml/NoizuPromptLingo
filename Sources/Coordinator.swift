import Foundation
import AppKit
import AVFoundation
import Speech

@MainActor
final class Coordinator: SpeechEngineDelegate {
    private var config: QueuePopulatorConfig
    private let appConfig: AppConfig
    private let stateMachine = AppStateMachine()
    private var speechEngine: SpeechEngine
    private var phraseDetector: PhraseDetector
    private let overlay = StateOverlay()
    private let reviewWindow = ReviewWindow()
    private let transcriptWindow: TranscriptWindow?
    private let statusBar: StatusBarController
    private var llmClient: LlmClient

    private var finalizedChunks: [String] = []
    private var currentPartial: String = ""

    init(config: QueuePopulatorConfig, appConfig: AppConfig) {
        self.config = config
        self.appConfig = appConfig

        self.speechEngine = SpeechEngine(
            locale: config.recognition.locale,
            onDevice: config.recognition.onDevice,
            inputDeviceId: config.recognition.inputDeviceId,
            verbose: appConfig.verbose
        )
        self.phraseDetector = PhraseDetector(phrases: config.phrases)
        self.llmClient = LlmClient(config: config.llm)
        self.statusBar = StatusBarController(config: config)
        self.transcriptWindow = config.ui.showTranscriptWindow ? TranscriptWindow() : nil

        speechEngine.delegate = self
    }

    func start() {
        statusBar.setup(
            onConfigure: { [weak self] in self?.showConfig() },
            onShowTranscript: { [weak self] in self?.transcriptWindow?.show() },
            onTogglePause: { [weak self] in self?.togglePause() },
            onQuit: { [weak self] in self?.quit() }
        )
        NSApplication.shared.activate(ignoringOtherApps: true)
        startListening()
        statusBar.updateState(.idle)
        showConfig()

        fputs("queue-populator: listening for \"\(config.phrases.wake)\"\n", stderr)
        fputs("  end: \"\(config.phrases.end)\"  cancel: \"\(config.phrases.cancel)\"\n", stderr)
        fputs("  approve: \"\(config.phrases.approve)\"  revise: \"\(config.phrases.revise)\"\n", stderr)
        fputs("  queue: \(config.resolvedQueueBasePath)\n", stderr)
        fputs("  llm: \(config.llm.provider) / \(config.llm.effectiveModel)\n", stderr)
    }

    // MARK: - SpeechEngineDelegate

    nonisolated func speechEngine(_ engine: SpeechEngine, didReceivePartial text: String) {
        Task { @MainActor in
            self.currentPartial = text
            self.processTranscript()
        }
    }

    nonisolated func speechEngine(_ engine: SpeechEngine, didFinalize text: String) {
        Task { @MainActor in
            self.finalizedChunks.append(text)
            self.currentPartial = ""
            log("  [finalized] \"\(text)\"")
            log("  [buffer] chunks=\(self.finalizedChunks.count) total=\"\(self.buildFullTranscript())\"")
        }
    }

    nonisolated func speechEngine(_ engine: SpeechEngine, didReceiveRecognitionError message: String) {
        Task { @MainActor in
            self.log("  [speech] \(message)")
            self.transcriptWindow?.appendEvent("Speech: \(message)")
            if message != "Speech recognizer callback received" {
                self.statusBar.setPaused(true)
            }
        }
    }

    // MARK: - Transcript processing

    private var fullTranscript: String {
        buildFullTranscript()
    }

    private func buildFullTranscript() -> String {
        var parts = finalizedChunks
        if !currentPartial.isEmpty {
            parts.append(currentPartial)
        }
        return parts.joined(separator: " ")
    }

    private func processTranscript() {
        let text = fullTranscript
        let currentState = stateMachine.state
        transcriptWindow?.updateLiveTranscript(text, state: currentState)

        guard let event = phraseDetector.detect(in: text, forState: currentState) else { return }

        switch event {
        case .wakeDetected:
            log("━━━ WAKE PHRASE DETECTED ━━━")
            log("  state: \(currentState.label) → Recording")
            log("  clearing memo buffer")
            finalizedChunks = []
            currentPartial = ""
            phraseDetector.reset()
            let effects = stateMachine.handle(event)
            execute(effects)

        case .endDetected:
            let memo = extractMemo(from: fullTranscript)
            log("━━━ END PHRASE DETECTED ━━━")
            log("  state: \(currentState.label) → Processing")
            log("  raw transcript: \"\(fullTranscript)\"")
            log("  extracted memo: \"\(memo)\"")
            log("  finalized chunks: \(finalizedChunks)")
            if memo.isEmpty {
                log("  ⚠ memo is EMPTY — will show 'Nothing heard'")
            }
            let effects = stateMachine.handle(.endDetected(transcript: memo))
            execute(effects)

        case .cancelDetected:
            log("━━━ CANCEL PHRASE DETECTED ━━━")
            log("  state: \(currentState.label)")
            let effects = stateMachine.handle(event)
            execute(effects)

        case .approveDetected:
            log("━━━ APPROVE PHRASE DETECTED ━━━")
            let effects = stateMachine.handle(event)
            execute(effects)

        case .reviseDetected:
            log("━━━ REVISE PHRASE DETECTED ━━━")
            finalizedChunks = []
            currentPartial = ""
            phraseDetector.reset()
            let effects = stateMachine.handle(event)
            execute(effects)

        default:
            let effects = stateMachine.handle(event)
            execute(effects)
        }
    }

    private func extractMemo(from text: String) -> String {
        var memo = text
        for phrase in [config.phrases.wake, config.phrases.end] {
            memo = memo.replacingOccurrences(of: phrase, with: "", options: [.caseInsensitive])
        }
        return memo.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Side effects

    private func execute(_ effects: [SideEffect]) {
        for effect in effects {
            switch effect {
            case .startRecording:
                phraseDetector.reset()
                statusBar.updateState(stateMachine.state)
                NSApplication.shared.activate(ignoringOtherApps: true)
                transcriptWindow?.show()
                overlay.showState(stateMachine.state, phrases: config.phrases)
                transcriptWindow?.appendEvent("Recording started")

            case .stopRecording:
                statusBar.updateState(stateMachine.state)

            case .sendToLlm(let transcript):
                statusBar.updateState(.processing)
                overlay.showState(.processing, phrases: config.phrases)
                NSApplication.shared.activate(ignoringOtherApps: true)
                transcriptWindow?.show()
                transcriptWindow?.appendEvent("Sending to LLM: \(transcript)")
                log("━━━ SENDING TO LLM ━━━")
                log("  provider: \(config.llm.provider)")
                log("  model: \(config.llm.effectiveModel)")
                log("  transcript: \"\(transcript)\"")
                Task { await self.classifyTranscript(transcript) }

            case .sendRevisionToLlm(let original, let revision):
                statusBar.updateState(.processing)
                overlay.showState(.processing, phrases: config.phrases)
                NSApplication.shared.activate(ignoringOtherApps: true)
                transcriptWindow?.show()
                transcriptWindow?.appendEvent("Sending revision: \(revision)")
                log("━━━ SENDING REVISION TO LLM ━━━")
                log("  original entries: \(original.count)")
                log("  revision: \"\(revision)\"")
                Task { await self.reviseEntries(original: original, revision: revision) }

            case .showReview(let entries):
                statusBar.updateState(stateMachine.state)
                overlay.showState(stateMachine.state, phrases: config.phrases)
                phraseDetector.reset()
                finalizedChunks = []
                currentPartial = ""
                log("━━━ REVIEW ━━━")
                for (i, entry) in entries.enumerated() {
                    log("  [\(i+1)] → \(entry.file)  type=\(entry.type)  text=\"\(entry.text)\"")
                }
                reviewWindow.show(
                    entries: entries,
                    approve: { [weak self] in self?.handleButtonEvent(.approveDetected) },
                    revise: { [weak self] in self?.handleButtonEvent(.reviseDetected) },
                    cancel: { [weak self] in self?.handleButtonEvent(.cancelDetected) }
                )

            case .writeEntries(let entries):
                reviewWindow.hide()
                log("━━━ WRITING ENTRIES ━━━")
                for entry in entries {
                    log("  → \(entry.file): \(entry.text)")
                }
                writeEntries(entries)

            case .showOverlay(let message):
                overlay.show(message: message)
                log("  [overlay] \(message)")

            case .showError(let error):
                overlay.show(message: "Error: \(error)", icon: "⚠️", duration: 5.0)
                transcriptWindow?.appendEvent("Error: \(error)")
                log("  [ERROR] \(error)")

            case .returnToIdle:
                statusBar.updateState(.idle)
                phraseDetector.reset()
                finalizedChunks = []
                currentPartial = ""
                log("  [state] → Idle")
            }
        }
    }

    private func handleButtonEvent(_ event: AppEvent) {
        log("━━━ BUTTON: \(event) ━━━")
        let effects = stateMachine.handle(event)
        execute(effects)
    }

    // MARK: - LLM

    private func classifyTranscript(_ transcript: String) async {
        let (system, user) = PromptBuilder.classificationPrompt(
            transcript: transcript,
            systemOverride: config.systemPromptOverride
        )
        transcriptWindow?.appendBlock(
            title: "LLM REQUEST  \(config.llm.provider) / \(config.llm.effectiveModel)",
            body: """
            SYSTEM:
            \(system)

            USER:
            \(user)
            """,
            color: .systemOrange
        )
        log("━━━ LLM REQUEST ━━━")
        log("  system prompt: \(system.prefix(200))...")
        log("  user prompt: \(user)")
        do {
            let result = try await llmClient.classifyWithTrace(system: system, user: user)
            let response = result.response
            transcriptWindow?.appendBlock(
                title: "LLM RESPONSE",
                body: """
                RAW:
                \(result.rawText)

                PARSED:
                \(formatEntries(response.entries, reasoning: response.reasoning))
                """,
                color: .systemGreen
            )
            log("━━━ LLM RESPONSE ━━━")
            log("  entries: \(response.entries.count)")
            if let reasoning = response.reasoning {
                log("  reasoning: \(reasoning)")
            }
            for (i, entry) in response.entries.enumerated() {
                log("  [\(i+1)] file=\(entry.file)  type=\(entry.type)  text=\"\(entry.text)\"")
            }
            let effects = stateMachine.handle(.llmCompleted(response.entries))
            execute(effects)
        } catch {
            transcriptWindow?.appendBlock(
                title: "LLM ERROR",
                body: "\(error)",
                color: .systemRed
            )
            log("━━━ LLM ERROR ━━━")
            log("  \(error)")
            let effects = stateMachine.handle(.llmFailed("\(error)"))
            execute(effects)
        }
    }

    private func reviseEntries(original: [ProposedEntry], revision: String) async {
        let (system, user) = PromptBuilder.revisionPrompt(
            original: original,
            revision: revision,
            systemOverride: config.systemPromptOverride
        )
        transcriptWindow?.appendBlock(
            title: "LLM REVISION REQUEST  \(config.llm.provider) / \(config.llm.effectiveModel)",
            body: """
            SYSTEM:
            \(system)

            USER:
            \(user)
            """,
            color: .systemOrange
        )
        log("━━━ LLM REVISION REQUEST ━━━")
        log("  user prompt: \(user.prefix(300))...")
        do {
            let result = try await llmClient.classifyWithTrace(system: system, user: user)
            let response = result.response
            transcriptWindow?.appendBlock(
                title: "LLM REVISION RESPONSE",
                body: """
                RAW:
                \(result.rawText)

                PARSED:
                \(formatEntries(response.entries, reasoning: response.reasoning))
                """,
                color: .systemGreen
            )
            log("━━━ LLM REVISION RESPONSE ━━━")
            for (i, entry) in response.entries.enumerated() {
                log("  [\(i+1)] file=\(entry.file)  type=\(entry.type)  text=\"\(entry.text)\"")
            }
            let effects = stateMachine.handle(.llmCompleted(response.entries))
            execute(effects)
        } catch {
            transcriptWindow?.appendBlock(
                title: "LLM REVISION ERROR",
                body: "\(error)",
                color: .systemRed
            )
            log("━━━ LLM REVISION ERROR ━━━")
            log("  \(error)")
            let effects = stateMachine.handle(.llmFailed("\(error)"))
            execute(effects)
        }
    }

    private func formatEntries(_ entries: [ProposedEntry], reasoning: String?) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let entriesJson: String
        if let data = try? encoder.encode(entries),
           let json = String(data: data, encoding: .utf8) {
            entriesJson = json
        } else {
            entriesJson = "\(entries)"
        }

        if let reasoning, !reasoning.isEmpty {
            return """
            entries:
            \(entriesJson)

            reasoning:
            \(reasoning)
            """
        }
        return """
        entries:
        \(entriesJson)
        """
    }

    private func writeEntries(_ entries: [ProposedEntry]) {
        do {
            let count = try QueueWriter.appendAll(entries: entries, basePath: config.resolvedQueueBasePath)
            log("━━━ WROTE \(count) ENTRIES ━━━")
            transcriptWindow?.appendEvent("Wrote \(count) entries")
            let effects = stateMachine.handle(.writeCompleted(count))
            execute(effects)
        } catch {
            log("━━━ WRITE ERROR: \(error) ━━━")
            overlay.show(message: "Write error: \(error.localizedDescription)", icon: "⚠️", duration: 5.0)
            transcriptWindow?.appendEvent("Write error: \(error)")
        }
    }

    private func togglePause() {
        let paused = !statusBar.isPaused
        statusBar.setPaused(paused)
        if paused {
            speechEngine.stop()
            log("━━━ PAUSED ━━━")
            transcriptWindow?.appendEvent("Listening paused")
            overlay.show(message: "Paused", icon: "⏸")
        } else {
            startListening()
            finalizedChunks = []
            currentPartial = ""
            phraseDetector.reset()
            log("━━━ RESUMED ━━━")
            transcriptWindow?.appendEvent("Listening resumed")
            overlay.show(message: "Resumed", icon: "▶️")
        }
    }

    private func quit() {
        speechEngine.stop()
        unloadLaunchAgent()
        NSApplication.shared.terminate(nil)
    }

    private func unloadLaunchAgent() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        let plistPath = "\(homeDir)/Library/LaunchAgents/com.noizu.queue-populator.plist"
        guard FileManager.default.fileExists(atPath: plistPath) else { return }

        do {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/bin/launchctl")
            proc.arguments = ["unload", plistPath]
            try proc.run()
            proc.waitUntilExit()
        } catch {
            // Keep app quit behavior unchanged if LaunchAgent unload fails.
        }
    }

    private func showConfig() {
        guard let updated = showConfigDialog(config: config) else { return }
        saveConfig(updated)
        applyConfig(updated)
        overlay.show(message: "Configuration saved", icon: "✓")
        transcriptWindow?.appendEvent("Configuration saved")
        log("━━━ CONFIG UPDATED ━━━")
        log("  llm: \(config.llm.provider) / \(config.llm.effectiveModel)")
    }

    private func applyConfig(_ updated: QueuePopulatorConfig) {
        let wasListening = speechEngine.isRunning && !statusBar.isPaused
        speechEngine.stop()
        config = updated
        phraseDetector = PhraseDetector(phrases: updated.phrases)
        llmClient = LlmClient(config: updated.llm)
        speechEngine = SpeechEngine(
            locale: updated.recognition.locale,
            onDevice: updated.recognition.onDevice,
            inputDeviceId: updated.recognition.inputDeviceId,
            verbose: appConfig.verbose
        )
        speechEngine.delegate = self
        if wasListening {
            startListening()
        }
        statusBar.updateConfig(updated)
    }

    private func startListening() {
        if let permissionError = recognitionPermissionError() {
            requestPermissionsThenStartListening(reason: permissionError)
            return
        }

        switch speechEngine.start() {
        case .started(let inputDescription):
            log("━━━ MIC STARTED ━━━")
            log("  input: \(inputDescription)")
            transcriptWindow?.appendEvent("Mic listening: \(inputDescription)")
        case .alreadyRunning:
            log("━━━ MIC ALREADY RUNNING ━━━")
        case .failed(let error):
            statusBar.setPaused(true)
            overlay.show(message: "Mic failed: \(error)", icon: "⚠️", duration: 5.0)
            transcriptWindow?.show()
            transcriptWindow?.appendEvent("Mic failed: \(error)")
            log("━━━ MIC FAILED ━━━")
            log("  \(error)")
        }
    }

    private func requestPermissionsThenStartListening(reason: String) {
        log("━━━ MIC PERMISSION NEEDED ━━━")
        log("  \(reason)")
        transcriptWindow?.show()
        transcriptWindow?.appendEvent("Requesting microphone and speech permissions")

        Task { @MainActor in
            await requestPermissions()
            if let permissionError = recognitionPermissionError() {
                statusBar.setPaused(true)
                overlay.show(message: permissionError, icon: "⚠️", duration: 5.0)
                transcriptWindow?.show()
                transcriptWindow?.appendEvent(permissionError)
                log("━━━ MIC PERMISSION FAILED ━━━")
                log("  \(permissionError)")
                return
            }
            startListening()
        }
    }

    private func recognitionPermissionError() -> String? {
        if #available(macOS 14.0, *) {
            guard AVAudioApplication.shared.recordPermission == .granted else {
                return "Microphone not authorized."
            }
        } else {
            guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else {
                return "Microphone not authorized."
            }
        }
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            return "Speech recognition not authorized."
        }
        guard SFSpeechRecognizer(locale: Locale(identifier: config.recognition.locale))?.isAvailable == true else {
            return "Speech recognizer unavailable for \(config.recognition.locale)."
        }
        return nil
    }

    private func log(_ message: String) {
        fputs("\(message)\n", stderr)
    }
}
