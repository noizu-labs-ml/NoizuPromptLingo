"""Artifact and revision management."""

import base64
import json
import yaml
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List, Any
from ..storage.db import Database


class ArtifactManager:
    """Manages artifacts and their revisions."""

    def __init__(self, db: Database):
        """Initialize artifact manager.

        Args:
            db: Database instance
        """
        self.db = db

    async def create_artifact(
        self,
        name: str,
        artifact_type: str,
        file_content: bytes,
        filename: str,
        created_by: Optional[str] = None,
        purpose: Optional[str] = None
    ) -> Dict[str, Any]:
        """Create a new artifact with initial revision.

        Args:
            name: Unique name for the artifact
            artifact_type: Type (document, image, code, data, etc.)
            file_content: Binary content of the file
            filename: Original filename
            created_by: Persona slug of creator
            purpose: Purpose/description of the artifact

        Returns:
            Dict with artifact_id, revision_id, and paths

        Raises:
            ValueError: If artifact with this name already exists
        """
        # Check if artifact already exists
        existing = await self.db.fetchone(
            "SELECT id FROM artifacts WHERE name = ?",
            (name,)
        )
        if existing:
            raise ValueError(f"Artifact '{name}' already exists")

        # Create artifact record
        cursor = await self.db.execute(
            """
            INSERT INTO artifacts (name, type)
            VALUES (?, ?)
            """,
            (name, artifact_type)
        )
        artifact_id = cursor.lastrowid

        # Create initial revision (revision 0)
        revision_result = await self.add_revision(
            artifact_id=artifact_id,
            file_content=file_content,
            filename=filename,
            created_by=created_by,
            purpose=purpose or "Initial version"
        )

        # Update artifact's current_revision_id
        await self.db.execute(
            "UPDATE artifacts SET current_revision_id = ? WHERE id = ?",
            (revision_result["revision_id"], artifact_id)
        )

        return {
            "artifact_id": artifact_id,
            "artifact_name": name,
            "artifact_type": artifact_type,
            "revision_id": revision_result["revision_id"],
            "revision_num": 0,
            "file_path": str(revision_result["file_path"]),
            "meta_path": str(revision_result["meta_path"])
        }

    async def add_revision(
        self,
        artifact_id: int,
        file_content: bytes,
        filename: str,
        created_by: Optional[str] = None,
        purpose: Optional[str] = None,
        notes: Optional[str] = None
    ) -> Dict[str, Any]:
        """Add a new revision to an artifact.

        Args:
            artifact_id: ID of the artifact
            file_content: Binary content of the file
            filename: Filename for this revision
            created_by: Persona slug of creator
            purpose: Purpose of this revision
            notes: Additional notes

        Returns:
            Dict with revision_id, revision_num, and paths

        Raises:
            ValueError: If artifact doesn't exist
        """
        # Get artifact info
        artifact = await self.db.fetchone(
            "SELECT name, type FROM artifacts WHERE id = ?",
            (artifact_id,)
        )
        if not artifact:
            raise ValueError(f"Artifact with id {artifact_id} not found")

        artifact_name = artifact["name"]

        # Get next revision number
        max_rev = await self.db.fetchone(
            "SELECT MAX(revision_num) as max_num FROM revisions WHERE artifact_id = ?",
            (artifact_id,)
        )
        max_num = max_rev["max_num"] if max_rev and max_rev["max_num"] is not None else -1
        revision_num = max_num + 1

        # Save file
        file_path = self.db.get_artifact_path(artifact_name, revision_num, filename)
        with open(file_path, 'wb') as f:
            f.write(file_content)

        # Create metadata file
        meta_path = self.db.get_artifact_meta_path(artifact_name, revision_num)
        metadata = {
            "revision": revision_num,
            "artifact_name": artifact_name,
            "created_by": created_by or "unknown",
            "created_at": datetime.now().isoformat(),
            "purpose": purpose or "",
            "filename": filename
        }

        with open(meta_path, 'w') as f:
            f.write("---\n")
            yaml.dump(metadata, f, default_flow_style=False)
            f.write("---\n\n")
            if notes:
                f.write(f"# Notes\n\n{notes}\n")

        # Store relative paths
        rel_file_path = file_path.relative_to(self.db.data_dir)
        rel_meta_path = meta_path.relative_to(self.db.data_dir)

        # Insert revision record
        cursor = await self.db.execute(
            """
            INSERT INTO revisions
            (artifact_id, revision_num, created_by, file_path, meta_path, purpose, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (artifact_id, revision_num, created_by, str(rel_file_path),
             str(rel_meta_path), purpose, notes)
        )

        revision_id = cursor.lastrowid

        return {
            "revision_id": revision_id,
            "revision_num": revision_num,
            "file_path": file_path,
            "meta_path": meta_path
        }

    async def get_artifact(
        self,
        artifact_id: int,
        revision: Optional[int] = None
    ) -> Dict[str, Any]:
        """Get artifact and its revision content.

        Args:
            artifact_id: ID of the artifact
            revision: Specific revision number (None for current)

        Returns:
            Dict with artifact info and file content

        Raises:
            ValueError: If artifact or revision not found
        """
        # Get artifact
        artifact = await self.db.fetchone(
            "SELECT * FROM artifacts WHERE id = ?",
            (artifact_id,)
        )
        if not artifact:
            raise ValueError(f"Artifact with id {artifact_id} not found")

        # Get revision
        if revision is None:
            # Get current revision
            revision_id = artifact["current_revision_id"]
            if not revision_id:
                raise ValueError(f"Artifact {artifact_id} has no revisions")

            revision_data = await self.db.fetchone(
                "SELECT * FROM revisions WHERE id = ?",
                (revision_id,)
            )
        else:
            revision_data = await self.db.fetchone(
                "SELECT * FROM revisions WHERE artifact_id = ? AND revision_num = ?",
                (artifact_id, revision)
            )

        if not revision_data:
            raise ValueError(f"Revision {revision} not found for artifact {artifact_id}")

        # Read file content
        file_path = self.db.data_dir / revision_data["file_path"]
        with open(file_path, 'rb') as f:
            file_content = f.read()

        # Read metadata
        meta_path = self.db.data_dir / revision_data["meta_path"]
        with open(meta_path, 'r') as f:
            meta_content = f.read()

        return {
            "artifact_id": artifact_id,
            "artifact_name": artifact["name"],
            "artifact_type": artifact["type"],
            "revision_id": revision_data["id"],
            "revision_num": revision_data["revision_num"],
            "created_by": revision_data["created_by"],
            "created_at": revision_data["created_at"],
            "purpose": revision_data["purpose"],
            "file_content": base64.b64encode(file_content).decode('utf-8'),
            "file_path": str(file_path),
            "metadata": meta_content
        }

    async def list_artifacts(self) -> List[Dict[str, Any]]:
        """List all artifacts.

        Returns:
            List of artifact dicts
        """
        rows = await self.db.fetchall(
            """
            SELECT a.id, a.name, a.type, a.created_at, a.current_revision_id,
                   r.revision_num as current_revision
            FROM artifacts a
            LEFT JOIN revisions r ON a.current_revision_id = r.id
            ORDER BY a.created_at DESC
            """
        )

        return [dict(row) for row in rows]

    async def get_artifact_history(self, artifact_id: int) -> List[Dict[str, Any]]:
        """Get revision history for an artifact.

        Args:
            artifact_id: ID of the artifact

        Returns:
            List of revision dicts

        Raises:
            ValueError: If artifact not found
        """
        # Verify artifact exists
        artifact = await self.db.fetchone(
            "SELECT name FROM artifacts WHERE id = ?",
            (artifact_id,)
        )
        if not artifact:
            raise ValueError(f"Artifact with id {artifact_id} not found")

        rows = await self.db.fetchall(
            """
            SELECT id, revision_num, created_by, created_at, purpose
            FROM revisions
            WHERE artifact_id = ?
            ORDER BY revision_num DESC
            """,
            (artifact_id,)
        )

        return [dict(row) for row in rows]
