"""Storage helpers for tool-call and LLM-call metrics tables."""

from __future__ import annotations

from typing import Optional

from npl_mcp.storage.pool import get_pool


# ---------------------------------------------------------------------------
# Insert helpers
# ---------------------------------------------------------------------------


async def record_tool_call(
    tool_name: str,
    *,
    arguments: Optional[str] = None,
    result_summary: Optional[str] = None,
    response_time_ms: Optional[int] = None,
    error: Optional[str] = None,
    session_id: Optional[str] = None,
) -> None:
    """Record a tool invocation. Best-effort -- swallows DB errors."""
    try:
        pool = await get_pool()
        async with pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO npl_tool_calls
                    (tool_name, session_id, arguments, result_summary,
                     response_time_ms, error)
                VALUES ($1, $2, $3, $4, $5, $6)
                """,
                tool_name,
                session_id,
                (arguments or "")[:4096],
                (result_summary or "")[:2048],
                response_time_ms,
                (error or "")[:2048] if error else None,
            )
    except Exception:
        # Never let metric logging break the caller
        pass


async def record_llm_call(
    model: str,
    *,
    purpose: Optional[str] = None,
    prompt_tokens: Optional[int] = None,
    completion_tokens: Optional[int] = None,
    total_tokens: Optional[int] = None,
    latency_ms: Optional[int] = None,
    session_id: Optional[str] = None,
) -> None:
    """Record an LLM invocation. Best-effort -- swallows DB errors."""
    try:
        pool = await get_pool()
        async with pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO npl_llm_calls
                    (model, purpose, prompt_tokens, completion_tokens,
                     total_tokens, latency_ms, session_id)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                """,
                model,
                purpose,
                prompt_tokens,
                completion_tokens,
                total_tokens,
                latency_ms,
                session_id,
            )
    except Exception:
        pass


# ---------------------------------------------------------------------------
# Query helpers
# ---------------------------------------------------------------------------


async def list_tool_calls(limit: int = 20) -> dict:
    """Return recent tool calls (newest first) in MetricListResult shape."""
    pool = await get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT id, tool_name, session_id, response_time_ms, error,
                   called_at
            FROM npl_tool_calls
            ORDER BY called_at DESC
            LIMIT $1
            """,
            limit,
        )
        items = [
            {
                "id": r["id"],
                "tool_name": r["tool_name"],
                "status": "error" if r["error"] else "ok",
                "response_time_ms": r["response_time_ms"],
                "session_id": r["session_id"],
                "created_at": r["called_at"].isoformat() + "Z"
                if r["called_at"]
                else None,
            }
            for r in rows
        ]
        return {"items": items, "count": len(items)}


async def list_llm_calls(limit: int = 20) -> dict:
    """Return recent LLM calls (newest first) in MetricListResult shape."""
    pool = await get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT id, model, purpose, prompt_tokens, completion_tokens,
                   latency_ms, session_id, called_at
            FROM npl_llm_calls
            ORDER BY called_at DESC
            LIMIT $1
            """,
            limit,
        )
        items = [
            {
                "id": r["id"],
                "model": r["model"],
                "purpose": r["purpose"],
                "tokens_in": r["prompt_tokens"],
                "tokens_out": r["completion_tokens"],
                "duration_ms": r["latency_ms"],
                "session_id": r["session_id"],
                "created_at": r["called_at"].isoformat() + "Z"
                if r["called_at"]
                else None,
            }
            for r in rows
        ]
        return {"items": items, "count": len(items)}
