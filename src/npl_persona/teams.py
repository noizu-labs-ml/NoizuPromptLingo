"""
Team operations for npl_persona.

Handles team create, add, list, synthesize, matrix, and analyze operations.
"""

import re
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

from .config import DATE_FORMAT, TABLE_MARKERS, SECTIONS
from .models import TeamMember
from .paths import PathResolver, ResourceType, resolve_persona, resolve_team
from .io import read_file, write_file, ensure_dir
from .parsers import parse_team_members, extract_persona_role, parse_knowledge_domains
from .templates import generate_team_definition, generate_team_history, generate_member_row
from .analysis import TeamAnalyzer, format_team_analysis_text


class TeamManager:
    """Manages team operations."""

    def __init__(self):
        """Initialize team manager."""
        self.resolver = PathResolver(ResourceType.TEAMS)

    def create_team(
        self,
        team_id: str,
        members: Optional[List[str]] = None,
        scope: str = "project"
    ) -> bool:
        """
        Create a new team.

        Args:
            team_id: Team identifier
            members: Optional list of initial member persona IDs
            scope: Where to create team (project/user/system)

        Returns:
            True on success, False on failure
        """
        team_path = self.resolver.get_target_path(scope)

        # Ensure directory exists
        result = ensure_dir(team_path)
        if result.is_err():
            print(f"Error: {result.error}", file=sys.stderr)
            return False

        team_file = team_path / f"{team_id}.team.md"

        if team_file.exists():
            print(f"Error: Team '{team_id}' already exists at {team_path}", file=sys.stderr)
            return False

        # Build member rows
        member_rows = []
        member_list = members or []

        for member_id in member_list:
            location = resolve_persona(member_id)
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

        # Generate team definition
        team_content = generate_team_definition(team_id, scope, member_rows_str)

        result = write_file(team_file, team_content)
        if result.is_err():
            print(f"Error creating team file: {result.error}", file=sys.stderr)
            return False

        print(f"✨ Team '{team_id}' created successfully at {scope} scope")
        if member_list:
            print(f"   Members: {', '.join([f'@{m}' for m in member_list])}")

        # Create team history file
        history_file = team_path / f"{team_id}.history.md"
        initial_members = ", ".join([f"@{m}" for m in member_list]) if member_list else "None"
        history_content = generate_team_history(team_id, initial_members)

        result = write_file(history_file, history_content)
        if result.is_err():
            print(f"Warning: Failed to create team history: {result.error}", file=sys.stderr)
        else:
            print(f"   Created team history: {team_id}.history.md")

        return True

    def add_member(self, team_id: str, persona_id: str) -> bool:
        """
        Add a persona to an existing team.

        Args:
            team_id: Team identifier
            persona_id: Persona to add

        Returns:
            True on success, False on failure
        """
        location = resolve_team(team_id)
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

        # Check if already member
        if f"@{persona_id}" in content:
            print(f"Warning: @{persona_id} is already a member of {team_id}")
            return False

        # Get role from persona
        role = "Member"
        persona_location = resolve_persona(persona_id)
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

        # Create new row
        new_row = generate_member_row(persona_id, role)

        # Find the table and add row
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

        # Insert the new row
        if last_row_index >= 0:
            new_lines = lines[:last_row_index + 1] + [new_row] + lines[last_row_index + 1:]
        else:
            # No existing members, find table header
            for i, line in enumerate(lines):
                if TABLE_MARKERS["team"] in line:
                    new_lines = lines[:i + 1] + [new_row] + lines[i + 1:]
                    break

        # Write back
        result = write_file(team_file, "\n".join(new_lines))
        if result.is_err():
            print(f"Error writing team file: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Added @{persona_id} ({role}) to team '{team_id}'")

        # Log to history
        history_file = base_path / f"{team_id}.history.md"
        if history_file.exists():
            result = read_file(history_file)
            if result.is_ok():
                joined_date = datetime.now().strftime(DATE_FORMAT)
                history_entry = f"\n### {joined_date} - Member Joined\n**New Member**: @{persona_id} ({role})\n\n---\n"
                new_history = result.value + history_entry
                write_file(history_file, new_history)

        return True

    def list_members(self, team_id: str, verbose: bool = False) -> bool:
        """
        List team members.

        Args:
            team_id: Team identifier
            verbose: Show detailed information

        Returns:
            True on success, False on failure
        """
        location = resolve_team(team_id)
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

        # Display
        title = team_id.replace("-", " ").title()
        print(f"\n# Team: {title}")
        print(f"**Scope**: {scope}")
        print(f"**Members**: {len(members)}\n")

        if not members:
            print("No members in this team yet.")
            return True

        if verbose:
            print(f"{'Persona':<25} {'Role':<20} {'Joined':<12} {'Status':<10}")
            print("-" * 67)
            for member in members:
                print(f"@{member.persona_id:<24} {member.role:<20} {member.joined.strftime(DATE_FORMAT):<12} {member.status:<10}")
        else:
            for member in members:
                print(f"  - @{member.persona_id} ({member.role})")

        print()
        return True

    def synthesize_knowledge(
        self,
        team_id: str,
        output: Optional[str] = None
    ) -> bool:
        """
        Synthesize knowledge from all team members.

        Args:
            team_id: Team identifier
            output: Optional output file path

        Returns:
            True on success, False on failure
        """
        location = resolve_team(team_id)
        if not location:
            print(f"Error: Team '{team_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        team_file = base_path / f"{team_id}.team.md"

        # Get team members
        result = read_file(team_file)
        if result.is_err():
            print(f"Error reading team file: {result.error}", file=sys.stderr)
            return False

        members = parse_team_members(result.value)

        if not members:
            print(f"Error: No members in team '{team_id}'", file=sys.stderr)
            return False

        print(f"Synthesizing knowledge from {len(members)} team members...")

        # Collect knowledge from each member
        all_knowledge: Dict[str, List[dict]] = {}
        domain_experts: Dict[str, List[tuple]] = defaultdict(list)

        for member in members:
            persona_location = resolve_persona(member.persona_id)
            if not persona_location:
                print(f"  ⚠️  Skipping {member.persona_id}: not found")
                continue

            persona_base, _ = persona_location
            kb_file = persona_base / f"{member.persona_id}.knowledge-base.md"

            if not kb_file.exists():
                print(f"  ⚠️  Skipping {member.persona_id}: no knowledge base")
                continue

            print(f"  📚 Processing @{member.persona_id}...")

            result = read_file(kb_file)
            if result.is_err():
                continue

            kb_content = result.value
            domains = parse_knowledge_domains(kb_content)

            for domain in domains:
                if domain.name not in all_knowledge:
                    all_knowledge[domain.name] = []

                all_knowledge[domain.name].append({
                    "persona": member.persona_id,
                    "confidence": domain.confidence,
                })

                if domain.confidence >= 70:
                    domain_experts[domain.name].append((member.persona_id, domain.confidence))

        # Generate synthesis document
        synthesis_date = datetime.now().strftime(DATE_FORMAT)
        title = team_id.replace("-", " ").title()

        synthesis_content = f"""# {title} - Team Knowledge Synthesis
**Generated**: {synthesis_date}
**Team Members**: {len(members)}
**Knowledge Domains**: {len(all_knowledge)}

## Team Expertise Matrix

⟪📊: (l,l,c,r) | Domain,Expert(s),Confidence,Coverage⟫
"""

        for domain, experts_list in sorted(all_knowledge.items()):
            highest = max(experts_list, key=lambda x: x["confidence"])
            coverage = len(experts_list)
            coverage_pct = (coverage / len(members)) * 100

            expert_names = ", ".join([
                f"@{e[0]} ({e[1]}%)"
                for e in sorted(domain_experts.get(domain, []), key=lambda x: x[1], reverse=True)
            ])
            if not expert_names:
                expert_names = f"@{highest['persona']} ({highest['confidence']}%)"

            synthesis_content += f"| {domain} | {expert_names} | {highest['confidence']}% | {coverage}/{len(members)} |\n"

        synthesis_content += "\n## Knowledge Distribution\n"

        for domain, experts_list in sorted(all_knowledge.items(), key=lambda x: len(x[1]), reverse=True):
            synthesis_content += f"\n### {domain}\n"
            synthesis_content += f"**Team Coverage**: {len(experts_list)}/{len(members)} members\n\n"

            for expert in sorted(experts_list, key=lambda x: x["confidence"], reverse=True):
                bar = "█" * (expert["confidence"] // 10)
                synthesis_content += f"- @{expert['persona']}: {bar} {expert['confidence']}%\n"

        # Identify gaps
        synthesis_content += "\n## Knowledge Gaps\n\n"

        single_expert_domains = [d for d, e in all_knowledge.items() if len(e) == 1]
        if single_expert_domains:
            synthesis_content += "**Single Point of Knowledge** (bus factor = 1):\n"
            for domain in single_expert_domains:
                expert = all_knowledge[domain][0]
                synthesis_content += f"- {domain} (only @{expert['persona']})\n"
        else:
            synthesis_content += "✅ No single points of knowledge - good distribution!\n"

        synthesis_content += "\n## Team Strengths\n\n"

        strong_domains = [
            (d, e) for d, e in all_knowledge.items()
            if len(e) >= len(members) // 2 and max(x["confidence"] for x in e) >= 80
        ]

        if strong_domains:
            for domain, experts_list in strong_domains[:5]:
                max_conf = max(x["confidence"] for x in experts_list)
                synthesis_content += f"- **{domain}**: {len(experts_list)} members, max confidence {max_conf}%\n"
        else:
            synthesis_content += "Team is building expertise across domains.\n"

        synthesis_content += "\n## Recommendations\n\n"
        synthesis_content += "1. **Knowledge Sharing**: Schedule sessions for single-expert domains\n"
        synthesis_content += "2. **Cross-Training**: Pair members with complementary skills\n"
        synthesis_content += "3. **Documentation**: Capture knowledge in shared resources\n"
        synthesis_content += "4. **Regular Synthesis**: Re-run synthesis monthly to track growth\n"
        synthesis_content += f"\n---\n\n*Generated by npl-persona v2.0 on {synthesis_date}*\n"

        # Write synthesis
        if output:
            output_file = Path(output)
        else:
            shared_dir = Path("./.npl/shared")
            ensure_dir(shared_dir)
            output_file = shared_dir / f"team-knowledge-{team_id}.md"

        result = write_file(output_file, synthesis_content)
        if result.is_err():
            print(f"Error writing synthesis: {result.error}", file=sys.stderr)
            return False

        print(f"\n✅ Team knowledge synthesized: {output_file}")
        print(f"   Domains covered: {len(all_knowledge)}")
        print(f"   Total expertise entries: {sum(len(e) for e in all_knowledge.values())}")

        return True

    def show_matrix(self, team_id: str) -> bool:
        """
        Display team expertise matrix.

        Args:
            team_id: Team identifier

        Returns:
            True on success, False on failure
        """
        location = resolve_team(team_id)
        if not location:
            print(f"Error: Team '{team_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        team_file = base_path / f"{team_id}.team.md"

        result = read_file(team_file)
        if result.is_err():
            print(f"Error reading team file: {result.error}", file=sys.stderr)
            return False

        members = parse_team_members(result.value)

        if not members:
            print(f"Error: No members in team '{team_id}'", file=sys.stderr)
            return False

        title = team_id.replace("-", " ").title()
        print(f"\n# Team Expertise Matrix: {title}\n")

        # Collect domain data
        domain_data: Dict[str, Dict[str, List[str]]] = defaultdict(
            lambda: {"expert": [], "proficient": [], "learning": []}
        )

        for member in members:
            persona_location = resolve_persona(member.persona_id)
            if not persona_location:
                continue

            persona_base, _ = persona_location
            kb_file = persona_base / f"{member.persona_id}.knowledge-base.md"

            if not kb_file.exists():
                continue

            result = read_file(kb_file)
            if result.is_err():
                continue

            domains = parse_knowledge_domains(result.value)

            for domain in domains:
                if domain.confidence >= 80:
                    domain_data[domain.name]["expert"].append(member.persona_id)
                elif domain.confidence >= 50:
                    domain_data[domain.name]["proficient"].append(member.persona_id)
                else:
                    domain_data[domain.name]["learning"].append(member.persona_id)

        if not domain_data:
            print("No domain expertise data found for team members.")
            return True

        # Display matrix
        print(f"{'Domain':<30} {'Expert':<20} {'Proficient':<20} {'Learning':<20}")
        print("-" * 90)

        for domain in sorted(domain_data.keys()):
            data = domain_data[domain]

            experts = ", ".join([f"@{p}" for p in data["expert"]]) or "-"
            proficient = ", ".join([f"@{p}" for p in data["proficient"]]) or "-"
            learning = ", ".join([f"@{p}" for p in data["learning"]]) or "-"

            # Truncate if too long
            experts = experts[:18] + ".." if len(experts) > 20 else experts
            proficient = proficient[:18] + ".." if len(proficient) > 20 else proficient
            learning = learning[:18] + ".." if len(learning) > 20 else learning

            print(f"{domain:<30} {experts:<20} {proficient:<20} {learning:<20}")

        print()
        return True

    def analyze_team(self, team_id: str, period: int = 30) -> bool:
        """
        Analyze team collaboration patterns.

        Args:
            team_id: Team identifier
            period: Analysis period in days

        Returns:
            True on success, False on failure
        """
        location = resolve_team(team_id)
        if not location:
            print(f"Error: Team '{team_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        team_file = base_path / f"{team_id}.team.md"

        result = read_file(team_file)
        if result.is_err():
            print(f"Error reading team file: {result.error}", file=sys.stderr)
            return False

        members = parse_team_members(result.value)

        if not members:
            print(f"Error: No members in team '{team_id}'", file=sys.stderr)
            return False

        member_ids = [m.persona_id for m in members]

        # Create analyzer
        analyzer = TeamAnalyzer(team_id, member_ids, period)

        # Load member journals
        for member_id in member_ids:
            persona_location = resolve_persona(member_id)
            if not persona_location:
                continue

            persona_base, _ = persona_location
            journal_file = persona_base / f"{member_id}.journal.md"

            if not journal_file.exists():
                continue

            result = read_file(journal_file)
            if result.is_ok():
                analyzer.load_member_journal(member_id, result.value)

        # Run analysis
        analyzer.analyze_interactions()

        # Get and format report
        report = analyzer.get_full_report()
        output = format_team_analysis_text(report)
        print(output)

        return True
