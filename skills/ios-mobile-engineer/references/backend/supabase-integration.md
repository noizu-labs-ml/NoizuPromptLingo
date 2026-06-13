# Supabase Integration for iOS

## Overview

Supabase is an open-source Firebase alternative built on PostgreSQL. It provides
a relational database, auth, file storage, realtime subscriptions, and edge
functions. The Swift client is first-class and works well with Codable.

Key advantage over Firebase: you get a real PostgreSQL database with SQL,
joins, foreign keys, and Row Level Security — not a document store.

---

## Supabase Swift Client Setup

### 1. Add via SPM

```
File → Add Package Dependencies
URL: https://github.com/supabase/supabase-swift
Version: Up to Next Major (2.0.0+)
```

Select products: `Supabase` (includes Auth, PostgREST, Realtime, Storage, Functions).

### 2. Initialize Client

```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://your-project.supabase.co")!,
    supabaseKey: "your-anon-key"  // safe to embed — RLS protects data
)
```

### 3. Environment Integration

```swift
// Share client via SwiftUI environment
struct SupabaseKey: EnvironmentKey {
    static let defaultValue = SupabaseClient(
        supabaseURL: URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "")!,
        supabaseKey: ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""
    )
}

extension EnvironmentValues {
    var supabase: SupabaseClient {
        get { self[SupabaseKey.self] }
        set { self[SupabaseKey.self] = newValue }
    }
}
```

---

## Database Queries

### Model Definition

```swift
struct Todo: Codable, Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var priority: Int
    var userId: UUID
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, priority
        case isCompleted = "is_completed"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
```

### Create

```swift
struct NewTodo: Encodable {
    let title: String
    let isCompleted: Bool = false
    let priority: Int
    let userId: UUID

    enum CodingKeys: String, CodingKey {
        case title, priority
        case isCompleted = "is_completed"
        case userId = "user_id"
    }
}

func createTodo(title: String, priority: Int) async throws -> Todo {
    let userId = try await supabase.auth.session.user.id

    let newTodo = NewTodo(title: title, priority: priority, userId: userId)

    return try await supabase
        .from("todos")
        .insert(newTodo)
        .select()
        .single()
        .execute()
        .value
}
```

### Read with Filters

```swift
// Fetch all for current user
func fetchTodos() async throws -> [Todo] {
    try await supabase
        .from("todos")
        .select()
        .order("created_at", ascending: false)
        .execute()
        .value
}

// Filtered query
func fetchIncompleteTodos() async throws -> [Todo] {
    try await supabase
        .from("todos")
        .select()
        .eq("is_completed", value: false)
        .gte("priority", value: 2)
        .order("priority", ascending: false)
        .limit(20)
        .execute()
        .value
}

// Query with joins (foreign table)
struct TodoWithProfile: Codable {
    let id: UUID
    let title: String
    let profile: Profile

    struct Profile: Codable {
        let username: String
        let avatarUrl: String?
    }
}

func fetchTodosWithProfile() async throws -> [TodoWithProfile] {
    try await supabase
        .from("todos")
        .select("id, title, profiles(username, avatar_url)")
        .execute()
        .value
}
```

### Update

```swift
func toggleTodo(id: UUID, isCompleted: Bool) async throws -> Todo {
    try await supabase
        .from("todos")
        .update(["is_completed": isCompleted])
        .eq("id", value: id)
        .select()
        .single()
        .execute()
        .value
}
```

### Delete

```swift
func deleteTodo(id: UUID) async throws {
    try await supabase
        .from("todos")
        .delete()
        .eq("id", value: id)
        .execute()
}
```

---

## Realtime Subscriptions

### Listen for Changes

```swift
@Observable
final class TodosViewModel {
    var todos: [Todo] = []
    private var channel: RealtimeChannelV2?

    func startListening() async {
        // Initial fetch
        todos = (try? await fetchTodos()) ?? []

        // Subscribe to changes
        channel = supabase.realtimeV2.channel("todos-changes")

        let changes = channel!.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "todos"
        )

        await channel!.subscribe()

        for await change in changes {
            switch change {
            case .insert(let action):
                if let todo = try? action.decodeRecord(as: Todo.self, decoder: JSONDecoder()) {
                    todos.insert(todo, at: 0)
                }
            case .update(let action):
                if let todo = try? action.decodeRecord(as: Todo.self, decoder: JSONDecoder()),
                   let index = todos.firstIndex(where: { $0.id == todo.id }) {
                    todos[index] = todo
                }
            case .delete(let action):
                if let id = action.oldRecord["id"]?.stringValue.flatMap(UUID.init) {
                    todos.removeAll { $0.id == id }
                }
            }
        }
    }

    func stopListening() async {
        await channel?.unsubscribe()
        channel = nil
    }
}
```

### Presence (Who's Online)

```swift
func trackPresence() async {
    let channel = supabase.realtimeV2.channel("room:lobby")

    let presence = channel.presenceChange()
    await channel.subscribe()
    await channel.track(["user_id": userId, "online_at": Date().ISO8601Format()])

    for await change in presence {
        let joins = change.joins    // users who just came online
        let leaves = change.leaves  // users who just went offline
    }
}
```

---

## Auth with Supabase GoTrue

### Email/Password

```swift
func signUp(email: String, password: String) async throws {
    try await supabase.auth.signUp(email: email, password: password)
}

func signIn(email: String, password: String) async throws {
    try await supabase.auth.signIn(email: email, password: password)
}

func signOut() async throws {
    try await supabase.auth.signOut()
}
```

### Sign in with Apple

```swift
import AuthenticationServices

func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
    guard let identityToken = credential.identityToken,
          let tokenString = String(data: identityToken, encoding: .utf8) else {
        throw AuthError.missingToken
    }

    try await supabase.auth.signInWithIdToken(
        credentials: .init(
            provider: .apple,
            idToken: tokenString
        )
    )
}
```

### Auth State Listener

```swift
@Observable
final class AuthViewModel {
    var session: Session?
    var isAuthenticated: Bool { session != nil }

    init() {
        Task {
            for await (event, session) in supabase.auth.authStateChanges {
                await MainActor.run {
                    self.session = session
                }

                switch event {
                case .signedIn:
                    print("User signed in")
                case .signedOut:
                    print("User signed out")
                case .tokenRefreshed:
                    print("Token refreshed")
                default:
                    break
                }
            }
        }
    }
}
```

---

## Storage for File Uploads

### Upload

```swift
func uploadAvatar(userId: UUID, imageData: Data) async throws -> String {
    let path = "avatars/\(userId.uuidString).jpg"

    try await supabase.storage
        .from("avatars")
        .upload(
            path,
            data: imageData,
            options: FileOptions(contentType: "image/jpeg", upsert: true)
        )

    // Get public URL
    let url = try supabase.storage
        .from("avatars")
        .getPublicURL(path: path)

    return url.absoluteString
}
```

### Download

```swift
func downloadAvatar(path: String) async throws -> Data {
    try await supabase.storage
        .from("avatars")
        .download(path: path)
}
```

### Signed URLs (Private Files)

```swift
func getSignedURL(path: String) async throws -> URL {
    try await supabase.storage
        .from("documents")
        .createSignedURL(path: path, expiresIn: 3600)  // 1 hour
}
```

---

## Edge Functions Integration

### Invoke a Function

```swift
struct InvoiceRequest: Encodable {
    let orderId: String
    let format: String
}

struct InvoiceResponse: Decodable {
    let pdfUrl: String
    let invoiceNumber: String
}

func generateInvoice(orderId: String) async throws -> InvoiceResponse {
    try await supabase.functions.invoke(
        "generate-invoice",
        options: .init(
            body: InvoiceRequest(orderId: orderId, format: "pdf")
        )
    )
}
```

### Streaming Response

```swift
func streamCompletion(prompt: String) async throws -> AsyncThrowingStream<Data, Error> {
    // Edge function returns a streaming response
    // Useful for AI/LLM integrations
    let response = try await supabase.functions.invoke(
        "ai-complete",
        options: .init(body: ["prompt": prompt])
    )
    // Handle streaming based on your edge function's response format
    return response
}
```

---

## Row Level Security Patterns

RLS is what makes the anon key safe to embed in your app. Without RLS,
anyone with the anon key can read/write everything.

### Common Policies (SQL — apply via Supabase Dashboard or migrations)

```sql
-- Users can only see their own todos
CREATE POLICY "Users see own todos" ON todos
    FOR SELECT USING (auth.uid() = user_id);

-- Users can only insert their own todos
CREATE POLICY "Users insert own todos" ON todos
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can only update their own todos
CREATE POLICY "Users update own todos" ON todos
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can only delete their own todos
CREATE POLICY "Users delete own todos" ON todos
    FOR DELETE USING (auth.uid() = user_id);

-- Public read access for a shared table
CREATE POLICY "Anyone can read categories" ON categories
    FOR SELECT USING (true);

-- Team-based access
CREATE POLICY "Team members see team data" ON projects
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM team_members
            WHERE team_members.team_id = projects.team_id
            AND team_members.user_id = auth.uid()
        )
    );
```

### iOS Impact

With RLS enabled, queries automatically filter to the authenticated user's
data — no need to add `.eq("user_id", value: userId)` to every query:

```swift
// With RLS on, this only returns the current user's todos
let todos: [Todo] = try await supabase
    .from("todos")
    .select()
    .execute()
    .value
// No user_id filter needed — RLS handles it
```

---

## Key Takeaways

1. **Real PostgreSQL** — joins, foreign keys, indexes, and SQL migrations
2. **RLS makes the anon key safe** — always enable it before shipping
3. **Codable integration** is clean — snake_case mapping via CodingKeys
4. **Realtime** uses PostgreSQL's WAL, so it works on any table change
5. **Edge Functions** run Deno/TypeScript — good for webhooks and server-side logic
6. **Storage** supports signed URLs for private files and public buckets for avatars
7. **Auth token refresh** is automatic — the Swift client handles session management
8. **Self-hostable** — you can run Supabase on your own infrastructure if needed
