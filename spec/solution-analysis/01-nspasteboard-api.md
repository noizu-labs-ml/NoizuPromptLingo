# NSPasteboard API Usage and Best Practices

## Overview

NSPasteboard is the macOS API for handling clipboard/pasteboard operations. It's the core mechanism for copying and pasting data within and between applications in macOS.

## Core Concepts

### Pasteboard Types
- **Pasteboard**: A container for shared data between applications
- **Types**: UTI (Uniform Type Identifier) strings that describe data formats
- **Ownership**: Only one application can own a pasteboard at a time
- **Change Counting**: Track changes to detect clipboard modifications

## Key APIs and Frameworks

| API/Framework | Purpose |
|--------------|---------|
| `AppKit.NSPasteboard` | Main pasteboard API |
| `UTType` | Type identification using UTIs |
| `PasteboardType` | Swift wrapper for pasteboard type strings |
| `NSPasteboardWriting` | Protocol for custom pasteboard writing |
| `NSPasteboardReading` | Protocol for custom pasteboard reading |

## Swift Code Examples

### Basic Clipboard Reading

```swift
import AppKit

class ClipboardManager {
    let pasteboard = NSPasteboard.general

    func getCurrentClipboardType() -> String? {
        // Get available types on the pasteboard
        guard let availableTypes = pasteboard.types else {
            return nil
        }

        // Check for common types in priority order
        if availableTypes.contains(.fileURL) {
            return "file"
        } else if availableTypes.contains(.png) || availableTypes.contains(.tiff) {
            return "image"
        } else if availableTypes.contains(.url) {
            return "url"
        } else if availableTypes.contains(.string) {
            return "text"
        } else if availableTypes.contains(.rtf) {
            return "rtf"
        }

        return nil
    }

    func readString() -> String? {
        return pasteboard.string(forType: .string)
    }

    func readImage() -> NSImage? {
        guard let data = pasteboard.data(forType: .tiff) ??
                       pasteboard.data(forType: .png) else {
            return nil
        }
        return NSImage(data: data)
    }

    func readURL() -> URL? {
        guard let data = pasteboard.data(forType: .url) else {
            return nil
        }
        return URL(dataRepresentation: data, relativeTo: nil)
    }
}
```

### Clipboard Change Monitoring

```swift
import AppKit

class ClipboardMonitor {
    private var changeCount: Int = 0
    private let pasteboard = NSPasteboard.general
    private var timer: Timer?

    func startMonitoring(interval: TimeInterval = 0.5, callback: @escaping () -> Void) {
        changeCount = pasteboard.changeCount

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.pasteboard.changeCount != self.changeCount {
                self.changeCount = self.pasteboard.changeCount
                callback()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
}
```

### Custom Pasteboard Types

```swift
import AppKit

extension PasteboardType {
    static let customAppType = PasteboardType("com.yourapp.clipboardItem")
}

struct ClipboardItem: NSPasteboardWriting, NSPasteboardReading {
    let id: UUID
    let type: String
    let content: String
    let timestamp: Date

    // NSPasteboardWriting
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.customAppType]
    }

    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        guard type == .customAppType else { return nil }

        return [
            "id": id.uuidString,
            "type": type,
            "content": content,
            "timestamp": timestamp.timeIntervalSince1970
        ]
    }

    // NSPasteboardReading
    static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.customAppType]
    }

    static func readingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {
        return .asKeyedArchive
    }

    init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        guard let dict = propertyList as? [String: Any],
              let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let type = dict["type"] as? String,
              let content = dict["content"] as? String,
              let timestampInterval = dict["timestamp"] as? TimeInterval else {
            return nil
        }

        self.id = id
        self.type = type
        self.content = content
        self.timestamp = Date(timeIntervalSince1970: timestampInterval)
    }
}
```

### Reading File Lists

```swift
import AppKit

func readFileList() -> [URL]? {
    guard let fileURLs = NSPasteboard.general.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
        return nil
    }
    return fileURLs
}

func isFileOnPasteboard() -> Bool {
    guard let types = NSPasteboard.general.types else { return false }
    return types.contains(.fileURL)
}
```

## Implementation Considerations

### Thread Safety
- NSPasteboard methods should be called on the main thread
- For background monitoring, dispatch to main queue before accessing pasteboard

```swift
DispatchQueue.main.async {
    let clipboardContent = self.readString()
}
```

### Memory Management
- Large images on pasteboard can consume significant memory
- Consider caching strategies for clipboard history
- Release references to pasted content when not needed

### Performance
- `changeCount` property is fast and efficient for monitoring
- Avoid polling too frequently
- Use `clearContents()` with caution - it affects other apps

### Data Retention
- Pasteboard data is owned by the application that last set it
- When an application terminates, its clipboard data may be lost
- Consider implementing a "clipboard server" for persistent history

## Potential Pitfalls to Avoid

### 1. Incorrect Type Handling
```swift
// BAD - Assumes string type is always available
let text = pasteboard.string(forType: .string)!

// GOOD - Safely unwrap and check type
guard let types = pasteboard.types,
      types.contains(.string),
      let text = pasteboard.string(forType: .string) else {
    return
}
```

### 2. Blocking the Main Thread
```swift
// BAD - Long-running operation on main thread
let image = processLargeImage(pasteboard.data(forType: .tiff))

// GOOD - Offload to background queue
if let data = pasteboard.data(forType: .tiff) {
    DispatchQueue.global(qos: .userInitiated).async {
        let image = self.processLargeImage(data)
        DispatchQueue.main.async {
            self.displayImage(image)
        }
    }
}
```

### 3. Polling Too Aggressively
```swift
// BAD - Excessive polling wastes CPU
Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
    // Check clipboard
}

// GOOD - Reasonable interval
Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
    // Check clipboard
}
```

### 4. Not Handling Multiple Data Types
```swift
// BAD - Only reads strings
if let text = pasteboard.string(forType: .string) {
    // Process as text only
}

// GOOD - Check all relevant types
if pasteboard.types?.contains(.string) == true {
    handleString()
} else if pasteboard.types?.contains(.png) == true {
    handleImage()
} else if pasteboard.types?.contains(.url) == true {
    handleURL()
}
```

### 5. Ignoring Clipboard Ownership Changes
```swift
// BAD - Doesn't track when another app takes ownership
// Just reads blindly

// GOOD - Track change count to detect ownership changes
class SmartMonitor {
    var lastChangeCount: Int = 0

    func checkClipboard() {
        let currentCount = NSPasteboard.general.changeCount
        if currentCount != lastChangeCount {
            lastChangeCount = currentCount
            // Handle new content
        }
    }
}
```

## Common Pasteboard Types (UTIs)

| Type | UTI String | Description |
|------|------------|-------------|
| Text | `public.utf8-plain-text` | Plain text (UTF-8) |
| RTF | `public.rtf` | Rich Text Format |
| HTML | `public.html` | HTML content |
| URL | `public.url` | URL string |
| File URL | `public.file-url` | File reference URL |
| PNG | `public.png` | PNG image |
| TIFF | `public.tiff` | TIFF image |
| PDF | `com.adobe.pdf` | PDF document |
| Color | `com.apple.pasteboard.color` | NSColor |

## Apple Documentation References

- [NSPasteboard](https://developer.apple.com/documentation/appkit/nspasteboard)
- [NSPasteboardWriting](https://developer.apple.com/documentation/appkit/nspasteboardwriting)
- [NSPasteboardReading](https://developer.apple.com/documentation/appkit/nspastebordreading)
- [PasteboardType](https://developer.apple.com/documentation/appkit/pasteboardtype)
- [Uniform Type Identifiers](https://developer.apple.com/documentation/uniformtypeidentifiers)
- [Copy and Paste Operations](https://developer.apple.com/documentation/appkit/copy-and-paste-operations)

## Best Practices Summary

1. **Use Named Pasteboards**: `NSPasteboard.general` for system clipboard
2. **Check Types Before Reading**: Always verify available types first
3. **Monitor Change Count**: Efficient way to detect clipboard changes
4. **Handle Errors Gracefully**: Clipboard operations can fail
5. **Main Thread Access**: Perform pasteboard operations on main thread
6. **Memory Awareness**: Be mindful of large data (images, files)
7. **UTI Over Strings**: Prefer UTI-based type identification
8. **Respect Privacy**: Some applications pasteboard data may contain sensitive information
9. **Test Multiple Apps**: Verify behavior with various copier applications
10. **Consider Accessibility**: Ensure your app works with screen readers and assistive technologies

<!-- nav -->

---

[Table of Contents](../../product-spec.md) | [Next: Global Hotkey Implementation >](02-global-hotkeys.md)

<!-- nav -->
