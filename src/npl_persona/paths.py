"""
Path resolution utilities for npl_persona.

Consolidates the duplicated path resolution logic (3+ methods that were
nearly identical) into a single unified PathResolver class.
"""

import os
import sys
from enum import Enum
from pathlib import Path
from typing import List, Optional, Tuple

from .config import ENV_PERSONA_DIR, ENV_PERSONA_TEAMS, ENV_PERSONA_SHARED


class ResourceType(Enum):
    """Types of resources that can be resolved."""
    PERSONAS = "personas"
    TEAMS = "teams"
    SHARED = "shared"


class PathResolver:
    """
    Unified path resolution for all NPL persona resources.

    Handles hierarchical path resolution (project -> user -> system)
    for personas, teams, and shared resources.
    """

    def __init__(self, resource_type: ResourceType):
        """
        Initialize resolver for a specific resource type.

        Args:
            resource_type: The type of resource to resolve (personas, teams, shared)
        """
        self.resource_type = resource_type
        self._env_override = self._get_env_override()

    def _get_env_override(self) -> Optional[str]:
        """Get environment variable override for this resource type."""
        env_vars = {
            ResourceType.PERSONAS: ENV_PERSONA_DIR,
            ResourceType.TEAMS: ENV_PERSONA_TEAMS,
            ResourceType.SHARED: ENV_PERSONA_SHARED,
        }
        env_var = env_vars.get(self.resource_type)
        return os.environ.get(env_var) if env_var else None

    def _get_system_path(self) -> Path:
        """Get platform-specific system path."""
        resource_name = self.resource_type.value

        if sys.platform.startswith("win"):
            base = Path(os.environ.get("PROGRAMDATA", "C:\\ProgramData"))
            return base / "npl" / resource_name
        elif sys.platform == "darwin":
            return Path(f"/Library/Application Support/npl/{resource_name}")
        else:
            return Path(f"/etc/npl/{resource_name}")

    def get_search_paths(self) -> List[Path]:
        """
        Get search paths in priority order (project -> user -> system).

        Returns:
            List of paths to search, highest priority first
        """
        paths: List[Path] = []
        resource_name = self.resource_type.value

        # Environment override takes highest priority
        if self._env_override:
            paths.append(Path(self._env_override))

        # Project-level
        paths.append(Path(f"./.npl/{resource_name}"))

        # User-level
        paths.append(Path.home() / f".npl/{resource_name}")

        # System-level
        paths.append(self._get_system_path())

        return paths

    def resolve(self, resource_id: str, file_suffix: str = ".persona.md") -> Optional[Tuple[Path, str]]:
        """
        Find a resource and return its location and scope.

        Args:
            resource_id: The ID of the resource to find
            file_suffix: The file suffix to look for (e.g., ".persona.md", ".team.md")

        Returns:
            Tuple of (directory_path, scope_name) or None if not found
        """
        search_paths = self.get_search_paths()

        for i, base_path in enumerate(search_paths):
            resource_file = base_path / f"{resource_id}{file_suffix}"
            if resource_file.exists():
                scope = self._index_to_scope(i)
                return (base_path, scope)

        return None

    def _index_to_scope(self, index: int) -> str:
        """Convert search path index to scope name."""
        # Account for possible env override at index 0
        if self._env_override:
            if index == 0:
                return "project"  # env override counts as project-level
            index -= 1

        scopes = ["project", "user", "system"]
        return scopes[min(index, len(scopes) - 1)]

    def get_target_path(self, scope: str = "project") -> Path:
        """
        Get the target path for creating new resources.

        Args:
            scope: The scope to create in ("project", "user", or "system")

        Returns:
            Path where new resources should be created
        """
        resource_name = self.resource_type.value

        if scope == "user":
            return Path.home() / f".npl/{resource_name}"
        elif scope == "system":
            return self._get_system_path()
        else:  # project
            return Path(f"./.npl/{resource_name}")

    def list_all(self, file_suffix: str = ".persona.md") -> List[Tuple[str, Path, str]]:
        """
        List all resources across all scopes.

        Args:
            file_suffix: The file suffix to look for

        Returns:
            List of (resource_id, path, scope) tuples
        """
        results: List[Tuple[str, Path, str]] = []
        seen_ids: set = set()

        for i, base_path in enumerate(self.get_search_paths()):
            if not base_path.exists():
                continue

            scope = self._index_to_scope(i)
            pattern = f"*{file_suffix}"

            for resource_file in base_path.glob(pattern):
                resource_id = resource_file.stem.replace(
                    file_suffix.replace(".", "").replace("md", ""),
                    ""
                ).rstrip(".")

                # First found wins (priority order)
                if resource_id in seen_ids:
                    continue

                seen_ids.add(resource_id)
                results.append((resource_id, base_path, scope))

        return results


# Convenience factory functions
def persona_resolver() -> PathResolver:
    """Create a resolver for persona resources."""
    return PathResolver(ResourceType.PERSONAS)


def team_resolver() -> PathResolver:
    """Create a resolver for team resources."""
    return PathResolver(ResourceType.TEAMS)


def shared_resolver() -> PathResolver:
    """Create a resolver for shared resources."""
    return PathResolver(ResourceType.SHARED)


def resolve_persona(persona_id: str) -> Optional[Tuple[Path, str]]:
    """
    Convenience function to resolve a persona location.

    Args:
        persona_id: The persona ID to find

    Returns:
        Tuple of (directory_path, scope) or None if not found
    """
    return persona_resolver().resolve(persona_id, ".persona.md")


def resolve_team(team_id: str) -> Optional[Tuple[Path, str]]:
    """
    Convenience function to resolve a team location.

    Args:
        team_id: The team ID to find

    Returns:
        Tuple of (directory_path, scope) or None if not found
    """
    return team_resolver().resolve(team_id, ".team.md")
