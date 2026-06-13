import Foundation
import AVFoundation

final class MemoAudioRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var file: AVAudioFile?
    private var tempURL: URL?
    private var outputURL: URL?
    private var wroteAudio = false

    var isRecording: Bool {
        lock.withLock { file != nil }
    }

    func start(format: AVAudioFormat?, outputDirectory: URL) throws -> URL {
        guard let format else {
            throw MemoAudioRecorderError.missingFormat
        }

        let timestamp = Self.timestamp()
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("queue-populator-\(timestamp).caf")
        let output = outputDirectory
            .appendingPathComponent("memo-\(timestamp).mp3")

        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )
        try? FileManager.default.removeItem(at: temp)
        try? FileManager.default.removeItem(at: output)

        let audioFile = try AVAudioFile(forWriting: temp, settings: format.settings)

        lock.withLock {
            file = audioFile
            tempURL = temp
            outputURL = output
            wroteAudio = false
        }

        return output
    }

    func append(_ buffer: AVAudioPCMBuffer) {
        lock.withLock {
            guard let file else { return }
            do {
                try file.write(from: buffer)
                wroteAudio = true
            } catch {
                fputs("memo-audio: failed to write buffer: \(error.localizedDescription)\n", stderr)
            }
        }
    }

    func stopAndExportMP3() throws -> URL? {
        let state = lock.withLock {
            let result = (file, tempURL, outputURL, wroteAudio)
            file = nil
            tempURL = nil
            outputURL = nil
            wroteAudio = false
            return result
        }

        guard state.0 != nil, let temp = state.1, let output = state.2 else {
            return nil
        }

        guard state.3 else {
            try? FileManager.default.removeItem(at: temp)
            return nil
        }

        try Self.convertToMP3(input: temp, output: output)
        try? FileManager.default.removeItem(at: temp)
        return output
    }

    func cancel() {
        let temp = lock.withLock {
            let temp = tempURL
            file = nil
            tempURL = nil
            outputURL = nil
            wroteAudio = false
            return temp
        }
        if let temp {
            try? FileManager.default.removeItem(at: temp)
        }
    }

    private static func convertToMP3(input: URL, output: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/afconvert")
        process.arguments = [
            "-f", "MPG3",
            "-d", ".mp3",
            input.path,
            output.path
        ]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw MemoAudioRecorderError.exportFailed(Int(process.terminationStatus))
        }
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: Date())
    }
}

enum MemoAudioRecorderError: LocalizedError {
    case missingFormat
    case exportFailed(Int)

    var errorDescription: String? {
        switch self {
        case .missingFormat:
            "Live microphone format is not available yet."
        case .exportFailed(let status):
            "MP3 export failed with status \(status)."
        }
    }
}
