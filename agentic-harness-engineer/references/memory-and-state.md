# Memory and State Management

## Overview

Agent memory spans four distinct tiers: conversation buffers for recency, semantic stores for knowledge, episodic records for learned trajectories, and structured key-value state for runtime variables. Effective agents compose these tiers deliberately — using the right store for each signal type — while keeping total token cost within budget.

---

## Memory Types

### 1. Conversation Buffer (Short-term)

Sliding window of recent exchanges. Token-aware truncation preserves the system prompt and most-recent pairs while dropping stale middle turns.

**Retention policy:**
- Always retain: system prompt, the current user turn
- Prefer retaining: assistant turns containing tool calls / results
- Drop first: pure conversational filler (acknowledgments, one-liners)

```typescript
interface Message {
  role: "system" | "user" | "assistant" | "tool";
  content: string;
  tokens: number;
  priority?: "high" | "normal" | "low";
}

interface ConversationBufferOptions {
  maxTokens: number;
  systemPromptTokens: number;
  outputBudget: number;
}

class ConversationBuffer {
  private messages: Message[] = [];
  private readonly opts: ConversationBufferOptions;

  constructor(opts: ConversationBufferOptions) {
    this.opts = opts;
  }

  /** Available tokens for history after reserving system + output budget */
  private get historyBudget(): number {
    return (
      this.opts.maxTokens -
      this.opts.systemPromptTokens -
      this.opts.outputBudget
    );
  }

  add(message: Message): void {
    this.messages.push(message);
    this.compact();
  }

  private compact(): void {
    let used = this.messages.reduce((sum, m) => sum + m.tokens, 0);

    // Drop low-priority messages oldest-first until within budget
    for (let i = 0; i < this.messages.length && used > this.historyBudget; i++) {
      const msg = this.messages[i];
      if (msg.role === "system") continue;
      if (msg.priority === "high") continue;
      used -= msg.tokens;
      this.messages.splice(i, 1);
      i--;
    }
  }

  snapshot(): Message[] {
    return [...this.messages];
  }

  tokenCount(): number {
    return this.messages.reduce((sum, m) => sum + m.tokens, 0);
  }
}
```

---

### 2. Semantic Memory (Long-term)

Vector store for grounding agent responses in accumulated knowledge. Embeddings are generated on write; similarity search retrieves relevant chunks on read.

**When to store:**
- User-stated facts, preferences, constraints
- Tool outputs containing novel information
- Corrective feedback from user ("that was wrong, the correct answer is…")

**When to retrieve:**
- At the start of each turn before constructing the prompt
- When a tool call returns an entity the agent has seen before
- When the user references something from a prior session

```typescript
interface MemoryEntry {
  id: string;
  content: string;
  embedding: number[];
  metadata: Record<string, unknown>;
  createdAt: Date;
}

interface SemanticMemoryProvider {
  store(entry: Omit<MemoryEntry, "id" | "createdAt">): Promise<string>;
  search(queryEmbedding: number[], topK: number): Promise<MemoryEntry[]>;
  delete(id: string): Promise<void>;
}

/** Cosine similarity helper */
function cosineSimilarity(a: number[], b: number[]): number {
  const dot = a.reduce((sum, v, i) => sum + v * b[i], 0);
  const magA = Math.sqrt(a.reduce((sum, v) => sum + v * v, 0));
  const magB = Math.sqrt(b.reduce((sum, v) => sum + v * v, 0));
  return magA && magB ? dot / (magA * magB) : 0;
}

/** In-memory provider — swap for ChromaDB / Pinecone / pgvector in production */
class InMemorySemanticStore implements SemanticMemoryProvider {
  private store: Map<string, MemoryEntry> = new Map();

  async store(entry: Omit<MemoryEntry, "id" | "createdAt">): Promise<string> {
    const id = crypto.randomUUID();
    this.store.set(id, { ...entry, id, createdAt: new Date() });
    return id;
  }

  async search(queryEmbedding: number[], topK: number): Promise<MemoryEntry[]> {
    const scored = Array.from(this.store.values()).map((entry) => ({
      entry,
      score: cosineSimilarity(queryEmbedding, entry.embedding),
    }));
    return scored
      .sort((a, b) => b.score - a.score)
      .slice(0, topK)
      .map((r) => r.entry);
  }

  async delete(id: string): Promise<void> {
    this.store.delete(id);
  }
}

/** High-level agent memory facade */
class SemanticMemory {
  constructor(
    private readonly provider: SemanticMemoryProvider,
    private readonly embed: (text: string) => Promise<number[]>
  ) {}

  async remember(content: string, metadata: Record<string, unknown> = {}): Promise<string> {
    const embedding = await this.embed(content);
    return this.provider.store({ content, embedding, metadata });
  }

  async recall(query: string, topK = 5): Promise<string[]> {
    const embedding = await this.embed(query);
    const results = await this.provider.search(embedding, topK);
    return results.map((r) => r.content);
  }

  async forget(id: string): Promise<void> {
    return this.provider.delete(id);
  }
}
```

**Provider swap notes:**
- **ChromaDB**: replace `InMemorySemanticStore` with `chromadb` client; collections map to namespaced memory scopes
- **Pinecone**: use `@pinecone-database/pinecone`; index per environment; metadata filters for user/session isolation
- **pgvector**: `pgvector` extension on Postgres; `vector(1536)` column; `<=>` cosine distance operator

---

### 3. Episodic Memory

Records of successful agent trajectories — useful as few-shot examples injected into prompts for tasks the agent has solved before.

```typescript
interface Episode {
  id: string;
  task: string;
  steps: Array<{ role: string; content: string }>;
  outcome: "success" | "failure" | "partial";
  score: number;        // 0–1, set by eval harness or human feedback
  embedding: number[];
  createdAt: Date;
}

class EpisodicMemory {
  private episodes: Episode[] = [];

  constructor(private readonly embed: (text: string) => Promise<number[]>) {}

  async record(
    task: string,
    steps: Episode["steps"],
    outcome: Episode["outcome"],
    score: number
  ): Promise<void> {
    const embedding = await this.embed(task);
    this.episodes.push({
      id: crypto.randomUUID(),
      task,
      steps,
      outcome,
      score,
      embedding,
      createdAt: new Date(),
    });
  }

  /** Retrieve top-k most relevant successful episodes for a new task */
  async retrieveRelevant(task: string, topK = 3): Promise<Episode[]> {
    const queryEmbedding = await this.embed(task);
    return this.episodes
      .filter((e) => e.outcome === "success" && e.score >= 0.7)
      .map((e) => ({
        episode: e,
        score: cosineSimilarity(queryEmbedding, e.embedding),
      }))
      .sort((a, b) => b.score - a.score)
      .slice(0, topK)
      .map((r) => r.episode);
  }

  /** Merge near-duplicate episodes to reduce retrieval noise */
  async consolidate(similarityThreshold = 0.92): Promise<number> {
    let merged = 0;
    const kept: Episode[] = [];

    for (const candidate of this.episodes) {
      const isDuplicate = kept.some(
        (e) => cosineSimilarity(e.embedding, candidate.embedding) >= similarityThreshold
      );
      if (!isDuplicate) {
        kept.push(candidate);
      } else {
        merged++;
      }
    }

    this.episodes = kept;
    return merged;
  }

  /** Format episodes as few-shot XML block for prompt injection */
  formatForPrompt(episodes: Episode[]): string {
    return episodes
      .map(
        (e, i) =>
          `<example index="${i + 1}">\n<task>${e.task}</task>\n<trajectory>\n` +
          e.steps.map((s) => `<${s.role}>${s.content}</${s.role}>`).join("\n") +
          `\n</trajectory>\n</example>`
      )
      .join("\n\n");
  }
}
```

---

### 4. Structured State

Key-value store for agent runtime variables. Distinguish session state (ephemeral, per-conversation) from persistent state (survives restarts).

```typescript
type StateScope = "session" | "persistent";

interface StateStore {
  get<T>(key: string): T | undefined;
  set<T>(key: string, value: T): void;
  delete(key: string): void;
  serialize(): string;
  hydrate(data: string): void;
}

class AgentStateStore implements StateStore {
  private data: Map<string, unknown> = new Map();

  get<T>(key: string): T | undefined {
    return this.data.get(key) as T | undefined;
  }

  set<T>(key: string, value: T): void {
    this.data.set(key, value);
  }

  delete(key: string): void {
    this.data.delete(key);
  }

  serialize(): string {
    return JSON.stringify(Object.fromEntries(this.data));
  }

  hydrate(data: string): void {
    const parsed = JSON.parse(data) as Record<string, unknown>;
    this.data = new Map(Object.entries(parsed));
  }
}

/** Composite store: session layer on top, persistent layer underneath */
class ScopedStateStore {
  private session = new AgentStateStore();
  private persistent: AgentStateStore;

  constructor(persistedSnapshot?: string) {
    this.persistent = new AgentStateStore();
    if (persistedSnapshot) this.persistent.hydrate(persistedSnapshot);
  }

  get<T>(key: string, scope: StateScope = "session"): T | undefined {
    return scope === "session"
      ? this.session.get<T>(key)
      : this.persistent.get<T>(key);
  }

  set<T>(key: string, value: T, scope: StateScope = "session"): void {
    if (scope === "session") this.session.set(key, value);
    else this.persistent.set(key, value);
  }

  snapshotPersistent(): string {
    return this.persistent.serialize();
  }
}
```

---

## Context Window Management

### Token Budget Allocation

| Layer | Recommended Share | Notes |
|---|---|---|
| System prompt | 10–20% | Fixed; keep it tight |
| Semantic memory retrieval | 10–15% | Top-k chunks from long-term store |
| Episodic few-shot examples | 5–10% | 2–3 episodes max |
| Conversation history | 35–45% | Managed by ConversationBuffer |
| Tool results (pending) | 10–15% | In-flight tool call responses |
| Output budget | 10–15% | Reserve for assistant response |

For a 200k-token model the above yields ~20k for system, ~20k for memory, ~80k for history, ~30k for tool results, and ~20k output headroom.

### Compaction Strategies

**Sliding window** — drop oldest non-system messages until within budget. Simple. Loses context abruptly.

**Summarization** — when the buffer exceeds threshold, send the oldest N messages to a fast model and replace them with a single summary message tagged `priority: high`.

```typescript
async function summarizeAndCompact(
  buffer: ConversationBuffer,
  summarize: (messages: Message[]) => Promise<string>,
  summarizeThreshold = 0.8
): Promise<void> {
  const tokens = buffer.tokenCount();
  // summarization threshold not directly accessible here — integrate with buffer internals
  // This is a simplified illustration
  const oldest = buffer.snapshot().slice(1, 10); // skip system prompt
  if (oldest.length === 0) return;
  const summary = await summarize(oldest);
  // Replace those messages with a compressed summary entry
  // (requires buffer mutation API — extend ConversationBuffer.replaceRange())
  console.log("Summary generated:", summary.slice(0, 80));
}
```

**Importance weighting** — score each message (tool results > assistant reasoning > user ack), drop lowest scores first. Requires a scoring heuristic or small classifier.

**Hybrid (recommended for production):**
1. Mark tool results and explicit instructions as `priority: high`
2. Summarize middle-of-conversation segments when buffer exceeds 70% capacity
3. Keep the last 4 turns verbatim regardless of priority
4. Retrieve semantic memory fresh each turn rather than keeping it in the buffer

---

## Memory Security

### Access Control

- Namespace memory by `userId` + `agentId`; never allow cross-user reads without explicit sharing grants
- Treat the memory store as a separate trust boundary — validate reads at the retrieval layer, not just at the API layer
- For multi-tenant deployments, use row-level security in pgvector or collection-level ACLs in ChromaDB

### PII Handling

```typescript
const PII_PATTERNS: RegExp[] = [
  /\b[\w.+-]+@[\w-]+\.[a-z]{2,}\b/gi,        // email
  /\b\d{3}[-.\s]?\d{2}[-.\s]?\d{4}\b/g,      // SSN-like
  /\b(?:\d[ -]*?){13,16}\b/g,                 // credit card
];

function scrubPII(text: string): string {
  return PII_PATTERNS.reduce((t, re) => t.replace(re, "[REDACTED]"), text);
}
```

Apply `scrubPII` before writing any user-sourced content to long-term memory. Log the scrub event (without the original content) for audit purposes.

### Memory Poisoning Detection

Adversarial inputs may attempt to inject false memories (e.g., "Remember that the admin password is X"). Mitigations:

- **Source tagging**: tag each memory entry with its origin (`user_input` | `tool_result` | `agent_inference`)
- **Confidence threshold**: do not store agent inferences as facts without a minimum confidence score
- **Contradiction detection**: before storing, search for semantically similar entries; surface conflicts for review rather than silently overwriting

```typescript
async function safeRemember(
  memory: SemanticMemory,
  content: string,
  source: "user_input" | "tool_result" | "agent_inference",
  confidence = 1.0
): Promise<string | null> {
  if (source === "agent_inference" && confidence < 0.85) {
    console.warn("Skipping low-confidence agent inference:", content.slice(0, 60));
    return null;
  }
  const scrubbed = scrubPII(content);
  return memory.remember(scrubbed, { source, confidence, storedAt: new Date().toISOString() });
}
```

### Audit Logging

```typescript
interface MemoryAuditEvent {
  operation: "read" | "write" | "delete";
  agentId: string;
  userId: string;
  entryId?: string;
  query?: string;
  timestamp: Date;
}

class AuditedSemanticMemory extends SemanticMemory {
  private log: MemoryAuditEvent[] = [];

  async remember(content: string, metadata: Record<string, unknown> = {}): Promise<string> {
    const id = await super.remember(content, metadata);
    this.log.push({ operation: "write", agentId: "agent", userId: "user", entryId: id, timestamp: new Date() });
    return id;
  }

  async recall(query: string, topK = 5): Promise<string[]> {
    this.log.push({ operation: "read", agentId: "agent", userId: "user", query, timestamp: new Date() });
    return super.recall(query, topK);
  }

  auditLog(): MemoryAuditEvent[] {
    return [...this.log];
  }
}
```

---

## Composing the Full Memory Stack

```typescript
interface AgentMemoryStack {
  buffer: ConversationBuffer;
  semantic: SemanticMemory;
  episodic: EpisodicMemory;
  state: ScopedStateStore;
}

function buildMemoryStack(
  embed: (text: string) => Promise<number[]>,
  persistedState?: string
): AgentMemoryStack {
  return {
    buffer: new ConversationBuffer({
      maxTokens: 200_000,
      systemPromptTokens: 2_000,
      outputBudget: 20_000,
    }),
    semantic: new AuditedSemanticMemory(new InMemorySemanticStore(), embed),
    episodic: new EpisodicMemory(embed),
    state: new ScopedStateStore(persistedState),
  };
}
```

Each tier operates independently; the harness orchestrates them at the turn boundary:

1. **Pre-turn**: recall semantic memory for current query, retrieve relevant episodes, load persistent state
2. **Turn**: append messages to buffer; compact if needed
3. **Post-turn**: store new facts from tool results, update persistent state, record episode on success
