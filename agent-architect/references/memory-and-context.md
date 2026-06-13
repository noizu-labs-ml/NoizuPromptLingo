# Memory and Context Management for Agents

Multi-layer memory architectures, context window strategies, and retrieval patterns. Based on 2025-2026 research and production experience.

---

## The 2025-2026 Memory Stack

The field converged on a **multi-layer architecture**:

| Layer | Scope | Implementation | Persistence | Example |
|-------|-------|----------------|-------------|---------|
| Working Memory | Current task | Context window | Session only | Current file being edited, tool results |
| Short-term Memory | Recent conversation | Sliding window + summarization | Hours | Last 5 turns of conversation |
| Episodic Memory | Past task experiences | Vector DB with temporal metadata | Weeks-months | "Last time we deployed, the health check failed because..." |
| Semantic Memory | Facts and knowledge | RAG / knowledge graph | Permanent | "The auth service uses OAuth2 with PKCE" |
| Procedural Memory | Learned skills | Prompt templates / tool configs | Permanent | "To deploy: build → push → apply → verify" |

### Key Finding: Large Context Windows Are Not Enough

A dominant assumption in 2025 was that 1M+ token windows would eliminate external memory. **This collapsed in practice.**

- Retrieval accuracy degrades in long contexts — "lost in the middle" persists
- Long context is useful for *availability* but not for *reliable retrieval*
- Cost scales linearly with context size — stuffing 500K tokens when you need 10K is wasteful
- Latency increases with context size

**Practical implication:** Use large context windows for *breadth of availability*, but use retrieval strategies for *reliable access* to specific information.

### Sources
- Alok Mishra: "A 2026 Memory Stack for Enterprise Agents" (2026)
- Sitepoint: "The New Reality of Agent Memory" (2025-2026)
- Mem0: "State of AI Agent Memory 2026"
- VentureBeat: "Observational Memory Cuts AI Agent Costs 10x" (2025)

---

## Memory is a Product Requirement

Memory-related failures were the **most frequently reported category** of production reliability issues in 2025. Users notice immediately when agents:
- Forget prior decisions
- Re-ask questions they've already answered
- Lose track of established preferences
- Fail to learn from past mistakes

**Memory is no longer an optimization — it is a core product requirement.**

---

## Context Window Strategies

### Strategy 1: Hierarchical Summarization

Older messages get progressively compressed:

```
Turn 1-5:   Full text (current working context)
Turn 6-15:  Detailed summary (key decisions, tool results)
Turn 16-30: Key points (one line per turn)
Turn 31+:   Single-line note ("Discussed auth architecture, decided on OAuth2+PKCE")
```

**Implementation:** Run summarization at defined thresholds (e.g., every 10 turns). The summary itself goes into context; original turns are evicted.

### Strategy 2: Relevance-Based Eviction

Instead of chronological eviction (oldest first), use embedding similarity to keep contextually relevant history.

```
Current task: "Fix the auth redirect bug"

Keep (high relevance):
  - Turn 12: "The OAuth redirect URL is constructed in auth.ts:45"
  - Turn 8: "We decided to use PKCE for the mobile app"

Evict (low relevance):
  - Turn 15: "Unrelated: updated the README formatting"
  - Turn 3: "Small talk about weekend plans"
```

**Trade-off:** More expensive (requires embeddings) but preserves critical context that chronological eviction would lose.

### Strategy 3: Tool Result Caching

Don't re-call tools when results are still in context. Implement TTL-based cache invalidation.

```
tool_cache:
  search_users("active"):
    result: [...]
    cached_at: 2025-03-15T10:30:00Z
    ttl: 300s  # 5 minutes
    status: valid

  get_deployment_status("prod"):
    result: {status: "healthy"}
    cached_at: 2025-03-15T10:28:00Z
    ttl: 60s   # 1 minute — changes frequently
    status: expired → re-fetch
```

### Strategy 4: Lazy Loading

Load tool schemas, memory, and knowledge **on demand**, not all at agent startup.

```
Startup context: Identity + guardrails + current task (small)
  → Agent determines it needs code search
    → Load code search tool schema
  → Agent determines it needs user history
    → Load user memory scope
  → Agent determines it needs API docs
    → Retrieve relevant API docs via RAG
```

**Savings:** A typical agent with 50 tools, 10KB of memory, and 20KB of docs would consume ~80K tokens at startup. Lazy loading reduces this to ~5K tokens initially.

### Strategy 5: Scratchpad with Compaction

Dedicate a context section for working notes. Compact periodically.

**Before compaction (1500 tokens):**
```
SCRATCHPAD:
- Found auth.ts, oauth.ts, session.ts matching "auth" pattern
- auth.ts:45 has redirect URL construction — BUG IS HERE
- oauth.ts:12 imports redirect URL from auth.ts
- session.ts is unrelated — uses different auth path
- Tried fix #1: URL encoding — didn't work, redirect still fails
- Root cause: missing trailing slash in redirect URI
- Fix #2: normalize redirect URI with trailing slash
- Tests pass locally
- Need to check if this affects the mobile OAuth flow
```

**After compaction (400 tokens):**
```
SCRATCHPAD:
- BUG: auth.ts:45 missing trailing slash in redirect URI
- FIX: normalize redirect URI (fix #2) — tests pass locally
- TODO: verify mobile OAuth flow compatibility
```

---

## Observational Memory (2025)

A technique that divides the context window into blocks and maintains a hierarchical index. Instead of external retrieval, the agent keeps months of compressed conversation history *within* the context window using a structured index.

### How It Works

```
INDEX (always in context):
  Session 2025-03-01: Auth architecture discussion → decided OAuth2+PKCE
  Session 2025-03-05: Deployment pipeline → added canary stage
  Session 2025-03-10: Database migration → chose blue-green strategy
  ...

DETAIL (loaded on demand from index):
  [Session 2025-03-01 expanded]:
    - Evaluated JWT vs OAuth2 vs session tokens
    - Chose OAuth2+PKCE for mobile support
    - Key constraint: must support offline-first mobile clients
    - Decision owner: @keith
```

**Reported result:** 10x cost reduction compared to traditional RAG on long-context benchmarks (VentureBeat 2025).

**Trade-off:** Requires careful index maintenance. Index quality degrades without periodic human review.

---

## Multi-Scope Memory

A design pattern where each memory write is **tagged with identity scopes**:

| Scope | Visibility | Example |
|-------|-----------|---------|
| User | Only this user | "Keith prefers terse output" |
| Session | Only this conversation | "Currently debugging auth redirect" |
| Project | All users in this project | "Auth service uses OAuth2+PKCE" |
| Organization | All users in this org | "Company policy: no PII in logs" |

**At retrieval time:** Scopes compose and results merge + rank automatically. This prevents cross-user contamination while enabling organizational knowledge sharing.

---

## Memory Design for Claude Code Agents

Claude Code's memory system provides a concrete implementation pattern:

### File-Based Memory

```
~/.claude/projects/{project}/memory/
  ├── MEMORY.md              # Index (always loaded)
  ├── user_role.md            # User-scoped
  ├── feedback_testing.md     # Feedback-scoped
  ├── project_auth_arch.md    # Project-scoped
  └── reference_linear.md     # Reference-scoped
```

### Memory Types Map to the Stack

| Claude Code Type | Memory Stack Layer | Purpose |
|-----------------|-------------------|---------|
| `user` | Semantic | Who the user is, how to work with them |
| `feedback` | Procedural | Learned behavioral rules |
| `project` | Episodic + Semantic | Project-specific facts and decisions |
| `reference` | Semantic | Where to find external information |

### Design Principle: Memory Files, Not Memory Blobs

Each memory is a separate file with frontmatter:
```yaml
---
name: auth-architecture-decision
description: OAuth2+PKCE chosen for mobile support — affects all auth-related work
metadata:
  type: project
---

OAuth2 with PKCE was chosen for the auth system.
**Why:** Must support offline-first mobile clients that can't securely store client secrets.
**How to apply:** All auth-related changes must be compatible with PKCE flow. No client secrets in mobile code paths.
```

**Why separate files:** Atomic updates, targeted retrieval, easy to audit and clean up stale entries.

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Dump everything into context | "Lost in the middle" + cost explosion | Hierarchical summarization + lazy loading |
| No memory eviction | Context window fills up, oldest context lost unpredictably | Explicit eviction strategy (chronological or relevance-based) |
| Storing conclusions without reasoning | Can't evaluate if memory is still valid | Store the reasoning ("Why") with every memory |
| No memory scoping | Cross-user contamination, irrelevant memories | Tag with identity scopes |
| Treating memory as append-only | Stale memories accumulate, conflict with current state | Regular cleanup, update-or-replace semantics |
| External retrieval for everything | High latency, embedding quality varies | Use context window for recent/critical, external for archival |
