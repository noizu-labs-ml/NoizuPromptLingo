import Foundation

struct QueueFile: Sendable {
    let path: String
    let description: String
}

enum QueueManifest {
    static let files: [QueueFile] = [
        // Top-level
        QueueFile(path: "tasks.jsonl", description: "Actionable tasks with clear completion criteria"),
        QueueFile(path: "todo.jsonl", description: "Short-term to-do items and chores"),
        QueueFile(path: "work-items.jsonl", description: "Professional/work-related items"),
        QueueFile(path: "reminders.jsonl", description: "Time-sensitive reminders"),
        QueueFile(path: "binlog.jsonl", description: "Raw activity log entries, observations, stream-of-consciousness"),

        // Ideas
        QueueFile(path: "ideas/agents.jsonl", description: "AI agent concepts and architectures"),
        QueueFile(path: "ideas/applications.jsonl", description: "Application ideas (desktop, web, mobile)"),
        QueueFile(path: "ideas/blogging.jsonl", description: "Blog post topics and article ideas"),
        QueueFile(path: "ideas/books.jsonl", description: "Book ideas, outlines, chapter concepts"),
        QueueFile(path: "ideas/business-development.jsonl", description: "Business strategies, partnerships, revenue ideas"),
        QueueFile(path: "ideas/experiments.jsonl", description: "Experiments to run, hypotheses to test"),
        QueueFile(path: "ideas/improvements.jsonl", description: "Improvements to existing systems/tools"),
        QueueFile(path: "ideas/mobile.jsonl", description: "Mobile app concepts"),
        QueueFile(path: "ideas/papers.jsonl", description: "Academic/technical paper topics"),
        QueueFile(path: "ideas/products.jsonl", description: "Product concepts for sale"),
        QueueFile(path: "ideas/prompts.jsonl", description: "Prompt engineering ideas and templates"),
        QueueFile(path: "ideas/research.jsonl", description: "Research directions and questions"),
        QueueFile(path: "ideas/sites.jsonl", description: "Website/domain ideas"),
        QueueFile(path: "ideas/tools.jsonl", description: "Developer tool concepts"),
        QueueFile(path: "ideas/utilities.jsonl", description: "Utility program ideas"),
        QueueFile(path: "ideas/videos.jsonl", description: "Video content ideas"),

        // Knowledge base
        QueueFile(path: "knowledge-base/references.jsonl", description: "References, links, resources to catalog"),
        QueueFile(path: "knowledge-base/subjects.jsonl", description: "Subject areas to explore or document"),

        // Learning plan
        QueueFile(path: "learning-plan/goals.jsonl", description: "Learning objectives and milestones"),
        QueueFile(path: "learning-plan/smart.jsonl", description: "SMART-formatted learning goals"),

        // Personal development
        QueueFile(path: "personal-development/questions.jsonl", description: "Open questions to investigate"),
        QueueFile(path: "personal-development/study.jsonl", description: "Study items, flashcard seeds, drill topics"),

        // Writing
        QueueFile(path: "writing/ideas.jsonl", description: "Writing project ideas"),
        QueueFile(path: "writing/inspiration.jsonl", description: "Inspirational quotes, passages, sparks"),
        QueueFile(path: "writing/genres.jsonl", description: "Genre explorations and notes"),
        QueueFile(path: "writing/reading-list.jsonl", description: "Books/articles to read"),
        QueueFile(path: "writing/resources.jsonl", description: "Writing resources and tools"),
        QueueFile(path: "writing/subjects.jsonl", description: "Subject matter for writing projects"),
    ]

    static func manifestText() -> String {
        var sections: [(String, [QueueFile])] = []

        let topLevel = files.filter { !$0.path.contains("/") }
        sections.append(("TOP-LEVEL", topLevel))

        let groups: [(String, String)] = [
            ("ideas/", "IDEAS"),
            ("knowledge-base/", "KNOWLEDGE-BASE"),
            ("learning-plan/", "LEARNING-PLAN"),
            ("personal-development/", "PERSONAL-DEVELOPMENT"),
            ("writing/", "WRITING"),
        ]

        for (prefix, label) in groups {
            let group = files.filter { $0.path.hasPrefix(prefix) }
            if !group.isEmpty {
                sections.append((label, group))
            }
        }

        var lines: [String] = []
        for (label, group) in sections {
            lines.append("\(label):")
            for file in group {
                lines.append("- \(file.path) — \(file.description)")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }

    static func validPaths() -> Set<String> {
        Set(files.map(\.path))
    }
}
