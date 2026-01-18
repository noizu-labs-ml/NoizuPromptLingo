"""Sync orchestration between YAML and database."""

from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

from .db import DBManager
from .yaml_ops import YAMLLoader
from .refs import ReferenceManager


class SyncManager:
    """Coordinates syncing between YAML files and the database.

    Handles both initial population and incremental refresh of the database
    from YAML source files. Uses digest comparison to detect changes.
    """

    def __init__(self, npl_dir: Path, db: DBManager = None):
        """Initialize sync manager.

        Args:
            npl_dir: Path to the NPL YAML directory
            db: Optional DBManager instance (creates new one if not provided)
        """
        self.npl_dir = npl_dir
        self.db = db if db is not None else DBManager()
        self._owns_db = db is None

    def __enter__(self):
        """Context manager entry - connect to database."""
        self.db.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit - close database connection."""
        self.db.close()
        return False

    def sync(self):
        """Main entry point - determines whether to populate or refresh.

        Checks for existing convention-definitions metadata to decide:
        - If metadata exists: incremental refresh
        - If no metadata: full populate
        """
        convention_def = self.db.get_metadata("convention-definitions")

        if convention_def is None:
            self.populate()
        else:
            self.refresh()

    def populate(self):
        """Full initial population of the database from YAML files.

        Processes all YAML files and inserts/updates all sections,
        components, instructional items, and concepts.
        """
        print("Populating convention definitions...")

        loader = YAMLLoader(self.npl_dir)
        data = loader.load_all()

        if not data:
            print(f"No YAML files found in {self.npl_dir}")
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
        self.db.set_metadata("convention-definitions", convention_def)

        # Extract and store section order
        refs = ReferenceManager(data)
        section_order = refs.get_section_order()
        self.db.set_metadata("section-order", section_order)

        # Process each file
        valid_files = []
        valid_section_ids = []

        for key, file_data in data.items():
            filename = file_data["filename"]
            valid_files.append(filename)
            content = file_data["content"]

            section_name = content.get("name", key)
            section_id = content.get("slug", YAMLLoader.slugify(section_name))
            valid_section_ids.append(section_id)

            self._process_file(filename, section_id, section_name, content)

        # Mark deleted entries
        self.db.mark_deleted_for_missing_files("npl_component", valid_files)
        self.db.mark_deleted_sections_not_in(valid_section_ids)
        self.db.mark_deleted_for_missing_files("npl_concepts", valid_files)

        # Validate references
        refs.validate()

        print(f"Populated {len(data)} files")

    def refresh(self):
        """Incremental refresh - only process files that have changed.

        Compares current file digests with stored digests to identify
        new, changed, and deleted files.
        """
        print("Refreshing convention definitions...")

        # Get existing metadata
        convention_def = self.db.get_metadata("convention-definitions")

        if not convention_def:
            return self.populate()

        # Load current YAML files
        loader = YAMLLoader(self.npl_dir)
        data = loader.load_all()

        if not data:
            print(f"No YAML files found in {self.npl_dir}")
            return

        # Detect changes
        new_files, changed_files, deleted_files = self._detect_changes(convention_def, data)

        print(f"  New files: {len(new_files)}")
        print(f"  Changed files: {len(changed_files)}")
        print(f"  Deleted files: {len(deleted_files)}")

        # Collect all valid section IDs
        valid_section_ids = []
        for key, file_data in data.items():
            content = file_data["content"]
            section_name = content.get("name", key)
            section_id = content.get("slug", YAMLLoader.slugify(section_name))
            valid_section_ids.append(section_id)

        # Process new and changed files
        files_to_process = new_files + changed_files
        valid_files = [file_data["filename"] for file_data in data.values()]

        for key in files_to_process:
            file_data = data[key]
            filename = file_data["filename"]
            content = file_data["content"]

            section_name = content.get("name", key)
            section_id = content.get("slug", YAMLLoader.slugify(section_name))

            self._process_file(filename, section_id, section_name, content)

        # Mark deleted entries
        self.db.mark_deleted_for_missing_files("npl_component", valid_files)
        self.db.mark_deleted_sections_not_in(valid_section_ids)
        self.db.mark_deleted_for_missing_files("npl_concepts", valid_files)

        # Update metadata
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

        self.db.set_metadata("convention-definitions", convention_def)

        # Update section order
        refs = ReferenceManager(data)
        section_order = refs.get_section_order()
        self.db.set_metadata("section-order", section_order)

        # Validate references
        refs.validate()

    def _detect_changes(self, existing_meta: Dict, current_data: Dict) -> Tuple[List[str], List[str], List[str]]:
        """Detect new, changed, and deleted files.

        Args:
            existing_meta: Convention-definitions metadata from database
            current_data: Current data from YAMLLoader.load_all()

        Returns:
            Tuple of (new_files, changed_files, deleted_files)
            where each is a list of file keys/names
        """
        # Build digest map from existing metadata
        existing_digests = {}
        for file_info in existing_meta.get("files", []):
            existing_digests[file_info["name"]] = file_info["digest"]

        new_files = []
        changed_files = []

        for key, file_data in current_data.items():
            filename = file_data["filename"]
            current_digest = file_data["digest"]

            if filename not in existing_digests:
                new_files.append(key)
            elif existing_digests[filename] != current_digest:
                changed_files.append(key)

        # Find deleted files
        current_filenames = {file_data["filename"] for file_data in current_data.values()}
        deleted_files = [f for f in existing_digests.keys() if f not in current_filenames]

        return new_files, changed_files, deleted_files

    def _process_file(self, filename: str, section_id: str, section_name: str, content: Dict):
        """Process a single file - upsert section, components, and concepts.

        Args:
            filename: YAML filename
            section_id: Section slug/ID
            section_name: Section display name
            content: File content dict
        """
        version = "1.0"
        refs = ReferenceManager({})

        # Upsert section
        section_value = {
            "name": section_name,
            "brief": content.get("brief", ""),
            "description": content.get("description", ""),
            "purpose": content.get("purpose", "")
        }
        section_digest = YAMLLoader(self.npl_dir).compute_digest(section_value)

        self.db.upsert_section(
            section_id, section_name, version,
            [filename], section_digest, section_value
        )

        # Process components and instructional items
        component_ids = []

        # Regular components
        for component in content.get("components", []):
            comp_name = component.get("name", "unknown")
            comp_id = f"{section_id}.{component.get('slug', YAMLLoader.slugify(comp_name))}"
            component_ids.append(comp_id)

            comp_digest = YAMLLoader(self.npl_dir).compute_digest(component)
            search_text = refs.component_to_search_text(component)

            self.db.upsert_component(
                comp_id, version, section_id,
                filename, comp_digest, component, search_text
            )

        # Instructional items - add _instructional flag
        for component in content.get("instructional", []):
            comp_name = component.get("name", "unknown")
            comp_id = f"{section_id}.{component.get('slug', YAMLLoader.slugify(comp_name))}"
            component_ids.append(comp_id)

            component_with_flag = {**component, "_instructional": True}
            comp_digest = YAMLLoader(self.npl_dir).compute_digest(component_with_flag)
            search_text = refs.component_to_search_text(component)

            self.db.upsert_component(
                comp_id, version, section_id,
                filename, comp_digest, component_with_flag, search_text
            )

        # Mark deleted components for this file
        self.db.mark_deleted_for_file("npl_component", filename, component_ids)

        # Process concepts
        concepts = content.get("concepts", [])
        concept_ids = []

        for concept in concepts:
            concept_name = concept.get("name", "unknown")
            concept_id = f"concept.{YAMLLoader.slugify(concept_name)}"
            concept_ids.append(concept_id)

            concept_digest = YAMLLoader(self.npl_dir).compute_digest(concept)

            self.db.upsert_concept(
                concept_id, concept_name, version,
                filename, concept_digest, concept
            )

        if concept_ids:
            self.db.mark_deleted_for_file("npl_concepts", filename, concept_ids)
