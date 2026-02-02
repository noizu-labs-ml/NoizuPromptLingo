"""Directory structure validation."""

from pathlib import Path
from typing import Dict, List


class StructureValidator:
    """Validates skill directory structure."""

    REQUIRED_FILES = ["SKILL.md"]
    REQUIRED_FOLDERS = ["EVAL", "FINE-TUNE", "MULTI-SHOT"]

    def __init__(self, skill_path: Path):
        self.skill_path = Path(skill_path)

    def validate(self) -> Dict:
        """Validate directory structure."""
        items = []
        issues = []

        # Check required files
        for required_file in self.REQUIRED_FILES:
            file_path = self.skill_path / required_file
            if file_path.exists():
                items.append({"check": f"{required_file} exists", "status": "PASS"})
            else:
                items.append({"check": f"{required_file} exists", "status": "FAIL"})
                issues.append(f"Missing required file: {required_file}")

        # Check required folders
        for required_folder in self.REQUIRED_FOLDERS:
            folder_path = self.skill_path / required_folder
            if folder_path.is_dir():
                items.append(
                    {"check": f"{required_folder}/ folder exists", "status": "PASS"}
                )
            else:
                items.append(
                    {"check": f"{required_folder}/ folder exists", "status": "FAIL"}
                )
                issues.append(f"Missing required folder: {required_folder}/")

        # Check for prompt files
        prompt_files = list(self.skill_path.glob("*.prompt.md"))
        if len(prompt_files) >= 2:
            items.append(
                {"check": f"Prompt files exist (found {len(prompt_files)})", "status": "PASS"}
            )
        else:
            items.append(
                {"check": f"Prompt files exist (found {len(prompt_files)})", "status": "FAIL"}
            )
            issues.append(f"Expected 2+ prompt files, found {len(prompt_files)}")

        # Check specific files in EVAL
        eval_path = self.skill_path / "EVAL"
        if eval_path.is_dir():
            for eval_file in ["rubric.md", "examples.md", "checklist.md"]:
                file_path = eval_path / eval_file
                if file_path.exists():
                    items.append(
                        {
                            "check": f"EVAL/{eval_file} exists",
                            "status": "PASS",
                        }
                    )
                else:
                    items.append(
                        {
                            "check": f"EVAL/{eval_file} exists",
                            "status": "FAIL",
                        }
                    )
                    issues.append(f"Missing required file: EVAL/{eval_file}")

        # Check specific files in FINE-TUNE
        fine_tune_path = self.skill_path / "FINE-TUNE"
        if fine_tune_path.is_dir():
            for ft_file in ["README.md", "training_data.parquet"]:
                file_path = fine_tune_path / ft_file
                if file_path.exists():
                    items.append(
                        {
                            "check": f"FINE-TUNE/{ft_file} exists",
                            "status": "PASS",
                        }
                    )
                else:
                    items.append(
                        {
                            "check": f"FINE-TUNE/{ft_file} exists",
                            "status": "FAIL",
                        }
                    )
                    issues.append(f"Missing required file: FINE-TUNE/{ft_file}")

        # Check specific files in MULTI-SHOT
        multi_shot_path = self.skill_path / "MULTI-SHOT"
        if multi_shot_path.is_dir():
            index_file = multi_shot_path / "index.yaml"
            if index_file.exists():
                items.append(
                    {
                        "check": "MULTI-SHOT/index.yaml exists",
                        "status": "PASS",
                    }
                )
            else:
                items.append(
                    {
                        "check": "MULTI-SHOT/index.yaml exists",
                        "status": "FAIL",
                    }
                )
                issues.append("Missing required file: MULTI-SHOT/index.yaml")

            # Check for example files
            example_files = list(multi_shot_path.glob("*.md"))
            example_files = [
                f for f in example_files if f.name != "index.yaml"
            ]  # Exclude index.yaml
            if len(example_files) >= 3:
                items.append(
                    {
                        "check": f"Multi-shot example files exist (found {len(example_files)})",
                        "status": "PASS",
                    }
                )
            else:
                items.append(
                    {
                        "check": f"Multi-shot example files exist (found {len(example_files)})",
                        "status": "FAIL",
                    }
                )
                issues.append(
                    f"Expected 3+ multi-shot examples, found {len(example_files)}"
                )

        return {
            "status": "PASS" if not issues else "FAIL",
            "items": items,
            "issues": issues,
        }
