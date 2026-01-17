#!/usr/bin/env python3
"""NPL Loader with Database Support - Loads NPL from database and outputs formatted markdown."""

from __future__ import annotations

import hashlib
import json
import os
import re
from datetime import datetime
from pathlib import Path
from typing import Any, Optional, Dict, List

import yaml

try:
    import psycopg2
    from psycopg2.extras import Json, RealDictCursor
    HAS_PSYCOPG2 = True
except ImportError:
    HAS_PSYCOPG2 = False


# =============================================================================
# Database Configuration
# =============================================================================

def get_db_config() -> Dict[str, str]:
    """Get database configuration from environment variables."""
    return {
        "host": os.environ.get("NPL_DB_HOST", "localhost"),
        "port": os.environ.get("NPL_DB_PORT", "5432"),
        "database": os.environ.get("NPL_DB_NAME", "npl"),
        "user": os.environ.get("NPL_DB_USER", "npl"),
        "password": os.environ.get("NPL_DB_PASSWORD", "npl_secret"),
    }


def get_db_connection():
    """Get a database connection."""
    if not HAS_PSYCOPG2:
        raise ImportError("psycopg2 is required for database operations. Install with: uv add psycopg2-binary")

    config = get_db_config()
    return psycopg2.connect(**config)


# =============================================================================
# YAML File Operations
# =============================================================================

def load_yaml_file(path: Path) -> Optional[dict]:
    """Load a single YAML file."""
    if path.exists():
        with open(path, "r") as f:
            return yaml.safe_load(f)
    return None


def load_all_yaml_files(npl_dir: Path) -> Dict[str, Dict]:
    """Load all YAML files from the NPL directory recursively."""
    data = {}

    if not npl_dir.exists():
        return data

    for yaml_file in npl_dir.rglob("*.yaml"):
        relative_path = yaml_file.relative_to(npl_dir)
        key = str(relative_path).replace("/", ".").replace(".yaml", "")
        content = load_yaml_file(yaml_file)
        if content:
            # Calculate file digest
            with open(yaml_file, "rb") as f:
                file_digest = hashlib.sha256(f.read()).hexdigest()

            data[key] = {
                "path": str(yaml_file),
                "relative_path": str(relative_path),
                "filename": yaml_file.name,
                "digest": file_digest,
                "content": content
            }

    return data


def slugify(text: str) -> str:
    """Convert text to a slug."""
    text = text.lower()
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s_]+', '-', text)
    return text.strip('-')


def compute_component_digest(component: dict) -> str:
    """Compute SHA256 digest of a component's YAML representation."""
    yaml_str = yaml.dump(component, sort_keys=True, default_flow_style=False)
    return hashlib.sha256(yaml_str.encode()).hexdigest()


def component_to_search_text(component: dict) -> str:
    """Convert component to text for vectorization (without examples)."""
    lines = []

    name = component.get("name", "")
    if name:
        lines.append(f"# {name}")

    brief = component.get("brief", "")
    if brief:
        lines.append(brief)

    description = component.get("description", "").strip()
    if description:
        lines.append(description)

    syntax = component.get("syntax")
    if syntax:
        if isinstance(syntax, str):
            lines.append(f"Syntax: {syntax.strip()}")
        elif isinstance(syntax, list):
            for s in syntax:
                if isinstance(s, dict):
                    lines.append(f"Syntax: {s.get('syntax', '')}")

    labels = component.get("labels", [])
    if labels:
        lines.append(f"Labels: {', '.join(labels)}")

    return "\n".join(lines)


# =============================================================================
# Database Operations
# =============================================================================

def get_metadata(conn, key: str) -> Optional[dict]:
    """Get metadata value from database."""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT value FROM npl_metadata WHERE id = %s", (key,))
        row = cur.fetchone()
        return row["value"] if row else None


def set_metadata(conn, key: str, value: dict):
    """Set metadata value in database."""
    now = datetime.utcnow()
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO npl_metadata (id, value, created_at, modified_at)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (id) DO UPDATE SET
                value = EXCLUDED.value,
                modified_at = EXCLUDED.modified_at
        """, (key, Json(value), now, now))
    conn.commit()


def upsert_component(conn, component_id: str, version: str, section: str,
                     file: str, digest: str, value: dict, search_text: str):
    """Upsert a component into the database."""
    now = datetime.utcnow()
    with conn.cursor() as cur:
        # For now, we don't compute embeddings - just store null for search vector
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
    conn.commit()


def upsert_section(conn, section_id: str, name: str, version: str,
                   files: List[str], digest: str, value: dict):
    """Upsert a section into the database."""
    now = datetime.utcnow()
    with conn.cursor() as cur:
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
    conn.commit()


def upsert_concept(conn, concept_id: str, name: str, version: str,
                   file: str, digest: str, value: dict):
    """Upsert a concept into the database."""
    now = datetime.utcnow()
    with conn.cursor() as cur:
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
    conn.commit()


def mark_deleted_for_file(conn, table: str, file: str, valid_ids: List[str]):
    """Mark entries as deleted if they're from a file but not in valid_ids."""
    now = datetime.utcnow()
    with conn.cursor() as cur:
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
    conn.commit()


def mark_deleted_for_missing_files(conn, table: str, valid_files: List[str]):
    """Mark entries as deleted if their file no longer exists."""
    now = datetime.utcnow()
    with conn.cursor() as cur:
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
    conn.commit()


# =============================================================================
# Populate and Refresh Logic
# =============================================================================

def populate_convention_definitions(conn, npl_dir: Path):
    """Initial population of convention definitions."""
    print("Populating convention definitions...")

    # Load all YAML files
    data = load_all_yaml_files(npl_dir)

    if not data:
        print(f"No YAML files found in {npl_dir}")
        return

    # Prepare convention-definitions metadata
    files_info = []
    for key, file_data in data.items():
        files_info.append({
            "name": file_data["filename"],
            "path": file_data["path"],
            "digest": file_data["digest"]
        })

    convention_def = {
        "updated_on": datetime.utcnow().isoformat(),
        "files": files_info
    }

    # Store convention definitions
    set_metadata(conn, "convention-definitions", convention_def)

    # Process each file
    valid_files = []
    for key, file_data in data.items():
        filename = file_data["filename"]
        valid_files.append(filename)
        content = file_data["content"]

        # Get section info
        section_name = content.get("name", key)
        section_id = content.get("slug", slugify(section_name))
        version = "1.0"

        # Upsert section
        section_digest = compute_component_digest({
            "name": section_name,
            "brief": content.get("brief", ""),
            "description": content.get("description", ""),
            "purpose": content.get("purpose", "")
        })

        upsert_section(conn, section_id, section_name, version,
                      [filename], section_digest, {
                          "name": section_name,
                          "brief": content.get("brief", ""),
                          "description": content.get("description", ""),
                          "purpose": content.get("purpose", "")
                      })

        # Process components
        components = content.get("components", [])
        component_ids = []
        for component in components:
            comp_name = component.get("name", "unknown")
            comp_id = f"{section_id}.{component.get('slug', slugify(comp_name))}"
            component_ids.append(comp_id)

            comp_digest = compute_component_digest(component)
            search_text = component_to_search_text(component)

            upsert_component(conn, comp_id, version, section_id,
                           filename, comp_digest, component, search_text)

        # Mark deleted components for this file
        mark_deleted_for_file(conn, "npl_component", filename, component_ids)

        # Process concepts (from npl.yaml)
        concepts = content.get("concepts", [])
        concept_ids = []
        for concept in concepts:
            concept_name = concept.get("name", "unknown")
            concept_id = f"concept.{slugify(concept_name)}"
            concept_ids.append(concept_id)

            concept_digest = compute_component_digest(concept)

            upsert_concept(conn, concept_id, concept_name, version,
                          filename, concept_digest, concept)

        if concept_ids:
            mark_deleted_for_file(conn, "npl_concepts", filename, concept_ids)

    # Mark entries from non-existent files as deleted
    mark_deleted_for_missing_files(conn, "npl_component", valid_files)
    mark_deleted_for_missing_files(conn, "npl_sections", valid_files)
    mark_deleted_for_missing_files(conn, "npl_concepts", valid_files)

    print(f"Populated {len(data)} files")


def refresh_convention_definitions(conn, npl_dir: Path):
    """Refresh convention definitions - only process changed files."""
    print("Refreshing convention definitions...")

    # Get current convention definitions
    convention_def = get_metadata(conn, "convention-definitions")

    if not convention_def:
        # No existing definitions, do full populate
        return populate_convention_definitions(conn, npl_dir)

    # Build digest map from existing definitions
    existing_digests = {}
    for file_info in convention_def.get("files", []):
        existing_digests[file_info["name"]] = file_info["digest"]

    # Load current YAML files
    data = load_all_yaml_files(npl_dir)

    if not data:
        print(f"No YAML files found in {npl_dir}")
        return

    # Find changed files
    changed_files = []
    new_files = []

    for key, file_data in data.items():
        filename = file_data["filename"]
        current_digest = file_data["digest"]

        if filename not in existing_digests:
            new_files.append(key)
        elif existing_digests[filename] != current_digest:
            changed_files.append(key)

    # Find deleted files
    current_filenames = {file_data["filename"] for file_data in data.values()}
    deleted_files = [f for f in existing_digests.keys() if f not in current_filenames]

    print(f"  New files: {len(new_files)}")
    print(f"  Changed files: {len(changed_files)}")
    print(f"  Deleted files: {len(deleted_files)}")

    # Process new and changed files
    files_to_process = new_files + changed_files
    valid_files = list(current_filenames)

    for key in files_to_process:
        file_data = data[key]
        filename = file_data["filename"]
        content = file_data["content"]

        section_name = content.get("name", key)
        section_id = content.get("slug", slugify(section_name))
        version = "1.0"

        # Upsert section
        section_digest = compute_component_digest({
            "name": section_name,
            "brief": content.get("brief", ""),
            "description": content.get("description", ""),
            "purpose": content.get("purpose", "")
        })

        upsert_section(conn, section_id, section_name, version,
                      [filename], section_digest, {
                          "name": section_name,
                          "brief": content.get("brief", ""),
                          "description": content.get("description", ""),
                          "purpose": content.get("purpose", "")
                      })

        # Process components
        components = content.get("components", [])
        component_ids = []
        for component in components:
            comp_name = component.get("name", "unknown")
            comp_id = f"{section_id}.{component.get('slug', slugify(comp_name))}"
            component_ids.append(comp_id)

            comp_digest = compute_component_digest(component)
            search_text = component_to_search_text(component)

            upsert_component(conn, comp_id, version, section_id,
                           filename, comp_digest, component, search_text)

        mark_deleted_for_file(conn, "npl_component", filename, component_ids)

        # Process concepts
        concepts = content.get("concepts", [])
        concept_ids = []
        for concept in concepts:
            concept_name = concept.get("name", "unknown")
            concept_id = f"concept.{slugify(concept_name)}"
            concept_ids.append(concept_id)

            concept_digest = compute_component_digest(concept)

            upsert_concept(conn, concept_id, concept_name, version,
                          filename, concept_digest, concept)

        if concept_ids:
            mark_deleted_for_file(conn, "npl_concepts", filename, concept_ids)

    # Mark entries from deleted files
    mark_deleted_for_missing_files(conn, "npl_component", valid_files)
    mark_deleted_for_missing_files(conn, "npl_sections", valid_files)
    mark_deleted_for_missing_files(conn, "npl_concepts", valid_files)

    # Update convention definitions metadata
    files_info = []
    for key, file_data in data.items():
        files_info.append({
            "name": file_data["filename"],
            "path": file_data["path"],
            "digest": file_data["digest"]
        })

    convention_def = {
        "updated_on": datetime.utcnow().isoformat(),
        "files": files_info
    }

    set_metadata(conn, "convention-definitions", convention_def)

    print("Refresh complete")


def sync_database(npl_dir: Path):
    """Sync NPL files to database - populate or refresh as needed."""
    conn = get_db_connection()
    try:
        convention_def = get_metadata(conn, "convention-definitions")

        if convention_def is None:
            populate_convention_definitions(conn, npl_dir)
        else:
            refresh_convention_definitions(conn, npl_dir)
    finally:
        conn.close()


# =============================================================================
# Database-driven Output
# =============================================================================

def fetch_all_components(conn) -> Dict[str, List[dict]]:
    """Fetch all non-deleted components grouped by section."""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT id, version, section, file, value
            FROM npl_component
            WHERE deleted_at IS NULL
            ORDER BY section, id
        """)
        rows = cur.fetchall()

    by_section = {}
    for row in rows:
        section = row["section"]
        if section not in by_section:
            by_section[section] = []
        by_section[section].append(row["value"])

    return by_section


def fetch_all_sections(conn) -> List[dict]:
    """Fetch all non-deleted sections."""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT id, name, version, value
            FROM npl_sections
            WHERE deleted_at IS NULL
            ORDER BY id
        """)
        return [dict(row) for row in cur.fetchall()]


def fetch_all_concepts(conn) -> List[dict]:
    """Fetch all non-deleted concepts."""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT id, name, version, value
            FROM npl_concepts
            WHERE deleted_at IS NULL
            ORDER BY id
        """)
        return [dict(row) for row in cur.fetchall()]


def format_component(component: dict, level: int = 3) -> List[str]:
    """Format a single component to markdown lines."""
    lines = []
    heading = "#" * level

    name = component.get("name", "Unknown")
    lines.append(f"{heading} {name}")
    lines.append("")

    brief = component.get("brief", "")
    if brief:
        lines.append(f"*{brief}*")
        lines.append("")

    description = component.get("description", "").strip()
    if description:
        lines.append(description)
        lines.append("")

    syntax = component.get("syntax")
    if syntax:
        if isinstance(syntax, str):
            lines.append("**Syntax**:")
            lines.append("```")
            lines.append(syntax.strip())
            lines.append("```")
            lines.append("")
        elif isinstance(syntax, list):
            lines.append("**Syntax**:")
            lines.append("")
            for s in syntax:
                if isinstance(s, dict):
                    syn_name = s.get("name", "")
                    syn_syntax = s.get("syntax", "")
                    syn_desc = s.get("description", "")
                    if syn_name:
                        lines.append(f"- **{syn_name}**: `{syn_syntax}`")
                        if syn_desc:
                            lines.append(f"  - {syn_desc}")
                else:
                    lines.append(f"- `{s}`")
            lines.append("")

    labels = component.get("labels", [])
    if labels:
        lines.append(f"**Labels**: {', '.join(f'`{l}`' for l in labels)}")
        lines.append("")

    return lines


def format_from_database() -> str:
    """Format NPL output from database."""
    conn = get_db_connection()
    try:
        sections = fetch_all_sections(conn)
        components_by_section = fetch_all_components(conn)
        concepts = fetch_all_concepts(conn)

        lines = []

        # Header
        lines.append("\u231cNPL@1.0\u231d")
        lines.append("# Noizu Prompt Lingua (NPL)")
        lines.append("")
        lines.append("A modular, structured framework for advanced prompt engineering and agent simulation with context-aware loading capabilities.")
        lines.append("")
        lines.append("**Convention**: Additional details and deep-dive instructions are available under `${NPL_HOME}/npl/` and can be loaded on an as-needed basis.")
        lines.append("")

        # Core concepts
        if concepts:
            lines.append("## Core Concepts")
            lines.append("")
            for concept in concepts:
                value = concept["value"]
                concept_name = value.get("name", "")
                concept_desc = value.get("description", "").strip().split("\n")[0]
                concept_purpose = value.get("purpose", "").strip()
                lines.append(f"**{concept_name}**")
                lines.append(f": {concept_desc}")
                if concept_purpose:
                    lines.append(f"  *Purpose*: {concept_purpose.split('.')[0]}.")
                lines.append("")

        # Sections and their components
        for section in sections:
            section_id = section["id"]
            section_value = section["value"]
            section_name = section_value.get("name", section_id)

            lines.append(f"## {section_name.title()}")
            lines.append("")

            brief = section_value.get("brief", "")
            if brief:
                lines.append(f"*{brief}*")
                lines.append("")

            description = section_value.get("description", "").strip()
            if description:
                lines.append(description)
                lines.append("")

            # Components for this section
            section_components = components_by_section.get(section_id, [])
            for component in section_components:
                lines.extend(format_component(component, level=3))

        # Footer
        lines.append("\u231eNPL@1.0\u231f")

        return "\n".join(lines)
    finally:
        conn.close()


# =============================================================================
# Main Entry Point
# =============================================================================

def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description="Load and format NPL YAML files with database support")
    parser.add_argument(
        "--path", "-p",
        type=str,
        default=None,
        help="Path to NPL directory (default: ~/.npl/npl or ./npl)"
    )
    parser.add_argument(
        "--sync",
        action="store_true",
        help="Sync YAML files to database"
    )
    parser.add_argument(
        "--from-db",
        action="store_true",
        help="Output from database instead of YAML files"
    )
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List all YAML files found"
    )

    args = parser.parse_args()

    # Determine NPL directory
    if args.path:
        npl_dir = Path(args.path)
    else:
        home_npl = Path.home() / ".npl" / "npl"
        local_npl = Path.cwd() / "npl"

        if home_npl.exists():
            npl_dir = home_npl
        elif local_npl.exists():
            npl_dir = local_npl
        else:
            if args.from_db:
                # For DB output, we don't need the npl_dir
                npl_dir = None
            else:
                print(f"Error: Could not find NPL directory at {home_npl} or {local_npl}")
                print("Use --path to specify the NPL directory location")
                return 1

    if args.sync:
        if not npl_dir or not npl_dir.exists():
            print(f"Error: NPL directory not found")
            return 1
        sync_database(npl_dir)
        return 0

    if args.from_db:
        output = format_from_database()
        print(output)
        return 0

    if not npl_dir or not npl_dir.exists():
        print(f"Error: NPL directory not found")
        return 1

    # Load all YAML files
    data = load_all_yaml_files(npl_dir)

    if not data:
        print(f"Error: No YAML files found in {npl_dir}")
        return 1

    if args.list:
        print(f"Found {len(data)} YAML files in {npl_dir}:")
        for key, section_data in sorted(data.items()):
            print(f"  - {section_data.get('relative_path', key)} (digest: {section_data['digest'][:8]}...)")
        return 0

    # Default: output formatted markdown from YAML files
    from npl_loader import format_npl_output
    output = format_npl_output(data)
    print(output)
    return 0


if __name__ == "__main__":
    exit(main())
