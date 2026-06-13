# Testing Strategy for macOS SwiftUI Apps

## Test Pyramid

```
         [XCUITest]          — UI automation (slow, high-value smoke tests)
       [Integration Tests]   — multi-component, real dependencies
     [Unit Tests]            — isolated logic, pure functions, ViewModels
```

All test targets live in the same Xcode project. Use Test Plans to group and configure.

---

## XCTest (All macOS Versions)

Standard unit testing. Each test class inherits `XCTestCase`.

```swift
import XCTest
@testable import MyApp

final class DocumentParserTests: XCTestCase {

    var parser: DocumentParser!

    override func setUp() {
        super.setUp()
        parser = DocumentParser()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    func testParsesValidDocument() throws {
        let doc = try parser.parse(data: validFixture)
        XCTAssertEqual(doc.title, "Expected Title")
        XCTAssertFalse(doc.sections.isEmpty)
    }

    func testThrowsOnCorruptData() {
        XCTAssertThrowsError(try parser.parse(data: corruptFixture)) { error in
            XCTAssertEqual(error as? ParseError, .invalidFormat)
        }
    }

    func testAsyncFetch() async throws {
        let result = try await parser.fetchRemote(url: mockURL)
        XCTAssertNotNil(result)
    }
}
```

---

## Swift Testing (macOS 15+)

Swift Testing replaces XCTest with a modern macro-based API. Available in Xcode 16, runs on macOS 15+.

```swift
import Testing
@testable import MyApp

@Suite("Document Parser")
struct DocumentParserTests {

    @Test("parses valid document")
    func parsesValidDocument() throws {
        let parser = DocumentParser()
        let doc = try parser.parse(data: validFixture)
        #expect(doc.title == "Expected Title")
        #expect(!doc.sections.isEmpty)
    }

    @Test("throws on corrupt data")
    func throwsOnCorruptData() {
        #expect(throws: ParseError.invalidFormat) {
            try DocumentParser().parse(data: corruptFixture)
        }
    }

    @Test("parameterized formats", arguments: ["json", "xml", "csv"])
    func parsesAllFormats(format: String) throws {
        let doc = try DocumentParser().parse(data: fixture(format))
        #expect(doc != nil)
    }
}
```

Key advantages over XCTest: parameterized tests, parallel test execution by default, `#expect` with richer diagnostics, `@Suite` grouping, `@Tag` for filtering.

---

## Testing @Observable ViewModels

With `@Observable` (macOS 14+), avoid SwiftUI rendering in unit tests — test the model layer directly.

```swift
@Observable
final class DocumentViewModel {
    var documents: [Document] = []
    var isLoading = false
    private let service: DocumentServiceProtocol

    init(service: DocumentServiceProtocol) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        documents = await service.fetchAll()
    }
}

// Test with mock
struct MockDocumentService: DocumentServiceProtocol {
    var stubbedDocuments: [Document] = []
    func fetchAll() async -> [Document] { stubbedDocuments }
}

@Test("loads documents")
func loadsDocuments() async {
    let service = MockDocumentService(stubbedDocuments: [.fixture()])
    let vm = DocumentViewModel(service: service)
    await vm.load()
    #expect(vm.documents.count == 1)
    #expect(vm.isLoading == false)
}
```

Use protocol-based dependency injection so ViewModels are testable without real network/disk.

---

## XCUITest for Mac

`XCUIApplication` automates the real running app. Use for smoke tests of critical user flows.

```swift
import XCTest

final class DocumentUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // Menu bar interaction
    func testNewDocumentViaMenu() {
        app.menuBars.menuBarItems["File"].click()
        app.menus["File"].menuItems["New Document"].click()
        XCTAssertTrue(app.windows["Untitled"].exists)
    }

    // Keyboard shortcut
    func testNewDocumentShortcut() {
        app.typeKey("n", modifierFlags: .command)
        XCTAssertTrue(app.windows.element(boundBy: 0).exists)
    }

    // Window enumeration
    func testWindowTitleAfterSave() throws {
        app.typeKey("n", modifierFlags: .command)
        let window = app.windows.firstMatch
        window.typeKey("s", modifierFlags: .command)
        // Handle save panel
        let savePanel = app.sheets.firstMatch
        if savePanel.waitForExistence(timeout: 2) {
            savePanel.textFields.firstMatch.typeText("TestDoc")
            savePanel.buttons["Save"].click()
        }
        XCTAssertTrue(window.title.contains("TestDoc"))
    }

    // Toolbar button
    func testSidebarToggle() {
        let toolbar = app.toolbars.firstMatch
        toolbar.buttons["Toggle Sidebar"].click()
        // verify sidebar collapsed
    }
}
```

Launch argument convention: `--uitesting` disables animations, uses in-memory stores, skips onboarding.

---

## Accessibility Testing

Accessibility is also testability — UI tests depend on accessibility labels.

```swift
// In SwiftUI views
Button("Delete Document") { delete() }
    .accessibilityLabel("Delete")
    .accessibilityHint("Permanently removes the document")

List(documents) { doc in
    DocumentRow(doc: doc)
        .accessibilityIdentifier("doc-\(doc.id)")
}
```

Run Accessibility Inspector (Xcode → Open Developer Tool → Accessibility Inspector) to audit:
- Missing labels on interactive elements
- Color contrast failures
- Keyboard navigation flow

Automated check:
```swift
func testAccessibilityLabelsPresent() {
    let buttons = app.buttons.allElementsBoundByIndex
    for button in buttons {
        XCTAssertFalse(button.label.isEmpty, "Button missing accessibility label")
    }
}
```

---

## Snapshot Testing

Use [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) to assert view appearance:

```swift
import SnapshotTesting
import SwiftUI

final class DocumentRowSnapshotTests: XCTestCase {
    func testDocumentRowLight() {
        let view = DocumentRow(doc: .fixture())
            .frame(width: 400)
            .environment(\.colorScheme, .light)
        assertSnapshot(of: view, as: .image(precision: 0.99))
    }

    func testDocumentRowDark() {
        let view = DocumentRow(doc: .fixture())
            .frame(width: 400)
            .environment(\.colorScheme, .dark)
        assertSnapshot(of: view, as: .image(precision: 0.99))
    }
}
```

First run generates reference images under `__Snapshots__/`. Set `isRecording = true` to regenerate. Commit snapshots to source control.

---

## Test Plans

Test Plans (`.xctestplan` files) configure which tests run, in which order, with which environment:

- Create via: Test navigator → right-click scheme → New Test Plan
- Group tests: All Unit Tests, All UI Tests, Smoke Tests (subset), CI Tests
- Per-plan settings: language/locale, code coverage, sanitizers (Thread Sanitizer for concurrency bugs, Address Sanitizer for memory)

```json
// Excerpt from .xctestplan
{
  "configurations": [
    {
      "name": "English",
      "options": { "language": "en", "region": "US" }
    },
    {
      "name": "Japanese",
      "options": { "language": "ja", "region": "JP" }
    }
  ]
}
```

Run specific plan from command line:
```bash
xcodebuild test \
  -scheme MyApp \
  -testPlan "CI Tests" \
  -destination "platform=macOS"
```

---

## XCTMetric Performance Tests

```swift
func testListRenderPerformance() {
    measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
        let _ = DocumentListView(documents: largeDataset)
    }
}
```

Set baseline in Xcode: run once, right-click result → "Set Baseline". Future runs fail if > 10% regression (configurable).

---

## Checklist

- [ ] Unit tests for all ViewModel/service logic (pure functions, no SwiftUI)
- [ ] Protocol-based DI so all dependencies are mockable
- [ ] Swift Testing used for new test targets on macOS 15+ projects
- [ ] `--uitesting` launch argument wires in-memory store and disables animations
- [ ] XCUITest covers critical flows: new document, save, open, quit
- [ ] Snapshot tests for key views, dark mode variants included
- [ ] Accessibility identifiers on all interactive list items
- [ ] Test Plans configured: unit, integration, UI, CI subsets
- [ ] Thread Sanitizer enabled in CI test plan
- [ ] Performance baselines committed for regression detection
