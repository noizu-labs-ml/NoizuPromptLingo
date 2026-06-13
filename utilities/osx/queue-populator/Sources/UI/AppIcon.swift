import AppKit

func queuePopulatorAppIcon(size: NSSize) -> NSImage? {
    let bundledImage =
        NSImage(named: "QueuePopulator") ??
        Bundle.main.url(forResource: "QueuePopulator", withExtension: "icns").flatMap { NSImage(contentsOf: $0) }
    let image = bundledImage ?? NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)

    guard let copy = image.copy() as? NSImage else { return nil }
    copy.size = size
    copy.isTemplate = false
    return copy
}
