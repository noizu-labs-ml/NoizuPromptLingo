# Project Schema

## Overview

NPL MCP uses PostgreSQL (asyncpg) with Liquibase YAML changelogs for migrations. The schema covers six domains: NPL content storage with vector search, credential management, agent session tracking, versioned instruction documents, project scoping, and project management (personas/stories).

**Database**: `localhost:5111/npl` | **Driver**: asyncpg | **Migrations**: `liquibase/changelogs/`

## Entity Relationship Diagram

### Mermaid

```mermaid
erDiagram
    npl_projects ||--o{ npl_tool_sessions : "scopes"
    npl_tool_sessions ||--o{ npl_tool_sessions : "parent"
    npl_tool_sessions ||--o{ npl_instructions : "session"
    npl_instructions ||--o{ npl_instruction_versions : "has versions"
    npl_projects ||--o{ npl_user_personas : "has personas"
    npl_projects ||--o{ npl_user_stories : "has stories"

    npl_metadata {
        VARCHAR_64 id PK
        JSONB value
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    npl_component {
        VARCHAR_128 id PK
        VARCHAR_32 version
        VARCHAR_128 section
        VARCHAR_64 file
        CHAR_64 digest
        JSONB value
        vector_1536 search
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }

    npl_sections {
        VARCHAR_128 id PK
        VARCHAR_128 name
        VARCHAR_32 version
        JSONB files
        CHAR_64 digest
        JSONB value
        vector_1536 search
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }

    npl_concepts {
        VARCHAR_128 id PK
        VARCHAR_128 name
        VARCHAR_32 version
        VARCHAR_64 file
        CHAR_64 digest
        JSONB value
        vector_1536 search
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }

    npl_secrets {
        VARCHAR_128 name PK
        TEXT value
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    npl_projects {
        UUID id PK
        VARCHAR_256 name
        TEXT title
        TEXT description
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }

    npl_tool_sessions {
        UUID id PK
        UUID project_id FK
        UUID parent_id FK
        VARCHAR_256 agent
        TEXT brief
        VARCHAR_512 task
        TEXT notes
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    npl_instructions {
        UUID id PK
        UUID session_id FK
        VARCHAR_512 title
        TEXT description
        TEXT_ARRAY tags
        INTEGER active_version
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    npl_instruction_versions {
        UUID id PK
        UUID instruction_id FK
        INTEGER version
        TEXT body
        TEXT change_note
        TIMESTAMP created_at
    }

    npl_user_personas {
        UUID id PK
        UUID project_id FK
        VARCHAR_255 name
        VARCHAR_255 role
        TEXT description
        TEXT goals
        TEXT pain_points
        TEXT behaviors
        TEXT physical_description
        TEXT persona_image
        JSONB demographics
        UUID created_by
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }

    npl_user_stories {
        UUID id PK
        UUID project_id FK
        UUID_ARRAY persona_ids
        VARCHAR_500 title
        TEXT story_text
        TEXT description
        VARCHAR_20 priority
        VARCHAR_30 status
        INTEGER story_points
        JSONB acceptance_criteria
        TEXT_ARRAY tags
        UUID created_by
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
```

### PlantUML

```plantuml
@startuml
skinparam linetype ortho

package "NPL Content" {
  entity npl_metadata {
    * id : VARCHAR(64) <<PK>>
    --
    * value : JSONB
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
  }

  entity npl_component {
    * id : VARCHAR(128) <<PK>>
    --
    * version : VARCHAR(32)
    * section : VARCHAR(128)
    * file : VARCHAR(64)
    * digest : CHAR(64)
    * value : JSONB
    search : vector(1536)
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
    deleted_at : TIMESTAMP
  }

  entity npl_sections {
    * id : VARCHAR(128) <<PK>>
    --
    * name : VARCHAR(128)
    * version : VARCHAR(32)
    * files : JSONB
    * digest : CHAR(64)
    * value : JSONB
    search : vector(1536)
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
    deleted_at : TIMESTAMP
  }

  entity npl_concepts {
    * id : VARCHAR(128) <<PK>>
    --
    * name : VARCHAR(128)
    * version : VARCHAR(32)
    * file : VARCHAR(64)
    * digest : CHAR(64)
    * value : JSONB
    search : vector(1536)
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
    deleted_at : TIMESTAMP
  }
}

package "Credentials" {
  entity npl_secrets {
    * name : VARCHAR(128) <<PK>>
    --
    * value : TEXT
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
  }
}

package "Projects" {
  entity npl_projects {
    * id : UUID <<PK>>
    --
    * name : VARCHAR(256) <<UNIQUE>>
    title : TEXT
    description : TEXT
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
    deleted_at : TIMESTAMP
  }
}

package "Sessions" {
  entity npl_tool_sessions {
    * id : UUID <<PK>>
    --
    * project_id : UUID <<FK>>
    parent_id : UUID <<FK>>
    * agent : VARCHAR(256)
    * brief : TEXT
    * task : VARCHAR(512)
    notes : TEXT
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
  }
}

package "Instructions" {
  entity npl_instructions {
    * id : UUID <<PK>>
    --
    session_id : UUID <<FK>>
    * title : VARCHAR(512)
    description : TEXT
    tags : TEXT[]
    * active_version : INTEGER
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
  }

  entity npl_instruction_versions {
    * id : UUID <<PK>>
    --
    * instruction_id : UUID <<FK>>
    * version : INTEGER
    * body : TEXT
    change_note : TEXT
    * created_at : TIMESTAMP
  }
}

package "Project Management" {
  entity npl_user_personas {
    * id : UUID <<PK>>
    --
    * project_id : UUID <<FK>>
    * name : VARCHAR(255)
    role : VARCHAR(255)
    description : TEXT
    goals : TEXT
    pain_points : TEXT
    behaviors : TEXT
    physical_description : TEXT
    persona_image : TEXT
    demographics : JSONB
    created_by : UUID
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
    deleted_at : TIMESTAMP
  }

  entity npl_user_stories {
    * id : UUID <<PK>>
    --
    * project_id : UUID <<FK>>
    persona_ids : UUID[]
    * title : VARCHAR(500)
    story_text : TEXT
    description : TEXT
    priority : VARCHAR(20)
    * status : VARCHAR(30)
    story_points : INTEGER
    acceptance_criteria : JSONB
    tags : TEXT[]
    created_by : UUID
    * created_at : TIMESTAMP
    * updated_at : TIMESTAMP
    deleted_at : TIMESTAMP
  }
}

npl_projects ||--o{ npl_tool_sessions : "project_id"
npl_tool_sessions ||--o{ npl_tool_sessions : "parent_id"
npl_tool_sessions ||--o{ npl_instructions : "session_id"
npl_instructions ||--o{ npl_instruction_versions : "instruction_id"
npl_projects ||--o{ npl_user_personas : "project_id"
npl_projects ||--o{ npl_user_stories : "project_id"
@enduml
```

## Enum Types

### npl_element_type

```sql
CREATE TYPE npl_element_type AS ENUM (
  'concept', 'section', 'component', 'label', 'example', 'syntax'
);
```

> **Note**: Defined in changeset 001 but not currently referenced as a column type in any table.

## NPL Content Domain

Tables for storing parsed NPL language elements with vector embeddings for semantic search.

### npl_metadata

Key-value configuration and state store.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | VARCHAR(64) | No | — | Primary key |
| value | JSONB | No | — | Stored value |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |

**Indexes**: `idx_npl_metadata_updated_at` (updated_at)

### npl_component

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

### npl_sections

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

### npl_concepts

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

## Credentials Domain

### npl_secrets

Named credential store for API keys and tokens.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| name | VARCHAR(128) | No | — | Primary key (credential name) |
| value | TEXT | No | — | Credential value |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |

## Projects Domain

### npl_projects

Project container for scoping sessions, personas, and stories. ID is application-generated (UUID5 deterministic), not auto-generated.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | — | Primary key (app-generated UUID5) |
| name | VARCHAR(256) | No | — | Project name (unique) |
| title | TEXT | Yes | — | Display title |
| description | TEXT | Yes | — | Project description |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |
| deleted_at | TIMESTAMP | Yes | — | Soft delete marker |

**Constraints**: `name` UNIQUE

## Session Domain

### npl_tool_sessions

Agent session tracking scoped to projects, with optional parent hierarchy.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | gen_random_uuid() | Primary key |
| project_id | UUID | No | — | FK to npl_projects(id) |
| parent_id | UUID | Yes | — | Self-FK for session hierarchy |
| agent | VARCHAR(256) | No | — | Agent identifier |
| brief | TEXT | No | — | Session purpose |
| task | VARCHAR(512) | No | — | Task identifier |
| notes | TEXT | Yes | — | Appended session notes |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |

**Foreign Keys**: `fk_tool_sessions_project` (project_id) REFERENCES npl_projects(id), `fk_tool_sessions_parent` (parent_id) REFERENCES npl_tool_sessions(id)
**Constraints**: `uq_npl_tool_sessions_project_agent_task` UNIQUE (project_id, agent, task)

## Instructions Domain

Versioned instruction documents with active version pointer, optionally linked to a session.

### npl_instructions

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

### npl_instruction_versions

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

## Project Management Domain

Tables for user personas and user stories. Supports the feature implementation workflow (idea-to-spec pipeline). Scoped to projects via FK.

### npl_user_personas

Archetypal user personas linked to a project.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | gen_random_uuid() | Primary key |
| project_id | UUID | No | — | FK to npl_projects(id) |
| name | VARCHAR(255) | No | — | Persona name |
| role | VARCHAR(255) | Yes | — | Persona role |
| description | TEXT | Yes | — | Persona description |
| goals | TEXT | Yes | — | User goals |
| pain_points | TEXT | Yes | — | User pain points |
| behaviors | TEXT | Yes | — | Behavioral patterns |
| physical_description | TEXT | Yes | — | Physical appearance |
| persona_image | TEXT | Yes | — | Image URL or path |
| demographics | JSONB | Yes | — | Demographic data |
| created_by | UUID | Yes | — | Creator reference |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |
| deleted_at | TIMESTAMP | Yes | — | Soft delete marker |

**Foreign Key**: `fk_user_personas_project` (project_id) REFERENCES npl_projects(id)
**Indexes**: `idx_user_personas_project_id` (project_id), `idx_user_personas_deleted_at` (deleted_at — partial, WHERE deleted_at IS NULL)

### npl_user_stories

User stories with persona references and acceptance criteria.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | gen_random_uuid() | Primary key |
| project_id | UUID | No | — | FK to npl_projects(id) |
| persona_ids | UUID[] | Yes | — | Associated persona IDs |
| title | VARCHAR(500) | No | — | Story title |
| story_text | TEXT | Yes | — | "As a... I want... So that..." |
| description | TEXT | Yes | — | Additional details |
| priority | VARCHAR(20) | Yes | 'medium' | Priority level |
| status | VARCHAR(30) | No | 'draft' | Workflow status |
| story_points | INTEGER | Yes | — | Effort estimate |
| acceptance_criteria | JSONB | Yes | — | Acceptance criteria list |
| tags | TEXT[] | Yes | — | Categorization tags |
| created_by | UUID | Yes | — | Creator reference |
| created_at | TIMESTAMP | No | NOW() | Creation time |
| updated_at | TIMESTAMP | No | NOW() | Last modification |
| deleted_at | TIMESTAMP | Yes | — | Soft delete marker |

**Foreign Key**: `fk_user_stories_project` (project_id) REFERENCES npl_projects(id)
**Indexes**: `idx_user_stories_project_id` (project_id), `idx_user_stories_status` (status), `idx_user_stories_priority` (priority), `idx_user_stories_persona_ids` (persona_ids — GIN), `idx_user_stories_deleted_at` (deleted_at — partial, WHERE deleted_at IS NULL)

## Migration History

| Changeset | File | Description |
|-----------|------|-------------|
| 001 | changeset-001 | `npl_element_type` enum |
| 002 | changeset-001 | `npl_metadata` |
| 003 | changeset-001 | `npl_component` |
| 004 | changeset-001 | `npl_sections` |
| 005 | changeset-001 | `npl_concepts` |
| 006 | changeset-002 | `npl_secrets` |
| 007 | changeset-003 | `npl_tool_sessions` |
| 008 | changeset-004 | `npl_instructions` |
| 009 | changeset-004 | `npl_instruction_versions` |
| 010 | changeset-006 | `npl_projects` |
| 011 | changeset-006 | Seed legacy project |
| 012 | changeset-006 | Alter `npl_tool_sessions` — add project_id, parent_id |
| 013 | changeset-006 | Alter `npl_instructions` — add session_id |
| 014 | changeset-007 | `npl_user_personas` |
| 015 | changeset-007 | `npl_user_stories` |

## Design Notes

- **Soft deletes**: NPL content tables and project management tables use `deleted_at` rather than hard deletes
- **Vector search**: 1536-dimension embeddings with ivfflat indexes (cosine similarity, 100 lists) on content tables
- **Project scoping**: Sessions are scoped to projects via `project_id` FK; unique constraint is (project_id, agent, task). Instructions optionally linked to sessions via `session_id`
- **Session hierarchy**: `npl_tool_sessions.parent_id` is a self-FK enabling parent-child session trees
- **Timestamps**: All tables use `TIMESTAMP WITHOUT TIME ZONE` with `NOW()` defaults — application manages UTC. All tables use `updated_at` as the modification timestamp column
- **pgvector**: Required extension for `vector(1536)` columns and ivfflat indexes
- **Array columns**: `npl_user_stories.persona_ids` uses `UUID[]` with GIN index for containment queries; `npl_user_stories.tags` and `npl_instructions.tags` use `TEXT[]`
- **Partial indexes**: Project management tables use partial indexes on `deleted_at` (WHERE deleted_at IS NULL)
- **Seed data**: Legacy project (`abde7a0e-fe09-5a67-8e95-dd30da1862a2`, name=`legacy`) seeded by changeset 011 for backfilling pre-scoping sessions
