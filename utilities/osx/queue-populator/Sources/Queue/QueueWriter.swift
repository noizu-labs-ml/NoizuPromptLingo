import Foundation

enum QueueWriteError: Error {
    case encodingFailed
    case invalidPath(String)
}

enum QueueWriter {
    static func append(entry: QueueEntry, toFile relativePath: String, basePath: String) throws {
        let validPaths = QueueManifest.validPaths()
        guard validPaths.contains(relativePath) else {
            throw QueueWriteError.invalidPath(relativePath)
        }

        let fullPath = (basePath as NSString).appendingPathComponent(relativePath)
        let fileURL = URL(fileURLWithPath: fullPath)

        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(entry),
              var line = String(data: data, encoding: .utf8) else {
            throw QueueWriteError.encodingFailed
        }
        line += "\n"

        if FileManager.default.fileExists(atPath: fullPath) {
            let handle = try FileHandle(forWritingTo: fileURL)
            defer { try? handle.close() }
            handle.seekToEndOfFile()
            handle.write(line.data(using: .utf8)!)
        } else {
            try line.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    static func appendAll(entries: [ProposedEntry], basePath: String) throws -> Int {
        var written = 0
        for proposed in entries {
            let entry = QueueEntry.create(type: proposed.type, text: proposed.text)
            try append(entry: entry, toFile: proposed.file, basePath: basePath)
            written += 1
        }
        return written
    }
}
