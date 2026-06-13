# System Integrations — SwiftUI macOS

## Spotlight (Core Spotlight)

Index app content so it appears in Spotlight search:

```swift
import CoreSpotlight

func indexItem(_ item: MyItem) {
    let attributes = CSSearchableItemAttributeSet(contentType: .text)
    attributes.title = item.title
    attributes.contentDescription = item.summary
    attributes.thumbnailData = item.thumbnailData
    attributes.keywords = item.tags

    let searchItem = CSSearchableItem(
        uniqueIdentifier: item.id.uuidString,
        domainIdentifier: "com.example.myapp.items",
        attributeSet: attributes
    )
    searchItem.expirationDate = .distantFuture

    CSSearchableIndex.default().indexSearchableItems([searchItem]) { error in
        if let error { print("Spotlight index error: \(error)") }
    }
}

func removeItem(id: UUID) {
    CSSearchableIndex.default().deleteSearchableItems(
        withIdentifiers: [id.uuidString]
    ) { _ in }
}
```

Handle Spotlight-initiated opens in your App:

```swift
.onContinueUserActivity(CSSearchableItemActionType) { activity in
    guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String
    else { return }
    openItem(id: id)
}
```

---

## Quick Look Preview

### In-App Preview Panel

```swift
import QuickLookUI

Button("Preview") {
    QLPreviewPanel.shared().makeKeyAndOrderFront(nil)
}

// Implement QLPreviewPanelDataSource on NSWindowDelegate or NSViewController:
class MyController: NSViewController, QLPreviewPanelDataSource {
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int { 1 }
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        fileURL as NSURL
    }
}
```

SwiftUI wrapper via `.quickLookPreview`:

```swift
@State private var previewURL: URL? = nil

SomeView()
    .quickLookPreview($previewURL)  // macOS 13+
```

### Quick Look Extension (Finder thumbnails/previews)

Create a `QLPreviewingController` in an App Extension target — same approach as iOS.

---

## Share Extensions / NSSharingService

```swift
// Share sheet
ShareLink(item: myURL, subject: Text("Check this out"), message: Text("Sharing via My App"))

// Programmatic
ShareLink(item: exportedFileURL) {
    Label("Share", systemImage: "square.and.arrow.up")
}

// AppKit for more control:
let picker = NSSharingServicePicker(items: [url, text])
picker.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
```

---

## App Intents / Shortcuts

```swift
import AppIntents

struct SearchItemsIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Items"
    static var description = IntentDescription("Search your items by keyword")

    @Parameter(title: "Query") var query: String

    func perform() async throws -> some ReturnsValue<[ItemEntity]> {
        let results = await ItemStore.shared.search(query)
        return .result(value: results.map(ItemEntity.init))
    }
}

// Entity for returning rich results
struct ItemEntity: AppEntity {
    var id: UUID
    var title: String
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Item"
    static var defaultQuery = ItemEntityQuery()
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}
```

Register in your App struct (automatic for types conforming to `AppIntent`). Appears in Shortcuts.app and Spotlight suggestions.

---

## Services Menu

Implement `NSServicesMenuRequestor` to receive text/images from other apps:

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?,
                                  returnType: NSPasteboard.PasteboardType?) -> Any? {
        if returnType == .string { return self }
        return super.validRequestor(forSendType: sendType, returnType: returnType)
    }

    func readSelection(from pboard: NSPasteboard) -> Bool {
        guard let text = pboard.string(forType: .string) else { return false }
        processServiceInput(text)
        return true
    }
}
```

Register service in `Info.plist` under `NSServices`:

```xml
<key>NSServices</key>
<array>
    <dict>
        <key>NSMenuItem</key>
        <dict><key>default</key><string>Process with My App</string></dict>
        <key>NSMessage</key><string>processServiceInput:</string>
        <key>NSReturnTypes</key><array><string>NSStringPboardType</string></array>
    </dict>
</array>
```

---

## AppleScript Support

Enable scripting in `Info.plist`:

```xml
<key>NSAppleScriptEnabled</key><true/>
<key>OSAScriptingDefinition</key><string>MyApp.sdef</string>
```

Implement in `AppDelegate`:

```swift
@objc func handleGetURLEvent(_ event: NSAppleEventDescriptor,
                              replyEvent: NSAppleEventDescriptor) {
    guard let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
          let url = URL(string: urlString) else { return }
    openURL(url)
}
```

Define object model in `.sdef` XML file (standard suite + custom commands/classes).

---

## URL Schemes

Register in `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array><string>myapp</string></array>
        <key>CFBundleURLName</key>
        <string>com.example.myapp</string>
    </dict>
</array>
```

Handle in SwiftUI:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Router.shared.handle(url)
                }
        }
    }
}
```

Parse URL: `myapp://action/path?param=value`

```swift
func handle(_ url: URL) {
    guard url.scheme == "myapp" else { return }
    switch url.host {
    case "open":  openItem(id: url.lastPathComponent)
    case "share": handleShare(url.queryParameters)
    default: break
    }
}
```

---

## Common Pitfalls

- Spotlight indexing requires `NSUserActivity` or `CSSearchableIndex` — neither works in a fully sandboxed context without the `com.apple.security.personal-information.location` or relevant entitlements for content types.
- `App Intents` require the app to have run at least once after install before Siri/Shortcuts picks them up.
- Services menu items only appear when the app is registered — run the app once for the system to cache the services.
- URL scheme handlers fire on the main thread — dispatch heavy work off-thread immediately.
- `QLPreviewPanel` must be driven from the main thread; panel data source calls are synchronous.
