import Foundation

/// One of the virtual microphone devices vended by the RobotAudio HAL driver.
/// `deviceName` must match the device name the driver publishes (see Driver/RobotAudio).
enum MicTarget: String, CaseIterable, Sendable {
    case recording
    case claude
    case codex
    case llama

    /// Name as it appears in CoreAudio / other apps' input lists.
    var deviceName: String {
        switch self {
        case .recording: "Recording"
        case .claude: "Claude"
        case .codex: "Codex"
        case .llama: "Llama"
        }
    }

    var isExternalAssistant: Bool {
        switch self {
        case .claude, .codex, .llama:
            true
        case .recording:
            false
        }
    }

    var label: String { deviceName }
}
