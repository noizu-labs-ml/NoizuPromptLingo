"""Structured error logging for MCP tool invocations."""
import traceback
from typing import Optional
from npl_mcp.storage.pool import get_pool


async def log_tool_error(
    tool_name: str,
    exc: BaseException,
    session_id: Optional[str] = None,
) -> None:
    """Record a tool-call error. Best-effort — swallows DB errors."""
    try:
        pool = await get_pool()
        async with pool.acquire() as conn:
            stack = "".join(traceback.format_exception(type(exc), exc, exc.__traceback__))[:2048]
            await conn.execute(
                """
                INSERT INTO npl_tool_errors
                    (tool_name, error_type, error_message, session_id, stack_excerpt)
                VALUES ($1, $2, $3, $4, $5)
                """,
                tool_name,
                type(exc).__name__,
                str(exc)[:1024],
                session_id,
                stack,
            )
    except Exception:
        # Never let logging itself fail the tool call
        pass


async def list_tool_errors(limit: int = 50) -> list[dict]:
    """Return recent errors (newest first)."""
    pool = await get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT id, tool_name, error_type, error_message, session_id,
                   stack_excerpt, created_at
            FROM npl_tool_errors
            ORDER BY created_at DESC
            LIMIT $1
            """,
            limit,
        )
        return [
            {
                "id": r["id"],
                "tool_name": r["tool_name"],
                "error_type": r["error_type"],
                "error_message": r["error_message"],
                "session_id": r["session_id"],
                "stack_excerpt": r["stack_excerpt"],
                "created_at": r["created_at"].isoformat() + "Z",
            }
            for r in rows
        ]
