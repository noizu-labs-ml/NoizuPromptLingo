import Foundation
import CoreAudio

/// Helpers for finding CoreAudio devices by their published name.
enum AudioDeviceLookup {

    /// Returns the AudioDeviceID for a device whose name matches `name` (case-insensitive),
    /// or nil if no such device is currently present.
    static func deviceID(named name: String) -> AudioDeviceID? {
        for id in allDeviceIDs() {
            // Qualify with Self so the `name` parameter doesn't shadow `name(of:)`.
            if let deviceName = Self.name(of: id),
               deviceName.compare(name, options: .caseInsensitive) == .orderedSame {
                return id
            }
        }
        return nil
    }

    /// All audio device IDs known to the HAL.
    static func allDeviceIDs() -> [AudioDeviceID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &dataSize
        )
        guard status == noErr, dataSize > 0 else { return [] }

        let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var ids = [AudioDeviceID](repeating: 0, count: count)
        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &dataSize,
            &ids
        )
        guard status == noErr else { return [] }
        return ids
    }

    /// Human-readable name of a device, or nil if it can't be read.
    static func name(of deviceID: AudioDeviceID) -> String? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        // The property returns a +1-retained CFStringRef, so take it as Unmanaged
        // and release ownership via takeRetainedValue().
        var name: Unmanaged<CFString>? = nil
        var dataSize = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        let status = withUnsafeMutablePointer(to: &name) { ptr -> OSStatus in
            AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, ptr)
        }
        guard status == noErr, let name else { return nil }
        return name.takeRetainedValue() as String
    }

    /// True if the device exposes at least one output stream (i.e. we can render into it).
    static func hasOutputStreams(_ deviceID: AudioDeviceID) -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &dataSize)
        return status == noErr && dataSize > 0
    }
}
