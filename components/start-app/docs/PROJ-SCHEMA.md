# Database Schema — start-app

Schema for the start-app scaffold. Managed by Liquibase YAML changelogs (`backend/db/changelog/`). All tables use UUID primary keys and `timestamptz` timestamps with `now()` defaults.

## Extensions

| Extension | Purpose |
|-----------|---------|
| citext | Case-insensitive text (emails, usernames, slugs) |
| uuid-ossp | UUID generation |
| postgis | Geospatial queries |
| vector | pgvector embeddings |
| cube | Multi-dimensional indexing (used by earthdistance) |
| pg_trgm | Trigram similarity search |
| earthdistance | Geographic distance calculations |

## Enum Types

| Enum | Values |
|------|--------|
| `status_enum` | active, disabled, suspended, deleted, other |
| `user_status_enum` | active, unverified, waitlist, suspended, deleted, other |
| `credential_status_enum` | active, disabled, suspended, deleted, other |
| `session_status_enum` | active, revoked, disabled, suspended, deleted, other |
| `media_type_enum` | image, video, audio, document, other |
| `file_type_enum` | jpg, jpeg, png, gif, webp, svg, bmp, ico, tiff, mp4, avi, mov, webm, mp3, wav, ogg, pdf, doc, other |
| `owner_type_enum` | user, organization, other |
| `credential_type_enum` | login, oauth, smart_link, other |
| `device_type_enum` | web, ios, android, other |

## ERD — Mermaid

```mermaid
erDiagram
    users ||--o| versioned_names : "name_id"
    users ||--o| versioned_descriptions : "description_id"
    users ||--o{ user_credentials : "has many"
    users ||--o{ user_sessions : "has many"
    users ||--o{ user_media : "has many"
    users ||--o{ memberships : "belongs to orgs"
    users ||--o{ invite_tokens : "creates"

    user_credentials }o--|| auth_providers : "uses"
    user_credentials ||--o{ user_sessions : "creates"

    user_media }o--|| media : "references"
    user_media }o--o| versioned_descriptions : "description_id"

    organizations ||--o{ memberships : "has members"
    organizations ||--o{ invite_tokens : "scoped to"

    seed_helper_records {
        UUID id PK
        VARCHAR_255 key
        VARCHAR_255 hash
        TIMESTAMP inserted_at
        TIMESTAMP updated_at
    }

    versioned_strings {
        UUID id PK
        TEXT content
        TIMESTAMPTZ deleted_at
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    versioned_names {
        UUID id PK
        VARCHAR_255 first
        TEXT_ARRAY middle
        VARCHAR_255 last
        TIMESTAMPTZ deleted_at
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    versioned_descriptions {
        UUID id PK
        VARCHAR_255 title
        TEXT body
        TIMESTAMPTZ deleted_at
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    auth_providers {
        UUID id PK
        VARCHAR_255 title
        TEXT description
        TEXT settings
        TIMESTAMPTZ deleted_at
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    media {
        UUID id PK
        media_type_enum media_type
        file_type_enum file_type
        VARCHAR_512 file
        BOOLEAN flagged
        JSONB settings
        TIMESTAMPTZ deleted_at
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    users {
        UUID id PK
        CITEXT user_name
        CITEXT handle
        UUID name_id FK
        UUID description_id FK
        CITEXT email
        VARCHAR_255 hashed_password
        user_status_enum status
        BOOLEAN verified
        BOOLEAN flagged
        TIMESTAMPTZ deleted_at
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    user_media {
        UUID id PK
        UUID user_id FK
        UUID media_id FK
        UUID description_id FK
        media_type_enum media_type
        JSONB settings
        TIMESTAMPTZ deleted_at
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    user_credentials {
        UUID id PK
        UUID user_id FK
        UUID auth_provider_id FK
        UUID description_id FK
        credential_status_enum status
        JSONB settings
        JSONB state
        VARCHAR_255 fingerprint
        TIMESTAMPTZ deleted_at
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    user_sessions {
        UUID id PK
        UUID user_id FK
        UUID credential_id FK
        session_status_enum status
        JSONB details
        TIMESTAMPTZ deleted_at
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    organizations {
        UUID id PK
        CITEXT slug
        VARCHAR_255 name
        JSONB settings
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    memberships {
        UUID id PK
        UUID organization_id FK
        UUID user_id FK
        VARCHAR_50 role
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }

    invite_tokens {
        UUID id PK
        UUID organization_id FK
        UUID created_by_user_id FK
        VARCHAR_255 token_hash
        VARCHAR_10 key_prefix
        CITEXT email
        INTEGER max_uses
        INTEGER uses
        TIMESTAMPTZ expires_at
        BOOLEAN revoked
        TIMESTAMPTZ inserted_at
        TIMESTAMPTZ updated_at
    }
```

## ERD — PlantUML

```plantuml
@startuml
!define TABLE(name) entity name <<(T,#FFAAAA)>>
skinparam linetype ortho

package "Infrastructure" {
  TABLE(seed_helper_records) {
    * id : UUID <<PK>>
    --
    * key : VARCHAR(255) <<UNIQUE>>
    hash : VARCHAR(255)
    inserted_at : TIMESTAMP
    updated_at : TIMESTAMP
  }
}

package "Versioned Entities" {
  TABLE(versioned_strings) {
    * id : UUID <<PK>>
    --
    content : TEXT
    deleted_at : TIMESTAMPTZ
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }

  TABLE(versioned_names) {
    * id : UUID <<PK>>
    --
    first : VARCHAR(255)
    middle : TEXT[]
    last : VARCHAR(255)
    deleted_at : TIMESTAMPTZ
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }

  TABLE(versioned_descriptions) {
    * id : UUID <<PK>>
    --
    title : VARCHAR(255)
    body : TEXT
    deleted_at : TIMESTAMPTZ
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }
}

package "Auth" {
  TABLE(auth_providers) {
    * id : UUID <<PK>>
    --
    title : VARCHAR(255)
    description : TEXT
    settings : TEXT
    deleted_at : TIMESTAMPTZ
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }
}

package "Media" {
  TABLE(media) {
    * id : UUID <<PK>>
    --
    * media_type : media_type_enum
    * file_type : file_type_enum
    file : VARCHAR(512)
    flagged : BOOLEAN
    settings : JSONB
    deleted_at : TIMESTAMPTZ
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }
}

package "Users" {
  TABLE(users) {
    * id : UUID <<PK>>
    --
    user_name : CITEXT <<UNIQUE>>
    handle : CITEXT <<UNIQUE>>
    name_id : UUID <<FK>>
    description_id : UUID <<FK>>
    * email : CITEXT <<UNIQUE>>
    hashed_password : VARCHAR(255)
    * status : user_status_enum
    verified : BOOLEAN
    flagged : BOOLEAN
    deleted_at : TIMESTAMPTZ
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }

  TABLE(user_media) {
    * id : UUID <<PK>>
    --
    * user_id : UUID <<FK>>
    * media_id : UUID <<FK>>
    description_id : UUID <<FK>>
    media_type : media_type_enum
    settings : JSONB
    deleted_at : TIMESTAMPTZ
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }

  TABLE(user_credentials) {
    * id : UUID <<PK>>
    --
    * user_id : UUID <<FK>>
    * auth_provider_id : UUID <<FK>>
    description_id : UUID <<FK>>
    * status : credential_status_enum
    settings : JSONB
    state : JSONB
    fingerprint : VARCHAR(255)
    deleted_at : TIMESTAMPTZ
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }

  TABLE(user_sessions) {
    * id : UUID <<PK>>
    --
    * user_id : UUID <<FK>>
    credential_id : UUID <<FK>>
    * status : session_status_enum
    details : JSONB
    deleted_at : TIMESTAMPTZ
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }
}

package "Organizations" {
  TABLE(organizations) {
    * id : UUID <<PK>>
    --
    * slug : CITEXT <<UNIQUE>>
    * name : VARCHAR(255)
    settings : JSONB
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }

  TABLE(memberships) {
    * id : UUID <<PK>>
    --
    * organization_id : UUID <<FK>>
    * user_id : UUID <<FK>>
    * role : VARCHAR(50)
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }

  TABLE(invite_tokens) {
    * id : UUID <<PK>>
    --
    organization_id : UUID <<FK>>
    created_by_user_id : UUID <<FK>>
    * token_hash : VARCHAR(255) <<UNIQUE>>
    * key_prefix : VARCHAR(10)
    email : CITEXT
    max_uses : INTEGER
    * uses : INTEGER
    expires_at : TIMESTAMPTZ
    revoked : BOOLEAN
    * inserted_at : TIMESTAMPTZ
    * updated_at : TIMESTAMPTZ
  }
}

users }o--o| versioned_names : "name_id"
users }o--o| versioned_descriptions : "description_id"
users ||--o{ user_credentials : "has many"
users ||--o{ user_sessions : "has many"
users ||--o{ user_media : "has many"
users ||--o{ memberships : "belongs to orgs"
users ||--o{ invite_tokens : "creates"

user_credentials }o--|| auth_providers : "uses"
user_credentials ||--o{ user_sessions : "creates"

user_media }o--|| media : "references"
user_media }o--o| versioned_descriptions : "description_id"

organizations ||--o{ memberships : "has members"
organizations ||--o{ invite_tokens : "scoped to"
@enduml
```

## Table Details

### Infrastructure

#### seed_helper_records

Tracks idempotent seed execution by key + content hash.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | — | Primary key |
| key | VARCHAR(255) | No | — | Unique seed identifier |
| hash | VARCHAR(255) | Yes | — | Content hash for change detection |
| inserted_at | TIMESTAMP | Yes | — | Created timestamp |
| updated_at | TIMESTAMP | Yes | — | Modified timestamp |

**Constraints**: UNIQUE(key)

### Versioned Entities

Immutable-style records for user profile data. Soft-deletable via `deleted_at`.

#### versioned_strings

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| content | TEXT | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | now() |
| updated_at | TIMESTAMPTZ | No | now() |

#### versioned_names

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| first | VARCHAR(255) | Yes | — |
| middle | TEXT[] | Yes | '{}' |
| last | VARCHAR(255) | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | now() |
| updated_at | TIMESTAMPTZ | No | now() |

#### versioned_descriptions

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| title | VARCHAR(255) | Yes | — |
| body | TEXT | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | now() |
| updated_at | TIMESTAMPTZ | No | now() |

### Auth

#### auth_providers

Registry of authentication providers (login, OAuth, SSO). Seeded at startup.

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| title | VARCHAR(255) | Yes | — |
| description | TEXT | Yes | — |
| settings | TEXT | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

### Media

#### media

Uploaded file metadata. Linked to users via `user_media`.

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| media_type | media_type_enum | No | — |
| file_type | file_type_enum | No | — |
| file | VARCHAR(512) | Yes | — |
| flagged | BOOLEAN | Yes | false |
| settings | JSONB | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

### Users

#### users

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| user_name | CITEXT | Yes | — |
| handle | CITEXT | Yes | — |
| name_id | UUID | Yes | — |
| description_id | UUID | Yes | — |
| email | CITEXT | No | — |
| hashed_password | VARCHAR(255) | Yes | — |
| status | user_status_enum | No | 'active' |
| verified | BOOLEAN | Yes | false |
| flagged | BOOLEAN | Yes | false |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

**Indexes**: idx_users_email (email, UNIQUE), idx_users_user_name (user_name, UNIQUE), idx_users_handle (handle, UNIQUE)
**FKs**: name_id → versioned_names(id), description_id → versioned_descriptions(id)

#### user_media

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| user_id | UUID | No | — |
| media_id | UUID | No | — |
| description_id | UUID | Yes | — |
| media_type | media_type_enum | Yes | — |
| settings | JSONB | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

**Indexes**: idx_user_media_user_id (user_id)
**FKs**: user_id → users(id), media_id → media(id), description_id → versioned_descriptions(id)

#### user_credentials

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| user_id | UUID | No | — |
| auth_provider_id | UUID | No | — |
| description_id | UUID | Yes | — |
| status | credential_status_enum | No | 'active' |
| settings | JSONB | Yes | — |
| state | JSONB | Yes | — |
| fingerprint | VARCHAR(255) | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

**Indexes**: idx_user_credentials_user_provider (user_id, auth_provider_id)
**FKs**: user_id → users(id), auth_provider_id → auth_providers(id), description_id → versioned_descriptions(id)

#### user_sessions

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| user_id | UUID | No | — |
| credential_id | UUID | Yes | — |
| status | session_status_enum | No | 'active' |
| details | JSONB | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

**Indexes**: idx_user_sessions_user_id (user_id)
**FKs**: user_id → users(id), credential_id → user_credentials(id)

### Organizations

#### organizations

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| slug | CITEXT | No | — |
| name | VARCHAR(255) | No | — |
| settings | JSONB | Yes | '{}' |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

**Constraints**: UNIQUE(slug)

#### memberships

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| organization_id | UUID | No | — |
| user_id | UUID | No | — |
| role | VARCHAR(50) | No | 'viewer' |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

**Constraints**: uq_memberships_org_user (organization_id, user_id) — one membership per user per org
**FKs**: organization_id → organizations(id), user_id → users(id)

#### invite_tokens

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| organization_id | UUID | Yes | — |
| created_by_user_id | UUID | Yes | — |
| token_hash | VARCHAR(255) | No | — |
| key_prefix | VARCHAR(10) | No | — |
| email | CITEXT | Yes | — |
| max_uses | INTEGER | Yes | — |
| uses | INTEGER | No | 0 |
| expires_at | TIMESTAMPTZ | Yes | — |
| revoked | BOOLEAN | Yes | false |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

**Indexes**: idx_invite_tokens_key_prefix (key_prefix), idx_invite_tokens_token_hash (token_hash, UNIQUE)
**FKs**: organization_id → organizations(id), created_by_user_id → users(id)

## Changeset Reference

| Changeset | File | Tables/Objects |
|-----------|------|----------------|
| 000 | extensions | citext, uuid-ossp, postgis, vector, cube, pg_trgm, earthdistance |
| 001 | enums | 9 enum types |
| 002 | seed-helper | seed_helper_records |
| 003 | versioned-entities | versioned_strings, versioned_names, versioned_descriptions |
| 004 | auth-providers | auth_providers |
| 005 | media | media |
| 006 | users | users + 3 indexes |
| 007 | user-media | user_media + 1 index |
| 008 | credentials-sessions | user_credentials + 1 index, user_sessions + 1 index |
| 009 | organizations | organizations, memberships + unique constraint |
| 010 | invite-tokens | invite_tokens + 2 indexes |
