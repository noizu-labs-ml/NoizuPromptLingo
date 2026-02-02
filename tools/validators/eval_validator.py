"""EVAL folder validation."""

import re
from pathlib import Path
from typing import Dict


class EvalValidator:
    """Validates EVAL folder contents."""

    def __init__(self, eval_path: Path):
        self.eval_path = Path(eval_path)

    def validate(self) -> Dict:
        """Validate EVAL folder."""
        issues = []
        results = {}

        # Validate rubric.md
        rubric_result = self._validate_rubric()
        results["rubric"] = rubric_result
        if rubric_result["status"] == "FAIL":
            issues.extend(rubric_result.get("issues", []))

        # Validate examples.md
        examples_result = self._validate_examples()
        results["examples"] = examples_result
        if examples_result["status"] == "FAIL":
            issues.extend(examples_result.get("issues", []))

        # Validate checklist.md
        checklist_result = self._validate_checklist()
        results["checklist"] = checklist_result
        if checklist_result["status"] == "FAIL":
            issues.extend(checklist_result.get("issues", []))

        return {
            "status": "PASS" if not issues else "FAIL",
            "rubric": results["rubric"],
            "examples": results["examples"],
            "checklist": results["checklist"],
            "issues": issues,
        }

    def _validate_rubric(self) -> Dict:
        """Validate rubric.md."""
        rubric_file = self.eval_path / "rubric.md"
        issues = []

        if not rubric_file.exists():
            return {
                "status": "FAIL",
                "issues": ["rubric.md does not exist"],
            }

        with open(rubric_file, "r") as f:
            content = f.read()

        # Check for dimensions
        dimension_pattern = r"^## Dimension|^## \[|^### \w+"
        dimensions = re.findall(dimension_pattern, content, re.MULTILINE)
        dimension_count = len(dimensions)

        if dimension_count < 3:
            issues.append(f"Expected 3+ dimensions, found {dimension_count}")
        if dimension_count > 5:
            issues.append(f"Too many dimensions ({dimension_count}, recommended 3-5)")

        # Check for scoring scale (0-4)
        if "| **4**" not in content or "| **0**" not in content:
            issues.append("Missing 0-4 scoring scale in rubric")

        # Check for weights/threshold
        if "Weight:" not in content and "weight:" not in content:
            issues.append("Missing dimension weights")

        if "threshold" not in content.lower() and "pass" not in content.lower():
            issues.append("Missing pass threshold definition")

        return {
            "status": "PASS" if not issues else "FAIL",
            "dimensions": dimension_count,
            "issues": issues,
        }

    def _validate_examples(self) -> Dict:
        """Validate examples.md."""
        examples_file = self.eval_path / "examples.md"
        issues = []

        if not examples_file.exists():
            return {
                "status": "FAIL",
                "issues": ["examples.md does not exist"],
            }

        with open(examples_file, "r") as f:
            content = f.read()

        # Check for good/fair/poor examples
        if "✅" not in content and "Excellent" not in content and "4/4" not in content:
            issues.append("Missing excellent/good examples")

        if "⚠️" not in content and "Fair" not in content and "2/4" not in content:
            issues.append("Missing fair examples")

        if "❌" not in content and "Poor" not in content and "0/4" not in content:
            issues.append("Missing poor examples")

        # Count example sections
        example_count = content.count("##")
        if example_count < 2:
            issues.append(
                f"Expected 2+ example types documented, found {example_count}"
            )

        return {
            "status": "PASS" if not issues else "FAIL",
            "example_sections": example_count,
            "issues": issues,
        }

    def _validate_checklist(self) -> Dict:
        """Validate checklist.md."""
        checklist_file = self.eval_path / "checklist.md"
        issues = []

        if not checklist_file.exists():
            return {
                "status": "FAIL",
                "issues": ["checklist.md does not exist"],
            }

        with open(checklist_file, "r") as f:
            content = f.read()

        # Count checkbox items
        checkbox_count = content.count("- [")

        if checkbox_count < 10:
            issues.append(
                f"Expected 10+ checklist items, found {checkbox_count}"
            )

        # Check for categories
        category_count = content.count("##")
        if category_count < 3:
            issues.append(
                f"Expected 3+ checklist categories, found {category_count}"
            )

        return {
            "status": "PASS" if not issues else "FAIL",
            "checklist_items": checkbox_count,
            "categories": category_count,
            "issues": issues,
        }
