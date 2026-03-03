# NPL Content Domain

Tables for storing parsed NPL language elements with vector embeddings for semantic search.

## npl_metadata

Key-value configuration and state store.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | VARCHAR(64) | No | — | Primary key |
| value | JSONB | No | — | Stored value |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |

**Indexes**: `idx_npl_metadata_updated_at` (updated_at)

## npl_component

NPL components with section grouping and vector search.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | VARCHAR(128) | No | — | Primary key |
| version | VARCHAR(32) | No | — | Component version |
| section | VARCHAR(128) | No | — | Parent section ID |
| file | VARCHAR(64) | No | — | Source file |
| digest | CHAR(64) | No | — | Content SHA-256 |
| value | JSONB | No | — | Component data |
| search | vector(1536) | Yes | — | Embedding vector |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |
| deleted_at | TIMESTAMP | Yes | — | Soft delete marker |

**Indexes**: `idx_npl_component_section` (section), `idx_npl_component_file` (file), `idx_npl_component_deleted_at` (deleted_at), `idx_npl_component_search` (search — ivfflat, vector_cosine_ops, lists=100)

## npl_sections

NPL section definitions with associated file lists.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | VARCHAR(128) | No | — | Primary key |
| name | VARCHAR(128) | No | — | Section name |
| version | VARCHAR(32) | No | — | Section version |
| files | JSONB | No | — | Associated files |
| digest | CHAR(64) | No | — | Content SHA-256 |
| value | JSONB | No | — | Section data |
| search | vector(1536) | Yes | — | Embedding vector |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |
| deleted_at | TIMESTAMP | Yes | — | Soft delete marker |

**Indexes**: `idx_npl_sections_name` (name), `idx_npl_sections_deleted_at` (deleted_at), `idx_npl_sections_search` (search — ivfflat, vector_cosine_ops, lists=100)

## npl_concepts

Core NPL concept definitions.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | VARCHAR(128) | No | — | Primary key |
| name | VARCHAR(128) | No | — | Concept name |
| version | VARCHAR(32) | No | — | Concept version |
| file | VARCHAR(64) | No | — | Source file |
| digest | CHAR(64) | No | — | Content SHA-256 |
| value | JSONB | No | — | Concept data |
| search | vector(1536) | Yes | — | Embedding vector |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |
| deleted_at | TIMESTAMP | Yes | — | Soft delete marker |

**Indexes**: `idx_npl_concepts_name` (name), `idx_npl_concepts_deleted_at` (deleted_at), `idx_npl_concepts_search` (search — ivfflat, vector_cosine_ops, lists=100)
