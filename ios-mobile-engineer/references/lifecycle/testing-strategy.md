# iOS Testing Strategy

Testing pyramid for iOS apps: unit tests form the base, integration tests validate
module boundaries, and UI tests cover critical user flows. Favor fast, deterministic
tests at the bottom; use slower, broader tests sparingly at the top.

---

## Testing Pyramid

```
        /  UI Tests  \          ~10% — XCUITest, slow, flaky-prone
       / Integration  \         ~20% — multi-module, real dependencies
      /   Unit Tests    \       ~70% — fast, isolated, deterministic
```

**Rule of thumb:** if a test requires a simulator, it belongs higher in the pyramid.
Push logic down into testable layers so unit tests cover the majority of behavior.

---

## Swift Testing Framework (iOS 18+)

Swift Testing is the modern replacement for XCTest. Use it for all new test targets
on projects with an iOS 18+ minimum deployment.

### Basic Structure

```swift
import Testing

@Suite("Authentication")
struct AuthTests {
    let sut: AuthService

    init() {
        sut = AuthService(store: MockTokenStore())
    }

    @Test("login succeeds with valid credentials")
    func loginSuccess() async throws {
        let result = try await sut.login(email: "test@example.com", password: "valid")
        #expect(result.isAuthenticated)
    }

    @Test("login fails with wrong password")
    func loginFailure() async throws {
        await #expect(throws: AuthError.invalidCredentials) {
            try await sut.login(email: "test@example.com", password: "wrong")
        }
    }
}
```

### Parameterized Tests

```swift
@Test("validates email format", arguments: [
    ("user@example.com", true),
    ("invalid", false),
    ("@missing.com", false),
    ("user@.com", false),
])
func emailValidation(email: String, expected: Bool) {
    #expect(EmailValidator.isValid(email) == expected)
}
```

### Traits

```swift
@Test(.disabled("Waiting on API v2 endpoint"))
func newEndpoint() { }

@Test(.timeLimit(.minutes(1)))
func longRunningOperation() async { }

@Test(.tags(.networking))
func apiCall() async throws { }
```

---

## XCTest (Backward Compatibility)

Use XCTest when supporting iOS 17 or earlier, or for UI testing (XCUITest).

```swift
import XCTest
@testable import MyApp

final class CartTests: XCTestCase {
    var sut: ShoppingCart!

    override func setUp() {
        super.setUp()
        sut = ShoppingCart()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testAddItem_incrementsCount() {
        sut.add(Item(name: "Widget", price: 9.99))
        XCTAssertEqual(sut.items.count, 1)
    }

    func testTotalPrice_sumsAllItems() {
        sut.add(Item(name: "A", price: 10.00))
        sut.add(Item(name: "B", price: 5.50))
        XCTAssertEqual(sut.totalPrice, 15.50, accuracy: 0.001)
    }
}
```

### Async Testing in XCTest

```swift
func testFetchUser() async throws {
    let user = try await service.fetchUser(id: "123")
    XCTAssertEqual(user.name, "Alice")
}
```

---

## Snapshot Testing

Use `swift-snapshot-testing` (Point-Free) to catch unintended visual regressions.

### Setup

Add to `Package.swift` or SPM dependency in Xcode:
```swift
.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0")
```

### Usage

```swift
import SnapshotTesting
import SwiftUI
import XCTest
@testable import MyApp

final class ProfileViewSnapshotTests: XCTestCase {
    func testProfileView_default() {
        let view = ProfileView(user: .mock)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        assertSnapshot(of: vc, as: .image(on: .iPhone15Pro))
    }

    func testProfileView_darkMode() {
        let view = ProfileView(user: .mock)
        let vc = UIHostingController(rootView: view)
        vc.overrideUserInterfaceStyle = .dark
        vc.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        assertSnapshot(of: vc, as: .image(on: .iPhone15Pro))
    }
}
```

### Best Practices

- Run `record = true` once to generate reference images, then switch back
- Snapshot only stable, data-driven views (avoid animations, timestamps)
- Store reference images in the test target, commit them to version control
- Test multiple device sizes and accessibility categories

---

## XCUITest (UI Automation)

Reserve UI tests for critical user journeys: onboarding, purchase, login.

```swift
import XCTest

final class OnboardingUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting", "--reset-state"]
        app.launch()
    }

    func testOnboardingFlow_completesSuccessfully() {
        // Page 1
        XCTAssertTrue(app.staticTexts["Welcome"].exists)
        app.buttons["Next"].tap()

        // Page 2
        XCTAssertTrue(app.staticTexts["Setup"].exists)
        app.textFields["Name"].tap()
        app.textFields["Name"].typeText("Alice")
        app.buttons["Continue"].tap()

        // Home screen
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))
    }
}
```

### Tips for Stable UI Tests

- Use `accessibilityIdentifier` on views for reliable element lookup
- Set launch arguments to seed deterministic state
- Avoid sleep; use `waitForExistence(timeout:)` instead
- Keep UI test count low (10-20 for most apps)

---

## Code Coverage

### Targets

| Layer | Target | Rationale |
|-------|--------|-----------|
| Domain / Models | 90%+ | Pure logic, easy to test exhaustively |
| ViewModels / Services | 75%+ | Business logic with some I/O boundaries |
| Views | 40-60% | Snapshot tests cover visual; logic should be extracted |
| Networking | 60%+ | Test request construction, response parsing |
| Overall | 70%+ | Balanced; higher is better but not at cost of test quality |

### Measuring in Xcode

1. Edit scheme > Test > Options > check "Code Coverage"
2. Select targets to gather coverage for
3. After test run: Report Navigator > Coverage tab
4. Export via `xcodebuild test -enableCodeCoverage YES -resultBundlePath result.xcresult`
5. Parse with `xcrun xccov view --report result.xcresult`

---

## Protocol-Based Mocking

Avoid mock libraries. Define protocols at module boundaries and inject test doubles.

### Pattern

```swift
// Production protocol
protocol UserRepository {
    func fetch(id: String) async throws -> User
    func save(_ user: User) async throws
}

// Production implementation
struct RemoteUserRepository: UserRepository {
    let client: HTTPClient
    func fetch(id: String) async throws -> User { /* network call */ }
    func save(_ user: User) async throws { /* network call */ }
}

// Test double
struct MockUserRepository: UserRepository {
    var fetchResult: Result<User, Error> = .success(.mock)
    var savedUsers: [User] = []

    func fetch(id: String) async throws -> User {
        try fetchResult.get()
    }

    mutating func save(_ user: User) async throws {
        savedUsers.append(user)
    }
}

// Usage in tests
@Test("profile loads user data")
func profileLoadsUser() async throws {
    let mock = MockUserRepository(fetchResult: .success(.mock))
    let vm = ProfileViewModel(repository: mock)
    await vm.loadUser(id: "123")
    #expect(vm.user?.name == "Alice")
}
```

### Why Protocol-Based

- No third-party dependency to maintain
- Compile-time enforcement: if the protocol changes, mocks break immediately
- Lightweight: a struct with stored properties is sufficient for most doubles
- Transparent: test setup reads like documentation of expected behavior

---

## Test Organization

```
MyAppTests/
├── Unit/
│   ├── Models/
│   ├── Services/
│   └── ViewModels/
├── Integration/
│   ├── Repositories/
│   └── Persistence/
├── Snapshots/
│   ├── __Snapshots__/      # Reference images
│   └── Views/
└── Helpers/
    ├── Mocks/
    └── Fixtures/

MyAppUITests/
├── Flows/
│   ├── OnboardingUITests.swift
│   └── PurchaseUITests.swift
└── Helpers/
    └── XCUIApplication+Extensions.swift
```

Keep test helpers, mocks, and fixtures in a shared `Helpers/` directory within
the test target. Never import test utilities into production targets.
