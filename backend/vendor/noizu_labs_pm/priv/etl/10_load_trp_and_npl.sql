-- Staging ETL: load therobotplans + tobor_locker into pm_core.
-- Run as superuser on pm_core. Variables: :trp_conn :npl_conn (dblink conninfo).
-- Idempotent. Preserves UUIDs. Nulls versioned-name FKs to avoid cross-table deps.

\set ON_ERROR_STOP on

CREATE EXTENSION IF NOT EXISTS dblink;

-- ── Users (null name_id/description_id/invite/approved_by to skip FK order) ──
INSERT INTO users (
  id, user_name, handle, email, hashed_password, status, verified, flagged,
  deleted_at, inserted_at, updated_at, admin, consent_preferences, consent_updated_at,
  mobile_phone, profile_completed_at, approved_at, role, bio
)
SELECT
  id, user_name, handle, email, hashed_password,
  COALESCE(status, 'active')::user_status_enum,
  COALESCE(verified, false), COALESCE(flagged, false),
  deleted_at, inserted_at, updated_at, COALESCE(admin, false),
  consent_preferences, consent_updated_at, mobile_phone,
  profile_completed_at, approved_at,
  'user'::user_role_enum, NULL
FROM dblink(:'trp_conn', $q$
  SELECT id, user_name::text, handle::text, email::text, hashed_password,
         status::text, verified, flagged, deleted_at, inserted_at, updated_at, admin,
         consent_preferences, consent_updated_at, mobile_phone,
         profile_completed_at, approved_at
  FROM users
$q$) AS t(
  id uuid, user_name text, handle text, email text, hashed_password text,
  status text, verified boolean, flagged boolean, deleted_at timestamptz,
  inserted_at timestamptz, updated_at timestamptz, admin boolean,
  consent_preferences jsonb, consent_updated_at timestamptz, mobile_phone text,
  profile_completed_at timestamptz, approved_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO users (
  id, user_name, handle, email, hashed_password, status, verified, flagged,
  deleted_at, inserted_at, updated_at, admin, role, bio
)
SELECT
  id, user_name, handle, email, NULL,
  COALESCE(status, 'active')::user_status_enum,
  COALESCE(verified, false), COALESCE(flagged, false),
  deleted_at, inserted_at, updated_at, COALESCE(admin, false),
  COALESCE(role, 'user')::user_role_enum, bio
FROM dblink(:'npl_conn', $q$
  SELECT id, user_name::text, handle::text, email::text,
         status::text, verified, flagged, deleted_at, inserted_at, updated_at, admin,
         role::text, bio
  FROM users
$q$) AS t(
  id uuid, user_name text, handle text, email text,
  status text, verified boolean, flagged boolean, deleted_at timestamptz,
  inserted_at timestamptz, updated_at timestamptz, admin boolean,
  role text, bio text
)
WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.id = t.id)
  AND NOT EXISTS (SELECT 1 FROM users u WHERE t.email IS NOT NULL AND u.email = t.email::citext)
  AND NOT EXISTS (SELECT 1 FROM users u WHERE t.handle IS NOT NULL AND u.handle = t.handle::citext)
  AND NOT EXISTS (SELECT 1 FROM users u WHERE t.user_name IS NOT NULL AND u.user_name = t.user_name::citext);

-- Email uniqueness: if same email already loaded from TRP, skip NPL row (already handled by id)
-- Extra safety for handle/user_name collisions across systems:
INSERT INTO user_id_map (source_system, source_id, pm_id, notes)
SELECT 'trp', id, id, 'uuid preserved'
FROM dblink(:'trp_conn', 'SELECT id FROM users') AS x(id uuid)
ON CONFLICT (source_system, source_id) DO NOTHING;

INSERT INTO user_id_map (source_system, source_id, pm_id, notes)
SELECT 'npl', id, id, 'uuid preserved'
FROM dblink(:'npl_conn', 'SELECT id FROM users') AS x(id uuid)
ON CONFLICT (source_system, source_id) DO NOTHING;

-- ── Organizations ─────────────────────────────────────────────────────────
INSERT INTO organizations (id, slug, name, settings, key_prefix, inserted_at, updated_at)
SELECT id, slug, name, COALESCE(settings, '{}'::jsonb), key_prefix, inserted_at, updated_at
FROM dblink(:'trp_conn', $q$
  SELECT id, slug, name, settings, key_prefix, inserted_at, updated_at FROM organizations
$q$) AS t(id uuid, slug text, name text, settings jsonb, key_prefix text, inserted_at timestamptz, updated_at timestamptz)
ON CONFLICT (id) DO NOTHING;

INSERT INTO organizations (id, slug, name, settings, key_prefix, inserted_at, updated_at)
SELECT id, slug, name, COALESCE(settings, '{}'::jsonb), key_prefix, inserted_at, updated_at
FROM dblink(:'npl_conn', $q$
  SELECT id, slug, name, settings, key_prefix, inserted_at, updated_at FROM organizations
$q$) AS t(id uuid, slug text, name text, settings jsonb, key_prefix text, inserted_at timestamptz, updated_at timestamptz)
ON CONFLICT (id) DO NOTHING;

INSERT INTO org_id_map (source_system, source_id, pm_id, notes)
SELECT 'trp', id, id, 'uuid preserved' FROM dblink(:'trp_conn', 'SELECT id FROM organizations') AS x(id uuid)
ON CONFLICT (source_system, source_id) DO NOTHING;
INSERT INTO org_id_map (source_system, source_id, pm_id, notes)
SELECT 'npl', id, id, 'uuid preserved' FROM dblink(:'npl_conn', 'SELECT id FROM organizations') AS x(id uuid)
ON CONFLICT (source_system, source_id) DO NOTHING;

-- PBAC groups/scoped_memberships: deferred (name UNIQUE + dual-source id
-- collisions need operator mapping). Work items load without them.

-- ── Projects ──────────────────────────────────────────────────────────────
INSERT INTO projects (
  id, organization_id, name, slug, description, settings, status, created_by,
  archived_at, key_prefix, default_methodology, default_queue_id, lock_version,
  inserted_at, updated_at
)
SELECT
  id, organization_id, name, slug, description, COALESCE(settings, '{}'::jsonb), status,
  CASE WHEN EXISTS (SELECT 1 FROM users u WHERE u.id = t.created_by) THEN t.created_by ELSE NULL END,
  archived_at, key_prefix, COALESCE(default_methodology, 'kanban'), NULL,
  0, inserted_at, updated_at
FROM dblink(:'trp_conn', $q$
  SELECT id, organization_id, name, slug, description, settings, status, created_by,
         archived_at, key_prefix, default_methodology, inserted_at, updated_at
  FROM projects
$q$) AS t(
  id uuid, organization_id uuid, name text, slug text, description text, settings jsonb,
  status text, created_by uuid, archived_at timestamptz, key_prefix text,
  default_methodology text, inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO projects (
  id, organization_id, name, slug, description, settings, status, created_by,
  archived_at, key_prefix, default_methodology, default_queue_id, lock_version,
  inserted_at, updated_at
)
SELECT
  id, organization_id, name, slug, description, COALESCE(settings, '{}'::jsonb), status,
  CASE WHEN EXISTS (SELECT 1 FROM users u WHERE u.id = t.created_by) THEN t.created_by ELSE NULL END,
  archived_at, key_prefix, 'kanban', NULL, 0, inserted_at, updated_at
FROM dblink(:'npl_conn', $q$
  SELECT id, organization_id, name, slug, description, settings, status, created_by,
         archived_at, key_prefix, inserted_at, updated_at
  FROM projects
$q$) AS t(
  id uuid, organization_id uuid, name text, slug text, description text, settings jsonb,
  status text, created_by uuid, archived_at timestamptz, key_prefix text,
  inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO project_id_map (source_system, source_id, pm_id, notes)
SELECT 'trp', id, id, 'uuid preserved' FROM dblink(:'trp_conn', 'SELECT id FROM projects') AS x(id uuid)
ON CONFLICT (source_system, source_id) DO NOTHING;
INSERT INTO project_id_map (source_system, source_id, pm_id, notes)
SELECT 'npl', id, id, 'uuid preserved' FROM dblink(:'npl_conn', 'SELECT id FROM projects') AS x(id uuid)
ON CONFLICT (source_system, source_id) DO NOTHING;

-- ── Definitions ───────────────────────────────────────────────────────────
INSERT INTO item_field_definitions (
  id, organization_id, project_id, slug, label, field_type, options, default_value,
  description, disabled, inserted_at, updated_at
)
SELECT * FROM dblink(:'trp_conn', $q$
  SELECT id, organization_id, project_id, slug, label, field_type, options, default_value,
         description, disabled, inserted_at, updated_at FROM item_field_definitions
$q$) AS t(
  id uuid, organization_id uuid, project_id uuid, slug text, label text, field_type text,
  options jsonb, default_value text, description text, disabled boolean,
  inserted_at timestamptz, updated_at timestamptz
)
WHERE NOT EXISTS (
  SELECT 1 FROM item_field_definitions f
  WHERE f.slug = t.slug
    AND f.organization_id IS NOT DISTINCT FROM t.organization_id
    AND f.project_id IS NOT DISTINCT FROM t.project_id
);

INSERT INTO item_field_definitions (
  id, organization_id, project_id, slug, label, field_type, options, default_value,
  description, disabled, inserted_at, updated_at
)
SELECT * FROM dblink(:'npl_conn', $q$
  SELECT id, organization_id, project_id, slug, label, field_type, options, default_value,
         description, disabled, inserted_at, updated_at FROM ticket_field_definitions
$q$) AS t(
  id uuid, organization_id uuid, project_id uuid, slug text, label text, field_type text,
  options jsonb, default_value text, description text, disabled boolean,
  inserted_at timestamptz, updated_at timestamptz
)
WHERE NOT EXISTS (
  SELECT 1 FROM item_field_definitions f
  WHERE f.slug = t.slug
    AND f.organization_id IS NOT DISTINCT FROM t.organization_id
    AND f.project_id IS NOT DISTINCT FROM t.project_id
);

INSERT INTO item_type_definitions (
  id, organization_id, project_id, slug, name, description, icon, color, status_workflow,
  disabled, deleted_at, inserted_at, updated_at
)
SELECT * FROM dblink(:'trp_conn', $q$
  SELECT id, organization_id, project_id, slug, name, description, icon, color, status_workflow,
         disabled, deleted_at, inserted_at, updated_at FROM item_type_definitions
$q$) AS t(
  id uuid, organization_id uuid, project_id uuid, slug text, name text, description text,
  icon text, color text, status_workflow jsonb, disabled boolean, deleted_at timestamptz,
  inserted_at timestamptz, updated_at timestamptz
)
WHERE NOT EXISTS (
  SELECT 1 FROM item_type_definitions f
  WHERE f.slug = t.slug
    AND f.organization_id IS NOT DISTINCT FROM t.organization_id
    AND f.project_id IS NOT DISTINCT FROM t.project_id
);

INSERT INTO item_type_definitions (
  id, organization_id, project_id, slug, name, description, icon, color, status_workflow,
  disabled, deleted_at, inserted_at, updated_at
)
SELECT id, organization_id, project_id, slug, name, description, icon, NULL, status_workflow,
       COALESCE(disabled, false), deleted_at, inserted_at, updated_at
FROM dblink(:'npl_conn', $q$
  SELECT id, organization_id, project_id, slug, name, description, icon, status_workflow,
         disabled, deleted_at, inserted_at, updated_at FROM ticket_type_definitions
$q$) AS t(
  id uuid, organization_id uuid, project_id uuid, slug text, name text, description text,
  icon text, status_workflow jsonb, disabled boolean, deleted_at timestamptz,
  inserted_at timestamptz, updated_at timestamptz
)
WHERE NOT EXISTS (
  SELECT 1 FROM item_type_definitions f
  WHERE f.slug = t.slug
    AND f.organization_id IS NOT DISTINCT FROM t.organization_id
    AND f.project_id IS NOT DISTINCT FROM t.project_id
);

-- ── Queues / stages / iterations ──────────────────────────────────────────
INSERT INTO item_queues (
  id, organization_id, project_id, name, slug, description, methodology, config,
  inserted_at, updated_at
)
SELECT * FROM dblink(:'trp_conn', $q$
  SELECT id, organization_id, project_id, name, slug, description, methodology, config,
         inserted_at, updated_at FROM item_queues
$q$) AS t(
  id uuid, organization_id uuid, project_id uuid, name text, slug text, description text,
  methodology text, config jsonb, inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO item_queues (
  id, organization_id, project_id, name, slug, description, methodology, config,
  inserted_at, updated_at
)
SELECT id, organization_id, project_id, name, slug, description,
       COALESCE(methodology, 'kanban'), COALESCE(config, '{}'::jsonb), inserted_at, updated_at
FROM dblink(:'npl_conn', $q$
  SELECT id, organization_id, project_id, name, slug, description, methodology, config,
         inserted_at, updated_at FROM ticket_queues
$q$) AS t(
  id uuid, organization_id uuid, project_id uuid, name text, slug text, description text,
  methodology text, config jsonb, inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO board_stages (
  id, queue_id, slug, name, kind, position, wip_limit, config, inserted_at, updated_at
)
SELECT * FROM dblink(:'trp_conn', $q$
  SELECT id, queue_id, slug, name, kind, position, wip_limit, config, inserted_at, updated_at FROM board_stages
$q$) AS t(
  id uuid, queue_id uuid, slug text, name text, kind text, position int, wip_limit int,
  config jsonb, inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO board_stages (
  id, queue_id, slug, name, kind, position, wip_limit, config, inserted_at, updated_at
)
SELECT * FROM dblink(:'npl_conn', $q$
  SELECT id, queue_id, slug, name, kind, position, wip_limit, config, inserted_at, updated_at FROM board_stages
$q$) AS t(
  id uuid, queue_id uuid, slug text, name text, kind text, position int, wip_limit int,
  config jsonb, inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO board_iterations (
  id, queue_id, name, sequence, status, goal, starts_on, ends_on, config, inserted_at, updated_at
)
SELECT * FROM dblink(:'trp_conn', $q$
  SELECT id, queue_id, name, sequence, status, goal, starts_on, ends_on, config, inserted_at, updated_at FROM board_iterations
$q$) AS t(
  id uuid, queue_id uuid, name text, sequence int, status text, goal text,
  starts_on date, ends_on date, config jsonb, inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO board_iterations (
  id, queue_id, name, sequence, status, goal, starts_on, ends_on, config, inserted_at, updated_at
)
SELECT * FROM dblink(:'npl_conn', $q$
  SELECT id, queue_id, name, sequence, status, goal, starts_on, ends_on, config, inserted_at, updated_at FROM board_iterations
$q$) AS t(
  id uuid, queue_id uuid, name text, sequence int, status text, goal text,
  starts_on date, ends_on date, config jsonb, inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

UPDATE projects p SET default_queue_id = s.default_queue_id
FROM dblink(:'trp_conn', $q$
  SELECT id, default_queue_id FROM projects WHERE default_queue_id IS NOT NULL
$q$) AS s(id uuid, default_queue_id uuid)
WHERE p.id = s.id AND s.default_queue_id IS NOT NULL;

-- ── Items (TRP) ───────────────────────────────────────────────────────────
INSERT INTO items (
  id, organization_id, project_id, title, description, item_type, status, priority,
  assignee, reporter, custom_fields, queue_id, stage_id, iteration_id, parent_id,
  owner_user_id, tags, rank, start_date, due_date, estimate, number, key,
  lock_version, inserted_at, updated_at
)
SELECT
  id, organization_id, project_id, title, description, item_type, status, priority,
  assignee, reporter, COALESCE(custom_fields, '{}'::jsonb), queue_id, stage_id, iteration_id, parent_id,
  owner_user_id, COALESCE(tags, '{}'::text[]), rank, start_date, due_date, estimate, number, key,
  0, inserted_at, updated_at
FROM dblink(:'trp_conn', $q$
  SELECT id, organization_id, project_id, title, description, item_type, status, priority,
         assignee, reporter, custom_fields, queue_id, stage_id, iteration_id, parent_id,
         owner_user_id, tags, rank, start_date, due_date, estimate, number, key,
         inserted_at, updated_at
  FROM items
$q$) AS t(
  id uuid, organization_id uuid, project_id uuid, title text, description text,
  item_type text, status text, priority text, assignee text, reporter text,
  custom_fields jsonb, queue_id uuid, stage_id uuid, iteration_id uuid, parent_id uuid,
  owner_user_id uuid, tags text[], rank text, start_date date, due_date date,
  estimate numeric, number int, key text, inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO item_id_map (source_system, source_id, pm_id, notes)
SELECT 'trp', id, id, 'uuid preserved' FROM dblink(:'trp_conn', 'SELECT id FROM items') AS x(id uuid)
ON CONFLICT (source_system, source_id) DO NOTHING;

-- ── Items from NPL tickets ────────────────────────────────────────────────
INSERT INTO items (
  id, organization_id, project_id, title, description, item_type, status, priority,
  assignee, reporter, custom_fields, queue_id, stage_id, iteration_id, parent_id,
  owner_user_id, tags, rank, start_date, due_date, estimate, number, key,
  lock_version, inserted_at, updated_at
)
SELECT
  id, organization_id, project_id, title, description, item_type, status, priority,
  assignee, reporter, COALESCE(custom_fields, '{}'::jsonb), queue_id, stage_id, iteration_id, parent_id,
  NULL, '{}'::text[], NULL, NULL, NULL, NULL, number, key,
  0, inserted_at, updated_at
FROM dblink(:'npl_conn', $q$
  SELECT id, organization_id, project_id, title, description, ticket_type, status, priority,
         assignee, reporter, custom_fields, queue_id, stage_id, iteration_id, parent_id,
         number, key, inserted_at, updated_at
  FROM tickets
$q$) AS t(
  id uuid, organization_id uuid, project_id uuid, title text, description text,
  item_type text, status text, priority text, assignee text, reporter text,
  custom_fields jsonb, queue_id uuid, stage_id uuid, iteration_id uuid, parent_id uuid,
  number int, key text, inserted_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO item_id_map (source_system, source_id, pm_id, notes)
SELECT 'npl', id, id, 'ticket→item'
FROM dblink(:'npl_conn', 'SELECT id FROM tickets') AS x(id uuid)
ON CONFLICT (source_system, source_id) DO NOTHING;

-- Counters (TRP + NPL ticket counters)
INSERT INTO item_number_counters (id, organization_id, project_id, last_number, inserted_at, updated_at)
SELECT * FROM dblink(:'trp_conn', $q$
  SELECT id, organization_id, project_id, last_number, inserted_at, updated_at FROM item_number_counters
$q$) AS t(id uuid, organization_id uuid, project_id uuid, last_number int, inserted_at timestamptz, updated_at timestamptz)
ON CONFLICT (id) DO NOTHING;

INSERT INTO item_number_counters (id, organization_id, project_id, last_number, inserted_at, updated_at)
SELECT * FROM dblink(:'npl_conn', $q$
  SELECT id, organization_id, project_id, last_number, inserted_at, updated_at FROM ticket_number_counters
$q$) AS t(id uuid, organization_id uuid, project_id uuid, last_number int, inserted_at timestamptz, updated_at timestamptz)
ON CONFLICT (id) DO NOTHING;

-- Validation summary
SELECT 'pm_users' AS metric, count(*)::text AS value FROM users
UNION ALL SELECT 'pm_orgs', count(*)::text FROM organizations
UNION ALL SELECT 'pm_projects', count(*)::text FROM projects
UNION ALL SELECT 'pm_items', count(*)::text FROM items
UNION ALL SELECT 'pm_queues', count(*)::text FROM item_queues
UNION ALL SELECT 'pm_stages', count(*)::text FROM board_stages
UNION ALL SELECT 'map_users', count(*)::text FROM user_id_map
UNION ALL SELECT 'map_items', count(*)::text FROM item_id_map
ORDER BY 1;
