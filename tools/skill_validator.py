#!/usr/bin/env python3
"""
Skill Validator Tool - Part 1: Structure Validation

Validates that skill directories follow SKILL-GUIDELINE.md requirements.

Usage:
    python tools/skill_validator.py skills/market-intelligence/
    python tools/skill_validator.py skills/ --all
    python tools/skill_validator.py skills/market-intelligence/ --report html
"""

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple

from validators.structure_validator import StructureValidator
from validators.skill_md_validator import SkillMdValidator
from validators.prompts_validator import PromptsValidator
from validators.eval_validator import EvalValidator
from validators.fine_tune_validator import FineTuneValidator
from validators.multi_shot_validator import MultiShotValidator


class SkillValidator:
    """Main validator orchestrator."""

    def __init__(self, skill_path: Path, verbose: bool = False):
        self.skill_path = Path(skill_path)
        self.verbose = verbose
        self.skill_name = self.skill_path.name
        self.results = {}

    def validate_all(self) -> Dict:
        """Run all validators."""
        print(f"\n{'='*60}")
        print(f"Validating skill: {self.skill_name}")
        print(f"Path: {self.skill_path}")
        print(f"{'='*60}\n")

        # Part 1: Directory structure
        print("1️⃣  Checking directory structure...")
        struct_validator = StructureValidator(self.skill_path)
        self.results["directory_structure"] = struct_validator.validate()

        # Part 2: SKILL.md
        print("2️⃣  Validating SKILL.md...")
        skill_validator = SkillMdValidator(self.skill_path / "SKILL.md")
        self.results["skill_md"] = skill_validator.validate()

        # Part 3: Prompt files
        print("3️⃣  Validating prompt files...")
        prompts_validator = PromptsValidator(self.skill_path)
        self.results["prompts"] = prompts_validator.validate()

        # Part 4: EVAL folder
        print("4️⃣  Validating EVAL/ folder...")
        eval_validator = EvalValidator(self.skill_path / "EVAL")
        self.results["eval_folder"] = eval_validator.validate()

        # Part 5: FINE-TUNE folder
        print("5️⃣  Validating FINE-TUNE/ folder...")
        fine_tune_validator = FineTuneValidator(self.skill_path / "FINE-TUNE")
        self.results["fine_tune_folder"] = fine_tune_validator.validate()

        # Part 6: MULTI-SHOT folder
        print("6️⃣  Validating MULTI-SHOT/ folder...")
        multi_shot_validator = MultiShotValidator(self.skill_path / "MULTI-SHOT")
        self.results["multi_shot_folder"] = multi_shot_validator.validate()

        return self.generate_report()

    def generate_report(self) -> Dict:
        """Generate comprehensive validation report."""
        # Calculate overall status
        all_pass = all(
            result.get("status") == "PASS"
            for result in self.results.values()
            if isinstance(result, dict) and "status" in result
        )

        report = {
            "skill": self.skill_name,
            "path": str(self.skill_path),
            "status": "PASS" if all_pass else "FAIL",
            "timestamp": datetime.now().isoformat(),
            "checks": self.results,
        }

        # Count issues
        issue_count = 0
        for section, result in self.results.items():
            if isinstance(result, dict):
                issues = result.get("issues", [])
                if isinstance(issues, list):
                    issue_count += len(issues)

        report["summary"] = self._generate_summary(all_pass, issue_count)

        return report

    def _generate_summary(self, all_pass: bool, issue_count: int) -> str:
        if all_pass:
            return "✅ Skill structure is valid and complete"
        else:
            return f"❌ Skill validation failed with {issue_count} issue(s). See details below."

    def print_report(self, report: Dict, format: str = "text"):
        """Print validation report."""
        if format == "json":
            print(json.dumps(report, indent=2))
        elif format == "html":
            self._print_html_report(report)
        else:
            self._print_text_report(report)

    def _print_text_report(self, report: Dict):
        """Print human-readable report."""
        print(f"\n{'='*60}")
        print(f"VALIDATION REPORT: {report['skill']}")
        print(f"{'='*60}\n")

        status = report["status"]
        symbol = "✅" if status == "PASS" else "❌"
        print(f"{symbol} Status: {status}")
        print(f"📍 Path: {report['path']}")
        print(f"⏰ Timestamp: {report['timestamp']}")
        print(f"\n{report['summary']}\n")

        # Print checks
        for section_name, section_result in report["checks"].items():
            if not isinstance(section_result, dict):
                continue

            status = section_result.get("status", "UNKNOWN")
            symbol = "✅" if status == "PASS" else "❌"
            print(f"\n{symbol} {self._section_title(section_name)}")

            # Print items if available
            if "items" in section_result:
                for item in section_result["items"]:
                    item_status = "✅" if item["status"] == "PASS" else "❌"
                    print(f"  {item_status} {item['check']}")

            # Print specific details
            for key, value in section_result.items():
                if key not in ["status", "items", "issues"]:
                    if isinstance(value, dict):
                        print(f"  {key}:")
                        for k, v in value.items():
                            print(f"    - {k}: {v}")

            # Print issues
            issues = section_result.get("issues", [])
            if issues:
                print(f"  Issues:")
                for issue in issues:
                    print(f"    ❌ {issue}")

        print(f"\n{'='*60}\n")

    def _section_title(self, section: str) -> str:
        """Convert section name to title."""
        return section.replace("_", " ").title()

    def _print_html_report(self, report: Dict):
        """Generate HTML report."""
        html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Skill Validation Report - {report['skill']}</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        h1 {{ color: #333; }}
        .pass {{ color: green; }}
        .fail {{ color: red; }}
        .summary {{ padding: 10px; margin: 10px 0; border-left: 4px solid #ddd; }}
        .section {{ margin: 20px 0; padding: 10px; border: 1px solid #ddd; }}
        table {{ width: 100%; border-collapse: collapse; margin: 10px 0; }}
        th, td {{ padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }}
        th {{ background-color: #f5f5f5; }}
    </style>
</head>
<body>
    <h1>Skill Validation Report</h1>
    <p><strong>Skill:</strong> {report['skill']}</p>
    <p><strong>Path:</strong> {report['path']}</p>
    <p><strong>Status:</strong> <span class="{'pass' if report['status'] == 'PASS' else 'fail'}">{report['status']}</span></p>
    <p><strong>Timestamp:</strong> {report['timestamp']}</p>

    <div class="summary">
        {report['summary']}
    </div>

    <h2>Validation Checks</h2>
    {self._generate_html_checks(report['checks'])}
</body>
</html>
"""
        print(html)

    def _generate_html_checks(self, checks: Dict) -> str:
        """Generate HTML for checks."""
        html = ""
        for section_name, section_result in checks.items():
            if not isinstance(section_result, dict):
                continue
            status = section_result.get("status", "UNKNOWN")
            status_class = "pass" if status == "PASS" else "fail"
            html += f'<div class="section"><h3 class="{status_class}">{section_name.replace("_", " ").title()}</h3>'

            if "items" in section_result:
                html += "<table><tr><th>Check</th><th>Status</th></tr>"
                for item in section_result["items"]:
                    item_class = "pass" if item["status"] == "PASS" else "fail"
                    html += f'<tr><td>{item["check"]}</td><td class="{item_class}">{item["status"]}</td></tr>'
                html += "</table>"

            issues = section_result.get("issues", [])
            if issues:
                html += "<h4>Issues:</h4><ul>"
                for issue in issues:
                    html += f"<li>{issue}</li>"
                html += "</ul>"

            html += "</div>"
        return html


def main():
    parser = argparse.ArgumentParser(
        description="Validate skill structure against SKILL-GUIDELINE.md"
    )
    parser.add_argument(
        "path",
        help="Path to skill directory (e.g., skills/market-intelligence/) or skills/ for all",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Validate all skills in directory",
    )
    parser.add_argument(
        "--report",
        choices=["text", "json", "html"],
        default="text",
        help="Report format (default: text)",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose output",
    )
    parser.add_argument(
        "-o", "--output",
        help="Output file (if not specified, prints to stdout)",
    )

    args = parser.parse_args()
    path = Path(args.path)

    if not path.exists():
        print(f"Error: Path not found: {path}")
        sys.exit(1)

    if args.all and path.is_dir():
        # Validate all skills
        skills = [p for p in path.iterdir() if p.is_dir()]
        all_reports = []

        for skill_path in sorted(skills):
            validator = SkillValidator(skill_path, args.verbose)
            report = validator.validate_all()
            all_reports.append(report)

        # Generate summary report
        summary = {
            "total_skills": len(all_reports),
            "passed": sum(1 for r in all_reports if r["status"] == "PASS"),
            "failed": sum(1 for r in all_reports if r["status"] == "FAIL"),
            "skills": all_reports,
            "timestamp": datetime.now().isoformat(),
        }

        output = json.dumps(summary, indent=2)
    else:
        # Validate single skill
        validator = SkillValidator(path, args.verbose)
        report = validator.validate_all()

        if args.report == "json":
            output = json.dumps(report, indent=2)
        elif args.report == "html":
            # For HTML, we need to handle differently
            validator.print_report(report, args.report)
            return
        else:
            validator.print_report(report, args.report)
            return

    if args.output:
        with open(args.output, "w") as f:
            f.write(output)
        print(f"Report written to: {args.output}")
    else:
        print(output)


if __name__ == "__main__":
    main()
