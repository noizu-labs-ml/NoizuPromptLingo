-- The Robot Remembers — Initial Schema
-- Phase 0: Foundation

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Memory entries — the atomic unit of the system
CREATE TABLE memories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    source_agent TEXT NOT NULL,

    -- Content
    content TEXT NOT NULL,
    content_type TEXT NOT NULL DEFAULT 'episodic'
        CHECK (content_type IN ('episodic', 'semantic', 'procedural')),
    summary TEXT NOT NULL DEFAULT '',

    -- Emotional metadata (JSONB for schema flexibility)
    emotional_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Contextual metadata
    contextual_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Lifecycle
    lifecycle_state TEXT NOT NULL DEFAULT 'active'
        CHECK (lifecycle_state IN ('active', 'consolidating', 'archived', 'quarantined', 'pruned')),
    decay_weight NUMERIC(6,5) NOT NULL DEFAULT 1.0
        CHECK (decay_weight >= 0 AND decay_weight <= 1),
    last_recalled_at TIMESTAMPTZ,
    recall_count INTEGER NOT NULL DEFAULT 0,
    reinforcement_count INTEGER NOT NULL DEFAULT 0,
    denforcement_count INTEGER NOT NULL DEFAULT 0,
    consolidation_ids UUID[] NOT NULL DEFAULT '{}',
    pruned_at TIMESTAMPTZ,

    -- Access control
    compartment TEXT NOT NULL DEFAULT 'default',
    classification TEXT NOT NULL DEFAULT 'open'
        CHECK (classification IN ('open', 'restricted', 'sealed')),
    owner_agent TEXT NOT NULL DEFAULT 'system'
);

-- Indexes for common query patterns
CREATE INDEX idx_memories_lifecycle_state ON memories (lifecycle_state);
CREATE INDEX idx_memories_compartment ON memories (compartment, lifecycle_state);
CREATE INDEX idx_memories_created_at ON memories (created_at);
CREATE INDEX idx_memories_content_type ON memories (content_type);
CREATE INDEX idx_memories_decay_weight ON memories (decay_weight) WHERE lifecycle_state = 'active';
CREATE INDEX idx_memories_source_agent ON memories (source_agent);

-- Quarantine buffer for Guardian-flagged memories
CREATE TABLE memory_quarantine (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    memory_id UUID NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    flagged_by TEXT NOT NULL,
    flagged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolution TEXT CHECK (resolution IN ('approved', 'rejected', 'pending')),
    resolved_at TIMESTAMPTZ,
    resolved_by TEXT,
    UNIQUE (memory_id)
);

CREATE INDEX idx_quarantine_resolution ON memory_quarantine (resolution);

-- Association edges — weighted links between memories
CREATE TABLE association_edges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_memory_id UUID NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
    target_memory_id UUID NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
    weight NUMERIC(6,5) NOT NULL DEFAULT 0.5
        CHECK (weight >= 0 AND weight <= 1),
    edge_type TEXT NOT NULL DEFAULT 'semantic'
        CHECK (edge_type IN ('semantic', 'emotional', 'temporal', 'causal', 'co-occurrence', 'synthetic')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by TEXT NOT NULL,
    reinforcement_count INTEGER NOT NULL DEFAULT 0,
    denforcement_count INTEGER NOT NULL DEFAULT 0,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    UNIQUE (source_memory_id, target_memory_id, edge_type)
);

CREATE INDEX idx_edges_source ON association_edges (source_memory_id);
CREATE INDEX idx_edges_target ON association_edges (target_memory_id);
CREATE INDEX idx_edges_weight ON association_edges (weight) WHERE weight > 0.05;

-- Agent state — per-agent emotional state and metrics
CREATE TABLE agent_state (
    agent_id TEXT PRIMARY KEY,
    agent_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'idle'
        CHECK (status IN ('active', 'idle', 'error')),
    emotional_state JSONB NOT NULL DEFAULT '{}'::jsonb,
    metrics JSONB NOT NULL DEFAULT '{}'::jsonb,
    last_processed_event_id TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Memory compartments — access control partitions
CREATE TABLE compartments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL DEFAULT '',
    access_policy JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert default compartment
INSERT INTO compartments (name, description) VALUES ('default', 'Default memory compartment');

-- Recall log — audit trail for recall requests
CREATE TABLE recall_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    query TEXT NOT NULL,
    mode TEXT NOT NULL CHECK (mode IN ('active', 'tangential')),
    requester TEXT NOT NULL,
    results JSONB NOT NULL DEFAULT '[]'::jsonb,
    total_candidates INTEGER NOT NULL DEFAULT 0,
    latency_ms INTEGER NOT NULL DEFAULT 0,
    hot_index_hit BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_recall_log_created_at ON recall_log (created_at);

-- Audit log — inter-agent event trail
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    source_agent TEXT NOT NULL,
    target_agent TEXT,
    event_type TEXT NOT NULL,
    payload_hash TEXT NOT NULL,
    duration_ms INTEGER,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX idx_audit_log_timestamp ON audit_log (timestamp);
CREATE INDEX idx_audit_log_source ON audit_log (source_agent);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER memories_updated_at
    BEFORE UPDATE ON memories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER edges_updated_at
    BEFORE UPDATE ON association_edges
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER agent_state_updated_at
    BEFORE UPDATE ON agent_state
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
