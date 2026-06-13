import AppKit

protocol PressureSource: Sendable {
    mutating func pressure(for event: NSEvent) -> Float
}

struct TabletPressureSource: PressureSource {
    func pressure(for event: NSEvent) -> Float {
        max(0.01, Float(event.pressure))
    }
}

struct MousePressureSource: PressureSource {
    private var lastPosition: NSPoint?
    private var lastTimestamp: TimeInterval?
    private var smoothedSpeed: Float = 0

    private let maxSpeed: Float = 1500.0
    private let gamma: Float = 1.5

    mutating func pressure(for event: NSEvent) -> Float {
        let pos = event.locationInWindow
        let ts = event.timestamp

        defer {
            lastPosition = pos
            lastTimestamp = ts
        }

        guard let prevPos = lastPosition, let prevTs = lastTimestamp else {
            return 0.7
        }

        let dt = Float(ts - prevTs)
        guard dt > 0 else { return max(0.1, 1.0 - pow(smoothedSpeed / maxSpeed, gamma)) }

        let dx = Float(pos.x - prevPos.x)
        let dy = Float(pos.y - prevPos.y)
        let rawSpeed = sqrtf(dx * dx + dy * dy) / dt

        smoothedSpeed = 0.3 * smoothedSpeed + 0.7 * rawSpeed

        let normalized = min(smoothedSpeed / maxSpeed, 1.0)
        return max(0.1, 1.0 - pow(normalized, gamma))
    }
}

struct TrackpadPressureSource: PressureSource {
    func pressure(for event: NSEvent) -> Float {
        max(0.1, min(1.0, Float(event.pressure)))
    }
}

enum PressureSourceFactory {
    static func detect(from event: NSEvent) -> any PressureSource {
        if event.subtype == .tabletPoint || event.pressure > 0 {
            return TabletPressureSource()
        }
        return MousePressureSource()
    }
}
