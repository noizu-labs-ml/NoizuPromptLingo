"""Artifact review system — inline comments and review workflow.

Ported from main's ReviewManager. Uses standalone functions with asyncpg pool.
"""

from __future__ import annotations

from typing import Any, Optional

from npl_mcp.storage import get_pool


async def review_list_by_artifact(
    artifact_id: int,
    limit: int = 50,
) -> dict[str, Any]:
    """List all reviews for a given artifact."""
    pool = await get_pool()
    rows = await pool.fetch(
        """SELECT id, artifact_id, revision_id, reviewer_persona, status,
                  overall_comment, created_at
        FROM npl_reviews
        WHERE artifact_id = $1
        ORDER BY created_at DESC
        LIMIT $2""",
        artifact_id,
        limit,
    )
    return {
        "status": "ok",
        "reviews": [
            {
                "review_id": r["id"],
                "artifact_id": r["artifact_id"],
                "revision_id": r["revision_id"],
                "reviewer_persona": r["reviewer_persona"],
                "review_status": r["status"],
                "overall_comment": r["overall_comment"],
                "created_at": r["created_at"].isoformat() if r["created_at"] else None,
            }
            for r in rows
        ],
    }


async def review_create(
    artifact_id: int,
    revision_id: int,
    reviewer_persona: str,
) -> dict[str, Any]:
    """Start a review session for an artifact revision."""
    pool = await get_pool()
    row = await pool.fetchrow(
        """INSERT INTO npl_reviews (artifact_id, revision_id, reviewer_persona)
        VALUES ($1, $2, $3)
        RETURNING id, artifact_id, revision_id, reviewer_persona, status,
                  overall_comment, created_at""",
        artifact_id,
        revision_id,
        reviewer_persona,
    )
    return {
        "status": "ok",
        "review_id": row["id"],
        "artifact_id": row["artifact_id"],
        "revision_id": row["revision_id"],
        "reviewer_persona": row["reviewer_persona"],
        "review_status": row["status"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }


async def review_add_comment(
    review_id: int,
    location: str,
    comment: str,
    persona: str,
) -> dict[str, Any]:
    """Add an inline comment to a review.

    Args:
        review_id: Review to comment on.
        location: Location descriptor (e.g. "line:58", "@x:100,y:200").
        comment: Comment text.
        persona: Commenting persona slug.
    """
    pool = await get_pool()

    exists = await pool.fetchval(
        "SELECT id FROM npl_reviews WHERE id = $1", review_id
    )
    if not exists:
        return {"status": "not_found", "review_id": review_id}

    row = await pool.fetchrow(
        """INSERT INTO npl_inline_comments (review_id, location, comment, persona)
        VALUES ($1, $2, $3, $4)
        RETURNING id, review_id, location, comment, persona, created_at""",
        review_id,
        location,
        comment,
        persona,
    )
    return {
        "status": "ok",
        "comment_id": row["id"],
        "review_id": row["review_id"],
        "location": row["location"],
        "comment": row["comment"],
        "persona": row["persona"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }


async def review_add_overlay(
    review_id: int,
    x: int,
    y: int,
    comment: str,
    persona: str,
) -> dict[str, Any]:
    """Shorthand for adding an image overlay annotation."""
    return await review_add_comment(
        review_id=review_id,
        location=f"@x:{x},y:{y}",
        comment=comment,
        persona=persona,
    )


async def review_get(
    review_id: int,
    include_comments: bool = True,
) -> dict[str, Any]:
    """Fetch a review, optionally with all inline comments."""
    pool = await get_pool()
    row = await pool.fetchrow(
        """SELECT id, artifact_id, revision_id, reviewer_persona, status,
                  overall_comment, created_at
        FROM npl_reviews WHERE id = $1""",
        review_id,
    )
    if not row:
        return {"status": "not_found", "review_id": review_id}

    result: dict[str, Any] = {
        "status": "ok",
        "review_id": row["id"],
        "artifact_id": row["artifact_id"],
        "revision_id": row["revision_id"],
        "reviewer_persona": row["reviewer_persona"],
        "review_status": row["status"],
        "overall_comment": row["overall_comment"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }

    if include_comments:
        comments = await pool.fetch(
            """SELECT id, location, comment, persona, created_at
            FROM npl_inline_comments
            WHERE review_id = $1
            ORDER BY created_at""",
            review_id,
        )
        result["comments"] = [
            {
                "id": c["id"],
                "location": c["location"],
                "comment": c["comment"],
                "persona": c["persona"],
                "created_at": c["created_at"].isoformat() if c["created_at"] else None,
            }
            for c in comments
        ]

    return result


async def review_complete(
    review_id: int,
    overall_comment: Optional[str] = None,
) -> dict[str, Any]:
    """Mark a review as completed."""
    pool = await get_pool()
    row = await pool.fetchrow(
        """UPDATE npl_reviews
        SET status = 'completed', overall_comment = COALESCE($1, overall_comment)
        WHERE id = $2
        RETURNING id, artifact_id, revision_id, reviewer_persona, status,
                  overall_comment, created_at""",
        overall_comment,
        review_id,
    )
    if not row:
        return {"status": "not_found", "review_id": review_id}

    return {
        "status": "ok",
        "review_id": row["id"],
        "artifact_id": row["artifact_id"],
        "review_status": row["status"],
        "overall_comment": row["overall_comment"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
    }
