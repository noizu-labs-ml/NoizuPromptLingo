"""Storage package – asyncpg connection pool singleton."""

from .pool import get_pool, close_pool

__all__ = ["get_pool", "close_pool"]
