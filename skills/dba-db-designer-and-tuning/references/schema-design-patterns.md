# Schema Design Patterns

> A PostgreSQL-first reference for schema design decisions that come up repeatedly. Real SQL, real trade-offs, no hand-waving. The kind of doc you bookmark and revisit when you're staring at a `CREATE TABLE` and thinking "there has to be a better way."

---

## Table of Contents

1. [Normalization Decision Framework](#normalization-decision-framework)
2. [Common Schema Patterns](#common-schema-patterns)
   - [Polymorphic Associations](#polymorphic-associations)
   - [Temporal Data](#temporal-data)
   - [Hierarchical Data](#hierarchical-data)
   - [Multi-Tenancy](#multi-tenancy)
   - [Soft Deletes](#soft-deletes)
   - [Audit Logging](#audit-logging)
   - [Tags and Categories](#tags-and-categories)
   - [EAV vs. JSONB](#eav-vs-jsonb)
   - [UUID vs. Serial Primary Keys](#uuid-vs-serial-primary-keys)
3. [PostgreSQL-Specific Types](#postgresql-specific-types)
4. [Constraint Design](#constraint-design)
5. [Anti-Pattern Catalog](#anti-pattern-catalog)

---

## Normalization Decision Framework

The textbook answer is "normalize to 3NF, then denormalize for performance." The real answer is that denormalization is a trade-off you choose deliberately, not a shortcut you take because joins feel hard.

### Decision Table

| Scenario | Recommendation | Trade-off |
|----------|---------------|-----------|
| Data has clear entity boundaries (users, orders, products) | Normalize to 3NF | More joins, but updates are atomic and consistent |
| Read-heavy dashboards, analytics queries | Denormalize into materialized views or summary tables | Stale reads (refresh lag), extra storage, update complexity |
| Write-heavy OLTP with strict consistency | Normalize; use indexes aggressively | Join cost is real but predictable; index maintenance on writes |
| Frequently accessed composite data (e.g., "order with line items and shipping") | Normalize storage, denormalize the read path with views or JSONB columns | Two representations to keep in sync |
| Append-only event data (logs, metrics, activity feeds) | Denormalize at write time; events are immutable so update anomalies don't apply | Larger row size, but no update anomalies by definition |
| Data shared across many tables (e.g., addresses used by users, warehouses, vendors) | Normalize into a shared table with FKs | Join cost, but single source of truth for address validation/formatting |
| Rapidly evolving schema during early product development | Use JSONB for the volatile parts, normalize the stable parts | JSONB fields are harder to constrain, migrate, and index meaningfully |
| Reporting across multiple source tables | Create materialized views; refresh on schedule or via triggers | Refresh cost, potential staleness, but fast reads |
| High-cardinality many-to-many (e.g., user-permission, product-tag) | Normalize with a join table; never flatten into arrays in the parent | Array columns break referential integrity and make updates painful |
| Caching derived values (e.g., `order_total`, `comment_count`) | Store the derived value + maintain via trigger or application logic | Must handle staleness; triggers add write overhead |

### The Denormalization Checklist

Before denormalizing, answer all five:

1. **Have you measured the join cost?** `EXPLAIN ANALYZE` the actual query. If the join takes 2ms, denormalizing saves you nothing and costs you consistency.
2. **Is the data immutable or append-only?** Denormalization is safest when you never update the duplicated data.
3. **Can you tolerate staleness?** If the answer is "no," you need triggers or application-level sync, which often costs more than the join you're avoiding.
4. **Who maintains consistency?** Every denormalized column needs an owner: a trigger, a background job, or application code that keeps it in sync.
5. **What happens when the source of truth changes?** If you denormalize `user.display_name` into `comments`, what happens when the user changes their name? Do you backfill? Accept drift?

---

## Common Schema Patterns

### Polymorphic Associations

The problem: multiple tables need to reference different types of "parent" records. A `comments` table that can belong to a `post`, an `issue`, or a `pull_request`.

#### Option 1: Single Table Inheritance (STI)

All types share one table, differentiated by a discriminator column.

```sql
CREATE TABLE notifications (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type          text NOT NULL CHECK (type IN ('email', 'sms', 'push', 'webhook')),
    recipient     text NOT NULL,
    subject       text,          -- NULL for sms/push
    body          text NOT NULL,
    phone_number  text,          -- NULL for email/webhook
    device_token  text,          -- NULL for email/sms/webhook
    webhook_url   text,          -- NULL for email/sms/push
    sent_at       timestamptz,
    created_at    timestamptz NOT NULL DEFAULT now()
);

-- Enforce type-specific constraints
ALTER TABLE notifications ADD CONSTRAINT chk_email
    CHECK (type <> 'email' OR (subject IS NOT NULL AND phone_number IS NULL AND device_token IS NULL AND webhook_url IS NULL));
ALTER TABLE notifications ADD CONSTRAINT chk_sms
    CHECK (type <> 'sms' OR (phone_number IS NOT NULL AND subject IS NULL AND device_token IS NULL AND webhook_url IS NULL));
ALTER TABLE notifications ADD CONSTRAINT chk_push
    CHECK (type <> 'push' OR (device_token IS NOT NULL AND subject IS NULL AND phone_number IS NULL AND webhook_url IS NULL));
ALTER TABLE notifications ADD CONSTRAINT chk_webhook
    CHECK (type <> 'webhook' OR (webhook_url IS NOT NULL AND subject IS NULL AND phone_number IS NULL AND device_token IS NULL));
```

**When to use:** Few types, mostly shared columns, you query across types often.
**Trade-off:** NULLable columns proliferate. CHECK constraints get verbose. Adding a type means ALTERing the table.

#### Option 2: Class Table Inheritance (CTI)

Shared columns in a base table, type-specific columns in child tables.

```sql
CREATE TABLE notifications (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type          text NOT NULL CHECK (type IN ('email', 'sms', 'push', 'webhook')),
    recipient     text NOT NULL,
    body          text NOT NULL,
    sent_at       timestamptz,
    created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE notification_emails (
    notification_id bigint PRIMARY KEY REFERENCES notifications(id) ON DELETE CASCADE,
    subject         text NOT NULL,
    cc              text[],
    reply_to        text
);

CREATE TABLE notification_sms (
    notification_id bigint PRIMARY KEY REFERENCES notifications(id) ON DELETE CASCADE,
    phone_number    text NOT NULL,
    carrier         text
);

CREATE TABLE notification_push (
    notification_id bigint PRIMARY KEY REFERENCES notifications(id) ON DELETE CASCADE,
    device_token    text NOT NULL,
    badge_count     int DEFAULT 0
);

CREATE TABLE notification_webhooks (
    notification_id bigint PRIMARY KEY REFERENCES notifications(id) ON DELETE CASCADE,
    webhook_url     text NOT NULL,
    secret          text,
    retry_count     int DEFAULT 0
);
```

**When to use:** Types have significantly different columns. You need to query across all types (via the base table) AND query type-specific data efficiently.
**Trade-off:** Requires a join to get the full record. Inserts touch two tables (use a transaction).

#### Option 3: Exclusive Belongs-To (No Base Table)

The polymorphic side stores nullable FKs for each possible parent. Exactly one must be non-NULL.

```sql
CREATE TABLE comments (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    body            text NOT NULL,
    author_id       bigint NOT NULL REFERENCES users(id),
    post_id         bigint REFERENCES posts(id) ON DELETE CASCADE,
    issue_id        bigint REFERENCES issues(id) ON DELETE CASCADE,
    pull_request_id bigint REFERENCES pull_requests(id) ON DELETE CASCADE,
    created_at      timestamptz NOT NULL DEFAULT now(),

    -- Exactly one parent must be set
    CONSTRAINT chk_single_parent CHECK (
        num_nonnulls(post_id, issue_id, pull_request_id) = 1
    )
);

-- Partial indexes for each parent type (sparse, efficient)
CREATE INDEX idx_comments_post ON comments(post_id) WHERE post_id IS NOT NULL;
CREATE INDEX idx_comments_issue ON comments(issue_id) WHERE issue_id IS NOT NULL;
CREATE INDEX idx_comments_pr ON comments(pull_request_id) WHERE pull_request_id IS NOT NULL;
```

**When to use:** Small number of parent types (2-5). You want real FK constraints. You query by parent type, not across all comments generically.
**Trade-off:** Adding a new parent type requires `ALTER TABLE ADD COLUMN`. Columns are mostly NULL. But you get referential integrity, which the "type + type_id" anti-pattern does not.

#### Option 4: Enum-Typed Dual-Key Poly Join (Preferred for extensible systems)

When the number of parent/member types will grow and you need a single join table that can attach any entity to any other entity. Uses PostgreSQL enums for the type discriminator instead of free-text, giving compile-time type safety and preventing orphaned type strings.

```sql
-- Type-safe enums
CREATE TYPE resource_type_enum AS ENUM ('organization', 'project');
CREATE TYPE member_type_enum AS ENUM ('user', 'group');

CREATE TABLE scoped_memberships (
    id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    group_id        UUID NOT NULL REFERENCES groups(id),
    resource_type   resource_type_enum NOT NULL,
    resource_id     UUID NOT NULL,
    member_type     member_type_enum NOT NULL,
    member_id       UUID NOT NULL,
    expires_at      TIMESTAMPTZ,
    added_by        UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- One membership per entity pair per resource
    CONSTRAINT uk_scoped_membership_resource_member
        UNIQUE (resource_type, resource_id, member_type, member_id)
);

-- Composite indexes on (type, id) pairs for fast lookups
CREATE INDEX idx_scoped_memberships_resource
    ON scoped_memberships (resource_type, resource_id);
CREATE INDEX idx_scoped_memberships_member
    ON scoped_memberships (member_type, member_id);
CREATE INDEX idx_scoped_memberships_expires
    ON scoped_memberships (expires_at) WHERE expires_at IS NOT NULL;
```

**Query pattern — conditional LEFT JOIN on discriminator:**

```sql
SELECT sm.*, g.name AS role_name,
       CASE WHEN sm.member_type = 'user' THEN u.email ELSE NULL END AS member_email,
       CASE WHEN sm.member_type = 'user' THEN u.name  ELSE NULL END AS member_name
FROM scoped_memberships sm
JOIN groups g ON sm.group_id = g.id
LEFT JOIN users u ON sm.member_type = 'user' AND sm.member_id = u.id
WHERE sm.resource_type = 'organization' AND sm.resource_id = $1
  AND (sm.expires_at IS NULL OR sm.expires_at > NOW())
ORDER BY g.name, sm.created_at;
```

**Atomic operations via stored procedures:**

```sql
CREATE OR REPLACE FUNCTION add_scoped_member(
    p_resource_type resource_type_enum,
    p_resource_id   UUID,
    p_user_id       UUID,
    p_role_name     role_name_enum,
    p_added_by      UUID DEFAULT NULL
) RETURNS scoped_memberships LANGUAGE plpgsql AS $$
DECLARE
    v_group_id UUID;
    v_result   scoped_memberships;
BEGIN
    SELECT id INTO v_group_id FROM groups WHERE name = p_role_name::text;
    IF v_group_id IS NULL THEN
        RAISE EXCEPTION 'Invalid role: %', p_role_name USING ERRCODE = 'P0002';
    END IF;
    IF EXISTS (
        SELECT 1 FROM scoped_memberships
        WHERE resource_type = p_resource_type AND resource_id = p_resource_id
          AND member_type = 'user' AND member_id = p_user_id
    ) THEN
        RAISE EXCEPTION 'User is already a member' USING ERRCODE = 'P0004';
    END IF;
    INSERT INTO scoped_memberships
        (group_id, resource_type, resource_id, member_type, member_id, added_by)
    VALUES
        (v_group_id, p_resource_type, p_resource_id, 'user', p_user_id, p_added_by)
    RETURNING * INTO v_result;
    RETURN v_result;
END; $$;
```

**Deterministic UUIDs for template entities** (no seeding required):

```sql
-- Predictable IDs computed from (type, name) — same in every environment
SELECT uuid_generate_v5(uuid_ns_dns(), 'group:owner')  AS owner_group_id;
SELECT uuid_generate_v5(uuid_ns_dns(), 'group:admin')  AS admin_group_id;
SELECT uuid_generate_v5(uuid_ns_dns(), 'group:member') AS member_group_id;
```

**When to use:** You have an Elixir/Phoenix or similar framework with libraries that facilitate polymorphic joins. The number of parent types will grow over time. You need notes, tags, memberships, policies, or audit logs attachable to any entity type. You want a single generic table rather than N exclusive-FK columns.

**Why this works where Rails polymorphic fails:**
- PostgreSQL enums prevent type string drift — adding a new type requires `ALTER TYPE ... ADD VALUE`, which is an explicit, migration-tracked schema change
- Composite indexes on `(type, id)` make lookups fast
- Stored procedures enforce business rules atomically
- Conditional LEFT JOINs on the discriminator keep queries clean
- The UNIQUE constraint on `(resource_type, resource_id, member_type, member_id)` prevents duplicates

**Trade-off:** No FK from `resource_id` to the actual parent table (same as Rails polymorphic). Mitigated by: enum type safety, application-layer validation, and cascade triggers that use the type discriminator for conditional cleanup. If you need hard FK integrity and have ≤5 parent types, use Option 3 (exclusive belongs-to) instead.

#### The Naive Anti-Pattern: Free-Text `commentable_type` + `commentable_id`

```sql
-- DO NOT DO THIS — no enum, no type safety, no constraint on type values
CREATE TABLE comments (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    commentable_type  text NOT NULL,  -- 'Post', 'Issue', 'PullRequest'
    commentable_id    bigint NOT NULL, -- FK to... somewhere
    body              text NOT NULL
);
```

This is Rails' `polymorphic: true`. It looks clean. It has zero referential integrity AND zero type safety. You cannot create a foreign key from `commentable_id` to "whatever table `commentable_type` says." Type strings drift. Orphaned rows are inevitable. If you must use dual-key polymorphism, use Option 4 with PostgreSQL enums, not free-text strings.

---

### Temporal Data

#### SCD Type 1: Overwrite

Just update the row. No history.

```sql
CREATE TABLE products (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name    text NOT NULL,
    price   numeric(10,2) NOT NULL
);

-- Price change: just UPDATE
UPDATE products SET price = 29.99 WHERE id = 42;
```

**When to use:** You genuinely don't care about history. Lookup tables, user preferences, config values.

#### SCD Type 2: Row-Per-Version

Each change creates a new row. The current version is identified by a validity range.

```sql
CREATE TABLE product_prices (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id  bigint NOT NULL REFERENCES products(id),
    price       numeric(10,2) NOT NULL,
    valid_from  timestamptz NOT NULL DEFAULT now(),
    valid_to    timestamptz,  -- NULL = current

    -- No two versions of the same product can overlap
    CONSTRAINT no_overlap EXCLUDE USING gist (
        product_id WITH =,
        tstzrange(valid_from, valid_to, '[)') WITH &&
    )
);

-- The "current" price
CREATE VIEW current_product_prices AS
SELECT DISTINCT ON (product_id) *
FROM product_prices
WHERE valid_to IS NULL OR valid_to > now()
ORDER BY product_id, valid_from DESC;
```

**When to use:** You need full history and "as-of" queries. Financial data, pricing, compliance-sensitive records.
**Trade-off:** Table grows with every change. Queries need range filters. Updates require closing the old row and inserting a new one (do this in a transaction).

Note: the `EXCLUDE` constraint above requires the `btree_gist` extension:

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;
```

#### SCD Type 3: Previous-Value Column

Store the current and immediately prior value in the same row.

```sql
CREATE TABLE employees (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                text NOT NULL,
    department          text NOT NULL,
    previous_department text,
    department_changed  timestamptz
);
```

**When to use:** You only need one level of history and it's for a specific column. Rare in practice; usually you either need no history (Type 1) or full history (Type 2).

#### Bitemporal

Two time axes: *valid time* (when the fact is true in the real world) and *transaction time* (when the database learned about it).

```sql
CREATE TABLE insurance_policies (
    id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    policy_number     text NOT NULL,
    holder_name       text NOT NULL,
    coverage_amount   numeric(12,2) NOT NULL,

    -- Valid time: when this coverage is effective in reality
    valid_from        date NOT NULL,
    valid_to          date,

    -- Transaction time: when this row was recorded/superseded in the DB
    recorded_at       timestamptz NOT NULL DEFAULT now(),
    superseded_at     timestamptz,  -- NULL = current knowledge

    CONSTRAINT no_valid_overlap EXCLUDE USING gist (
        policy_number WITH =,
        daterange(valid_from, valid_to, '[)') WITH &&
    ) WHERE (superseded_at IS NULL)
);

-- "What did we believe on March 1 about coverage effective Jan 15?"
SELECT * FROM insurance_policies
WHERE policy_number = 'POL-2024-001'
  AND recorded_at <= '2024-03-01'
  AND (superseded_at IS NULL OR superseded_at > '2024-03-01')
  AND valid_from <= '2024-01-15'
  AND (valid_to IS NULL OR valid_to > '2024-01-15');
```

**When to use:** Regulated industries (insurance, finance, healthcare) where you need to answer "what did we know and when did we know it." Auditors love this. Developers do not.

#### Event Sourcing (Append-Only)

Store events, derive state. The event log is the source of truth.

```sql
CREATE TABLE account_events (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id  uuid NOT NULL,
    event_type  text NOT NULL CHECK (event_type IN ('opened', 'deposited', 'withdrawn', 'closed')),
    amount      numeric(12,2),
    metadata    jsonb DEFAULT '{}',
    occurred_at timestamptz NOT NULL DEFAULT now()
);

-- Derive current balance from events
CREATE MATERIALIZED VIEW account_balances AS
SELECT
    account_id,
    coalesce(sum(
        CASE event_type
            WHEN 'deposited' THEN amount
            WHEN 'withdrawn' THEN -amount
            ELSE 0
        END
    ), 0) AS balance,
    max(occurred_at) AS last_activity
FROM account_events
GROUP BY account_id;

CREATE UNIQUE INDEX ON account_balances(account_id);
```

**When to use:** Financial systems, audit-critical workflows, systems where "undo" and "replay" matter. Pairs well with CQRS.
**Trade-off:** Querying current state requires aggregation or materialized views. Event tables grow fast. Snapshots help (periodically materialize state and replay only from the snapshot).

---

### Hierarchical Data

#### Adjacency List

The simplest model. Each row points to its parent.

```sql
CREATE TABLE categories (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        text NOT NULL,
    parent_id   bigint REFERENCES categories(id),
    sort_order  int DEFAULT 0
);

CREATE INDEX idx_categories_parent ON categories(parent_id);

-- Direct children of "Electronics"
SELECT * FROM categories WHERE parent_id = 1;

-- Full subtree using recursive CTE
WITH RECURSIVE tree AS (
    SELECT id, name, parent_id, 0 AS depth, ARRAY[id] AS path
    FROM categories WHERE id = 1

    UNION ALL

    SELECT c.id, c.name, c.parent_id, t.depth + 1, t.path || c.id
    FROM categories c
    JOIN tree t ON c.parent_id = t.id
)
SELECT * FROM tree ORDER BY path;
```

**When to use:** Trees that are frequently modified (nodes added, moved, deleted). Moderate depth (< 20 levels). Most common and most maintainable.
**Trade-off:** Fetching the full subtree requires a recursive CTE. Performance degrades with very deep trees or very wide trees (thousands of children).

#### Materialized Path

Store the full ancestor path as a string.

```sql
CREATE TABLE categories (
    id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  text NOT NULL,
    path  text NOT NULL  -- e.g., '1.5.12.47'
);

CREATE INDEX idx_categories_path ON categories USING btree (path text_pattern_ops);

-- All descendants of node 5 (path starts with '1.5.')
SELECT * FROM categories WHERE path LIKE '1.5.%';

-- Depth of a node
SELECT (length(path) - length(replace(path, '.', ''))) AS depth
FROM categories WHERE id = 47;
```

**When to use:** Read-heavy trees where you need fast subtree queries. Breadcrumbs in a UI. URL path structures.
**Trade-off:** Moving a node means updating every descendant's path. Path strings can get long for deep trees.

#### ltree (PostgreSQL Extension)

PostgreSQL's built-in label tree type. Like materialized path, but with proper operators and GiST indexing.

```sql
CREATE EXTENSION IF NOT EXISTS ltree;

CREATE TABLE categories (
    id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  text NOT NULL,
    path  ltree NOT NULL
);

CREATE INDEX idx_categories_ltree ON categories USING gist (path);

-- Insert a hierarchy
INSERT INTO categories (name, path) VALUES
    ('Electronics',         'electronics'),
    ('Computers',           'electronics.computers'),
    ('Laptops',             'electronics.computers.laptops'),
    ('Gaming Laptops',      'electronics.computers.laptops.gaming'),
    ('Phones',              'electronics.phones'),
    ('Cameras',             'electronics.cameras'),
    ('DSLR',                'electronics.cameras.dslr');

-- All descendants of electronics.computers
SELECT * FROM categories WHERE path <@ 'electronics.computers';

-- All ancestors of electronics.computers.laptops.gaming
SELECT * FROM categories WHERE path @> 'electronics.computers.laptops.gaming';

-- Direct children only (depth = 1 below)
SELECT * FROM categories
WHERE path ~ 'electronics.computers.*{1}';

-- Depth of each node
SELECT name, nlevel(path) AS depth FROM categories;
```

**When to use:** Same as materialized path, but you want proper operators, GiST indexes, and pattern matching. Strongly preferred over hand-rolled materialized paths in PostgreSQL.
**Trade-off:** Labels are restricted to `[a-zA-Z0-9_]` and can't contain dots (dots are path separators). Still has the "move requires update of descendants" problem.

#### Nested Set

Each node stores `lft` and `rgt` values. A node's descendants are all nodes where `lft > parent.lft AND rgt < parent.rgt`.

```sql
CREATE TABLE categories (
    id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  text NOT NULL,
    lft   int NOT NULL,
    rgt   int NOT NULL
);

CREATE INDEX idx_categories_lft_rgt ON categories(lft, rgt);

-- Example tree:
-- Electronics (1, 14)
--   Computers (2, 7)
--     Laptops (3, 4)
--     Desktops (5, 6)
--   Phones (8, 11)
--     Smartphones (9, 10)
--   Cameras (12, 13)

-- All descendants of Computers (lft=2, rgt=7)
SELECT * FROM categories WHERE lft > 2 AND rgt < 7;

-- Count of descendants
SELECT (rgt - lft - 1) / 2 AS descendant_count FROM categories WHERE id = 1;
```

**When to use:** Read-heavy trees that almost never change structure. Subtree queries are a simple range scan. Counting descendants is arithmetic.
**Trade-off:** Inserting or moving a node requires renumbering potentially every row in the table. Concurrent modifications are nightmarish. Rarely the right choice in OLTP systems.

#### Recommendation

| Need | Use |
|------|-----|
| General purpose, moderate writes | Adjacency list + recursive CTE |
| Fast subtree reads in PostgreSQL | ltree |
| URL-like paths, breadcrumbs | Materialized path or ltree |
| Read-only reference data | Nested set |
| Maximum flexibility, all operations | Adjacency list (add ltree as a computed/cached column if reads need to be fast) |

---

### Multi-Tenancy

#### Row-Level (Shared Schema, Shared Tables)

Every table has a `tenant_id`. All queries filter by it.

```sql
CREATE TABLE tenants (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    slug    text UNIQUE NOT NULL,
    name    text NOT NULL
);

CREATE TABLE projects (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id   bigint NOT NULL REFERENCES tenants(id),
    name        text NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- EVERY index on a tenant-scoped table should lead with tenant_id
CREATE INDEX idx_projects_tenant ON projects(tenant_id, created_at DESC);

-- Row-Level Security: enforce tenant isolation at the database level
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON projects
    USING (tenant_id = current_setting('app.current_tenant_id')::bigint);

-- Application sets this at connection time
SET app.current_tenant_id = '42';

-- Now all queries are automatically filtered
SELECT * FROM projects;  -- only sees tenant 42's projects
```

**When to use:** Most SaaS applications. Shared infrastructure, simple ops, works at scale.
**Trade-off:** Every query must filter by `tenant_id` (RLS helps enforce this). Noisy neighbors can affect performance. Schema migrations affect all tenants simultaneously. Accidental cross-tenant data leaks are possible if RLS is misconfigured.

#### Schema-Per-Tenant

Each tenant gets their own PostgreSQL schema. Tables are identical across schemas.

```sql
-- Create a new tenant
CREATE SCHEMA tenant_acme;

CREATE TABLE tenant_acme.projects (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        text NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- Application sets search_path per request
SET search_path TO tenant_acme, public;

-- Queries hit the tenant's schema automatically
SELECT * FROM projects;  -- hits tenant_acme.projects
```

**When to use:** Regulatory requirements for data isolation. Tenants with wildly different data volumes. Need to backup/restore individual tenants. Want per-tenant schema migrations (risky but sometimes necessary).
**Trade-off:** Schema count grows linearly. Migrations must be applied to every schema. Connection pooling is harder (each connection pins to a schema). Monitoring and indexing across tenants requires iteration.

#### Shared-Nothing (Database-Per-Tenant)

Each tenant gets their own database (or even their own server).

**When to use:** Enterprise customers with contractual isolation requirements. Tenants in different geographic regions (data residency). Extremely high-value tenants who need guaranteed resources.
**Trade-off:** Operational complexity scales linearly. Cross-tenant queries require `dblink` or `postgres_fdw`. Connection pooling is per-database. Most SaaS companies never need this.

#### Recommendation

Start with row-level tenancy + RLS. Graduate individual tenants to schema-per-tenant or database-per-tenant only when you have a specific reason (compliance, performance isolation, data residency).

---

### Soft Deletes

#### Option 1: `deleted_at` Timestamp

```sql
CREATE TABLE posts (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title       text NOT NULL,
    body        text NOT NULL,
    author_id   bigint NOT NULL REFERENCES users(id),
    created_at  timestamptz NOT NULL DEFAULT now(),
    deleted_at  timestamptz  -- NULL = active
);

-- Default view excludes soft-deleted rows
CREATE VIEW active_posts AS
SELECT * FROM posts WHERE deleted_at IS NULL;

-- Partial index: only index active rows (most queries only need these)
CREATE INDEX idx_posts_author_active ON posts(author_id) WHERE deleted_at IS NULL;

-- Unique constraint that only applies to active records
CREATE UNIQUE INDEX idx_posts_unique_title ON posts(title) WHERE deleted_at IS NULL;
```

**When to use:** You need undo/undelete. Compliance requires you to retain data but hide it. You want to audit what was deleted and when.
**Trade-off:** Every query must remember to filter `WHERE deleted_at IS NULL` (use a view or RLS). The table grows forever. Indexes that don't use `WHERE deleted_at IS NULL` waste space on dead rows.

#### Option 2: Status Enum

```sql
CREATE TYPE post_status AS ENUM ('draft', 'published', 'archived', 'deleted');

CREATE TABLE posts (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title       text NOT NULL,
    body        text NOT NULL,
    status      post_status NOT NULL DEFAULT 'draft',
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_posts_status ON posts(status) WHERE status = 'published';
```

**When to use:** "Deleted" is just one of several lifecycle states. You already have a status field. The semantics are richer than just "exists or doesn't."
**Trade-off:** Same "every query must filter" problem. But often the status filter is already there.

#### Option 3: Archive Table

Move deleted rows to a separate table.

```sql
CREATE TABLE posts (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title       text NOT NULL,
    body        text NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE posts_archive (
    LIKE posts INCLUDING ALL,
    archived_at timestamptz NOT NULL DEFAULT now(),
    archived_by bigint REFERENCES users(id)
);

-- Delete = move to archive
WITH deleted AS (
    DELETE FROM posts WHERE id = 123 RETURNING *
)
INSERT INTO posts_archive
SELECT *, now(), 42 FROM deleted;
```

**When to use:** Active table must stay lean (performance-critical). Archived data is rarely queried. You want clean separation between live and dead data.
**Trade-off:** Restoring requires moving the row back. FKs pointing to the deleted row break (unless they cascade or use the archive table). Schema changes must be applied to both tables.

#### Recommendation

`deleted_at` for most apps. Status enum when lifecycle is richer than binary. Archive table only for performance-critical tables with high delete volume.

---

### Audit Logging

#### Trigger-Based (Generic)

A single audit table captures all changes across all tracked tables.

```sql
CREATE TABLE audit_log (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name      text NOT NULL,
    row_id          text NOT NULL,
    action          text NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values      jsonb,
    new_values      jsonb,
    changed_fields  text[],
    performed_by    text,         -- from session variable
    performed_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_table_row ON audit_log(table_name, row_id);
CREATE INDEX idx_audit_performed_at ON audit_log(performed_at);

-- Generic audit trigger function
CREATE OR REPLACE FUNCTION fn_audit_trigger()
RETURNS trigger AS $$
DECLARE
    old_json jsonb;
    new_json jsonb;
    changed text[];
    key text;
BEGIN
    IF TG_OP = 'DELETE' THEN
        old_json := to_jsonb(OLD);
        new_json := NULL;
    ELSIF TG_OP = 'INSERT' THEN
        old_json := NULL;
        new_json := to_jsonb(NEW);
    ELSE
        old_json := to_jsonb(OLD);
        new_json := to_jsonb(NEW);
        -- Compute changed fields
        FOR key IN SELECT jsonb_object_keys(new_json)
        LOOP
            IF old_json->key IS DISTINCT FROM new_json->key THEN
                changed := array_append(changed, key);
            END IF;
        END LOOP;
    END IF;

    INSERT INTO audit_log (table_name, row_id, action, old_values, new_values, changed_fields, performed_by)
    VALUES (
        TG_TABLE_NAME,
        CASE TG_OP WHEN 'DELETE' THEN (OLD.id)::text ELSE (NEW.id)::text END,
        TG_OP,
        old_json,
        new_json,
        changed,
        current_setting('app.current_user', true)
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Attach to any table
CREATE TRIGGER trg_audit_orders
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION fn_audit_trigger();
```

**When to use:** You need a complete change history across multiple tables. Compliance requirements (SOC 2, HIPAA, financial auditing). Debugging "who changed this and when."
**Trade-off:** Every write to a tracked table incurs an additional insert. JSONB serialization on every row change. The audit table grows fast; partition by `performed_at`.

#### Application-Level

The application writes audit records explicitly.

```sql
CREATE TABLE activity_log (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    actor_id      bigint NOT NULL REFERENCES users(id),
    action        text NOT NULL,
    resource_type text NOT NULL,
    resource_id   bigint NOT NULL,
    details       jsonb DEFAULT '{}',
    ip_address    inet,
    created_at    timestamptz NOT NULL DEFAULT now()
);

-- Application code:
-- INSERT INTO activity_log (actor_id, action, resource_type, resource_id, details, ip_address)
-- VALUES (current_user_id, 'updated_price', 'product', 42, '{"old": 19.99, "new": 29.99}', client_ip);
```

**When to use:** You want human-readable audit entries ("User X updated the price of Product Y from $19.99 to $29.99"). Business-level auditing, not row-level. You need context the database doesn't have (IP address, session info, business intent).
**Trade-off:** The application can forget to log. Inconsistency risk. But richer, more meaningful entries.

#### CDC (Change Data Capture)

Use logical replication or tools like Debezium to stream WAL changes to an external system.

**When to use:** You need audit data outside PostgreSQL (data lake, Kafka, Elasticsearch). High-volume systems where in-database audit tables become a bottleneck. You want to decouple audit from the write path.
**Trade-off:** External infrastructure dependency. Eventual consistency (audit lags writes). More complex ops.

#### Recommendation

Use trigger-based auditing for compliance-critical tables. Use application-level logging for user-facing activity feeds. Consider CDC when scale makes in-database auditing a bottleneck or when audit consumers are external systems.

---

### Tags and Categories

#### Join Table (Classic Many-to-Many)

```sql
CREATE TABLE tags (
    id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  text UNIQUE NOT NULL,
    slug  text UNIQUE NOT NULL
);

CREATE TABLE article_tags (
    article_id  bigint NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    tag_id      bigint NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (article_id, tag_id)
);

CREATE INDEX idx_article_tags_tag ON article_tags(tag_id);

-- Articles with tag "postgresql"
SELECT a.* FROM articles a
JOIN article_tags at ON a.id = at.article_id
JOIN tags t ON at.tag_id = t.id
WHERE t.slug = 'postgresql';

-- Articles with ALL of these tags
SELECT a.* FROM articles a
JOIN article_tags at ON a.id = at.article_id
JOIN tags t ON at.tag_id = t.id
WHERE t.slug IN ('postgresql', 'performance')
GROUP BY a.id
HAVING count(DISTINCT t.slug) = 2;
```

**When to use:** Tags are first-class entities with their own metadata (description, color, icon). You need referential integrity. You query "all articles with tag X" frequently. You need tag counts, tag clouds, tag management.

#### Array Column

```sql
CREATE TABLE articles (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title   text NOT NULL,
    tags    text[] DEFAULT '{}'
);

CREATE INDEX idx_articles_tags ON articles USING gin (tags);

-- Articles tagged "postgresql"
SELECT * FROM articles WHERE tags @> ARRAY['postgresql'];

-- Articles tagged both "postgresql" AND "performance"
SELECT * FROM articles WHERE tags @> ARRAY['postgresql', 'performance'];

-- Articles tagged "postgresql" OR "mysql"
SELECT * FROM articles WHERE tags && ARRAY['postgresql', 'mysql'];
```

**When to use:** Tags are free-form labels, not managed entities. You don't need a canonical tag list. Reads vastly outnumber tag management operations. Simple use cases.
**Trade-off:** No referential integrity. Renaming a tag means updating every row. No tag metadata. Typos create duplicate tags silently. But queries are simpler and often faster for read-heavy workloads.

#### JSONB Tags

```sql
CREATE TABLE articles (
    id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title    text NOT NULL,
    metadata jsonb DEFAULT '{}'
    -- metadata: {"tags": ["postgresql", "performance"], "difficulty": "advanced"}
);

CREATE INDEX idx_articles_tags ON articles USING gin ((metadata->'tags'));

SELECT * FROM articles WHERE metadata->'tags' ? 'postgresql';
```

**When to use:** Tags are part of a larger flexible metadata bag. You already have a JSONB column for other purposes. Avoid creating a JSONB column just for tags; use a text array.

#### ltree for Hierarchical Categories

```sql
CREATE EXTENSION IF NOT EXISTS ltree;

CREATE TABLE articles (
    id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title    text NOT NULL,
    category ltree NOT NULL
);

CREATE INDEX idx_articles_category ON articles USING gist (category);

INSERT INTO articles (title, category) VALUES
    ('PostgreSQL Indexing Guide', 'tech.databases.postgresql'),
    ('MySQL vs PostgreSQL', 'tech.databases.comparison'),
    ('React Hooks Deep Dive', 'tech.frontend.react');

-- All database articles (including subcategories)
SELECT * FROM articles WHERE category <@ 'tech.databases';

-- All tech articles
SELECT * FROM articles WHERE category <@ 'tech';
```

**When to use:** Categories form a strict hierarchy (exactly one path per item). You need "all items in this category and below" queries. Product catalogs, content taxonomies.

#### Recommendation

| Situation | Use |
|-----------|-----|
| Tags are managed entities with metadata | Join table |
| Tags are simple labels, read-heavy | Array column |
| Hierarchical categories | ltree |
| Tags as part of existing JSONB metadata | JSONB (but don't build around this) |

---

### EAV vs. JSONB

Entity-Attribute-Value is a schema pattern where attributes are rows, not columns. It was the go-to for "flexible schema" before JSONB existed.

#### EAV (When You Must)

```sql
CREATE TABLE product_attributes (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id    bigint NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    attribute_key text NOT NULL,
    value_text    text,
    value_numeric numeric,
    value_bool    boolean,
    value_date    date,

    CONSTRAINT chk_single_value CHECK (
        num_nonnulls(value_text, value_numeric, value_bool, value_date) = 1
    ),
    UNIQUE (product_id, attribute_key)
);

CREATE INDEX idx_product_attrs_key ON product_attributes(attribute_key, value_text);

-- Get all attributes for a product (pivot)
SELECT
    p.name,
    max(CASE WHEN pa.attribute_key = 'color' THEN pa.value_text END) AS color,
    max(CASE WHEN pa.attribute_key = 'weight_kg' THEN pa.value_numeric END) AS weight_kg,
    max(CASE WHEN pa.attribute_key = 'is_fragile' THEN pa.value_bool END) AS is_fragile
FROM products p
JOIN product_attributes pa ON p.id = pa.product_id
WHERE p.id = 42
GROUP BY p.id, p.name;
```

**When EAV is defensible:**
- User-defined fields (CRM custom fields, form builders)
- Compliance systems where the attribute schema is defined by external regulation and changes frequently
- Catalog systems with genuinely hundreds of product-type-specific attributes

**When JSONB is better (most of the time):**

```sql
CREATE TABLE products (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        text NOT NULL,
    category    text NOT NULL,
    attributes  jsonb NOT NULL DEFAULT '{}'
);

-- GIN index for containment queries
CREATE INDEX idx_products_attributes ON products USING gin (attributes);

-- Specific attribute index (for high-selectivity queries)
CREATE INDEX idx_products_color ON products ((attributes->>'color'));

INSERT INTO products (name, category, attributes) VALUES
    ('Widget Pro', 'electronics', '{"color": "black", "weight_kg": 0.5, "waterproof": true}');

-- Query by attribute
SELECT * FROM products WHERE attributes @> '{"color": "black"}';
SELECT * FROM products WHERE (attributes->>'weight_kg')::numeric < 1.0;
```

JSONB wins over EAV because:
- Single row per entity (no pivot queries)
- GIN indexing for containment
- Path-based indexing for specific attributes
- `jsonb_each`, `jsonb_to_record` for unpacking
- Readable queries
- Better `EXPLAIN` plans

EAV wins over JSONB only when:
- You need per-attribute constraints, permissions, or audit trails
- Attribute definitions are themselves stored in the database and drive UI generation
- You need to query "all entities where attribute X has value Y" and X is user-defined at runtime (though JSONB handles this too)

---

### UUID vs. Serial Primary Keys

#### Serial / IDENTITY (Recommended Default)

```sql
CREATE TABLE orders (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY
    -- ...
);
```

**Advantages:** 8 bytes. Sortable (insertion order). B-tree friendly. Efficient joins. Human-readable in logs and debugging.
**Disadvantages:** Predictable (information leakage in URLs). Requires the database to generate (can't pre-generate client-side). Cross-database merges are painful.

#### UUIDv4 (Random)

```sql
CREATE TABLE orders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid()
    -- ...
);
```

**Advantages:** Globally unique. Can be generated client-side. No information leakage. Safe for distributed systems.
**Disadvantages:** 16 bytes (2x a bigint). Random UUIDs cause B-tree index fragmentation (random insertion points, poor cache locality). `CLUSTER` and range scans suffer. Unreadable in logs.

#### UUIDv7 (Time-Ordered)

```sql
-- Requires PostgreSQL 17+ or a custom function
CREATE TABLE orders (
    id uuid PRIMARY KEY DEFAULT uuidv7()
    -- ...
);
```

**Advantages:** Globally unique AND time-sorted. B-tree friendly (monotonically increasing prefix). Best of both worlds for distributed systems.
**Disadvantages:** Still 16 bytes. Requires PG 17+ for native `uuidv7()`. Leaks creation timestamp (first 48 bits are millisecond epoch).

#### Recommendation

| Scenario | Use |
|----------|-----|
| Single-database OLTP (most apps) | `bigint GENERATED ALWAYS AS IDENTITY` |
| Distributed systems, client-side ID generation | UUIDv7 (PG 17+) or UUIDv4 |
| Public-facing IDs in URLs | UUID (any version) or a separate `public_id` column |
| Cross-database data merging | UUID |
| Time-series or append-heavy tables | bigint identity or UUIDv7 |

A common compromise: use `bigint` as the internal PK for joins and indexes, add a `public_id uuid` column with a unique index for external exposure.

```sql
CREATE TABLE orders (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    public_id   uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    -- ...
);

-- Internal queries join on id (fast, 8 bytes)
-- API endpoints resolve by public_id (secure, no enumeration)
```

---

## PostgreSQL-Specific Types

PostgreSQL has a type system that most developers underuse. Here's when to reach for each.

### JSONB

```sql
-- Good: flexible metadata that varies per row
ALTER TABLE products ADD COLUMN metadata jsonb DEFAULT '{}';

-- Good: API response caching / webhook payloads
CREATE TABLE webhook_deliveries (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payload     jsonb NOT NULL,
    response    jsonb,
    status_code int,
    delivered_at timestamptz DEFAULT now()
);

-- Good: document-like data that doesn't need relational modeling
CREATE TABLE form_submissions (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    form_id     bigint NOT NULL REFERENCES forms(id),
    answers     jsonb NOT NULL,
    submitted_at timestamptz DEFAULT now()
);
```

**Anti-pattern: JSONB as a crutch for poor modeling.**

```sql
-- BAD: using JSONB to avoid designing a schema
CREATE TABLE orders (
    id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    data jsonb NOT NULL
    -- data: {"customer_name": "...", "items": [...], "total": 99.99, "status": "shipped"}
);
-- You just reinvented a document database, poorly.
-- No type safety, no constraints, no FKs, no indexing strategy.

-- GOOD: model the relational parts relationally, use JSONB for the genuinely flexible parts
CREATE TABLE orders (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   bigint NOT NULL REFERENCES customers(id),
    status        text NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'delivered')),
    total         numeric(10,2) NOT NULL,
    notes         jsonb DEFAULT '{}',  -- JSONB for the unstructured bits
    created_at    timestamptz NOT NULL DEFAULT now()
);
```

### Arrays

```sql
-- Good: ordered lists of simple values that belong to the row
ALTER TABLE users ADD COLUMN phone_numbers text[];
ALTER TABLE articles ADD COLUMN tags text[];

-- Querying
SELECT * FROM articles WHERE 'postgresql' = ANY(tags);
SELECT * FROM articles WHERE tags @> ARRAY['postgresql', 'indexing'];

-- GIN index for containment queries
CREATE INDEX idx_articles_tags ON articles USING gin (tags);
```

**Anti-pattern: arrays of IDs (use a join table instead).**

```sql
-- BAD
ALTER TABLE orders ADD COLUMN product_ids bigint[];
-- No FK constraint. No ON DELETE CASCADE. No metadata per association (quantity, price).

-- GOOD
CREATE TABLE order_items (
    order_id    bigint REFERENCES orders(id) ON DELETE CASCADE,
    product_id  bigint REFERENCES products(id),
    quantity    int NOT NULL DEFAULT 1,
    unit_price  numeric(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);
```

### Ranges

```sql
-- Date ranges for bookings, availability, subscriptions
CREATE TABLE room_bookings (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id     bigint NOT NULL REFERENCES rooms(id),
    guest_id    bigint NOT NULL REFERENCES guests(id),
    stay        daterange NOT NULL,

    -- No overlapping bookings for the same room
    CONSTRAINT no_double_booking EXCLUDE USING gist (
        room_id WITH =,
        stay WITH &&
    )
);

-- Requires btree_gist extension
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Query: rooms available for Jan 15-20
SELECT r.* FROM rooms r
WHERE NOT EXISTS (
    SELECT 1 FROM room_bookings rb
    WHERE rb.room_id = r.id
    AND rb.stay && daterange('2025-01-15', '2025-01-20')
);

-- Numeric ranges for price tiers
CREATE TABLE shipping_rates (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    weight_range numrange NOT NULL,
    rate         numeric(10,2) NOT NULL,

    CONSTRAINT no_overlap EXCLUDE USING gist (weight_range WITH &&)
);

INSERT INTO shipping_rates (weight_range, rate) VALUES
    (numrange(0, 1, '[)'), 5.99),
    (numrange(1, 5, '[)'), 9.99),
    (numrange(5, 20, '[)'), 14.99),
    (numrange(20, NULL, '[)'), 24.99);

-- What's the shipping rate for a 3.5kg package?
SELECT rate FROM shipping_rates WHERE weight_range @> 3.5;
```

### Enums

```sql
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled');

CREATE TABLE orders (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status  order_status NOT NULL DEFAULT 'pending'
);

-- Advantages: type safety, 4 bytes storage, readable
-- Disadvantages: ALTER TYPE ADD VALUE is not transactional (pre-PG12: can't be in a transaction block)
-- Adding values is easy; removing or renaming values requires a migration dance:
--   1. Create new enum type
--   2. ALTER TABLE ALTER COLUMN TYPE new_enum USING status::text::new_enum
--   3. DROP old type
```

**When to use:** Stable, small sets of values (order statuses, user roles, priority levels). Values rarely change.
**When NOT to use:** Values change frequently. You need to remove values. Values are user-defined. Use a CHECK constraint or a lookup table instead.

### Composite Types

```sql
CREATE TYPE address AS (
    street   text,
    city     text,
    state    text,
    zip      text,
    country  text
);

CREATE TABLE warehouses (
    id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name     text NOT NULL,
    location address NOT NULL
);

INSERT INTO warehouses (name, location) VALUES
    ('West Coast Hub', ROW('123 Industrial Blvd', 'Portland', 'OR', '97201', 'US'));

SELECT (location).city FROM warehouses;
```

**When to use:** Rarely. Most of the time you want either a separate table (if the data is shared/referenced) or JSONB (if the structure is flexible). Composite types are useful for function return types and very stable, always-embedded value objects.

### tsvector / Full-Text Search

```sql
ALTER TABLE articles ADD COLUMN search_vector tsvector;

-- Populate and index
UPDATE articles SET search_vector =
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(body, '')), 'B');

CREATE INDEX idx_articles_search ON articles USING gin (search_vector);

-- Automatically maintain via trigger
CREATE OR REPLACE FUNCTION fn_articles_search_update() RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.body, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_articles_search
    BEFORE INSERT OR UPDATE OF title, body ON articles
    FOR EACH ROW EXECUTE FUNCTION fn_articles_search_update();

-- Search with ranking
SELECT title, ts_rank(search_vector, query) AS rank
FROM articles, to_tsquery('english', 'postgresql & indexing') AS query
WHERE search_vector @@ query
ORDER BY rank DESC;
```

**When to use:** You need search but Elasticsearch is overkill. Moderate corpus size (millions of rows is fine). You want transactional consistency between data and search index.
**When NOT to use:** You need fuzzy matching, typo tolerance, faceted search, or multi-language support beyond what `pg_trgm` and dictionaries provide.

### hstore

```sql
CREATE EXTENSION IF NOT EXISTS hstore;

CREATE TABLE legacy_config (
    id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    settings hstore DEFAULT ''
);

INSERT INTO legacy_config (settings) VALUES ('theme => dark, language => en, timezone => UTC');
SELECT settings->'theme' FROM legacy_config;
```

**When to use:** Almost never. JSONB does everything hstore does, plus nesting, arrays, and better tooling. hstore exists for historical reasons. Use JSONB for new work.

---

## Constraint Design

Constraints are your schema's immune system. They catch bugs before they become data corruption.

### CHECK Constraints

```sql
CREATE TABLE invoices (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subtotal    numeric(10,2) NOT NULL,
    tax_rate    numeric(5,4) NOT NULL,
    total       numeric(10,2) NOT NULL,
    status      text NOT NULL DEFAULT 'draft',
    issued_at   date,
    due_at      date,

    -- Domain constraints
    CONSTRAINT chk_positive_amounts CHECK (subtotal >= 0 AND total >= 0),
    CONSTRAINT chk_tax_rate CHECK (tax_rate >= 0 AND tax_rate <= 1),

    -- Cross-column constraint
    CONSTRAINT chk_due_after_issued CHECK (due_at >= issued_at),

    -- Status-dependent constraint
    CONSTRAINT chk_issued_requires_dates CHECK (
        status <> 'issued' OR (issued_at IS NOT NULL AND due_at IS NOT NULL)
    )
);
```

### Exclusion Constraints

Prevent overlapping ranges. The `EXCLUDE` constraint uses a GiST index to enforce that no two rows can satisfy the specified condition.

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- No two employees can be scheduled for the same shift in the same department
CREATE TABLE shift_assignments (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id     bigint NOT NULL REFERENCES employees(id),
    department_id   bigint NOT NULL REFERENCES departments(id),
    shift_period    tstzrange NOT NULL,

    -- Same employee can't work two shifts at once
    CONSTRAINT no_employee_overlap EXCLUDE USING gist (
        employee_id WITH =,
        shift_period WITH &&
    ),

    -- Same department can't have duplicate assignments
    -- (if department has a max capacity, handle differently)
    CONSTRAINT no_department_double_assign EXCLUDE USING gist (
        department_id WITH =,
        employee_id WITH =,
        shift_period WITH &&
    )
);

-- IP address range allocations that must not overlap
CREATE TABLE ip_allocations (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    network     cidr NOT NULL,
    tenant_id   bigint NOT NULL REFERENCES tenants(id),
    allocated   daterange NOT NULL DEFAULT daterange(current_date, NULL),

    CONSTRAINT no_network_overlap EXCLUDE USING gist (
        network inet_ops WITH &&,
        allocated WITH &&
    )
);
```

### Partial Unique Indexes

A unique constraint that only applies to a subset of rows.

```sql
-- Only one active subscription per user (but many cancelled/expired ones are fine)
CREATE UNIQUE INDEX idx_one_active_subscription
    ON subscriptions(user_id)
    WHERE status = 'active';

-- Only one "primary" address per user
CREATE UNIQUE INDEX idx_one_primary_address
    ON addresses(user_id)
    WHERE is_primary = true;

-- Unique slug per published article (drafts can have duplicate slugs)
CREATE UNIQUE INDEX idx_unique_published_slug
    ON articles(slug)
    WHERE status = 'published';
```

### Generated Columns

Computed columns that are stored and indexed like regular columns but maintained automatically.

```sql
CREATE TABLE products (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            text NOT NULL,
    price_cents     int NOT NULL,
    quantity         int NOT NULL DEFAULT 0,

    -- Stored generated columns (PG 12+)
    price_dollars   numeric(10,2) GENERATED ALWAYS AS (price_cents / 100.0) STORED,
    total_value     numeric(12,2) GENERATED ALWAYS AS ((price_cents * quantity) / 100.0) STORED,

    -- Searchable slug derived from name
    slug            text GENERATED ALWAYS AS (
        lower(regexp_replace(name, '[^a-zA-Z0-9]+', '-', 'g'))
    ) STORED
);

-- Generated columns are indexable
CREATE INDEX idx_products_slug ON products(slug);
```

**Limitations:** Generated columns can only reference columns in the same row (no subqueries, no other table references). Expression must be immutable. Can't be part of a PRIMARY KEY (but can have a UNIQUE index).

---

## Anti-Pattern Catalog

### 1. God Tables

**The problem:** A single table tries to represent multiple entities or accumulates columns for every feature.

```sql
-- BAD: 40+ columns, half of which are NULL for any given row
CREATE TABLE users (
    id                  bigint PRIMARY KEY,
    email               text,
    name                text,
    -- ...personal fields...
    company_name        text,       -- only for business users
    company_tax_id      text,       -- only for business users
    company_address     text,       -- only for business users
    shipping_street     text,       -- denormalized address
    shipping_city       text,
    shipping_state      text,
    shipping_zip        text,
    billing_street      text,       -- another denormalized address
    billing_city        text,
    billing_state       text,
    billing_zip         text,
    stripe_customer_id  text,       -- payment integration
    paypal_email        text,       -- another payment integration
    last_login_at       timestamptz,
    login_count         int,
    preferences_json    jsonb,      -- "we'll put it in JSON for now"
    -- ...30 more columns...
);
```

**Why it's bad:** Hard to reason about. NULLs everywhere. Indexes bloated. Migrations are terrifying. Different concerns are coupled.

**Fix:** Decompose into focused tables.

```sql
CREATE TABLE users (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email   text UNIQUE NOT NULL,
    name    text NOT NULL
);

CREATE TABLE user_profiles (
    user_id         bigint PRIMARY KEY REFERENCES users(id),
    last_login_at   timestamptz,
    login_count     int DEFAULT 0,
    preferences     jsonb DEFAULT '{}'
);

CREATE TABLE business_accounts (
    user_id     bigint PRIMARY KEY REFERENCES users(id),
    company     text NOT NULL,
    tax_id      text,
    address_id  bigint REFERENCES addresses(id)
);

CREATE TABLE addresses (
    id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id  bigint NOT NULL REFERENCES users(id),
    type     text NOT NULL CHECK (type IN ('shipping', 'billing')),
    street   text NOT NULL,
    city     text NOT NULL,
    state    text,
    zip      text NOT NULL,
    UNIQUE (user_id, type)
);

CREATE TABLE payment_methods (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id     bigint NOT NULL REFERENCES users(id),
    provider    text NOT NULL CHECK (provider IN ('stripe', 'paypal')),
    external_id text NOT NULL,
    is_default  boolean DEFAULT false,
    UNIQUE (user_id, provider)
);
```

### 2. Implicit Typing (Everything as TEXT)

```sql
-- BAD
CREATE TABLE events (
    id          serial PRIMARY KEY,
    event_date  text,        -- '2024-01-15' or 'January 15' or 'tomorrow'?
    amount      text,        -- '99.99' or '$99.99' or '99,99'?
    is_active   text,        -- 'true' or 'yes' or '1' or 'Y'?
    latitude    text,
    longitude   text
);

-- GOOD
CREATE TABLE events (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_date  date NOT NULL,
    amount      numeric(10,2) NOT NULL CHECK (amount >= 0),
    is_active   boolean NOT NULL DEFAULT true,
    coordinates point
);
```

**Why it's bad:** No type checking at the database level. Sorting is lexicographic ('9' > '10'). No built-in validation. Application must handle all parsing and validation. Index efficiency is terrible for comparisons.

### 3. Missing Foreign Keys

```sql
-- BAD: "We'll enforce this in the application layer"
CREATE TABLE order_items (
    id          serial PRIMARY KEY,
    order_id    int NOT NULL,      -- no FK
    product_id  int NOT NULL,      -- no FK
    quantity    int
);
-- Result: orphaned order_items after orders are deleted.
-- Result: order_items referencing products that no longer exist.
-- Result: joins that silently return fewer rows than expected.
```

**Fix:** Always declare FKs. If you're worried about FK checking performance on bulk inserts, use `SET CONSTRAINTS ... DEFERRED` or disable and re-enable within a transaction. Don't permanently omit them.

```sql
CREATE TABLE order_items (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id    bigint NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id  bigint NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity    int NOT NULL CHECK (quantity > 0)
);
```

**ON DELETE options:**
- `CASCADE` — delete child when parent is deleted (order_items when order is deleted)
- `RESTRICT` — prevent parent deletion if children exist (don't delete a product that's in orders)
- `SET NULL` — set FK to NULL when parent is deleted (rarely appropriate)
- Choose deliberately. The default (`NO ACTION`) behaves like `RESTRICT` but checks at transaction end.

### 4. Overusing JSONB

```sql
-- BAD: the "schemaless" PostgreSQL pattern
CREATE TABLE users (
    id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    data jsonb NOT NULL
);
-- "It's like MongoDB but in Postgres!"
-- No. You've lost: type safety, FK constraints, NOT NULL on individual fields,
-- query plan visibility, column-level permissions, straightforward migrations,
-- and the ability for anyone else to understand your data model.
```

**JSONB is appropriate for:**
- Truly semi-structured data (API payloads, webhook bodies, form responses)
- Metadata that varies per row and doesn't participate in joins
- Columns whose structure changes faster than you can migrate

**JSONB is not appropriate for:**
- Core business entities (users, orders, products)
- Anything you join on
- Anything you need FK constraints on
- Anything you need NOT NULL constraints on individual fields for

### 5. Stringly-Typed Enums

```sql
-- BAD: status as unconstrained text
CREATE TABLE orders (
    id      serial PRIMARY KEY,
    status  text  -- 'pending', 'Pending', 'PENDING', 'pnding', 'shipped', 'shiped'
);

-- BETTER: CHECK constraint
CREATE TABLE orders (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status  text NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled'))
);

-- BEST (for stable sets): PostgreSQL enum
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled');
CREATE TABLE orders (
    id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status  order_status NOT NULL DEFAULT 'pending'
);

-- ALSO GOOD (for frequently changing sets): lookup table
CREATE TABLE order_statuses (
    id    smallint PRIMARY KEY,
    name  text UNIQUE NOT NULL
);
INSERT INTO order_statuses VALUES (1, 'pending'), (2, 'confirmed'), (3, 'shipped'), (4, 'delivered'), (5, 'cancelled');

CREATE TABLE orders (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status_id   smallint NOT NULL REFERENCES order_statuses(id)
);
```

### 6. Calendar Tables Done Wrong

**The anti-pattern:** Storing recurring events as individual rows.

```sql
-- BAD: generating a row for every occurrence of a recurring event
INSERT INTO events (title, event_date) VALUES
    ('Team standup', '2025-01-06'),
    ('Team standup', '2025-01-07'),
    ('Team standup', '2025-01-08'),
    -- ...365 rows per year, per recurring event
    -- Changing the time means updating hundreds of rows
    -- "Cancel all future standups" is a mass delete
```

**Fix:** Store the recurrence rule, generate occurrences at query time.

```sql
CREATE TABLE recurring_events (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title       text NOT NULL,
    start_date  date NOT NULL,
    end_date    date,                -- NULL = no end
    start_time  time NOT NULL,
    duration    interval NOT NULL,
    rrule       text NOT NULL,       -- iCal RRULE: 'FREQ=WEEKLY;BYDAY=MO,WE,FR'
    timezone    text NOT NULL DEFAULT 'UTC'
);

-- Exceptions (cancellations, reschedulings) stored separately
CREATE TABLE event_exceptions (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    recurring_event_id  bigint NOT NULL REFERENCES recurring_events(id) ON DELETE CASCADE,
    original_date       date NOT NULL,
    is_cancelled        boolean DEFAULT false,
    replacement_date    date,        -- non-null = rescheduled
    replacement_time    time,
    UNIQUE (recurring_event_id, original_date)
);
```

If you need to query "what events happen on date X" efficiently, maintain a materialized occurrence table that you regenerate periodically or on rule change. But the source of truth is the rule, not the expansion.

### 7. Not Indexing Foreign Keys

```sql
-- PostgreSQL does NOT automatically create indexes on FK columns.
-- This is a common surprise coming from MySQL (InnoDB does auto-index FKs).

CREATE TABLE order_items (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id    bigint NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id  bigint NOT NULL REFERENCES products(id)
);

-- Without these indexes:
-- - DELETE FROM orders WHERE id = X triggers a sequential scan on order_items
-- - JOIN queries on order_items.order_id are slow
-- - ON DELETE CASCADE becomes a performance cliff

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
```

**Rule:** Every FK column should have an index unless you have measured evidence that it's not needed.

### 8. Using SERIAL Instead of IDENTITY

```sql
-- LEGACY (avoid for new tables)
CREATE TABLE orders (
    id serial PRIMARY KEY
);
-- serial creates an implicit sequence and a DEFAULT. But:
-- - You can manually INSERT a conflicting id
-- - The sequence and column are loosely coupled
-- - Ownership semantics are confusing

-- MODERN (use this)
CREATE TABLE orders (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);
-- GENERATED ALWAYS prevents manual id insertion (use OVERRIDING SYSTEM VALUE if you must)
-- Tightly coupled to the column
-- Standard SQL (serial is PostgreSQL-specific)
-- Use bigint, not int. You will run out of int (2.1 billion) sooner than you think.
```

---

## Quick Reference

### Type Selection Cheat Sheet

| Data | Type | Why |
|------|------|-----|
| Money | `numeric(precision, scale)` | Exact decimal. Never use `float` or `real` for money. |
| Timestamps | `timestamptz` | Always. Not `timestamp`. Not `text`. Not `bigint` epoch. |
| Booleans | `boolean` | Not `int`, not `text`, not `char(1)`. |
| Short text with known max | `text` + CHECK | `varchar(n)` works but `text` + CHECK is more flexible. |
| Email, URL | `text` + CHECK or `citext` | `citext` for case-insensitive. Domain type for validation. |
| IP addresses | `inet` or `cidr` | Not `text`. Built-in operators for containment, masking. |
| MAC addresses | `macaddr` | Not `text`. |
| Geographic coordinates | `point` or PostGIS `geometry` | Not two `float` columns. |
| Binary data | `bytea` | Or external storage with a reference. |
| Status / category | `enum` or CHECK-constrained `text` | Not unconstrained `text`. |
| Tags / labels | `text[]` or join table | Not comma-separated `text`. |
| Flexible metadata | `jsonb` | Not `json` (not indexable). Not `text` storing JSON. |
| Ranges (dates, numbers) | `daterange`, `numrange`, `tstzrange` | Not two columns. Enables exclusion constraints. |
| Tree paths | `ltree` | Not `text` with manual parsing. |

### Index Type Selection

| Query Pattern | Index Type |
|---------------|-----------|
| Equality, range, sorting | B-tree (default) |
| JSONB containment (`@>`, `?`, `?&`) | GIN |
| Array containment (`@>`, `&&`) | GIN |
| Full-text search (`@@`) | GIN |
| Range overlap, nearest-neighbor | GiST |
| ltree queries | GiST |
| Equality only (hash join) | Hash (PG 10+, WAL-logged) |
| Pattern matching (`LIKE 'foo%'`) | B-tree with `text_pattern_ops` |
| Trigram similarity (`%`, `similarity()`) | GIN or GiST with `pg_trgm` |

### Naming Conventions

```
Tables:         plural snake_case          orders, order_items, user_profiles
Columns:        singular snake_case        created_at, user_id, total_amount
PKs:            id                         (not order_id, not pk_order)
FKs:            {referenced_table_singular}_id    user_id, order_id
Indexes:        idx_{table}_{columns}      idx_orders_customer_id
Unique indexes: idx_{table}_{columns}_uniq idx_users_email_uniq (or use constraint name)
Constraints:    chk_{table}_{description}  chk_orders_positive_total
Triggers:       trg_{table}_{event}        trg_orders_audit
Functions:      fn_{description}           fn_audit_trigger, fn_update_search_vector
Enums:          singular snake_case        order_status, priority_level
```
