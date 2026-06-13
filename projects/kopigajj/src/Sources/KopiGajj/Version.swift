/// Single source of truth for app version.
/// Also read by build-app.sh via: grep 'current =' Sources/KopiGajj/Version.swift
enum AppVersion {
    static let current = "0.2.0"
    static let stage = "Stage 0.5 — Canvas Render Engine"
}
