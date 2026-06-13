# Drag and Drop — SwiftUI macOS

## Transferable Protocol

`Transferable` is the modern (macOS 13+) type-safe DnD API. Conform your model:

```swift
struct ColorSwatch: Transferable {
    var color: Color
    var name: String

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .colorSwatch)
        ProxyRepresentation(exporting: \.name)  // fallback: plain text
    }
}

extension UTType {
    static let colorSwatch = UTType(exportedAs: "com.example.colorswatch")
}
```

Multiple representations are tried in order — most specific first.

---

## .draggable

```swift
ForEach(swatches) { swatch in
    SwatchView(swatch: swatch)
        .draggable(swatch)                          // Transferable item
        // With custom preview:
        .draggable(swatch) {
            RoundedRectangle(cornerRadius: 8)
                .fill(swatch.color)
                .frame(width: 60, height: 60)
        }
}
```

Drag multiple items by wrapping in an array if your `Transferable` type is an array, or use `draggable` with a custom `NSItemProvider`.

---

## .dropDestination

```swift
SwatchPalette()
    .dropDestination(for: ColorSwatch.self) { swatches, location in
        palette.append(contentsOf: swatches)
        return true  // accepted
    } isTargeted: { isOver in
        isHighlighted = isOver
    }
```

`location` is in the coordinate space of the drop target view.

For multiple accepted types, use the most specific `Transferable` conformance; the system picks the best match.

---

## File Drop (UTType)

```swift
.dropDestination(for: URL.self) { urls, _ in
    for url in urls {
        openFile(url)
    }
    return !urls.isEmpty
}
```

`URL` conforms to `Transferable` automatically and matches `public.file-url`. To accept only specific file types, filter in the handler or use a custom `Transferable` wrapper.

---

## File Promises (Deferred File Creation)

For exporting files that are expensive to create:

```swift
// Draggable with file promise
Text("Drag to export")
    .onDrag {
        let provider = NSItemProvider()
        provider.registerFileRepresentation(
            forTypeIdentifier: UTType.pdf.identifier,
            fileOptions: [],
            visibility: .all
        ) { completion in
            DispatchQueue.global().async {
                let url = self.generatePDF()
                completion(url, true, nil)
            }
            return Progress(totalUnitCount: 1)
        }
        return provider
    }
```

Receiving file promises:

```swift
.onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
    for provider in providers {
        _ = provider.loadFileRepresentation(forTypeIdentifier: UTType.pdf.identifier) { url, error in
            if let url { DispatchQueue.main.async { openFile(url) } }
        }
    }
    return true
}
```

---

## Inter-App Drag with NSItemProvider

When `Transferable` isn't sufficient (legacy apps, custom pasteboard types):

```swift
.onDrag {
    let provider = NSItemProvider(object: myString as NSString)
    provider.suggestedName = "Export"
    return provider
}

.onDrop(of: [.plainText], isTargeted: nil) { providers in
    for p in providers {
        p.loadObject(ofClass: NSString.self) { string, _ in
            if let s = string as? String {
                DispatchQueue.main.async { process(s) }
            }
        }
    }
    return true
}
```

---

## NSDraggingDestination (AppKit Bridge)

For fine-grained control (enter/exit/updated callbacks, custom rendering):

```swift
class DropView: NSView, NSDraggingDestination {
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    override func draggingExited(_ sender: NSDraggingInfo?) { }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let data = sender.draggingPasteboard.data(forType: .string) else { return false }
        // process data
        return true
    }
}
```

Wrap in `NSViewRepresentable` to use in SwiftUI.

---

## Pasteboard (Copy/Paste Coordination)

```swift
// Write
NSPasteboard.general.clearContents()
NSPasteboard.general.setString("hello", forType: .string)
NSPasteboard.general.writeObjects([image])  // NSImage, NSColor, NSURL, etc.

// Read
let string = NSPasteboard.general.string(forType: .string)
let urls = NSPasteboard.general.readObjects(forClasses: [NSURL.self]) as? [URL]
```

SwiftUI `.onCopyCommand` / `.onPasteCommand` for view-level copy/paste:

```swift
.onCopyCommand {
    [NSItemProvider(object: selectedText as NSString)]
}
.onPasteCommand(of: [.plainText]) { providers in
    // handle paste
}
```

---

## Common Pitfalls

- `Transferable` representations are tried in declared order — put the richest first, plain text last.
- `.dropDestination` requires the dropped type to exactly match; mismatched `UTType` identifiers silently reject.
- File promise completion must call `completion(url, false, nil)` with `inPlace: false` for copies.
- `onDrag` returns `NSItemProvider` — returning `NSItemProvider()` (empty) shows a drag but drops nothing.
- Drag previews are clipped to 400×400 pts; scale down large previews explicitly.
- Sandbox restricts file access — dropped file URLs need security-scoped resource access: `url.startAccessingSecurityScopedResource()`.
