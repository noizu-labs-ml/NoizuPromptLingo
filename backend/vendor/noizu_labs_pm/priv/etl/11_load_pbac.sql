-- Load PBAC groups + scoped_memberships into pm_core.
-- Groups share stable UUIDs across TRP/NPL for owner/admin/member/viewer;
-- NPL adds "lead". Memberships remap member_id when the NPL user was
-- collapsed into the TRP user (email/handle uniqueness).

\set ON_ERROR_STOP on
CREATE EXTENSION IF NOT EXISTS dblink;

-- ── Groups (prefer NPL set — superset with lead) ──────────────────────────
INSERT INTO groups (id, name, display_name, description, is_system, created_at, updated_at)
SELECT id, name::role_name_enum, display_name, description, COALESCE(is_system, true), created_at, updated_at
FROM dblink(:'npl_conn', $q$
  SELECT id, name::text, display_name, description, is_system, created_at, updated_at FROM groups
$q$) AS t(
  id uuid, name text, display_name text, description text, is_system boolean,
  created_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

-- TRP-only groups if any (usually none beyond shared UUIDs)
INSERT INTO groups (id, name, display_name, description, is_system, created_at, updated_at)
SELECT id, name::role_name_enum, display_name, description, COALESCE(is_system, true), created_at, updated_at
FROM dblink(:'trp_conn', $q$
  SELECT id, name::text, display_name, description, is_system, created_at, updated_at FROM groups
$q$) AS t(
  id uuid, name text, display_name text, description text, is_system boolean,
  created_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

-- ── Temporary email-based user remap (NPL id → pm_core id) ────────────────
CREATE TEMP TABLE tmp_user_remap (
  source_system text NOT NULL,
  source_id uuid NOT NULL,
  pm_id uuid NOT NULL,
  PRIMARY KEY (source_system, source_id)
);

INSERT INTO tmp_user_remap (source_system, source_id, pm_id)
SELECT 'trp', id, id
FROM dblink(:'trp_conn', 'SELECT id FROM users') AS x(id uuid)
WHERE EXISTS (SELECT 1 FROM users u WHERE u.id = x.id);

-- Same-id NPL users that landed in pm_core
INSERT INTO tmp_user_remap (source_system, source_id, pm_id)
SELECT 'npl', id, id
FROM dblink(:'npl_conn', 'SELECT id FROM users') AS x(id uuid)
WHERE EXISTS (SELECT 1 FROM users u WHERE u.id = x.id)
ON CONFLICT DO NOTHING;

-- Collapsed NPL users: map by email to existing pm_core user
INSERT INTO tmp_user_remap (source_system, source_id, pm_id)
SELECT 'npl', n.id, p.id
FROM dblink(:'npl_conn', 'SELECT id, email::text FROM users') AS n(id uuid, email text)
JOIN users p ON p.email = n.email::citext
WHERE NOT EXISTS (SELECT 1 FROM tmp_user_remap r WHERE r.source_system = 'npl' AND r.source_id = n.id)
ON CONFLICT DO NOTHING;

-- Refresh durable map notes for collapsed users
INSERT INTO user_id_map (source_system, source_id, pm_id, notes)
SELECT source_system, source_id, pm_id,
       CASE WHEN source_id = pm_id THEN 'uuid preserved' ELSE 'collapsed by email' END
FROM tmp_user_remap
ON CONFLICT (source_system, source_id) DO UPDATE
SET pm_id = EXCLUDED.pm_id,
    notes = EXCLUDED.notes;

-- ── Scoped memberships TRP ────────────────────────────────────────────────
INSERT INTO scoped_memberships (
  id, group_id, resource_type, resource_id, member_type, member_id, expires_at, added_by, created_at
)
SELECT
  t.id,
  t.group_id,
  t.resource_type::resource_type_enum,
  t.resource_id,
  t.member_type::member_type_enum,
  COALESCE(ur.pm_id, t.member_id),
  t.expires_at,
  CASE WHEN EXISTS (SELECT 1 FROM users u WHERE u.id = t.added_by) THEN t.added_by ELSE NULL END,
  t.created_at
FROM dblink(:'trp_conn', $q$
  SELECT id, group_id, resource_type::text, resource_id, member_type::text, member_id,
         expires_at, added_by, created_at
  FROM scoped_memberships
$q$) AS t(
  id uuid, group_id uuid, resource_type text, resource_id uuid, member_type text,
  member_id uuid, expires_at timestamptz, added_by uuid, created_at timestamptz
)
LEFT JOIN tmp_user_remap ur
  ON t.member_type = 'user' AND ur.source_system = 'trp' AND ur.source_id = t.member_id
WHERE EXISTS (SELECT 1 FROM groups g WHERE g.id = t.group_id)
  AND (
    t.member_type <> 'user'
    OR EXISTS (SELECT 1 FROM users u WHERE u.id = COALESCE(ur.pm_id, t.member_id))
  )
ON CONFLICT (id) DO NOTHING;

-- ── Scoped memberships NPL ────────────────────────────────────────────────
INSERT INTO scoped_memberships (
  id, group_id, resource_type, resource_id, member_type, member_id, expires_at, added_by, created_at
)
SELECT
  t.id,
  t.group_id,
  t.resource_type::resource_type_enum,
  t.resource_id,
  t.member_type::member_type_enum,
  COALESCE(ur.pm_id, t.member_id),
  t.expires_at,
  CASE WHEN EXISTS (SELECT 1 FROM users u WHERE u.id = t.added_by) THEN t.added_by ELSE NULL END,
  t.created_at
FROM dblink(:'npl_conn', $q$
  SELECT id, group_id, resource_type::text, resource_id, member_type::text, member_id,
         expires_at, added_by, created_at
  FROM scoped_memberships
$q$) AS t(
  id uuid, group_id uuid, resource_type text, resource_id uuid, member_type text,
  member_id uuid, expires_at timestamptz, added_by uuid, created_at timestamptz
)
LEFT JOIN tmp_user_remap ur
  ON t.member_type = 'user' AND ur.source_system = 'npl' AND ur.source_id = t.member_id
WHERE EXISTS (SELECT 1 FROM groups g WHERE g.id = t.group_id)
  AND (
    t.member_type <> 'user'
    OR EXISTS (SELECT 1 FROM users u WHERE u.id = COALESCE(ur.pm_id, t.member_id))
  )
  -- skip exact resource/member dupes if TRP already inserted a different id
  AND NOT EXISTS (
    SELECT 1 FROM scoped_memberships s
    WHERE s.resource_type = t.resource_type::resource_type_enum
      AND s.resource_id = t.resource_id
      AND s.member_type = t.member_type::member_type_enum
      AND s.member_id = COALESCE(ur.pm_id, t.member_id)
  )
ON CONFLICT (id) DO NOTHING;

SELECT 'groups' AS metric, count(*)::text AS value FROM groups
UNION ALL SELECT 'scoped_memberships', count(*)::text FROM scoped_memberships
UNION ALL SELECT 'user_id_map', count(*)::text FROM user_id_map
ORDER BY 1;
