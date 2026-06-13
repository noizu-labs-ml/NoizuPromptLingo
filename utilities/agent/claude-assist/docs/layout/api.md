# packages/api — REST API Server

Express-based API for indexing, searching, and serving Claude conversation data.

```
api/
├── src/
│   ├── routes/                 # HTTP route handlers
│   │   ├── config.ts           #   GET /config — runtime configuration
│   │   ├── conversations.ts    #   /conversations — list, get, browse
│   │   ├── datasets.ts         #   /datasets — dataset management
│   │   ├── index-routes.ts     #   /index — trigger re-indexing
│   │   ├── projects.ts         #   /projects — project metadata
│   │   ├── prompts.ts          #   /prompts — prompt extraction
│   │   ├── search.ts           #   /search — full-text + semantic search
│   │   └── tags.ts             #   /tags — tag management
│   ├── services/               # Core business logic
│   │   ├── converter.ts        #   JSONL → structured conversation objects
│   │   ├── editor.ts           #   Conversation editing operations
│   │   ├── embeddings.ts       #   Vector embedding generation
│   │   ├── exporter.ts         #   Export conversations to various formats
│   │   ├── indexer.ts          #   Scan + index conversation files
│   │   ├── operations.ts       #   Cross-service orchestration
│   │   ├── search.ts           #   Search engine (FTS + vector)
│   │   └── storage.ts          #   SQLite persistence layer
│   ├── __tests__/              # Unit tests
│   └── index.ts                # Server entry point
├── package.json
└── tsconfig.json
```
