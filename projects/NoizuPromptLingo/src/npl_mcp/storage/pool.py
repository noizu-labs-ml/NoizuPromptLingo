"""Asyncpg connection pool singleton with lazy initialization.

Configuration via environment variables:
    NPL_DB_HOST     (default: localhost)
    NPL_DB_PORT     (default: 5111)
    NPL_DB_NAME     (default: npl)
    NPL_DB_USER     (default: npl)
    NPL_DB_PASSWORD  (default: npl)
"""

import os
from typing import Optional

import asyncpg

_pool: Optional[asyncpg.Pool] = None


async def get_pool() -> asyncpg.Pool:
    """Return the shared connection pool, creating it on first call."""
    global _pool
    if _pool is None:
        _pool = await asyncpg.create_pool(
            host=os.environ.get("NPL_DB_HOST", "localhost"),
            port=int(os.environ.get("NPL_DB_PORT", "5111")),
            database=os.environ.get("NPL_DB_NAME", "npl"),
            user=os.environ.get("NPL_DB_USER", "npl"),
            password=os.environ.get("NPL_DB_PASSWORD", "npl"),
            min_size=1,
            max_size=5,
        )
    return _pool


async def close_pool() -> None:
    """Close the pool if it was created."""
    global _pool
    if _pool is not None:
        await _pool.close()
        _pool = None
