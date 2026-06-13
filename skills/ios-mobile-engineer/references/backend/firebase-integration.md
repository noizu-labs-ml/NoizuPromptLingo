# Firebase Integration for iOS

## Overview

Firebase provides a full backend suite — database (Firestore), authentication,
cloud functions, push notifications, analytics, and storage. It works across
Apple platforms, Android, and web, making it the go-to for cross-platform apps.

---

## Firebase SDK Setup via SPM

### 1. Add Firebase Package

```
File → Add Package Dependencies
URL: https://github.com/firebase/firebase-ios-sdk
Version: Up to Next Major (11.0.0+)
```

Select the libraries you need:
- `FirebaseFirestore`
- `FirebaseAuth`
- `FirebaseMessaging`
- `FirebaseAnalytics`
- `FirebaseFunctions`
- `FirebaseStorage`

### 2. Configure Firebase

Download `GoogleService-Info.plist` from the Firebase Console and add it to your
Xcode project (ensure it's included in your app target).

```swift
import Firebase

@main
struct MyApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## Firestore CRUD with Codable

### Model Definition

```swift
import FirebaseFirestore

struct Task: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?

    enum Priority: String, Codable {
        case low, medium, high
    }
}
```

### Create

```swift
let db = Firestore.firestore()

func createTask(_ task: Task) async throws -> String {
    let ref = try db.collection("tasks").addDocument(from: task)
    return ref.documentID
}

// With explicit ID
func createTaskWithID(_ task: Task, id: String) async throws {
    try db.collection("tasks").document(id).setData(from: task)
}
```

### Read

```swift
// Single document
func fetchTask(id: String) async throws -> Task {
    try await db.collection("tasks").document(id).getDocument(as: Task.self)
}

// Query with filters
func fetchIncompleteTasks() async throws -> [Task] {
    let snapshot = try await db.collection("tasks")
        .whereField("isCompleted", isEqualTo: false)
        .order(by: "createdAt", descending: true)
        .limit(to: 50)
        .getDocuments()

    return snapshot.documents.compactMap { doc in
        try? doc.data(as: Task.self)
    }
}

// Paginated query
func fetchTasks(after lastDocument: DocumentSnapshot?) async throws -> ([Task], DocumentSnapshot?) {
    var query = db.collection("tasks")
        .order(by: "createdAt", descending: true)
        .limit(to: 20)

    if let lastDocument {
        query = query.start(afterDocument: lastDocument)
    }

    let snapshot = try await query.getDocuments()
    let tasks = snapshot.documents.compactMap { try? $0.data(as: Task.self) }
    return (tasks, snapshot.documents.last)
}
```

### Update

```swift
func toggleTaskCompletion(id: String, isCompleted: Bool) async throws {
    try await db.collection("tasks").document(id).updateData([
        "isCompleted": isCompleted,
        "updatedAt": FieldValue.serverTimestamp()
    ])
}
```

### Delete

```swift
func deleteTask(id: String) async throws {
    try await db.collection("tasks").document(id).delete()
}
```

### Real-Time Listener

```swift
@Observable
final class TasksViewModel {
    var tasks: [Task] = []
    private var listener: ListenerRegistration?

    func startListening() {
        listener = Firestore.firestore().collection("tasks")
            .whereField("isCompleted", isEqualTo: false)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.tasks = documents.compactMap { try? $0.data(as: Task.self) }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    deinit { stopListening() }
}
```

---

## Firebase Auth

### Email/Password

```swift
import FirebaseAuth

func signUp(email: String, password: String) async throws -> User {
    let result = try await Auth.auth().createUser(withEmail: email, password: password)
    return result.user
}

func signIn(email: String, password: String) async throws -> User {
    let result = try await Auth.auth().signIn(withEmail: email, password: password)
    return result.user
}

func signOut() throws {
    try Auth.auth().signOut()
}
```

### Sign in with Apple

```swift
import AuthenticationServices
import CryptoKit

final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {
    private var currentNonce: String?

    func startSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8),
              let nonce = currentNonce else { return }

        let credential = OAuthProvider.appleCredential(
            withIDToken: tokenString,
            rawNonce: nonce,
            fullName: appleCredential.fullName
        )

        Task {
            try await Auth.auth().signIn(with: credential)
        }
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
```

### Auth State Observer

```swift
@Observable
final class AuthViewModel {
    var user: User?
    var isAuthenticated: Bool { user != nil }
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }
}
```

---

## Cloud Functions Integration

### Calling Functions from iOS

```swift
import FirebaseFunctions

let functions = Functions.functions()

// Callable function
func processPayment(amount: Int, currency: String) async throws -> [String: Any] {
    let result = try await functions.httpsCallable("processPayment").call([
        "amount": amount,
        "currency": currency
    ])
    return result.data as? [String: Any] ?? [:]
}

// With Codable
struct PaymentRequest: Encodable {
    let amount: Int
    let currency: String
}

struct PaymentResult: Decodable {
    let transactionId: String
    let status: String
}

func processPaymentTyped(request: PaymentRequest) async throws -> PaymentResult {
    let callable = functions.httpsCallable("processPayment")
    let result = try await callable.call(request, as: PaymentResult.self)
    return result
}
```

---

## FCM Push Notifications

### Setup

```swift
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        application.registerForRemoteNotifications()
        return true
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        // Send token to your server or store in Firestore
        print("FCM Token: \(token)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
```

### Topic Subscriptions

```swift
// Subscribe to a topic
Messaging.messaging().subscribe(toTopic: "news") { error in
    if let error { print("Subscribe error: \(error)") }
}

// Unsubscribe
Messaging.messaging().unsubscribe(fromTopic: "news")
```

---

## Firebase Analytics

```swift
import FirebaseAnalytics

// Log custom event
Analytics.logEvent("task_completed", parameters: [
    "task_priority": task.priority.rawValue,
    "time_to_complete": timeInterval
])

// Log screen view
Analytics.logEvent(AnalyticsEventScreenView, parameters: [
    AnalyticsParameterScreenName: "TaskList",
    AnalyticsParameterScreenClass: "TaskListView"
])

// Set user property
Analytics.setUserProperty("premium", forName: "subscription_tier")
```

---

## Offline Support with Firestore Cache

Firestore has built-in offline persistence — enabled by default on iOS.

```swift
// Configure cache size (default: 100MB)
let settings = FirestoreSettings()
settings.cacheSettings = PersistentCacheSettings(sizeBytes: 200 * 1024 * 1024)  // 200MB
Firestore.firestore().settings = settings

// Force read from cache
func fetchTasksCached() async throws -> [Task] {
    let snapshot = try await Firestore.firestore()
        .collection("tasks")
        .getDocuments(source: .cache)

    return snapshot.documents.compactMap { try? $0.data(as: Task.self) }
}

// Check if data came from cache
func fetchWithSourceInfo() async throws -> ([Task], Bool) {
    let snapshot = try await Firestore.firestore()
        .collection("tasks")
        .getDocuments()

    let fromCache = snapshot.metadata.isFromCache
    let tasks = snapshot.documents.compactMap { try? $0.data(as: Task.self) }
    return (tasks, fromCache)
}
```

### Offline Write Queue

Firestore automatically queues writes when offline and syncs when connectivity
returns. No additional code needed — writes to Firestore while offline will
resolve once the device reconnects.

```swift
// This works offline — queued automatically
try await Firestore.firestore().collection("tasks").addDocument(from: newTask)

// Listener fires immediately with local data, then again when server confirms
```

---

## Key Takeaways

1. **SPM is the recommended installation** — CocoaPods support is being phased out
2. **@DocumentID and @ServerTimestamp** reduce boilerplate significantly with Codable
3. **Sign in with Apple is mandatory** if you offer any third-party social login
4. **Offline persistence is on by default** — Firestore handles the queue
5. **Snapshot listeners** give real-time updates with minimal code
6. **Cloud Functions** keep sensitive logic server-side (payment processing, admin ops)
7. **FCM tokens rotate** — always update your server when `didReceiveRegistrationToken` fires
