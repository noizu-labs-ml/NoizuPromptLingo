"""
Data models for npl_persona.

Provides typed dataclasses for all domain objects, replacing the
ad-hoc dictionaries used throughout the original codebase.
"""

from dataclasses import dataclass, field
from datetime import date, datetime
from pathlib import Path
from typing import Dict, List, Optional
from enum import Enum


class TaskStatus(Enum):
    """Task status enumeration."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    BLOCKED = "blocked"
    COMPLETED = "completed"

    @classmethod
    def from_icon(cls, icon: str) -> "TaskStatus":
        """Parse status from icon character."""
        mapping = {
            "✅": cls.COMPLETED,
            "🔄": cls.IN_PROGRESS,
            "🚫": cls.BLOCKED,
            "⏸️": cls.PENDING,
        }
        return mapping.get(icon, cls.PENDING)

    @property
    def icon(self) -> str:
        """Get icon for this status."""
        icons = {
            self.COMPLETED: "✅",
            self.IN_PROGRESS: "🔄",
            self.BLOCKED: "🚫",
            self.PENDING: "⏸️",
        }
        return icons[self]

    @property
    def display_name(self) -> str:
        """Get display name for this status."""
        names = {
            self.COMPLETED: "Complete",
            self.IN_PROGRESS: "In Progress",
            self.BLOCKED: "Blocked",
            self.PENDING: "Pending",
        }
        return names[self]


class Scope(Enum):
    """Resource scope enumeration."""
    PROJECT = "project"
    USER = "user"
    SYSTEM = "system"


@dataclass
class PersonaFiles:
    """Tracks existence of mandatory persona files."""
    definition: bool = False
    journal: bool = False
    tasks: bool = False
    knowledge: bool = False

    def all_present(self) -> bool:
        """Check if all mandatory files exist."""
        return all([self.definition, self.journal, self.tasks, self.knowledge])

    def missing(self) -> List[str]:
        """Get list of missing file types."""
        result = []
        if not self.definition:
            result.append("definition")
        if not self.journal:
            result.append("journal")
        if not self.tasks:
            result.append("tasks")
        if not self.knowledge:
            result.append("knowledge")
        return result

    def as_dict(self) -> Dict[str, bool]:
        """Convert to dictionary."""
        return {
            "definition": self.definition,
            "journal": self.journal,
            "tasks": self.tasks,
            "knowledge": self.knowledge,
        }


@dataclass
class Persona:
    """Represents a persona with its location and file status."""
    id: str
    path: Path
    scope: Scope
    files: PersonaFiles = field(default_factory=PersonaFiles)
    role: Optional[str] = None

    @property
    def definition_path(self) -> Path:
        """Path to persona definition file."""
        return self.path / f"{self.id}.persona.md"

    @property
    def journal_path(self) -> Path:
        """Path to persona journal file."""
        return self.path / f"{self.id}.journal.md"

    @property
    def tasks_path(self) -> Path:
        """Path to persona tasks file."""
        return self.path / f"{self.id}.tasks.md"

    @property
    def knowledge_path(self) -> Path:
        """Path to persona knowledge base file."""
        return self.path / f"{self.id}.knowledge-base.md"


@dataclass
class JournalEntry:
    """A single journal entry."""
    date: date
    session_id: str
    content: str
    participants: List[str] = field(default_factory=list)
    context: Optional[str] = None
    outcomes: Optional[str] = None
    growth: Optional[str] = None

    @classmethod
    def from_raw(cls, date_str: str, session_id: str, text: str) -> "JournalEntry":
        """Create from raw parsed values."""
        import re
        entry_date = datetime.strptime(date_str, "%Y-%m-%d").date()
        participants = re.findall(r"@(\w+[-\w]*)", text)
        return cls(
            date=entry_date,
            session_id=session_id,
            content=text,
            participants=participants,
        )


@dataclass
class Task:
    """A single task item."""
    description: str
    status: TaskStatus
    owner: str
    due: Optional[date] = None
    priority: str = "med"

    @classmethod
    def from_table_row(cls, parts: List[str]) -> Optional["Task"]:
        """Create from parsed table row parts."""
        if len(parts) < 4:
            return None

        description = parts[0].strip()
        status_text = parts[1].strip()
        owner = parts[2].strip().lstrip("@")
        due_str = parts[3].strip() if len(parts) > 3 else None

        # Parse status from icon
        status = TaskStatus.PENDING
        for icon, task_status in [
            ("✅", TaskStatus.COMPLETED),
            ("🔄", TaskStatus.IN_PROGRESS),
            ("🚫", TaskStatus.BLOCKED),
            ("⏸️", TaskStatus.PENDING),
        ]:
            if icon in status_text:
                status = task_status
                break

        # Parse due date
        due_date = None
        if due_str:
            try:
                due_date = datetime.strptime(due_str, "%Y-%m-%d").date()
            except ValueError:
                pass

        return cls(
            description=description,
            status=status,
            owner=owner,
            due=due_date,
        )


@dataclass
class KnowledgeDomain:
    """A knowledge domain with confidence level."""
    name: str
    confidence: int  # 0-100
    depth: str  # surface, working, proficient, expert
    last_updated: date

    @property
    def depth_from_confidence(self) -> str:
        """Derive depth level from confidence percentage."""
        if self.confidence >= 90:
            return "expert"
        elif self.confidence >= 70:
            return "proficient"
        elif self.confidence >= 50:
            return "working"
        return "surface"


@dataclass
class KnowledgeEntry:
    """A knowledge base entry."""
    date: date
    topic: str
    source: str
    learning: str
    integration: Optional[str] = None
    application: Optional[str] = None


@dataclass
class TeamMember:
    """A team member with role and status."""
    persona_id: str
    role: str
    joined: date
    status: str = "Active"


@dataclass
class Team:
    """Represents a team with its members."""
    id: str
    path: Path
    scope: Scope
    members: List[TeamMember] = field(default_factory=list)
    created: Optional[date] = None
    status: str = "Active"

    @property
    def definition_path(self) -> Path:
        """Path to team definition file."""
        return self.path / f"{self.id}.team.md"

    @property
    def history_path(self) -> Path:
        """Path to team history file."""
        return self.path / f"{self.id}.history.md"


@dataclass
class HealthReport:
    """Health check results for a persona."""
    persona_id: str
    scope: Scope
    path: Path
    files: PersonaFiles
    total_size: int = 0
    issues: List[str] = field(default_factory=list)
    file_ages: Dict[str, int] = field(default_factory=dict)  # days

    @property
    def health_score(self) -> float:
        """Calculate health score (0-100)."""
        files_present = sum([
            self.files.definition,
            self.files.journal,
            self.files.tasks,
            self.files.knowledge,
        ])
        files_score = (files_present / 4) * 100
        issue_penalty = len(self.issues) * 5
        return max(0, files_score - issue_penalty)

    @property
    def is_healthy(self) -> bool:
        """Check if persona is healthy (score >= 80)."""
        return self.health_score >= 80


@dataclass
class FrequencyReport:
    """Interaction frequency analysis results."""
    total_sessions: int
    sessions_by_member: Dict[str, int] = field(default_factory=dict)
    average_per_week: float = 0.0


@dataclass
class SentimentReport:
    """Sentiment analysis results."""
    positive_count: int = 0
    negative_count: int = 0

    @property
    def score(self) -> float:
        """Calculate sentiment score (0-100)."""
        total = self.positive_count + self.negative_count
        if total == 0:
            return 50.0
        return (self.positive_count / total) * 100

    @property
    def trend(self) -> str:
        """Get trend indicator."""
        score = self.score
        if score > 60:
            return "↗"
        elif score < 40:
            return "↘"
        return "→"


@dataclass
class CollaborationReport:
    """Collaboration pattern analysis results."""
    collaborators: Dict[str, int] = field(default_factory=dict)  # persona -> count
    pairs: Dict[str, int] = field(default_factory=dict)  # "a<->b" -> count

    @property
    def top_collaborators(self) -> List[tuple]:
        """Get top 3 collaborators by interaction count."""
        sorted_collab = sorted(
            self.collaborators.items(),
            key=lambda x: x[1],
            reverse=True
        )
        return sorted_collab[:3]


@dataclass
class TopicReport:
    """Topic extraction analysis results."""
    topics: Dict[str, int] = field(default_factory=dict)  # topic -> count

    @property
    def top_topics(self) -> List[tuple]:
        """Get top 5 topics by frequency."""
        sorted_topics = sorted(
            self.topics.items(),
            key=lambda x: x[1],
            reverse=True
        )
        return sorted_topics[:5]


@dataclass
class TeamAnalysisReport:
    """Complete team analysis report."""
    team_id: str
    period_days: int
    frequency: FrequencyReport
    sentiment: SentimentReport
    collaborations: CollaborationReport
    topics: TopicReport
    learning_velocity: float = 0.0
