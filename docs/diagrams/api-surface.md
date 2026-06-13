# API Surface Diagrams

Complete API route map and request/response schemas for The Robot Remembers.

---

## 1. API Route Map

All endpoints grouped by domain. Color coding: blue = read, green = write, orange = action, red = admin.

```mermaid
graph LR
    subgraph "Memory CRUD"
        direction TB
        M1["POST /api/v1/memories<br/><i>Create memory</i>"]
        M2["POST /api/v1/memories/batch<br/><i>Batch ingest</i>"]
        M3["GET /api/v1/memories/:id<br/><i>Get memory + full metadata</i>"]
        M4["PATCH /api/v1/memories/:id<br/><i>Update content/metadata</i>"]
        M5["DELETE /api/v1/memories/:id<br/><i>Request pruning (via Guardian)</i>"]
        M6["GET /api/v1/memories/:id/associations<br/><i>List edges for a memory</i>"]
        M7["GET /api/v1/memories/:id/path/:target_id<br/><i>Find association paths</i>"]
    end

    subgraph "Recall"
        direction TB
        R1["POST /api/v1/recall<br/><i>Active recall: deep search</i>"]
        R2["POST /api/v1/recall/by-association<br/><i>Traverse from memory ID</i>"]
        R3["POST /api/v1/recall/by-emotion<br/><i>Recall by emotional state</i>"]
        R4["WS /api/v1/stream<br/><i>Tangential insertion stream</i>"]
    end

    subgraph "Reinforcement"
        direction TB
        RF1["POST /api/v1/memories/:id/reinforce<br/><i>Boost decay weight + edges</i>"]
        RF2["POST /api/v1/memories/:id/denforce<br/><i>Weaken decay weight</i>"]
        RF3["POST /api/v1/memories/:id/merge<br/><i>Request consolidation</i>"]
    end

    subgraph "Agents"
        direction TB
        A1["GET /api/v1/agents<br/><i>List all agents + state</i>"]
        A2["GET /api/v1/agents/:id<br/><i>Agent detail</i>"]
        A3["GET /api/v1/agents/:id/state<br/><i>Current emotional state vector</i>"]
        A4["GET /api/v1/agents/:id/logs<br/><i>Recent activity log</i>"]
    end

    subgraph "Guardian"
        direction TB
        G1["GET /api/v1/guardian/quarantine<br/><i>List quarantined memories</i>"]
        G2["POST /api/v1/guardian/quarantine/:id/approve<br/><i>Release from quarantine</i>"]
        G3["POST /api/v1/guardian/quarantine/:id/reject<br/><i>Reject quarantined memory</i>"]
        G4["GET /api/v1/guardian/alerts<br/><i>Integrity alert feed</i>"]
        G5["POST /api/v1/guardian/alerts/:id/resolve<br/><i>Acknowledge alert</i>"]
    end

    subgraph "Admin"
        direction TB
        AD1["GET /api/v1/admin/health<br/><i>System health summary</i>"]
        AD2["GET /api/v1/admin/metrics<br/><i>Memory count, edges, storage</i>"]
        AD3["PATCH /api/v1/admin/weights<br/><i>Update global weight params</i>"]
        AD4["PATCH /api/v1/admin/decay-config<br/><i>Update decay curve params</i>"]
        AD5["GET /api/v1/admin/compartments<br/><i>List compartments + policies</i>"]
        AD6["POST /api/v1/admin/compartments<br/><i>Create new compartment</i>"]
        AD7["PUT /api/v1/agents/:id/state<br/><i>Manual agent state override</i>"]
        AD8["POST /api/v1/admin/hot-index/refresh<br/><i>Force hot index rebuild</i>"]
    end

    style M1 fill:#4caf50,color:#fff
    style M2 fill:#4caf50,color:#fff
    style M3 fill:#42a5f5,color:#fff
    style M4 fill:#ff9800,color:#000
    style M5 fill:#ef5350,color:#fff
    style M6 fill:#42a5f5,color:#fff
    style M7 fill:#42a5f5,color:#fff
    style R1 fill:#4caf50,color:#fff
    style R2 fill:#4caf50,color:#fff
    style R3 fill:#4caf50,color:#fff
    style R4 fill:#ab47bc,color:#fff
    style RF1 fill:#ff9800,color:#000
    style RF2 fill:#ff9800,color:#000
    style RF3 fill:#ff9800,color:#000
    style A1 fill:#42a5f5,color:#fff
    style A2 fill:#42a5f5,color:#fff
    style A3 fill:#42a5f5,color:#fff
    style A4 fill:#42a5f5,color:#fff
    style G1 fill:#42a5f5,color:#fff
    style G2 fill:#4caf50,color:#fff
    style G3 fill:#ef5350,color:#fff
    style G4 fill:#42a5f5,color:#fff
    style G5 fill:#ff9800,color:#000
    style AD1 fill:#78909c,color:#fff
    style AD2 fill:#78909c,color:#fff
    style AD3 fill:#78909c,color:#fff
    style AD4 fill:#78909c,color:#fff
    style AD5 fill:#78909c,color:#fff
    style AD6 fill:#78909c,color:#fff
    style AD7 fill:#78909c,color:#fff
    style AD8 fill:#78909c,color:#fff
```

### Endpoint Summary

| Domain | Count | Auth Level |
|--------|-------|------------|
| Memory CRUD | 7 | Agent or API key |
| Recall | 4 | Agent or API key |
| Reinforcement | 3 | Agent or API key |
| Agents | 4 | Read: any authenticated; Write: admin |
| Guardian | 5 | Operator or admin |
| Admin | 8 | Admin only |
| **Total** | **31** | |

---

## 2. WebSocket Stream Protocol

The tangential insertion stream (`WS /api/v1/stream`) is a bidirectional WebSocket. The client sends conversation turns; the server pushes tangential memories when resonance exceeds threshold.

```mermaid
sequenceDiagram
    participant C as Client Agent
    participant WS as WebSocket /api/v1/stream
    participant SYS as Memory System

    C->>WS: Connect + auth token + session_id
    WS-->>C: { type: "connected", session_id, config }

    loop Every conversation turn
        C->>WS: { type: "turn", content, emotional_state }
        WS->>SYS: Resonance detection pipeline

        alt Resonance above threshold
            WS-->>C: { type: "tangential",<br/>  memories: [...],<br/>  resonance_score,<br/>  injection_hint }
        end

        alt Periodic state update
            WS-->>C: { type: "state_update",<br/>  agent_states: {...},<br/>  hot_index_stats: {...} }
        end
    end

    C->>WS: { type: "feedback",<br/>  memory_id, helpful: true/false }
    WS->>SYS: Reinforcement / denforcement signal

    C->>WS: Close
    WS-->>C: { type: "disconnected",<br/>  session_stats: {...} }
```

---

## 3. Request/Response Schemas

TypeScript interfaces for the key API payloads. These define the contract between client agents and the memory service.

### Recall

```typescript
// POST /api/v1/recall
interface RecallRequest {
  /** Natural language query text */
  query: string;

  /** Which retrieval mode to use */
  mode: 'active' | 'tangential';

  /** Maximum memories to return (active: 10-20, tangential: 1-3) */
  max_results?: number;

  /** Current emotional state for resonance scoring */
  emotional_context?: {
    /** Use the Monitor's current state instead of providing one */
    match_current_mood?: boolean;

    /** Override emotional state for this query */
    mood_override?: {
      valence?: number;   // -1.0 to 1.0
      arousal?: number;   // 0.0 to 1.0
      dominance?: number; // 0.0 to 1.0
    };

    /** Override hormonal state for this query */
    hormones_override?: {
      cortisol?: number;  // 0.0 to 1.0
      dopamine?: number;  // 0.0 to 1.0
      oxytocin?: number;  // 0.0 to 1.0
      serotonin?: number; // 0.0 to 1.0
    };
  };

  /** Filter by contextual attributes */
  contextual_filter?: {
    domain?: string;
    time_of_day?: 'morning' | 'afternoon' | 'evening' | 'night';
    season?: 'spring' | 'summer' | 'autumn' | 'winter';
    collaborators?: string[];
    content_type?: 'episodic' | 'semantic' | 'procedural';
  };

  /** Temporal range filter */
  temporal_range?: {
    after?: string;  // ISO 8601
    before?: string; // ISO 8601
  };

  /** Graph traversal configuration */
  traversal?: {
    max_depth?: number;      // default 3
    min_edge_weight?: number; // default 0.2
    edge_types?: Array<'semantic' | 'emotional' | 'temporal' | 'causal' | 'co-occurrence' | 'synthetic'>;
  };

  /** Output format */
  format?: 'context_injection' | 'full' | 'summary_only';
}

interface RecallResponse {
  /** Recalled memories, ordered by relevance */
  memories: RecalledMemory[];

  /** Metadata about the recall operation */
  meta: {
    query: string;
    mode: 'active' | 'tangential';
    latency_ms: number;
    candidates_evaluated: number;
    paths_explored: number;
    emotional_state_used: EmotionalVector;
    winnowed_from: number;
  };
}

interface RecalledMemory {
  id: string;
  content: string;
  summary: string;
  content_type: 'episodic' | 'semantic' | 'procedural';

  /** Composite relevance score (0.0-1.0) */
  relevance_score: number;

  /** Emotional resonance between query state and memory (0.0-1.0) */
  emotional_resonance: number;

  /** How this memory was found */
  retrieval_path: 'vector' | 'attribute' | 'graph_traversal' | 'co-occurrence';

  /** Emotional state when this memory was formed */
  emotional_metadata: EmotionalMetadata;

  /** When and where this memory was formed */
  contextual_metadata: ContextualMetadataSummary;

  /** Strongest associations from this memory */
  associations: AssociationHint[];

  /** Lifecycle info */
  decay_weight: number;
  recall_count: number;
  created_at: string;
  last_recalled_at: string | null;
}

interface AssociationHint {
  target_memory_id: string;
  target_summary: string;
  edge_type: string;
  weight: number;
}
```

### Memory Write

```typescript
// POST /api/v1/memories
interface MemoryWriteRequest {
  /** The memory content — natural language text */
  content: string;

  /** Memory classification */
  content_type?: 'episodic' | 'semantic' | 'procedural';

  /** Compressed version (auto-generated if omitted) */
  summary?: string;

  /** Emotional state at time of memory formation */
  emotional_metadata?: {
    mood?: {
      valence?: number;
      arousal?: number;
      dominance?: number;
    };
    hormones?: {
      cortisol?: number;
      dopamine?: number;
      oxytocin?: number;
      serotonin?: number;
    };
    frustration_index?: number;
    confidence?: 'high' | 'medium' | 'low';
  };

  /** Contextual information about the formation moment */
  contextual_metadata?: {
    topic?: string;
    domain?: string;
    modality?: 'chat' | 'voice' | 'api' | 'api_batch' | 'background';
    collaborators?: string[];
    environment?: Record<string, string>;
  };

  /** Access control partition */
  compartment?: string;

  /** Classification level */
  classification?: 'open' | 'restricted' | 'sealed';

  /** Source identification */
  source_agent?: string;
}

interface MemoryWriteResponse {
  id: string;
  lifecycle_state: 'enriched' | 'quarantined';
  content_type: string;
  decay_weight: number;
  created_at: string;

  /** If quarantined, why */
  quarantine_reason?: string;

  /** Associations created (empty if still processing) */
  associations_created: number;
}
```

### Agent State

```typescript
// GET /api/v1/agents/:id/state
interface AgentStateResponse {
  agent_id: string;
  agent_name: string;
  agent_role: string;
  biological_analogue: string;
  status: 'active' | 'idle' | 'degraded' | 'offline';

  /** Current emotional state vector */
  emotional_state: EmotionalVector;

  /** Operational metrics */
  metrics: {
    /** Events processed in the last hour */
    throughput_per_hour: number;
    /** Pending items in the agent's work queue */
    queue_depth: number;
    /** Error rate (0.0-1.0) over the last hour */
    error_rate: number;
    /** Average processing time per event (ms) */
    avg_latency_ms: number;
    /** Uptime since last restart */
    uptime_seconds: number;
  };

  /** Agent-specific stats */
  agent_specific: Record<string, unknown>;
  // Examples:
  //   Archivist: { memories_formed_today: 47, salience_rejection_rate: 0.62 }
  //   Guardian:  { quarantined_today: 3, contradiction_rate: 0.04 }
  //   Weaver:    { edges_created_today: 182, avg_edge_weight: 0.41 }
  //   Curator:   { pruned_today: 12, archived_today: 5 }
  //   Dreamer:   { consolidated_today: 8, speculative_proposals: 15 }
  //   Sentinel:  { access_denials_today: 2, redactions_applied: 7 }
  //   Recall:    { queries_today: 89, avg_latency_ms: 340, hit_rate: 0.78 }
  //   Monitor:   { state_broadcasts_today: 156, drift_events: 12 }

  last_updated: string;
}
```

### Shared Types

```typescript
interface EmotionalVector {
  valence: number;    // -1.0 to 1.0
  arousal: number;    // 0.0 to 1.0
  dominance: number;  // 0.0 to 1.0
  cortisol: number;   // 0.0 to 1.0
  dopamine: number;   // 0.0 to 1.0
  oxytocin: number;   // 0.0 to 1.0
  serotonin: number;  // 0.0 to 1.0
}

interface EmotionalMetadata extends EmotionalVector {
  frustration_index: number;
  confidence: 'high' | 'medium' | 'low';
  schema_version: number;
}

interface ContextualMetadataSummary {
  timestamp_utc: string;
  time_of_day: string;
  domain: string;
  topic: string;
  collaborators: string[];
  modality: string;
}
```

### Health and Metrics

```typescript
// GET /api/v1/admin/health
interface HealthResponse {
  status: 'healthy' | 'degraded' | 'unhealthy';
  components: {
    api: ComponentHealth;
    orchestrator: ComponentHealth;
    postgres: ComponentHealth;
    weaviate: ComponentHealth;
    redis: ComponentHealth;
  };
  timestamp: string;
}

interface ComponentHealth {
  status: 'up' | 'degraded' | 'down';
  latency_ms: number;
  details?: string;
}

// GET /api/v1/admin/metrics
interface MetricsResponse {
  memories: {
    total: number;
    by_state: Record<string, number>;
    by_type: Record<string, number>;
    by_compartment: Record<string, number>;
  };
  associations: {
    total_edges: number;
    avg_weight: number;
    by_type: Record<string, number>;
  };
  storage: {
    postgres_size_mb: number;
    weaviate_size_mb: number;
    redis_memory_mb: number;
  };
  recall: {
    total_queries_24h: number;
    active_queries_24h: number;
    tangential_insertions_24h: number;
    avg_active_latency_ms: number;
    avg_tangential_latency_ms: number;
    hit_rate: number;
  };
  quarantine: {
    pending: number;
    approved_24h: number;
    rejected_24h: number;
  };
  agents: Record<string, {
    status: string;
    queue_depth: number;
    error_rate: number;
  }>;
  timestamp: string;
}
```

---

## 4. Authentication and Authorization

```mermaid
graph TB
    subgraph "Auth Flow"
        REQ["API Request"]
        AUTH["Auth Middleware"]
        ROLE["Role Resolution"]
        COMP["Compartment Check<br/>(Sentinel)"]
        HANDLER["Route Handler"]
    end

    REQ -->|"Bearer token or<br/>API key header"| AUTH
    AUTH -->|"Validate JWT / API key"| ROLE
    ROLE -->|"agent / operator / admin"| COMP
    COMP -->|"Allowed compartments<br/>+ redaction rules"| HANDLER

    subgraph "Role Permissions"
        direction TB
        R_AGENT["<b>agent</b><br/>Read: own compartment memories<br/>Write: create memories<br/>Recall: active + tangential<br/>Reinforce/denforce: yes"]
        R_OPER["<b>operator</b><br/>Read: all compartments<br/>Write: create + edit<br/>Recall: all modes<br/>Guardian: quarantine management<br/>Agent state: read"]
        R_ADMIN["<b>admin</b><br/>All operator permissions<br/>+ weight/decay config<br/>+ compartment management<br/>+ agent state override<br/>+ hot index control"]
    end
```

| Role | Memory Read | Memory Write | Recall | Guardian | Admin | Agent State |
|------|-------------|-------------|--------|----------|-------|-------------|
| agent | Own compartment | Create | Active + tangential | -- | -- | Read own |
| operator | All compartments | Create + edit | All modes | Quarantine mgmt | -- | Read all |
| admin | All + sealed | All | All | All | All | Read + write |
