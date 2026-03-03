# Project Management Domain

Tables for user personas and user stories. Supports the feature implementation workflow (idea-to-spec pipeline). Scoped to projects via FK.

## npl_user_personas

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

## npl_user_stories

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
