# CloudKit Integration Guide

## Overview

CloudKit is Apple's first-party backend-as-a-service. It provides a database,
file storage, and push notifications — all tied to iCloud accounts with zero
server infrastructure to manage. Free tier is generous for indie apps.

---

## When CloudKit Is the Right Choice

**Use CloudKit when:**
- Your app is Apple-only (iOS, macOS, watchOS, visionOS)
- You want zero backend infrastructure to maintain
- User data should sync across their Apple devices
- You need the free tier (100MB asset storage, 500MB database per user)
- Privacy is critical — Apple handles encryption and compliance

**Avoid CloudKit when:**
- You need Android or web clients (CloudKit JS exists but is limited)
- You need complex server-side logic (use Firebase/Supabase instead)
- You need relational queries with joins (CloudKit is document-oriented)
- You need full-text search (CloudKit has tokenized query fields, not search)

---

## CloudKit Setup in Xcode

### 1. Enable Capabilities

```
Target → Signing & Capabilities → + Capability → iCloud
  ✓ CloudKit
  → Select or create a container: iCloud.com.yourcompany.appname
```

### 2. Container Types

| Container | Scope | Use Case |
|-----------|-------|----------|
| **Private Database** | Per-user, encrypted | User's own data |
| **Public Database** | Shared across all users | Catalog, shared content |
| **Shared Database** | Invited users only | Collaborative features |

### 3. Define Schema in CloudKit Dashboard

Navigate to https://icloud.developer.apple.com → select your container.

Record types can be defined in the dashboard or created on first save from code.
Production schema requires explicit promotion from development.

---

## Record Types and Schemas

### Defining Models

```swift
import CloudKit

struct Note {
    let id: CKRecord.ID
    var title: String
    var content: String
    var tags: [String]
    var attachment: CKAsset?
    var modifiedAt: Date

    // Keys — keep these consistent
    static let recordType = "Note"
    enum Field: String {
        case title, content, tags, attachment, modifiedAt
    }
}
```

### Converting To/From CKRecord

```swift
extension Note {
    /// Create a Note from a CloudKit record
    init(record: CKRecord) {
        self.id = record.recordID
        self.title = record[Field.title.rawValue] as? String ?? ""
        self.content = record[Field.content.rawValue] as? String ?? ""
        self.tags = record[Field.tags.rawValue] as? [String] ?? []
        self.attachment = record[Field.attachment.rawValue] as? CKAsset
        self.modifiedAt = record[Field.modifiedAt.rawValue] as? Date ?? record.modificationDate ?? Date()
    }

    /// Convert to a CKRecord for saving
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: id)
        record[Field.title.rawValue] = title as CKRecordValue
        record[Field.content.rawValue] = content as CKRecordValue
        record[Field.tags.rawValue] = tags as CKRecordValue
        record[Field.modifiedAt.rawValue] = modifiedAt as CKRecordValue
        if let attachment {
            record[Field.attachment.rawValue] = attachment
        }
        return record
    }
}
```

---

## CRUD Operations

### Container Reference

```swift
let container = CKContainer(identifier: "iCloud.com.yourcompany.appname")
let privateDB = container.privateCloudDatabase
let publicDB = container.publicCloudDatabase
```

### Create

```swift
func createNote(title: String, content: String) async throws -> Note {
    let recordID = CKRecord.ID(recordName: UUID().uuidString)
    let record = CKRecord(recordType: Note.recordType, recordID: recordID)
    record[Note.Field.title.rawValue] = title
    record[Note.Field.content.rawValue] = content
    record[Note.Field.modifiedAt.rawValue] = Date()

    let saved = try await privateDB.save(record)
    return Note(record: saved)
}
```

### Read (Query)

```swift
func fetchNotes(matching searchText: String? = nil) async throws -> [Note] {
    var predicate = NSPredicate(value: true)  // fetch all
    if let searchText, !searchText.isEmpty {
        // TOKENIZED query — not full-text search
        predicate = NSPredicate(format: "allTokens TOKENMATCHES[cdl] %@", searchText)
    }

    let query = CKQuery(recordType: Note.recordType, predicate: predicate)
    query.sortDescriptors = [NSSortDescriptor(key: Note.Field.modifiedAt.rawValue, ascending: false)]

    let (results, _) = try await privateDB.records(matching: query, resultsLimit: 50)

    return results.compactMap { _, result in
        guard case .success(let record) = result else { return nil }
        return Note(record: record)
    }
}
```

### Update

```swift
func updateNote(_ note: Note) async throws -> Note {
    // Fetch the existing record first to avoid overwriting concurrent changes
    let record = try await privateDB.record(for: note.id)
    record[Note.Field.title.rawValue] = note.title
    record[Note.Field.content.rawValue] = note.content
    record[Note.Field.tags.rawValue] = note.tags
    record[Note.Field.modifiedAt.rawValue] = Date()

    let saved = try await privateDB.save(record)
    return Note(record: saved)
}
```

### Delete

```swift
func deleteNote(id: CKRecord.ID) async throws {
    try await privateDB.deleteRecord(withID: id)
}
```

### Batch Operations

```swift
func batchSave(notes: [Note]) async throws {
    let records = notes.map { $0.toRecord() }
    let operation = CKModifyRecordsOperation(
        recordsToSave: records,
        recordIDsToDelete: nil
    )
    operation.savePolicy = .changedKeys  // only send modified fields
    operation.isAtomic = true            // all-or-nothing

    try await privateDB.add(operation)
}
```

---

## Subscriptions and Real-Time Updates

### Database Subscription (All Changes)

```swift
func subscribeToChanges() async throws {
    let subscription = CKDatabaseSubscription(subscriptionID: "all-notes-changes")

    let notificationInfo = CKSubscription.NotificationInfo()
    notificationInfo.shouldSendContentAvailable = true  // silent push
    subscription.notificationInfo = notificationInfo

    try await privateDB.save(subscription)
}
```

### Query Subscription (Filtered Changes)

```swift
func subscribeToUrgentNotes() async throws {
    let predicate = NSPredicate(format: "tags CONTAINS %@", "urgent")
    let subscription = CKQuerySubscription(
        recordType: Note.recordType,
        predicate: predicate,
        subscriptionID: "urgent-notes",
        options: [.firesOnRecordCreation, .firesOnRecordUpdate]
    )

    let notificationInfo = CKSubscription.NotificationInfo()
    notificationInfo.titleLocalizationKey = "New urgent note"
    notificationInfo.shouldBadge = true
    subscription.notificationInfo = notificationInfo

    try await privateDB.save(subscription)
}
```

### Handling Push Notifications

```swift
// In AppDelegate or App struct
func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any]
) async -> UIBackgroundFetchResult {
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)

    if notification?.subscriptionID == "all-notes-changes" {
        await fetchChanges()
        return .newData
    }
    return .noData
}
```

### Fetching Changes (Change Tokens)

```swift
final class CloudKitSyncEngine {
    private var changeToken: CKServerChangeToken?

    func fetchChanges() async throws -> [CKRecord] {
        var changedRecords: [CKRecord] = []

        let config = CKFetchDatabaseChangesOperation.Configuration()
        let operation = CKFetchDatabaseChangesOperation(
            previousServerChangeToken: changeToken
        )

        // This is simplified — production code should handle
        // zone changes, then fetch record changes per zone
        let (changes, newToken) = try await fetchZoneChanges()
        changedRecords = changes
        changeToken = newToken

        // Persist token for next launch
        if let tokenData = try? NSKeyedArchiver.archivedData(
            withRootObject: newToken as Any, requiringSecureCoding: true
        ) {
            UserDefaults.standard.set(tokenData, forKey: "ckChangeToken")
        }

        return changedRecords
    }
}
```

---

## NSPersistentCloudKitContainer (Core Data + CloudKit Sync)

This is the easiest path if you already use Core Data. Apple handles the entire
sync engine — conflict resolution, change tracking, push notifications.

### Setup

```swift
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "MyApp")

        // Configure for CloudKit sync
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No store description")
        }

        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.yourcompany.appname"
        )

        // Enable history tracking for sync
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { _, error in
            if let error { fatalError("Store load failed: \(error)") }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
```

### Observing Remote Changes

```swift
// In your App or a coordinator
NotificationCenter.default.addObserver(
    forName: .NSPersistentStoreRemoteChange,
    object: container.persistentStoreCoordinator,
    queue: .main
) { _ in
    // Core Data context updates automatically
    // UI refreshes through @FetchRequest / @Query
}
```

### SwiftUI Integration

```swift
@main
struct MyApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}

struct NotesListView: View {
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.modifiedAt, order: .reverse)],
        animation: .default
    )
    private var notes: FetchedResults<NoteEntity>

    var body: some View {
        List(notes) { note in
            Text(note.title ?? "Untitled")
        }
    }
}
```

---

## Error Handling

### Common CloudKit Errors

```swift
func handleCloudKitError(_ error: Error) {
    guard let ckError = error as? CKError else { return }

    switch ckError.code {
    case .notAuthenticated:
        // User not signed into iCloud
        // Show prompt to sign in via Settings
        break
    case .quotaExceeded:
        // User's iCloud storage is full
        break
    case .networkFailure, .networkUnavailable:
        // Queue for retry when connectivity returns
        break
    case .serverRecordChanged:
        // Conflict — server has a newer version
        // Merge using ckError.serverRecord and ckError.clientRecord
        break
    case .limitExceeded:
        // Too many records in one operation — batch smaller
        break
    case .zoneBusy:
        // Retry after delay (check ckError.retryAfterSeconds)
        break
    default:
        break
    }
}
```

---

## Key Takeaways

1. **NSPersistentCloudKitContainer** is the fastest path — automatic sync with Core Data
2. **Private database** is free and unlimited per-user; public has shared quotas
3. **Change tokens** are essential — never refetch everything, track incremental changes
4. **Schema promotion** from dev to production is a one-way, manual step in the dashboard
5. **Conflict resolution** must be handled — `serverRecordChanged` errors are inevitable
6. **No joins** — model data as denormalized records or use `CKRecord.Reference` for parent-child
