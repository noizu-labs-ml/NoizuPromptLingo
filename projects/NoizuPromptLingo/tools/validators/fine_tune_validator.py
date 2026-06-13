"""FINE-TUNE folder validation."""

from pathlib import Path
from typing import Dict
import json


class FineTuneValidator:
    """Validates FINE-TUNE folder contents."""

    def __init__(self, fine_tune_path: Path):
        self.fine_tune_path = Path(fine_tune_path)

    def validate(self) -> Dict:
        """Validate FINE-TUNE folder."""
        issues = []
        results = {}

        # Validate README.md
        readme_result = self._validate_readme()
        results["readme"] = readme_result
        if readme_result["status"] == "FAIL":
            issues.extend(readme_result.get("issues", []))

        # Validate training_data.parquet
        dataset_result = self._validate_dataset()
        results["dataset"] = dataset_result
        if dataset_result["status"] == "FAIL":
            issues.extend(dataset_result.get("issues", []))

        return {
            "status": "PASS" if not issues else "FAIL",
            "readme": results["readme"],
            "dataset": results["dataset"],
            "issues": issues,
        }

    def _validate_readme(self) -> Dict:
        """Validate README.md."""
        readme_file = self.fine_tune_path / "README.md"
        issues = []

        if not readme_file.exists():
            return {
                "status": "FAIL",
                "issues": ["README.md does not exist"],
            }

        with open(readme_file, "r") as f:
            content = f.read()
            lines = content.split("\n")

        line_count = len(lines)

        # Check length
        if line_count < 1000:
            issues.append(f"README.md too short ({line_count} lines, expected 1,000+)")

        # Check required sections
        required_sections = [
            "Fine-Tuning Goals",
            "Dataset Overview",
            "Recommended Approaches",
            "Success Metrics",
        ]
        for section in required_sections:
            if section not in content:
                issues.append(f"Missing section: {section}")

        # Check for goals
        if "Goal" not in content:
            issues.append("No fine-tuning goals documented")

        return {
            "status": "PASS" if not issues else "FAIL",
            "line_count": line_count,
            "issues": issues,
        }

    def _validate_dataset(self) -> Dict:
        """Validate training_data.parquet."""
        parquet_file = self.fine_tune_path / "training_data.parquet"
        issues = []

        if not parquet_file.exists():
            return {
                "status": "FAIL",
                "row_count": 0,
                "issues": ["training_data.parquet does not exist"],
            }

        try:
            import pandas as pd

            df = pd.read_parquet(parquet_file)

            # Check row count
            row_count = len(df)
            if row_count < 100:
                issues.append(
                    f"Dataset too small ({row_count} rows, minimum 100)"
                )
            if row_count > 150:
                issues.append(
                    f"Dataset large but acceptable ({row_count} rows)"
                )

            # Check required columns
            required_cols = ["prompt", "response"]
            for col in required_cols:
                if col not in df.columns:
                    issues.append(f"Missing required column: {col}")

            # Check for empty rows
            empty_prompts = df["prompt"].isna().sum()
            empty_responses = df["response"].isna().sum()

            if empty_prompts > 0:
                issues.append(f"Found {empty_prompts} empty prompts")
            if empty_responses > 0:
                issues.append(f"Found {empty_responses} empty responses")

            # Estimate token count (rough: ~4 chars per token)
            avg_response_length = df["response"].str.len().mean()
            avg_response_tokens = int(avg_response_length / 4)

            if avg_response_tokens < 250:
                issues.append(
                    f"Responses too short ({avg_response_tokens} avg tokens, expected 250+)"
                )

            return {
                "status": "PASS" if not issues else "FAIL",
                "row_count": row_count,
                "avg_response_tokens": avg_response_tokens,
                "columns": list(df.columns),
                "issues": issues,
            }

        except ImportError:
            return {
                "status": "FAIL",
                "row_count": 0,
                "issues": ["pandas not available for parquet validation"],
            }
        except Exception as e:
            return {
                "status": "FAIL",
                "row_count": 0,
                "issues": [f"Error reading parquet file: {str(e)}"],
            }
