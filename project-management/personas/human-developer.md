---
id: persona-human-developer
name: Human Developer
type: human
role: Engineer building integrations, extending the API, and tuning the memory system internals
archetype: Platform engineer / ML engineer
---

# Human Developer

## Overview
The Human Developer builds and extends the memory service itself. They add new memory types, write client agent adapters so external agents can form and recall memories, extend the API surface, tune embedding models for better vector similarity, write evaluation suites to measure recall quality, and optimize the performance of the associative web traversal. They care deeply about developer experience — both their own (working inside the system) and that of external developers integrating with it.

The developer operates at a different layer than the operator. While the operator manages the running system through dashboards and policy, the developer changes what the system is and how it works through code, configuration, and model tuning.

## Goals
- Build clean, well-documented APIs that make memory formation and recall intuitive for client agents
- Extend the memory type system to support new kinds of memories (procedural, episodic, semantic, etc.)
- Tune embedding models so vector similarity accurately reflects semantic and emotional relatedness
- Write comprehensive evals that measure recall quality, precision, and latency under realistic conditions
- Maintain system performance as the memory store and associative web grow

## Frustrations
- The associative web's emergent structure makes performance profiling difficult — hot paths change as links evolve
- Embedding model updates require re-vectorizing the entire memory store, which is expensive and risky
- The synthetic agents' behaviors are hard to unit test because they depend on the state of the full web
- The Sentinel's access control adds complexity to every API endpoint
- The emotional metadata schema is domain-specific enough that standard NLP tooling doesn't help
- Documentation of inter-agent protocols exists mostly as emergent behavior, not specification

## Key Behaviors
- Designs and implements API endpoints for memory CRUD, recall, reinforcement, and denforcement
- Writes client adapters that translate external agent protocols into memory service operations
- Tunes embedding model parameters and evaluates their impact on recall quality
- Builds evaluation suites that benchmark recall precision, latency, and path diversity
- Profiles and optimizes associative web traversal for large memory stores
- Documents API contracts, memory type schemas, and integration patterns

## Interactions
- **Collaborates with:** The Recall Agent (API design for recall requests and result formats), The Archivist (memory formation API and metadata schema), The Sentinel (access control integration in API endpoints), Human Operator (operational requirements inform API design)
- **Tensions with:** The Sentinel (access control adds API complexity), The Weaver (associative web structure is hard to predict and optimize for), The Guardian (validation rules constrain what the API can accept)

## Metrics They Care About
- API response latency (p50, p95, p99 for recall and formation endpoints)
- Eval suite pass rate (recall precision and path diversity benchmarks)
- Integration time for new client agents (time from "I want to use this" to "it works")
- Embedding model quality (cosine similarity correlation with human relevance judgments)
- Test coverage across memory types and agent interaction patterns
