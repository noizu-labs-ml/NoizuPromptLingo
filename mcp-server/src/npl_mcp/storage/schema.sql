-- NPL MCP Database Schema

-- Artifacts: Main artifact registry
CREATE TABLE IF NOT EXISTS artifacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL,  -- 'document', 'image', 'code', 'data', etc.
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    current_revision_id INTEGER,
    FOREIGN KEY (current_revision_id) REFERENCES revisions(id)
);

-- Revisions: Version history for artifacts
CREATE TABLE IF NOT EXISTS revisions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    artifact_id INTEGER NOT NULL,
    revision_num INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    created_by TEXT,  -- persona slug
    file_path TEXT NOT NULL,  -- relative path in data/artifacts/
    meta_path TEXT NOT NULL,  -- path to .meta.md file
    purpose TEXT,
    notes TEXT,
    FOREIGN KEY (artifact_id) REFERENCES artifacts(id),
    UNIQUE(artifact_id, revision_num)
);

-- Reviews: Artifact review sessions
CREATE TABLE IF NOT EXISTS reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    artifact_id INTEGER NOT NULL,
    revision_id INTEGER NOT NULL,
    reviewer_persona TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    status TEXT DEFAULT 'in_progress',  -- 'in_progress', 'completed'
    overall_comment TEXT,
    FOREIGN KEY (artifact_id) REFERENCES artifacts(id),
    FOREIGN KEY (revision_id) REFERENCES revisions(id)
);

-- Inline Comments: Line-by-line or position-based comments
CREATE TABLE IF NOT EXISTS inline_comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    review_id INTEGER NOT NULL,
    location TEXT NOT NULL,  -- 'line:58' or '@x:100,y:200' for images
    comment TEXT NOT NULL,
    persona TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (review_id) REFERENCES reviews(id)
);

-- Review Overlays: Image annotation overlays
CREATE TABLE IF NOT EXISTS review_overlays (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    review_id INTEGER NOT NULL,
    overlay_file TEXT NOT NULL,  -- path to overlay image/annotation
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (review_id) REFERENCES reviews(id)
);

-- Chat Rooms: Collaboration spaces
CREATE TABLE IF NOT EXISTS chat_rooms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    description TEXT
);

-- Room Members: Persona membership in rooms
CREATE TABLE IF NOT EXISTS room_members (
    room_id INTEGER NOT NULL,
    persona_slug TEXT NOT NULL,
    joined_at TEXT NOT NULL DEFAULT (datetime('now')),
    PRIMARY KEY (room_id, persona_slug),
    FOREIGN KEY (room_id) REFERENCES chat_rooms(id)
);

-- Chat Events: All events in chat rooms
CREATE TABLE IF NOT EXISTS chat_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    room_id INTEGER NOT NULL,
    event_type TEXT NOT NULL,  -- 'message', 'emoji_reaction', 'artifact_share', 'todo_create', 'persona_join', 'persona_leave'
    persona TEXT NOT NULL,
    timestamp TEXT NOT NULL DEFAULT (datetime('now')),
    data TEXT NOT NULL,  -- JSON-encoded event data
    reply_to_id INTEGER,  -- optional: ID of event being replied to
    FOREIGN KEY (room_id) REFERENCES chat_rooms(id),
    FOREIGN KEY (reply_to_id) REFERENCES chat_events(id)
);

-- Notifications: User notifications from @mentions and events
CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    persona TEXT NOT NULL,
    event_id INTEGER NOT NULL,
    notification_type TEXT NOT NULL,  -- 'mention', 'artifact_share', 'todo_assign', etc.
    read_at TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (event_id) REFERENCES chat_events(id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_revisions_artifact ON revisions(artifact_id);
CREATE INDEX IF NOT EXISTS idx_reviews_artifact ON reviews(artifact_id);
CREATE INDEX IF NOT EXISTS idx_reviews_revision ON reviews(revision_id);
CREATE INDEX IF NOT EXISTS idx_inline_comments_review ON inline_comments(review_id);
CREATE INDEX IF NOT EXISTS idx_chat_events_room ON chat_events(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_events_timestamp ON chat_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_notifications_persona ON notifications(persona);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(persona, read_at);
