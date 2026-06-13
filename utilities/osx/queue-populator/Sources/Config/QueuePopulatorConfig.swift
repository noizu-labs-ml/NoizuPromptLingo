import Foundation

struct PhrasesConfig: Codable, Sendable {
    var wake: String = "hey robot"
    var end: String = "that is all"
    var approveMemo: String = "approve memo"
    var cancel: String = "cancel that"
    var approve: String = "looks good"
    var revise: String = "revise that"

    // Virtual-mic routing commands (exclusive: opening one mutes the others).
    var openClaude: String = "robot open claude"
    var closeClaude: String = "robot close claude"
    var openCodex: String = "robot open codex"
    var closeCodex: String = "robot close codex"
    var openLlama: String = "robot open llama"
    var closeLlama: String = "robot close llama"

    enum CodingKeys: String, CodingKey {
        case wake
        case end
        case approveMemo
        case cancel
        case approve
        case revise
        case openClaude
        case closeClaude
        case openCodex
        case closeCodex
        case openLlama
        case closeLlama
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wake = try container.decodeIfPresent(String.self, forKey: .wake) ?? wake
        end = try container.decodeIfPresent(String.self, forKey: .end) ?? end
        approveMemo = try container.decodeIfPresent(String.self, forKey: .approveMemo) ?? approveMemo
        cancel = try container.decodeIfPresent(String.self, forKey: .cancel) ?? cancel
        approve = try container.decodeIfPresent(String.self, forKey: .approve) ?? approve
        revise = try container.decodeIfPresent(String.self, forKey: .revise) ?? revise
        openClaude = try container.decodeIfPresent(String.self, forKey: .openClaude) ?? openClaude
        closeClaude = try container.decodeIfPresent(String.self, forKey: .closeClaude) ?? closeClaude
        openCodex = try container.decodeIfPresent(String.self, forKey: .openCodex) ?? openCodex
        closeCodex = try container.decodeIfPresent(String.self, forKey: .closeCodex) ?? closeCodex
        openLlama = try container.decodeIfPresent(String.self, forKey: .openLlama) ?? openLlama
        closeLlama = try container.decodeIfPresent(String.self, forKey: .closeLlama) ?? closeLlama
    }
}

struct RecognitionConfig: Codable, Sendable {
    var locale: String = "en-US"
    var onDevice: Bool = true
    var maxRecordingSeconds: Int = 300
    var inputDeviceId: String? = nil
}

struct UIConfig: Codable, Sendable {
    var overlayDismissSeconds: Double = 3.0
    var showTranscriptWindow: Bool = true
}

struct QueuePopulatorConfig: Codable, Sendable {
    var llm: LlmConfig = LlmConfig()
    var phrases: PhrasesConfig = PhrasesConfig()
    var queueBasePath: String = "~/personal-development/queue"
    var systemPromptOverride: String? = nil
    var recognition: RecognitionConfig = RecognitionConfig()
    var ui: UIConfig = UIConfig()

    var resolvedQueueBasePath: String {
        (queueBasePath as NSString).expandingTildeInPath
    }

    func sanitized() -> QueuePopulatorConfig {
        var copy = self
        let defaults = PhrasesConfig()

        func phrase(_ value: String, fallback: String) -> String {
            let trimmed = value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? fallback : trimmed
        }

        copy.phrases.wake = phrase(copy.phrases.wake, fallback: defaults.wake)
        copy.phrases.end = phrase(copy.phrases.end, fallback: defaults.end)
        copy.phrases.approveMemo = phrase(copy.phrases.approveMemo, fallback: defaults.approveMemo)
        copy.phrases.cancel = phrase(copy.phrases.cancel, fallback: defaults.cancel)
        copy.phrases.approve = phrase(copy.phrases.approve, fallback: defaults.approve)
        copy.phrases.revise = phrase(copy.phrases.revise, fallback: defaults.revise)
        copy.phrases.openClaude = phrase(copy.phrases.openClaude, fallback: defaults.openClaude)
        copy.phrases.closeClaude = phrase(copy.phrases.closeClaude, fallback: defaults.closeClaude)
        copy.phrases.openCodex = phrase(copy.phrases.openCodex, fallback: defaults.openCodex)
        copy.phrases.closeCodex = phrase(copy.phrases.closeCodex, fallback: defaults.closeCodex)
        copy.phrases.openLlama = phrase(copy.phrases.openLlama, fallback: defaults.openLlama)
        copy.phrases.closeLlama = phrase(copy.phrases.closeLlama, fallback: defaults.closeLlama)
        if copy.queueBasePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            copy.queueBasePath = QueuePopulatorConfig().queueBasePath
        }
        return copy
    }
}
