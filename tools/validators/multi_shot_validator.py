"""MULTI-SHOT folder validation."""

import re
from pathlib import Path
from typing import Dict

import yaml


class MultiShotValidator:
    """Validates MULTI-SHOT folder contents."""

    def __init__(self, multi_shot_path: Path):
        self.multi_shot_path = Path(multi_shot_path)

    def validate(self) -> Dict:
        """Validate MULTI-SHOT folder."""
        issues = []
        results = {}

        # Validate index.yaml
        index_result = self._validate_index()
        results["index"] = index_result
        if index_result["status"] == "FAIL":
            issues.extend(index_result.get("issues", []))

        # Validate example files
        examples_result = self._validate_examples()
        results["examples"] = examples_result
        if examples_result["status"] == "FAIL":
            issues.extend(examples_result.get("issues", []))

        return {
            "status": "PASS" if not issues else "FAIL",
            "index": results["index"],
            "examples": results["examples"],
            "issues": issues,
        }

    def _validate_index(self) -> Dict:
        """Validate index.yaml."""
        index_file = self.multi_shot_path / "index.yaml"
        issues = []

        if not index_file.exists():
            return {
                "status": "FAIL",
                "example_count": 0,
                "issues": ["index.yaml does not exist"],
            }

        try:
            with open(index_file, "r") as f:
                data = yaml.safe_load(f)

            if not data or "examples" not in data:
                return {
                    "status": "FAIL",
                    "example_count": 0,
                    "issues": ["index.yaml is empty or missing 'examples' list"],
                }

            examples = data.get("examples", [])
            example_count = len(examples)

            if example_count < 3:
                issues.append(f"Expected 3+ examples, found {example_count}")

            # Validate each example entry
            required_fields = ["id", "title", "description", "complexity", "file"]
            for idx, example in enumerate(examples):
                for field in required_fields:
                    if field not in example:
                        issues.append(
                            f"Example {idx} ({example.get('id', 'unknown')}): missing '{field}'"
                        )

                # Check complexity values
                if example.get("complexity") not in [
                    "beginner",
                    "intermediate",
                    "advanced",
                ]:
                    issues.append(
                        f"Example {idx}: invalid complexity '{example.get('complexity')}'"
                    )

                # Check that referenced file exists
                file_name = example.get("file")
                if file_name and not (self.multi_shot_path / file_name).exists():
                    issues.append(
                        f"Example {idx}: referenced file not found: {file_name}"
                    )

            return {
                "status": "PASS" if not issues else "FAIL",
                "example_count": example_count,
                "issues": issues,
            }

        except yaml.YAMLError as e:
            return {
                "status": "FAIL",
                "example_count": 0,
                "issues": [f"YAML parsing error: {str(e)}"],
            }
        except Exception as e:
            return {
                "status": "FAIL",
                "example_count": 0,
                "issues": [f"Error validating index.yaml: {str(e)}"],
            }

    def _validate_examples(self) -> Dict:
        """Validate example .md files."""
        example_files = list(self.multi_shot_path.glob("*.md"))
        # Exclude index.yaml which might be .yaml not .md
        example_files = [f for f in example_files]

        examples = []
        issues = []

        # Expect at least 3 examples
        if len(example_files) < 3:
            issues.append(f"Expected 3+ example files, found {len(example_files)}")

        for example_file in sorted(example_files):
            result = self._validate_example_file(example_file)
            examples.append(result)
            if result["status"] == "FAIL":
                issues.extend(result.get("file_issues", []))

        return {
            "status": "PASS" if not issues else "FAIL",
            "files": examples,
            "issues": issues,
        }

    def _validate_example_file(self, example_file: Path) -> Dict:
        """Validate a single example file."""
        file_issues = []

        with open(example_file, "r") as f:
            content = f.read()
            lines = content.split("\n")

        line_count = len(lines)

        # Determine complexity from filename or content
        file_name = example_file.name
        if "beginner" in file_name:
            expected_min_lines = 400
        elif "intermediate" in file_name:
            expected_min_lines = 600
        elif "advanced" in file_name:
            expected_min_lines = 800
        else:
            expected_min_lines = 400

        if line_count < expected_min_lines:
            file_issues.append(
                f"File too short ({line_count} lines, expected {expected_min_lines}+)"
            )

        # Check for required sections
        required_sections = [
            "## Overview",
            "## Key Takeaways",
            "## Next Steps",
        ]
        for section in required_sections:
            if section not in content:
                file_issues.append(f"Missing section: {section}")

        # Check for YAML chat format (request/response pattern)
        if "request:" not in content.lower():
            file_issues.append("Missing 'request:' in YAML chat format")

        if "response:" not in content.lower():
            file_issues.append("Missing 'response:' in YAML chat format")

        # Check for code block balance
        if content.count("```") % 2 != 0:
            file_issues.append("Unbalanced code blocks")

        return {
            "file": file_name,
            "status": "PASS" if not file_issues else "FAIL",
            "line_count": line_count,
            "file_issues": file_issues,
        }
