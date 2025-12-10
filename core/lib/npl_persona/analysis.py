"""
Analysis utilities for npl_persona.

Decomposes the massive analyze_team() method (654 lines, complexity 137)
into focused, testable analyzers with clear responsibilities.
"""

import re
from collections import defaultdict
from datetime import datetime, timedelta, date
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from .config import (
    SENTIMENT_POSITIVE,
    SENTIMENT_NEGATIVE,
    LEARNING_KEYWORDS,
    DATE_FORMAT,
    DEFAULT_ANALYSIS_PERIOD,
)
from .models import (
    JournalEntry,
    Task,
    TaskStatus,
    FrequencyReport,
    SentimentReport,
    CollaborationReport,
    TopicReport,
    TeamAnalysisReport,
)
from .parsers import parse_journal_entries, extract_mentions


class JournalAnalyzer:
    """Analyzes journal entries for patterns and insights."""

    def __init__(self, entries: List[JournalEntry], period_days: int = DEFAULT_ANALYSIS_PERIOD):
        """
        Initialize analyzer with journal entries.

        Args:
            entries: List of journal entries to analyze
            period_days: Number of days to analyze (from now backwards)
        """
        self.period_days = period_days
        self.cutoff_date = date.today() - timedelta(days=period_days)

        # Filter entries to period
        self.entries = [
            e for e in entries
            if e.date >= self.cutoff_date
        ]

    def analyze_frequency(self) -> FrequencyReport:
        """
        Analyze interaction frequency.

        Returns:
            FrequencyReport with session counts
        """
        total = len(self.entries)
        average_per_week = total / (self.period_days / 7) if self.period_days >= 7 else total

        return FrequencyReport(
            total_sessions=total,
            sessions_by_member={},  # Populated when analyzing team
            average_per_week=average_per_week,
        )

    def analyze_sentiment(self) -> SentimentReport:
        """
        Analyze sentiment using keyword matching.

        Returns:
            SentimentReport with positive/negative counts
        """
        positive_count = 0
        negative_count = 0

        for entry in self.entries:
            text_lower = entry.content.lower()
            positive_count += sum(1 for kw in SENTIMENT_POSITIVE if kw in text_lower)
            negative_count += sum(1 for kw in SENTIMENT_NEGATIVE if kw in text_lower)

        return SentimentReport(
            positive_count=positive_count,
            negative_count=negative_count,
        )

    def analyze_collaborations(self, team_members: Optional[List[str]] = None) -> CollaborationReport:
        """
        Analyze collaboration patterns from @mentions.

        Args:
            team_members: Optional list of team member IDs to filter

        Returns:
            CollaborationReport with collaborator counts
        """
        collaborators: Dict[str, int] = defaultdict(int)
        pairs: Dict[str, int] = defaultdict(int)

        for entry in self.entries:
            mentions = extract_mentions(entry.content)

            # Filter to team members if provided
            if team_members:
                mentions = [m for m in mentions if m in team_members]

            for mention in mentions:
                collaborators[mention] += 1

        return CollaborationReport(
            collaborators=dict(collaborators),
            pairs=dict(pairs),
        )

    def analyze_topics(self) -> TopicReport:
        """
        Extract discussed topics from entries.

        Uses simple heuristic: capitalized word sequences.

        Returns:
            TopicReport with topic frequencies
        """
        topics: Dict[str, int] = defaultdict(int)

        for entry in self.entries:
            # Extract capitalized words/phrases
            matches = re.findall(r"\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\b", entry.content)
            for topic in matches:
                if len(topic) > 3:  # Skip short words
                    topics[topic] += 1

        return TopicReport(topics=dict(topics))

    def calculate_learning_velocity(self) -> float:
        """
        Calculate learning velocity (concepts learned per week).

        Returns:
            Learning events per week
        """
        learning_count = 0

        for entry in self.entries:
            text_lower = entry.content.lower()
            if any(kw in text_lower for kw in LEARNING_KEYWORDS):
                learning_count += 1

        if self.period_days >= 7:
            return learning_count / (self.period_days / 7)
        return learning_count


class TaskAnalyzer:
    """Analyzes task completion patterns."""

    def __init__(self, tasks: List[Task], period_days: int = DEFAULT_ANALYSIS_PERIOD):
        """
        Initialize analyzer with tasks.

        Args:
            tasks: List of tasks to analyze
            period_days: Analysis period in days
        """
        self.tasks = tasks
        self.period_days = period_days

    def get_status_breakdown(self) -> Dict[TaskStatus, int]:
        """Get count of tasks by status."""
        breakdown: Dict[TaskStatus, int] = defaultdict(int)
        for task in self.tasks:
            breakdown[task.status] += 1
        return dict(breakdown)

    def get_completion_rate(self) -> float:
        """Calculate task completion rate (0-100)."""
        if not self.tasks:
            return 0.0

        completed = sum(1 for t in self.tasks if t.status == TaskStatus.COMPLETED)
        return (completed / len(self.tasks)) * 100

    def get_overdue_tasks(self) -> List[Task]:
        """Get tasks that are past due date."""
        today = date.today()
        return [
            t for t in self.tasks
            if t.due and t.due < today and t.status != TaskStatus.COMPLETED
        ]


class TeamAnalyzer:
    """
    Analyzes team collaboration patterns.

    Decomposed from the original 654-line analyze_team() method.
    """

    def __init__(
        self,
        team_id: str,
        members: List[str],
        period_days: int = DEFAULT_ANALYSIS_PERIOD
    ):
        """
        Initialize team analyzer.

        Args:
            team_id: Team identifier
            members: List of team member persona IDs
            period_days: Analysis period in days
        """
        self.team_id = team_id
        self.members = members
        self.period_days = period_days
        self.cutoff_date = datetime.now() - timedelta(days=period_days)

        # Will be populated during analysis
        self.member_journals: Dict[str, List[JournalEntry]] = {}
        self.interaction_count = 0
        self.collaboration_pairs: Dict[Tuple[str, str], int] = defaultdict(int)
        self.member_activity: Dict[str, int] = defaultdict(int)
        self.topics_discussed: Dict[str, int] = defaultdict(int)

    def load_member_journal(self, member_id: str, journal_content: str) -> None:
        """
        Load and parse a member's journal content.

        Args:
            member_id: Member persona ID
            journal_content: Raw journal file content
        """
        entries = parse_journal_entries(journal_content)

        # Filter to period
        filtered = [
            e for e in entries
            if e.date >= self.cutoff_date.date()
        ]

        self.member_journals[member_id] = filtered

    def analyze_interactions(self) -> None:
        """Analyze all member interactions within the period."""
        for member_id, entries in self.member_journals.items():
            for entry in entries:
                self.interaction_count += 1
                self.member_activity[member_id] += 1

                # Find collaborations with other team members
                for other_member in self.members:
                    if other_member != member_id and f"@{other_member}" in entry.content:
                        pair = tuple(sorted([member_id, other_member]))
                        self.collaboration_pairs[pair] += 1

                # Extract topics
                topic_matches = re.findall(
                    r"\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\b",
                    entry.content
                )
                for topic in topic_matches:
                    if len(topic) > 3:
                        self.topics_discussed[topic] += 1

    def get_frequency_report(self) -> FrequencyReport:
        """Get interaction frequency report."""
        avg_per_week = self.interaction_count / (self.period_days / 7) if self.period_days >= 7 else self.interaction_count

        return FrequencyReport(
            total_sessions=self.interaction_count,
            sessions_by_member=dict(self.member_activity),
            average_per_week=avg_per_week,
        )

    def get_collaboration_report(self) -> CollaborationReport:
        """Get collaboration patterns report."""
        # Convert pairs dict to string keys for JSON compatibility
        pairs_str = {
            f"{p[0]}<->{p[1]}": count
            for p, count in self.collaboration_pairs.items()
        }

        # Aggregate collaborators from pairs
        collaborators: Dict[str, int] = defaultdict(int)
        for (m1, m2), count in self.collaboration_pairs.items():
            collaborators[m1] += count
            collaborators[m2] += count

        return CollaborationReport(
            collaborators=dict(collaborators),
            pairs=pairs_str,
        )

    def get_topic_report(self) -> TopicReport:
        """Get topic analysis report."""
        return TopicReport(topics=dict(self.topics_discussed))

    def calculate_collaboration_index(self) -> float:
        """
        Calculate team collaboration index.

        Measures what percentage of possible collaboration pairs are active.

        Returns:
            Collaboration index (0-100)
        """
        if len(self.members) <= 1:
            return 0.0

        possible_pairs = len(self.members) * (len(self.members) - 1) // 2
        actual_pairs = len(self.collaboration_pairs)

        return (actual_pairs / possible_pairs * 100) if possible_pairs > 0 else 0

    def get_full_report(self) -> TeamAnalysisReport:
        """
        Generate complete team analysis report.

        Returns:
            TeamAnalysisReport with all analysis results
        """
        # Run analysis if not done
        if not self.member_activity and self.member_journals:
            self.analyze_interactions()

        # Calculate sentiment across all journals
        all_entries = []
        for entries in self.member_journals.values():
            all_entries.extend(entries)

        journal_analyzer = JournalAnalyzer(all_entries, self.period_days)
        sentiment = journal_analyzer.analyze_sentiment()
        learning_velocity = journal_analyzer.calculate_learning_velocity()

        return TeamAnalysisReport(
            team_id=self.team_id,
            period_days=self.period_days,
            frequency=self.get_frequency_report(),
            sentiment=sentiment,
            collaborations=self.get_collaboration_report(),
            topics=self.get_topic_report(),
            learning_velocity=learning_velocity,
        )


def format_activity_bar(count: int, scale: int = 2) -> str:
    """
    Format activity count as a bar graph.

    Args:
        count: Activity count
        scale: How many counts per bar character

    Returns:
        String of block characters
    """
    return "█" * (count // scale) if count > 0 else ""


def format_team_analysis_text(report: TeamAnalysisReport) -> str:
    """
    Format team analysis report as text output.

    Args:
        report: TeamAnalysisReport to format

    Returns:
        Formatted text string
    """
    lines = []
    lines.append(f"📊 Team Collaboration Analysis: {report.team_id.replace('-', ' ').title()}")
    lines.append(f"Period: Last {report.period_days} days\n")

    # Frequency
    lines.append(f"**Total Interactions**: {report.frequency.total_sessions}")
    active_members = len([m for m, c in report.frequency.sessions_by_member.items() if c > 0])
    total_members = len(report.frequency.sessions_by_member)
    lines.append(f"**Active Members**: {active_members}/{total_members}\n")

    # Member activity
    if report.frequency.sessions_by_member:
        lines.append("**Member Activity**:")
        sorted_activity = sorted(
            report.frequency.sessions_by_member.items(),
            key=lambda x: x[1],
            reverse=True
        )
        for member, count in sorted_activity:
            bar = format_activity_bar(count)
            lines.append(f"  @{member}: {bar} {count} interactions")
        lines.append("")

    # Collaboration pairs
    if report.collaborations.pairs:
        lines.append("**Top Collaboration Pairs**:")
        sorted_pairs = sorted(
            report.collaborations.pairs.items(),
            key=lambda x: x[1],
            reverse=True
        )[:5]
        for pair, count in sorted_pairs:
            m1, m2 = pair.split("<->")
            lines.append(f"  @{m1} ↔ @{m2}: {count} interactions")
        lines.append("")

    # Topics
    if report.topics.top_topics:
        lines.append("**Frequently Discussed Topics**:")
        for topic, count in report.topics.top_topics:
            lines.append(f"  - {topic} ({count})")
        lines.append("")

    # Team health metrics
    collab_index = (
        len(report.collaborations.pairs) /
        (len(report.frequency.sessions_by_member) * (len(report.frequency.sessions_by_member) - 1) // 2) * 100
        if len(report.frequency.sessions_by_member) > 1 else 0
    )

    lines.append("**Team Health Metrics**:")
    actual_pairs = len(report.collaborations.pairs)
    n_members = len(report.frequency.sessions_by_member)
    possible_pairs = n_members * (n_members - 1) // 2 if n_members > 1 else 0
    lines.append(f"  Collaboration Index: {collab_index:.0f}% ({actual_pairs}/{possible_pairs} pairs active)")

    if report.frequency.total_sessions > 0 and n_members > 0:
        avg_interactions = report.frequency.total_sessions / n_members
        lines.append(f"  Average Interactions per Member: {avg_interactions:.1f}")

    lines.append("")

    return "\n".join(lines)
