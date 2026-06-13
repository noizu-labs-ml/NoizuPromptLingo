# Design Notes

Captured decisions and clarifications that should be reflected in architecture and stories.

## Active Recall vs Tangential Insertion (2026-05-27)

Two fundamentally different retrieval modes:

### Active Recall
- Agent deliberately tries to remember: "What do I know about X?"
- Triggers deep, vigorous multi-path traversal (semantic + emotional + temporal + relational)
- Higher latency tolerance — the agent knows it's searching and can wait
- Exhaustive search, wider association radius, lower relevance threshold
- May involve the Dreamer for real-time synthesis if initial results are sparse
- Analogy: trying to remember someone's name — effortful, focused, recursive

### Tangential Insertion
- During ongoing conversation, relevant memories bubble up without explicit request
- Lightweight, low-latency, must not disrupt conversational flow
- Narrow association radius, high relevance threshold (only surface strong matches)
- Triggered by emotional resonance, keyword overlap, or context similarity with current conversation
- Results injected into context window as "reminds me of..." or background context
- Analogy: a song plays and you suddenly remember a summer vacation — effortless, serendipitous

### Architectural Implications
- The Recall Agent needs two operating modes (or two sub-agents)
- Tangential insertion needs a fast-path index (pre-computed hot memories per emotional state?)
- Active recall can afford vector DB round-trips and graph traversals
- Different winnowing thresholds: tangential is aggressive (only top 1-3), active is generous (top 10-20)
- Context injection formatting differs: tangential is subtle/parenthetical, active is structured/detailed
- Latency budgets: tangential < 100ms, active < 2s
