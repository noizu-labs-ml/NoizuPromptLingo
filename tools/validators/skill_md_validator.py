"""SKILL.md file validation."""

from pathlib import Path
from typing import Dict


class SkillMdValidator:
    """Validates SKILL.md file structure and content."""

    REQUIRED_SECTIONS = [
        "# ",  # Title
        "## Overview",
        "## When to Use",
        "## Common Mistakes",
        "## Next Steps",
        "## Related Skills",
        "## Version History",
    ]

    def __init__(self, skill_md_path: Path):
        self.skill_md_path = Path(skill_md_path)

    def validate(self) -> Dict:
        """Validate SKILL.md file."""
        issues = []
        items = []

        if not self.skill_md_path.exists():
            return {
                "status": "FAIL",
                "line_count": 0,
                "issues": ["SKILL.md does not exist"],
            }

        # Read file
        with open(self.skill_md_path, "r") as f:
            content = f.read()
            lines = content.split("\n")

        line_count = len(lines)

        # Check line count
        if line_count >= 1500:
            items.append(
                {"check": f"Minimum line count (1,500+)", "status": "PASS", "value": line_count}
            )
        else:
            items.append(
                {"check": f"Minimum line count (1,500+)", "status": "FAIL", "value": line_count}
            )
            issues.append(f"File is too short ({line_count} lines, expected 1,500+)")

        # Check required sections
        for section in self.REQUIRED_SECTIONS:
            if section in content:
                section_name = section.strip("# ") or "Title"
                items.append(
                    {"check": f'Section "{section_name}" exists', "status": "PASS"}
                )
            else:
                section_name = section.strip("# ") or "Title"
                items.append(
                    {"check": f'Section "{section_name}" exists', "status": "FAIL"}
                )
                issues.append(f'Missing required section: "{section}"')

        # Check for Evaluation & Completion section linking to EVAL
        if "Evaluation & Completion" in content and "EVAL/" in content:
            items.append(
                {
                    "check": "Evaluation & Completion section with EVAL/ link",
                    "status": "PASS",
                }
            )
        else:
            items.append(
                {
                    "check": "Evaluation & Completion section with EVAL/ link",
                    "status": "FAIL",
                }
            )
            issues.append(
                "Missing 'Evaluation & Completion' section linking to EVAL/ folder"
            )

        # Check for broken markdown
        markdown_issues = self._check_markdown_syntax(content)
        if not markdown_issues:
            items.append({"check": "Markdown syntax valid", "status": "PASS"})
        else:
            items.append({"check": "Markdown syntax valid", "status": "FAIL"})
            issues.extend(markdown_issues)

        return {
            "status": "PASS" if not issues else "FAIL",
            "line_count": line_count,
            "items": items,
            "issues": issues,
        }

    def _check_markdown_syntax(self, content: str) -> list:
        """Check for basic markdown syntax issues."""
        issues = []

        # Check balanced code blocks
        code_block_count = content.count("```")
        if code_block_count % 2 != 0:
            issues.append("Unbalanced code blocks (``` count not even)")

        # Check balanced links
        open_brackets = content.count("[")
        close_brackets = content.count("]")
        if open_brackets != close_brackets:
            issues.append("Unbalanced square brackets in links")

        return issues
