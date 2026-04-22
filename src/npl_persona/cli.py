"""
CLI interface for npl_persona.

Provides argparse setup and command dispatch.
"""

import argparse
import os
import sys
from collections import defaultdict
from typing import Optional

from .persona import PersonaManager
from .journal import JournalManager
from .tasks import TaskManager
from .knowledge import KnowledgeManager
from .teams import TeamManager
from .analysis import JournalAnalyzer, TaskAnalyzer
from .paths import resolve_persona
from .io import read_file
from .parsers import parse_journal_entries, parse_tasks


def create_parser() -> argparse.ArgumentParser:
    """Create and configure argument parser."""
    parser = argparse.ArgumentParser(
        description="NPL Persona Management Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Create and manage personas
  npl-persona init sarah-architect --role=architect
  npl-persona list --scope=all
  npl-persona which qa-engineer
  npl-persona get sarah-architect --files=definition,journal

  # Journal operations
  npl-persona journal sarah-architect add --message="Learned about API patterns"
  npl-persona journal sarah-architect view --entries=5

  # Task management
  npl-persona task sarah-architect add "Review API design" --due=2025-10-15
  npl-persona task sarah-architect list
  npl-persona task sarah-architect update "Review API" --status=completed

  # Knowledge base
  npl-persona kb sarah-architect add "GraphQL" --content="Query language for APIs"
  npl-persona kb sarah-architect search "API"
  npl-persona kb sarah-architect get "GraphQL"
  npl-persona kb sarah-architect update-domain "Architecture" --confidence=85

  # Health and sync
  npl-persona health --all
  npl-persona health sarah-architect --verbose
  npl-persona sync sarah-architect --validate

  # Backup and sharing
  npl-persona backup sarah-architect --output=./backups
  npl-persona backup --all
  npl-persona share sarah-architect mike-backend --topic="API patterns"

  # Analytics and reporting
  npl-persona analyze sarah-architect --type=journal --period=30
  npl-persona analyze sarah-architect --type=tasks --period=90
  npl-persona report sarah-architect --format=md --period=quarter
        """
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    # Init command
    sp_init = subparsers.add_parser("init", help="Create new persona with all mandatory files")
    sp_init.add_argument("persona_id", help="Persona identifier (e.g., sarah-architect)")
    sp_init.add_argument("--role", help="Role/title for the persona")
    sp_init.add_argument("--scope", choices=["project", "user", "system"], default="project",
                         help="Where to create persona (default: project)")
    sp_init.add_argument("--from-template", metavar="SCOPE", choices=["system", "user"],
                         help="Copy from existing persona in specified scope")

    # Get command
    sp_get = subparsers.add_parser("get", help="Fetch persona files")
    sp_get.add_argument("persona_id", help="Persona identifier")
    sp_get.add_argument("--files", default="all",
                        help="Files to load: definition,journal,tasks,knowledge or all (default: all)")
    sp_get.add_argument("--skip", nargs="*", default=[],
                        help="Skip personas if already loaded")

    # List command
    sp_list = subparsers.add_parser("list", help="List available personas")
    sp_list.add_argument("--scope", choices=["project", "user", "system", "all"], default="all",
                         help="Filter by scope (default: all)")
    sp_list.add_argument("--verbose", "-v", action="store_true",
                         help="Show detailed information")

    # Which command
    sp_which = subparsers.add_parser("which", help="Locate persona in search paths")
    sp_which.add_argument("persona_id", help="Persona identifier")

    # Remove command
    sp_remove = subparsers.add_parser("remove", help="Delete persona files")
    sp_remove.add_argument("persona_id", help="Persona identifier")
    sp_remove.add_argument("--scope", choices=["project", "user", "system"],
                           help="Only delete from specified scope")
    sp_remove.add_argument("--force", "-f", action="store_true",
                           help="Skip confirmation prompt")

    # Journal commands
    sp_journal = subparsers.add_parser("journal", help="Journal operations")
    sp_journal.add_argument("persona_id", help="Persona identifier")
    sp_journal.add_argument("action", choices=["add", "view", "archive"],
                            help="Journal action")
    sp_journal.add_argument("--message", help="Journal entry message (for add)")
    sp_journal.add_argument("--interactive", "-i", action="store_true",
                            help="Interactive mode for add")
    sp_journal.add_argument("--entries", type=int, default=5,
                            help="Number of entries to view (default: 5)")
    sp_journal.add_argument("--since", help="View entries since date (YYYY-MM-DD)")
    sp_journal.add_argument("--before", help="Archive entries before date (YYYY-MM-DD)")

    # Health command
    sp_health = subparsers.add_parser("health", help="Check persona file health")
    sp_health.add_argument("persona_id", nargs="?", help="Persona identifier")
    sp_health.add_argument("--all", action="store_true",
                           help="Check all personas")
    sp_health.add_argument("--verbose", "-v", action="store_true",
                           help="Show detailed information")

    # Task commands
    sp_task = subparsers.add_parser("task", help="Task management operations")
    sp_task.add_argument("persona_id", help="Persona identifier")
    sp_task.add_argument("action", choices=["add", "update", "complete", "list", "remove"],
                         help="Task action")
    sp_task.add_argument("task_description", nargs="?",
                         help="Task description (for add) or pattern (for update/complete)")
    sp_task.add_argument("--due", help="Due date (YYYY-MM-DD)")
    sp_task.add_argument("--priority", choices=["high", "med", "low"], default="med",
                         help="Task priority (default: med)")
    sp_task.add_argument("--status", choices=["pending", "in-progress", "blocked", "completed"],
                         help="New status (for update)")
    sp_task.add_argument("--filter", help="Filter tasks by status (for list)")
    sp_task.add_argument("--note", help="Completion note (for complete)")

    # Knowledge base commands
    sp_kb = subparsers.add_parser("kb", help="Knowledge base operations")
    sp_kb.add_argument("persona_id", help="Persona identifier")
    sp_kb.add_argument("action", choices=["add", "search", "get", "update-domain"],
                       help="Knowledge base action")
    sp_kb.add_argument("topic", nargs="?", help="Topic name or search query")
    sp_kb.add_argument("--content", help="Knowledge content")
    sp_kb.add_argument("--source", help="Knowledge source")
    sp_kb.add_argument("--domain", help="Knowledge domain filter")
    sp_kb.add_argument("--confidence", type=int, help="Confidence level 0-100 (for update-domain)")

    # Sync command
    sp_sync = subparsers.add_parser("sync", help="Synchronize and validate persona files")
    sp_sync.add_argument("persona_id", help="Persona identifier")
    sp_sync.add_argument("--validate", action="store_true", default=True,
                         help="Validate file structure (default: true)")
    sp_sync.add_argument("--no-validate", dest="validate", action="store_false",
                         help="Skip validation")

    # Backup command
    sp_backup = subparsers.add_parser("backup", help="Backup persona data")
    sp_backup.add_argument("persona_id", nargs="?", help="Persona identifier (or use --all)")
    sp_backup.add_argument("--all", action="store_true",
                           help="Backup all personas")
    sp_backup.add_argument("--output", help="Output directory (default: ./backups)")

    # Share command
    sp_share = subparsers.add_parser("share", help="Share knowledge between personas")
    sp_share.add_argument("from_persona", help="Source persona")
    sp_share.add_argument("to_persona", help="Target persona")
    sp_share.add_argument("--topic", required=True, help="Knowledge topic to share")
    sp_share.add_argument("--translate", action="store_true",
                          help="Translate knowledge to target context")

    # Analyze command
    sp_analyze = subparsers.add_parser("analyze", help="Analyze persona data")
    sp_analyze.add_argument("persona_id", help="Persona identifier")
    sp_analyze.add_argument("--type", choices=["journal", "tasks"], default="journal",
                            help="Analysis type (default: journal)")
    sp_analyze.add_argument("--period", type=int, default=30,
                            help="Analysis period in days (default: 30)")

    # Report command
    sp_report = subparsers.add_parser("report", help="Generate persona report")
    sp_report.add_argument("persona_id", help="Persona identifier")
    sp_report.add_argument("--format", choices=["md", "json", "html"], default="md",
                           help="Report format (default: md)")
    sp_report.add_argument("--period", choices=["week", "month", "quarter", "year"], default="month",
                           help="Report period (default: month)")

    # Team commands
    sp_team = subparsers.add_parser("team", help="Team management operations")
    sp_team.add_argument("action", choices=["create", "add", "list", "synthesize", "matrix", "analyze"],
                         help="Team action")
    sp_team.add_argument("team_id", help="Team identifier")
    sp_team.add_argument("persona_id", nargs="?", help="Persona to add (for add action)")
    sp_team.add_argument("--members", help="Comma-separated list of persona IDs (for create)")
    sp_team.add_argument("--scope", choices=["project", "user", "system"], default="project",
                         help="Scope for team creation (default: project)")
    sp_team.add_argument("--output", help="Output file path (for synthesize)")
    sp_team.add_argument("--period", type=int, default=30,
                         help="Analysis period in days (for analyze, default: 30)")
    sp_team.add_argument("--verbose", "-v", action="store_true",
                         help="Show detailed information (for list)")

    return parser


def dispatch(args: argparse.Namespace) -> bool:
    """
    Dispatch command to appropriate handler.

    Args:
        args: Parsed arguments

    Returns:
        True on success, False on failure
    """
    persona_mgr = PersonaManager()
    journal_mgr = JournalManager()
    task_mgr = TaskManager()
    kb_mgr = KnowledgeManager()
    team_mgr = TeamManager()

    if args.command == "init":
        return persona_mgr.init_persona(
            args.persona_id,
            role=args.role,
            scope=args.scope,
            from_template=args.from_template
        )

    elif args.command == "get":
        skip_set = set(args.skip) if args.skip else set()
        success = persona_mgr.get_persona(args.persona_id, args.files, skip_set)

        # Output tracking flags
        if success and persona_mgr.loaded_personas:
            print("\n# Flag Update")
            print("```🏳️")
            print(f'@npl.personas.loaded+="{",".join(sorted(persona_mgr.loaded_personas))}"')
            print("```\n")

        return success

    elif args.command == "list":
        personas = persona_mgr.list_personas(args.scope)

        if not personas:
            scope_msg = f" in {args.scope} scope" if args.scope != "all" else ""
            print(f"No personas found{scope_msg}")
            return True

        if args.scope == "all":
            by_scope = defaultdict(list)
            for pid, info in personas.items():
                by_scope[info["scope"]].append((pid, info))

            for scope in ["project", "user", "system"]:
                if scope in by_scope:
                    print(f"{scope.capitalize()} personas:")
                    for pid, info in sorted(by_scope[scope]):
                        if args.verbose:
                            files_status = ", ".join([
                                f"{ft}:{'✓' if info['files'].get(ft) else '✗'}"
                                for ft in ["definition", "journal", "tasks", "knowledge"]
                            ])
                            print(f"  - {pid} [{files_status}]")
                        else:
                            print(f"  - {pid}")
                    print()
        else:
            for pid in sorted(personas.keys()):
                info = personas[pid]
                if args.verbose:
                    files_status = ", ".join([
                        f"{ft}:{'✓' if info['files'].get(ft) else '✗'}"
                        for ft in ["definition", "journal", "tasks", "knowledge"]
                    ])
                    print(f"{pid} [{files_status}]")
                else:
                    print(pid)

        return True

    elif args.command == "which":
        return persona_mgr.which_persona(args.persona_id)

    elif args.command == "remove":
        return persona_mgr.remove_persona(
            args.persona_id,
            scope=args.scope,
            force=args.force
        )

    elif args.command == "journal":
        if args.action == "add":
            return journal_mgr.add_entry(
                args.persona_id,
                message=args.message,
                interactive=args.interactive
            )
        elif args.action == "view":
            return journal_mgr.view_entries(
                args.persona_id,
                entries=args.entries,
                since=args.since
            )
        elif args.action == "archive":
            if not args.before:
                print("Error: --before date required for archive", file=sys.stderr)
                return False
            return journal_mgr.archive_entries(args.persona_id, args.before)

    elif args.command == "health":
        return persona_mgr.health_check(
            persona_id=args.persona_id,
            verbose=args.verbose,
            check_all=args.all
        )

    elif args.command == "task":
        if args.action == "add":
            if not args.task_description:
                print("Error: task_description required for add action", file=sys.stderr)
                return False
            return task_mgr.add_task(
                args.persona_id,
                args.task_description,
                due=args.due,
                priority=args.priority
            )
        elif args.action == "update":
            if not args.task_description or not args.status:
                print("Error: task_description and --status required for update", file=sys.stderr)
                return False
            return task_mgr.update_task(args.persona_id, args.task_description, args.status)
        elif args.action == "complete":
            if not args.task_description:
                print("Error: task_description required for complete", file=sys.stderr)
                return False
            return task_mgr.update_task(args.persona_id, args.task_description, "completed")
        elif args.action == "list":
            return task_mgr.list_tasks(args.persona_id, status_filter=args.filter)
        elif args.action == "remove":
            if not args.task_description:
                print("Error: task_description required for remove", file=sys.stderr)
                return False
            return task_mgr.remove_task(args.persona_id, args.task_description)

    elif args.command == "kb":
        if args.action == "add":
            if not args.topic:
                print("Error: topic required for add action", file=sys.stderr)
                return False
            return kb_mgr.add_entry(
                args.persona_id,
                args.topic,
                content=args.content,
                source=args.source
            )
        elif args.action == "search":
            if not args.topic:
                print("Error: topic (search query) required", file=sys.stderr)
                return False
            return kb_mgr.search(args.persona_id, args.topic, domain=args.domain)
        elif args.action == "get":
            if not args.topic:
                print("Error: topic required for get", file=sys.stderr)
                return False
            return kb_mgr.get_entry(args.persona_id, args.topic)
        elif args.action == "update-domain":
            if not args.topic or args.confidence is None:
                print("Error: topic and --confidence required for update-domain", file=sys.stderr)
                return False
            return kb_mgr.update_domain(args.persona_id, args.topic, args.confidence)

    elif args.command == "sync":
        return persona_mgr.sync_persona(args.persona_id, validate=args.validate)

    elif args.command == "backup":
        return persona_mgr.backup_persona(
            persona_id=args.persona_id,
            output=args.output,
            backup_all=args.all
        )

    elif args.command == "share":
        return kb_mgr.share_knowledge(
            args.from_persona,
            args.to_persona,
            args.topic,
            translate=args.translate
        )

    elif args.command == "analyze":
        return _handle_analyze(args)

    elif args.command == "report":
        return _handle_report(args, persona_mgr)

    elif args.command == "team":
        if args.action == "create":
            members_list = None
            if args.members:
                members_list = [m.strip() for m in args.members.split(",")]
            return team_mgr.create_team(args.team_id, members=members_list, scope=args.scope)
        elif args.action == "add":
            if not args.persona_id:
                print("Error: persona_id required for 'add' action", file=sys.stderr)
                return False
            return team_mgr.add_member(args.team_id, args.persona_id)
        elif args.action == "list":
            return team_mgr.list_members(args.team_id, verbose=args.verbose)
        elif args.action == "synthesize":
            return team_mgr.synthesize_knowledge(args.team_id, output=args.output)
        elif args.action == "matrix":
            return team_mgr.show_matrix(args.team_id)
        elif args.action == "analyze":
            return team_mgr.analyze_team(args.team_id, period=args.period)

    print(f"Command '{args.command}' not yet implemented", file=sys.stderr)
    return False


def _handle_analyze(args: argparse.Namespace) -> bool:
    """Handle analyze command."""
    location = resolve_persona(args.persona_id)
    if not location:
        print(f"Error: Persona '{args.persona_id}' not found", file=sys.stderr)
        return False

    base_path, scope = location

    if args.type == "journal":
        journal_file = base_path / f"{args.persona_id}.journal.md"
        if not journal_file.exists():
            print(f"Error: Journal file not found", file=sys.stderr)
            return False

        result = read_file(journal_file)
        if result.is_err():
            print(f"Error reading journal: {result.error}", file=sys.stderr)
            return False

        entries = parse_journal_entries(result.value)
        analyzer = JournalAnalyzer(entries, args.period)

        print(f"📊 Journal Analysis (Last {args.period} days)\n")
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

    elif args.type == "tasks":
        tasks_file = base_path / f"{args.persona_id}.tasks.md"
        if not tasks_file.exists():
            print(f"Error: Tasks file not found", file=sys.stderr)
            return False

        result = read_file(tasks_file)
        if result.is_err():
            print(f"Error reading tasks: {result.error}", file=sys.stderr)
            return False

        tasks = parse_tasks(result.value)
        analyzer = TaskAnalyzer(tasks, args.period)

        print(f"📈 Task Completion Analysis (Last {args.period} days)\n")
        print(f"Total tasks: {len(tasks)}")

        breakdown = analyzer.get_status_breakdown()
        completion_rate = analyzer.get_completion_rate()

        from .models import TaskStatus
        print(f"Completed: {breakdown.get(TaskStatus.COMPLETED, 0)} ({completion_rate:.0f}%)")
        print(f"In Progress: {breakdown.get(TaskStatus.IN_PROGRESS, 0)}")
        print(f"Blocked: {breakdown.get(TaskStatus.BLOCKED, 0)}")

        return True

    return False


def _handle_report(args: argparse.Namespace, persona_mgr: PersonaManager) -> bool:
    """Handle report command."""
    from datetime import datetime
    from pathlib import Path

    location = resolve_persona(args.persona_id)
    if not location:
        print(f"Error: Persona '{args.persona_id}' not found", file=sys.stderr)
        return False

    base_path, scope = location
    period_days = {"week": 7, "month": 30, "quarter": 90, "year": 365}.get(args.period, 30)

    report_date = datetime.now().strftime("%Y-%m-%d")
    report_file = base_path / f"{args.persona_id}-{args.period}-{report_date}.{args.format}"

    print(f"Generating {args.period} report for {args.persona_id}...")

    title = args.persona_id.replace("-", " ").title()
    report_content = f"""# {title} - {args.period.title()} Report
**Generated**: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
**Period**: Last {period_days} days
**Scope**: {scope}

## Executive Summary

Persona {args.persona_id} has been active in the {scope} scope.

## Health Status

"""

    files = persona_mgr._check_persona_files(args.persona_id, base_path)
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

    from .io import write_file
    result = write_file(report_file, report_content)
    if result.is_err():
        print(f"Error writing report: {result.error}", file=sys.stderr)
        return False

    print(f"✅ Report saved: {report_file}")
    return True


def main() -> int:
    """
    Main entry point.

    Returns:
        Exit code (0 for success, 1 for failure)
    """
    parser = create_parser()
    args = parser.parse_args()

    try:
        success = dispatch(args)
        return 0 if success else 1

    except KeyboardInterrupt:
        print("\nCancelled by user", file=sys.stderr)
        return 130

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        if os.environ.get("DEBUG"):
            raise
        return 1
