import Foundation
import AVFoundation
import Speech

func requestPermissions() async {
    fputs("Requesting microphone access...\n", stderr)
    let micGranted: Bool
    if #available(macOS 14.0, *) {
        micGranted = await AVAudioApplication.requestRecordPermission()
    } else {
        micGranted = await withCheckedContinuation { cont in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                cont.resume(returning: granted)
            }
        }
    }
    fputs(micGranted ? "  ✓ Microphone authorized\n" : "  ✗ Microphone denied\n", stderr)

    fputs("Requesting speech recognition access...\n", stderr)
    let speechStatus = await withCheckedContinuation { cont in
        SFSpeechRecognizer.requestAuthorization { status in
            cont.resume(returning: status)
        }
    }
    switch speechStatus {
    case .authorized:
        fputs("  ✓ Speech recognition authorized\n", stderr)
    case .denied:
        fputs("  ✗ Speech recognition denied — enable in System Settings > Privacy > Speech Recognition\n", stderr)
    case .restricted:
        fputs("  ✗ Speech recognition restricted on this device\n", stderr)
    case .notDetermined:
        fputs("  ? Speech recognition not yet determined\n", stderr)
    @unknown default:
        fputs("  ? Unknown speech recognition status\n", stderr)
    }
}
