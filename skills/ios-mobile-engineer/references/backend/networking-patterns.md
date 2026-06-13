# Networking Patterns for iOS

## Overview

iOS networking centers on `URLSession` with Swift's async/await concurrency model.
This guide covers API client architecture, JSON parsing, error handling, and retry
logic — with comparisons to web equivalents for developers transitioning from
TypeScript/JavaScript.

---

## URLSession with async/await

### Basic GET Request

```swift
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw APIError.invalidResponse
    }

    return try JSONDecoder().decode(User.self, from: data)
}
```

### POST with Body

```swift
func createUser(_ user: CreateUserRequest) async throws -> User {
    var request = URLRequest(url: URL(string: "https://api.example.com/users")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(user)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
        throw APIError.invalidResponse
    }

    return try JSONDecoder().decode(User.self, from: data)
}
```

### Comparison: fetch/axios vs URLSession

| Concept | TypeScript (fetch/axios) | Swift (URLSession) |
|---------|------------------------|--------------------|
| GET request | `fetch(url)` / `axios.get(url)` | `URLSession.shared.data(from: url)` |
| POST body | `{ body: JSON.stringify(obj) }` | `request.httpBody = try JSONEncoder().encode(obj)` |
| Headers | `{ headers: { 'Content-Type': ... } }` | `request.setValue(_, forHTTPHeaderField:)` |
| Response check | `if (!res.ok)` | `guard (200...299).contains(http.statusCode)` |
| JSON parse | `await res.json()` / TS interfaces | `JSONDecoder().decode(T.self, from: data)` — compile-time safe |
| Async model | `async/await` + Promises | `async/await` + structured concurrency |
| Interceptors | axios interceptors | `URLProtocol` subclass or custom `URLSessionDelegate` |
| Cancel | `AbortController` | `Task.cancel()` / `task.cancel()` |

---

## JSON Parsing with Codable

Swift's `Codable` protocol gives you compile-time-safe JSON parsing — no runtime
`JSON.parse` surprises, no `as unknown as T` casts.

### Basic Model

```swift
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let createdAt: Date

    // Map snake_case JSON keys to camelCase properties
    enum CodingKeys: String, CodingKey {
        case id, name, email
        case createdAt = "created_at"
    }
}
```

### Custom Date Decoding

```swift
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601

// Or custom format:
let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
decoder.dateDecodingStrategy = .formatted(formatter)
```

### Nested and Optional Fields

```swift
struct APIResponse<T: Codable>: Codable {
    let data: T
    let meta: Meta?

    struct Meta: Codable {
        let page: Int
        let totalPages: Int
        let totalCount: Int
    }
}

// Decode paginated response
let response = try decoder.decode(APIResponse<[User]>.self, from: data)
let users = response.data
let nextPage = response.meta?.page
```

### Key Difference from TypeScript

```typescript
// TypeScript: runtime shape is trust-based
interface User { id: string; name: string }
const user = (await res.json()) as User  // no runtime validation
```

```swift
// Swift: decoder throws if shape doesn't match
let user = try JSONDecoder().decode(User.self, from: data)
// Mismatched types, missing required fields → DecodingError at runtime
// But the compiler ensures your code handles the error (throws/try)
```

---

## Error Handling Patterns

### Typed API Errors

```swift
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, body: Data?)
    case decodingError(DecodingError)
    case networkError(URLError)
    case unauthorized
    case rateLimited(retryAfter: TimeInterval?)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid server response"
        case .httpError(let code, _): return "HTTP error: \(code)"
        case .decodingError(let err): return "Decoding failed: \(err.localizedDescription)"
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        case .unauthorized: return "Session expired. Please sign in again."
        case .rateLimited: return "Too many requests. Please wait."
        }
    }
}
```

### Structured Error Response Parsing

```swift
struct ServerError: Codable {
    let code: String
    let message: String
    let details: [String: String]?
}

func parseResponse<T: Codable>(_ data: Data, _ response: URLResponse) throws -> T {
    guard let http = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
    }

    switch http.statusCode {
    case 200...299:
        return try JSONDecoder().decode(T.self, from: data)
    case 401:
        throw APIError.unauthorized
    case 429:
        let retryAfter = http.value(forHTTPHeaderField: "Retry-After")
            .flatMap(TimeInterval.init)
        throw APIError.rateLimited(retryAfter: retryAfter)
    default:
        throw APIError.httpError(statusCode: http.statusCode, body: data)
    }
}
```

---

## Retry Logic and Timeout Configuration

### Custom URLSession Configuration

```swift
let config = URLSessionConfiguration.default
config.timeoutIntervalForRequest = 30       // per-request timeout
config.timeoutIntervalForResource = 300     // total resource timeout
config.waitsForConnectivity = true          // wait for network instead of failing
config.allowsCellularAccess = true

let session = URLSession(configuration: config)
```

### Exponential Backoff Retry

```swift
func withRetry<T>(
    maxAttempts: Int = 3,
    initialDelay: TimeInterval = 1.0,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<maxAttempts {
        do {
            return try await operation()
        } catch let error as APIError {
            lastError = error
            switch error {
            case .rateLimited(let retryAfter):
                let delay = retryAfter ?? (initialDelay * pow(2.0, Double(attempt)))
                try await Task.sleep(for: .seconds(delay))
            case .networkError:
                let delay = initialDelay * pow(2.0, Double(attempt))
                try await Task.sleep(for: .seconds(delay))
            case .unauthorized:
                throw error  // don't retry auth failures
            default:
                throw error
            }
        } catch {
            lastError = error
            let delay = initialDelay * pow(2.0, Double(attempt))
            try await Task.sleep(for: .seconds(delay))
        }
    }

    throw lastError ?? APIError.invalidResponse
}

// Usage
let user = try await withRetry {
    try await apiClient.fetchUser(id: "123")
}
```

---

## API Client Architecture (Protocol-Based)

### Define the Contract

```swift
protocol APIClientProtocol {
    func get<T: Codable>(_ path: String, query: [String: String]?) async throws -> T
    func post<T: Codable, B: Encodable>(_ path: String, body: B) async throws -> T
    func put<T: Codable, B: Encodable>(_ path: String, body: B) async throws -> T
    func delete(_ path: String) async throws
}
```

### Concrete Implementation

```swift
final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let authProvider: AuthProviderProtocol

    init(
        baseURL: URL,
        session: URLSession = .shared,
        authProvider: AuthProviderProtocol
    ) {
        self.baseURL = baseURL
        self.session = session
        self.authProvider = authProvider
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func get<T: Codable>(_ path: String, query: [String: String]? = nil) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)!
        components.queryItems = query?.map { URLQueryItem(name: $0.key, value: $0.value) }

        var request = URLRequest(url: components.url!)
        try await applyAuth(&request)

        let (data, response) = try await session.data(for: request)
        return try parseResponse(data, response)
    }

    func post<T: Codable, B: Encodable>(_ path: String, body: B) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        try await applyAuth(&request)

        let (data, response) = try await session.data(for: request)
        return try parseResponse(data, response)
    }

    // ... put, delete follow same pattern

    private func applyAuth(_ request: inout URLRequest) async throws {
        let token = try await authProvider.currentToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
```

### Mock for Testing

```swift
final class MockAPIClient: APIClientProtocol {
    var getResult: Any?
    var postResult: Any?

    func get<T: Codable>(_ path: String, query: [String: String]?) async throws -> T {
        guard let result = getResult as? T else {
            throw APIError.invalidResponse
        }
        return result
    }

    // ... same pattern for post, put, delete
}
```

### Dependency Injection in SwiftUI

```swift
// Environment key
struct APIClientKey: EnvironmentKey {
    static let defaultValue: APIClientProtocol = APIClient(
        baseURL: URL(string: "https://api.example.com")!,
        authProvider: KeychainAuthProvider()
    )
}

extension EnvironmentValues {
    var apiClient: APIClientProtocol {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

// In views
struct UserProfileView: View {
    @Environment(\.apiClient) private var api

    func loadUser() async {
        let user: User = try await api.get("/users/me", query: nil)
    }
}

// In previews / tests
UserProfileView()
    .environment(\.apiClient, MockAPIClient())
```

---

## Key Takeaways

1. **URLSession + async/await** is the modern standard — no need for third-party HTTP libraries
2. **Codable** gives compile-time JSON safety that TypeScript interfaces cannot
3. **Protocol-based API clients** enable clean testing without network calls
4. **Retry with exponential backoff** — always skip retries for auth errors
5. **Snake-case conversion** can be automatic via `keyDecodingStrategy`
6. **Structured concurrency** means cancellation propagates automatically through `Task` trees
