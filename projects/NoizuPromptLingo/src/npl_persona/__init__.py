"""
npl_persona - Modular persona management for NPL

This package provides persona management with multi-tier hierarchical loading
(project -> user -> system) and comprehensive persona file management.

Architecture:
- config.py: Constants, markers, defaults
- models.py: Data classes for domain objects
- paths.py: Unified path resolution
- io.py: Safe file operations
- parsers.py: Markdown parsing utilities
- templates.py: Template generators
- analysis.py: Analysis utilities
- persona.py: Persona CRUD operations
- journal.py: Journal operations
- tasks.py: Task management
- knowledge.py: Knowledge base operations
- teams.py: Team operations
- cli.py: CLI interface
"""

__version__ = "2.0.0"

# Config exports
from .config import (
    MANDATORY_FILES,
    PERSONA_HEADER,
    PERSONA_FOOTER,
    TEAM_HEADER,
    TEAM_FOOTER,
    TABLE_MARKERS,
    STATUS_ICONS,
    SECTIONS,
)

# Model exports
from .models import (
    Persona,
    PersonaFiles,
    JournalEntry,
    Task,
    TaskStatus,
    KnowledgeDomain,
    KnowledgeEntry,
    TeamMember,
    Team,
    Scope,
    HealthReport,
)

# Path resolution exports
from .paths import PathResolver, ResourceType, resolve_persona, resolve_team

# IO exports
from .io import FileManager, FileError, read_file, write_file, ensure_dir

# Manager exports
from .persona import PersonaManager
from .journal import JournalManager
from .tasks import TaskManager
from .knowledge import KnowledgeManager
from .teams import TeamManager

# Analysis exports
from .analysis import JournalAnalyzer, TaskAnalyzer, TeamAnalyzer

# CLI exports
from .cli import main, create_parser, dispatch

# Compatibility wrapper
from .compat import NPLPersona

__all__ = [
    # Version
    "__version__",
    # Config
    "MANDATORY_FILES",
    "PERSONA_HEADER",
    "PERSONA_FOOTER",
    "TEAM_HEADER",
    "TEAM_FOOTER",
    "TABLE_MARKERS",
    "STATUS_ICONS",
    "SECTIONS",
    # Models
    "Persona",
    "PersonaFiles",
    "JournalEntry",
    "Task",
    "TaskStatus",
    "KnowledgeDomain",
    "KnowledgeEntry",
    "TeamMember",
    "Team",
    "Scope",
    "HealthReport",
    # Paths
    "PathResolver",
    "ResourceType",
    "resolve_persona",
    "resolve_team",
    # IO
    "FileManager",
    "FileError",
    "read_file",
    "write_file",
    "ensure_dir",
    # Managers
    "PersonaManager",
    "JournalManager",
    "TaskManager",
    "KnowledgeManager",
    "TeamManager",
    # Analysis
    "JournalAnalyzer",
    "TaskAnalyzer",
    "TeamAnalyzer",
    # CLI
    "main",
    "create_parser",
    "dispatch",
    # Compatibility
    "NPLPersona",
]
