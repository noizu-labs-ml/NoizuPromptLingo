# SQLite Integration in Swift for Local Persistence

## Overview

SQLite is a lightweight, embedded SQL database engine ideal for macOS applications that need local data persistence, such as storing clipboard history with indexing and querying capabilities.

## Core Concepts

- **Embedded Database**: SQLite runs within the application process
- **SQL Queries**: Standard SQL for data manipulation
- **Transactions**: ACID-compliant operations
- **Prepared Statements**: Efficient query execution
- **Concurrency**: Thread-safe operations with proper locking

## Key APIs and Frameworks

| API/Library | Purpose | Notes |
|-------------|---------|-------|
| `SQLite3` | C API | Foundation (built into macOS) |
| `GRDB.swift` | Swift wrapper | Type-safe, recommended |
| `SQLite.swift` | Swift wrapper | Lightweight alternative |
| `CoreData` | Apple ORM | Overkill for clipboard history |

## Swift Code Examples

### Native SQLite3 Approach

```swift
import Foundation
import SQLite3

class SQLiteDatabase {
    private var db: OpaquePointer?
    private let path: String

    init?(path: String) {
        self.path = path
        guard openDatabase() else {
            return nil
        }
        createTables()
    }

    private func openDatabase() -> Bool {
        if sqlite3_open_v2(path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK {
            return true
        }

        let errorMessage = String(cString: sqlite3_errmsg(db)!)
        print("Cannot open database: \(errorMessage)")
        return false
    }

    func createTables() {
        let createTableSQL = """
        CREATE TABLE IF NOT EXISTS clipboard_items (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            content TEXT,
            created_at REAL NOT NULL,
            source_app TEXT,
            is_favorite INTEGER DEFAULT 0,
            metadata TEXT
        );

        CREATE INDEX IF NOT EXISTS idx_created_at ON clipboard_items(created_at DESC);
        CREATE INDEX IF NOT EXISTS idx_type ON clipboard_items(type);
        CREATE INDEX IF NOT EXISTS idx_favorite ON clipboard_items(is_favorite);
        """

        if sqlite3_exec(db, createTableSQL, nil, nil, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errorMessage)")
        }
    }

    func insert(_ item: ClipboardItem) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO clipboard_items
        (id, type, content, created_at, source_app, is_favorite, metadata)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, item.id.uuidString, -1, nil)
            sqlite3_bind_text(statement, 2, item.type.rawValue, -1, nil)
            sqlite3_bind_text(statement, 3, item.content, -1, nil)
            sqlite3_bind_double(statement, 4, item.timestamp.timeIntervalSince1970)
            sqlite3_bind_text(statement, 5, item.sourceApp, -1, nil)
            sqlite3_bind_int(statement, 6, item.isFavorite ? 1 : 0)

            // Encode metadata as JSON
            if let metadata = item.metadataJSON {
                sqlite3_bind_text(statement, 7, metadata, -1, nil)
            } else {
                sqlite3_bind_text(statement, 7, "{}", -1, nil)
            }

            let result = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
            return result
        }

        return false
    }

    func fetch(limit: Int = 100, offset: Int = 0) -> [ClipboardItem] {
        let sql = """
        SELECT id, type, content, created_at, source_app, is_favorite, metadata
        FROM clipboard_items
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
        """

        var statement: OpaquePointer?
        var items: [ClipboardItem] = []

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, Int64(limit))
            sqlite3_bind_int64(statement, 2, Int64(offset))

            while sqlite3_step(statement) == SQLITE_ROW {
                if let item = parseItem(from: statement) {
                    items.append(item)
                }
            }

            sqlite3_finalize(statement)
        }

        return items
    }

    func search(query: String, limit: Int = 20) -> [ClipboardItem] {
        let sql = """
        SELECT id, type, content, created_at, source_app, is_favorite, metadata
        FROM clipboard_items
        WHERE content LIKE ? OR source_app LIKE ?
        ORDER BY created_at DESC
        LIMIT ?
        """

        var statement: OpaquePointer?
        var items: [ClipboardItem] = []
        let searchPattern = "%\(query)%"

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, searchPattern, -1, nil)
            sqlite3_bind_text(statement, 2, searchPattern, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(limit))

            while sqlite3_step(statement) == SQLITE_ROW {
                if let item = parseItem(from: statement) {
                    items.append(item)
                }
            }

            sqlite3_finalize(statement)
        }

        return items
    }

    func delete(id: UUID) -> Bool {
        let sql = "DELETE FROM clipboard_items WHERE id = ?"

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id.uuidString, -1, nil)
            let result = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
            return result
        }

        return false
    }

    private func parseItem(from statement: OpaquePointer?) -> ClipboardItem? {
        guard let statement = statement else { return nil }

        let idString = String(cString: sqlite3_column_text(statement, 0))
        let type = String(cString: sqlite3_column_text(statement, 1))
        let content = String(cString: sqlite3_column_text(statement, 2))
        let timestamp = Date(timeIntervalSince1970: sqlite3_column_double(statement, 3))
        let sourceApp = String(cString: sqlite3_column_text(statement, 4))
        let isFavorite = sqlite3_column_int(statement, 5) == 1
        let metadata = String(cString: sqlite3_column_text(statement, 6))

        guard let id = UUID(uuidString: idString),
              let itemType = ClipboardItemType(rawValue: type) else {
            return nil
        }

        return ClipboardItem(
            id: id,
            type: itemType,
            content: content,
            timestamp: timestamp,
            sourceApp: sourceApp,
            isFavorite: isFavorite,
            metadata: metadata
        )
    }

    deinit {
        sqlite3_close(db)
    }
}
```

### GRDB.swift Approach (Recommended)

```swift
import GRDB

class GRDBDatabase {
    private var dbPool: DatabasePool?

    init?(path: String) {
        let config = Configuration()
        // Enable WAL mode for better concurrency
        config.busyMode = .timeout(5)
        config.readonly = false

        do {
            dbPool = try DatabasePool(path: path, configuration: config)
            try migrate()
        } catch {
            print("Failed to initialize database: \(error)")
            return nil
        }
    }

    private func migrate() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("CreateClipboardItemsTable") { db in
            try db.create(table: "clipboard_items") { t in
                t.column("id", .text).primaryKey()
                t.column("type", .text).notNull()
                t.column("content", .text).notNull()
                t.column("created_at", .double).notNull()
                t.column("source_app", .text)
                t.column("is_favorite", .boolean).defaults(to: false)
                t.column("metadata", .text)
            }

            try db.create(index: "idx_created_at", on: "clipboard_items", columns: ["created_at"], options: [.descending])
            try db.create(index: "idx_type", on: "clipboard_items", columns: ["type"])
            try db.create(index: "idx_favorite", on: "clipboard_items", columns: ["is_favorite"])
        }

        migrator.registerMigration("AddPreviewColumn") { db in
            try db.alter(table: "clipboard_items") { t in
                t.add(column: "preview", .text)
            }
        }

        try migrator.migrate(dbPool!)
    }

    func insert(_ item: ClipboardItem) throws {
        try dbPool?.write { db in
            var record = ClipboardItemRecord(item: item)
            try record.save(db)
        }
    }

    func insertMany(_ items: [ClipboardItem]) throws {
        try dbPool?.write { db in
            for item in items {
                var record = ClipboardItemRecord(item: item)
                try record.save(db)
            }
        }
    }

    func fetch(limit: Int = 100, offset: Int = 0) -> [ClipboardItem] {
        guard let dbPool = dbPool else { return [] }

        return try! dbPool.read { db in
            try ClipboardItemRecord
                .order(Column("created_at").desc)
                .limit(limit, offset: offset)
                .fetchAll(db)
                .map { $0.toClipboardItem() }
        }
    }

    func fetchFavorites() -> [ClipboardItem] {
        guard let dbPool = dbPool else { return [] }

        return try! dbPool.read { db in
            try ClipboardItemRecord
                .filter(Column("is_favorite") == true)
                .order(Column("created_at").desc)
                .fetchAll(db)
                .map { $0.toClipboardItem() }
        }
    }

    func search(query: String, limit: Int = 20) -> [ClipboardItem] {
        guard let dbPool = dbPool else { return [] }

        return try! dbPool.read { db in
            let pattern = "%\(query)%"

            return try ClipboardItemRecord
                .filter(Column("content").like(pattern) || Column("source_app").like(pattern))
                .order(Column("created_at").desc)
                .limit(limit)
                .fetchAll(db)
                .map { $0.toClipboardItem() }
        }
    }

    func fetchByType(_ type: ClipboardItemType, limit: Int = 50) -> [ClipboardItem] {
        guard let dbPool = dbPool else { return [] }

        return try! dbPool.read { db in
            try ClipboardItemRecord
                .filter(Column("type") == type.rawValue)
                .order(Column("created_at").desc)
                .limit(limit)
                .fetchAll(db)
                .map { $0.toClipboardItem() }
        }
    }

    func fetchFromDateRange(start: Date, end: Date) -> [ClipboardItem] {
        guard let dbPool = dbPool else { return [] }

        return try! dbPool.read { db in
            try ClipboardItemRecord
                .filter(Column("created_at") >= start.timeIntervalSince1970)
                .filter(Column("created_at") <= end.timeIntervalSince1970)
                .order(Column("created_at").desc)
                .fetchAll(db)
                .map { $0.toClipboardItem() }
        }
    }

    func delete(id: UUID) throws {
        try dbPool?.write { db in
            try ClipboardItemRecord
                .filter(Column("id") == id.uuidString)
                .deleteAll(db)
        }
    }

    func deleteBefore(date: Date) throws {
        try dbPool?.write { db in
            try ClipboardItemRecord
                .filter(Column("created_at") < date.timeIntervalSince1970)
                .deleteAll(db)
        }
    }

    func updateFavorite(id: UUID, isFavorite: Bool) throws {
        try dbPool?.write { db in
            try ClipboardItemRecord
                .filter(Column("id") == id.uuidString)
                .updateAll(db, Column("is_favorite").set(to: isFavorite))
        }
    }

    func getStats() -> DatabaseStats {
        guard let dbPool = dbPool else {
            return DatabaseStats(totalItems: 0, byType: [:])
        }

        return try! dbPool.read { db in
            let totalCount: Int = try ClipboardItemRecord.fetchCount(db)

            // Group by type
            let groupedRows = try Row.fetchAll(db, sql: """
                SELECT type, COUNT(*) as count
                FROM clipboard_items
                GROUP BY type
            """)

            var byType: [String: Int] = [:]
            for row in groupedRows {
                byType[row["type" as String]] = row["count" as Int]
            }

            return DatabaseStats(totalItems: totalCount, byType: byType)
        }
    }
}

// MARK: - Database Models

struct ClipboardItemRecord: Codable, PersistableRecord, FetchableRecord {
    var id: String
    var type: String
    var content: String
    var createdAt: Double
    var sourceApp: String?
    var isFavorite: Bool
    var metadata: String?
    var preview: String?

    init(item: ClipboardItem) {
        id = item.id.uuidString
        type = item.type.rawValue
        content = item.content
        createdAt = item.timestamp.timeIntervalSince1970
        sourceApp = item.sourceApp
        isFavorite = item.isFavorite
        metadata = item.metadataJSON
        preview = item.previewText
    }

    func toClipboardItem() -> ClipboardItem {
        return ClipboardItem(
            id: UUID(uuidString: id)!,
            type: ClipboardItemType(rawValue: type) ?? .text,
            content: content,
            timestamp: Date(timeIntervalSince1970: createdAt),
            sourceApp: sourceApp,
            isFavorite: isFavorite,
            metadata: metadata,
            previewText: preview
        )
    }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let type = Column(CodingKeys.type)
        static let content = Column(CodingKeys.content)
        static let createdAt = Column(CodingKeys.createdAt)
        static let sourceApp = Column(CodingKeys.sourceApp)
        static let isFavorite = Column(CodingKeys.isFavorite)
        static let metadata = Column(CodingKeys.metadata)
        static let preview = Column(CodingKeys.preview)
    }
}

struct DatabaseStats {
    let totalItems: Int
    let byType: [String: Int]
}

// MARK: - Domain Models

enum ClipboardItemType: String, Codable {
    case text
    case image
    case url
    case file
    case rtf
    case html
    case custom
}

struct ClipboardItem: Identifiable {
    let id: UUID
    let type: ClipboardItemType
    let content: String
    let timestamp: Date
    let sourceApp: String?
    var isFavorite: Bool
    var metadata: String?
    var previewText: String?

    var metadataJSON: String? {
        metadata
    }
}
```

### Database Manager Singleton

```swift
import GRDB

class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()
    private var db: GRDBDatabase?

    @Published var items: [ClipboardItem] = []
    @Published var isLoading = false

    private init() {
        setupDatabase()
        loadItems()
    }

    private func setupDatabase() {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        guard let appSupportURL = paths.first else { return }

        let dbURL = appSupportURL.appendingPathComponent("ClipboardManager/db.sqlite")

        // Create directory if needed
        try? FileManager.default.createDirectory(
            at: dbURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        db = GRDBDatabase(path: dbURL.path)
    }

    func loadItems() {
        isLoading = true
        defer { isLoading = false }

        items = db?.fetch(limit: 500) ?? []
    }

    func save(_ item: ClipboardItem) {
        do {
            try db?.insert(item)

            // Update published items
            items.insert(item, at: 0)

            // Maintain size limit
            if items.count > 500 {
                let toRemove = items.count - 500
                items.removeLast(toRemove)
            }
        } catch {
            print("Failed to save item: \(error)")
        }
    }

    func search(_ query: String) {
        if query.isEmpty {
            loadItems()
        } else {
            items = db?.search(query: query) ?? []
        }
    }

    func delete(_ item: ClipboardItem) {
        try? db?.delete(id: item.id)
        items.removeAll { $0.id == item.id }
    }

    func toggleFavorite(_ item: ClipboardItem) {
        let newState = !item.isFavorite
        try? db?.updateFavorite(id: item.id, isFavorite: newState)

        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite = newState
        }
    }

    func cleanupOldItems(olderThan days: Int = 30) {
        let cutoffDate = Date().addingTimeInterval(-Double(days) * 86400)
        try? db?.deleteBefore(date: cutoffDate)
        loadItems()
    }

    func getStats() -> DatabaseStats {
        return db?.getStats() ?? DatabaseStats(totalItems: 0, byType: [:])
    }
}
```

### FTS (Full-Text Search) Implementation

```swift
class FTSDatabase {
    private var dbPool: DatabasePool?

    init?(path: String) {
        do {
            dbPool = try DatabasePool(path: path)
            try setupFTS()
        } catch {
            print("Failed to initialize FTS database: \(error)")
            return nil
        }
    }

    private func setupFTS() throws {
        try dbPool?.write { db in
            // Enable FTS5
            try db.create(table: "clipboard_items_fts") { t in
                t.column("id")
                t.column("content")
                t.column("source_app")
            }
        }

        try dbPool?.write { db in
            try db.execute(sql: """
            CREATE VIRTUAL TABLE IF NOT EXISTS clipboard_fts USING fts5(
                id,
                content,
                source_app,
                content_rowid='rowid'
            );
            """)
        }
    }

    func indexItem(_ item: ClipboardItem) throws {
        try dbPool?.write { db in
            try db.execute(sql: """
            INSERT INTO clipboard_fts(rowid, id, content, source_app)
            VALUES (?, ?, ?, ?)
            """, arguments: [item.id.hashValue, item.id.uuidString, item.content, item.sourceApp ?? ""])
        }
    }

    func searchFTS(query: String, limit: Int = 50) -> [UUID] {
        guard let dbPool = dbPool else { return [] }

        return try! dbPool.read { db in
            return try UUID.fetchAll(db, sql: """
                SELECT id
                FROM clipboard_fts
                WHERE clipboard_fts MATCH ?
                ORDER BY rank
                LIMIT ?
            """, arguments: [query, limit])
        }
    }

    func rebuildIndex(items: [ClipboardItem]) throws {
        try dbPool?.write { db in
            try db.execute(sql: "DELETE FROM clipboard_fts")

            for item in items {
                try db.execute(sql: """
                INSERT INTO clipboard_fts(rowid, id, content, source_app)
                VALUES (?, ?, ?, ?)
                """, arguments: [item.id.hashValue, item.id.uuidString, item.content, item.sourceApp ?? ""])
            }
        }
    }
}
```

## Implementation Considerations

### Database Location
Store in Application Support directory:

```swift
let paths = FileManager.default.urls(
    for: .applicationSupportDirectory,
    in: .userDomainMask
)
let dbURL = paths.first!
    .appendingPathComponent("YourApp/db.sqlite")
```

### WAL Mode (Write-Ahead Logging)
Enables better concurrency:

```swift
try db.execute(sql: "PRAGMA journal_mode=WAL")
```

### Prepared Statements Cache
Improve performance by caching statements:

```sql
PREPARE stmt FROM 'SELECT ...';
EXECUTE stmt USING @param;
```

### Connection Pooling
Use DatabasePool in GRDB for concurrent reads.

## Potential Pitfalls to Avoid

### 1. Not Using Transactions

```swift
// BAD - Unbounded transaction
for item in items {
    try db.insert(item) // Each insert commits
}

// GOOD - Single transaction
try db.write { db in
    for item in items {
        var record = ClipboardItemRecord(item: item)
        try record.save(db)
    }
}
```

### 2. SQL Injection

```swift
// BAD - String interpolation
let sql = "SELECT * FROM items WHERE id = '\(id)'"

// GOOD - Parameterized queries
let sql = "SELECT * FROM items WHERE id = ?"
// Bind id as parameter
```

### 3. Not Handling Errors

```swift
// BAD - Ignoring errors
_ = try? db.insert(item)

// GOOD - Proper error handling
do {
    try db.insert(item)
} let error {
    print("Failed to insert: \(error)")
    // Show user error
}
```

### 4. Memory Issues with Large Results

```swift
// BAD - Loading all items at once
let allItems = db.fetchAll() // Could be huge

// GOOD - Paginated or cursor-based
let page1 = db.fetch(limit: 100, offset: 0)
```

### 5. Not Closing Connections

```swift
// BAD - Never closes
let db = Database(path: "...")

// GOOD - Proper cleanup
deinit {
    db.close()
}
```

## Library Comparison

| Feature | Native SQLite3 | GRDB.swift | SQLite.swift |
|---------|---------------|------------|-------------|
| Type Safety | Low | High | Medium |
| Async Support | Manual | Built-in | Manual |
| Query Builder | None | Yes | Yes |
| Migrations | Manual | Built-in | Manual |
| Performance | Best | Good | Good |
| Learning Curve | High | Medium | Medium |
| Documentation | Extensive | Good | Good |

## Best Practices Summary

1. **Use Type-Safe Wrapper**: GRDB.swift is recommended for Swift开发
2. **Parameterize Queries**: Always use prepared statements
3. **Use Transactions**: Group related operations
4. **Index Wisely**: Add indexes on frequently queried columns
5. **Enable WAL Mode**: Better performance for concurrent access
6. **Limit History Size**: Don't store unlimited clipboard history
7. **Vacuum Periodically**: Reclaim space with `VACUUM`
8. **Handle Errors Gracefully**: Show user-friendly error messages
9. **Test Concurrency**: Ensure thread-safe access
10. **Backup Regularly**: Offer export/import functionality

## Useful SQL Queries

```sql
-- Get recent items by type
SELECT * FROM clipboard_items
WHERE type = 'image'
ORDER BY created_at DESC
LIMIT 50;

-- Get duplicate content
SELECT content, COUNT(*) as count
FROM clipboard_items
GROUP BY content
HAVING count > 1;

-- Get stats by day
SELECT DATE(created_at), COUNT(*) as count
FROM clipboard_items
GROUP BY DATE(created_at)
ORDER BY created_at DESC;

-- Search with ranking (FTS)
SELECT id, rank
FROM clipboard_fts
WHERE clipboard_fts MATCH 'search_query'
ORDER BY rank;
```

<!-- nav -->

---

[< Previous: Clipboard Type Detection](05-clipboard-types.md) | [Table of Contents](../../product-spec.md) | [Next: App Sandboxing Considerations for Clipboard Access >](07-sandboxing.md)

<!-- nav -->
