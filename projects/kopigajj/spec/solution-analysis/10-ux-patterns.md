# Common Clipboard Manager UX Patterns

## Overview

Clipboard managers need to balance utility with minimal distraction. Understanding common UX patterns helps create a product that is both powerful and unobtrusive.

## Core Concepts

- **Minimal Intrusion**: Show only when needed
- **Quick Access**: Keyboard shortcuts and gestures
- **Visual Scanning**: Easy item identification
- **Organization**: Natural categorization and search
- **Context Awareness**: Smart features based on usage

## Key UX Patterns

| Pattern | Description |
|---------|-------------|
| Menu Bar Icon | Always-visible access point |
| Global Hotkey | Quick activation without UI |
| Search-First | Primary interface is search |
| Type-First UI | Content type organization |
| Time-Based | Chronological organization |
| Favorite/Pinned | Important items accessible |
| Preview Panes | Visual preview before selection |
| Keyboard-First | Complete keyboard navigation |

## UX Patterns and Implementations

### 1. Menu Bar Interface

The menu bar provides a persistent, minimal interface.

```swift
import SwiftUI

struct MenuBarInterface: View {
    @State private var clipboardHistory: [ClipboardItem] = []
    @State private var showWindow = false

    var body: some View {
        Menu {
            // Quick actions
            Button("Show History") {
                showWindow = true
            }
            .keyboardShortcut("v", modifiers: [.command, .shift])

            Divider()

            // Recent items (last 5)
            Menu("Recent") {
                if clipboardHistory.isEmpty {
                    Text("No recent items")
                        .disabled(true)
                } else {
                    ForEach(clipboardHistory.prefix(5)) { item in
                        Button {
                            copyItem(item)
                        } label: {
                            RecentItemRow(item: item)
                        }
                    }
                }
            }

            Divider()

            // Settings and about
            Button("Settings") {
                openSettings()
            }
            Button("About") {
                showAbout()
            }

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            // Menu bar icon
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
        }
        .menuStyle(.borderlessButton)
        .frame(width: 25)
        .sheet(isPresented: $showWindow) {
            HistoryWindow(isPresented: $showWindow)
        }
    }

    struct RecentItemRow: View {
        let item: ClipboardItem

        var body: some View {
            VStack(alignment: .leading) {
                Text(item.preview ?? "Empty")
                    .lineLimit(1)
                Text(item.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

### 2. Popup Window Pattern

A centered, floating window triggered by hotkey.

```swift
import SwiftUI

struct PopupWindow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedItem: ClipboardItem?
    @State private var selectedType: ClipboardType?

    let items: [ClipboardItem]

    var body: some View {
        popupContent
            .frame(maxWidth: 600, maxHeight: 500)
            .background(
                Rectangle()
                    .fill(Color(.windowBackgroundColor))
                    .shadow(radius: 20)
            )
            .searchable(text: $searchText)
            .onDisappear {
                // Save selection
            }
    }

    private var popupContent: some View {
        VStack(spacing: 0) {
            // Header with search
            header

            // Type filter tabs
            typeFilter

            Divider()

            // Content list
            itemList

            Divider()

            // Footer with actions
            footer
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search clipboard history...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.title3)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.escape)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }

    private var typeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                typeTab("All", type: nil)
                typeTab("Text", type: .text)
                typeTab("Images", type: .image)
                typeTab("Files", type: .file)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.controlBackgroundColor))
    }

    private func typeTab(_ label: String, type: ClipboardType?) -> some View {
        Button {
            selectedType = type
        } label: {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(selectedType == type ? Color.accentColor : Color.clear)
                .foregroundColor(selectedType == type ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private var itemList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(displayedItems) { item in
                    ClipboardListItem(item: item, isSelected: selectedItem?.id == item.id)
                        .onTapGesture {
                            selectedItem = item
                            copyItem(item)
                            dismiss()
                        }
                        .onHover { hovering in
                            // Update selection on hover
                            if hovering {
                                selectedItem = item
                            }
                        }
                }
            }
        }
    }

    private var footer: some View {
        HStack {
            Text("\(displayedItems.count) items")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            HStack(spacing: 8) {
                Button(action: clearHistory) {
                    Label("Clear", systemImage: "trash")
                }
                .buttonStyle(.plain)
                .font(.caption)

                Button(action: openSettings) {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.plain)
                .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor))
    }

    private var displayedItems: [ClipboardItem] {
        var filtered = items

        // Type filter
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
        }

        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }

        return filtered
    }
}

struct ClipboardListItem: View {
    let item: ClipboardItem
    let isSelected: Bool

    var body: some View {
        HStack {
            // Type icon
            typeIcon
                .frame(width: 24, height: 24)

            // Content preview
            VStack(alignment: .leading, spacing: 2) {
                if let preview = item.preview {
                    Text(preview)
                        .font(.body)
                        .lineLimit(2)
                }

                HStack {
                    Text(item.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if let source = item.source {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text(source)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Action buttons
            actionButtons
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
    }

    private var typeIcon: some View {
        Group {
            switch item.type {
            case .text:
                Label("", systemImage: "doc.text")
            case .image:
                Label("", systemImage: "photo")
            case .file:
                Label("", systemImage: "doc.folder")
            case .url:
                Label("", systemImage: "link")
            }
        }
        .foregroundColor(.secondary)
    }

    private var actionButtons: some View {
        HStack(spacing: 4) {
            if item.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
    }
}
```

### 3. Keyboard Navigation Pattern

Complete keyboard control for power users.

```swift
import SwiftUI

struct KeyboardAccessibleListView: View {
    @State private var items: [ClipboardItem] = []
    @State private var selectedIndex = 0
    @FocusState private var focused: Bool

    var body: some View {
        List(Array(items.enumerated()), id: \.element.id) { index, item in
            KeyboardListItem(item: item, isSelected: index == selectedIndex)
                .focusable()
                .onTapGesture {
                    selectedIndex = index
                    copyItem(item)
                }
        }
        .focused($focused)
        .onAppear {
            focused = true
        }
        .onKeyPress(key: .upArrow) { keyPress in
            if selectedIndex > 0 {
                selectedIndex -= 1
                return .handled
            }
            return .ignored
        }
        .onKeyPress(key: .downArrow) { keyPress in
            if selectedIndex < items.count - 1 {
                selectedIndex += 1
                return .handled
            }
            return .ignored
        }
        .onKeyPress(key: .return, modifiers: .command) { keyPress in
            // Copy selected item
            if selectedIndex < items.count {
                copyItem(items[selectedIndex])
                return .handled
            }
            return .ignored
        }
        .onKeyPress(.escape) { keyPress in
            // Close window
            dismiss()
            return .handled
        }
        .onKeyPress(.delete, modifiers: []) { keyPress in
            // Delete selected item
            if selectedIndex < items.count {
                items.remove(at: selectedIndex)
                if selectedIndex >= items.count {
                    selectedIndex = max(0, items.count - 1)
                }
                return .handled
            }
            return .ignored
        }
    }
}

struct KeyboardHelpOverlay: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("Keyboard Shortcuts")

            KeyboardShortcutRow("Select item", shortcut: "↑↓")
            KeyboardShortcutRow("Copy item", shortcut: "⌘ + Return")
            KeyboardShortcutRow("Delete item", shortcut: "Delete")
            KeyboardShortcutRow("Toggle favorite", shortcut: "F")
            KeyboardShortcutRow("Clear search", shortcut: "Escape")
            KeyboardShortcutRow("Show type filter", shortcut: "/")
        }
        .padding()
    }
}

struct KeyboardShortcutRow: View {
    let action: String
    let shortcut: String

    var body: some View {
        HStack {
            Text(action)
                .font(.body)
            Spacer()
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

struct SectionHeader: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.bottom, 4)
    }
}
```

### 4. Preview Pattern

Visual preview before copying.

```swift
import SwiftUI

struct ItemPreviewPanel: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Metadata
            metadataSection

            Divider()

            // Preview content
            previewContent

            Divider()

            // Actions
            actionButtons
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private var metadataSection: some View {
        HStack {
            if let icon = item.typeIcon {
                icon
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading) {
                Text(item.type.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack {
                    Text(item.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let source = item.source {
                        Text("from \(source)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Size
            Text(item.formattedSize)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var previewContent: some View {
        switch item.type {
        case .text:
            textPreview
        case .image:
            imagePreview
        case .file:
            filePreview
        case .url:
            urlPreview
        }
    }

    private var textPreview: some View {
        ScrollView {
            Text(item.content ?? "")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .frame(maxHeight: 200)
    }

    private var imagePreview: some View {
        if let image = nsImage(for: item) {
            ZoomableImage(image: image)
        } else {
            placeholder("No image preview available")
        }
    }

    private var filePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(item.fileURL?.lastPathComponent ?? "Unknown file",
                  systemImage: item.fileIcon)
                .font(.headline)

            if let path = item.fileURL?.path {
                Text(path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            }

            FilePreviewQuickActions(item: item)
        }
    }

    private var urlPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = item.url {
                LinkPreview(url: url)

                if let title = item.preview {
                    Text(title)
                        .font(.body)
                        .padding(.top, 4)
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack {
            Button("Copy") {
                copyItem(item)
            }
            .buttonStyle(.borderedProminent)

            Button(action: { toggleFavorite(item) }) {
                Label(item.isFavorite ? "Unfavorite" : "Favorite",
                      systemImage: item.isFavorite ? "star.fill" : "star")
            }

            Spacer()

            if item.canDelete {
                Button(role: .destructive, action: { deleteItem(item) }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private func placeholder(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(40)
    }
}

struct ZoomableImage: View {
    let image: NSImage
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = lastScale * value
                    }
                    .onEnded { value in
                        lastScale = scale
                    }
            )
            .onAppear {
                lastScale = scale
            }
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.1))
            .cornerRadius(8)
    }
}
```

### 5. Type-Based Organization

Group items by clipboard content type.

```swift
import SwiftUI

struct TypeOrganizedView: View {
    @State private var selectedType: ClipboardType? = nil

    let items: [ClipboardItem]

    var body: some View {
        HSplitView {
            // Type list sidebar
            typeSidebar

            // Content area
            contentArea
        }
        .frame(minWidth: 500, minHeight: 300)
    }

    private var typeSidebar: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                typeRow(nil, name: "All", count: items.count)

                ForEach(ClipboardType.allCases, id: \.self) { type in
                    typeRow(type, name: type.name, count: count(of: type))
                }
            }
        }
        .frame(minWidth: 150, idealWidth: 180)
        .background(Color(.controlBackgroundColor))
        .border(Color(separatorColor))
    }

    private func typeRow(_ type: ClipboardType?, name: String, count: Int) -> some View {
        Button {
            selectedType = type
        } label: {
            HStack {
                type.map { Label("", systemImage: $0.icon) } ?? Image(systemName: "tray")
                Text(name)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(selectedType == type ? Color.accentColor.opacity(0.15) : Color.clear)
        .cornerRadius(6)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }

    private var contentArea: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(filteredItems) { item in
                    ClipboardListItem(item: item, isSelected: false)
                        .onTapGesture {
                            copyItem(item)
                        }
                }
            }
        }
        .id(UUID()) // Force refresh on type change
    }

    private var filteredItems: [ClipboardItem] {
        guard let type = selectedType else { return items }
        return items.filter { $0.type == type }
    }

    private func count(of type: ClipboardType) -> Int {
        items.filter { $0.type == type }.count
    }

    private var separatorColor: NSColor {
        .separatorColor.withAlphaComponent(0.2)
    }
}

enum ClipboardType {
    case text
    case image
    case file
    case url

    var name: String {
        switch self {
        case .text: return "Text"
        case .image: return "Images"
        case .file: return "Files"
        case .url: return "URLs"
        }
    }

    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .image: return "photo"
        case .file: return "doc.folder"
        case .url: return "link"
        }
    }
}
```

### 6. Smart Features Pattern

AI-enhanced features for intelligent browsing.

```swift
import SwiftUI

struct SmartFeaturesView: View {
    @State private var suggestedItems: [ClipboardItem] = []
    @State private var frequentItems: [ClipboardItem] = []
    @State private var recentFromApp: [ClipboardItem] = []

    var body: some View {
        VStack(spacing: 16) {
            // Quick suggestions based on context
            if !suggestedItems.isEmpty {
                QuickSuggestions(items: suggestedItems)
            }

            // Frequent items
            FrequentItemsSection(items: frequentItems)

            // Recent from current app
            if !recentFromApp.isEmpty {
                RecentFromAppSection(items: recentFromApp)
            }
        }
        .padding()
    }
}

struct QuickSuggestions: View {
    let items: [ClipboardItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Suggested for you", systemImage: "lightbulb")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        SuggestionCard(item: item)
                    }
                }
            }
        }
    }
}

struct SuggestionCard: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let preview = item.preview {
                Text(preview)
                    .lineLimit(2)
                    .font(.callout)
            }

            Text(item.formattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(width: 180)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .onTapGesture {
            copyItem(item)
        }
    }
}

struct SmartSearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []

    var body: some View {
        VStack(spacing: 0) {
            searchInput
            searchResultsList
        }
    }

    private var searchInput: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.title3)

            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var searchResultsList: some View {
        List {
            ForEach(searchResults) { result in
                SearchResultRow(result: result)
                    .onTapGesture {
                        openResult(result)
                    }
            }
        }
        .id(searchText) // Refresh on search change
    }
}

struct SearchResult: Identifiable {
    let id: UUID
    let item: ClipboardItem
    let relevance: Double
    let matchedContext: String?
}

struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        HStack {
            result.item.type.icon
                .foregroundColor(.secondary)

            VStack(alignment: .leading) {
                if let context = result.matchedContext {
                    Text(context.replacingOccurrences(of: result.item.preview ?? "", with: ""))
                        .lineLimit(2)
                } else {
                    Text(result.item.preview ?? "")
                        .lineLimit(2)
                }

                HStack(spacing: 4) {
                    Text(result.item.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    RelevanceIndicator(relevance: result.relevance)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct RelevanceIndicator: View {
    let relevance: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index < Int(relevance * 5) ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 4, height: 4)
            }
        }
    }
}
```

## Implementation Considerations

### Hierarchy Information Architecture

1. **Primary Actions**: Copy, Search, Filter
2. **Secondary Actions**: Favorite, Delete, Share
3. **Meta Actions**: Settings, About, Quit

### Visual Hierarchy

- Selected item: Highlight, expand preview
- Regular items: Compact, preview only
- Type indicators: Icons with subtle color

### Animation Guidelines

- Show window: Fade + scale (fast, 0.2s)
- Hide window: Fade only (fast, 0.15s)
- Selection: Instant (no animation)
- Scrolling: Smooth (default scroll animations)
- Preview load: Fade in (0.3s)

## Potential Pitfalls to Avoid

### 1. Keyboard Navigation Without Visual Feedback

```swift
// BAD - Can select but not see it
List(items) { item in
    Row(item)
}

// GOOD - Show selection state
List(Array(items.enumerated()), id: \.element.id) { index, item in
    Row(item, isSelected: index == selectedIndex)
}
```

### 2. No Quick Dismissal

```swift
// BAD - No way to close quickly

// GOOD - Escape key closes
.onKeyPress(.escape) { _ in
    dismiss()
    return .handled
}
```

### 3. Complex Multi-Step Actions

```swift
// BAD - Copy requires multiple steps
Button {
    // Select
    // Confirm
    // Copy
}

// GOOD - Click to copy
Button(action: { copyItem() }) {
    Text("Copy")
}
```

### 4. Visual Clutter

```swift
// BAD - Too much information per item
ItemRow {
    All fields, metadata, buttons...
}

// GOOD - Show only essentials
ItemRow {
    Preview + Type
    // Expand for details
}
```

## Standard Hotkeys

| Action | Shortcut | Notes |
|--------|----------|-------|
| Open popup | Cmd+Shift+T | Default |
| Copy selected | Return | Immediate |
| Copy and dismiss | Cmd+Return | Quick |
| Navigate | ↑↓ | Up/down arrow |
| Favorite | F | Toggle |
| Delete | Delete | Remove |
| Search | / | Start search |
| Clear search | Escape | Reset |
| Show type filter | Cmd+T | Cycle types |
| Open Settings | Cmd+, | Preferences |
| Quit | Cmd+Q | Exit app |

## Best Practices Summary

1. **Keyboard First**: Complete keyboard support
2. **Quick Dismiss**: Escape key should close
3. **Visual Feedback**: Show selection clearly
4. **Minimal Intrusion**: Show only when needed
5. **Type Indicators**: Clear icons for content types
6. **Preview Before Copy**: Allow inspection
7. **Context Help**: Show shortcuts in UI
8. **Fast Actions**: One-click to copy
9. **Search Prominent**: Main interaction method
10. **Responsive**: Fast load, smooth interactions

## Design Resources

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [SF Symbols](https://developer.apple.com/sf-symbols/) - System icons
- [macOS Design Templates](https://developer.apple.com/design/mac/)

## Common UX Anti-Patterns to Avoid

1. **Modal dialogs for everyday actions**
2. **Requiring mouse for common operations**
3. **No undo for delete**
4. **No clear selection state**
5. **Can't cancel search**
6. **No keyboard shortcut for primary action**
7. **Too many clicks to perform common task**
8. **No visual feedback for long operations**
9. **Menu bar icon with no clear purpose**
10. **Persistent UI when not needed**

<!-- nav -->

---

[< Previous: LaunchAgents/LaunchDaemons for Background Processes](09-launch-agents.md) | [Table of Contents](../../product-spec.md)

<!-- nav -->
