# Instructions Domain

Versioned instruction documents with active version pointer, optionally linked to a session. Supports multi-facet vector embeddings for semantic search.

## npl_instructions

Instruction document metadata with active version tracking.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | gen_random_uuid() | Primary key |
| session_id | UUID | Yes | — | FK to npl_tool_sessions(id) |
| title | VARCHAR(512) | No | — | Document title |
| description | TEXT | Yes | — | Document description |
| tags | TEXT[] | Yes | — | Categorization tags |
| active_version | INTEGER | No | 1 | Points to active version number |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |

**Foreign Key**: `fk_instructions_session` (session_id) REFERENCES npl_tool_sessions(id)
**Indexes**: `idx_instructions_session_id` (session_id)

## npl_instruction_versions

Versioned instruction bodies linked to parent instruction.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | gen_random_uuid() | Primary key |
| instruction_id | UUID | No | — | FK to npl_instructions(id) |
| version | INTEGER | No | — | Version number |
| body | TEXT | No | — | Instruction content |
| change_note | TEXT | Yes | — | Version change description |
| created_at | TIMESTAMP | No | NOW() | Creation time |

**Foreign Key**: `fk_instruction_version_instruction` (instruction_id) REFERENCES npl_instructions(id)
**Constraints**: `uq_instruction_version` UNIQUE (instruction_id, version)
**Indexes**: `idx_instruction_versions_instruction_id` (instruction_id)

## npl_instruction_embeddings

Multi-facet vector embeddings for semantic search across instructions. Each instruction can have multiple embedding rows (one per descriptive phrase/label).

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | gen_random_uuid() | Primary key |
| instruction_id | UUID | No | — | FK to npl_instructions(id) |
| label | TEXT | No | — | Descriptive phrase for this embedding |
| embedding | vector(1536) | No | — | Embedding vector |
| created_at | TIMESTAMP | No | NOW() | Creation time |

**Foreign Key**: `fk_instruction_embeddings_instruction` (instruction_id) REFERENCES npl_instructions(id)
**Indexes**: `idx_instruction_embeddings_instruction_id` (instruction_id), `idx_instruction_embeddings_search` (embedding — HNSW, vector_cosine_ops)
