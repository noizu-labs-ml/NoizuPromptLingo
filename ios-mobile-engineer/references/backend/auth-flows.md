# Authentication Flows for iOS

## Overview

iOS authentication spans Sign in with Apple (mandatory if you offer social login),
OAuth 2.0/OIDC, JWT management, biometrics, and secure credential storage in the
Keychain. This guide covers each pattern with production-ready code.

---

## Sign in with Apple

**App Store requirement:** If your app offers any third-party social login
(Google, Facebook, Twitter), you must also offer Sign in with Apple.

### Basic Implementation

```swift
import AuthenticationServices

struct SignInWithAppleButton: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                handleAuthorization(authorization)
            case .failure(let error):
                print("Sign in failed: \(error.localizedDescription)")
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 50)
    }

    private func handleAuthorization(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        let userId = credential.user                              // stable user ID
        let identityToken = credential.identityToken              // JWT for your server
        let authorizationCode = credential.authorizationCode      // exchange for refresh token
        let email = credential.email                              // only on first sign-in
        let fullName = credential.fullName                        // only on first sign-in

        // IMPORTANT: email and fullName are only provided on the FIRST authorization.
        // You must persist them immediately — they won't be sent again.

        if let tokenData = identityToken,
           let tokenString = String(data: tokenData, encoding: .utf8) {
            Task {
                await sendTokenToServer(tokenString, userId: userId)
            }
        }
    }
}
```

### Credential State Checking

```swift
func checkAppleCredentialState(userId: String) async -> Bool {
    await withCheckedContinuation { continuation in
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { state, _ in
            switch state {
            case .authorized:
                continuation.resume(returning: true)
            case .revoked, .notFound, .transferred:
                continuation.resume(returning: false)
            @unknown default:
                continuation.resume(returning: false)
            }
        }
    }
}

// Listen for revocation
NotificationCenter.default.addObserver(
    forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
    object: nil,
    queue: .main
) { _ in
    // User revoked Apple ID credentials — sign them out
}
```

---

## OAuth 2.0 / OIDC Patterns on iOS

### Using ASWebAuthenticationSession

This is Apple's built-in OAuth browser — handles the redirect flow securely
without requiring `SFSafariViewController` hacks.

```swift
import AuthenticationServices

final class OAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }

    func signInWithGoogle() async throws -> OAuthToken {
        let clientId = "your-google-client-id"
        let redirectURI = "com.yourapp:/oauth/callback"
        let scope = "openid email profile"
        let state = UUID().uuidString
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)

        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]

        let authURL = components.url!
        let callbackScheme = "com.yourapp"

        let callbackURL = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackScheme
            ) { url, error in
                if let error { continuation.resume(throwing: error) }
                else if let url { continuation.resume(returning: url) }
                else { continuation.resume(throwing: AuthError.unknown) }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true  // no shared cookies
            session.start()
        }

        // Extract authorization code from callback URL
        let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value

        guard let code else { throw AuthError.missingCode }

        // Exchange code for tokens
        return try await exchangeCodeForToken(code: code, codeVerifier: codeVerifier)
    }

    // PKCE helpers
    private func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
```

---

## JWT Token Management

### Token Model

```swift
struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let tokenType: String

    var isExpired: Bool {
        Date() >= expiresAt
    }

    var isExpiringSoon: Bool {
        Date().addingTimeInterval(300) >= expiresAt  // 5 min buffer
    }
}
```

### Token Manager with Auto-Refresh

```swift
import Foundation

actor TokenManager {
    private var tokens: AuthTokens?
    private var refreshTask: Task<AuthTokens, Error>?
    private let keychain: KeychainService

    init(keychain: KeychainService = .shared) {
        self.keychain = keychain
        self.tokens = keychain.loadTokens()
    }

    func currentToken() async throws -> String {
        // If we have a valid token, return it
        if let tokens, !tokens.isExpiringSoon {
            return tokens.accessToken
        }

        // If a refresh is already in progress, wait for it
        if let refreshTask {
            let refreshed = try await refreshTask.value
            return refreshed.accessToken
        }

        // Start a new refresh
        guard let tokens else { throw AuthError.notAuthenticated }

        let task = Task {
            let refreshed = try await refreshTokens(tokens.refreshToken)
            self.tokens = refreshed
            keychain.saveTokens(refreshed)
            self.refreshTask = nil
            return refreshed
        }

        refreshTask = task
        let refreshed = try await task.value
        return refreshed.accessToken
    }

    func setTokens(_ tokens: AuthTokens) {
        self.tokens = tokens
        keychain.saveTokens(tokens)
    }

    func clearTokens() {
        tokens = nil
        keychain.deleteTokens()
    }

    private func refreshTokens(_ refreshToken: String) async throws -> AuthTokens {
        var request = URLRequest(url: URL(string: "https://api.example.com/auth/refresh")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["refresh_token": refreshToken])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw AuthError.refreshFailed
        }

        return try JSONDecoder().decode(AuthTokens.self, from: data)
    }
}
```

---

## Biometric Auth (Face ID / Touch ID)

### Info.plist Requirement

```xml
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to unlock the app and access your account.</string>
```

### LocalAuthentication Implementation

```swift
import LocalAuthentication

final class BiometricAuthService {

    enum BiometricType {
        case faceID, touchID, none
    }

    var availableBiometric: BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        default: return .none
        }
    }

    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"

        // Allow fallback to device passcode
        context.localizedFallbackTitle = "Enter Passcode"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error { throw error }
            return false
        }

        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }

    /// Authenticate, falling back to device passcode if biometrics fail
    func authenticateWithPasscodeFallback(reason: String) async throws -> Bool {
        let context = LAContext()

        return try await context.evaluatePolicy(
            .deviceOwnerAuthentication,  // biometrics OR passcode
            localizedReason: reason
        )
    }
}
```

### Usage in SwiftUI

```swift
struct ProtectedView: View {
    @State private var isUnlocked = false
    private let biometrics = BiometricAuthService()

    var body: some View {
        Group {
            if isUnlocked {
                SensitiveContentView()
            } else {
                LockedView(onUnlock: unlock)
            }
        }
        .task { await unlock() }
    }

    private func unlock() async {
        do {
            isUnlocked = try await biometrics.authenticate(
                reason: "Access your financial data"
            )
        } catch {
            // Handle LAError cases — user cancelled, biometry locked out, etc.
        }
    }
}
```

---

## Keychain for Secure Credential Storage

### Keychain Service

```swift
import Security

final class KeychainService {
    static let shared = KeychainService()

    private let service = Bundle.main.bundleIdentifier ?? "com.app"

    // MARK: - Generic Save/Load/Delete

    func save(_ data: Data, for key: String) throws {
        // Delete existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func load(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Codable Convenience

    func saveTokens(_ tokens: AuthTokens) {
        guard let data = try? JSONEncoder().encode(tokens) else { return }
        try? save(data, for: "auth_tokens")
    }

    func loadTokens() -> AuthTokens? {
        guard let data = load(for: "auth_tokens") else { return nil }
        return try? JSONDecoder().decode(AuthTokens.self, from: data)
    }

    func deleteTokens() {
        delete(for: "auth_tokens")
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
}
```

### Accessibility Levels

| Level | Meaning |
|-------|---------|
| `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` | Available only when device is unlocked, never migrated to new devices. **Best for tokens.** |
| `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` | Available after first unlock until reboot. Good for background refresh tokens. |
| `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` | Requires device passcode to be set. Deleted if passcode is removed. Most secure. |

### Biometric-Protected Keychain Items

```swift
func saveBiometricProtected(_ data: Data, for key: String) throws {
    let access = SecAccessControlCreateWithFlags(
        nil,
        kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
        .biometryCurrentSet,  // invalidated if biometrics change
        nil
    )

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: key,
        kSecValueData as String: data,
        kSecAttrAccessControl as String: access as Any,
    ]

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw KeychainError.saveFailed(status)
    }
}
```

---

## Session Management Patterns

### Centralized Auth State

```swift
@Observable
final class AuthManager {
    var isAuthenticated = false
    var currentUser: AppUser?

    private let tokenManager: TokenManager
    private let keychain: KeychainService
    private let biometrics: BiometricAuthService

    init() {
        self.keychain = .shared
        self.tokenManager = TokenManager(keychain: keychain)
        self.biometrics = BiometricAuthService()
    }

    func restoreSession() async {
        // Check for stored tokens
        guard let tokens = keychain.loadTokens(), !tokens.isExpired else {
            isAuthenticated = false
            return
        }

        // Optionally require biometric unlock
        if UserDefaults.standard.bool(forKey: "biometricLockEnabled") {
            guard (try? await biometrics.authenticate(reason: "Unlock app")) == true else {
                return
            }
        }

        // Validate token with server
        do {
            let token = try await tokenManager.currentToken()
            currentUser = try await fetchCurrentUser(token: token)
            isAuthenticated = true
        } catch {
            await signOut()
        }
    }

    func signOut() async {
        await tokenManager.clearTokens()
        currentUser = nil
        isAuthenticated = false
    }
}
```

### Root View Routing

```swift
@main
struct MyApp: App {
    @State private var auth = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isAuthenticated {
                    MainTabView()
                } else {
                    SignInView()
                }
            }
            .environment(auth)
            .task { await auth.restoreSession() }
        }
    }
}
```

---

## Key Takeaways

1. **Sign in with Apple is mandatory** if you have any social login — App Store will reject without it
2. **Email and name from Apple are only sent once** — persist immediately on first authorization
3. **PKCE is required** for mobile OAuth — never use implicit grant on iOS
4. **Keychain, not UserDefaults** — tokens, passwords, and secrets go in Keychain only
5. **Actor-based TokenManager** prevents race conditions during concurrent token refresh
6. **Biometric auth** is straightforward with `LocalAuthentication` — add passcode fallback for accessibility
7. **`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`** is the right default for most credentials
