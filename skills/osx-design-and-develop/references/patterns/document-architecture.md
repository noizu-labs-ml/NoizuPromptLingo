# Document Architecture — SwiftUI macOS

## DocumentGroup Scene

```swift
@main
struct MyApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { TextDocument() }) { config in
            ContentView(document: config.$document)
        }
    }
}
```

`DocumentGroup` handles: open/save dialogs, recent documents, window titling, autosave, versioning.

---

## FileDocument (Value Semantics)

Use for formats where the full file fits in memory.

```swift
struct TextDocument: FileDocument {
    var text: String = ""

    static var readableContentTypes: [UTType] { [.plainText] }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
```

---

## ReferenceFileDocument (Reference Semantics)

Use for large files or when you need partial writes / undo snapshots.

```swift
class JSONDocument: ReferenceFileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    @Published var items: [Item] = []

    required init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents ?? Data()
        items = try JSONDecoder().decode([Item].self, from: data)
    }

    func snapshot(contentType: UTType) throws -> [Item] {
        items  // snapshot for background write
    }

    func fileWrapper(snapshot: [Item], configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(snapshot)
        return FileWrapper(regularFileWithContents: data)
    }
}
```

`snapshot()` is called on the main thread; `fileWrapper` runs on a background thread.

---

## UTType Registration

In `Info.plist` (or via Xcode target settings):

```xml
<key>UTExportedTypeDeclarations</key>
<array>
    <dict>
        <key>UTTypeIdentifier</key>  <string>com.example.myformat</string>
        <key>UTTypeDescription</key> <string>My Format</string>
        <key>UTTypeConformsTo</key>  <array><string>public.data</string></array>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key> <array><string>myfmt</string></array>
        </dict>
    </dict>
</array>
```

In code:

```swift
extension UTType {
    static let myFormat = UTType(exportedAs: "com.example.myformat")
}
```

---

## Undo / Redo

`DocumentGroup` injects an `UndoManager` into the environment automatically.

```swift
struct ContentView: View {
    @Binding var document: TextDocument
    @Environment(\.undoManager) private var undoManager

    func updateText(_ newValue: String) {
        let old = document.text
        document.text = newValue
        undoManager?.registerUndo(withTarget: document as AnyObject) { _ in
            self.document.text = old
        }
        undoManager?.setActionName("Edit Text")
    }
}
```

For `ReferenceFileDocument`, use `UndoManager` on the document object directly since it's a reference type.

---

## Autosave and Versioning

`DocumentGroup` autosaves based on system policy (typically after edits settle). To mark a document dirty:

```swift
// FileDocument: any @Binding mutation triggers dirty state automatically
// ReferenceFileDocument: call on document object
document.objectWillChange.send()
```

File versioning (Browse All Versions) is automatic for sandboxed apps. Opt out per-window:

```swift
.windowStyle(.titleBar)  // versioning UI appears in title bar by default
```

---

## Recent Documents

Managed automatically by `DocumentGroup`. Access via:

```swift
NSDocumentController.shared.recentDocumentURLs
```

Clear programmatically:

```swift
NSDocumentController.shared.clearRecentDocuments(nil)
```

---

## Quick Look Thumbnails

Register a `QLThumbnailProvider` extension target. Implement:

```swift
class ThumbnailProvider: QLThumbnailProvider {
    override func provideThumbnail(
        for request: QLFileThumbnailRequest,
        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
    ) {
        let reply = QLThumbnailReply(contextSize: request.maximumSize) { context in
            // Draw into CGContext
            return true
        }
        handler(reply, nil)
    }
}
```

Declare in extension `Info.plist` under `QLSupportedContentTypes`.

---

## Common Pitfalls

- `FileDocument` `init(configuration:)` must not fail silently — throw to surface read errors.
- `ReferenceFileDocument.snapshot()` is called on main thread; keep it fast (copy, don't encode).
- UTType must be declared in `Info.plist` **and** in `readableContentTypes` — mismatch causes open dialog to reject files.
- Undo registration after every binding change adds overhead; batch with `withAnimation` or debounce.
- `DocumentGroup` doesn't support `defaultSize` — use `NSWindowDelegate` or `WindowAccessor` to set initial frame.
