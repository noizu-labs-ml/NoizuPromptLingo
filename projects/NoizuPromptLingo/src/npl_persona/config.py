"""
Configuration constants for npl_persona.

Centralizes all hardcoded markers, patterns, and defaults that were
previously scattered throughout the codebase.
"""

from typing import Dict, List

# NPL Block Markers
PERSONA_HEADER = "⌜persona:"
PERSONA_FOOTER = "⌞persona:"
TEAM_HEADER = "⌜team:"
TEAM_FOOTER = "⌞team:"

# NPL Table Markers (used in markdown parsing)
TABLE_MARKERS: Dict[str, str] = {
    "task": "⟪📅:",
    "team": "⟪👥:",
    "knowledge": "⟪📚:",
    "relationship": "⟪🤝:",
    "blocked": "⟪⚠️:",
}

# Status Icons for task states
STATUS_ICONS: Dict[str, str] = {
    "completed": "✅",
    "complete": "✅",
    "in_progress": "🔄",
    "in-progress": "🔄",
    "blocked": "🚫",
    "pending": "⏸️",
}

# Reverse mapping for parsing
STATUS_FROM_ICON: Dict[str, str] = {
    "✅": "completed",
    "🔄": "in_progress",
    "🚫": "blocked",
    "⏸️": "pending",
}

# Section Headers in markdown files
SECTIONS: Dict[str, str] = {
    "recent_interactions": "## Recent Interactions",
    "relationship_evolution": "## Relationship Evolution",
    "personal_development": "## Personal Development Log",
    "reflection_patterns": "## Reflection Patterns",
    "active_tasks": "## 🎯 Active Tasks",
    "role_responsibilities": "## 🎭 Role Responsibilities",
    "goals_okrs": "## 📈 Goals & OKRs",
    "task_history": "## 🔄 Task History",
    "blocked_items": "## 🚫 Blocked Items",
    "knowledge_domains": "## 📚 Core Knowledge Domains",
    "recently_acquired": "## 🔄 Recently Acquired Knowledge",
    "learning_paths": "## 🎓 Learning Paths",
    "reference_library": "## 📖 Reference Library",
    "knowledge_gaps": "## ❓ Knowledge Gaps",
    "knowledge_graph": "## 🔗 Knowledge Graph Connections",
    "team_composition": "## Team Composition",
    "team_purpose": "## Team Purpose",
    "collaboration_patterns": "## Collaboration Patterns",
    "team_dynamics": "## Team Dynamics",
    "knowledge_areas": "## Knowledge Areas",
    "team_metrics": "## Team Metrics",
}

# Mandatory files for each persona
MANDATORY_FILES: Dict[str, str] = {
    "definition": "{persona_id}.persona.md",
    "journal": "{persona_id}.journal.md",
    "tasks": "{persona_id}.tasks.md",
    "knowledge": "{persona_id}.knowledge-base.md",
}

# Team files
TEAM_FILES: Dict[str, str] = {
    "definition": "{team_id}.team.md",
    "history": "{team_id}.history.md",
}

# Priority levels
PRIORITY_ICONS: Dict[str, str] = {
    "high": "🔴",
    "med": "🟡",
    "medium": "🟡",
    "low": "🟢",
}

# Valid task statuses
VALID_STATUSES: List[str] = ["pending", "in-progress", "blocked", "completed"]

# Sentiment analysis keywords
SENTIMENT_POSITIVE: List[str] = [
    "success",
    "learned",
    "achieved",
    "completed",
    "great",
    "excellent",
    "progress",
    "improved",
    "solved",
    "mastered",
]

SENTIMENT_NEGATIVE: List[str] = [
    "failed",
    "blocked",
    "difficult",
    "problem",
    "issue",
    "error",
    "struggle",
    "confused",
    "stuck",
    "frustrated",
]

# Learning-related keywords for velocity analysis
LEARNING_KEYWORDS: List[str] = [
    "learned",
    "discovered",
    "understood",
    "mastered",
    "studied",
    "explored",
    "researched",
    "realized",
]

# Depth levels for knowledge domains
DEPTH_LEVELS: Dict[str, int] = {
    "surface": 30,
    "working": 50,
    "proficient": 70,
    "expert": 90,
}

# Date formats
DATE_FORMAT = "%Y-%m-%d"
DATETIME_FORMAT = "%Y-%m-%d %H:%M"
SESSION_ID_FORMAT = "%Y%m%d-%H%M%S"

# Default values
DEFAULT_DUE_DAYS = 7
DEFAULT_JOURNAL_ENTRIES = 5
DEFAULT_ANALYSIS_PERIOD = 30
DEFAULT_SEARCH_RESULTS = 10

# Environment variable names
ENV_PERSONA_DIR = "NPL_PERSONA_DIR"
ENV_PERSONA_TEAMS = "NPL_PERSONA_TEAMS"
ENV_PERSONA_SHARED = "NPL_PERSONA_SHARED"

# File size limits (bytes)
FILE_SIZE_LIMITS: Dict[str, int] = {
    "journal": 100 * 1024,  # 100KB
    "knowledge": 500 * 1024,  # 500KB
    "tasks": 50 * 1024,  # 50KB
    "definition": 20 * 1024,  # 20KB
}
