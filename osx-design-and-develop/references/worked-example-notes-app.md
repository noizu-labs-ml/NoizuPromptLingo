# Worked Example: Document-Based Notes App

A full walkthrough building a Markdown notes app using `DocumentGroup`, `NavigationSplitView`, a live markdown editor, toolbar actions, keyboard shortcuts, sandboxing, and document lifecycle testing.

---

## App Overview

| Attribute | Value |
|-----------|-------|
| App name | SwiftNotes |
| App type | Document-based |
| Window topology | NavigationSplitView (sidebar + editor) |
| File format | `.md` (plain UTF-8 text) |
| Min macOS | 14.0 (Sonoma) |
| Distribution | Mac App Store (sandboxed) |

---

## 1. Document Model

Define a `FileDocument` conforming to `ReferenceFileDocument` so SwiftUI can manage open/save/revert automatically.

```swift
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var markdownText: UTType {
        UTType(importedAs: "net.daringfireball.markdown")
    }
}

@Observable
final class NoteDocument: ReferenceFileDocument {
    static var readableContentTypes: [UTType] { [.markdownText, .plainText] }
    static var writableContentTypes: [UTType] { [.markdownText] }

    var text: String

    init(text: String = "# Untitled Note\n\n") {
        self.text = text
    }

    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else { throw CocoaError(.fileReadCorruptFile) }
        text = string
    }

    func snapshot(contentType: UTType) throws -> String { text }

    func fileWrapper(snapshot: String, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = snapshot.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}
```

**Why `ReferenceFileDocument`?** It supports undo history via `UndoManager` injection and avoids full-document copies on every keystroke.

---

## 2. App Entry Point

```swift
@main
struct SwiftNotesApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { NoteDocument() }) { file in
            ContentView(document: file.$document)
                .frame(minWidth: 700, minHeight: 450)
        }
        .commands {
            NoteCommands()
        }
    }
}
```

`DocumentGroup` wires open/save/revert/print into the system File menu automatically. No manual `NSOpenPanel` needed.

---

## 3. ContentView with NavigationSplitView

```swift
struct ContentView: View {
    @Binding var document: NoteDocument
    @State private var selectedSection: String? = "editor"

    var body: some View {
        NavigationSplitView {
            Sidebar(document: document, selection: $selectedSection)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            EditorView(document: $document)
        }
        .navigationTitle(document.text.firstLine ?? "Untitled")
        .navigationSubtitle(document.wordCount)
    }
}

private extension String {
    var firstLine: String? { components(separatedBy: "\n").first?.trimmingCharacters(in: .whitespaces) }
    var wordCount: String {
        let count = components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        return "\(count) words"
    }
}
```

---

## 4. Editor View

Use `TextEditor` for a native feel; inject `UndoManager` so undo/redo flows through the document lifecycle.

```swift
struct EditorView: View {
    @Binding var document: NoteDocument
    @Environment(\.undoManager) private var undoManager

    var body: some View {
        TextEditor(text: Binding(
            get: { document.text },
            set: { newValue in
                undoManager?.registerUndo(withTarget: document) { doc in
                    doc.text = document.text
                }
                document.text = newValue
            }
        ))
        .font(.system(.body, design: .monospaced))
        .padding(12)
    }
}
```

---

## 5. Toolbar Actions

```swift
struct EditorView: View {
    // ... existing properties

    var body: some View {
        TextEditor(text: ...)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Bold", systemImage: "bold") { insertMarkdown("**", "**") }
                    Button("Italic", systemImage: "italic") { insertMarkdown("_", "_") }
                    Divider()
                    Button("Export PDF", systemImage: "doc.richtext") { exportPDF() }
                }
            }
    }

    private func insertMarkdown(_ prefix: String, _ suffix: String) {
        // Wrap selected text or insert at cursor
        document.text += "\(prefix)text\(suffix)"
    }

    private func exportPDF() {
        // NSSavePanel + NSAttributedString rendering
    }
}
```

---

## 6. Keyboard Shortcuts via Commands

```swift
struct NoteCommands: Commands {
    var body: some Commands {
        CommandMenu("Note") {
            Button("Insert Heading") {
                NotificationCenter.default.post(name: .insertHeading, object: nil)
            }
            .keyboardShortcut("h", modifiers: [.command, .shift])

            Button("Word Count") {
                NotificationCenter.default.post(name: .showWordCount, object: nil)
            }
            .keyboardShortcut("w", modifiers: [.command, .option])
        }
    }
}

extension Notification.Name {
    static let insertHeading = Notification.Name("insertHeading")
    static let showWordCount = Notification.Name("showWordCount")
}
```

Use `NotificationCenter` to decouple commands from view state — commands live at app scope but views are document-scoped.

---

## 7. Sidebar with Outline

```swift
struct Sidebar: View {
    var document: NoteDocument
    @Binding var selection: String?

    private var headings: [String] {
        document.text.components(separatedBy: "\n")
            .filter { $0.hasPrefix("#") }
    }

    var body: some View {
        List(selection: $selection) {
            Section("Outline") {
                ForEach(headings, id: \.self) { heading in
                    Label(heading.trimmingCharacters(in: CharacterSet(charactersIn: "# ")),
                          systemImage: "text.alignleft")
                        .tag(heading)
                }
            }
        }
        .listStyle(.sidebar)
    }
}
```

---

## 8. Sandbox Entitlements

`SwiftNotes.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0"><dict>
    <key>com.apple.security.app-sandbox</key><true/>
    <key>com.apple.security.files.user-selected.read-write</key><true/>
    <key>com.apple.security.print</key><true/>
</dict></plist>
```

- `user-selected.read-write` — required for `DocumentGroup` open/save
- Do NOT add `files.all` — App Store will reject it
- Bookmark security-scoped URLs if you need persistent access outside the document

---

## 9. Document Lifecycle Testing

```swift
import XCTest
@testable import SwiftNotes

final class NoteDocumentTests: XCTestCase {

    func test_roundtrip_preserves_content() throws {
        let original = NoteDocument(text: "# Hello\n\nWorld")
        let snapshot = try original.snapshot(contentType: .markdownText)
        let wrapper = try original.fileWrapper(snapshot: snapshot, configuration: .init(existingFile: nil))

        let readConfig = FileDocumentReadConfiguration(contentType: .markdownText, existingFile: wrapper)
        let restored = try NoteDocument(configuration: readConfig)
        XCTAssertEqual(restored.text, original.text)
    }

    func test_corrupt_file_throws() {
        let wrapper = FileWrapper(regularFileWithContents: Data([0xFF, 0xFE]))
        let config = FileDocumentReadConfiguration(contentType: .markdownText, existingFile: wrapper)
        XCTAssertThrowsError(try NoteDocument(configuration: config))
    }
}
```

Run with `xcodebuild test -scheme SwiftNotes -destination 'platform=macOS'`.

---

## 10. Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| `@Binding var document` in child views loses undo | Inject `@Environment(\.undoManager)` and register manually |
| `NavigationSplitView` sidebar collapses on small windows | Set `minWidth` on the column |
| File extension not registered | Add `UTI` declaration to `Info.plist` under `CFBundleDocumentTypes` |
| `TextEditor` ignores `.font()` | Use `.font()` before `.padding()` and confirm macOS 14+ |
| Undo crosses document save boundary | Call `undoManager?.removeAllActions()` after save if needed |

---

## Key Takeaways

- `DocumentGroup` + `ReferenceFileDocument` gives you open/save/revert/print for free
- `NavigationSplitView` is the correct primitive for sidebar + detail layouts on macOS 13+
- Commands are app-scoped; communicate to views via `NotificationCenter` or `FocusedBinding`
- Sandbox entitlements must be minimal — plan them before first build
- Test document round-trips as unit tests, not just manually
