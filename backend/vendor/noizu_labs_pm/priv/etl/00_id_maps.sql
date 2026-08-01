-- =============================================================================
-- 00_id_maps.sql — migration ID maps for pm_core ETL (Phase 4 prep)
-- =============================================================================
-- Target: PM_CORE_URL only. Idempotent: CREATE TABLE IF NOT EXISTS.
-- Do NOT run against production.
--
-- Conventions:
--   source_system  'npl' | 'trp'
--   source_id      UUID in the source DB
--   pm_id          UUID in pm_core (prefer source_id when no collision)
--   notes          operator notes (merge reason, collision, etc.)
-- =============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- user_id_map
-- D1: link by OIDC subject / email → one pm_core user UUID.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_id_map (
  source_system text NOT NULL CHECK (source_system IN ('npl', 'trp')),
  source_id     uuid NOT NULL,
  pm_id         uuid NOT NULL,
  notes         text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source_system, source_id)
);

CREATE INDEX IF NOT EXISTS idx_user_id_map_pm_id ON user_id_map (pm_id);

-- ---------------------------------------------------------------------------
-- org_id_map
-- D2: on collision TRP wins; NPL orgs re-point via this map.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS org_id_map (
  source_system text NOT NULL CHECK (source_system IN ('npl', 'trp')),
  source_id     uuid NOT NULL,
  pm_id         uuid NOT NULL,
  notes         text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source_system, source_id)
);

CREATE INDEX IF NOT EXISTS idx_org_id_map_pm_id ON org_id_map (pm_id);

-- ---------------------------------------------------------------------------
-- project_id_map
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS project_id_map (
  source_system text NOT NULL CHECK (source_system IN ('npl', 'trp')),
  source_id     uuid NOT NULL,
  pm_id         uuid NOT NULL,
  notes         text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source_system, source_id)
);

CREATE INDEX IF NOT EXISTS idx_project_id_map_pm_id ON project_id_map (pm_id);

-- ---------------------------------------------------------------------------
-- item_id_map
-- NPL tickets + TRP items → pm_core items.
-- Prefer preserving UUIDs; on collision keep TRP id, map NPL source_id → that pm_id.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS item_id_map (
  source_system text NOT NULL CHECK (source_system IN ('npl', 'trp')),
  source_id     uuid NOT NULL,
  pm_id         uuid NOT NULL,
  notes         text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source_system, source_id)
);

CREATE INDEX IF NOT EXISTS idx_item_id_map_pm_id ON item_id_map (pm_id);

-- ---------------------------------------------------------------------------
-- Optional re-run helpers (commented — operator-driven)
-- ---------------------------------------------------------------------------
-- Truncate maps only on a disposable target after wiping domain tables:
--   TRUNCATE item_id_map, project_id_map, org_id_map, user_id_map;
--
-- Upsert map row without overwriting an existing decision:
--   INSERT INTO user_id_map (source_system, source_id, pm_id, notes)
--   VALUES ('npl', :source_id, :pm_id, 'initial')
--   ON CONFLICT (source_system, source_id) DO NOTHING;
--
-- Force remap (use sparingly; rewrite FKs first):
--   INSERT INTO user_id_map (source_system, source_id, pm_id, notes)
--   VALUES ('npl', :source_id, :pm_id, 'operator override')
--   ON CONFLICT (source_system, source_id)
--   DO UPDATE SET pm_id = EXCLUDED.pm_id, notes = EXCLUDED.notes;

COMMIT;
