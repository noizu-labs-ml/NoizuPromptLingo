"""Database connection and CRUD operations."""

from datetime import datetime
from typing import Dict, List, Optional

try:
    import psycopg2
    from psycopg2.extras import Json, RealDictCursor
    HAS_PSYCOPG2 = True
except ImportError:
    HAS_PSYCOPG2 = False

from .config import Config


class DBManager:
    """Database connection and CRUD operations with context manager support."""

    def __init__(self, config: Dict[str, str] = None):
        """Initialize with optional custom config.

        Args:
            config: Database config dict, or None to use Config class defaults
        """
        if config is None:
            self.config = Config().to_dict()
        else:
            self.config = config
        self.conn = None

    def __enter__(self):
        """Connect to database on context enter."""
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Close connection on context exit."""
        self.close()
        return False

    def connect(self):
        """Establish database connection."""
        if not HAS_PSYCOPG2:
            raise ImportError(
                "psycopg2 is required for database operations. "
                "Install with: uv add psycopg2-binary"
            )
        self.conn = psycopg2.connect(**self.config)

    def close(self):
        """Close database connection."""
        if self.conn:
            self.conn.close()
            self.conn = None

    # -------------------------------------------------------------------------
    # Metadata Operations
    # -------------------------------------------------------------------------

    def get_metadata(self, key: str) -> Optional[dict]:
        """Get metadata value by key.

        Args:
            key: Metadata key (e.g., "section-order")

        Returns:
            JSON value as dict, or None if not found
        """
        with self.conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT value FROM npl_metadata WHERE id = %s", (key,))
            row = cur.fetchone()
            return row["value"] if row else None

    def set_metadata(self, key: str, value: dict):
        """Set metadata value (upsert).

        Args:
            key: Metadata key
            value: JSON-serializable dict
        """
        now = datetime.utcnow()
        with self.conn.cursor() as cur:
            cur.execute("""
                INSERT INTO npl_metadata (id, value, created_at, modified_at)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (id) DO UPDATE SET
                    value = EXCLUDED.value,
                    modified_at = EXCLUDED.modified_at
            """, (key, Json(value), now, now))
        self.conn.commit()

    # -------------------------------------------------------------------------
    # Component Operations
    # -------------------------------------------------------------------------

    def upsert_component(self, component_id: str, version: str, section: str,
                         file: str, digest: str, value: dict, search_text: str):
        """Insert or update a component.

        Args:
            component_id: Unique ID (section.slug format)
            version: NPL version
            section: Parent section ID
            file: Source filename
            digest: Content hash
            value: Full component data as JSON
            search_text: Text for embedding (currently unused)
        """
        now = datetime.utcnow()
        with self.conn.cursor() as cur:
            cur.execute("""
                INSERT INTO npl_component (id, version, section, file, digest, value, created_at, modified_at, deleted_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NULL)
                ON CONFLICT (id) DO UPDATE SET
                    version = EXCLUDED.version,
                    section = EXCLUDED.section,
                    file = EXCLUDED.file,
                    digest = EXCLUDED.digest,
                    value = EXCLUDED.value,
                    modified_at = EXCLUDED.modified_at,
                    deleted_at = NULL
            """, (component_id, version, section, file, digest, Json(value), now, now))
        self.conn.commit()

    # -------------------------------------------------------------------------
    # Section Operations
    # -------------------------------------------------------------------------

    def upsert_section(self, section_id: str, name: str, version: str,
                       files: List[str], digest: str, value: dict):
        """Insert or update a section.

        Args:
            section_id: Section slug
            name: Human-readable name
            version: NPL version
            files: Source filenames
            digest: Content hash
            value: Section metadata as JSON
        """
        now = datetime.utcnow()
        with self.conn.cursor() as cur:
            cur.execute("""
                INSERT INTO npl_sections (id, name, version, files, digest, value, created_at, modified_at, deleted_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NULL)
                ON CONFLICT (id) DO UPDATE SET
                    name = EXCLUDED.name,
                    version = EXCLUDED.version,
                    files = EXCLUDED.files,
                    digest = EXCLUDED.digest,
                    value = EXCLUDED.value,
                    modified_at = EXCLUDED.modified_at,
                    deleted_at = NULL
            """, (section_id, name, version, Json(files), digest, Json(value), now, now))
        self.conn.commit()

    # -------------------------------------------------------------------------
    # Concept Operations
    # -------------------------------------------------------------------------

    def upsert_concept(self, concept_id: str, name: str, version: str,
                       file: str, digest: str, value: dict):
        """Insert or update a concept.

        Args:
            concept_id: Concept ID
            name: Human-readable name
            version: NPL version
            file: Source filename
            digest: Content hash
            value: Concept data as JSON
        """
        now = datetime.utcnow()
        with self.conn.cursor() as cur:
            cur.execute("""
                INSERT INTO npl_concepts (id, name, version, file, digest, value, created_at, modified_at, deleted_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NULL)
                ON CONFLICT (id) DO UPDATE SET
                    name = EXCLUDED.name,
                    version = EXCLUDED.version,
                    file = EXCLUDED.file,
                    digest = EXCLUDED.digest,
                    value = EXCLUDED.value,
                    modified_at = EXCLUDED.modified_at,
                    deleted_at = NULL
            """, (concept_id, name, version, file, digest, Json(value), now, now))
        self.conn.commit()

    # -------------------------------------------------------------------------
    # Soft-Delete Operations
    # -------------------------------------------------------------------------

    def mark_deleted_for_file(self, table: str, file: str, valid_ids: List[str]):
        """Soft-delete entries from a file not in valid_ids.

        Args:
            table: Table name (npl_component or npl_concepts)
            file: Source filename
            valid_ids: IDs that should remain active
        """
        now = datetime.utcnow()
        with self.conn.cursor() as cur:
            if valid_ids:
                cur.execute(f"""
                    UPDATE {table}
                    SET deleted_at = %s
                    WHERE file = %s AND id NOT IN %s AND deleted_at IS NULL
                """, (now, file, tuple(valid_ids)))
            else:
                cur.execute(f"""
                    UPDATE {table}
                    SET deleted_at = %s
                    WHERE file = %s AND deleted_at IS NULL
                """, (now, file))
        self.conn.commit()

    def mark_deleted_for_missing_files(self, table: str, valid_files: List[str]):
        """Soft-delete entries from files that no longer exist.

        Args:
            table: Table name
            valid_files: Filenames that currently exist
        """
        now = datetime.utcnow()
        with self.conn.cursor() as cur:
            if valid_files:
                cur.execute(f"""
                    UPDATE {table}
                    SET deleted_at = %s
                    WHERE file NOT IN %s AND deleted_at IS NULL
                """, (now, tuple(valid_files)))
            else:
                cur.execute(f"""
                    UPDATE {table}
                    SET deleted_at = %s
                    WHERE deleted_at IS NULL
                """, (now,))
        self.conn.commit()

    def mark_deleted_sections_not_in(self, valid_section_ids: List[str]):
        """Soft-delete sections not in valid set.

        Args:
            valid_section_ids: Section IDs that should remain active
        """
        now = datetime.utcnow()
        with self.conn.cursor() as cur:
            if valid_section_ids:
                cur.execute("""
                    UPDATE npl_sections
                    SET deleted_at = %s
                    WHERE id NOT IN %s AND deleted_at IS NULL
                """, (now, tuple(valid_section_ids)))
            else:
                cur.execute("""
                    UPDATE npl_sections
                    SET deleted_at = %s
                    WHERE deleted_at IS NULL
                """, (now,))
        self.conn.commit()

    # -------------------------------------------------------------------------
    # Query Operations
    # -------------------------------------------------------------------------

    def fetch_sections(self) -> List[dict]:
        """Fetch all active sections."""
        with self.conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, name, version, value
                FROM npl_sections
                WHERE deleted_at IS NULL
                ORDER BY id
            """)
            return [dict(row) for row in cur.fetchall()]

    def fetch_components(self) -> List[dict]:
        """Fetch all active components."""
        with self.conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, version, section, file, value
                FROM npl_component
                WHERE deleted_at IS NULL
                ORDER BY section, id
            """)
            return [dict(row) for row in cur.fetchall()]

    def fetch_concepts(self) -> List[dict]:
        """Fetch all active concepts."""
        with self.conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, name, version, value
                FROM npl_concepts
                WHERE deleted_at IS NULL
                ORDER BY id
            """)
            return [dict(row)["value"] for row in cur.fetchall()]

    def load_from_database(self) -> Dict[str, Dict]:
        """Load NPL data from database into structure matching YAMLLoader.load_all().

        Returns:
            Dict keyed by section slug with content dicts containing
            name, slug, brief, description, purpose, components, instructional
        """
        sections = self.fetch_sections()
        components = self.fetch_components()
        concepts = self.fetch_concepts()
        section_order = self.get_metadata("section-order")

        return self.reconstruct_data(sections, components, concepts, section_order)

    @staticmethod
    def reconstruct_data(sections: List[dict], components: List[dict],
                         concepts: List[dict], section_order: Optional[dict] = None) -> Dict[str, Dict]:
        """Transform raw database records into YAMLLoader-compatible structure.

        This pure transformation method can be tested with stubbed data.

        Args:
            sections: List of section records with id, name, version, value
            components: List of component records with id, section, value
            concepts: List of concept value dicts
            section_order: Optional section order metadata

        Returns:
            Dict keyed by section slug with content dicts
        """
        # Group components by section
        components_by_section = {}
        for row in components:
            section = row["section"]
            if section not in components_by_section:
                components_by_section[section] = []
            components_by_section[section].append(row["value"])

        # Build data structure
        data = {}
        for section in sections:
            section_id = section["id"]
            section_value = section["value"]

            # Separate components and instructional by _instructional flag
            all_items = components_by_section.get(section_id, [])
            regular_components = []
            instructional = []

            for item in all_items:
                if item.get("_instructional"):
                    # Remove internal flag
                    item_copy = {k: v for k, v in item.items() if k != "_instructional"}
                    instructional.append(item_copy)
                else:
                    regular_components.append(item)

            content = {
                "name": section_value.get("name", section_id),
                "slug": section_id,
                "brief": section_value.get("brief", ""),
                "description": section_value.get("description", ""),
                "purpose": section_value.get("purpose", ""),
                "components": regular_components,
                "instructional": instructional,
            }

            # Add concepts to npl section
            if section_id == "npl" and concepts:
                content["concepts"] = concepts

            data[section_id] = {"content": content}

        # Add section order to npl section if available
        if section_order and "npl" in data:
            data["npl"]["content"]["npl"] = {"section_order": section_order}

        return data
