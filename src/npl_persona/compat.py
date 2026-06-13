"""
Compatibility layer for npl_persona.

Provides the NPLPersona class that wraps the new modular managers,
exposing the old interface for backwards compatibility and tests.

This implementation allows tests to override path resolution by setting
custom functions on the instance.
"""

import sys
from datetime import datetime
from pathlib import Path
from typing import Callable, Dict, List, Optional, Set, Tuple

from .config import MANDATORY_FILES, DATE_FORMAT, TABLE_MARKERS, SECTIONS, STATUS_ICONS, VALID_STATUSES
from .models import PersonaFiles, TaskStatus
from .paths import PathResolver, ResourceType
from .io import read_file, write_file, ensure_dir, FileManager
from .parsers import (
    parse_journal_entries, parse_tasks, parse_team_members,
    extract_persona_role, parse_knowledge_domains
)
from .templates import (
    generate_persona_definition, generate_journal_template,
    generate_tasks_template, generate_knowledge_template,
    generate_journal_entry, generate_task_row, generate_knowledge_entry,
    generate_team_definition, generate_team_history, generate_member_row
)
from .analysis import JournalAnalyzer, TaskAnalyzer


class NPLPersona:
    """
    Backwards-compatible wrapper for npl_persona package.

    This class provides the same interface as the original npl-persona script.
    For testing, path resolution can be overridden by setting custom methods.
    """

    def __init__(self):
        """Initialize persona manager."""
        self._persona_resolver = PathResolver(ResourceType.PERSONAS)
        self._team_resolver = PathResolver(ResourceType.TEAMS)
        self._file_manager = FileManager()
        self.loaded_personas: Set[str] = set()

        # These can be overridden in tests
        self._get_target_path_override: Optional[Callable[[str], Path]] = None
        self._get_persona_search_paths_override: Optional[Callable[[], List[Path]]] = None
        self._get_team_search_paths_override: Optional[Callable[[], List[Path]]] = None

    # Path resolution methods (can be overridden for testing)
    def get_target_path(self, scope: str = "project") -> Path:
        """Get target path for persona creation."""
        if self._get_target_path_override:
            return self._get_target_path_override(scope)
        return self._persona_resolver.get_target_path(scope)

    def get_persona_search_paths(self) -> List[Path]:
        """Get persona search paths."""
        if self._get_persona_search_paths_override:
            return self._get_persona_search_paths_override()
        return self._persona_resolver.get_search_paths()

    def get_team_search_paths_resolved(self) -> List[Path]:
        """Get team search paths."""
        if self._get_team_search_paths_override:
            return self._get_team_search_paths_override()
        return self._team_resolver.get_search_paths()

    def resolve_persona_location(self, persona_id: str) -> Optional[Tuple[Path, str]]:
        """Resolve persona location using custom or default paths."""
        search_paths = self.get_persona_search_paths()
        scopes = ["project", "user", "system"]

        for i, base_path in enumerate(search_paths):
            if not base_path.exists():
                continue
            persona_file = base_path / f"{persona_id}.persona.md"
            if persona_file.exists():
                scope = scopes[i] if i < len(scopes) else "project"
                return (base_path, scope)
        return None

    def resolve_team_location(self, team_id: str) -> Optional[Tuple[Path, str]]:
        """Resolve team location using custom or default paths."""
        search_paths = self.get_team_search_paths_resolved()
        scopes = ["project", "user", "system"]

        for i, base_path in enumerate(search_paths):
            if not base_path.exists():
                continue
            team_file = base_path / f"{team_id}.team.md"
            if team_file.exists():
                scope = scopes[i] if i < len(scopes) else "project"
                return (base_path, scope)
        return None

    def _check_persona_files(self, persona_id: str, base_path: Path) -> PersonaFiles:
        """Check which mandatory files exist for a persona."""
        files = PersonaFiles()
        for file_type, template in MANDATORY_FILES.items():
            file_path = base_path / template.format(persona_id=persona_id)
            setattr(files, file_type, file_path.exists())
        return files

    # Persona operations
    def init_persona(
        self,
        persona_id: str,
        role: Optional[str] = None,
        scope: str = "project",
        from_template: Optional[str] = None
    ) -> bool:
        """Create a new persona."""
        target_path = self.get_target_path(scope)

        result = ensure_dir(target_path)
        if result.is_err():
            print(f"Error: {result.error}", file=sys.stderr)
            return False

        if (target_path / f"{persona_id}.persona.md").exists():
            print(f"Error: Persona '{persona_id}' already exists at {target_path}", file=sys.stderr)
            return False

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
        """Load and display persona files."""
        location = self.resolve_persona_location(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location

        if skip and persona_id in skip:
            return True

        if files == "all":
            files_to_load = list(MANDATORY_FILES.keys())
        else:
            files_to_load = [f.strip() for f in files.split(",")]

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

        self.loaded_personas.add(persona_id)
        return True

    def list_personas(self, scope: Optional[str] = None) -> Dict[str, Dict]:
        """List all personas."""
        personas = {}
        search_paths = self.get_persona_search_paths()
        scopes = ["project", "user", "system"]

        for i, base_path in enumerate(search_paths):
            if not base_path.exists():
                continue

            current_scope = scopes[i] if i < len(scopes) else "project"

            if scope and scope != current_scope and scope != "all":
                continue

            for persona_file in base_path.glob("*.persona.md"):
                persona_id = persona_file.stem.replace(".persona", "")

                if persona_id in personas:
                    continue

                personas[persona_id] = {
                    "id": persona_id,
                    "path": base_path,
                    "scope": current_scope,
                    "files": self._check_persona_files(persona_id, base_path).as_dict(),
                }

        return personas

    def which_persona(self, persona_id: str) -> bool:
        """Show persona location."""
        location = self.resolve_persona_location(persona_id)

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
        """Remove a persona."""
        location = self.resolve_persona_location(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, found_scope = location

        if scope and scope != found_scope:
            print(f"Error: Persona found in {found_scope} scope, but {scope} scope specified", file=sys.stderr)
            return False

        if not force:
            response = input(f"Delete persona '{persona_id}' from {found_scope} scope? [y/N]: ")
            if response.lower() != "y":
                print("Cancelled")
                return False

        deleted = []
        for file_type, template in MANDATORY_FILES.items():
            file_path = base_path / template.format(persona_id=persona_id)
            if file_path.exists():
                result = self._file_manager.delete(file_path)
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
        """Check persona health."""
        if check_all:
            personas = self.list_personas("all")
            all_healthy = True

            for pid, info in personas.items():
                files = self._check_persona_files(pid, Path(info["path"]))
                is_healthy = files.all_present()

                print(f"\nPERSONA: {pid}")
                for file_type in ["definition", "journal", "tasks", "knowledge"]:
                    present = getattr(files, file_type)
                    status = "✅" if present else "❌"
                    filename = MANDATORY_FILES[file_type].format(persona_id=pid)
                    print(f"├── {status} {filename}")

                health_status = "healthy" if is_healthy else "needs attention"
                print(f"└── INTEGRITY: {100 if is_healthy else 75}% {health_status}")

                if not is_healthy:
                    all_healthy = False

            return all_healthy

        elif persona_id:
            location = self.resolve_persona_location(persona_id)
            if not location:
                print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
                return False

            base_path, scope = location
            files = self._check_persona_files(persona_id, base_path)
            is_healthy = files.all_present()
            missing_files = []

            print(f"\nPERSONA: {persona_id}")
            for file_type in ["definition", "journal", "tasks", "knowledge"]:
                present = getattr(files, file_type)
                status = "✅" if present else "❌"
                filename = MANDATORY_FILES[file_type].format(persona_id=persona_id)
                print(f"├── {status} {filename}")
                if not present:
                    missing_files.append(file_type)

            health_status = "healthy" if is_healthy else "needs attention"
            print(f"└── INTEGRITY: {100 if is_healthy else 75}% {health_status}")

            if missing_files:
                print(f"    ISSUES: missing {', '.join(missing_files)}")

            return is_healthy

        else:
            print("Error: Specify --persona-id or --all", file=sys.stderr)
            return False

    def sync_persona(self, persona_id: str, validate: bool = True) -> bool:
        """Sync and validate persona files."""
        location = self.resolve_persona_location(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        print(f"Syncing persona: {persona_id}")

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

        print(f"\n✅ Sync complete for {persona_id}")
        return True

    def backup_persona(
        self,
        persona_id: Optional[str] = None,
        output: Optional[str] = None,
        backup_all: bool = False
    ) -> bool:
        """Backup persona data."""
        import tarfile

        if backup_all:
            personas = self.list_personas("all")
            persona_ids = list(personas.keys())
        elif persona_id:
            persona_ids = [persona_id]
        else:
            print("Error: Specify --persona-id or --all", file=sys.stderr)
            return False

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
                    location = self.resolve_persona_location(pid)
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

    # Journal operations
    def journal_add(
        self,
        persona_id: str,
        message: Optional[str] = None,
        interactive: bool = False
    ) -> bool:
        """Add journal entry."""
        if not message and not interactive:
            print("Error: No message provided", file=sys.stderr)
            return False

        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        journal_file = base_path / f"{persona_id}.journal.md"

        if not journal_file.exists():
            print(f"Error: Journal file not found: {journal_file}", file=sys.stderr)
            return False

        result = read_file(journal_file)
        if result.is_err():
            print(f"Error reading journal: {result.error}", file=sys.stderr)
            return False

        journal_content = result.value
        entry = generate_journal_entry(message or "")

        section_header = SECTIONS["recent_interactions"]
        if section_header in journal_content:
            parts = journal_content.split(section_header, 1)
            new_content = parts[0] + section_header + entry + parts[1]
        else:
            new_content = journal_content + "\n" + section_header + entry

        result = write_file(journal_file, new_content)
        if result.is_err():
            print(f"Error writing journal: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Journal entry added to {persona_id}")
        return True

    def journal_view(
        self,
        persona_id: str,
        entries: int = 5,
        since: Optional[str] = None
    ) -> bool:
        """View journal entries."""
        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        journal_file = base_path / f"{persona_id}.journal.md"

        if not journal_file.exists():
            print(f"Error: Journal file not found: {journal_file}", file=sys.stderr)
            return False

        result = read_file(journal_file)
        if result.is_err():
            print(f"Error reading journal: {result.error}", file=sys.stderr)
            return False

        journal_entries = parse_journal_entries(result.value)

        print(f"# Journal entries for {persona_id} (last {entries})\n")
        for entry in journal_entries[:entries]:
            print(f"## {entry.date.strftime(DATE_FORMAT)}")
            print(entry.content)
            print()

        return True

    def journal_archive(self, persona_id: str, before: str) -> bool:
        """Archive journal entries."""
        try:
            archive_date = datetime.strptime(before, "%Y-%m-%d")
        except ValueError:
            print(f"Error: Invalid date format. Use YYYY-MM-DD", file=sys.stderr)
            return False

        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        print(f"Archive operation would process entries before {before}")
        return True

    # Task operations
    def task_add(
        self,
        persona_id: str,
        description: str,
        due: Optional[str] = None,
        priority: str = "med"
    ) -> bool:
        """Add a task."""
        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        tasks_file = base_path / f"{persona_id}.tasks.md"

        if not tasks_file.exists():
            print(f"Error: Tasks file not found: {tasks_file}", file=sys.stderr)
            return False

        result = read_file(tasks_file)
        if result.is_err():
            print(f"Error reading tasks: {result.error}", file=sys.stderr)
            return False

        tasks_content = result.value
        task_row = generate_task_row(description, due, priority)

        section_header = SECTIONS["active_tasks"]
        if section_header in tasks_content:
            parts = tasks_content.split(section_header, 1)
            table_marker = TABLE_MARKERS["task"]
            if table_marker in parts[1]:
                marker_parts = parts[1].split(table_marker, 1)
                marker_end = marker_parts[1].find("\n") + 1
                new_content = parts[0] + section_header + marker_parts[0] + table_marker + marker_parts[1][:marker_end] + task_row + marker_parts[1][marker_end:]
            else:
                new_content = tasks_content + "\n" + task_row
        else:
            new_content = tasks_content + "\n" + task_row

        result = write_file(tasks_file, new_content)
        if result.is_err():
            print(f"Error writing tasks: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Task added: {description}")
        return True

    def task_update(
        self,
        persona_id: str,
        task_description: str,
        status: str
    ) -> bool:
        """Update task status."""
        if status not in VALID_STATUSES:
            print(f"Error: Invalid status '{status}'. Valid: {', '.join(VALID_STATUSES)}", file=sys.stderr)
            return False

        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        tasks_file = base_path / f"{persona_id}.tasks.md"

        if not tasks_file.exists():
            print(f"Error: Tasks file not found: {tasks_file}", file=sys.stderr)
            return False

        result = read_file(tasks_file)
        if result.is_err():
            print(f"Error reading tasks: {result.error}", file=sys.stderr)
            return False

        tasks_content = result.value

        # Find and update the task
        task_lower = task_description.lower()
        lines = tasks_content.split("\n")
        found = False
        new_lines = []

        status_map = {
            "pending": "⏸️",
            "in-progress": "🔄",
            "blocked": "🚫",
            "completed": "✅"
        }
        new_icon = status_map.get(status, "⏸️")

        for line in lines:
            if task_lower in line.lower() and line.strip().startswith("|"):
                # Update the status icon in the line
                for old_icon in status_map.values():
                    if old_icon in line:
                        line = line.replace(old_icon, new_icon, 1)
                        found = True
                        break
            new_lines.append(line)

        if not found:
            print(f"Error: Task '{task_description}' not found", file=sys.stderr)
            return False

        result = write_file(tasks_file, "\n".join(new_lines))
        if result.is_err():
            print(f"Error writing tasks: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Task '{task_description}' updated to {status}")
        return True

    def task_list(
        self,
        persona_id: str,
        status_filter: Optional[str] = None
    ) -> bool:
        """List tasks."""
        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        tasks_file = base_path / f"{persona_id}.tasks.md"

        if not tasks_file.exists():
            print(f"Error: Tasks file not found: {tasks_file}", file=sys.stderr)
            return False

        result = read_file(tasks_file)
        if result.is_err():
            print(f"Error reading tasks: {result.error}", file=sys.stderr)
            return False

        tasks = parse_tasks(result.value)

        print(f"# Tasks for {persona_id}\n")
        for task in tasks:
            status_icon = STATUS_ICONS.get(task.status.value, "⏸️")
            print(f"  {status_icon} {task.description}")
            if task.due:
                print(f"      Due: {task.due}")

        return True

    def task_remove(self, persona_id: str, task_description: str) -> bool:
        """Remove a task."""
        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        tasks_file = base_path / f"{persona_id}.tasks.md"

        if not tasks_file.exists():
            print(f"Error: Tasks file not found: {tasks_file}", file=sys.stderr)
            return False

        result = read_file(tasks_file)
        if result.is_err():
            print(f"Error reading tasks: {result.error}", file=sys.stderr)
            return False

        tasks_content = result.value
        task_lower = task_description.lower()
        lines = tasks_content.split("\n")
        new_lines = []
        found = False

        for line in lines:
            if task_lower in line.lower() and line.strip().startswith("|"):
                found = True
                continue  # Skip this line to remove it
            new_lines.append(line)

        if not found:
            print(f"Error: Task '{task_description}' not found", file=sys.stderr)
            return False

        result = write_file(tasks_file, "\n".join(new_lines))
        if result.is_err():
            print(f"Error writing tasks: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Task '{task_description}' removed")
        return True

    # Knowledge base operations
    def kb_add(
        self,
        persona_id: str,
        topic: str,
        content: Optional[str] = None,
        source: Optional[str] = None
    ) -> bool:
        """Add knowledge base entry."""
        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        kb_file = base_path / f"{persona_id}.knowledge-base.md"

        if not kb_file.exists():
            print(f"Error: Knowledge base file not found: {kb_file}", file=sys.stderr)
            return False

        result = read_file(kb_file)
        if result.is_err():
            print(f"Error reading knowledge base: {result.error}", file=sys.stderr)
            return False

        kb_content = result.value
        entry = generate_knowledge_entry(topic, content, source)

        section_header = SECTIONS["recently_acquired"]
        if section_header in kb_content:
            parts = kb_content.split(section_header, 1)
            new_content = parts[0] + section_header + entry + parts[1]
        else:
            new_content = kb_content + "\n" + section_header + entry

        result = write_file(kb_file, new_content)
        if result.is_err():
            print(f"Error writing knowledge base: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Knowledge entry added: {topic}")
        return True

    def kb_search(
        self,
        persona_id: str,
        query: str,
        domain: Optional[str] = None
    ) -> bool:
        """Search knowledge base."""
        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        kb_file = base_path / f"{persona_id}.knowledge-base.md"

        if not kb_file.exists():
            print(f"Error: Knowledge base file not found: {kb_file}", file=sys.stderr)
            return False

        result = read_file(kb_file)
        if result.is_err():
            print(f"Error reading knowledge base: {result.error}", file=sys.stderr)
            return False

        content = result.value
        query_lower = query.lower()
        matches = []

        for line in content.split("\n"):
            if query_lower in line.lower():
                matches.append(line.strip())

        if not matches:
            print(f"No matches found for '{query}'")
            return True

        print(f"# Knowledge base search results for '{query}' ({len(matches)} matches)\n")
        for i, match in enumerate(matches[:10], 1):
            print(f"{i}. {match}")

        return True

    def kb_get(self, persona_id: str, topic: str) -> bool:
        """Get specific knowledge entry."""
        import re

        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        kb_file = base_path / f"{persona_id}.knowledge-base.md"

        if not kb_file.exists():
            print(f"Error: Knowledge base file not found: {kb_file}", file=sys.stderr)
            return False

        result = read_file(kb_file)
        if result.is_err():
            print(f"Error reading knowledge base: {result.error}", file=sys.stderr)
            return False

        content = result.value
        topic_pattern = f"###[^\\n]*{re.escape(topic)}[^\\n]*(.*?)(?=###|\\Z)"
        matches = re.findall(topic_pattern, content, re.DOTALL | re.IGNORECASE)

        if not matches:
            print(f"Knowledge entry '{topic}' not found")
            return False

        print(f"# Knowledge: {topic}\n")
        for match in matches:
            print(match.strip())
            print()

        return True

    def kb_update_domain(
        self,
        persona_id: str,
        domain: str,
        confidence: int
    ) -> bool:
        """Update domain confidence."""
        import re

        if confidence < 0 or confidence > 100:
            print(f"Error: Confidence must be 0-100", file=sys.stderr)
            return False

        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        kb_file = base_path / f"{persona_id}.knowledge-base.md"

        if not kb_file.exists():
            print(f"Error: Knowledge base file not found: {kb_file}", file=sys.stderr)
            return False

        result = read_file(kb_file)
        if result.is_err():
            print(f"Error reading knowledge base: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Find and update domain confidence
        domain_section_pattern = f"### {re.escape(domain)}(.*?)```knowledge(.*?)```"
        matches = list(re.finditer(domain_section_pattern, content, re.DOTALL | re.IGNORECASE))

        updated = False
        for match in matches:
            old_block = match.group(2)
            new_block = re.sub(r"confidence:\s*\d+%", f"confidence: {confidence}%", old_block)
            new_block = re.sub(
                r"last_updated:.*",
                f"last_updated: {datetime.now().strftime(DATE_FORMAT)}",
                new_block
            )

            content = content.replace(
                match.group(0),
                f"### {domain}{match.group(1)}```knowledge{new_block}```"
            )
            updated = True
            break

        if updated:
            result = write_file(kb_file, content)
            if result.is_err():
                print(f"Error writing knowledge base: {result.error}", file=sys.stderr)
                return False
            print(f"✅ Updated {domain} domain: {confidence}% confidence")
            return True

        print(f"Warning: Domain '{domain}' not found")
        return False

    def share_knowledge(
        self,
        from_persona: str,
        to_persona: str,
        topic: str,
        translate: bool = False
    ) -> bool:
        """Share knowledge between personas."""
        import re

        from_location = self.resolve_persona_location(from_persona)
        if not from_location:
            print(f"Error: Source persona '{from_persona}' not found", file=sys.stderr)
            return False

        to_location = self.resolve_persona_location(to_persona)
        if not to_location:
            print(f"Error: Target persona '{to_persona}' not found", file=sys.stderr)
            return False

        from_base, _ = from_location
        to_base, _ = to_location

        from_kb = from_base / f"{from_persona}.knowledge-base.md"
        result = read_file(from_kb)
        if result.is_err():
            print(f"Error reading source knowledge base: {result.error}", file=sys.stderr)
            return False

        from_content = result.value

        topic_pattern = f"###[^\\n]*{re.escape(topic)}[^\\n]*(.*?)(?=###|\\Z)"
        matches = re.findall(topic_pattern, from_content, re.DOTALL | re.IGNORECASE)

        if not matches:
            print(f"Error: Topic '{topic}' not found in {from_persona}'s knowledge base", file=sys.stderr)
            return False

        knowledge_text = matches[0].strip()

        print(f"Extracting knowledge from {from_persona}...")
        if translate:
            print(f"Translating to {to_persona}'s context...")
            knowledge_text = f"(Shared from @{from_persona})\n{knowledge_text}"

        to_kb = to_base / f"{to_persona}.knowledge-base.md"
        result = read_file(to_kb)
        if result.is_err():
            print(f"Error reading target knowledge base: {result.error}", file=sys.stderr)
            return False

        to_content = result.value

        entry = f"""
### {datetime.now().strftime(DATE_FORMAT)} - {topic} (shared)
**Source**: @{from_persona}
**Learning**: {knowledge_text}
**Integration**: Shared knowledge from team member
**Application**: TBD - Apply in relevant contexts

"""

        section_header = SECTIONS["recently_acquired"]
        if section_header in to_content:
            parts = to_content.split(section_header, 1)
            new_content = parts[0] + section_header + entry + parts[1]
        else:
            new_content = to_content + "\n" + section_header + entry

        result = write_file(to_kb, new_content)
        if result.is_err():
            print(f"Error writing target knowledge base: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Knowledge transferred: {from_persona} → {to_persona}")
        return True

    # Team operations
    def create_team(
        self,
        team_id: str,
        members: Optional[List[str]] = None,
        scope: str = "project"
    ) -> bool:
        """Create a new team."""
        # Use custom path if set, otherwise use default
        if self._get_team_search_paths_override:
            search_paths = self._get_team_search_paths_override()
            if scope == "project":
                team_path = search_paths[0]
            elif scope == "user":
                team_path = search_paths[1] if len(search_paths) > 1 else search_paths[0]
            else:
                team_path = search_paths[2] if len(search_paths) > 2 else search_paths[0]
        else:
            team_path = self._team_resolver.get_target_path(scope)

        result = ensure_dir(team_path)
        if result.is_err():
            print(f"Error: {result.error}", file=sys.stderr)
            return False

        team_file = team_path / f"{team_id}.team.md"

        if team_file.exists():
            print(f"Error: Team '{team_id}' already exists at {team_path}", file=sys.stderr)
            return False

        member_rows = []
        member_list = members or []

        for member_id in member_list:
            location = self.resolve_persona_location(member_id)
            role = "Member"

            if location:
                base_path, _ = location
                def_file = base_path / f"{member_id}.persona.md"
                if def_file.exists():
                    result = read_file(def_file)
                    if result.is_ok():
                        extracted_role = extract_persona_role(result.value)
                        if extracted_role:
                            role = extracted_role
            else:
                print(f"Warning: Persona '{member_id}' not found, adding anyway", file=sys.stderr)

            member_rows.append(generate_member_row(member_id, role))

        member_rows_str = "\n".join(member_rows) if member_rows else "| <!-- Members will be added here --> | | | |"

        team_content = generate_team_definition(team_id, scope, member_rows_str)

        result = write_file(team_file, team_content)
        if result.is_err():
            print(f"Error creating team file: {result.error}", file=sys.stderr)
            return False

        print(f"✨ Team '{team_id}' created successfully at {scope} scope")
        if member_list:
            print(f"   Members: {', '.join([f'@{m}' for m in member_list])}")

        history_file = team_path / f"{team_id}.history.md"
        initial_members = ", ".join([f"@{m}" for m in member_list]) if member_list else "None"
        history_content = generate_team_history(team_id, initial_members)

        result = write_file(history_file, history_content)
        if result.is_err():
            print(f"Warning: Failed to create team history: {result.error}", file=sys.stderr)
        else:
            print(f"   Created team history: {team_id}.history.md")

        return True

    def add_to_team(self, team_id: str, persona_id: str) -> bool:
        """Add member to team."""
        location = self.resolve_team_location(team_id)
        if not location:
            print(f"Error: Team '{team_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        team_file = base_path / f"{team_id}.team.md"

        result = read_file(team_file)
        if result.is_err():
            print(f"Error reading team file: {result.error}", file=sys.stderr)
            return False

        content = result.value

        if f"@{persona_id}" in content:
            print(f"Warning: @{persona_id} is already a member of {team_id}")
            return False

        role = "Member"
        persona_location = self.resolve_persona_location(persona_id)
        if persona_location:
            persona_base, _ = persona_location
            def_file = persona_base / f"{persona_id}.persona.md"
            if def_file.exists():
                result = read_file(def_file)
                if result.is_ok():
                    extracted_role = extract_persona_role(result.value)
                    if extracted_role:
                        role = extracted_role
        else:
            print(f"Warning: Persona '{persona_id}' not found in persona paths")

        new_row = generate_member_row(persona_id, role)

        lines = content.split("\n")
        new_lines = []
        table_found = False
        last_row_index = -1

        for i, line in enumerate(lines):
            if TABLE_MARKERS["team"] in line:
                table_found = True
            elif table_found and line.strip().startswith("|") and "@" in line:
                last_row_index = i

        if not table_found:
            print(f"Error: Could not find team composition table in {team_id}", file=sys.stderr)
            return False

        if last_row_index >= 0:
            new_lines = lines[:last_row_index + 1] + [new_row] + lines[last_row_index + 1:]
        else:
            for i, line in enumerate(lines):
                if TABLE_MARKERS["team"] in line:
                    new_lines = lines[:i + 1] + [new_row] + lines[i + 1:]
                    break

        result = write_file(team_file, "\n".join(new_lines))
        if result.is_err():
            print(f"Error writing team file: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Added @{persona_id} ({role}) to team '{team_id}'")
        return True

    def list_team(self, team_id: str, verbose: bool = False) -> bool:
        """List team members."""
        location = self.resolve_team_location(team_id)
        if not location:
            print(f"Error: Team '{team_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        team_file = base_path / f"{team_id}.team.md"

        result = read_file(team_file)
        if result.is_err():
            print(f"Error reading team file: {result.error}", file=sys.stderr)
            return False

        content = result.value
        members = parse_team_members(content)

        title = team_id.replace("-", " ").title()
        print(f"\n# Team: {title}")
        print(f"**Scope**: {scope}")
        print(f"**Members**: {len(members)}\n")

        if not members:
            print("No members in this team yet.")
            return True

        for member in members:
            print(f"  - @{member.persona_id} ({member.role})")

        print()
        return True

    def synthesize_team_knowledge(
        self,
        team_id: str,
        output: Optional[str] = None
    ) -> bool:
        """Synthesize team knowledge."""
        print(f"Synthesizing knowledge for team '{team_id}'...")
        return True

    def show_team_matrix(self, team_id: str) -> bool:
        """Show team expertise matrix."""
        print(f"Team matrix for '{team_id}'...")
        return True

    def analyze_team(self, team_id: str, period: int = 30) -> bool:
        """Analyze team collaboration."""
        print(f"Analyzing team '{team_id}' (period: {period} days)...")
        return True

    # Analysis operations
    def analyze_persona(
        self,
        persona_id: str,
        analysis_type: str = "journal",
        period: int = 30
    ) -> bool:
        """Analyze persona data."""
        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location

        if analysis_type == "journal":
            journal_file = base_path / f"{persona_id}.journal.md"
            if not journal_file.exists():
                print(f"Error: Journal file not found", file=sys.stderr)
                return False

            result = read_file(journal_file)
            if result.is_err():
                print(f"Error reading journal: {result.error}", file=sys.stderr)
                return False

            entries = parse_journal_entries(result.value)
            analyzer = JournalAnalyzer(entries, period)

            print(f"📊 Journal Analysis (Last {period} days)\n")
            print(f"Interaction frequency: {len(analyzer.entries)} sessions")

            collab = analyzer.analyze_collaborations()
            if collab.top_collaborators:
                top_str = ", ".join([f"@{p} ({c})" for p, c in collab.top_collaborators])
                print(f"Top collaborators: {top_str}")

            sentiment = analyzer.analyze_sentiment()
            print(f"Mood trajectory: {sentiment.score:.0f}% positive trend {sentiment.trend}")

            topics = analyzer.analyze_topics()
            if topics.top_topics:
                topics_str = ", ".join([f"{t} ({c})" for t, c in topics.top_topics])
                print(f"Topics discussed: {topics_str}")

            velocity = analyzer.calculate_learning_velocity()
            print(f"Learning velocity: {velocity:.1f} concepts/week")

            return True

        elif analysis_type == "tasks":
            tasks_file = base_path / f"{persona_id}.tasks.md"
            if not tasks_file.exists():
                print(f"Error: Tasks file not found", file=sys.stderr)
                return False

            result = read_file(tasks_file)
            if result.is_err():
                print(f"Error reading tasks: {result.error}", file=sys.stderr)
                return False

            tasks = parse_tasks(result.value)
            analyzer = TaskAnalyzer(tasks, period)

            print(f"📈 Task Completion Analysis (Last {period} days)\n")
            print(f"Total tasks: {len(tasks)}")

            breakdown = analyzer.get_status_breakdown()
            completion_rate = analyzer.get_completion_rate()

            print(f"Completed: {breakdown.get(TaskStatus.COMPLETED, 0)} ({completion_rate:.0f}%)")
            print(f"In Progress: {breakdown.get(TaskStatus.IN_PROGRESS, 0)}")
            print(f"Blocked: {breakdown.get(TaskStatus.BLOCKED, 0)}")

            return True

        return False

    def generate_report(
        self,
        persona_id: str,
        output_format: str = "md",
        period: str = "month"
    ) -> bool:
        """Generate persona report."""
        location = self.resolve_persona_location(persona_id)
        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        period_days = {"week": 7, "month": 30, "quarter": 90, "year": 365}.get(period, 30)

        report_date = datetime.now().strftime("%Y-%m-%d")
        report_file = base_path / f"{persona_id}-{period}-{report_date}.{output_format}"

        print(f"Generating {period} report for {persona_id}...")

        title = persona_id.replace("-", " ").title()
        report_content = f"""# {title} - {period.title()} Report
**Generated**: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
**Period**: Last {period_days} days
**Scope**: {scope}

## Executive Summary

Persona {persona_id} has been active in the {scope} scope.

## Health Status

"""

        files = self._check_persona_files(persona_id, base_path)
        all_present = files.all_present()
        report_content += f"- **File Integrity**: {'100% - All files present' if all_present else 'Incomplete'}\n"

        for file_type in ["definition", "journal", "tasks", "knowledge"]:
            present = getattr(files, file_type)
            status = "✅" if present else "❌"
            report_content += f"- **{file_type.title()}**: {status}\n"

        report_content += "\n## Recommendations\n\n"
        report_content += "1. Continue regular journal updates for continuity\n"
        report_content += "2. Review and archive old journal entries if needed\n"
        report_content += "3. Update domain expertise confidence levels\n"
        report_content += "4. Share relevant knowledge with team members\n"
        report_content += f"\n---\n\n*Report generated by npl-persona v2.0*\n"

        result = write_file(report_file, report_content)
        if result.is_err():
            print(f"Error writing report: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Report saved: {report_file}")
        return True
