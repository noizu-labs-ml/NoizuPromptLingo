import Foundation

enum PromptBuilder {
    static func classificationPrompt(transcript: String, systemOverride: String? = nil) -> (system: String, user: String) {
        let system = systemOverride ?? defaultSystemPrompt()
        let user = """
        USER MEMO TRANSCRIPT:
        \(transcript)
        """
        return (system, user)
    }

    static func revisionPrompt(original: [ProposedEntry], revision: String, systemOverride: String? = nil) -> (system: String, user: String) {
        let system = systemOverride ?? defaultSystemPrompt()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let entriesJson: String
        if let data = try? encoder.encode(original),
           let str = String(data: data, encoding: .utf8) {
            entriesJson = str
        } else {
            entriesJson = "[]"
        }

        let user = """
        You previously classified a voice memo into the following entries:

        PREVIOUS ENTRIES:
        \(entriesJson)

        The user has provided revision instructions:

        REVISION INSTRUCTIONS:
        \(revision)

        Apply the user's revisions. You may add, remove, modify, or re-route entries.
        Return the same JSON format as before with the corrected entries.
        """
        return (system, user)
    }

    private static func defaultSystemPrompt() -> String {
        """
        You are a queue classifier. You receive voice-transcribed memos and classify them into structured queue entries.

        RULES:
        1. A single memo may produce multiple entries routed to different queues.
        2. Each entry must include: "file" (relative path from the list below), "type" (short descriptor like "idea", "task", "reminder", "question", "study", "goal"), "text" (cleaned version of the relevant portion).
        3. Preserve the user's intent. Clean up speech artifacts (um, uh, like, you know) but do not rephrase substantially.
        4. If the memo is ambiguous about which queue to use, prefer the most specific queue. If truly ambiguous, use binlog.jsonl.
        5. The "file" field MUST be one of the paths listed below. Do not invent new paths.
        6. Return ONLY valid JSON — no markdown fences, no commentary outside the JSON object.

        OUTPUT FORMAT:
        {"entries": [{"file": "ideas/tools.jsonl", "type": "idea", "text": "Build a CLI that auto-generates changelogs from conventional commits"}], "reasoning": "Brief explanation of classification choices"}

        AVAILABLE QUEUES:
        \(QueueManifest.manifestText())
        """
    }
}
