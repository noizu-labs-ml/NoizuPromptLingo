"""Prompt file validation."""

from pathlib import Path
from typing import Dict


class PromptsValidator:
    """Validates .prompt.md files."""

    REQUIRED_SECTIONS = [
        "## PROMPT:",
        "### What to Provide",
        "### Expected Output",
        "### Tips for Best Results",
        "### Related Prompts",
    ]

    def __init__(self, skill_path: Path):
        self.skill_path = Path(skill_path)

    def validate(self) -> Dict:
        """Validate all prompt files."""
        prompt_files = list(self.skill_path.glob("*.prompt.md"))
        files = []
        issues = []

        if len(prompt_files) < 2:
            issues.append(f"Expected 2+ prompt files, found {len(prompt_files)}")

        for prompt_file in sorted(prompt_files):
            file_result = self._validate_prompt_file(prompt_file)
            files.append(file_result)

            if file_result["status"] == "FAIL":
                issues.extend(file_result.get("issues", []))

        return {
            "status": "PASS" if not issues else "FAIL",
            "file_count": len(prompt_files),
            "files": files,
            "issues": issues,
        }

    def _validate_prompt_file(self, prompt_file: Path) -> Dict:
        """Validate a single prompt file."""
        with open(prompt_file, "r") as f:
            content = f.read()
            lines = content.split("\n")

        line_count = len(lines)
        file_issues = []

        # Check line count
        if line_count < 300:
            file_issues.append(f"File too short ({line_count} lines, expected 300+)")

        # Check required sections
        for section in self.REQUIRED_SECTIONS:
            if section not in content:
                file_issues.append(f"Missing section: {section}")

        # Check for code block balance
        if content.count("```") % 2 != 0:
            file_issues.append("Unbalanced code blocks")

        return {
            "file": prompt_file.name,
            "status": "PASS" if not file_issues else "FAIL",
            "line_count": line_count,
            "issues": file_issues,
        }
