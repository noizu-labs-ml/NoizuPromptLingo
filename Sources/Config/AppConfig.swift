import Foundation

struct AppConfig: Sendable {
    var authorize: Bool = false
    var verbose: Bool = false
}

func parseArgs(_ args: [String]) -> AppConfig {
    var config = AppConfig()
    var i = 1
    while i < args.count {
        switch args[i] {
        case "--authorize":
            config.authorize = true
        case "--verbose", "-v":
            config.verbose = true
        case "--help", "-h":
            printUsage()
            exit(0)
        default:
            fputs("unknown option: \(args[i])\n", stderr)
            printUsage()
            exit(1)
        }
        i += 1
    }
    return config
}

func printUsage() {
    let usage = """
    Usage: queue-populator [OPTIONS]

    Voice-driven queue entry system. Listens for a wake phrase, captures a voice
    memo, classifies it with an LLM, and appends entries to JSONL queue files.

    Options:
          --authorize          Request microphone + speech permissions and exit
      -v, --verbose            Print partial transcriptions to stderr
      -h, --help               Show this help

    Configuration is stored at ~/.config/queue-populator/config.json
    Queue files are written to ~/personal-development/queue/
    """
    fputs(usage, stderr)
}
