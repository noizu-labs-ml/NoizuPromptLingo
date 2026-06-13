"""Project scoping for tool sessions.

Projects are identified by a deterministic UUID5 derived from their name.
The ``upsert_project`` function ensures the project row exists in the DB
before it is referenced by a session.
"""

import uuid as _uuid_mod

from npl_mcp.storage import get_pool

# Fixed namespace for UUID5 generation — never changes.
NPL_NAMESPACE = _uuid_mod.UUID("a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d")


def project_uuid(name: str) -> _uuid_mod.UUID:
    """Return a deterministic UUID5 for the given project *name*.

    The UUID is derived from ``npl/{name}`` under :data:`NPL_NAMESPACE`.
    """
    return _uuid_mod.uuid5(NPL_NAMESPACE, f"npl/{name}")


async def upsert_project(name: str) -> _uuid_mod.UUID:
    """Ensure a project row exists and return its UUID.

    Uses INSERT ... ON CONFLICT to atomically create or touch the row.
    """
    pid = project_uuid(name)
    pool = await get_pool()
    await pool.execute(
        """
        INSERT INTO npl_projects (id, name, created_at, updated_at)
        VALUES ($1, $2, NOW(), NOW())
        ON CONFLICT (name) DO UPDATE SET updated_at = NOW()
        """,
        pid,
        name,
    )
    return pid
