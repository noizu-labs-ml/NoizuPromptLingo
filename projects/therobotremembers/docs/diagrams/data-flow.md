# Data Flow Diagrams

Detailed sequence and state diagrams for every major data path through The Robot Remembers.

---

## 1. Memory Formation Flow

The complete journey of a new memory from raw conversation event to stored, associated node in the memory graph. This is the "write path" — the most common operation in the system.

```mermaid
sequenceDiagram
    participant EXT as External Event
    participant MON as Monitor
    participant ARC as Archivist
    participant LLM as LLM Provider
    participant GUA as Guardian
    participant WV as Weaviate
    participant PG as PostgreSQL
    participant WEA as Weaver
    participant RD as Redis

    Note over EXT,RD: Phase 1 — Observation & Enrichment

    EXT->>MON: Conversation turn / system event
    MON->>MON: Update emotional state vector<br/>(valence, arousal, dominance, hormones)
    MON->>RD: Publish agent_state:{monitor} update
    MON->>ARC: emotional_state snapshot + event payload

    ARC->>ARC: Salience check: is this memory-worthy?
    Note right of ARC: Heuristics: novelty, emotional<br/>intensity, explicit instruction,<br/>task milestone, contradiction signal

    alt Not salient
        ARC-->>ARC: Discard (no storage)
    else Salient
        ARC->>LLM: Generate embedding (content text)
        LLM-->>ARC: vector[1536]
        ARC->>ARC: Attach emotional metadata from Monitor
        ARC->>ARC: Attach contextual metadata<br/>(timestamp, session, collaborators, domain)
        ARC->>ARC: Generate compressed summary
        ARC->>ARC: Classify content_type<br/>(episodic / semantic / procedural)

        Note over ARC,GUA: Phase 2 — Validation

        ARC->>GUA: MemoryEntry candidate (full payload)
        GUA->>GUA: Schema compliance check
        GUA->>WV: Semantic similarity search<br/>(embedding, top-5, threshold 0.92)
        WV-->>GUA: Similar existing memories
        GUA->>GUA: Contradiction analysis<br/>(compare claims against existing)
        GUA->>GUA: Injection/poisoning pattern scan

        alt Approved
            GUA-->>ARC: APPROVED

            Note over ARC,WEA: Phase 3 — Storage & Association

            par Store to vector DB
                ARC->>WV: Upsert: embedding + content + summary
            and Store to relational DB
                ARC->>PG: INSERT memory_entries +<br/>emotional_metadata + contextual_metadata
            end

            ARC->>RD: Publish memory.stored event
            RD->>WEA: memory.stored event

            WEA->>WV: Find semantically similar memories<br/>(top-10, threshold 0.7)
            WV-->>WEA: Candidate neighbors (by content)
            WEA->>PG: Find emotionally similar memories<br/>(cosine on 7-dim emotional vector)
            PG-->>WEA: Candidate neighbors (by emotion)
            WEA->>PG: Find temporally proximate memories<br/>(within session, same day)
            PG-->>WEA: Candidate neighbors (by time)

            WEA->>WEA: Compute initial edge weights<br/>(per dimension similarity scores)
            WEA->>PG: INSERT association_edges<br/>(batch, multiple edge_types)

            WEA->>RD: Update hot index if new memory<br/>scores above tangential threshold

        else Quarantined
            GUA->>PG: INSERT quarantine_buffer<br/>(reason, flagged_by)
            GUA->>RD: Publish integrity.alert
            RD->>MON: integrity.alert event
        end
    end
```

**Key design decisions in this flow:**

- **Salience filtering** happens early (at the Archivist) to avoid wasting embedding API calls on trivial events. Heuristics are tunable: emotional intensity threshold, novelty score vs. existing memories, explicit "remember this" signals.
- **Contradiction checking** uses a high similarity threshold (0.92) — it is looking for near-duplicates with conflicting claims, not loosely related content.
- **Storage is parallel** — the Weaviate and PostgreSQL writes happen concurrently. The memory ID is pre-generated (UUID) so both stores reference the same key.
- **Association creation is asynchronous** — the Weaver receives a pub/sub event and processes it independently. The formation pipeline does not block on association building.

---

## 2. Active Recall Flow

Explicit, deliberate retrieval: the agent or operator asks "What do I know about X?" This is the deep search path with a 2-second latency budget.

```mermaid
sequenceDiagram
    participant REQ as Recall Request
    participant SEN as Sentinel
    participant REC as Recall Agent
    participant MON as Monitor
    participant WV as Weaviate
    participant PG as PostgreSQL
    participant RD as Redis
    participant LLM as LLM Provider
    participant CW as Context Window

    Note over REQ,CW: Phase 1 — Authorization & Context

    REQ->>SEN: Recall query + requester identity +<br/>compartment scope
    SEN->>PG: Lookup requester permissions +<br/>compartment policies
    PG-->>SEN: Access grants + redaction rules
    SEN-->>REC: Authorized query envelope<br/>(allowed compartments, redaction map)

    REC->>RD: GET agent_state:{monitor}
    RD-->>REC: Current emotional state vector

    Note over REC,PG: Phase 2 — Multi-Path Retrieval (parallel)

    par Vector Search
        REC->>LLM: Embed query text
        LLM-->>REC: query_vector[1536]
        REC->>WV: ANN search (query_vector,<br/>top-50, compartment filter)
        WV-->>REC: Vector candidates (id, score, content)
    and Attribute Filter
        REC->>PG: Query emotional_metadata +<br/>contextual_metadata<br/>(domain, time_of_day, collaborators,<br/>emotional similarity to current state)
        PG-->>REC: Attribute candidates (id, metadata)
    and Graph Traversal
        REC->>PG: Recursive CTE from seed memories<br/>(top-10 vector hits as seeds,<br/>max_depth=3, min_weight=0.2)
        PG-->>REC: Graph candidates (id, path, edge_weights)
    end

    Note over REC,CW: Phase 3 — Scoring & Winnowing

    REC->>REC: Merge candidate sets<br/>(union with dedup by memory_id)
    REC->>REC: Score each candidate:<br/>  content_relevance (0.4 weight)<br/>  + emotional_resonance (0.3 weight)<br/>  + recency_boost (0.1 weight)<br/>  + association_strength (0.2 weight)
    REC->>REC: Apply redaction rules from Sentinel<br/>(remove sealed, redact restricted)
    REC->>REC: Winnow to top 10-20<br/>(token budget: 2000 tokens max)
    REC->>REC: Format: full content for top-5,<br/>summaries for remainder,<br/>association hints per memory

    Note over REC,CW: Phase 4 — Injection & Reinforcement

    REC->>CW: Inject structured memory block<br/>(XML format with metadata attributes)

    par Reinforce recalled memories
        REC->>PG: UPDATE memory_entries<br/>SET decay_weight += boost,<br/>recall_count += 1,<br/>last_recalled_at = NOW()<br/>WHERE id IN (recalled_ids)
    and Reinforce traversed edges
        REC->>PG: UPDATE association_edges<br/>SET weight += edge_boost,<br/>reinforcement_count += 1<br/>WHERE id IN (traversed_edge_ids)
    and Hebbian co-recall
        REC->>PG: UPSERT association_edges<br/>for co-recalled memory pairs<br/>(edge_type = 'co-occurrence')
    and Audit log
        REC->>PG: INSERT recall_log<br/>(query, mode='active', results,<br/>latency_ms, requester)
    end
```

**Scoring formula detail:**

```
final_score = (0.4 * content_relevance)
            + (0.3 * emotional_resonance)
            + (0.1 * recency_boost)
            + (0.2 * association_strength)

where:
  content_relevance  = normalized vector similarity (0-1)
  emotional_resonance = 1 - (cosine_distance(current_emotion, memory_emotion) / 2)
  recency_boost      = e^(-hours_since_last_recall / 168)
  association_strength = max edge weight on any path from a seed memory to this candidate
```

---

## 3. Tangential Insertion Flow

Passive, serendipitous recall: memories surface unbidden during conversation when emotional/contextual resonance exceeds a threshold. This is the "background hum" of the memory system — the equivalent of a song triggering a childhood memory.

```mermaid
sequenceDiagram
    participant CS as Conversation Stream
    participant RD as Redis
    participant RES as Resonance Detector
    participant REC as Recall Agent
    participant SEN as Sentinel
    participant CW as Context Window

    Note over CS,CW: Continuous loop — runs on every conversational turn

    CS->>RES: Current turn text +<br/>emotional state snapshot

    RES->>RD: GET tangential:rate:{session_id}
    RD-->>RES: Current insertion count this window

    alt Rate limit exceeded (>3 per 10 turns)
        RES-->>RES: Skip — too many recent insertions
    else Under rate limit
        RES->>RES: Extract emotional signature<br/>from current turn
        RES->>RES: Compute emotional bucket key<br/>(quantized valence + arousal)

        RES->>RD: ZRANGEBYSCORE hot:{emotional_bucket}<br/>min=threshold, LIMIT 5
        RD-->>RES: Hot index hits<br/>(memory_id, resonance_score)

        alt No hits above threshold
            RES-->>RES: No insertion — nothing resonates
        else Hits found
            RES->>RES: Quick relevance check:<br/>does turn context match<br/>any hit's domain/collaborators?

            RES->>SEN: Access check (requester, memory_ids)
            SEN-->>RES: Allowed memory IDs

            RES->>RES: Select top 1-3 memories<br/>(highest resonance, access-cleared)

            RES->>CW: Inject subtle parenthetical:<br/>"(This reminds me of when...)"

            Note over RES,RD: Lightweight reinforcement

            RES->>RD: INCR tangential:rate:{session_id}
            RES->>RD: ZINCRBY hot:{emotional_bucket}<br/>member=memory_id, increment=0.05

            RES-->>REC: Async: weak reinforcement signal<br/>(memory_ids, boost=0.05)
        end
    end
```

**Performance constraints (< 100ms budget):**

| Operation | Budget | Notes |
|-----------|--------|-------|
| Rate limit check | < 1ms | Single Redis GET |
| Emotional bucket lookup | < 5ms | Redis sorted set range query |
| Access check | < 10ms | Sentinel uses cached compartment policies in Redis |
| Context relevance filter | < 5ms | In-memory string matching, no DB call |
| Total | < 25ms | Leaves 75ms headroom for network variance |

The key insight: tangential insertion **never touches Weaviate or PostgreSQL**. It operates entirely from the pre-computed hot index in Redis. This is what makes sub-100ms possible.

---

## 4. Memory Lifecycle Flow

A state machine showing every phase a memory can pass through, with the responsible agent at each transition and the conditions that trigger state changes.

```mermaid
stateDiagram-v2
    [*] --> Observed: Event detected by Monitor

    Observed --> Enriched: Archivist attaches<br/>emotional + contextual metadata

    Enriched --> Validated: Guardian schema +<br/>contradiction check

    Validated --> Quarantined: Fails validation<br/>(contradiction, injection pattern)
    Validated --> Stored: Passes validation

    Quarantined --> Stored: Operator approves<br/>(POST /admin/quarantine/:id/approve)
    Quarantined --> Pruned: Operator rejects<br/>(POST /admin/quarantine/:id/reject)
    Quarantined --> Pruned: Auto-reject after<br/>configurable TTL (default 72h)

    Stored --> Associated: Weaver creates<br/>initial edges

    Associated --> Active: Edges established,<br/>decay clock starts

    state Active {
        [*] --> Healthy
        Healthy --> Recalled: Recall Agent retrieves
        Recalled --> Reinforced: decay_weight boosted
        Reinforced --> Healthy: Returns to baseline<br/>with higher weight
    }

    Active --> Decaying: decay_weight drops<br/>below decay_threshold<br/>(default 0.3)

    Decaying --> Active: Recalled before<br/>pruning grace period

    Decaying --> Consolidating: Dreamer identifies<br/>pattern cluster

    Consolidating --> Active: Merged into stronger<br/>composite memory<br/>(new ID, source IDs recorded)

    Decaying --> Fading: decay_weight drops<br/>below 0.1

    Fading --> Pruned: Grace period expires<br/>(48h) + no high-weight<br/>outgoing edges

    Fading --> Decaying: Curator defers:<br/>structurally important<br/>(edge weight > 0.6)

    Active --> Archived: Curator lifecycle sweep<br/>(age > retention_period,<br/>recall_count < threshold)

    Archived --> Active: Recalled from archive<br/>(weight reset to 0.5)

    Pruned --> [*]: Soft-deleted<br/>(tombstone retained)

    note right of Active
        Decay function runs continuously:
        weight(t) = w0 * e^(-lambda * t)

        Half-lives:
        - episodic: 168h (1 week)
        - semantic: 720h (30 days)
        - procedural: 2160h (90 days)
    end note

    note right of Consolidating
        Dreamer merges 2+ related
        weak memories into 1 strong one.
        Original IDs stored in
        consolidation_ids[].
    end note
```

### Lifecycle Phase Summary

| Phase | Agent | Entry Condition | Exit Conditions | Duration |
|-------|-------|----------------|-----------------|----------|
| Observed | Monitor | Event detected | Archivist picks up | Milliseconds |
| Enriched | Archivist | Salience threshold met | Guardian validation | < 500ms |
| Validated | Guardian | Schema + contradiction check | Approved or quarantined | < 1s |
| Quarantined | Guardian | Failed validation | Operator resolves or TTL expires | Hours to days |
| Stored | Archivist | Validation passed | Weaver processes | < 100ms |
| Associated | Weaver | Edges created | Fully linked | < 2s |
| Active | -- | Edges established | Decay threshold crossed | Hours to months |
| Decaying | Curator | `decay_weight < 0.3` | Recalled, consolidated, or fades further | Hours to days |
| Fading | Curator | `decay_weight < 0.1` | Pruned or deferred | 48h grace period |
| Consolidating | Dreamer | Pattern cluster identified | New composite memory created | Background batch |
| Archived | Curator | Age + low recall count | Recalled from archive | Indefinite |
| Pruned | Curator | Grace period + no structural importance | Tombstone | Terminal |

---

## 5. Hot Index Refresh Flow

The hot index is the backbone of tangential insertion performance. It must stay fresh enough to reflect the agent's current emotional state without being so aggressive that it saturates Redis or Weaviate with queries.

```mermaid
sequenceDiagram
    participant MON as Monitor
    participant RD as Redis
    participant BG as Background Prefetcher
    participant WV as Weaviate
    participant PG as PostgreSQL

    Note over MON,PG: Trigger: emotional state change exceeds drift threshold

    MON->>MON: Compute emotional state delta<br/>vs last broadcast
    MON->>MON: Check drift threshold:<br/>cosine_distance(prev, current) > 0.15?

    alt Drift below threshold
        MON-->>MON: No refresh needed
    else Significant drift
        MON->>RD: SET agent_state:{monitor}<br/>(new emotional vector)
        MON->>RD: PUBLISH channel:emotional_drift<br/>(new state + delta magnitude)

        RD->>BG: Emotional drift notification

        Note over BG,PG: Rebuild hot index for new emotional state

        BG->>BG: Compute emotional bucket keys<br/>for current state (primary + adjacent buckets)

        par Vector search for emotional neighbors
            BG->>WV: ANN search using emotional vector<br/>as query (top-100)
            WV-->>BG: Candidate memories by embedding proximity
        and Attribute search for emotional matches
            BG->>PG: SELECT memory_id, emotional_metadata<br/>WHERE lifecycle_state = 'active'<br/>ORDER BY emotional_cosine_similarity<br/>LIMIT 100
            PG-->>BG: Candidate memories by metadata match
        end

        BG->>BG: Merge candidates, compute<br/>resonance score for each:<br/>emotional_similarity * decay_weight * recency

        BG->>RD: Pipeline (atomic):
        Note over BG,RD: DEL hot:{bucket} for stale buckets<br/>ZADD hot:{bucket} score member<br/>for each candidate<br/>EXPIRE hot:{bucket} 600s

        BG->>RD: SET hot:last_refresh:{session}<br/>(timestamp + state hash)
    end

    Note over MON,PG: Also triggers on: every N turns (default 5),<br/>session start, explicit refresh request
```

**Refresh triggers (any of these):**

1. **Emotional drift** — cosine distance between current and last-broadcast state exceeds 0.15
2. **Turn interval** — every 5 conversational turns regardless of drift (catch gradual shifts)
3. **Session start** — always refresh at the beginning of a new conversation
4. **Explicit request** — operator or agent can force a refresh via admin API

**Hot index structure in Redis:**

```
Key: hot:{quantized_valence}:{quantized_arousal}
Type: Sorted Set
Members: memory_id (UUID)
Scores: resonance_score (float, 0.0-1.0)
TTL: 600 seconds (auto-expire if not refreshed)

Adjacent buckets: +/- 1 on each quantized axis
  e.g., if current state maps to hot:neg:high,
  also populate hot:neg:med and hot:neutral:high
```

This adjacency ensures that tangential insertion can find memories even when the emotional state is on a bucket boundary, avoiding sharp cutoff artifacts.
