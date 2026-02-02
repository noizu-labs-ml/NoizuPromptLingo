# FR-002: Fabric CLI Integration

**Status**: Completed

## Description

System must integrate with danielmiessler/fabric CLI for LLM-based analysis of command outputs, with auto-detection and graceful fallback.

## Interface

```python
def find_fabric() -> Optional[Path]:
    """Auto-detect fabric installation."""

def apply_fabric_pattern(
    content: str,
    pattern: str,
    model: Optional[str] = None,
    timeout: int = 30
) -> Dict:
    """Apply single fabric pattern to content."""

def analyze_with_patterns(
    content: str,
    patterns: List[str],
    combine_results: bool = False
) -> Dict:
    """Apply multiple patterns and optionally combine results."""

def list_patterns() -> Dict:
    """List available fabric patterns."""

def select_pattern_for_task(task_type: str) -> str:
    """Select appropriate pattern based on task type."""
```

## Behavior

- **Given** fabric is installed at /usr/local/bin/fabric
- **When** `find_fabric()` is called
- **Then** returns Path("/usr/local/bin/fabric")

- **Given** fabric is not installed
- **When** `apply_fabric_pattern()` is called
- **Then** returns error dict with graceful fallback message

- **Given** content="logs from crash" and pattern="analyze_logs"
- **When** `apply_fabric_pattern(content, pattern)` is called
- **Then** returns analyzed output with insights

## Edge Cases

- **Fabric not in PATH**: Check common locations (/usr/local/bin, ~/.local/bin, ~/bin)
- **Pattern not found**: Return error with list of available patterns
- **Timeout exceeded**: Kill process and return partial results
- **Empty content**: Return error without invoking fabric

## Related User Stories

- US-009-002

## Test Coverage

Expected test count: 8-12 tests
Target coverage: 100% for integration logic
