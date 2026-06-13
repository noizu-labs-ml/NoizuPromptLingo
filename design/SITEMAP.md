# Sitemap: The Robot Remembers

Operator and developer dashboard for the agent memory service.

```
therobotremembers.com/
│
├── /                                    Landing / System Overview
│   Health summary, memory count, agent status grid,
│   recent activity feed, system alerts
│
├── /memories
│   ├── /memories/explorer               Memory Explorer
│   │   Browse, search, and filter memories with full-text,
│   │   emotional, temporal, and contextual filters.
│   │   Card grid with sorting and pagination.
│   │
│   ├── /memories/graph                  Association Graph
│   │   Force-directed graph visualization of the memory web.
│   │   Nodes = memories, edges = associations.
│   │   Color by emotion, size by weight, filter by edge type.
│   │
│   ├── /memories/timeline               Memory Timeline
│   │   Chronological view with emotional color overlay.
│   │   Vertical timeline, emotional heatmap background,
│   │   filterable by domain/collaborator/mood.
│   │
│   └── /memories/:id                    Memory Detail
│       Full memory content, all metadata, association list,
│       lifecycle history, reinforcement/denforcement controls,
│       edit content/metadata, view in graph context.
│
├── /agents
│   ├── /agents/dashboard                Agent Dashboard
│   │   Grid of all 8 synthetic agents. Status, health,
│   │   key metric per agent, emotional state indicators.
│   │
│   ├── /agents/:id                      Agent Detail
│   │   Configuration, recent activity log, emotional state
│   │   over time (chart), performance metrics, manual
│   │   state adjustment (admin).
│   │
│   └── /agents/:id/state               Agent Emotional State
│       Current emotional vector displayed as radar chart.
│       Hormone levels as bar gauges. Historical trend.
│       Compare state across agents.
│
├── /recall
│   ├── /recall/console                  Recall Console
│   │   Interactive recall testing. Set query text, emotional
│   │   parameters, contextual filters, traversal depth.
│   │   See results with relevance scores, association paths,
│   │   context injection preview.
│   │
│   └── /recall/history                  Recall History
│       Past recall requests with parameters, results, timing.
│       Replay past recalls, compare results over time.
│
├── /guardian
│   ├── /guardian/alerts                 Guardian Alerts
│   │   Feed of blocked memories, detected contradictions,
│   │   quarantined entries. Severity levels, timestamps,
│   │   action buttons (approve/reject/escalate).
│   │
│   └── /guardian/rules                  Integrity Rules
│       Configuration of contradiction detection thresholds,
│       blocklist patterns, schema validation rules.
│       Test rules against sample memories.
│
├── /admin
│   ├── /admin/weights                   Weight Tuner
│   │   Global weight parameters: reinforcement boost,
│   │   denforcement penalty, co-recall factor.
│   │   Per-memory-type decay half-lives.
│   │   Preview weight changes with simulation.
│   │
│   ├── /admin/decay                     Decay Configuration
│   │   Decay curve visualization (interactive chart).
│   │   Half-life settings per memory type.
│   │   Pruning threshold and grace period.
│   │   Simulation: "how many memories would be pruned if..."
│   │
│   ├── /admin/compartments              Compartment Manager
│   │   Create, edit, delete memory compartments.
│   │   Assign classification levels. Configure access
│   │   policies per agent/user/API key.
│   │
│   └── /admin/api-keys                  API Key Management
│       Create, revoke, rotate API keys. Per-key permissions,
│       rate limits, compartment access grants.
│
└── /docs
    ├── /docs/api                        API Reference
    │   Interactive API documentation (OpenAPI/Swagger).
    │   Try-it-out console for each endpoint.
    │
    └── /docs/concepts                   Concept Glossary
        Rendered version of CONCEPTS.md.
        Searchable, cross-linked definitions.
```

## Navigation Structure

### Primary Navigation (Sidebar)
1. **Dashboard** (/)
2. **Memories** (/memories/explorer) — default to explorer
3. **Agents** (/agents/dashboard)
4. **Recall** (/recall/console)
5. **Guardian** (/guardian/alerts)
6. **Admin** (/admin/weights)
7. **Docs** (/docs/api)

### Secondary Navigation (Tab bars within sections)
- **Memories:** Explorer | Graph | Timeline
- **Recall:** Console | History
- **Guardian:** Alerts | Rules
- **Admin:** Weights | Decay | Compartments | API Keys
- **Docs:** API | Concepts

### Contextual Navigation
- Memory cards link to `/memories/:id`
- Agent tiles link to `/agents/:id`
- Association edges link to both connected memories
- Recall results link to source memories
- Guardian alerts link to quarantined memories
