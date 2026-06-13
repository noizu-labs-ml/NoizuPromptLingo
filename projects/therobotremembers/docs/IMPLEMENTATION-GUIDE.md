# Implementation Guide: The Robot Remembers

This is the developer-facing "how to build this" document. Open this on day 1 of Phase 0.

**Related docs:**
- `ARCHITECTURE.md` — System design, data models, agent details
- `CONCEPTS.md` — Concept glossary
- `adrs/` — Architecture Decision Records explaining why each design choice was made

---

## 1. Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 22+ | Runtime (native ES modules, `crypto.randomUUID`, stable `fetch`) |
| pnpm | 9+ | Package manager (workspace protocol) |
| Docker + Docker Compose | Latest | Local Weaviate, PostgreSQL, Redis |
| kubectl + helm | Latest | K8s deployment |
| Turborepo | 2+ | Monorepo task orchestration |
| TypeScript | 5.5+ | Language |

Optional but recommended:
- `pgcli` or `psql` — Direct database access
- `redis-cli` — Hot index inspection
- `jq` — API response formatting
- `httpie` or `curl` — API testing

---

## 2. Local Development Setup

### 2.1 Docker Compose — Infrastructure Services

Create `app/docker-compose.yaml` for local development. This runs the three storage backends:

```yaml
version: "3.8"
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: therobotremembers
      POSTGRES_USER: trr
      POSTGRES_PASSWORD: trr_dev_password
    ports:
      - "5432:5432"
    volumes:
      - pg_data:/var/lib/postgresql/data
      - ./packages/storage/migrations:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U trr"]
      interval: 5s
      timeout: 3s
      retries: 5

  weaviate:
    image: cr.weaviate.io/semitechnologies/weaviate:1.28.2
    environment:
      QUERY_DEFAULTS_LIMIT: 50
      AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED: "true"
      PERSISTENCE_DATA_PATH: /var/lib/weaviate
      DEFAULT_VECTORIZER_MODULE: none
      CLUSTER_HOSTNAME: node1
    ports:
      - "8080:8080"
      - "50051:50051"
    volumes:
      - weaviate_data:/var/lib/weaviate
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:8080/v1/.well-known/ready"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  pg_data:
  weaviate_data:
  redis_data:
```

### 2.2 Environment Variables

Create `app/.env.development`:

```bash
# PostgreSQL
DATABASE_URL=postgresql://trr:trr_dev_password@localhost:5432/therobotremembers

# Weaviate
WEAVIATE_URL=http://localhost:8080
WEAVIATE_API_KEY=  # empty for local dev (anonymous access)

# Redis
REDIS_URL=redis://localhost:6379

# LLM
ANTHROPIC_API_KEY=sk-ant-...       # Required for agent operations
OPENAI_API_KEY=sk-...               # Required for embeddings (text-embedding-3-small)

# Embedding
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_DIMENSIONS=1536

# Agent tunables (overridable via ConfigMap in K8s)
MEMORY_DECAY_HALF_LIFE_EPISODIC=168
MEMORY_DECAY_HALF_LIFE_SEMANTIC=720
MEMORY_DECAY_HALF_LIFE_PROCEDURAL=2160
EDGE_DECAY_HALF_LIFE_HOURS=720
EDGE_REINFORCE_BASE_BOOST=0.1
EDGE_CORECALL_BASE_BOOST=0.05
EDGE_PRUNE_THRESHOLD=0.05
TANGENTIAL_THRESHOLD=0.75
HOT_INDEX_REFRESH_TURNS=5
HOT_INDEX_BUCKET_SIZE=100
```

### 2.3 Bootstrap

```bash
cd app
docker compose up -d
pnpm install
pnpm run migrate          # Run PostgreSQL migrations
pnpm run seed:weaviate    # Create Weaviate collection schema
pnpm run dev              # Start API + agent runtime in watch mode
```

---

## 3. Project Structure

```
therobotremembers/
├── README.md
├── docs/
│   ├── ARCHITECTURE.md
│   ├── CONCEPTS.md
│   ├── IMPLEMENTATION-GUIDE.md          # This file
│   └── adrs/                            # Architecture Decision Records
├── design/
│   └── SITEMAP.md
├── project-management/
│   ├── personas/
│   ├── user-stories/
│   ├── screens/
│   └── components/
├── app/
│   ├── docker-compose.yaml              # Local infrastructure
│   ├── package.json                     # Workspace root
│   ├── turbo.json                       # Turborepo config
│   ├── tsconfig.base.json               # Shared TypeScript config
│   ├── .env.development
│   ├── packages/
│   │   ├── core/                        # Memory types, emotional model, schemas
│   │   │   ├── src/
│   │   │   │   ├── types/
│   │   │   │   │   ├── memory.ts        # MemoryEntry, ContentType, LifecycleState
│   │   │   │   │   ├── emotion.ts       # EmotionalMetadata, VADVector, HormonalState
│   │   │   │   │   ├── context.ts       # ContextualMetadata, TemporalContext
│   │   │   │   │   ├── association.ts   # AssociationEdge, EdgeType
│   │   │   │   │   ├── agent.ts         # Agent, AgentEvent, AgentAction, AgentState
│   │   │   │   │   └── recall.ts        # RecallRequest, RecallResult, RecallMode
│   │   │   │   ├── schemas/             # Zod schemas mirroring types
│   │   │   │   ├── emotional-model.ts   # Distance, resonance, hormone update functions
│   │   │   │   ├── weight-dynamics.ts   # Decay, reinforcement, Hebbian functions
│   │   │   │   └── index.ts
│   │   │   ├── package.json
│   │   │   └── tsconfig.json
│   │   ├── agents/                      # 8 agent implementations
│   │   │   ├── src/
│   │   │   │   ├── base-agent.ts        # Abstract base with event bus wiring
│   │   │   │   ├── event-bus.ts         # Typed event bus (in-process)
│   │   │   │   ├── monitor.ts
│   │   │   │   ├── archivist.ts
│   │   │   │   ├── guardian.ts
│   │   │   │   ├── weaver.ts
│   │   │   │   ├── curator.ts
│   │   │   │   ├── dreamer.ts
│   │   │   │   ├── sentinel.ts
│   │   │   │   ├── recall-agent.ts
│   │   │   │   └── index.ts
│   │   │   ├── package.json
│   │   │   └── tsconfig.json
│   │   ├── storage/                     # Weaviate, Postgres, Redis clients
│   │   │   ├── src/
│   │   │   │   ├── postgres.ts          # pg client, query builders
│   │   │   │   ├── weaviate.ts          # Weaviate client, collection setup
│   │   │   │   ├── redis.ts             # ioredis client, hot index operations
│   │   │   │   ├── graph-store.ts       # GraphStore interface + Postgres implementation
│   │   │   │   └── index.ts
│   │   │   ├── migrations/              # PostgreSQL migration files (SQL)
│   │   │   │   ├── 001_initial_schema.sql
│   │   │   │   ├── 002_association_edges.sql
│   │   │   │   └── 003_agent_state.sql
│   │   │   ├── package.json
│   │   │   └── tsconfig.json
│   │   ├── api/                         # REST API (Hono or Fastify)
│   │   │   ├── src/
│   │   │   │   ├── server.ts
│   │   │   │   ├── routes/
│   │   │   │   │   ├── memories.ts
│   │   │   │   │   ├── recall.ts
│   │   │   │   │   ├── agents.ts
│   │   │   │   │   └── admin.ts
│   │   │   │   └── middleware/
│   │   │   │       ├── auth.ts
│   │   │   │       └── error-handler.ts
│   │   │   ├── package.json
│   │   │   └── tsconfig.json
│   │   ├── dashboard/                   # Next.js operator UI
│   │   │   ├── src/
│   │   │   │   ├── app/
│   │   │   │   └── components/
│   │   │   ├── package.json
│   │   │   └── tsconfig.json
│   │   └── eval/                        # Eval pipeline
│   │       ├── src/
│   │       │   ├── scenarios/           # Test scenarios with expected recall results
│   │       │   ├── metrics.ts           # Precision, recall, MRR computation
│   │       │   └── runner.ts            # Eval harness
│   │       ├── package.json
│   │       └── tsconfig.json
│   └── Dockerfile                       # Multi-stage build for API + agents
```

---

## 4. Core Type Definitions

These are the foundational interfaces. Define them in `packages/core/src/types/` before writing any agent or storage code.

### 4.1 Emotional Model (`emotion.ts`)

```typescript
import { z } from "zod";

// --- VAD (Valence-Arousal-Dominance) ---

export interface VADVector {
  valence: number;   // -1.0 to 1.0
  arousal: number;   //  0.0 to 1.0
  dominance: number; //  0.0 to 1.0
}

export const VADVectorSchema = z.object({
  valence: z.number().min(-1).max(1),
  arousal: z.number().min(0).max(1),
  dominance: z.number().min(0).max(1),
});

// --- Simulated Hormones ---

export interface HormonalState {
  cortisol: number;  // 0.0 to 1.0 — stress, urgency
  dopamine: number;  // 0.0 to 1.0 — reward, satisfaction
  oxytocin: number;  // 0.0 to 1.0 — trust, bonding
  serotonin: number; // 0.0 to 1.0 — stability, contentment
}

export const HormonalStateSchema = z.object({
  cortisol: z.number().min(0).max(1),
  dopamine: z.number().min(0).max(1),
  oxytocin: z.number().min(0).max(1),
  serotonin: z.number().min(0).max(1),
});

// --- Combined Emotional Metadata ---

export type ConfidenceLevel = "high" | "medium" | "low";

export interface EmotionalMetadata {
  mood: VADVector;
  hormones: HormonalState;
  frustrationIndex: number; // 0.0 to 1.0
  confidence: ConfidenceLevel;
  schemaVersion: number;    // currently 1
}

export const EmotionalMetadataSchema = z.object({
  mood: VADVectorSchema,
  hormones: HormonalStateSchema,
  frustrationIndex: z.number().min(0).max(1),
  confidence: z.enum(["high", "medium", "low"]),
  schemaVersion: z.number().int().positive(),
});

// --- Neutral Baseline ---

export const NEUTRAL_EMOTIONAL_STATE: EmotionalMetadata = {
  mood: { valence: 0.0, arousal: 0.3, dominance: 0.5 },
  hormones: { cortisol: 0.2, dopamine: 0.3, oxytocin: 0.3, serotonin: 0.5 },
  frustrationIndex: 0.0,
  confidence: "low",
  schemaVersion: 1,
};
```

### 4.2 Memory Entry (`memory.ts`)

```typescript
import { z } from "zod";
import type { EmotionalMetadata } from "./emotion";
import type { ContextualMetadata } from "./context";

export type ContentType = "episodic" | "semantic" | "procedural";
export type LifecycleState =
  | "active"
  | "consolidating"
  | "archived"
  | "quarantined"
  | "pruned";
export type Classification = "open" | "restricted" | "sealed";

export interface MemoryEntry {
  id: string;                          // UUID
  version: number;
  createdAt: Date;
  updatedAt: Date;
  sourceAgent: string;

  // Content
  content: string;
  contentType: ContentType;
  summary: string;
  embedding: number[];                 // float[] — dimension matches EMBEDDING_DIMENSIONS

  // Metadata
  emotionalMetadata: EmotionalMetadata;
  contextualMetadata: ContextualMetadata;

  // Lifecycle
  lifecycle: {
    state: LifecycleState;
    decayWeight: number;               // 0.0 to 1.0
    lastRecalledAt: Date | null;
    recallCount: number;
    reinforcementCount: number;
    denforcementCount: number;
    consolidationIds: string[];        // UUIDs of source memories if consolidated
    prunedAt: Date | null;
  };

  // Access control
  compartment: string;
  classification: Classification;
  ownerAgent: string;
}
```

### 4.3 Association Edge (`association.ts`)

```typescript
export type EdgeType =
  | "semantic"
  | "emotional"
  | "temporal"
  | "causal"
  | "co-occurrence"
  | "synthetic";

export interface AssociationEdge {
  id: string;
  sourceMemoryId: string;
  targetMemoryId: string;
  weight: number;                // 0.0 to 1.0
  edgeType: EdgeType;
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;             // Agent that created this link
  reinforcementCount: number;
  denforcementCount: number;
  metadata: {
    reason: string;              // Why this link was created
    emotionalSimilarity: number; // Cosine similarity of emotional vectors
    temporalProximity: number;   // Closeness in time (normalized 0-1)
  };
}
```

### 4.4 Agent Interface (`agent.ts`)

```typescript
export interface AgentEvent {
  id: string;                    // UUID — idempotency key
  type: string;                  // e.g., "memory.stored", "recall.requested"
  timestamp: Date;
  sourceAgent: string;
  payload: unknown;              // Typed per event type via discriminated union
}

export interface AgentAction {
  type: string;
  payload: unknown;
}

export interface EmotionalProfile {
  baselineMood: import("./emotion").VADVector;
  baselineHormones: import("./emotion").HormonalState;
  description: string;          // e.g., "Cautious, high cortisol baseline"
}

export interface AgentState {
  id: string;
  name: string;
  status: "active" | "idle" | "error";
  lastProcessedEventId: string | null;
  emotionalProfile: EmotionalProfile;
  metrics: Record<string, number>;  // Agent-specific counters
}

export interface Agent {
  readonly id: string;
  readonly name: string;
  readonly emotionalProfile: EmotionalProfile;

  /** Process an event and return zero or more actions */
  process(event: AgentEvent): Promise<AgentAction[]>;

  /** Get current agent state (for dashboard, debugging) */
  getState(): AgentState;

  /** Graceful shutdown */
  shutdown(): Promise<void>;
}
```

### 4.5 Recall Types (`recall.ts`)

```typescript
export type RecallMode = "active" | "tangential";

export interface RecallRequest {
  query: string;
  mode: RecallMode;
  maxResults: number;
  emotionalFilter?: {
    matchCurrentMood: boolean;
    moodOverride?: Partial<import("./emotion").VADVector>;
  };
  contextualFilter?: {
    domain?: string;
    timeOfDay?: string;
    season?: string;
    collaborators?: string[];
  };
  traversal?: {
    maxDepth: number;           // default 3
    minEdgeWeight: number;      // default 0.2
    edgeTypes?: import("./association").EdgeType[];
  };
  requesterId: string;          // For Sentinel access check
  compartment?: string;
}

export interface ScoredMemory {
  memory: import("./memory").MemoryEntry;
  relevanceScore: number;       // 0.0 to 1.0
  emotionalResonance: number;   // 0.0 to 1.0
  retrievalPath: string[];      // Memory IDs in the graph path that led here
  distanceFromQuery: number;    // Hop count from seed
}

export interface RecallResult {
  mode: RecallMode;
  query: string;
  totalCandidates: number;
  results: ScoredMemory[];
  durationMs: number;
  hotIndexHit: boolean;         // true if served from Redis hot index
}
```

---

## 5. Phase-by-Phase Implementation Notes

### Phase 0: Foundation (Weeks 1-2)

**Goal:** Storage layer works, you can write and read a memory via raw SQL/API calls.

**Build order:**
1. `packages/core` — All types, schemas, and Zod validators
2. `packages/storage/migrations/001_initial_schema.sql` — `memories` table, `memory_quarantine` table
3. `packages/storage` — PostgreSQL client (`pg` + connection pool), Weaviate client (`weaviate-ts-client`), collection creation script
4. Smoke test: Insert a memory via direct Postgres call, embed it via OpenAI, store in Weaviate, retrieve by vector similarity

**Key migration — `001_initial_schema.sql`:**

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE content_type AS ENUM ('episodic', 'semantic', 'procedural');
CREATE TYPE lifecycle_state AS ENUM ('active', 'consolidating', 'archived', 'quarantined', 'pruned');
CREATE TYPE classification AS ENUM ('open', 'restricted', 'sealed');

CREATE TABLE memories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    source_agent VARCHAR(100) NOT NULL,

    content TEXT NOT NULL,
    content_type content_type NOT NULL DEFAULT 'episodic',
    summary TEXT,

    emotional_metadata JSONB NOT NULL DEFAULT '{}',
    contextual_metadata JSONB NOT NULL DEFAULT '{}',

    lifecycle_state lifecycle_state NOT NULL DEFAULT 'active',
    decay_weight FLOAT NOT NULL DEFAULT 1.0,
    last_recalled_at TIMESTAMPTZ,
    recall_count INT NOT NULL DEFAULT 0,
    reinforcement_count INT NOT NULL DEFAULT 0,
    denforcement_count INT NOT NULL DEFAULT 0,
    consolidation_ids UUID[] DEFAULT '{}',
    pruned_at TIMESTAMPTZ,

    compartment VARCHAR(100) NOT NULL DEFAULT 'default',
    classification classification NOT NULL DEFAULT 'open',
    owner_agent VARCHAR(100) NOT NULL
);

CREATE INDEX idx_memories_state ON memories(lifecycle_state);
CREATE INDEX idx_memories_compartment ON memories(compartment);
CREATE INDEX idx_memories_decay ON memories(decay_weight) WHERE lifecycle_state = 'active';
CREATE INDEX idx_memories_created ON memories(created_at DESC);
CREATE INDEX idx_memories_emotional ON memories USING gin(emotional_metadata);
CREATE INDEX idx_memories_contextual ON memories USING gin(contextual_metadata);

CREATE TABLE memory_quarantine (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    memory_candidate JSONB NOT NULL,
    rejection_reason TEXT NOT NULL,
    rejected_by VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    resolution VARCHAR(20)  -- 'approved' | 'rejected'
);
```

**Smoke test:**
```bash
# Insert a memory
curl -X POST http://localhost:3000/api/v1/memories \
  -H "Content-Type: application/json" \
  -d '{"content": "Debugged a Postgres deadlock at 2 AM", "contentType": "episodic"}'

# Verify it exists in Postgres
psql $DATABASE_URL -c "SELECT id, content, lifecycle_state FROM memories LIMIT 5;"

# Verify embedding in Weaviate
curl http://localhost:8080/v1/objects?class=Memory&limit=5 | jq
```

---

### Phase 1: Formation Pipeline (Weeks 3-4)

**Goal:** Monitor tracks emotional state, Archivist enriches memories, Guardian validates.

**Build order:**
1. `packages/agents/src/event-bus.ts` — Typed in-process event bus with at-least-once delivery
2. `packages/agents/src/base-agent.ts` — Abstract base class with event subscription, state management
3. `Monitor` agent — Maintains running emotional state from conversation events
4. `Archivist` agent — Subscribes to `memory.observed`, attaches emotional/contextual metadata, generates embedding, submits to Guardian
5. `Guardian` agent — Validates schema, contradiction-checks via Weaviate similarity search, approves/quarantines

**Key interface — Event Bus:**

```typescript
type EventHandler = (event: AgentEvent) => Promise<AgentAction[]>;

interface EventBus {
  /** Subscribe an agent to specific event types */
  subscribe(agentId: string, eventTypes: string[], handler: EventHandler): void;

  /** Publish an event — delivered to all subscribers of that type */
  publish(event: AgentEvent): Promise<void>;

  /** Get event history for debugging */
  getHistory(limit: number): AgentEvent[];
}
```

**Integration point:** The Archivist calls the OpenAI embeddings API (`text-embedding-3-small`) to generate the content embedding vector. This is the only external API call in the formation pipeline besides the LLM call for emotional assessment.

**Smoke test:**
```bash
# Submit a raw observation event
curl -X POST http://localhost:3000/api/v1/memories \
  -d '{"content": "Spent 2 hours debugging connection pool exhaustion"}'

# Verify emotional metadata was attached
psql $DATABASE_URL -c "SELECT emotional_metadata FROM memories ORDER BY created_at DESC LIMIT 1;" | jq

# Verify embedding was stored in Weaviate
# (check vector dimension matches EMBEDDING_DIMENSIONS)
```

---

### Phase 2: Association & Graph (Weeks 5-6)

**Goal:** Weaver creates edges. Graph traversal works.

**Build order:**
1. `packages/storage/migrations/002_association_edges.sql` — Edge table with indexes (see ADR-006)
2. `packages/storage/src/graph-store.ts` — `GraphStore` interface + Postgres recursive CTE implementation
3. `Weaver` agent — Subscribes to `memory.stored`, finds related memories, creates edges
4. Graph traversal query builder — Parameterized recursive CTE with depth, weight, and type filters

**Key migration — `002_association_edges.sql`:**

```sql
CREATE TABLE association_edges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_memory_id UUID NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
    target_memory_id UUID NOT NULL REFERENCES memories(id) ON DELETE CASCADE,
    weight FLOAT NOT NULL DEFAULT 0.5,
    edge_type VARCHAR(20) NOT NULL,
    created_by VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reinforcement_count INT NOT NULL DEFAULT 0,
    denforcement_count INT NOT NULL DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    UNIQUE (source_memory_id, target_memory_id, edge_type)
);

CREATE INDEX idx_assoc_source_type_weight
    ON association_edges(source_memory_id, edge_type, weight DESC);
CREATE INDEX idx_assoc_target ON association_edges(target_memory_id);
CREATE INDEX idx_assoc_weight_active ON association_edges(weight) WHERE weight > 0.1;
CREATE INDEX idx_assoc_prune_candidates ON association_edges(weight, updated_at) WHERE weight < 0.05;
```

**Key interface — GraphStore:**

```typescript
interface GraphTraversalOptions {
  seedMemoryIds: string[];
  maxDepth: number;
  minEdgeWeight: number;
  edgeTypes?: EdgeType[];
  limit?: number;
}

interface GraphNeighbor {
  memoryId: string;
  shortestDepth: number;
  maxEdgeWeight: number;
  path: string[];
}

interface GraphStore {
  createEdge(edge: Omit<AssociationEdge, "id" | "createdAt" | "updatedAt">): Promise<AssociationEdge>;
  getEdgesForMemory(memoryId: string): Promise<AssociationEdge[]>;
  traverse(options: GraphTraversalOptions): Promise<GraphNeighbor[]>;
  reinforceEdge(edgeId: string, boost: number): Promise<void>;
  denforceEdge(edgeId: string, penalty: number): Promise<void>;
  pruneWeakEdges(threshold: number, graceHours: number): Promise<number>;
}
```

**Smoke test:**
```bash
# Store 5 related memories
# Verify edges were created
psql $DATABASE_URL -c "SELECT source_memory_id, target_memory_id, weight, edge_type FROM association_edges;"

# Test graph traversal
curl http://localhost:3000/api/v1/memories/{id}/associations | jq
curl http://localhost:3000/api/v1/memories/{id}/path/{target_id} | jq
```

---

### Phase 3: Recall (Weeks 7-8)

**Goal:** Active Recall works end-to-end. Tangential Insertion hot index is populated.

**Build order:**
1. `Sentinel` agent — Access control check (compartment + classification filtering)
2. `Recall Agent` — Active Recall path: vector search -> metadata filter -> graph traversal -> winnow -> format
3. Redis hot index — Background worker that pre-fetches emotionally resonant memories
4. `Recall Agent` — Tangential Insertion path: hot index lookup -> single-hop check -> winnow
5. Context injection formatter — XML output for active, inline for tangential

**Key migration — `003_agent_state.sql`:**

```sql
CREATE TABLE agent_state (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'idle',
    emotional_profile JSONB NOT NULL DEFAULT '{}',
    current_state JSONB NOT NULL DEFAULT '{}',
    last_processed_event_id UUID,
    metrics JSONB NOT NULL DEFAULT '{}',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE recall_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    query TEXT NOT NULL,
    mode VARCHAR(20) NOT NULL,
    requester_id VARCHAR(100) NOT NULL,
    total_candidates INT NOT NULL,
    results_returned INT NOT NULL,
    duration_ms INT NOT NULL,
    hot_index_hit BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE compartments (
    id VARCHAR(100) PRIMARY KEY,
    description TEXT,
    allowed_agents TEXT[] NOT NULL DEFAULT '{}',
    allowed_requesters TEXT[] NOT NULL DEFAULT '{}',
    classification classification NOT NULL DEFAULT 'open',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Smoke test:**
```bash
# Active recall
curl -X POST http://localhost:3000/api/v1/recall \
  -d '{"query": "postgres deadlock", "mode": "active", "maxResults": 10}' | jq

# Verify hot index populated
redis-cli ZCARD "hot:0:1:1"  # Check a bucket has entries

# Tangential insertion (simulated — check sub-100ms)
curl -X POST http://localhost:3000/api/v1/recall \
  -d '{"query": "debugging late at night", "mode": "tangential", "maxResults": 3}' | jq '.durationMs'
```

---

### Phase 4: Lifecycle (Weeks 9-10)

**Goal:** Curator manages decay, archival, pruning. Dreamer runs consolidation.

**Build order:**
1. `Curator` agent — Periodic sweep: compute decay weights, identify pruning candidates, archive stale memories
2. Weight dynamics engine (`packages/core/src/weight-dynamics.ts`) — Decay, reinforcement, Hebbian co-activation functions
3. `Dreamer` agent — Background consolidation: cluster weak memories by emotional/semantic similarity, merge into stronger composites
4. Integration: Dreamer's consolidated memories routed back through Archivist for re-storage and re-validation

**Smoke test:**
```bash
# Fast-forward time on a test memory (set last_recalled_at to 30 days ago)
psql $DATABASE_URL -c "UPDATE memories SET last_recalled_at = NOW() - INTERVAL '30 days' WHERE id = '...';"

# Run curator sweep
curl -X POST http://localhost:3000/api/v1/admin/curator/sweep

# Verify decay_weight decreased
psql $DATABASE_URL -c "SELECT id, decay_weight, lifecycle_state FROM memories WHERE id = '...';"
```

---

### Phase 5: Dashboard & API Polish (Weeks 11-12)

**Goal:** Operator UI, full API surface, error handling, observability.

**Build order:**
1. API routes for all endpoints defined in ARCHITECTURE.md section 7
2. `packages/dashboard` — Next.js app with screens from `project-management/screens/`
3. Health endpoint, Prometheus metrics, structured logging
4. Error handling middleware, rate limiting, input validation

---

### Phase 6: Eval & Tuning (Weeks 13-14)

**Goal:** Eval pipeline validates recall quality. Tune weight dynamics parameters.

**Build order:**
1. `packages/eval/src/scenarios/` — Test scenarios: known memory sets with expected recall results
2. Metrics: Precision@K, Recall@K, Mean Reciprocal Rank (MRR), emotional resonance accuracy
3. Runner: Automated eval harness that ingests scenarios, runs recall, computes metrics
4. Parameter sweep: Grid search over decay half-lives, boost values, pruning thresholds

---

## 6. Agent Implementation Pattern

Every agent follows the same structural pattern. Here is the base class:

```typescript
import type { Agent, AgentEvent, AgentAction, AgentState, EmotionalProfile } from "@trr/core";
import type { EventBus } from "./event-bus";

export abstract class BaseAgent implements Agent {
  abstract readonly id: string;
  abstract readonly name: string;
  abstract readonly emotionalProfile: EmotionalProfile;

  protected status: "active" | "idle" | "error" = "idle";
  protected lastProcessedEventId: string | null = null;
  protected metrics: Record<string, number> = {};

  constructor(protected readonly eventBus: EventBus) {}

  /** Subclasses declare which event types they handle */
  abstract get subscribedEvents(): string[];

  /** Subclasses implement event processing logic */
  abstract handleEvent(event: AgentEvent): Promise<AgentAction[]>;

  /** Register with event bus */
  start(): void {
    this.eventBus.subscribe(this.id, this.subscribedEvents, (event) =>
      this.process(event)
    );
    this.status = "active";
  }

  async process(event: AgentEvent): Promise<AgentAction[]> {
    try {
      const actions = await this.handleEvent(event);
      this.lastProcessedEventId = event.id;
      this.incrementMetric("events_processed");

      // Publish any resulting actions as new events
      for (const action of actions) {
        await this.eventBus.publish({
          id: crypto.randomUUID(),
          type: action.type,
          timestamp: new Date(),
          sourceAgent: this.id,
          payload: action.payload,
        });
      }

      return actions;
    } catch (error) {
      this.status = "error";
      this.incrementMetric("errors");
      throw error;
    }
  }

  getState(): AgentState {
    return {
      id: this.id,
      name: this.name,
      status: this.status,
      lastProcessedEventId: this.lastProcessedEventId,
      emotionalProfile: this.emotionalProfile,
      metrics: { ...this.metrics },
    };
  }

  async shutdown(): Promise<void> {
    this.status = "idle";
  }

  protected incrementMetric(key: string, amount = 1): void {
    this.metrics[key] = (this.metrics[key] ?? 0) + amount;
  }
}
```

**Example — Monitor agent (skeleton):**

```typescript
import { BaseAgent } from "./base-agent";
import type { AgentEvent, AgentAction, EmotionalProfile } from "@trr/core";
import { NEUTRAL_EMOTIONAL_STATE, type EmotionalMetadata } from "@trr/core";

export class MonitorAgent extends BaseAgent {
  readonly id = "monitor";
  readonly name = "The Monitor";
  readonly emotionalProfile: EmotionalProfile = {
    baselineMood: { valence: 0.0, arousal: 0.3, dominance: 0.5 },
    baselineHormones: { cortisol: 0.3, dopamine: 0.3, oxytocin: 0.3, serotonin: 0.5 },
    description: "Observational, neutral baseline, elevated cortisol sensitivity",
  };

  private currentEmotionalState: EmotionalMetadata = { ...NEUTRAL_EMOTIONAL_STATE };

  get subscribedEvents(): string[] {
    return ["conversation.turn", "system.event", "agent.self_report"];
  }

  async handleEvent(event: AgentEvent): Promise<AgentAction[]> {
    // Update emotional state based on event content
    // This is where the LLM call happens — assess emotional tone of the event
    const updatedState = await this.assessEmotionalState(event);
    this.currentEmotionalState = updatedState;

    return [
      {
        type: "emotional_state.updated",
        payload: { state: updatedState },
      },
    ];
  }

  getCurrentEmotionalState(): EmotionalMetadata {
    return { ...this.currentEmotionalState };
  }

  private async assessEmotionalState(event: AgentEvent): Promise<EmotionalMetadata> {
    // TODO: LLM call to assess emotional tone of the event
    // Returns updated VAD + hormonal state
    return this.currentEmotionalState;
  }
}
```

---

## 7. Emotional Model Implementation

Core computation functions in `packages/core/src/emotional-model.ts`:

```typescript
import type { EmotionalMetadata, VADVector, HormonalState } from "./types/emotion";

/**
 * Convert emotional metadata to a 7-dimensional vector for distance computation.
 */
export function toEmotionalVector(em: EmotionalMetadata): number[] {
  return [
    em.mood.valence,
    em.mood.arousal,
    em.mood.dominance,
    em.hormones.cortisol,
    em.hormones.dopamine,
    em.hormones.oxytocin,
    em.hormones.serotonin,
  ];
}

/**
 * Cosine distance between two vectors. Returns 0 (identical) to 2 (opposite).
 */
export function cosineDistance(a: number[], b: number[]): number {
  let dotProduct = 0;
  let normA = 0;
  let normB = 0;
  for (let i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  const denominator = Math.sqrt(normA) * Math.sqrt(normB);
  if (denominator === 0) return 1; // orthogonal if either is zero vector
  return 1 - dotProduct / denominator;
}

/**
 * Emotional resonance between two states.
 * Returns 0.0 (no resonance) to 1.0 (identical emotional state).
 */
export function emotionalResonance(
  current: EmotionalMetadata,
  memory: EmotionalMetadata
): number {
  const currentVec = toEmotionalVector(current);
  const memoryVec = toEmotionalVector(memory);
  const distance = cosineDistance(currentVec, memoryVec);
  return 1 - distance / 2; // Normalize from [0, 2] to [0, 1]
}

/**
 * Euclidean distance in VAD space (useful for bucketing).
 */
export function vadDistance(a: VADVector, b: VADVector): number {
  return Math.sqrt(
    (a.valence - b.valence) ** 2 +
    (a.arousal - b.arousal) ** 2 +
    (a.dominance - b.dominance) ** 2
  );
}

/**
 * Quantize a float value into N discrete buckets.
 * Used for Redis hot index keying (ADR-004).
 */
export function quantize(value: number, buckets: number, min = -1, max = 1): number {
  const range = max - min;
  const normalized = (value - min) / range; // 0 to 1
  return Math.min(buckets - 1, Math.floor(normalized * buckets));
}

/**
 * Generate Redis hot index bucket key from emotional state.
 * ~36 buckets: 4 valence * 3 arousal * 3 dominance.
 */
export function hotIndexBucketKey(em: EmotionalMetadata): string {
  const v = quantize(em.mood.valence, 4, -1, 1);
  const a = quantize(em.mood.arousal, 3, 0, 1);
  const d = quantize(em.mood.dominance, 3, 0, 1);
  return `hot:${v}:${a}:${d}`;
}

/**
 * Simulated hormone update rules.
 * Call after significant events to shift the Monitor's running state.
 */
export function updateHormones(
  current: HormonalState,
  event: {
    type: "error" | "success" | "collaboration" | "disruption" | "idle";
    intensity: number; // 0.0 to 1.0
  }
): HormonalState {
  const delta = event.intensity * 0.15; // Max shift per event
  const decay = 0.05; // Natural regression toward baseline per event

  const clamp = (v: number) => Math.max(0, Math.min(1, v));

  switch (event.type) {
    case "error":
      return {
        cortisol: clamp(current.cortisol + delta),
        dopamine: clamp(current.dopamine - delta * 0.5),
        oxytocin: current.oxytocin,
        serotonin: clamp(current.serotonin - delta * 0.3),
      };
    case "success":
      return {
        cortisol: clamp(current.cortisol - delta * 0.5),
        dopamine: clamp(current.dopamine + delta),
        oxytocin: current.oxytocin,
        serotonin: clamp(current.serotonin + delta * 0.3),
      };
    case "collaboration":
      return {
        cortisol: current.cortisol,
        dopamine: clamp(current.dopamine + delta * 0.3),
        oxytocin: clamp(current.oxytocin + delta),
        serotonin: clamp(current.serotonin + delta * 0.2),
      };
    case "disruption":
      return {
        cortisol: clamp(current.cortisol + delta * 0.8),
        dopamine: clamp(current.dopamine - delta * 0.3),
        oxytocin: clamp(current.oxytocin - delta * 0.2),
        serotonin: clamp(current.serotonin - delta * 0.5),
      };
    case "idle":
      // Regress all hormones toward baseline (0.3-0.5 range)
      return {
        cortisol: clamp(current.cortisol + (0.2 - current.cortisol) * decay),
        dopamine: clamp(current.dopamine + (0.3 - current.dopamine) * decay),
        oxytocin: clamp(current.oxytocin + (0.3 - current.oxytocin) * decay),
        serotonin: clamp(current.serotonin + (0.5 - current.serotonin) * decay),
      };
  }
}
```

---

## 8. Weight Dynamics Implementation

In `packages/core/src/weight-dynamics.ts`:

```typescript
export interface DecayConfig {
  halfLifeHours: {
    episodic: number;    // default 168 (1 week)
    semantic: number;    // default 720 (30 days)
    procedural: number;  // default 2160 (90 days)
  };
  edgeHalfLifeHours: number;  // default 720
  pruneThreshold: number;      // default 0.05
  pruneGraceHours: number;     // default 48 (memories), 72 (edges)
}

export interface ReinforcementConfig {
  baseBoost: number;              // default 0.15
  emotionalResonanceMaxBonus: number; // default 0.5
  edgeBoostMultiplier: number;    // default 0.1
  coRecallBaseBoost: number;      // default 0.05
  denforcePenalty: number;        // default 0.2
  edgeDenforcePenalty: number;    // default 0.15
}

/**
 * Compute decayed weight for a memory.
 * w(t) = w_0 * e^(-lambda * t)
 */
export function computeDecayedWeight(
  currentWeight: number,
  hoursSinceReinforcement: number,
  halfLifeHours: number
): number {
  const lambda = Math.LN2 / halfLifeHours;
  return currentWeight * Math.exp(-lambda * hoursSinceReinforcement);
}

/**
 * Compute reinforcement boost for a successfully recalled memory.
 * new_weight = min(1.0, current + base_boost * (1 + resonance_bonus))
 */
export function computeReinforcedWeight(
  currentWeight: number,
  emotionalResonance: number,
  config: ReinforcementConfig
): number {
  const resonanceBonus = emotionalResonance * config.emotionalResonanceMaxBonus;
  const boost = config.baseBoost * (1 + resonanceBonus);
  return Math.min(1.0, currentWeight + boost);
}

/**
 * Compute edge reinforcement after successful recall traversal.
 * new_weight = min(1.0, current + multiplier * relevance_score)
 */
export function computeEdgeReinforcement(
  currentWeight: number,
  recallRelevanceScore: number,
  config: ReinforcementConfig
): number {
  const boost = config.edgeBoostMultiplier * recallRelevanceScore;
  return Math.min(1.0, currentWeight + boost);
}

/**
 * Compute Hebbian co-activation boost.
 * When two memories are recalled in the same session:
 * boost = base * min(relevance_a, relevance_b)
 */
export function computeHebbianBoost(
  relevanceA: number,
  relevanceB: number,
  config: ReinforcementConfig
): number {
  return config.coRecallBaseBoost * Math.min(relevanceA, relevanceB);
}

/**
 * Apply denforcement penalty.
 */
export function computeDenforcedWeight(
  currentWeight: number,
  penalty: number
): number {
  return Math.max(0.0, currentWeight - penalty);
}

/**
 * Check if a memory/edge is a pruning candidate.
 */
export function isPruneCandidate(
  decayWeight: number,
  hoursBelowThreshold: number,
  config: DecayConfig
): boolean {
  return decayWeight < config.pruneThreshold && hoursBelowThreshold > config.pruneGraceHours;
}
```

---

## 9. Testing Strategy

### Unit Tests

Each agent in isolation. Mock the event bus and storage layer.

```
packages/agents/src/__tests__/
  monitor.test.ts          # Emotional state transitions
  archivist.test.ts        # Enrichment, embedding generation
  guardian.test.ts          # Contradiction detection, schema validation
  weaver.test.ts           # Edge creation logic, similarity thresholds
  curator.test.ts          # Decay sweep, pruning decisions
  dreamer.test.ts          # Consolidation clustering
  sentinel.test.ts         # Access control, compartment filtering
  recall-agent.test.ts     # Both retrieval modes, winnowing
```

### Core Library Tests

```
packages/core/src/__tests__/
  emotional-model.test.ts  # Resonance, distance, bucketing, hormone updates
  weight-dynamics.test.ts  # Decay, reinforcement, Hebbian, pruning
  schemas.test.ts          # Zod schema validation edge cases
```

### Integration Tests

Multi-agent flows with real (local) storage backends:

```
packages/agents/src/__tests__/integration/
  formation-pipeline.test.ts  # Observation -> Enrichment -> Validation -> Storage -> Association
  recall-pipeline.test.ts     # Query -> Sentinel -> Recall -> Reinforce
  lifecycle.test.ts           # Decay -> Curator sweep -> Dreamer consolidation -> Re-store
```

### Eval Pipeline

The `packages/eval` package runs structured scenarios:

1. **Ingest** a known corpus of memories with pre-defined emotional metadata.
2. **Query** with known-good recall requests.
3. **Measure** Precision@K, Recall@K, MRR against expected results.
4. **Report** metrics as JSON for tracking over time.

Key eval scenarios:
- **Emotional recall:** Ingest 50 memories across emotional spectrum. Query in a specific mood. Verify emotionally resonant memories rank higher.
- **Graph traversal:** Ingest a chain of causally linked memories. Query the first. Verify the chain is traversed.
- **Tangential accuracy:** Ingest 100 memories. Simulate conversation turns. Verify tangential insertion surfaces only strongly resonant memories (precision > 0.8).
- **Decay correctness:** Fast-forward time. Verify decayed memories are deprioritized. Verify pruned memories are excluded.

---

## 10. Deployment

### Helm Chart Structure (Two-Tier Pattern)

Following the incubator convention (see parent repo CLAUDE.md):

**Publishable chart** — `repos/incubator/helm/therobotremembers/`

```
therobotremembers/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml         # API + agent runtime
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml          # All tunables from .env
│   ├── hpa.yaml                # Horizontal pod autoscaler
│   └── _helpers.tpl
```

**Wrapper chart** — `helm/apps/therobotremembers/`

```
therobotremembers/
├── Chart.yaml                  # Declares OCI dependency
├── values.yaml                 # Environment-specific overrides
└── preapply/
    └── infisical-secret.yaml   # InfisicalSecret CRD for API keys
```

### ConfigMap Tunables

All weight dynamics and retrieval parameters exposed as environment variables, mapped from a ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: therobotremembers-config
data:
  # Decay
  MEMORY_DECAY_HALF_LIFE_EPISODIC: "168"
  MEMORY_DECAY_HALF_LIFE_SEMANTIC: "720"
  MEMORY_DECAY_HALF_LIFE_PROCEDURAL: "2160"
  EDGE_DECAY_HALF_LIFE_HOURS: "720"

  # Reinforcement
  MEMORY_REINFORCE_BASE_BOOST: "0.15"
  MEMORY_REINFORCE_RESONANCE_MAX_BONUS: "0.5"
  EDGE_REINFORCE_BASE_BOOST: "0.1"
  EDGE_CORECALL_BASE_BOOST: "0.05"
  MEMORY_DENFORCE_PENALTY: "0.2"
  EDGE_DENFORCE_PENALTY: "0.15"

  # Pruning
  MEMORY_PRUNE_THRESHOLD: "0.05"
  MEMORY_PRUNE_GRACE_HOURS: "48"
  EDGE_PRUNE_THRESHOLD: "0.05"
  EDGE_PRUNE_GRACE_HOURS: "72"

  # Retrieval
  TANGENTIAL_THRESHOLD: "0.75"
  HOT_INDEX_REFRESH_TURNS: "5"
  HOT_INDEX_BUCKET_SIZE: "100"
  ACTIVE_RECALL_MAX_CANDIDATES: "50"
  ACTIVE_RECALL_MAX_DEPTH: "3"
  ACTIVE_RECALL_MIN_EDGE_WEIGHT: "0.2"

  # Embedding
  EMBEDDING_MODEL: "text-embedding-3-small"
  EMBEDDING_DIMENSIONS: "1536"
```

### Secrets (via Infisical)

Managed through InfisicalSecret CRD, synced to K8s Secret:

- `ANTHROPIC_API_KEY` — For agent LLM calls (emotional assessment, contradiction detection, consolidation)
- `OPENAI_API_KEY` — For embedding generation
- `DATABASE_URL` — PostgreSQL connection string
- `WEAVIATE_API_KEY` — Weaviate authentication (if enabled)
- `REDIS_URL` — Redis connection string

### Resource Recommendations

| Component | CPU Request | Memory Request | Notes |
|-----------|------------|---------------|-------|
| API + Agents | 500m | 512Mi | Single pod for Phase 0-2; split API/agents in Phase 3+ |
| PostgreSQL | 500m | 1Gi | Shared instance from cluster (shared-postgres) |
| Weaviate | 1000m | 2Gi | Dedicated instance, memory-bound for vector index |
| Redis | 100m | 256Mi | Hot index is small — ~100 memories * 36 buckets |

---

## Appendix: Quick Reference

### Event Types

| Event | Producer | Consumer(s) |
|-------|----------|-------------|
| `conversation.turn` | External | Monitor |
| `memory.observed` | Monitor | Archivist |
| `memory.enriched` | Archivist | Guardian |
| `memory.validated` | Guardian | Archivist |
| `memory.rejected` | Guardian | Archivist |
| `memory.quarantined` | Guardian | Admin |
| `memory.stored` | Archivist | Weaver, Curator |
| `association.created` | Weaver | Graph store |
| `association.proposed` | Dreamer | Weaver |
| `memory.decaying` | Curator | Dreamer |
| `memory.consolidated` | Dreamer | Archivist |
| `memory.archived` | Curator | Storage |
| `memory.pruned` | Curator | Storage |
| `recall.requested` | External | Recall Agent |
| `recall.completed` | Recall Agent | External |
| `memory.reinforced` | Recall Agent | Archivist |
| `memory.denforced` | External | Archivist |
| `emotional_state.updated` | Monitor | Hot index worker |
| `integrity.alert` | Guardian | Monitor |

### Agent Emotional Baselines

| Agent | Valence | Arousal | Dominance | Key Hormone | Disposition |
|-------|---------|---------|-----------|-------------|-------------|
| Monitor | 0.0 | 0.3 | 0.5 | Cortisol 0.3 | Neutral observer, slightly vigilant |
| Archivist | 0.2 | 0.5 | 0.6 | Dopamine 0.5 | Eager to capture, reward-seeking |
| Guardian | -0.1 | 0.6 | 0.7 | Cortisol 0.6 | Suspicious, high-alert, authoritative |
| Weaver | 0.3 | 0.4 | 0.5 | Dopamine 0.4 | Curious, pattern-seeking |
| Curator | 0.0 | 0.3 | 0.8 | Serotonin 0.6 | Methodical, in-control, stability-seeking |
| Dreamer | 0.4 | 0.2 | 0.3 | Dopamine 0.7 | Speculative, relaxed, reward-driven |
| Sentinel | -0.2 | 0.5 | 0.8 | Cortisol 0.5 | Guarded, authoritative, wary |
| Recall Agent | 0.1 | 0.6 | 0.6 | Dopamine 0.4 | Focused, active, performance-oriented |
