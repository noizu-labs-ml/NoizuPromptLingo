# Clipboard Type Detection

## Overview

macOS clipboard supports multiple data types beyond plain text, including images, rich text, URLs, file references, and custom formats. A smart clipboard manager must detect and handle these various types appropriately.

## Core Concepts

- **Uniform Type Identifiers (UTIs)**: Reverse-DNS strings that identify data types
- **Pasteboard Types**: UTI strings used with NSPasteboard
- **Multiple Types**: Items may have multiple representations (text + RTF + HTML)
- **Priority Ordering**: Check preferred types before fallbacks
- **Type Conversion**: Converting between compatible formats

## Key APIs and Frameworks

| API/Framework | Purpose |
|--------------|---------|
| `UTType` | Type identification using UTIs |
| `PasteboardType` | Swift wrapper for pasteboard types |
| `NSPasteboard` | Accessing typed data |
| `UniformTypeIdentifiers` | System UTI definitions |
| `UTIUtilities` | UTI comparison and conversion |

## Swift Code Examples

### Type Detection Helper

```swift
import AppKit
import UniformTypeIdentifiers

enum ClipboardContentType: Hashable, Identifiable {
    case text
    case image(imageType: ImageType)
    case url
    case file(fileURLs: [URL])
    case rtf
    case html
    case custom(type: String)

    var id: String {
        switch self {
        case .text: return "text"
        case .image(let type): return "image-\(type.rawValue)"
        case .url: return "url"
        case .file(let urls): return "file-\(urls.count)"
        case .rtf: return "rtf"
        case .html: return "html"
        case .custom(let type): return "custom-\(type)"
        }
    }

    enum ImageType: String {
        case png
        case tiff
        case jpeg
        case pdf

        var utType: UTType {
            switch self {
            case .png: return .png
            case .tiff: return .tiff
            case .jpeg: return .jpeg
            case .pdf: return .pdf
            }
        }
    }
}

class ClipboardTypeDetector {
    private let pasteboard = NSPasteboard.general

    func detectContentType() -> ClipboardContentType? {
        guard let availableTypes = pasteboard.types else {
            return nil
        }

        // Check types in priority order

        // 1. File URLs
        if availableTypes.contains(.fileURL) {
            if let fileURLs = readFiles() {
                return .file(fileURLs: fileURLs)
            }
        }

        // 2. Images
        if let imageType = detectImageType(from: availableTypes) {
            return .image(imageType: imageType)
        }

        // 3. URLs
        if availableTypes.contains(.url) {
            return .url
        }

        // 4. HTML
        if availableTypes.contains(.html) {
            return .html
        }

        // 5. RTF
        if availableTypes.contains(.rtf) {
            return .rtf
        }

        // 6. Plain text
        if availableTypes.contains(.plainText) {
            return .text
        }

        // 7. Custom types
        for type in availableTypes {
            if !isStandardType(type) {
                return .custom(type: type.rawValue)
            }
        }

        return nil
    }

    private func detectImageType(from types: [PasteboardType]) -> ClipboardContentType.ImageType? {
        if types.contains(.pdf) {
            return .pdf
        } else if types.contains(.png) {
            return .png
        } else if types.contains(.tiff) {
            return .tiff
        } else if types.contains(.jpeg) {
            return .jpeg
        }
        return nil
    }

    private func readFiles() -> [URL]? {
        guard let fileURLs = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: nil
        ) as? [URL] else {
            return nil
        }
        return fileURLs
    }

    private func isStandardType(_ type: PasteboardType) -> Bool {
        let standardTypes: Set<PasteboardType> = [
            .plainText, .string, .rtf, .html,
            .url, .fileURL,
            .png, .tiff, .jpeg, .pdf,
            .color
        ]
        return standardTypes.contains(type)
    }

    func getAllAvailableTypes() -> [PasteboardType] {
        return pasteboard.types ?? []
    }
}
```

### Reading Different Content Types

```swift
import AppKit
import UniformTypeIdentifiers

class ClipboardReader {
    private let pasteboard = NSPasteboard.general

    // Text
    func readText() -> String? {
        return pasteboard.string(forType: .plainText)
    }

    // Image
    func readImage() -> NSImage? {
        // Try in order of preference
        for type in [PasteboardType.png, PasteboardType.tiff, PasteboardType.jpeg] {
            if let data = pasteboard.data(forType: type) {
                return NSImage(data: data)
            }
        }
        return nil
    }

    // Try specific image format
    func readImageData(ofType type: UTType) -> Data? {
        let pasteboardType = PasteboardType(type.identifier)
        return pasteboard.data(forType: pasteboardType)
    }

    // URL
    func readURL() -> URL? {
        guard let data = pasteboard.data(forType: .url) else {
            return nil
        }
        return URL(dataRepresentation: data, relativeTo: nil)
    }

    // Files
    func readFiles() -> [URL] {
        guard let objects = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: nil
        ) as? [URL] else {
            return []
        }
        return objects
    }

    // Rich Text (RTF)
    func readRTF() -> NSAttributedString? {
        guard let data = pasteboard.data(forType: .rtf) else {
            return nil
        }
        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        )
    }

    // HTML
    func readHTML() -> String? {
        guard let data = pasteboard.data(forType: .html) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    // Color (NSColor)
    func readColor() -> NSColor? {
        guard let data = pasteboard.data(forType: .color) else {
            return nil
        }
        return NSColor(dataRepresentation: data)
    }

    // Custom type
    func readCustomData(forType type: String) -> Data? {
        let pasteboardType = PasteboardType(type)
        return pasteboard.data(forType: pasteboardType)
    }

    // Read any available data
    func readAllAvailableData() -> [ClipboardData] {
        guard let types = pasteboard.types else { return [] }

        return types.compactMap { type in
            if let data = pasteboard.data(forType: type) {
                return ClipboardData(type: type.rawValue, data: data)
            }
            return nil
        }
    }
}

struct ClipboardData {
    let type: String
    let data: Data
}
```

### Writing Different Content Types

```swift
import AppKit
import UniformTypeIdentifiers

class ClipboardWriter {
    private let pasteboard = NSPasteboard.general

    // Write text
    func writeText(_ text: String) -> Bool {
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .plainText)
    }

    // Write image (multiple formats)
    func writeImage(_ image: NSImage, includeTiff: Bool = true) -> Bool {
        pasteboard.clearContents()

        var success = false

        // PNG
        if let pngData = image.tiffRepresentation?.using(.png) {
            pasteboard.setData(pngData, forType: .png)
            success = true
        }

        // TIFF (optional, for compatibility)
        if includeTiff, let tiffData = image.tiffRepresentation {
            pasteboard.setData(tiffData, forType: .tiff)
            success = true
        }

        return success
    }

    // Write URL
    func writeURL(_ url: URL) -> Bool {
        pasteboard.clearContents()

        // Write URL directly
        guard pasteboard.setData(url.dataRepresentation, forType: .url) else {
            return false
        }

        // Also write as text for compatibility
        pasteboard.setString(url.absoluteString, forType: .string)

        return true
    }

    // Write files
    func writeFiles(_ files: [URL]) -> Bool {
        pasteboard.clearContents()

        let fileURLs = files.compactMap { url in
            url as NSURL
        } as [NSURL]

        return pasteboard.writeObjects(fileURLs)
    }

    // Write RTF
    func writeRTF(from attributedString: NSAttributedString) -> Bool {
        pasteboard.clearContents()

        guard let data = attributedString.data(
            from: NSRange(location: 0, length: attributedString.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        ) else {
            return false
        }

        return pasteboard.setData(data, forType: .rtf)
    }

    // Write HTML
    func writeHTML(_ html: String) -> Bool {
        pasteboard.clearContents()

        guard let data = html.data(using: .utf8) else {
            return false
        }

        return pasteboard.setData(data, forType: .html)
    }

    // Write multiple types
    func writeMultiple(types: [(String, Data)]) -> Bool {
        pasteboard.clearContents()

        var success = true
        for (type, data) in types {
            let pasteboardType = PasteboardType(type)
            if !pasteboard.setData(data, forType: pasteboardType) {
                success = false
            }
        }

        return success
    }
}
```

### Convert Between Types

```swift
import AppKit
import UniformTypeIdentifiers

class ClipboardTypeConverter {
    // Image to PNG data
    static func convertImageToPNG(_ image: NSImage) -> Data? {
        return image.tiffRepresentation?.using(.png)
    }

    // Image to JPEG data
    static func convertImageToJPEG(_ image: NSImage, quality: CGFloat = 0.9) -> Data? {
        return image.tiffRepresentation?.using(.jpeg, compressionFactor: quality)
    }

    // HTML to plain text
    static func stripHTMLTags(_ html: String) -> String {
        guard let data = html.data(using: .utf8),
              let attributed = try? NSAttributedString(data: data, options: [
                  .documentType: NSAttributedString.DocumentType.html,
                  .characterEncoding: String.Encoding.utf8.rawValue
              ], documentAttributes: nil) else {
            return html
        }
        return attributed.string
    }

    // RTF to plain text
    static func rtfToPlainText(_ rtfData: Data) -> String? {
        guard let attributed = try? NSAttributedString(
            data: rtfData,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        ) else {
            return nil
        }
        return attributed.string
    }

    // Plain text to HTML
    static func plainTextToHTML(_ text: String) -> String {
        let escaped = text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\n", with: "<br>")
        return """
        <!DOCTYPE html>
        <html>
        <body>\(escaped)</body>
        </html>
        """
    }

    // Get best available type from multiple options
    static func getBestAvailableType(from types: [PasteboardType], preferences: [PasteboardType]) -> PasteboardType? {
        for preferred in preferences {
            if types.contains(preferred) {
                return preferred
            }
        }
        return nil
    }
}
```

### Unified Clipboard Item Model

```swift
import AppKit
import UniformTypeIdentifiers

struct ClipboardItem: Identifiable, Hashable {
    let id: UUID
    let type: ClipboardContentType
    let timestamp: Date
    let sourceApp: String?

    // Storage for the actual content
    private var textContent: String?
    private var imageData: Data?
    private var urlContent: URL?
    private var fileURLs: [URL]? = []
    private var rtfData: Data?
    private var htmlContent: String?

    init(
        id: UUID = UUID(),
        type: ClipboardContentType,
        timestamp: Date = Date(),
        sourceApp: String? = nil,
        text: String? = nil,
        imageData: Data? = nil,
        url: URL? = nil,
        fileURLs: [URL]? = nil,
        rtf: Data? = nil,
        html: String? = nil
    ) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.sourceApp = sourceApp
        self.textContent = text
        self.imageData = imageData
        self.urlContent = url
        self.fileURLs = fileURLs
        self.rtfData = rtf
        self.htmlContent = html
    }

    // Computed properties
    var formattedTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    var previewText: String? {
        switch type {
        case .text, .rtf, .url:
            return textContent ?? urlContent?.absoluteString
        case .file:
            return fileURLs?.map { $0.lastPathComponent }.joined(separator: ", ")
        case .image:
            return "Image"
        case .html:
            return "HTML content"
        case .custom:
            return "Custom content"
        }
    }

    var appIcon: NSImage? {
        guard let bundleId = sourceApp,
              let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)?.path else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: path)
    }

    var estimatedSize: Int {
        switch type {
        case .text:
            return textContent?.utf8.count ?? 0
        case .url:
            return urlContent?.absoluteString.utf8.count ?? 0
        case .image:
            return imageData?.count ?? 0
        case .file:
            return 100 // Rough estimate
        case .rtf:
            return rtfData?.count ?? 0
        case .html:
            return htmlContent?.utf8.count ?? 0
        case .custom:
            return 50 // Rough estimate
        }
    }

    func formattedSize() -> String {
        let bytes = estimatedSize
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024)
        } else {
            return String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
        }
    }

    // Copy to clipboard
    func copyToClipboard() -> Bool {
        let writer = ClipboardWriter()

        switch type {
        case .text:
            guard let text = textContent else { return false }
            return writer.writeText(text)

        case .url:
            guard let url = urlContent else { return false }
            return writer.writeURL(url)

        case .image(let imageType):
            if let data = imageData {
                if let image = NSImage(data: data) {
                    return writer.writeImage(image, includeTiff: !imageType.rawValue.contains("png"))
                }
            }
            return false

        case .file(let files):
            return writer.writeFiles(files)

        case .rtf:
            guard let data = rtfData else { return false }
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            return pasteboard.setData(data, forType: .rtf)

        case .html:
            guard let html = htmlContent else { return false }
            return writer.writeHTML(html)

        case .custom:
            return false
        }
    }
}
```

### Type-Specific Preview Generators

```swift
import AppKit

struct ClipboardItemPreview {
    static func generatePreview(for item: ClipboardItem) -> some View {
        VStack {
            switch item.type {
            case .image:
                ImagePreview(item: item)
            case .text:
                TextPreview(item: item)
            case .url:
                URLPreview(item: item)
            case .file:
                FilePreview(item: item)
            case .rtf:
                RTFPreview(item: item)
            case .html:
                HTMLPreview(item: item)
            case .custom:
                CustomPreview(item: item)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    struct ImagePreview: View {
        let item: ClipboardItem

        @State private var image: NSImage?

        var body: some View {
            Group {
                if let image = image ?? item.imageData.flatMap({ NSImage(data: $0) }) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                } else {
                    Text("No image data")
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                self.image = item.imageData.flatMap { NSImage(data: $0) }
            }
        }
    }

    struct TextPreview: View {
        let item: ClipboardItem

        var body: some View {
            if let text = item.textContent {
                ScrollView {
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding()
                }
            }
        }
    }

    struct URLPreview: View {
        let item: ClipboardItem

        var body: some View {
            if let url = item.urlContent {
                VStack(alignment: .leading) {
                    Label(url.host ?? "URL", systemImage: "link")
                        .font(.headline)

                    Text(url.absoluteString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)

                    if let text = item.textContent {
                        Divider()
                        Text(text)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                }
                .padding()
            }
        }
    }

    struct FilePreview: View {
        let item: ClipboardItem

        var body: some View {
            if let files = item.fileURLs, !files.isEmpty {
                VStack(alignment: .leading) {
                    Label("\(files.count) file(s)", systemImage: "doc.folder")
                        .font(.headline)

                    List(files, id: \.self) { file in
                        HStack {
                            Image(systemName: fileIcon(for: file))
                                .foregroundColor(.accentColor)
                            Text(file.lastPathComponent)
                                .textSelection(.enabled)
                            Spacer()
                            Text(file.path)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }

        private func fileIcon(for url: URL) -> String {
            let ext = url.pathExtension.lowercased()
            switch ext {
            case "png", "jpg", "jpeg", "gif": return "photo"
            case "pdf": return "doc.pdf"
            case "zip", "tar", "gz": return "archivebox"
            case "mp3", "wav", "aac": return "music.note"
            case "mp4", "mov", "avi": return "video"
            default: return "doc"
            }
        }
    }

    struct RTFPreview: View {
        let item: ClipboardItem

        var body: some View {
            if let rtfData = item.rtfData,
               let attributedString = try? NSAttributedString(
                data: rtfData,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
               ) {
                AttributedText(attributedString)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }

    struct HTMLPreview: View {
        let item: ClipboardItem

        var body: some View {
            if let html = item.htmlContent {
                ScrollView {
                    Text(html)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding()
                        .font(.system(.caption, design: .monospaced))
                }
            }
        }
    }

    struct CustomPreview: View {
        let item: ClipboardItem

        var body: some View {
            VStack {
                Label("Custom Format", systemImage: "doc.text")
                Text(item.type.id)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AttributedText: NSViewRepresentable {
    let attributedString: NSAttributedString

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.textStorage?.setAttributedString(attributedString)
        textView.drawsBackground = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.textContainer?.widthTracksTextView = true
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {}
}
```

## Implementation Considerations

### Type Priority Order
When detecting clipboard content, check types in this priority order:
1. Files (most specific)
2. Images
3. URLs
4. Rich Text formats (HTML, RTF)
5. Plain text (fallback)

### Memory Management
- Images can be large - consider thumbnail generation for preview
- Store file URLs instead of file contents
- Consider compressing large data for storage

### Type Compatibility
Not all apps support all clipboard types:
- Always include plain text as fallback
- Provide RTF and HTML for text with formatting
- Include TIFF for images for wider compatibility

## Potential Pitfalls to Avoid

### 1. Not Checking Available Types First

```swift
// BAD - Assumes type is available
let text = pasteboard.string(forType: .string) // May fail

// GOOD - Check first
if pasteboard.types?.contains(.string) == true {
    let text = pasteboard.string(forType: .string)
}
```

### 2. Forgetting Fallback Types

```swift
// BAD - Only sets custom type
pasteboard.setData(data, forType: .custom)

// GOOD - Include fallback
pasteboard.setData(data, forType: .custom)
pasteboard.setString(text, forType: .string) // Fallback
```

### 3. Not Handling Images Properly

```swift
// BAD - Expects tiffRepresentation to always exist
let tiff = image.tiffRepresentation

// GOOD - Handle multiple formats
guard let tiff = image.tiffRepresentation else { return }
let png = tiff.using(.png)
pasteboard.setData(png, forType: .png)
pasteboard.setData(tiff, forType: .tiff)
```

### 4. Memory Issues with Large Files

```swift
// BAD - Storing file contents
let fileData = try? Data(contentsOf: fileURL)

// GOOD - Store URL only
let fileURL = fileURL
```

## Apple Documentation References

- [Uniform Type Identifiers](https://developer.apple.com/documentation/uniformtypeidentifiers)
- [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard)
- [Pasteboard Types](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PasteboardGuide106/Articles/UsingPasteboard.html)
- [System Declared UTIs](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html)

## Standard Pasteboard Types

| UTI | PasteboardType Constant | Description |
|-----|------------------------|-------------|
| `public.utf8-plain-text` | `.plainText` | Plain text UTF-8 |
| `public.text` | `.string` | Generic text |
| `public.rtf` | `.rtf` | Rich Text Format |
| `public.html` | `.html` | HTML |
| `public.url` | `.url` | URL string |
| `public.file-url` | `.fileURL` | File reference URL |
| `public.png` | `.png` | PNG image |
| `public.tiff` | `.tiff` | TIFF image |
| `public.jpeg` | `.jpeg` | JPEG image |
| `com.adobe.pdf` | - | PDF document |
| `com.apple.pasteboard.color` | `.color` | NSColor |

## Best Practices Summary

1. **Check Before Reading**: Always verify the type exists before attempting to read
2. **Provide Fallbacks**: Include plain text as fallback for formatted content
3. **Store Type Metadata**: Remember what type the original content was
4. **Generate Thumbnails**: For images, don't store full resolution
5. **Handle Conversion**: Provide conversion between compatible formats
6. **File URL > Content**: Reference files, don't copy their contents
7. **Multiple Formats**: Write multiple compatible formats when possible
8. **Preview Wisely**: Generate lightweight previews for UI
9. **Respect Size Limits**: Don't store unlimited clipboard history
10. **Source Tracking**: Track which application provided the clipboard content

<!-- nav -->

---

[< Previous: Background Daemon Lifecycle for macOS Applications](04-background-daemon.md) | [Table of Contents](../../product-spec.md) | [Next: SQLite Integration in Swift for Local Persistence >](06-sqlite-persistence.md)

<!-- nav -->
