# FR-016-007: Jupyter Notebook Generator

**Status**: Draft

## Description

The system must generate interactive Jupyter notebooks with 7+ analysis cells for exploring skill quality, including visualizations, dimension breakdowns, and improvement recommendations.

## Interface

```python
def generate_evaluation_notebook(skill_path: str, evaluation: DatasetEvaluation) -> NotebookPath:
    """Generate Jupyter notebook for skill quality exploration.

    Returns:
        Path to generated .ipynb file
    """
```

## Behavior

- **Given** skill path and evaluation results
- **When** notebook generation is triggered
- **Then** interactive notebook is created with pre-populated analysis cells and visualizations

## Edge Cases

- **Missing dependencies**: Notebook includes cell to install required packages
- **Large datasets**: Uses sampling in notebook for performance
- **No visualizations**: Falls back to text output if plotting libraries unavailable
- **Existing notebook**: Prompts before overwriting or creates versioned copy

## Related User Stories

- US-016-002

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 90% for this FR (notebook rendering may be hard to test)
