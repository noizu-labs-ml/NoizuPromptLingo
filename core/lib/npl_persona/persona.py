"""
Persona CRUD operations for npl_persona.

Handles persona lifecycle: init, get, list, remove, which, sync, backup.
"""

import sys
import shutil
import tarfile
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Set

from .config import MANDATORY_FILES, FILE_SIZE_LIMITS
from .models import Persona, PersonaFiles, Scope, HealthReport
from .paths import PathResolver, ResourceType, resolve_persona
from .io import FileManager, FileError, read_file, write_file, ensure_dir
from .templates import (
    generate_persona_definition,
    generate_journal_template,
    generate_tasks_template,
    generate_knowledge_template,
)


class PersonaManager:
    """Manages persona lifecycle operations."""

    def __init__(self):
        """Initialize persona manager."""
        self.resolver = PathResolver(ResourceType.PERSONAS)
        self.file_manager = FileManager()
        self.loaded_personas: Set[str] = set()

    def _check_persona_files(self, persona_id: str, base_path: Path) -> PersonaFiles:
        """Check which mandatory files exist for a persona."""
        files = PersonaFiles()

        for file_type, template in MANDATORY_FILES.items():
            file_path = base_path / template.format(persona_id=persona_id)
            setattr(files, file_type, file_path.exists())

        return files

    def list_personas(self, scope: Optional[str] = None) -> Dict[str, Dict]:
        """
        List all personas, optionally filtered by scope.

        Args:
            scope: Filter by scope (project/user/system/all)

        Returns:
            Dict mapping persona_id to info dict
        """
        personas = {}
        search_paths = self.resolver.get_search_paths()

        for i, base_path in enumerate(search_paths):
            if not base_path.exists():
                continue

            current_scope = self.resolver._index_to_scope(i)

            # Skip if filtering by scope
            if scope and scope != current_scope and scope != "all":
                continue

            for persona_file in base_path.glob("*.persona.md"):
                persona_id = persona_file.stem.replace(".persona", "")

                # First found wins (priority order)
                if persona_id in personas:
                    continue

                personas[persona_id] = {
                    "id": persona_id,
                    "path": base_path,
                    "scope": current_scope,
                    "files": self._check_persona_files(persona_id, base_path).as_dict(),
                }

        return personas

    def init_persona(
        self,
        persona_id: str,
        role: Optional[str] = None,
        scope: str = "project",
        from_template: Optional[str] = None
    ) -> bool:
        """
        Initialize a new persona with all mandatory files.

        Args:
            persona_id: Persona identifier
            role: Role/title for the persona
            scope: Where to create (project/user/system)
            from_template: Copy from existing persona in specified scope

        Returns:
            True on success, False on failure
        """
        target_path = self.resolver.get_target_path(scope)

        # Ensure directory exists
        result = ensure_dir(target_path)
        if result.is_err():
            print(f"Error: {result.error}", file=sys.stderr)
            return False

        # Check if persona already exists
        if (target_path / f"{persona_id}.persona.md").exists():
            print(f"Error: Persona '{persona_id}' already exists at {target_path}", file=sys.stderr)
            return False

        # If from_template specified, copy from existing
        if from_template:
            source_location = self.resolver.resolve(from_template, ".persona.md")
            if not source_location:
                print(f"Error: Template persona '{from_template}' not found", file=sys.stderr)
                return False

            source_path, _ = source_location
            print(f"Copying {source_path}/{from_template}.* → {target_path}/")

            for file_type, template in MANDATORY_FILES.items():
                source_file = source_path / template.format(persona_id=from_template)
                target_file = target_path / template.format(persona_id=persona_id)

                if source_file.exists():
                    copy_result = self.file_manager.copy(source_file, target_file)
                    if copy_result.is_err():
                        print(f"Warning: Failed to copy {file_type}: {copy_result.error}", file=sys.stderr)

            print(f"✨ {scope.capitalize()}-level persona '{persona_id}' created from template")
            return True

        # Create from scratch
        print(f"Creating persona files in {target_path}")

        # Create definition file
        definition_content = generate_persona_definition(persona_id, role)
        definition_file = target_path / f"{persona_id}.persona.md"
        result = write_file(definition_file, definition_content)
        if result.is_err():
            print(f"Error creating definition: {result.error}", file=sys.stderr)
            return False
        print(f"> ✅ {persona_id}.persona.md")

        # Create journal file
        journal_content = generate_journal_template(persona_id)
        journal_file = target_path / f"{persona_id}.journal.md"
        result = write_file(journal_file, journal_content)
        if result.is_err():
            print(f"Error creating journal: {result.error}", file=sys.stderr)
            return False
        print(f"> ✅ {persona_id}.journal.md (empty template)")

        # Create tasks file
        tasks_content = generate_tasks_template(persona_id, role)
        tasks_file = target_path / f"{persona_id}.tasks.md"
        result = write_file(tasks_file, tasks_content)
        if result.is_err():
            print(f"Error creating tasks: {result.error}", file=sys.stderr)
            return False
        print(f"> ✅ {persona_id}.tasks.md (with role defaults)")

        # Create knowledge base file
        knowledge_content = generate_knowledge_template(persona_id, role)
        knowledge_file = target_path / f"{persona_id}.knowledge-base.md"
        result = write_file(knowledge_file, knowledge_content)
        if result.is_err():
            print(f"Error creating knowledge base: {result.error}", file=sys.stderr)
            return False
        print(f"> ✅ {persona_id}.knowledge-base.md (with role expertise)")

        print(f"✨ Persona '{persona_id}' created successfully")
        return True

    def get_persona(
        self,
        persona_id: str,
        files: str = "all",
        skip: Optional[Set[str]] = None
    ) -> bool:
        """
        Load and display persona files.

        Args:
            persona_id: Persona identifier
            files: Comma-separated file types or 'all'
            skip: Set of persona IDs to skip

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location

        # Check skip list
        if skip and persona_id in skip:
            return True

        # Determine which files to load
        if files == "all":
            files_to_load = list(MANDATORY_FILES.keys())
        else:
            files_to_load = [f.strip() for f in files.split(",")]

        # Load and display files
        for file_type in files_to_load:
            if file_type not in MANDATORY_FILES:
                print(f"Warning: Unknown file type '{file_type}'", file=sys.stderr)
                continue

            file_template = MANDATORY_FILES[file_type]
            file_path = base_path / file_template.format(persona_id=persona_id)

            if not file_path.exists():
                print(f"Warning: {file_type} file not found: {file_path}", file=sys.stderr)
                continue

            result = read_file(file_path)
            if result.is_err():
                print(f"Error reading {file_path}: {result.error}", file=sys.stderr)
                continue

            print(f"# {file_type}:{persona_id}:\n{result.value}␜\n")

        # Track loaded persona
        self.loaded_personas.add(persona_id)

        return True

    def which_persona(self, persona_id: str) -> bool:
        """
        Show where a persona is located.

        Args:
            persona_id: Persona identifier

        Returns:
            True if found, False otherwise
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Persona '{persona_id}' not found in search paths")
            return False

        base_path, scope = location
        print(f"Found: {base_path / f'{persona_id}.persona.md'} ({scope} scope)")
        return True

    def remove_persona(
        self,
        persona_id: str,
        scope: Optional[str] = None,
        force: bool = False
    ) -> bool:
        """
        Remove a persona (with confirmation).

        Args:
            persona_id: Persona identifier
            scope: Only delete from specified scope
            force: Skip confirmation prompt

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, found_scope = location

        # Check scope restriction
        if scope and scope != found_scope:
            print(f"Error: Persona found in {found_scope} scope, but {scope} scope specified", file=sys.stderr)
            return False

        # Confirmation unless force
        if not force:
            response = input(f"Delete persona '{persona_id}' from {found_scope} scope? [y/N]: ")
            if response.lower() != "y":
                print("Cancelled")
                return False

        # Remove all persona files
        deleted = []
        for file_type, template in MANDATORY_FILES.items():
            file_path = base_path / template.format(persona_id=persona_id)
            if file_path.exists():
                result = self.file_manager.delete(file_path)
                if result.is_ok():
                    deleted.append(file_path.name)

        if deleted:
            print(f"Deleted: {', '.join(deleted)}")
            print(f"✨ Persona '{persona_id}' removed from {found_scope} scope")
            return True
        else:
            print(f"Warning: No files found for persona '{persona_id}'", file=sys.stderr)
            return False

    def health_check(
        self,
        persona_id: Optional[str] = None,
        verbose: bool = False,
        check_all: bool = False
    ) -> bool:
        """
        Check health of persona files.

        Args:
            persona_id: Specific persona to check
            verbose: Show detailed information
            check_all: Check all personas

        Returns:
            True if healthy, False otherwise
        """
        if check_all:
            personas = self.list_personas("all")
            all_healthy = True

            for pid, info in personas.items():
                report = self._get_health_report(pid, Path(info["path"]), info["scope"])
                self._print_health_report(report, verbose)
                if not report.is_healthy:
                    all_healthy = False

            return all_healthy

        elif persona_id:
            location = resolve_persona(persona_id)
            if not location:
                print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
                return False

            base_path, scope = location
            report = self._get_health_report(persona_id, base_path, scope)
            self._print_health_report(report, verbose)
            return report.is_healthy

        else:
            print("Error: Specify --persona-id or --all", file=sys.stderr)
            return False

    def _get_health_report(self, persona_id: str, base_path: Path, scope: str) -> HealthReport:
        """Generate health report for a persona."""
        files = self._check_persona_files(persona_id, base_path)
        issues = []
        total_size = 0
        file_ages = {}

        for file_type, template in MANDATORY_FILES.items():
            file_path = base_path / template.format(persona_id=persona_id)

            if getattr(files, file_type):
                stat_result = self.file_manager.stat(file_path)
                if stat_result.is_ok():
                    stat = stat_result.value
                    size = stat.st_size
                    total_size += size

                    # Check age
                    mtime = datetime.fromtimestamp(stat.st_mtime)
                    age_days = (datetime.now() - mtime).days
                    file_ages[file_type] = age_days

                    # Check size limits
                    limit = FILE_SIZE_LIMITS.get(file_type, 100 * 1024)
                    if size > limit:
                        issues.append(f"{file_type} exceeds {limit // 1024}KB, consider archiving")
            else:
                issues.append(f"Missing {file_type} file")

        return HealthReport(
            persona_id=persona_id,
            scope=Scope(scope),
            path=base_path,
            files=files,
            total_size=total_size,
            issues=issues,
            file_ages=file_ages,
        )

    def _print_health_report(self, report: HealthReport, verbose: bool) -> None:
        """Print health report to stdout."""
        print(f"\nPERSONA: {report.persona_id}")

        for file_type, template in MANDATORY_FILES.items():
            present = getattr(report.files, file_type)
            file_name = template.format(persona_id=report.persona_id)

            if present:
                age = report.file_ages.get(file_type, 0)
                age_str = f"{age}d ago" if age > 0 else "today"
                status = "✅"

                # Check if there are size warnings
                for issue in report.issues:
                    if file_type in issue and "exceeds" in issue:
                        status = "⚠️"
                        break

                print(f"├── {status} {file_name} ({age_str})")
            else:
                print(f"├── ❌ {file_name} (missing)")

        health_status = "healthy" if report.is_healthy else "needs attention"
        print(f"└── INTEGRITY: {report.health_score:.0f}% {health_status}")

        if report.issues:
            print(f"    ISSUES: {'; '.join(report.issues)}")

        if verbose:
            print(f"    SCOPE: {report.scope.value}")
            print(f"    PATH: {report.path}")
            print(f"    TOTAL SIZE: {report.total_size / 1024:.1f}KB")

    def sync_persona(self, persona_id: str, validate: bool = True) -> bool:
        """
        Sync and validate persona files.

        Args:
            persona_id: Persona identifier
            validate: Whether to validate file structure

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        print(f"Syncing persona: {persona_id}")

        # Check all files exist
        all_exist = True
        for file_type, template in MANDATORY_FILES.items():
            file_path = base_path / template.format(persona_id=persona_id)
            if not file_path.exists():
                print(f"  ❌ Missing: {template.format(persona_id=persona_id)}")
                all_exist = False
            else:
                print(f"  ✅ Found: {template.format(persona_id=persona_id)}")

        if not all_exist:
            print(f"\nError: Not all mandatory files present", file=sys.stderr)
            return False

        # Validate if requested
        if validate:
            print(f"\nValidating files...")

            def_file = base_path / f"{persona_id}.persona.md"
            result = read_file(def_file)
            if result.is_ok():
                content = result.value
                if f"⌜persona:{persona_id}" not in content:
                    print(f"  ⚠️  Definition file missing proper NPL header")
                else:
                    print(f"  ✅ Definition validated")

                # Check file references
                if f"./{persona_id}.journal.md" not in content:
                    print(f"  ⚠️  Missing journal reference in definition")
                if f"./{persona_id}.tasks.md" not in content:
                    print(f"  ⚠️  Missing tasks reference in definition")
                if f"./{persona_id}.knowledge-base.md" not in content:
                    print(f"  ⚠️  Missing knowledge-base reference in definition")

        print(f"\n✅ Sync complete for {persona_id}")
        return True

    def backup_persona(
        self,
        persona_id: Optional[str] = None,
        output: Optional[str] = None,
        backup_all: bool = False
    ) -> bool:
        """
        Backup persona data.

        Args:
            persona_id: Specific persona to backup
            output: Output directory path
            backup_all: Backup all personas

        Returns:
            True on success, False on failure
        """
        if backup_all:
            personas = self.list_personas("all")
            persona_ids = list(personas.keys())
        elif persona_id:
            persona_ids = [persona_id]
        else:
            print("Error: Specify --persona-id or --all", file=sys.stderr)
            return False

        # Create backup directory
        if output:
            backup_dir = Path(output)
        else:
            backup_dir = Path("./backups")

        result = ensure_dir(backup_dir)
        if result.is_err():
            print(f"Error creating backup directory: {result.error}", file=sys.stderr)
            return False

        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        backup_name = f"personas-backup-{timestamp}.tar.gz"
        backup_path = backup_dir / backup_name

        print(f"Creating backup: {backup_path}")

        try:
            with tarfile.open(backup_path, "w:gz") as tar:
                for pid in persona_ids:
                    location = resolve_persona(pid)
                    if not location:
                        print(f"  ⚠️  Skipping {pid}: not found")
                        continue

                    base_path, scope = location
                    print(f"  📦 Backing up {pid} ({scope})")

                    for file_type, template in MANDATORY_FILES.items():
                        file_path = base_path / template.format(persona_id=pid)
                        if file_path.exists():
                            arcname = f"{pid}/{template.format(persona_id=pid)}"
                            tar.add(file_path, arcname=arcname)

            print(f"✅ Backup created: {backup_path}")
            print(f"   Personas: {len(persona_ids)}")
            return True

        except Exception as e:
            print(f"Error creating backup: {e}", file=sys.stderr)
            return False
