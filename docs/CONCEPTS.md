# Concepts: The Robot Remembers

A glossary of core concepts, ordered from foundational to composite. Each entry defines the concept, its role in the system, and where it intersects with other concepts.

---

## Memory Entry

The atomic unit of the system. A Memory Entry is a single stored observation, fact, or experience, enriched with emotional and contextual metadata. Every memory is a node in the association graph.

A Memory Entry contains:
- **Content** — The natural language text of what was observed or learned
- **Embedding** — A dense vector representation of the content, used for semantic similarity search
- **Emotional metadata** — The affective state of the agent at the moment the memory was formed
- **Contextual metadata** — Temporal, environmental, and situational data from the formation moment
- **Lifecycle state** — Current phase (active, decaying, archived, quarantined, pruned) and decay weight
- **Compartment** — Access control partition

Memory Entries are typed as **episodic** (a specific event — "we debugged the deadlock on Tuesday"), **semantic** (a general fact — "Postgres advisory locks can cause deadlocks across transactions"), or **procedural** (a how-to — "to fix migration deadlocks, use sequential runner with lock timeout").

**Lifecycle:** Observed → Enriched → Validated → Stored → Associated → Active → Decaying → Consolidated or Pruned

**See also:** Emotional Metadata, Contextual Metadata, Decay Curve, Association Path

---

## Emotional Metadata

The affective signature of a memory — the emotional state of the agent at the moment the memory was formed. Emotional metadata is not decoration; it is a retrieval coordinate. Two memories with similar emotional signatures will surface together during recall, even if their content is unrelated.

### Dimensional Model

Three primary axes based on Russell's circumplex model of affect:

| Axis | Range | Low end | High end |
|------|-------|---------|----------|
| **Valence** | -1.0 to 1.0 | Frustrated, angry, sad | Happy, satisfied, excited |
| **Arousal** | 0.0 to 1.0 | Calm, bored, sleepy | Alert, agitated, energized |
| **Dominance** | 0.0 to 1.0 | Helpless, overwhelmed | In control, confident |

### Simulated Hormones

Four simulated hormonal signals provide additional retrieval dimensions. These are not biologically accurate models — they are simplified proxies for states that the three-axis model alone does not capture well.

| Signal | Models | Range |
|--------|--------|-------|
| **Cortisol** | Stress, urgency, alarm | 0.0 (relaxed) to 1.0 (crisis) |
| **Dopamine** | Reward, breakthrough, satisfaction | 0.0 (stuck) to 1.0 (eureka moment) |
| **Oxytocin** | Trust, collaboration, bonding | 0.0 (adversarial) to 1.0 (deep trust) |
| **Serotonin** | Stability, steady-state contentment | 0.0 (everything is broken) to 1.0 (smooth sailing) |

### Frustration Index

A composite signal (0.0 to 1.0) computed from a sliding window of recent interactions. Captures sustained frustration that a single valence reading might miss. Used heavily by the Recall Agent to find "I've been here before" memories.

### Confidence Level

Each emotional metadata block carries a `confidence` flag (high, medium, low) indicating how certain the Archivist was about the emotional readings. Ambiguous interactions default to neutral baselines with `confidence: low`.

**See also:** Emotional Resonance, Memory Entry, Reinforcement

---

## Contextual Metadata

The situational context of a memory — when, where, how, and with whom the memory was formed. Together with emotional metadata, contextual metadata makes memories retrievable by "the shape of the moment" rather than just content.

### Temporal Context
- **UTC timestamp** and **local time** (configured timezone)
- **Time-of-day bucket:** morning, afternoon, evening, night (configurable boundaries)
- **Day of week, season**
- **Holiday proximity:** distance in days to configured observances (e.g., `{ "christmas": 2 }`)

### Session Context
- **Topic/domain:** The active subject area (debugging, design, ops, etc.)
- **Conversation length** at time of capture and **turn number**
- **Active project or repo** if applicable

### Interaction Modality
How the memory arrived: chat, voice, API, api_batch, background task.

### Collaborators
List of agent and user IDs present at the moment of formation. Enables retrieval by "who was involved."

### Environment
Freeform key-value pairs for deployment-specific context (project name, branch, tool in use, etc.).

**See also:** Memory Entry, Association Edge (temporal proximity edge type)

---

## Relational Weight

The strength of an association between two memories. Stored as a float (0.0 to 1.0) on each AssociationEdge. Weights are dynamic — they increase through reinforcement and decrease through decay and denforcement.

Weight determines traversal priority: when the Recall Agent walks the association graph, it follows high-weight edges first and ignores edges below a configurable threshold.

**Weight dynamics:**
- **Initial weight:** Set by the Weaver based on similarity scores at link creation time
- **Reinforcement:** Increases when the linked memories are recalled together (Hebbian learning)
- **Decay:** Decreases over time if the edge is not reinforced
- **Denforcement:** Explicit weight reduction when a link is marked as unhelpful

**See also:** Association Path, Reinforcement, Denforcement, Hebbian-like Learning

---

## Association Path

A traversal route through the association graph connecting two or more memories. The Recall Agent traces association paths to find memories that are not directly similar to the query but are reachable through a chain of related memories.

**Example path:**
```
"Postgres deadlock" (content match)
  → "frustrated debugging at 2 AM" (emotional similarity, weight 0.8)
    → "DNS timeout during midnight deploy" (temporal + emotional, weight 0.6)
      → "lesson: never deploy after midnight" (causal, weight 0.9)
```

The path's total strength is a function of its edge weights. Weak links in the chain reduce the path's overall score. The Recall Agent enforces a minimum edge weight threshold and maximum traversal depth to prevent runaway graph walks.

**See also:** Relational Weight, Winnowing, Recall Agent

---

## Reinforcement

The process of strengthening a memory's decay weight and its associated edges after successful recall. Reinforcement is the mechanism by which useful memories resist decay and become easier to recall over time.

**Triggers:**
- A memory is returned in a recall result and the consuming agent marks it as useful
- A memory participates in a recall path (even if not the primary result)
- An external signal explicitly reinforces a memory via the API

**Effects:**
- Memory's `decay_weight` increases by `base_boost * (1 + emotional_resonance_bonus)`
- Association edges traversed during recall receive a proportional weight boost
- Memory's `recall_count` and `reinforcement_count` increment
- Memory's `last_recalled_at` resets the decay clock

**See also:** Denforcement, Decay Curve, Hebbian-like Learning

---

## Denforcement

The process of weakening a memory's decay weight. Denforcement is the inverse of reinforcement — it reduces a memory's prominence in the association web.

**Triggers:**
- An agent or user explicitly marks a memory as unhelpful, incorrect, or outdated
- The Guardian detects a contradiction and weakens the less-trusted memory
- Administrative action via the API

**Effects:**
- Memory's `decay_weight` decreases by `denforcement_penalty` (default 0.2)
- Memory's `denforcement_count` increments
- If `decay_weight` drops below the pruning threshold, the memory enters the Curator's prune queue

Denforcement is not deletion. A denforced memory can still be reinforced back to health if it proves useful later. Only the Curator's prune process removes memories permanently.

**See also:** Reinforcement, Decay Curve, Pruning

---

## Decay Curve

The mathematical function governing how memories lose strength over time without reinforcement. The system uses exponential decay with a configurable half-life per memory type.

```
decay_weight(t) = initial_weight * e^(-lambda * t)

lambda = ln(2) / half_life
t = hours since last reinforcement
```

### Default Half-Lives

| Memory Type | Half-Life | Rationale |
|-------------|-----------|-----------|
| Episodic | 168 hours (1 week) | Specific events fade quickly without rehearsal |
| Semantic | 720 hours (30 days) | General facts persist longer |
| Procedural | 2160 hours (90 days) | How-to knowledge is the most durable |

The Curator runs periodic sweeps checking `decay_weight` against the **pruning threshold** (default 0.05). Memories below this threshold for longer than the **grace period** (default 48 hours) are candidates for pruning — unless the Dreamer has flagged them for consolidation or they have high-weight edges to active memories.

**See also:** Reinforcement, Pruning, Consolidation

---

## Consolidation

A background synthesis process run by the Dreamer agent. Consolidation identifies clusters of related weak memories and merges them into a single stronger memory, or strengthens a memory by discovering new associations.

**How it works:**
1. The Curator identifies decaying memories approaching the pruning threshold
2. The Dreamer examines these memories and their association neighborhoods
3. If a cluster of related weak memories shares a common theme, the Dreamer synthesizes a composite memory that captures the essence of the cluster
4. The composite memory is submitted to the Archivist for re-enrichment and storage
5. The original weak memories are linked to the composite via `consolidation_ids` and may be pruned

**Example:** Five separate memories about DNS configuration issues over 6 months might consolidate into a single semantic memory: "DNS configuration is a recurring pain point, typically occurring during infrastructure changes, associated with high frustration and late-night debugging sessions."

Consolidation is analogous to memory consolidation during REM sleep — the system processes its experiences and distills patterns.

**See also:** Dreamer, Decay Curve, Pruning, Memory Entry

---

## Winnowing

The process of narrowing a large set of candidate memories to the most relevant subset for context injection. The Recall Agent performs winnowing after the initial retrieval stages (vector search + attribute filtering + graph traversal).

**Winnowing criteria:**
- **Content relevance:** Cosine similarity to the query embedding
- **Emotional resonance:** Similarity between the memory's emotional metadata and the current agent state
- **Recency:** Recently reinforced memories get a small boost
- **Association strength:** Memories with high-weight edges to other candidates score higher
- **Diversity:** Prevent over-representation of a single cluster (include memories from different parts of the graph)
- **Token budget:** The final set must fit within the configured context injection budget

Winnowing is where the system's intelligence is most visible. A pure RAG system returns the top-K by vector similarity. This system returns memories that are contextually, emotionally, and associatively relevant — even if their content similarity is moderate.

**See also:** Recall Agent, Context Injection, Emotional Resonance, Association Path

---

## Context Injection

The process of formatting recalled memories and inserting them into an LLM's context window. Context injection is the system's output interface — the mechanism by which stored memories influence the LLM's behavior.

**Format:** Memories are formatted as structured XML blocks containing:
- A compressed summary of the content
- Key emotional metadata (mood, domain, formation time)
- Brief association hints (links to other recalled memories)
- Relevance and emotional resonance scores

**Strategy:**
- Top-ranked memories are injected with full content; lower-ranked ones use summaries only
- Total injection is bounded by a configurable token budget
- The injection block is placed at a configurable position in the context (typically after system prompt, before conversation history)
- Emotional priming: if the current mood strongly matches recalled memories, the injection block includes a brief emotional context note

**See also:** Winnowing, Recall Agent, Memory Entry

---

## Memory Compartment

An access-controlled partition within the memory store, managed by the Sentinel agent. Compartments restrict which agents, users, or API consumers can read or write specific memories.

**Use cases:**
- Personal memories visible only to a specific user
- Sensitive operational memories (credentials encountered, security incidents) restricted to admin access
- Project-scoped compartments that isolate memories by project context
- Cross-compartment recall with redaction (the Sentinel strips restricted fields before returning)

**Classification levels:**
- **Open:** Accessible to all authorized consumers
- **Restricted:** Accessible only to specified agents/users
- **Sealed:** Accessible only via explicit admin override

Compartments create boundaries in the association graph. The Weaver can create edges across compartment boundaries, but the Sentinel will redact or block traversal across those edges during recall unless the requester has appropriate access.

**See also:** Sentinel, Recall Agent, Association Path

---

## Contradiction Detection

The Guardian's process of identifying incoming memories that conflict with existing stored memories. Contradiction detection prevents the memory store from containing incompatible truths that would produce confused or hallucinated outputs.

**Detection methods:**
- **Semantic similarity + negation:** Two memories with high content similarity but opposite assertions (e.g., "service X uses JWT auth" vs. "service X uses session-based auth")
- **Temporal impossibility:** Two memories claiming different events at the same time for the same agent
- **Schema conflict:** Memories asserting incompatible structured facts (e.g., different values for the same configuration key)
- **Emotional inconsistency:** A memory tagged with high satisfaction about an event that other memories describe as a failure (potential poisoning signal)

**Resolution:**
- Low-severity contradictions: The newer memory is flagged; both remain with a `contradiction_link` between them
- Medium-severity: The incoming memory is quarantined pending human review
- High-severity (identity-level conflicts): Escalated to the human operator immediately

**See also:** Guardian, Quarantine, Memory Entry

---

## Emotional Resonance

A recall boost that occurs when the current emotional state of the agent closely matches the emotional metadata of a stored memory. Emotional resonance is the mechanism that makes the system's recall feel "human" — you remember frustrating things when you're frustrated, even if the content is unrelated.

**Computation:**
```
resonance = 1 - (cosine_distance(current_state, memory_state) / 2)
```

Where both state vectors include valence, arousal, dominance, and all four hormonal signals (7 dimensions total).

**Effect:** High resonance (> 0.7) provides a relevance boost during winnowing, potentially promoting an emotionally matching memory above a content-similar but emotionally mismatched one. The boost is configurable and can be tuned per deployment.

**See also:** Emotional Metadata, Winnowing, Recall Agent

---

## Hebbian-like Learning

The principle that "memories that fire together wire together." When two memories are recalled in the same recall session, the association edge between them is strengthened — or created if it does not exist.

This is the system's primary mechanism for emergent association discovery. Links created by the Weaver at formation time represent known relationships; links created through Hebbian co-recall represent discovered relationships that emerge from usage patterns.

**Mechanism:**
```
co_recall_boost = 0.05 * min(relevance_a, relevance_b)
```

New edges created via co-recall are typed as `co-occurrence` and start with the computed boost as their initial weight.

**See also:** Relational Weight, Reinforcement, Weaver, Association Path
