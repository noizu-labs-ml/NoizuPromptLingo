import Database from "better-sqlite3";
import type {
  AgentHarness,
  Conversation,
  RawTranscriptEvent,
  ThreadEdit,
  EditedMessage,
  UniversalMessage,
  Dataset,
  DatasetEntry,
  QualityLabel,
} from "@llm-toolkit/shared";

export interface TagMeta {
  name: string;
  color: string;
  description: string;
  createdAt: Date;
}

export interface ProjectMeta {
  projectPath: string;
  title: string | null;
  description: string | null;
  tags: string[];
  updatedAt: Date;
}

export interface SavedPrompt {
  id: string;
  title: string;
  content: string;
  role: string;
  tags: string[];
  evals: Record<string, unknown> | null;
  sourceConversationId?: string;
  sourceMessageIndex?: number;
  createdAt: Date;
  updatedAt: Date;
}
import { createHash } from "node:crypto";
import * as sqliteVec from "sqlite-vec";

export interface StoredMessage {
  conversationId: string;
  role: string;
  content: string;
  timestamp: string;
}

export interface StoredUniversalMessage extends UniversalMessage {
  conversationId: string;
}

export interface ConversationWorkItem {
  id: string;
  conversationId: string;
  kind: string;
  title: string;
  description: string;
  evidence: string | null;
  startIndex: number;
  endIndex: number;
  confidence: number;
  createdAt: string;
}

export interface IndexStatus {
  status: "idle" | "indexing";
  lastIndexed: string | null;
  conversationCount: number;
}

export class StorageService {
  private db: Database.Database | null = null;
  private dbPath: string;
  private _status: "idle" | "indexing" = "idle";
  private _lastIndexed: string | null = null;
  private _vecAvailable = false;

  constructor(dbPath: string = "llm-toolkit.db") {
    this.dbPath = dbPath;
  }

  getDb(): Database.Database {
    if (!this.db) throw new Error("StorageService not initialized — call initialize() first");
    return this.db;
  }

  async initialize(): Promise<void> {
    this.db = new Database(this.dbPath);
    this.db.pragma("journal_mode = WAL");
    this.db.pragma("foreign_keys = ON");

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS conversations (
        id            TEXT PRIMARY KEY,
        harness       TEXT NOT NULL DEFAULT 'claude',
        project_path  TEXT NOT NULL,
        started_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL,
        message_count INTEGER NOT NULL DEFAULT 0,
        title         TEXT NOT NULL DEFAULT '',
        slug          TEXT UNIQUE,
        description   TEXT,
        summary       TEXT,
        tags          TEXT NOT NULL DEFAULT '[]',
        status        TEXT NOT NULL DEFAULT 'active',
        source_path   TEXT NOT NULL
      );

      CREATE INDEX IF NOT EXISTS idx_conversations_project ON conversations(project_path);
      CREATE INDEX IF NOT EXISTS idx_conversations_updated ON conversations(updated_at);
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS messages (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id TEXT NOT NULL,
        role          TEXT NOT NULL,
        content       TEXT NOT NULL,
        timestamp     TEXT NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id)
      );

      CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS universal_messages (
        id              TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        role            TEXT NOT NULL,
        timestamp       TEXT NOT NULL,
        payload         TEXT NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id)
      );

      CREATE INDEX IF NOT EXISTS idx_universal_messages_conversation ON universal_messages(conversation_id);
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS raw_transcript_events (
        id              TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        timestamp       TEXT NOT NULL,
        harness         TEXT NOT NULL,
        event_type      TEXT NOT NULL,
        payload         TEXT NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id)
      );

      CREATE INDEX IF NOT EXISTS idx_raw_events_conversation ON raw_transcript_events(conversation_id);
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS conversation_work_items (
        id              TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        kind            TEXT NOT NULL,
        title           TEXT NOT NULL,
        description     TEXT NOT NULL,
        evidence        TEXT,
        start_index     INTEGER NOT NULL DEFAULT 0,
        end_index       INTEGER NOT NULL DEFAULT 0,
        confidence      REAL NOT NULL DEFAULT 0,
        created_at      TEXT NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id)
      );

      CREATE INDEX IF NOT EXISTS idx_work_items_conversation ON conversation_work_items(conversation_id);
    `);

    this.db.exec(`
      CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts USING fts5(
        content,
        content='messages',
        content_rowid='id'
      );
    `);

    // Triggers to keep FTS index in sync with messages table
    this.db.exec(`
      CREATE TRIGGER IF NOT EXISTS messages_ai AFTER INSERT ON messages BEGIN
        INSERT INTO messages_fts(rowid, content) VALUES (new.id, new.content);
      END;
      CREATE TRIGGER IF NOT EXISTS messages_ad AFTER DELETE ON messages BEGIN
        INSERT INTO messages_fts(messages_fts, rowid, content) VALUES('delete', old.id, old.content);
      END;
      CREATE TRIGGER IF NOT EXISTS messages_au AFTER UPDATE ON messages BEGIN
        INSERT INTO messages_fts(messages_fts, rowid, content) VALUES('delete', old.id, old.content);
        INSERT INTO messages_fts(rowid, content) VALUES (new.id, new.content);
      END;
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS thread_edits (
        id          TEXT PRIMARY KEY,
        source_id   TEXT NOT NULL,
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        status      TEXT NOT NULL DEFAULT 'finalized',
        messages    TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (source_id) REFERENCES conversations(id)
      );

      CREATE INDEX IF NOT EXISTS idx_edits_source ON thread_edits(source_id);
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS datasets (
        name        TEXT PRIMARY KEY,
        description TEXT NOT NULL DEFAULT '',
        version     INTEGER NOT NULL DEFAULT 1,
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL,
        entry_count INTEGER NOT NULL DEFAULT 0
      );

      CREATE TABLE IF NOT EXISTS dataset_entries (
        id              TEXT PRIMARY KEY,
        dataset_name    TEXT NOT NULL,
        conversation_id TEXT NOT NULL,
        edit_id         TEXT,
        start_index     INTEGER NOT NULL,
        end_index       INTEGER NOT NULL,
        quality         TEXT NOT NULL DEFAULT 'silver',
        system_prompt   TEXT,
        messages        TEXT NOT NULL DEFAULT '[]',
        created_at      TEXT NOT NULL,
        FOREIGN KEY (dataset_name) REFERENCES datasets(name),
        FOREIGN KEY (conversation_id) REFERENCES conversations(id)
      );

      CREATE INDEX IF NOT EXISTS idx_entries_dataset ON dataset_entries(dataset_name);
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS saved_prompts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user',
        tags TEXT NOT NULL DEFAULT '[]',
        evals TEXT,
        source_conversation_id TEXT,
        source_message_index INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS project_metadata (
        project_path TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        tags TEXT NOT NULL DEFAULT '[]',
        updated_at TEXT NOT NULL
      );
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS tag_metadata (
        name TEXT PRIMARY KEY,
        color TEXT NOT NULL DEFAULT '#06B6D4',
        description TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      );
    `);

    this.db.exec(`
      CREATE TABLE IF NOT EXISTS settings (
        key        TEXT PRIMARY KEY,
        value      TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    `);

    this.migrateThreadEdits();
    this.migrateConversationsMeta();
    this.migrateConversationHarness();
    this.initVectorTable();
  }

  private migrateThreadEdits(): void {
    const db = this.getDb();
    const cols = db.prepare("PRAGMA table_info(thread_edits)").all() as Array<{ name: string }>;
    const colNames = new Set(cols.map((c) => c.name));
    if (!colNames.has("status")) {
      db.exec("ALTER TABLE thread_edits ADD COLUMN status TEXT NOT NULL DEFAULT 'finalized'");
    }
    if (!colNames.has("updated_at")) {
      db.exec("ALTER TABLE thread_edits ADD COLUMN updated_at TEXT NOT NULL DEFAULT ''");
    }
  }

  private migrateConversationsMeta(): void {
    const db = this.getDb();
    const cols = db.prepare("PRAGMA table_info(conversations)").all() as Array<{ name: string }>;
    const colNames = new Set(cols.map((c) => c.name));
    if (!colNames.has("slug")) {
      db.exec("ALTER TABLE conversations ADD COLUMN slug TEXT");
      db.exec("CREATE UNIQUE INDEX IF NOT EXISTS idx_conversations_slug ON conversations(slug)");
    }
    if (!colNames.has("description")) {
      db.exec("ALTER TABLE conversations ADD COLUMN description TEXT");
    }
  }

  private migrateConversationHarness(): void {
    const db = this.getDb();
    const cols = db.prepare("PRAGMA table_info(conversations)").all() as Array<{ name: string }>;
    const colNames = new Set(cols.map((c) => c.name));
    if (!colNames.has("harness")) {
      db.exec("ALTER TABLE conversations ADD COLUMN harness TEXT NOT NULL DEFAULT 'claude'");
    }
    db.exec("CREATE INDEX IF NOT EXISTS idx_conversations_harness ON conversations(harness)");
  }

  private initVectorTable(): void {
    const db = this.getDb();
    try {
      sqliteVec.load(db);
      db.exec(`
        CREATE VIRTUAL TABLE IF NOT EXISTS conversation_vectors USING vec0(
          id TEXT PRIMARY KEY,
          embedding float[384]
        );

        CREATE VIRTUAL TABLE IF NOT EXISTS work_item_vectors USING vec0(
          id TEXT PRIMARY KEY,
          embedding float[384]
        );
      `);
      this._vecAvailable = true;
    } catch (err) {
      console.warn(
        `sqlite-vec not available: ${err instanceof Error ? err.message : err}. Semantic search disabled.`,
      );
      this._vecAvailable = false;
    }
  }

  get vecAvailable(): boolean {
    return this._vecAvailable;
  }

  async upsertVector(conversationId: string, embedding: Float32Array): Promise<void> {
    if (!this._vecAvailable) return;
    const db = this.getDb();
    db.prepare(
      "INSERT OR REPLACE INTO conversation_vectors (id, embedding) VALUES (?, ?)",
    ).run(conversationId, Buffer.from(embedding.buffer));
  }

  async upsertWorkItemVector(workItemId: string, embedding: Float32Array): Promise<void> {
    if (!this._vecAvailable) return;
    const db = this.getDb();
    db.prepare(
      "INSERT OR REPLACE INTO work_item_vectors (id, embedding) VALUES (?, ?)",
    ).run(workItemId, Buffer.from(embedding.buffer));
  }

  async knnSearch(queryEmbedding: Float32Array, limit: number = 20): Promise<Array<{ id: string; distance: number }>> {
    if (!this._vecAvailable) return [];
    const db = this.getDb();
    const rows = db.prepare(`
      SELECT id, distance
      FROM conversation_vectors
      WHERE embedding MATCH ?
      ORDER BY distance
      LIMIT ?
    `).all(Buffer.from(queryEmbedding.buffer), limit) as Array<{ id: string; distance: number }>;
    return rows;
  }

  async knnSearchWorkItems(queryEmbedding: Float32Array, limit: number = 20): Promise<Array<ConversationWorkItem & { distance: number }>> {
    if (!this._vecAvailable) return [];
    const db = this.getDb();
    const rows = db.prepare(`
      SELECT
        wi.id,
        wi.conversation_id as conversationId,
        wi.kind,
        wi.title,
        wi.description,
        wi.evidence,
        wi.start_index as startIndex,
        wi.end_index as endIndex,
        wi.confidence,
        wi.created_at as createdAt,
        vectors.distance
      FROM (
        SELECT id, distance
        FROM work_item_vectors
        WHERE embedding MATCH ?
        ORDER BY distance
        LIMIT ?
      ) vectors
      JOIN conversation_work_items wi ON wi.id = vectors.id
      ORDER BY vectors.distance
    `).all(Buffer.from(queryEmbedding.buffer), limit) as Array<ConversationWorkItem & { distance: number }>;
    return rows;
  }

  async getConversations(options?: {
    sort?: string;
    limit?: number;
    offset?: number;
    groupBy?: string;
    harness?: AgentHarness;
    project?: string;
  }): Promise<Conversation[]> {
    const db = this.getDb();
    const sort = options?.sort ?? "updated_at";
    const limit = options?.limit ?? 20;
    const offset = options?.offset ?? 0;

    const allowedSorts: Record<string, string> = {
      updated_at: "updated_at DESC",
      started_at: "started_at DESC",
      message_count: "message_count DESC",
      title: "title ASC",
    };
    const orderClause = allowedSorts[sort] ?? "updated_at DESC";

    let query = `SELECT c.*,
      (SELECT substr(content, 1, 200) FROM messages m WHERE m.conversation_id = c.id ORDER BY m.id ASC LIMIT 1) as first_message,
      (SELECT substr(content, 1, 200) FROM messages m WHERE m.conversation_id = c.id ORDER BY m.id DESC LIMIT 1) as last_message
      FROM conversations c`;
    const params: unknown[] = [];
    const wheres: string[] = [];

    if (options?.harness) {
      wheres.push("c.harness = ?");
      params.push(options.harness);
    }

    if (options?.project) {
      wheres.push("c.project_path = ?");
      params.push(options.project);
    }

    if (wheres.length > 0) {
      query += ` WHERE ${wheres.join(" AND ")}`;
    }

    query += ` ORDER BY ${orderClause} LIMIT ? OFFSET ?`;
    params.push(limit, offset);

    const rows = db.prepare(query).all(...params) as ConversationRow[];
    return rows.map(rowToConversation);
  }

  async getConversationCount(project?: string, harness?: AgentHarness): Promise<number> {
    const db = this.getDb();
    const wheres: string[] = [];
    const params: unknown[] = [];
    if (project) {
      wheres.push("project_path = ?");
      params.push(project);
    }
    if (harness) {
      wheres.push("harness = ?");
      params.push(harness);
    }
    const whereClause = wheres.length > 0 ? ` WHERE ${wheres.join(" AND ")}` : "";
    const row = db.prepare(`SELECT COUNT(*) as count FROM conversations${whereClause}`).get(...params) as { count: number };
    return row.count;
  }

  async getConversation(id: string): Promise<Conversation | null> {
    const db = this.getDb();
    const row = db.prepare("SELECT * FROM conversations WHERE id = ?").get(id) as ConversationRow | undefined;
    return row ? rowToConversation(row) : null;
  }

  async upsertConversation(conv: {
    id: string;
    harness?: AgentHarness;
    projectPath: string;
    startedAt: string;
    updatedAt: string;
    messageCount: number;
    title: string;
    summary?: string | null;
    tags?: string[];
    status?: string;
    sourcePath: string;
  }): Promise<void> {
    const db = this.getDb();
    db.prepare(`
      INSERT INTO conversations (id, harness, project_path, started_at, updated_at, message_count, title, summary, tags, status, source_path)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        harness = excluded.harness,
        project_path = excluded.project_path,
        started_at = excluded.started_at,
        updated_at = excluded.updated_at,
        message_count = excluded.message_count,
        title = excluded.title,
        summary = excluded.summary,
        tags = excluded.tags,
        status = excluded.status,
        source_path = excluded.source_path
    `).run(
      conv.id,
      conv.harness ?? "claude",
      conv.projectPath,
      conv.startedAt,
      conv.updatedAt,
      conv.messageCount,
      conv.title,
      conv.summary ?? null,
      JSON.stringify(conv.tags ?? []),
      conv.status ?? "active",
      conv.sourcePath,
    );
  }

  async updateConversationMeta(id: string, updates: { slug?: string | null; description?: string | null; title?: string }): Promise<void> {
    const db = this.getDb();
    const sets: string[] = [];
    const params: unknown[] = [];
    if (updates.slug !== undefined) {
      sets.push("slug = ?");
      params.push(updates.slug);
    }
    if (updates.description !== undefined) {
      sets.push("description = ?");
      params.push(updates.description);
    }
    if (updates.title !== undefined) {
      sets.push("title = ?");
      params.push(updates.title);
    }
    if (sets.length === 0) return;
    params.push(id);
    db.prepare(`UPDATE conversations SET ${sets.join(", ")} WHERE id = ?`).run(...params);
  }

  async getConversationBySlug(slug: string): Promise<Conversation | null> {
    const db = this.getDb();
    const row = db.prepare("SELECT * FROM conversations WHERE slug = ?").get(slug) as ConversationRow | undefined;
    return row ? rowToConversation(row) : null;
  }

  async insertMessages(conversationId: string, messages: StoredMessage[]): Promise<void> {
    const db = this.getDb();
    db.prepare("DELETE FROM messages WHERE conversation_id = ?").run(conversationId);

    const insert = db.prepare(
      "INSERT INTO messages (conversation_id, role, content, timestamp) VALUES (?, ?, ?, ?)",
    );
    const batch = db.transaction((msgs: StoredMessage[]) => {
      for (const msg of msgs) {
        insert.run(msg.conversationId, msg.role, msg.content, msg.timestamp);
      }
    });
    batch(messages);
  }

  async insertUniversalMessages(conversationId: string, messages: UniversalMessage[]): Promise<void> {
    const db = this.getDb();
    db.prepare("DELETE FROM universal_messages WHERE conversation_id = ?").run(conversationId);

    const insert = db.prepare(
      "INSERT INTO universal_messages (id, conversation_id, role, timestamp, payload) VALUES (?, ?, ?, ?, ?)",
    );
    const batch = db.transaction((msgs: UniversalMessage[]) => {
      for (const msg of msgs) {
        insert.run(msg.id, conversationId, msg.role, msg.timestamp, JSON.stringify(msg));
      }
    });
    batch(messages);
  }

  async getUniversalMessages(conversationId: string): Promise<StoredUniversalMessage[]> {
    const db = this.getDb();
    const rows = db
      .prepare("SELECT conversation_id as conversationId, payload FROM universal_messages WHERE conversation_id = ? ORDER BY timestamp, id")
      .all(conversationId) as Array<{ conversationId: string; payload: string }>;
    return rows.map((row) => ({ ...JSON.parse(row.payload), conversationId }));
  }

  async insertRawTranscriptEvents(conversationId: string, events: RawTranscriptEvent[]): Promise<void> {
    const db = this.getDb();
    db.prepare("DELETE FROM raw_transcript_events WHERE conversation_id = ?").run(conversationId);

    const insert = db.prepare(
      "INSERT INTO raw_transcript_events (id, conversation_id, timestamp, harness, event_type, payload) VALUES (?, ?, ?, ?, ?, ?)",
    );
    const batch = db.transaction((items: RawTranscriptEvent[]) => {
      for (const event of items) {
        insert.run(event.id, conversationId, event.timestamp, event.harness, event.eventType, JSON.stringify(event.raw));
      }
    });
    batch(events);
  }

  async getRawTranscriptEvents(conversationId: string): Promise<RawTranscriptEvent[]> {
    const db = this.getDb();
    const rows = db
      .prepare("SELECT id, timestamp, harness, event_type as eventType, payload FROM raw_transcript_events WHERE conversation_id = ? ORDER BY timestamp, id")
      .all(conversationId) as Array<{ id: string; timestamp: string; harness: AgentHarness; eventType: string; payload: string }>;
    return rows.map((row) => ({
      id: row.id,
      timestamp: row.timestamp,
      harness: row.harness,
      eventType: row.eventType,
      raw: JSON.parse(row.payload),
    }));
  }

  async replaceConversationWorkItems(conversationId: string, items: ConversationWorkItem[]): Promise<void> {
    const db = this.getDb();
    const existing = db
      .prepare("SELECT id FROM conversation_work_items WHERE conversation_id = ?")
      .all(conversationId) as Array<{ id: string }>;

    if (this._vecAvailable) {
      const deleteVector = db.prepare("DELETE FROM work_item_vectors WHERE id = ?");
      for (const row of existing) deleteVector.run(row.id);
    }

    db.prepare("DELETE FROM conversation_work_items WHERE conversation_id = ?").run(conversationId);

    const insert = db.prepare(`
      INSERT INTO conversation_work_items
        (id, conversation_id, kind, title, description, evidence, start_index, end_index, confidence, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    const batch = db.transaction((workItems: ConversationWorkItem[]) => {
      for (const item of workItems) {
        insert.run(
          item.id,
          conversationId,
          item.kind,
          item.title,
          item.description,
          item.evidence,
          item.startIndex,
          item.endIndex,
          item.confidence,
          item.createdAt,
        );
      }
    });
    batch(items);
  }

  async getConversationWorkItems(conversationId: string): Promise<ConversationWorkItem[]> {
    const db = this.getDb();
    return db.prepare(`
      SELECT
        id,
        conversation_id as conversationId,
        kind,
        title,
        description,
        evidence,
        start_index as startIndex,
        end_index as endIndex,
        confidence,
        created_at as createdAt
      FROM conversation_work_items
      WHERE conversation_id = ?
      ORDER BY start_index, id
    `).all(conversationId) as ConversationWorkItem[];
  }

  async getMessages(conversationId: string): Promise<StoredMessage[]> {
    const db = this.getDb();
    return db
      .prepare("SELECT conversation_id as conversationId, role, content, timestamp FROM messages WHERE conversation_id = ? ORDER BY id")
      .all(conversationId) as StoredMessage[];
  }

  async getStats(): Promise<{ conversationCount: number; projectCount: number; lastIndexed: string | null }> {
    const db = this.getDb();
    const convRow = db.prepare("SELECT COUNT(*) as count FROM conversations").get() as { count: number };
    const projRow = db.prepare("SELECT COUNT(DISTINCT project_path) as count FROM conversations").get() as { count: number };
    return {
      conversationCount: convRow.count,
      projectCount: projRow.count,
      lastIndexed: this._lastIndexed,
    };
  }

  setIndexStatus(status: "idle" | "indexing"): void {
    this._status = status;
    if (status === "idle") {
      this._lastIndexed = new Date().toISOString();
    }
  }

  getIndexStatus(): IndexStatus {
    return {
      status: this._status,
      lastIndexed: this._lastIndexed,
      conversationCount: this.db
        ? (this.db.prepare("SELECT COUNT(*) as count FROM conversations").get() as { count: number }).count
        : 0,
    };
  }

  // Dataset methods
  async createDataset(name: string, description: string): Promise<Dataset> {
    const db = this.getDb();
    const now = new Date().toISOString();
    db.prepare(
      "INSERT INTO datasets (name, description, created_at, updated_at) VALUES (?, ?, ?, ?)",
    ).run(name, description, now, now);
    return { name, description, version: 1, createdAt: new Date(now), updatedAt: new Date(now), entryCount: 0 };
  }

  async getDatasets(): Promise<Dataset[]> {
    const db = this.getDb();
    const rows = db.prepare("SELECT * FROM datasets ORDER BY updated_at DESC").all() as DatasetRow[];
    return rows.map(rowToDataset);
  }

  async getDataset(name: string): Promise<Dataset | null> {
    const db = this.getDb();
    const row = db.prepare("SELECT * FROM datasets WHERE name = ?").get(name) as DatasetRow | undefined;
    return row ? rowToDataset(row) : null;
  }

  async createDatasetEntry(entry: {
    datasetName: string;
    conversationId: string;
    editId?: string;
    startIndex: number;
    endIndex: number;
    quality: QualityLabel;
    systemPrompt?: string;
    messages: Array<{ role: string; content: string }>;
  }): Promise<DatasetEntry> {
    const db = this.getDb();
    const id = createHash("sha256").update(`${entry.datasetName}:${entry.conversationId}:${Date.now()}`).digest("hex").slice(0, 16);
    const now = new Date().toISOString();
    db.prepare(
      "INSERT INTO dataset_entries (id, dataset_name, conversation_id, edit_id, start_index, end_index, quality, system_prompt, messages, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
    ).run(id, entry.datasetName, entry.conversationId, entry.editId ?? null, entry.startIndex, entry.endIndex, entry.quality, entry.systemPrompt ?? null, JSON.stringify(entry.messages), now);

    db.prepare("UPDATE datasets SET entry_count = entry_count + 1, updated_at = ? WHERE name = ?").run(now, entry.datasetName);

    return { id, ...entry, createdAt: new Date(now) };
  }

  async getDatasetEntries(datasetName: string, filters?: { quality?: QualityLabel }): Promise<DatasetEntry[]> {
    const db = this.getDb();
    let query = "SELECT * FROM dataset_entries WHERE dataset_name = ?";
    const params: unknown[] = [datasetName];
    if (filters?.quality) {
      query += " AND quality = ?";
      params.push(filters.quality);
    }
    query += " ORDER BY created_at DESC";
    const rows = db.prepare(query).all(...params) as DatasetEntryRow[];
    return rows.map(rowToDatasetEntry);
  }

  async updateDatasetEntry(id: string, updates: { quality?: QualityLabel; systemPrompt?: string }): Promise<void> {
    const db = this.getDb();
    if (updates.quality) {
      db.prepare("UPDATE dataset_entries SET quality = ? WHERE id = ?").run(updates.quality, id);
    }
    if (updates.systemPrompt !== undefined) {
      db.prepare("UPDATE dataset_entries SET system_prompt = ? WHERE id = ?").run(updates.systemPrompt, id);
    }
  }

  async deleteDatasetEntry(id: string): Promise<void> {
    const db = this.getDb();
    const entry = db.prepare("SELECT dataset_name FROM dataset_entries WHERE id = ?").get(id) as { dataset_name: string } | undefined;
    db.prepare("DELETE FROM dataset_entries WHERE id = ?").run(id);
    if (entry) {
      db.prepare("UPDATE datasets SET entry_count = entry_count - 1 WHERE name = ?").run(entry.dataset_name);
    }
  }

  async createEdit(sourceId: string, description: string, messages: EditedMessage[], status: "draft" | "finalized" = "finalized"): Promise<ThreadEdit> {
    const db = this.getDb();
    const id = createHash("sha256").update(`${sourceId}:${Date.now()}`).digest("hex").slice(0, 16);
    const now = new Date().toISOString();
    db.prepare(
      "INSERT INTO thread_edits (id, source_id, created_at, updated_at, description, status, messages) VALUES (?, ?, ?, ?, ?, ?, ?)",
    ).run(id, sourceId, now, now, description, status, JSON.stringify(messages));
    return { id, sourceId, createdAt: new Date(now), description, messages };
  }

  async getEdits(conversationId: string): Promise<ThreadEdit[]> {
    const db = this.getDb();
    const rows = db.prepare(
      "SELECT * FROM thread_edits WHERE source_id = ? AND status = 'finalized' ORDER BY created_at DESC",
    ).all(conversationId) as EditRow[];
    return rows.map(rowToEdit);
  }

  async getEdit(editId: string): Promise<ThreadEdit | null> {
    const db = this.getDb();
    const row = db.prepare("SELECT * FROM thread_edits WHERE id = ?").get(editId) as EditRow | undefined;
    return row ? rowToEdit(row) : null;
  }

  async getDraftEdit(conversationId: string): Promise<ThreadEdit | null> {
    const db = this.getDb();
    const row = db.prepare(
      "SELECT * FROM thread_edits WHERE source_id = ? AND status = 'draft' ORDER BY updated_at DESC LIMIT 1",
    ).get(conversationId) as EditRow | undefined;
    return row ? rowToEdit(row) : null;
  }

  async updateEdit(editId: string, messages: EditedMessage[], description?: string): Promise<void> {
    const db = this.getDb();
    const now = new Date().toISOString();
    if (description !== undefined) {
      db.prepare("UPDATE thread_edits SET messages = ?, description = ?, updated_at = ? WHERE id = ?")
        .run(JSON.stringify(messages), description, now, editId);
    } else {
      db.prepare("UPDATE thread_edits SET messages = ?, updated_at = ? WHERE id = ?")
        .run(JSON.stringify(messages), now, editId);
    }
  }

  async finalizeEdit(editId: string): Promise<void> {
    const db = this.getDb();
    const now = new Date().toISOString();
    db.prepare("UPDATE thread_edits SET status = 'finalized', updated_at = ? WHERE id = ?").run(now, editId);
  }

  async deleteEdit(editId: string): Promise<void> {
    const db = this.getDb();
    db.prepare("DELETE FROM thread_edits WHERE id = ?").run(editId);
  }

  async createPrompt(prompt: {
    title: string;
    content: string;
    role: string;
    tags?: string[];
    sourceConversationId?: string;
    sourceMessageIndex?: number;
  }): Promise<SavedPrompt> {
    const db = this.getDb();
    const id = createHash("sha256").update(`${prompt.title}:${prompt.content}:${Date.now()}`).digest("hex").slice(0, 16);
    const now = new Date().toISOString();
    db.prepare(
      "INSERT INTO saved_prompts (id, title, content, role, tags, source_conversation_id, source_message_index, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
    ).run(
      id,
      prompt.title,
      prompt.content,
      prompt.role,
      JSON.stringify(prompt.tags ?? []),
      prompt.sourceConversationId ?? null,
      prompt.sourceMessageIndex ?? null,
      now,
      now,
    );
    return {
      id,
      title: prompt.title,
      content: prompt.content,
      role: prompt.role,
      tags: prompt.tags ?? [],
      evals: null,
      sourceConversationId: prompt.sourceConversationId,
      sourceMessageIndex: prompt.sourceMessageIndex,
      createdAt: new Date(now),
      updatedAt: new Date(now),
    };
  }

  async getPrompts(): Promise<SavedPrompt[]> {
    const db = this.getDb();
    const rows = db.prepare("SELECT * FROM saved_prompts ORDER BY updated_at DESC").all() as SavedPromptRow[];
    return rows.map(rowToSavedPrompt);
  }

  async getPrompt(id: string): Promise<SavedPrompt | null> {
    const db = this.getDb();
    const row = db.prepare("SELECT * FROM saved_prompts WHERE id = ?").get(id) as SavedPromptRow | undefined;
    return row ? rowToSavedPrompt(row) : null;
  }

  async updatePrompt(id: string, updates: { title?: string; content?: string; tags?: string[]; evals?: Record<string, unknown> | null }): Promise<void> {
    const db = this.getDb();
    const now = new Date().toISOString();
    if (updates.title !== undefined) db.prepare("UPDATE saved_prompts SET title = ?, updated_at = ? WHERE id = ?").run(updates.title, now, id);
    if (updates.content !== undefined) db.prepare("UPDATE saved_prompts SET content = ?, updated_at = ? WHERE id = ?").run(updates.content, now, id);
    if (updates.tags !== undefined) db.prepare("UPDATE saved_prompts SET tags = ?, updated_at = ? WHERE id = ?").run(JSON.stringify(updates.tags), now, id);
    if (updates.evals !== undefined) db.prepare("UPDATE saved_prompts SET evals = ?, updated_at = ? WHERE id = ?").run(updates.evals ? JSON.stringify(updates.evals) : null, now, id);
  }

  async deletePrompt(id: string): Promise<void> {
    const db = this.getDb();
    db.prepare("DELETE FROM saved_prompts WHERE id = ?").run(id);
  }

  async getProjectMeta(projectPath: string): Promise<ProjectMeta | null> {
    const db = this.getDb();
    const row = db.prepare("SELECT * FROM project_metadata WHERE project_path = ?").get(projectPath) as ProjectMetaRow | undefined;
    return row ? rowToProjectMeta(row) : null;
  }

  async getAllProjectMeta(): Promise<ProjectMeta[]> {
    const db = this.getDb();
    const rows = db.prepare("SELECT * FROM project_metadata ORDER BY updated_at DESC").all() as ProjectMetaRow[];
    return rows.map(rowToProjectMeta);
  }

  async upsertProjectMeta(meta: { projectPath: string; title?: string; description?: string; tags?: string[] }): Promise<void> {
    const db = this.getDb();
    const now = new Date().toISOString();
    const existing = db.prepare("SELECT * FROM project_metadata WHERE project_path = ?").get(meta.projectPath) as ProjectMetaRow | undefined;
    if (existing) {
      db.prepare(`
        UPDATE project_metadata SET
          title = ?,
          description = ?,
          tags = ?,
          updated_at = ?
        WHERE project_path = ?
      `).run(
        meta.title !== undefined ? meta.title : existing.title,
        meta.description !== undefined ? meta.description : existing.description,
        meta.tags !== undefined ? JSON.stringify(meta.tags) : existing.tags,
        now,
        meta.projectPath,
      );
    } else {
      db.prepare(`
        INSERT INTO project_metadata (project_path, title, description, tags, updated_at)
        VALUES (?, ?, ?, ?, ?)
      `).run(
        meta.projectPath,
        meta.title ?? null,
        meta.description ?? null,
        JSON.stringify(meta.tags ?? []),
        now,
      );
    }
  }

  async getTagMeta(name: string): Promise<TagMeta | null> {
    const db = this.getDb();
    const row = db.prepare("SELECT * FROM tag_metadata WHERE name = ?").get(name) as TagMetaRow | undefined;
    return row ? rowToTagMeta(row) : null;
  }

  async getAllTagMeta(): Promise<TagMeta[]> {
    const db = this.getDb();
    const rows = db.prepare("SELECT * FROM tag_metadata ORDER BY name ASC").all() as TagMetaRow[];
    return rows.map(rowToTagMeta);
  }

  async upsertTagMeta(meta: { name: string; color?: string; description?: string }): Promise<void> {
    const db = this.getDb();
    const now = new Date().toISOString();
    const existing = db.prepare("SELECT * FROM tag_metadata WHERE name = ?").get(meta.name) as TagMetaRow | undefined;
    if (existing) {
      db.prepare(`
        UPDATE tag_metadata SET color = ?, description = ? WHERE name = ?
      `).run(
        meta.color !== undefined ? meta.color : existing.color,
        meta.description !== undefined ? meta.description : existing.description,
        meta.name,
      );
    } else {
      db.prepare(`
        INSERT INTO tag_metadata (name, color, description, created_at) VALUES (?, ?, ?, ?)
      `).run(
        meta.name,
        meta.color ?? '#06B6D4',
        meta.description ?? '',
        now,
      );
    }
  }

  async deleteTagMeta(name: string): Promise<void> {
    const db = this.getDb();
    db.prepare("DELETE FROM tag_metadata WHERE name = ?").run(name);
  }

  getSetting(key: string): string | null {
    const db = this.getDb();
    const row = db.prepare("SELECT value FROM settings WHERE key = ?").get(key) as { value: string } | undefined;
    return row?.value ?? null;
  }

  setSetting(key: string, value: string): void {
    const db = this.getDb();
    const now = new Date().toISOString();
    db.prepare(
      "INSERT INTO settings (key, value, updated_at) VALUES (?, ?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at",
    ).run(key, value, now);
  }

  getAllSettings(): Record<string, string> {
    const db = this.getDb();
    const rows = db.prepare("SELECT key, value FROM settings").all() as Array<{ key: string; value: string }>;
    const result: Record<string, string> = {};
    for (const row of rows) result[row.key] = row.value;
    return result;
  }

  close(): void {
    this.db?.close();
    this.db = null;
  }

  static generateId(sourcePath: string, firstTimestamp: string, harness: AgentHarness = "claude"): string {
    const seed = harness === "claude" ? `${sourcePath}:${firstTimestamp}` : `${harness}:${sourcePath}:${firstTimestamp}`;
    return createHash("sha256").update(seed).digest("hex").slice(0, 16);
  }
}

interface ConversationRow {
  id: string;
  harness: string;
  project_path: string;
  started_at: string;
  updated_at: string;
  message_count: number;
  title: string;
  slug: string | null;
  description: string | null;
  summary: string | null;
  tags: string;
  status: string;
  source_path: string;
  first_message?: string | null;
  last_message?: string | null;
}

function rowToConversation(row: ConversationRow): Conversation {
  return {
    id: row.id,
    harness: (row.harness ?? "claude") as AgentHarness,
    projectPath: row.project_path,
    startedAt: new Date(row.started_at),
    updatedAt: new Date(row.updated_at),
    messageCount: row.message_count,
    title: row.title,
    slug: row.slug,
    description: row.description,
    summary: row.summary,
    tags: JSON.parse(row.tags),
    status: row.status as Conversation["status"],
    sourcePath: row.source_path,
    firstMessage: row.first_message ?? undefined,
    lastMessage: row.last_message ?? undefined,
  };
}

interface EditRow {
  id: string;
  source_id: string;
  created_at: string;
  updated_at: string;
  description: string;
  status: string;
  messages: string;
}

function rowToEdit(row: EditRow): ThreadEdit {
  return {
    id: row.id,
    sourceId: row.source_id,
    createdAt: new Date(row.created_at),
    description: row.description,
    messages: JSON.parse(row.messages),
  };
}

interface DatasetRow {
  name: string;
  description: string;
  version: number;
  created_at: string;
  updated_at: string;
  entry_count: number;
}

function rowToDataset(row: DatasetRow): Dataset {
  return {
    name: row.name,
    description: row.description,
    version: row.version,
    createdAt: new Date(row.created_at),
    updatedAt: new Date(row.updated_at),
    entryCount: row.entry_count,
  };
}

interface DatasetEntryRow {
  id: string;
  dataset_name: string;
  conversation_id: string;
  edit_id: string | null;
  start_index: number;
  end_index: number;
  quality: string;
  system_prompt: string | null;
  messages: string;
  created_at: string;
}

function rowToDatasetEntry(row: DatasetEntryRow): DatasetEntry {
  return {
    id: row.id,
    datasetName: row.dataset_name,
    conversationId: row.conversation_id,
    editId: row.edit_id ?? undefined,
    startIndex: row.start_index,
    endIndex: row.end_index,
    quality: row.quality as QualityLabel,
    systemPrompt: row.system_prompt ?? undefined,
    messages: JSON.parse(row.messages),
    createdAt: new Date(row.created_at),
  };
}

interface SavedPromptRow {
  id: string;
  title: string;
  content: string;
  role: string;
  tags: string;
  evals: string | null;
  source_conversation_id: string | null;
  source_message_index: number | null;
  created_at: string;
  updated_at: string;
}

function rowToSavedPrompt(row: SavedPromptRow): SavedPrompt {
  return {
    id: row.id,
    title: row.title,
    content: row.content,
    role: row.role,
    tags: JSON.parse(row.tags),
    evals: row.evals ? JSON.parse(row.evals) : null,
    sourceConversationId: row.source_conversation_id ?? undefined,
    sourceMessageIndex: row.source_message_index ?? undefined,
    createdAt: new Date(row.created_at),
    updatedAt: new Date(row.updated_at),
  };
}

interface ProjectMetaRow {
  project_path: string;
  title: string | null;
  description: string | null;
  tags: string;
  updated_at: string;
}

function rowToProjectMeta(row: ProjectMetaRow): ProjectMeta {
  return {
    projectPath: row.project_path,
    title: row.title,
    description: row.description,
    tags: JSON.parse(row.tags),
    updatedAt: new Date(row.updated_at),
  };
}

interface TagMetaRow {
  name: string;
  color: string;
  description: string;
  created_at: string;
}

function rowToTagMeta(row: TagMetaRow): TagMeta {
  return {
    name: row.name,
    color: row.color,
    description: row.description,
    createdAt: new Date(row.created_at),
  };
}
