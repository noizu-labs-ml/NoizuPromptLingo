-- =============================================================================
-- 03_validate.sql — count comparison templates (staging only)
-- =============================================================================
-- Compare source row counts vs pm_core after ETL. All multi-DB queries assume
-- you have wired FDW/dblink or staging copies:
--   npl_remote.*  ← SOURCE_NPL_URL (tobor_locker)
--   trp_remote.*  ← SOURCE_TRP_URL (therobotplans)
--
-- Until FDW exists, run the "source side" SELECTs on each source DB and the
-- "target side" SELECTs on PM_CORE_URL, then diff offline.
--
-- Do NOT run against production as a write path (reads only; still avoid prod).
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Map coverage
-- ---------------------------------------------------------------------------
SELECT source_system, COUNT(*) AS mapped_users
FROM user_id_map
GROUP BY source_system
ORDER BY source_system;

SELECT source_system, COUNT(*) AS mapped_orgs
FROM org_id_map
GROUP BY source_system
ORDER BY source_system;

SELECT source_system, COUNT(*) AS mapped_projects
FROM project_id_map
GROUP BY source_system
ORDER BY source_system;

SELECT source_system, COUNT(*) AS mapped_items
FROM item_id_map
GROUP BY source_system
ORDER BY source_system;

-- Duplicate pm_id fan-in (expected when NPL merges into TRP UUID)
SELECT pm_id, COUNT(*) AS sources
FROM user_id_map
GROUP BY pm_id
HAVING COUNT(*) > 1
ORDER BY sources DESC
LIMIT 50;

-- ---------------------------------------------------------------------------
-- Target-only counts (always safe on pm_core)
-- ---------------------------------------------------------------------------
SELECT 'users' AS entity, COUNT(*) AS n FROM users
UNION ALL
SELECT 'organizations', COUNT(*) FROM organizations
UNION ALL
SELECT 'projects', COUNT(*) FROM projects
UNION ALL
SELECT 'items', COUNT(*) FROM items
UNION ALL
SELECT 'item_queues', COUNT(*) FROM item_queues
UNION ALL
SELECT 'item_type_definitions', COUNT(*) FROM item_type_definitions
UNION ALL
SELECT 'item_field_definitions', COUNT(*) FROM item_field_definitions
UNION ALL
SELECT 'board_stages', COUNT(*) FROM board_stages
UNION ALL
SELECT 'board_iterations', COUNT(*) FROM board_iterations
-- TODO: add artifacts / wiki / personas / polymorphic when those steps run
ORDER BY entity;

-- ---------------------------------------------------------------------------
-- Source vs target templates (uncomment when FDW/staging is available)
-- ---------------------------------------------------------------------------

/*
-- Users: sources should be ≤ target maps + intentional merges
SELECT 'npl_users' AS src, COUNT(*) FROM npl_remote.users
UNION ALL
SELECT 'trp_users', COUNT(*) FROM trp_remote.users
UNION ALL
SELECT 'pm_users', COUNT(*) FROM users
UNION ALL
SELECT 'user_id_map', COUNT(*) FROM user_id_map;

-- Orgs
SELECT 'npl_orgs' AS src, COUNT(*) FROM npl_remote.organizations
UNION ALL
SELECT 'trp_orgs', COUNT(*) FROM trp_remote.organizations
UNION ALL
SELECT 'pm_orgs', COUNT(*) FROM organizations
UNION ALL
SELECT 'org_id_map', COUNT(*) FROM org_id_map;

-- Projects
SELECT 'npl_projects' AS src, COUNT(*) FROM npl_remote.projects
UNION ALL
SELECT 'trp_projects', COUNT(*) FROM trp_remote.projects
UNION ALL
SELECT 'pm_projects', COUNT(*) FROM projects
UNION ALL
SELECT 'project_id_map', COUNT(*) FROM project_id_map;

-- Work items: NPL tickets + TRP items → pm items
SELECT 'npl_tickets' AS src, COUNT(*) FROM npl_remote.tickets
UNION ALL
SELECT 'trp_items', COUNT(*) FROM trp_remote.items
UNION ALL
SELECT 'pm_items', COUNT(*) FROM items
UNION ALL
SELECT 'item_id_map_npl', COUNT(*) FROM item_id_map WHERE source_system = 'npl'
UNION ALL
SELECT 'item_id_map_trp', COUNT(*) FROM item_id_map WHERE source_system = 'trp';

-- Expectation sketch (operator-adjusted for intentional skips):
--   item_id_map npl count ≈ npl_tickets
--   item_id_map trp count ≈ trp_items
--   pm items count ≈ unique pm_ids in item_id_map
--     (less than npl+trp when collisions merge NPL→TRP UUID)
*/

-- ---------------------------------------------------------------------------
-- Orphan FK spot-checks (target)
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS items_missing_org
FROM items i
LEFT JOIN organizations o ON o.id = i.organization_id
WHERE o.id IS NULL;

SELECT COUNT(*) AS items_bad_project
FROM items i
LEFT JOIN projects p ON p.id = i.project_id
WHERE i.project_id IS NOT NULL AND p.id IS NULL;

SELECT COUNT(*) AS items_bad_parent
FROM items i
LEFT JOIN items p ON p.id = i.parent_id
WHERE i.parent_id IS NOT NULL AND p.id IS NULL;

SELECT COUNT(*) AS items_bad_queue
FROM items i
LEFT JOIN item_queues q ON q.id = i.queue_id
WHERE i.queue_id IS NOT NULL AND q.id IS NULL;

-- ---------------------------------------------------------------------------
-- Human keys / counters (after step 8 rebuild)
-- ---------------------------------------------------------------------------
-- TODO: after rebuilding item_number_counters from max(number):
-- SELECT project_id, MAX(number) AS max_num
-- FROM items
-- WHERE number IS NOT NULL
-- GROUP BY project_id
-- ORDER BY project_id
-- LIMIT 50;
--
-- Compare to counter table rows for the same scopes.

-- ---------------------------------------------------------------------------
-- Sample semantic checks (manual)
-- ---------------------------------------------------------------------------
-- 1) Pick an NPL ticket UUID known from census; resolve via item_id_map; open in TRP UI.
-- 2) Pick a TRP epic with children; confirm parent_id graph intact in pm_core.
-- 3) Confirm ticket_type values landed as item_type (no residual ticket_type column).

SELECT DISTINCT item_type, COUNT(*) AS n
FROM items
GROUP BY item_type
ORDER BY n DESC;
