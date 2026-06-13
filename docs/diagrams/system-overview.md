# System Overview Diagrams

Architectural views of The Robot Remembers — from external boundaries down to agent-level interaction patterns.

---

## 1. System Context Diagram

The memory service viewed from the outside: who talks to it, what they ask for, and what sits underneath.

```mermaid
graph TB
    subgraph "External Consumers"
        CA["Client Agents<br/><i>LLM-powered agents requesting<br/>recall and submitting memories</i>"]
        OP["Human Operator<br/><i>Dashboard user: monitoring agents,<br/>resolving quarantine, tuning weights</i>"]
        DEV["Developer API Consumer<br/><i>Programmatic access: batch ingest,<br/>recall queries, admin operations</i>"]
    end

    subgraph "therobotremembers" 
        direction TB
        API["Memory API<br/><i>Phoenix/Elixir — REST + WebSocket</i>"]
        ORCH["Agent Orchestrator<br/><i>OTP Supervisor tree running<br/>all 8 synthetic agents</i>"]
        DREAM["Dreamer Worker<br/><i>Background consolidation<br/>CronJob — off-peak synthesis</i>"]
    end

    subgraph "Storage Layer"
        WV[("Weaviate<br/><i>Vector embeddings<br/>Semantic search</i>")]
        PG[("PostgreSQL<br/><i>Metadata, graph,<br/>lifecycle, audit</i>")]
        RD[("Redis<br/><i>Hot index, agent state,<br/>event bus, rate limits</i>")]
    end

    subgraph "External Services"
        LLM["LLM Provider<br/><i>Embedding generation<br/>(OpenAI / local vLLM)</i>"]
        CF["Cloudflare<br/><i>TLS termination,<br/>origin pull</i>"]
        INF["Infisical<br/><i>Secrets management</i>"]
    end

    CA -->|"POST /recall<br/>POST /memories<br/>WS /stream"| API
    OP -->|"Dashboard UI<br/>(Next.js via Ingress)"| API
    DEV -->|"REST API<br/>batch + admin"| API

    API <--> ORCH
    ORCH <--> DREAM

    ORCH --> WV
    ORCH --> PG
    ORCH --> RD
    DREAM --> PG
    DREAM --> WV

    ORCH --> LLM
    CF --> API
    INF -.->|"K8s Secrets sync"| API

    style API fill:#4a90d9,color:#fff
    style ORCH fill:#4a90d9,color:#fff
    style DREAM fill:#6b7b8d,color:#fff
    style WV fill:#e8a838,color:#000
    style PG fill:#336791,color:#fff
    style RD fill:#dc382d,color:#fff
```

**Key boundaries:**

- **Client agents** interact exclusively through the API layer — they never touch storage directly. They submit memories via REST and receive recall results either synchronously (active recall) or via WebSocket (tangential insertion stream).
- **The operator dashboard** is a Next.js frontend served through Cloudflare-proxied Ingress, hitting the same API with elevated admin permissions.
- **The Dreamer Worker** runs as a separate K8s CronJob to avoid competing with real-time agent processing for resources. It reads from and writes to the same storage layer.

---

## 2. Agent Ensemble Diagram

All eight agents and their communication topology. Arrows indicate the primary direction of data/event flow; labels describe what travels along each edge.

```mermaid
graph TB
    MON["<b>Monitor</b><br/>Observation<br/><i>Nervous system</i>"]
    ARC["<b>Archivist</b><br/>Formation<br/><i>Sensory cortex</i>"]
    GUA["<b>Guardian</b><br/>Integrity<br/><i>Immune system</i>"]
    WEA["<b>Weaver</b><br/>Association<br/><i>Hippocampus</i>"]
    CUR["<b>Curator</b><br/>Lifecycle<br/><i>Prefrontal cortex</i>"]
    DRE["<b>Dreamer</b><br/>Synthesis<br/><i>Default mode network</i>"]
    SEN["<b>Sentinel</b><br/>Access Control<br/><i>Blood-brain barrier</i>"]
    REC["<b>Recall Agent</b><br/>Retrieval<br/><i>Conscious recall</i>"]

    %% Formation pipeline
    MON -->|"emotional state<br/>snapshot"| ARC
    ARC -->|"memory candidate"| GUA
    GUA -->|"approved memory"| ARC
    GUA -->|"quarantine alert"| MON
    ARC -->|"memory.stored event"| WEA

    %% Association and synthesis
    WEA -->|"association map<br/>+ graph updates"| DRE
    DRE -->|"consolidated memories<br/>+ speculative links"| ARC
    DRE -->|"association.proposed"| WEA

    %% Lifecycle
    CUR -->|"prune/archive<br/>decisions"| ARC
    CUR -->|"decaying candidates"| DRE
    CUR <-->|"edge weight<br/>queries"| WEA

    %% Retrieval
    REC -->|"access check<br/>+ requester ID"| SEN
    SEN -->|"authorized query<br/>+ redaction rules"| REC
    REC -->|"graph traversal<br/>request"| WEA
    REC -->|"reinforcement<br/>signals"| ARC

    %% Monitor broadcasts
    MON -.->|"state broadcast"| CUR
    MON -.->|"state broadcast"| REC
    MON -.->|"state broadcast"| DRE

    style MON fill:#7cb342,color:#fff
    style ARC fill:#5c6bc0,color:#fff
    style GUA fill:#ef5350,color:#fff
    style WEA fill:#ab47bc,color:#fff
    style CUR fill:#ff7043,color:#fff
    style DRE fill:#26c6da,color:#000
    style SEN fill:#78909c,color:#fff
    style REC fill:#ffa726,color:#000
```

**Communication patterns:**

| Pattern | Agents | Description |
|---------|--------|-------------|
| **Formation pipeline** | Monitor -> Archivist -> Guardian -> Archivist -> Weaver | Linear flow for new memory ingestion |
| **Synthesis loop** | Curator -> Dreamer -> Archivist -> Weaver -> Dreamer | Cyclical: decay triggers consolidation, which creates new memories, which get re-associated |
| **Retrieval fan-out** | Recall Agent -> Sentinel + Weaver (parallel) | Recall checks access while simultaneously preparing graph traversal |
| **State broadcast** | Monitor -> all agents (pub/sub) | Monitor publishes emotional state changes; agents subscribe as needed |
| **Reinforcement feedback** | Recall Agent -> Archivist | Successful recall feeds back to strengthen memory weights |

---

## 3. Agent Tension Map

Not all agent relationships are cooperative. The system's intelligence emerges from productive friction between agents with competing priorities. Green edges are collaborative; red edges are adversarial (healthy tension); orange edges are conditional.

```mermaid
graph LR
    MON["Monitor"]
    ARC["Archivist"]
    GUA["Guardian"]
    WEA["Weaver"]
    CUR["Curator"]
    DRE["Dreamer"]
    SEN["Sentinel"]
    REC["Recall Agent"]

    %% Collaborative (green)
    MON ---|"collaborative:<br/>state feeds formation"| ARC
    ARC ---|"collaborative:<br/>validated memories"| GUA
    ARC ---|"collaborative:<br/>stored -> linked"| WEA
    REC ---|"collaborative:<br/>reinforcement"| ARC
    REC ---|"collaborative:<br/>graph queries"| WEA

    %% Adversarial tension (red)
    CUR -.-|"TENSION:<br/>prune vs preserve"| WEA
    GUA -.-|"TENSION:<br/>safe vs speculative"| DRE
    SEN -.-|"TENSION:<br/>security vs completeness"| REC
    GUA -.-|"TENSION:<br/>strict vs permissive"| ARC

    %% Conditional (orange)
    DRE -.->|"conditional:<br/>proposals need validation"| WEA
    CUR -.->|"conditional:<br/>defer if consolidating"| DRE

    linkStyle 0 stroke:#4caf50,stroke-width:2px
    linkStyle 1 stroke:#4caf50,stroke-width:2px
    linkStyle 2 stroke:#4caf50,stroke-width:2px
    linkStyle 3 stroke:#4caf50,stroke-width:2px
    linkStyle 4 stroke:#4caf50,stroke-width:2px
    linkStyle 5 stroke:#f44336,stroke-width:3px
    linkStyle 6 stroke:#f44336,stroke-width:3px
    linkStyle 7 stroke:#f44336,stroke-width:3px
    linkStyle 8 stroke:#f44336,stroke-width:3px
    linkStyle 9 stroke:#ff9800,stroke-width:2px
    linkStyle 10 stroke:#ff9800,stroke-width:2px
```

### Tension Details

| Tension | Agents | What They Disagree About | Resolution Mechanism |
|---------|--------|--------------------------|---------------------|
| **Prune vs Preserve** | Curator vs Weaver | Curator wants to prune low-weight memories to save storage. Weaver argues a memory with weak recall weight may still be structurally important (high-weight edges to active memories). | Curator checks edge weights before pruning. If any outgoing edge exceeds `structural_importance_threshold` (default 0.6), pruning is deferred. |
| **Safe vs Speculative** | Guardian vs Dreamer | Dreamer generates speculative associations and synthetic merged memories. Guardian flags these as potential contradictions or unvalidated data. | Dreamer marks all output with `speculative: true`. Guardian applies a relaxed validation pass for speculative content — schema compliance required, contradiction check uses a higher similarity threshold. |
| **Security vs Completeness** | Sentinel vs Recall Agent | Sentinel restricts cross-compartment access, which can cause the Recall Agent to miss relevant memories that exist in sealed compartments. | Sentinel provides "shadow hits" — a count of redacted results so the Recall Agent (and the user) knows memories exist but are inaccessible. The operator can then grant temporary access if warranted. |
| **Strict vs Permissive** | Guardian vs Archivist | Under high load, the Archivist wants to batch-store rapidly with minimal validation. The Guardian insists on full contradiction checking, which is slower. | Configurable `validation_mode`: `full` (default), `schema_only` (skip contradiction check under load), `deferred` (store now, validate async). The operator sets the mode based on trust level of the input source. |
