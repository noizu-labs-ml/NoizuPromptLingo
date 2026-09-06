# Core Identity Domain (backend schema, changesets 000–010)

Base scaffold tables of the backend Postgres schema (`backend/db/changelog/`): infrastructure, versioned profile entities, auth, media, users, organizations. Soft-delete via `deleted_at` where present.

## Infrastructure

### seed_helper_records

Tracks idempotent seed execution by key + content hash.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | — | Primary key |
| key | VARCHAR(255) | No | — | Unique seed identifier |
| hash | VARCHAR(255) | Yes | — | Content hash for change detection |
| inserted_at | TIMESTAMP | Yes | — | Created timestamp |
| updated_at | TIMESTAMP | Yes | — | Modified timestamp |

**Constraints**: UNIQUE(key)

## Versioned Entities

Immutable-style records for user profile data.

### versioned_strings

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| content | TEXT | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | now() |
| updated_at | TIMESTAMPTZ | No | now() |

### versioned_names

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| first | VARCHAR(255) | Yes | — |
| middle | TEXT[] | Yes | '{}' |
| last | VARCHAR(255) | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | now() |
| updated_at | TIMESTAMPTZ | No | now() |

### versioned_descriptions

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| title | VARCHAR(255) | Yes | — |
| body | TEXT | Yes | — |
| deleted_at | TIMESTAMPTZ | Yes | — |
| inserted_at | TIMESTAMPTZ | No | now() |
| updated_at | TIMESTAMPTZ | No | now() |

## Auth

### auth_providers

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

## Media

### media

Uploaded file metadata. Linked to users via `user_media`. Extended by changesets 023–024 (visibility, short-id, variants cache).

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

## Users

### users

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

### user_media

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

### user_credentials

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

### user_sessions

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

## Organizations

### organizations

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| slug | CITEXT | No | — |
| name | VARCHAR(255) | No | — |
| settings | JSONB | Yes | '{}' |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

**Constraints**: UNIQUE(slug) — enforced again by changeset 082 (org-slug-uniqueness)

### memberships

Legacy membership table — migrated to PBAC model by changeset 021 (see [backend-domains.md](backend-domains.md)).

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | UUID | No | gen_random_uuid() |
| organization_id | UUID | No | — |
| user_id | UUID | No | — |
| role | VARCHAR(50) | No | 'viewer' |
| inserted_at | TIMESTAMPTZ | No | — |
| updated_at | TIMESTAMPTZ | No | — |

**Constraints**: uq_memberships_org_user (organization_id, user_id)
**FKs**: organization_id → organizations(id), user_id → users(id)

### invite_tokens

Extended by changeset 022 (enhance-invitations).

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
