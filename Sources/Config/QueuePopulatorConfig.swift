import Foundation

struct PhrasesConfig: Codable, Sendable {
    var wake: String = "hey robot"
    var end: String = "that is all"
    var cancel: String = "cancel that"
    var approve: String = "looks good"
    var revise: String = "revise that"
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
}
