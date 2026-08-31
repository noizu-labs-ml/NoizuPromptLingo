# packages/api — REST API Server

Hono-based API for indexing, searching, and serving coding-agent conversation data (SQLite + FTS5 + sqlite-vec).

```
api/
├── src/
│   ├── routes/                 # HTTP route handlers
│   │   ├── config.ts           #   GET /config — runtime configuration
│   │   ├── conversations.ts    #   /conversations — list, get, browse, edits, convert
│   │   ├── datasets.ts         #   /datasets — dataset management + export
│   │   ├── index-routes.ts     #   /index — trigger re-indexing
│   │   ├── llm.ts              #   /llm — LLM-assisted operations
│   │   ├── projects.ts         #   /projects — project metadata
│   │   ├── prompts.ts          #   /prompts — prompt extraction
│   │   ├── search.ts           #   /search — full-text + semantic search
│   │   └── tags.ts             #   /tags — tag management
│   ├── services/               # Core business logic
│   │   ├── converter.ts        #   JSONL → structured conversation objects
│   │   ├── editor.ts           #   Conversation editing operations
│   │   ├── embeddings.ts       #   Vector embedding generation
│   │   ├── exporter.ts         #   Export conversations / datasets
│   │   ├── harness-transfer.ts #   Move sessions between harnesses
│   │   ├── harness-transform.ts#   Convert transcripts across harness formats
│   │   ├── indexer.ts          #   Scan + index conversation files
│   │   ├── llm.ts              #   LLM provider client
│   │   ├── operations.ts       #   Cross-service orchestration
│   │   ├── search.ts           #   Search engine (FTS + vector)
│   │   ├── session-workflow.ts #   Continue-session workflow logic
│   │   └── storage.ts          #   SQLite persistence layer
│   ├── __tests__/              # Unit tests (routes + services)
│   └── index.ts                # Server entry point (Hono + @hono/node-server)
├── package.json
└── tsconfig.json
```
