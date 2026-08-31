import AppKit
import SwiftUI

enum Branding {
    static var heroImage: NSImage? { NSImage.brandingResource(named: "WatchdogHero") }
    static var companionImage: NSImage? { NSImage.brandingResource(named: "WatchdogCompanion") }
    static var markImage: NSImage? { NSImage.brandingResource(named: "AppMark") }
}

struct WatchdogHeroBanner: View {
    var height: CGFloat = 180

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let image = Branding.heroImage {
                    Image(nsImage: image)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [Nocturne.void, Nocturne.surfaceRaised],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()

            LinearGradient(
                colors: [.clear, Nocturne.void.opacity(0.72)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 2) {
                Text("agent-watch-dog")
                    .font(.caption.weight(.medium).monospaced())
                    .foregroundStyle(Nocturne.glow)
                Text("LLM Toolkit")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Nocturne.textBright)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Nocturne.border, lineWidth: 1)
        )
    }
}

struct WatchdogCompanionMark: View {
    var size: CGFloat = 36

    var body: some View {
        Group {
            if let image = Branding.companionImage {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
            } else if let mark = Branding.markImage {
                Image(nsImage: mark)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .padding(4)
            } else {
                Image(systemName: "diamond.fill")
                    .foregroundStyle(Nocturne.glow)
            }
        }
        .frame(width: size, height: size)
        .background(Nocturne.void)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .stroke(Nocturne.border, lineWidth: 1)
        )
    }
}

private extension NSImage {
    static func brandingResource(named name: String) -> NSImage? {
        if let url = Bundle.module.url(forResource: name, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        let extras = [
            Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/\(name).png"),
            URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .appendingPathComponent("Resources/\(name).png"),
        ]
        for url in extras {
            if FileManager.default.fileExists(atPath: url.path),
               let image = NSImage(contentsOf: url) {
                return image
            }
        }
        return nil
    }
}
