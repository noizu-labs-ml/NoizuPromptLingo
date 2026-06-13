"""Secret tools – persist and retrieve named credentials via PostgreSQL.

Secrets are stored as plaintext in the ``npl_secrets`` table.  Access control
is handled at the database level.
"""

import re
from typing import Any

from npl_mcp.storage import get_pool

# Validation
_NAME_RE = re.compile(r"^[a-zA-Z_][a-zA-Z0-9_]*$")
_MAX_NAME_LEN = 128
_MAX_VALUE_LEN = 65_536  # 64 KB


def _validate_name(name: str) -> str | None:
    """Return an error message if *name* is invalid, else ``None``."""
    if not isinstance(name, str) or not name:
        return "Secret name must be a non-empty string."
    if len(name) > _MAX_NAME_LEN:
        return f"Secret name exceeds {_MAX_NAME_LEN} characters."
    if not _NAME_RE.match(name):
        return (
            "Secret name must match [a-zA-Z_][a-zA-Z0-9_]* "
            f"(got {name!r})."
        )
    return None


async def secret_set(name: str, value: str) -> dict[str, Any]:
    """Create or update a named secret.

    Args:
        name: Identifier matching ``[a-zA-Z_][a-zA-Z0-9_]*`` (max 128 chars).
        value: Secret value (max 64 KB).

    Returns:
        ``{name, action: "created"|"updated", status: "ok"}``
    """
    err = _validate_name(name)
    if err:
        return {"name": name, "status": "error", "message": err}

    if not isinstance(value, str):
        return {"name": name, "status": "error", "message": "Secret value must be a string."}
    if len(value) > _MAX_VALUE_LEN:
        return {
            "name": name,
            "status": "error",
            "message": f"Secret value exceeds {_MAX_VALUE_LEN} bytes.",
        }

    pool = await get_pool()
    # UPSERT – xmax = 0 means a fresh insert (no prior row was updated)
    row = await pool.fetchrow(
        """
        INSERT INTO npl_secrets (name, value, created_at, updated_at)
        VALUES ($1, $2, NOW(), NOW())
        ON CONFLICT (name) DO UPDATE
            SET value = EXCLUDED.value, updated_at = NOW()
        RETURNING xmax
        """,
        name,
        value,
    )
    action = "created" if row["xmax"] == 0 else "updated"
    return {"name": name, "action": action, "status": "ok"}


async def secret_get(name: str) -> dict[str, Any]:
    """Retrieve a named secret.

    Args:
        name: Secret identifier.

    Returns:
        ``{name, value, status: "ok"}`` or ``{name, status: "not_found"}``.
    """
    err = _validate_name(name)
    if err:
        return {"name": name, "status": "error", "message": err}

    pool = await get_pool()
    row = await pool.fetchrow(
        "SELECT value FROM npl_secrets WHERE name = $1",
        name,
    )
    if row is None:
        return {"name": name, "status": "not_found"}
    return {"name": name, "value": row["value"], "status": "ok"}


async def get_secrets_batch(names: list[str]) -> dict[str, str]:
    """Fetch multiple secrets by name in one query.

    Args:
        names: List of secret names.

    Returns:
        ``{name: value}`` dict for all names found.
    """
    if not names:
        return {}
    pool = await get_pool()
    rows = await pool.fetch(
        "SELECT name, value FROM npl_secrets WHERE name = ANY($1)",
        names,
    )
    return {r["name"]: r["value"] for r in rows}
