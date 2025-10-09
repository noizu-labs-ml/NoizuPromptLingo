"""Review system for artifacts with inline comments and annotations."""

import base64
import re
from pathlib import Path
from typing import Optional, Dict, List, Any
from ..storage.db import Database


class ReviewManager:
    """Manages artifact reviews with inline comments and overlays."""

    def __init__(self, db: Database):
        """Initialize review manager.

        Args:
            db: Database instance
        """
        self.db = db

    async def create_review(
        self,
        artifact_id: int,
        revision_id: int,
        reviewer_persona: str
    ) -> Dict[str, Any]:
        """Start a new review for an artifact revision.

        Args:
            artifact_id: ID of the artifact
            revision_id: ID of the specific revision to review
            reviewer_persona: Persona slug of the reviewer

        Returns:
            Dict with review_id and metadata

        Raises:
            ValueError: If artifact or revision not found
        """
        # Verify artifact and revision exist
        revision = await self.db.fetchone(
            """
            SELECT r.* FROM revisions r
            WHERE r.id = ? AND r.artifact_id = ?
            """,
            (revision_id, artifact_id)
        )
        if not revision:
            raise ValueError(f"Revision {revision_id} not found for artifact {artifact_id}")

        # Create review
        cursor = await self.db.execute(
            """
            INSERT INTO reviews (artifact_id, revision_id, reviewer_persona)
            VALUES (?, ?, ?)
            """,
            (artifact_id, revision_id, reviewer_persona)
        )

        review_id = cursor.lastrowid

        return {
            "review_id": review_id,
            "artifact_id": artifact_id,
            "revision_id": revision_id,
            "revision_num": revision["revision_num"],
            "reviewer_persona": reviewer_persona,
            "status": "in_progress"
        }

    async def add_inline_comment(
        self,
        review_id: int,
        location: str,
        comment: str,
        persona: str
    ) -> Dict[str, Any]:
        """Add an inline comment to a review.

        Args:
            review_id: ID of the review
            location: Location string (e.g., "line:58" or "@x:100,y:200")
            comment: Comment text
            persona: Persona slug making the comment

        Returns:
            Dict with comment_id and metadata

        Raises:
            ValueError: If review not found
        """
        # Verify review exists
        review = await self.db.fetchone(
            "SELECT id FROM reviews WHERE id = ?",
            (review_id,)
        )
        if not review:
            raise ValueError(f"Review {review_id} not found")

        # Insert comment
        cursor = await self.db.execute(
            """
            INSERT INTO inline_comments (review_id, location, comment, persona)
            VALUES (?, ?, ?, ?)
            """,
            (review_id, location, comment, persona)
        )

        comment_id = cursor.lastrowid

        return {
            "comment_id": comment_id,
            "review_id": review_id,
            "location": location,
            "comment": comment,
            "persona": persona
        }

    async def add_overlay_annotation(
        self,
        review_id: int,
        x: int,
        y: int,
        comment: str,
        persona: str
    ) -> Dict[str, Any]:
        """Add an image overlay annotation (stores as inline comment + overlay marker).

        Args:
            review_id: ID of the review
            x: X coordinate of annotation
            y: Y coordinate of annotation
            comment: Comment text
            persona: Persona slug making the annotation

        Returns:
            Dict with annotation details
        """
        location = f"@x:{x},y:{y}"
        return await self.add_inline_comment(review_id, location, comment, persona)

    async def get_review(
        self,
        review_id: int,
        include_comments: bool = True
    ) -> Dict[str, Any]:
        """Get a review with all its comments.

        Args:
            review_id: ID of the review
            include_comments: Whether to include inline comments

        Returns:
            Dict with review data and comments

        Raises:
            ValueError: If review not found
        """
        # Get review
        review = await self.db.fetchone(
            """
            SELECT r.*, a.name as artifact_name, a.type as artifact_type,
                   rev.revision_num
            FROM reviews r
            JOIN artifacts a ON r.artifact_id = a.id
            JOIN revisions rev ON r.revision_id = rev.id
            WHERE r.id = ?
            """,
            (review_id,)
        )

        if not review:
            raise ValueError(f"Review {review_id} not found")

        result = dict(review)

        if include_comments:
            comments = await self.db.fetchall(
                """
                SELECT id, location, comment, persona, created_at
                FROM inline_comments
                WHERE review_id = ?
                ORDER BY created_at ASC
                """,
                (review_id,)
            )
            result["comments"] = [dict(c) for c in comments]
        else:
            result["comments"] = []

        return result

    async def generate_annotated_artifact(
        self,
        artifact_id: int,
        revision_id: int
    ) -> Dict[str, Any]:
        """Generate an annotated version of an artifact with all review comments as footnotes.

        Args:
            artifact_id: ID of the artifact
            revision_id: ID of the revision

        Returns:
            Dict with annotated content and per-reviewer files

        Raises:
            ValueError: If artifact/revision not found or is not a text file
        """
        # Get revision info
        revision = await self.db.fetchone(
            """
            SELECT r.*, a.name as artifact_name
            FROM revisions r
            JOIN artifacts a ON r.artifact_id = a.id
            WHERE r.id = ? AND r.artifact_id = ?
            """,
            (revision_id, artifact_id)
        )

        if not revision:
            raise ValueError(f"Revision {revision_id} not found for artifact {artifact_id}")

        # Read original file
        file_path = self.db.data_dir / revision["file_path"]
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            raise ValueError("Cannot annotate binary file")

        # Get all reviews and comments for this revision
        reviews = await self.db.fetchall(
            "SELECT id, reviewer_persona FROM reviews WHERE revision_id = ?",
            (revision_id,)
        )

        all_comments = []
        reviewer_comments = {}  # Group by reviewer

        for review in reviews:
            review_id = review["id"]
            persona = review["reviewer_persona"]

            comments = await self.db.fetchall(
                """
                SELECT location, comment, persona
                FROM inline_comments
                WHERE review_id = ?
                ORDER BY location
                """,
                (review_id,)
            )

            for comment in comments:
                comment_dict = dict(comment)
                all_comments.append(comment_dict)

                if persona not in reviewer_comments:
                    reviewer_comments[persona] = []
                reviewer_comments[persona].append(comment_dict)

        # Generate annotated content
        lines = content.split('\n')
        annotated_lines = []
        footnote_counter = 1
        footnotes = []

        # Extract line-based comments
        line_comments = {}
        for comment in all_comments:
            location = comment["location"]
            if location.startswith("line:"):
                line_num = int(location.split(":")[1])
                if line_num not in line_comments:
                    line_comments[line_num] = []
                line_comments[line_num].append(comment)

        # Add footnotes to lines
        for line_num, line in enumerate(lines, start=1):
            if line_num in line_comments:
                # Add footnote markers for all comments on this line
                markers = []
                for comment in line_comments[line_num]:
                    footnote_id = f"{comment['persona']}-{footnote_counter}"
                    markers.append(f"[^{footnote_id}]")
                    footnotes.append({
                        "id": footnote_id,
                        "persona": comment['persona'],
                        "comment": comment['comment']
                    })
                    footnote_counter += 1

                annotated_lines.append(line + "".join(markers))
            else:
                annotated_lines.append(line)

        # Append footnotes section
        annotated_content = "\n".join(annotated_lines)
        if footnotes:
            annotated_content += "\n\n---\n\n# Review Comments\n\n"
            for footnote in footnotes:
                annotated_content += f"[^{footnote['id']}]: @{footnote['persona']}: {footnote['comment']}\n"

        # Generate per-reviewer inline comment files
        reviewer_files = {}
        for persona, comments in reviewer_comments.items():
            reviewer_content = f"# Inline Comments by @{persona}\n\n"
            for i, comment in enumerate(comments, start=1):
                reviewer_content += f"[^{persona}-{i}]: {comment['location']}: {comment['comment']}\n\n"

            reviewer_content += "---\n\n"
            reviewer_content += f"# Overall Review by @{persona}\n\n"
            reviewer_content += "[Add overall review here]\n"

            reviewer_files[persona] = reviewer_content

        return {
            "artifact_id": artifact_id,
            "artifact_name": revision["artifact_name"],
            "revision_id": revision_id,
            "revision_num": revision["revision_num"],
            "annotated_content": annotated_content,
            "reviewer_files": reviewer_files,
            "total_comments": len(all_comments),
            "reviewers": list(reviewer_comments.keys())
        }

    async def complete_review(
        self,
        review_id: int,
        overall_comment: Optional[str] = None
    ) -> Dict[str, Any]:
        """Mark a review as completed.

        Args:
            review_id: ID of the review
            overall_comment: Optional overall review comment

        Returns:
            Dict with updated review status

        Raises:
            ValueError: If review not found
        """
        review = await self.db.fetchone(
            "SELECT id FROM reviews WHERE id = ?",
            (review_id,)
        )
        if not review:
            raise ValueError(f"Review {review_id} not found")

        await self.db.execute(
            """
            UPDATE reviews
            SET status = 'completed', overall_comment = ?
            WHERE id = ?
            """,
            (overall_comment, review_id)
        )

        return {
            "review_id": review_id,
            "status": "completed",
            "overall_comment": overall_comment
        }
