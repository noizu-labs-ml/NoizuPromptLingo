# Deep Linking

> Universal Links, custom URL schemes, deferred deep linking, NavigationStack integration, and testing strategies for iOS deep links.

## Table of Contents

- [1. Universal Links](#1-universal-links)
- [2. Custom URL Schemes](#2-custom-url-schemes)
- [3. Deferred Deep Linking](#3-deferred-deep-linking)
- [4. Navigation Integration](#4-navigation-integration)
- [5. Testing Deep Links](#5-testing-deep-links)

---

## 1. Universal Links

Universal Links open your app directly from HTTPS URLs. They are the preferred deep linking mechanism -- no fallback browser bounce, verified domain ownership.

### 1.1 Associated Domains Entitlement

Xcode > Signing & Capabilities > Associated Domains:

```
applinks:example.com
applinks:www.example.com
```

### 1.2 Apple App Site Association (AASA)

Host at `https://example.com/.well-known/apple-app-site-association` (no redirect, valid TLS, `application/json` content type):

```json
{
    "applinks": {
        "apps": [],
        "details": [
            {
                "appIDs": ["TEAMID.com.example.myapp"],
                "components": [
                    { "/": "/product/*", "comment": "Product pages" },
                    { "/": "/user/*", "comment": "User profiles" },
                    { "/": "/invite/*", "comment": "Invite links" },
                    { "/": "/settings", "exclude": true }
                ]
            }
        ]
    }
}
```

### 1.3 Handling Universal Links

```swift
// SwiftUI App with onOpenURL
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    DeepLinkRouter.shared.handle(url)
                }
        }
    }
}

// UIKit AppDelegate
func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else { return false }
    return DeepLinkRouter.shared.handle(url)
}
```

---

## 2. Custom URL Schemes

Fallback for scenarios where Universal Links are not viable (e.g., opening from non-web contexts).

### 2.1 Registration

In `Info.plist` or Xcode > Info > URL Types:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.example.myapp</string>
    </dict>
</array>
```

### 2.2 Handling

```swift
// Handles myapp://product/123
ContentView()
    .onOpenURL { url in
        guard url.scheme == "myapp" else { return }
        DeepLinkRouter.shared.handle(url)
    }
```

### 2.3 Universal Links vs URL Schemes

| Feature | Universal Links | URL Schemes |
|---------|----------------|-------------|
| Protocol | HTTPS | Custom (myapp://) |
| Verification | Apple-verified domain | None (any app can claim) |
| Fallback | Opens website if app missing | Nothing / error |
| User prompt | No (opens directly) | May prompt "Open in app?" |
| Security | High | Low (scheme hijacking risk) |
| Recommended | Yes | Only as fallback |

---

## 3. Deferred Deep Linking

Deferred deep links route users to specific content even when the app is not yet installed: click link -> App Store -> install -> first launch opens target content.

### 3.1 Implementation Strategies

**Clipboard-based (simple):**

```swift
// On first launch, check pasteboard for a deep link token
func checkDeferredDeepLink() {
    guard UserDefaults.standard.bool(forKey: "hasCheckedDeferred") == false else { return }
    UserDefaults.standard.set(true, forKey: "hasCheckedDeferred")

    if let pasteString = UIPasteboard.general.string,
       let url = URL(string: pasteString),
       url.host == "example.com" {
        DeepLinkRouter.shared.handle(url)
    }
}
```

**Server fingerprint (robust):**

1. Marketing link hits your server, records IP + user-agent + referrer
2. On first app launch, app sends same fingerprint to server
3. Server matches and returns the original deep link destination
4. App navigates to that destination

**Third-party SDKs:** Branch.io, Firebase Dynamic Links (deprecated), Adjust -- handle the fingerprinting and attribution automatically.

---

## 4. Navigation Integration

### 4.1 Deep Link Router

```swift
import SwiftUI

enum DeepLink: Equatable {
    case product(id: String)
    case profile(username: String)
    case settings
    case invite(code: String)
}

@Observable
class DeepLinkRouter {
    static let shared = DeepLinkRouter()
    var pending: DeepLink?

    @discardableResult
    func handle(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }

        let pathComponents = components.path
            .split(separator: "/")
            .map(String.init)

        switch pathComponents.first {
        case "product":
            if let id = pathComponents.dropFirst().first {
                pending = .product(id: id)
                return true
            }
        case "user":
            if let username = pathComponents.dropFirst().first {
                pending = .profile(username: username)
                return true
            }
        case "invite":
            if let code = pathComponents.dropFirst().first {
                pending = .invite(code: code)
                return true
            }
        default:
            break
        }
        return false
    }
}
```

### 4.2 NavigationStack Integration

```swift
struct ContentView: View {
    @State private var router = DeepLinkRouter.shared
    @State private var path = NavigationPath()
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $path) {
                HomeView()
                    .navigationDestination(for: ProductRoute.self) { route in
                        ProductDetailView(id: route.id)
                    }
                    .navigationDestination(for: ProfileRoute.self) { route in
                        ProfileView(username: route.username)
                    }
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(Tab.home)
        }
        .onOpenURL { url in
            router.handle(url)
            applyDeepLink()
        }
        .onChange(of: router.pending) { _, _ in
            applyDeepLink()
        }
    }

    private func applyDeepLink() {
        guard let link = router.pending else { return }
        router.pending = nil

        switch link {
        case .product(let id):
            selectedTab = .home
            path = NavigationPath()
            path.append(ProductRoute(id: id))
        case .profile(let username):
            selectedTab = .home
            path = NavigationPath()
            path.append(ProfileRoute(username: username))
        case .invite(let code):
            // Handle invite in a sheet or alert
            break
        case .settings:
            selectedTab = .settings
        }
    }
}

struct ProductRoute: Hashable { let id: String }
struct ProfileRoute: Hashable { let username: String }
```

---

## 5. Testing Deep Links

### 5.1 Simulator via CLI

```bash
# Universal Link
xcrun simctl openurl booted "https://example.com/product/123"

# Custom scheme
xcrun simctl openurl booted "myapp://product/123"
```

### 5.2 Unit Tests

```swift
import XCTest
@testable import MyApp

final class DeepLinkRouterTests: XCTestCase {
    let router = DeepLinkRouter()

    func testProductLink() {
        let url = URL(string: "https://example.com/product/abc123")!
        let handled = router.handle(url)
        XCTAssertTrue(handled)
        XCTAssertEqual(router.pending, .product(id: "abc123"))
    }

    func testUnknownPath() {
        let url = URL(string: "https://example.com/unknown/path")!
        let handled = router.handle(url)
        XCTAssertFalse(handled)
        XCTAssertNil(router.pending)
    }

    func testCustomScheme() {
        let url = URL(string: "myapp://user/johndoe")!
        let handled = router.handle(url)
        XCTAssertTrue(handled)
        XCTAssertEqual(router.pending, .profile(username: "johndoe"))
    }
}
```

### 5.3 AASA Validation

```bash
# Verify AASA file is accessible and valid
curl -s "https://example.com/.well-known/apple-app-site-association" | python3 -m json.tool

# Apple's CDN validation (checks what Apple has cached)
curl -s "https://app-site-association.cdn-apple.com/a/v1/example.com" | python3 -m json.tool
```

### 5.4 Common Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| Universal Link opens Safari | AASA not found or invalid | Check CDN cache, TLS, no redirects |
| Link works on device but not simulator | Simulator does not verify AASA | Test on real device for Universal Links |
| Long press shows "Open in Safari" | User chose "Open in Safari" once | Long press again, choose "Open in App" |
| Deferred link lost | App killed before checking | Check on `applicationDidBecomeActive` |

---

*Version: 0.1.0*
*Last updated: 2026-05-12*
