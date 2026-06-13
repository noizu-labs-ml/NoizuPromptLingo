import Foundation

private let configDir = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".config/queue-populator")
private let configFile = configDir.appendingPathComponent("config.json")

func loadConfig() -> QueuePopulatorConfig {
    guard let data = try? Data(contentsOf: configFile),
          let config = try? JSONDecoder().decode(QueuePopulatorConfig.self, from: data) else {
        return QueuePopulatorConfig()
    }
    return config
}

func saveConfig(_ config: QueuePopulatorConfig) {
    try? FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    if let data = try? encoder.encode(config) {
        try? data.write(to: configFile)
    }
}
