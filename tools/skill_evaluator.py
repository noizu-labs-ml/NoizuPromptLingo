#!/usr/bin/env python3
"""
Skill Evaluator - Part 2: Quality Evaluation with Arize Phoenix

Evaluates skill quality using Arize Phoenix and generates Jupyter notebooks.

Usage:
    python tools/skill_evaluator.py skills/market-intelligence/ --notebook
    python tools/skill_evaluator.py skills/ --all --export phoenix_data.json
"""

import argparse
import sys
from pathlib import Path
from typing import Dict
import json

from arize_integration import PhoenixEvaluator, RubricParser


class SkillQualityEvaluator:
    """Evaluates skill quality using EVAL rubric."""

    def __init__(self, skill_path: Path):
        self.skill_path = Path(skill_path)
        self.skill_name = self.skill_path.name
        self.evaluator = PhoenixEvaluator(self.skill_name, str(self.skill_path))

    def evaluate(self) -> Dict:
        """Run quality evaluation."""
        print(f"\n{'='*60}")
        print(f"Evaluating skill quality: {self.skill_name}")
        print(f"{'='*60}\n")

        # Load and parse rubric
        print("📊 Loading EVAL rubric...")
        rubric = self._load_rubric()
        if not rubric:
            return {"status": "FAIL", "error": "Could not load EVAL rubric"}

        # Evaluate fine-tuning dataset
        print("🔍 Evaluating fine-tuning dataset...")
        dataset_scores = self._evaluate_dataset(rubric)

        # Evaluate multi-shot examples
        print("🎯 Evaluating multi-shot examples...")
        example_scores = self._evaluate_examples(rubric)

        # Generate dashboard data
        print("📈 Generating dashboard data...")
        dashboard_data = self.evaluator.generate_dashboard_data()

        return {
            "skill": self.skill_name,
            "status": "COMPLETE",
            "rubric": rubric,
            "dataset_evaluation": dataset_scores,
            "example_evaluation": example_scores,
            "dashboard_data": dashboard_data,
            "evaluator": self.evaluator,
        }

    def _load_rubric(self) -> Dict:
        """Load and parse EVAL/rubric.md."""
        rubric_file = self.skill_path / "EVAL" / "rubric.md"

        if not rubric_file.exists():
            print(f"❌ rubric.md not found at {rubric_file}")
            return None

        with open(rubric_file, "r") as f:
            content = f.read()

        return RubricParser.parse_rubric(content)

    def _evaluate_dataset(self, rubric: Dict) -> Dict:
        """Evaluate fine-tuning dataset quality."""
        try:
            import pandas as pd

            dataset_file = self.skill_path / "FINE-TUNE" / "training_data.parquet"

            if not dataset_file.exists():
                return {"status": "FAIL", "error": "training_data.parquet not found"}

            df = pd.read_parquet(dataset_file)

            # Score sample of examples (first 20)
            sample_size = min(20, len(df))
            sample = df.head(sample_size)

            scores = []
            for idx, row in sample.iterrows():
                # Simulate evaluation against rubric
                score = self._score_example(
                    row["prompt"], row["response"], rubric
                )
                scores.append(score)
                self.evaluator.add_evaluation(
                    f"dataset_example_{idx}",
                    score,
                    f"Sample evaluation of fine-tuning example",
                )

            # Calculate statistics
            mean_score = sum(s.get("total", 0) for s in scores) / len(scores) if scores else 0
            passing = sum(1 for s in scores if s.get("total", 0) >= 2.5)

            return {
                "status": "COMPLETE",
                "sample_size": sample_size,
                "total_dataset_size": len(df),
                "mean_score": mean_score,
                "passing_count": passing,
                "pass_rate": passing / sample_size if sample_size > 0 else 0,
                "sample_scores": scores[:5],  # Return first 5 for display
            }

        except ImportError:
            return {
                "status": "SKIP",
                "reason": "pandas not available",
            }
        except Exception as e:
            return {
                "status": "ERROR",
                "error": str(e),
            }

    def _evaluate_examples(self, rubric: Dict) -> Dict:
        """Evaluate multi-shot examples."""
        multi_shot_path = self.skill_path / "MULTI-SHOT"

        if not multi_shot_path.exists():
            return {"status": "FAIL", "error": "MULTI-SHOT folder not found"}

        example_files = list(multi_shot_path.glob("*.md"))
        example_files = [f for f in example_files if f.name != "index.yaml"]

        example_scores = []
        for example_file in sorted(example_files):
            with open(example_file, "r") as f:
                content = f.read()

            # Extract outputs from YAML chat
            outputs = self._extract_outputs_from_yaml(content)

            if outputs:
                score = self._score_example(
                    example_file.name, outputs, rubric
                )
                example_scores.append({
                    "file": example_file.name,
                    "score": score,
                })
                self.evaluator.add_evaluation(
                    example_file.stem,
                    score,
                    f"Evaluation of multi-shot example: {example_file.name}",
                )

        mean_score = (
            sum(s["score"].get("total", 0) for s in example_scores) / len(example_scores)
            if example_scores
            else 0
        )

        return {
            "status": "COMPLETE",
            "example_count": len(example_scores),
            "mean_score": mean_score,
            "examples": example_scores,
        }

    def _score_example(
        self, prompt: str, response: str, rubric: Dict
    ) -> Dict:
        """Score an example against rubric dimensions (simplified)."""
        dimensions = rubric.get("dimensions", [])
        scores = {}

        for dimension in dimensions:
            # Simple heuristic scoring
            criteria_met = 0

            # Check for key indicators
            if len(response) > 500:
                criteria_met += 1
            if len(prompt) > 50:
                criteria_met += 1
            if "structured" in response.lower() or "|" in response:
                criteria_met += 1
            if any(keyword in response.lower() for keyword in ["example", "explanation", "why"]):
                criteria_met += 1

            # Map to 0-4 scale
            score = min(4, criteria_met)
            scores[dimension.get("name", "dimension")] = score

        # Calculate total weighted score
        total = sum(
            scores.get(d.get("name", ""), 0) * d.get("weight", 0.33)
            for d in dimensions
        )

        scores["total"] = total
        return scores

    def _extract_outputs_from_yaml(self, content: str) -> str:
        """Extract response outputs from YAML chat format."""
        # Simple extraction: get all content after "response:" markers
        outputs = []
        lines = content.split("\n")

        in_response = False
        for line in lines:
            if line.strip().startswith("response:"):
                in_response = True
            elif in_response and line.startswith("```"):
                in_response = False
            elif in_response and line.strip():
                outputs.append(line)

        return "\n".join(outputs)

    def generate_notebook(self, output_path: str = None) -> str:
        """Generate Jupyter notebook."""
        if not output_path:
            output_path = f"notebooks/{self.skill_name}_evaluation.ipynb"

        notebook = self._create_notebook()

        output_file = Path(output_path)
        output_file.parent.mkdir(parents=True, exist_ok=True)

        with open(output_file, "w") as f:
            json.dump(notebook, f, indent=2)

        print(f"✅ Notebook generated: {output_file}")
        return str(output_file)

    def _create_notebook(self) -> Dict:
        """Create Jupyter notebook structure."""
        cells = [
            self._create_markdown_cell("# Skill Evaluation: " + self.skill_name),
            self._create_markdown_cell("Interactive analysis notebook for skill quality evaluation."),
            self._create_code_cell(self._get_setup_code()),
            self._create_markdown_cell("## 1. Load Skill and Rubric"),
            self._create_code_cell(self._get_load_code()),
            self._create_markdown_cell("## 2. Visualize Rubric Dimensions"),
            self._create_code_cell(self._get_visualize_rubric_code()),
            self._create_markdown_cell("## 3. Dataset Quality Analysis"),
            self._create_code_cell(self._get_dataset_analysis_code()),
            self._create_markdown_cell("## 4. Multi-Shot Example Evaluation"),
            self._create_code_cell(self._get_example_evaluation_code()),
            self._create_markdown_cell("## 5. Dimension Breakdown"),
            self._create_code_cell(self._get_dimension_breakdown_code()),
            self._create_markdown_cell("## 6. Quality Improvement Recommendations"),
            self._create_code_cell(self._get_recommendations_code()),
        ]

        return {
            "cells": cells,
            "metadata": {
                "kernelspec": {
                    "display_name": "Python 3",
                    "language": "python",
                    "name": "python3",
                },
                "language_info": {
                    "name": "python",
                    "version": "3.8.0",
                },
            },
            "nbformat": 4,
            "nbformat_minor": 4,
        }

    def _create_markdown_cell(self, text: str) -> Dict:
        """Create markdown cell."""
        return {
            "cell_type": "markdown",
            "metadata": {},
            "source": [text],
        }

    def _create_code_cell(self, code: str) -> Dict:
        """Create code cell."""
        return {
            "cell_type": "code",
            "execution_count": None,
            "metadata": {},
            "outputs": [],
            "source": code.split("\n"),
        }

    def _get_setup_code(self) -> str:
        return """import pandas as pd
import json
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns

# Set style
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (12, 6)"""

    def _get_load_code(self) -> str:
        return f"""skill_path = Path('{self.skill_path}')
skill_name = '{self.skill_name}'

# Load rubric
with open(skill_path / 'EVAL' / 'rubric.md', 'r') as f:
    rubric_content = f.read()

# Load training data
training_data = pd.read_parquet(skill_path / 'FINE-TUNE' / 'training_data.parquet')

print(f"✅ Loaded skill: {skill_name}")
print(f"   Training dataset size: {len(training_data)} examples")
print(f"   Average response length: {training_data['response'].str.len().mean():.0f} chars")"""

    def _get_visualize_rubric_code(self) -> str:
        return """# Parse rubric dimensions
dimensions_text = [line for line in rubric_content.split('\\n') if line.startswith('## Dimension')]
print(f"Found {len(dimensions_text)} dimensions in rubric")
print("\\nRubric structure:")
for line in rubric_content.split('\\n')[:50]:
    print(line) if line else None"""

    def _get_dataset_analysis_code(self) -> str:
        return """# Analyze dataset quality
print("Dataset Statistics:")
print(f"  Total examples: {len(training_data)}")
print(f"  Avg prompt length: {training_data['prompt'].str.len().mean():.0f} chars")
print(f"  Avg response length: {training_data['response'].str.len().mean():.0f} chars")
print(f"  Min response: {training_data['response'].str.len().min()} chars")
print(f"  Max response: {training_data['response'].str.len().max()} chars")

# Show sample
print("\\nSample examples:")
training_data[['prompt', 'response']].head(3)"""

    def _get_example_evaluation_code(self) -> str:
        return """# Load and analyze multi-shot examples
multi_shot_path = skill_path / 'MULTI-SHOT'
example_files = list(multi_shot_path.glob('*.md'))
example_files = [f for f in example_files if f.name != 'index.yaml']

print(f"Found {len(example_files)} multi-shot examples:")
for f in sorted(example_files):
    size = f.stat().st_size
    print(f"  - {f.name}: {size:,} bytes")"""

    def _get_dimension_breakdown_code(self) -> str:
        return """# Dimension analysis
print("Rubric dimensions and weights:")
lines = rubric_content.split('\\n')
for line in lines:
    if 'Weight:' in line or 'Dimension' in line:
        print(line)"""

    def _get_recommendations_code(self) -> str:
        return """# Quality improvement recommendations
print("Recommendations for improving skill quality:")
print("\\n1. Dataset Quality:")
print(f"   - Current size: {len(training_data)} (target: 100-150)")
print(f"   - Response length: {training_data['response'].str.len().mean():.0f} chars avg")
print(f"   - Recommendation: Ensure all examples score 3+/4.0 on EVAL rubric")
print("\\n2. Example Diversity:")
print(f"   - Multi-shot examples: {len(example_files)}")
print(f"   - Recommendation: Cover all complexity levels and use cases")"""


def main():
    parser = argparse.ArgumentParser(
        description="Evaluate skill quality using Arize Phoenix"
    )
    parser.add_argument(
        "path",
        help="Path to skill directory (e.g., skills/market-intelligence/)",
    )
    parser.add_argument(
        "--notebook",
        action="store_true",
        help="Generate Jupyter notebook",
    )
    parser.add_argument(
        "-o", "--output",
        help="Output path for notebook",
    )
    parser.add_argument(
        "--export",
        help="Export Phoenix metrics to JSON file",
    )

    args = parser.parse_args()
    skill_path = Path(args.path)

    if not skill_path.exists():
        print(f"Error: Path not found: {skill_path}")
        sys.exit(1)

    evaluator = SkillQualityEvaluator(skill_path)
    result = evaluator.evaluate()

    if result.get("status") == "FAIL":
        print(f"❌ Evaluation failed: {result.get('error')}")
        sys.exit(1)

    # Generate notebook if requested
    if args.notebook:
        output_path = args.output or f"notebooks/{evaluator.skill_name}_evaluation.ipynb"
        evaluator.generate_notebook(output_path)

    # Export Phoenix data if requested
    if args.export:
        evaluator.evaluator.export_json(args.export)
        print(f"✅ Phoenix metrics exported to {args.export}")

    print("\n✅ Evaluation complete!")


if __name__ == "__main__":
    main()
