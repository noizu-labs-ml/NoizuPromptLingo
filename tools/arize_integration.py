"""Arize Phoenix integration for skill evaluation."""

from datetime import datetime
from typing import Dict, List, Optional
import json


class PhoenixEvaluator:
    """Wrapper for Arize Phoenix evaluations."""

    def __init__(self, skill_name: str, skill_path: str):
        self.skill_name = skill_name
        self.skill_path = skill_path
        self.evaluations = []
        self.metrics = {}

    def add_evaluation(
        self,
        example_id: str,
        metrics: Dict[str, float],
        reasoning: str = "",
        status: str = "PASS",
    ) -> None:
        """Add an evaluation result."""
        self.evaluations.append(
            {
                "example_id": example_id,
                "metrics": metrics,
                "reasoning": reasoning,
                "status": status,
                "timestamp": datetime.now().isoformat(),
            }
        )

    def aggregate_metrics(self) -> Dict:
        """Aggregate metrics across all evaluations."""
        if not self.evaluations:
            return {}

        # Collect all metric names
        all_metrics = {}
        for eval_result in self.evaluations:
            for metric_name, value in eval_result["metrics"].items():
                if metric_name not in all_metrics:
                    all_metrics[metric_name] = []
                if isinstance(value, (int, float)):
                    all_metrics[metric_name].append(value)

        # Calculate statistics
        aggregated = {}
        for metric_name, values in all_metrics.items():
            if values:
                aggregated[metric_name] = {
                    "mean": sum(values) / len(values),
                    "min": min(values),
                    "max": max(values),
                    "count": len(values),
                }

        return aggregated

    def generate_phoenix_metrics_config(self, rubric: Dict) -> Dict:
        """Generate Phoenix metrics configuration from EVAL rubric."""
        dimensions = rubric.get("dimensions", [])
        metrics_config = {
            "metrics": [],
            "timestamp": datetime.now().isoformat(),
        }

        for dimension in dimensions:
            metric = {
                "name": dimension.get("name", "unknown"),
                "type": "numeric",
                "scale": {"min": 0, "max": 4},
                "weight": dimension.get("weight", 1 / len(dimensions)),
                "description": dimension.get("description", ""),
                "criteria": dimension.get("criteria", {}),
            }
            metrics_config["metrics"].append(metric)

        return metrics_config

    def export_for_phoenix(self) -> Dict:
        """Export evaluations in Phoenix-compatible format."""
        return {
            "skill": self.skill_name,
            "skill_path": self.skill_path,
            "evaluation_count": len(self.evaluations),
            "metrics_summary": self.aggregate_metrics(),
            "evaluations": self.evaluations,
            "exported_at": datetime.now().isoformat(),
        }

    def export_json(self, filepath: str) -> None:
        """Export results to JSON."""
        with open(filepath, "w") as f:
            json.dump(self.export_for_phoenix(), f, indent=2)

    def generate_dashboard_data(self) -> Dict:
        """Generate data for Arize Phoenix dashboard."""
        aggregated = self.aggregate_metrics()

        dashboard_data = {
            "skill": self.skill_name,
            "overall_score": 0,
            "dimensions": {},
            "quality_distribution": {},
            "timestamp": datetime.now().isoformat(),
        }

        # Calculate overall score
        if aggregated:
            all_means = [m.get("mean", 0) for m in aggregated.values()]
            dashboard_data["overall_score"] = sum(all_means) / len(all_means) if all_means else 0

        # Build dimension breakdown
        for metric_name, stats in aggregated.items():
            dashboard_data["dimensions"][metric_name] = {
                "score": stats.get("mean", 0),
                "distribution": {
                    "low": len([v for v in self._get_metric_values(metric_name) if v < 2]),
                    "medium": len([v for v in self._get_metric_values(metric_name) if 2 <= v < 3.5]),
                    "high": len([v for v in self._get_metric_values(metric_name) if v >= 3.5]),
                },
            }

        return dashboard_data

    def _get_metric_values(self, metric_name: str) -> List[float]:
        """Get all values for a specific metric."""
        values = []
        for eval_result in self.evaluations:
            if metric_name in eval_result["metrics"]:
                value = eval_result["metrics"][metric_name]
                if isinstance(value, (int, float)):
                    values.append(value)
        return values


class RubricParser:
    """Parse EVAL rubric.md files."""

    @staticmethod
    def parse_rubric(rubric_content: str) -> Dict:
        """Parse rubric markdown into structured format."""
        dimensions = []
        current_dimension = None
        lines = rubric_content.split("\n")

        for line in lines:
            # Detect dimension headers
            if line.startswith("## Dimension") or line.startswith("### "):
                if current_dimension:
                    dimensions.append(current_dimension)

                current_dimension = {
                    "name": line.replace("##", "").replace("###", "").strip(),
                    "weight": 1 / 3,  # Default weight
                    "criteria": {0: "", 1: "", 2: "", 3: "", 4: ""},
                }

            # Parse weight
            if "Weight:" in line and current_dimension:
                try:
                    weight_str = line.split("Weight:")[1].strip("%").strip()
                    current_dimension["weight"] = float(weight_str) / 100
                except ValueError:
                    pass

            # Parse criteria rows
            if "| **" in line and current_dimension:
                parts = line.split("|")
                if len(parts) >= 3:
                    try:
                        score_str = parts[1].strip().replace("**", "").strip()
                        score = int(score_str)
                        criteria = parts[2].strip()
                        current_dimension["criteria"][score] = criteria
                    except (ValueError, IndexError):
                        pass

        if current_dimension:
            dimensions.append(current_dimension)

        return {
            "dimensions": dimensions,
            "dimension_count": len(dimensions),
            "weights_sum": sum(d.get("weight", 0) for d in dimensions),
        }
