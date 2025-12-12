"""Fabric CLI integration for output analysis."""

import asyncio
import shutil
import subprocess
from pathlib import Path
from typing import Optional, List, Dict, Any


# Common fabric patterns for tasker operations
FABRIC_PATTERNS = {
    "summarize": "General content summarization",
    "extract_wisdom": "Extract key insights and wisdom",
    "analyze_logs": "Analyze log output for errors and patterns",
    "explain_code": "Explain code snippets",
    "extract_main_idea": "Get the core message from content",
    "analyze_claims": "Analyze and fact-check claims",
    "create_summary": "Create structured summary",
}


def find_fabric() -> Optional[Path]:
    """Find the fabric CLI executable.

    Returns:
        Path to fabric executable or None if not found
    """
    # Check common locations
    locations = [
        Path.home() / ".local" / "bin" / "fabric",
        Path("/usr/local/bin/fabric"),
        Path("/usr/bin/fabric"),
    ]

    for loc in locations:
        if loc.exists() and loc.is_file():
            return loc

    # Try which/where
    fabric_path = shutil.which("fabric")
    if fabric_path:
        return Path(fabric_path)

    return None


async def apply_fabric_pattern(
    content: str,
    pattern: str,
    model: Optional[str] = None,
    timeout: int = 300
) -> Dict[str, Any]:
    """Apply a fabric pattern to content.

    Args:
        content: Input content to analyze
        pattern: Fabric pattern name (e.g., "analyze_logs")
        model: Optional model override
        timeout: Timeout in seconds (default: 300 = 5 minutes)

    Returns:
        Dict with success status, result, and metadata
    """
    fabric_path = find_fabric()
    if not fabric_path:
        return {
            "success": False,
            "error": "Fabric CLI not found. Install from https://github.com/danielmiessler/fabric",
            "result": content[:1000] + "..." if len(content) > 1000 else content,
            "fallback": True
        }

    cmd = [str(fabric_path), "--pattern", pattern]
    if model:
        cmd.extend(["--model", model])

    try:
        # Run fabric with content piped to stdin
        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        stdout, stderr = await asyncio.wait_for(
            process.communicate(input=content.encode()),
            timeout=timeout
        )

        if process.returncode != 0:
            return {
                "success": False,
                "error": f"Fabric pattern failed: {stderr.decode()}",
                "result": content[:1000] + "..." if len(content) > 1000 else content,
                "fallback": True
            }

        return {
            "success": True,
            "result": stdout.decode(),
            "pattern": pattern,
            "model": model
        }

    except asyncio.TimeoutError:
        return {
            "success": False,
            "error": f"Fabric pattern timed out after {timeout}s",
            "result": content[:1000] + "..." if len(content) > 1000 else content,
            "fallback": True
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Fabric error: {str(e)}",
            "result": content[:1000] + "..." if len(content) > 1000 else content,
            "fallback": True
        }


async def analyze_with_patterns(
    content: str,
    patterns: List[str],
    combine_results: bool = True
) -> Dict[str, Any]:
    """Apply multiple fabric patterns to content.

    Args:
        content: Input content
        patterns: List of pattern names
        combine_results: Whether to combine or return separately

    Returns:
        Dict with pattern results
    """
    if not patterns:
        return {
            "success": True,
            "result": content[:2000] + "..." if len(content) > 2000 else content,
            "note": "No patterns specified, returning truncated content"
        }

    results = {}
    any_success = False

    for pattern in patterns:
        result = await apply_fabric_pattern(content, pattern)
        results[pattern] = result
        if result.get("success"):
            any_success = True

    if combine_results and len(results) > 1:
        combined_parts = []
        for pattern, result in results.items():
            if result.get("success"):
                combined_parts.append(f"## {pattern}\n\n{result['result']}")
            else:
                combined_parts.append(f"## {pattern}\n\n*Error: {result.get('error')}*")

        combined = "\n\n---\n\n".join(combined_parts)
        return {
            "success": any_success,
            "result": combined,
            "patterns": list(results.keys()),
            "individual_results": results
        }

    # Return first successful result or last failure
    for pattern, result in results.items():
        if result.get("success"):
            return result

    # All failed - return last one
    return list(results.values())[-1] if results else {
        "success": False,
        "error": "No patterns to apply"
    }


async def list_patterns() -> Dict[str, Any]:
    """List available fabric patterns.

    Returns:
        Dict with patterns list or error
    """
    fabric_path = find_fabric()
    if not fabric_path:
        return {
            "success": False,
            "error": "Fabric CLI not found",
            "common_patterns": FABRIC_PATTERNS
        }

    try:
        process = await asyncio.create_subprocess_exec(
            str(fabric_path), "--listpatterns",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        stdout, stderr = await asyncio.wait_for(
            process.communicate(),
            timeout=30
        )

        if process.returncode != 0:
            return {
                "success": False,
                "error": stderr.decode(),
                "common_patterns": FABRIC_PATTERNS
            }

        patterns = [p.strip() for p in stdout.decode().split('\n') if p.strip()]
        return {
            "success": True,
            "patterns": patterns,
            "count": len(patterns)
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "common_patterns": FABRIC_PATTERNS
        }


def select_pattern_for_task(task_type: str) -> str:
    """Select appropriate fabric pattern based on task type.

    Args:
        task_type: Type of task (e.g., "test_output", "web_content", "log_file")

    Returns:
        Recommended pattern name
    """
    pattern_map = {
        "test_output": "analyze_logs",
        "build_output": "analyze_logs",
        "log_file": "analyze_logs",
        "error": "analyze_logs",
        "web_content": "summarize",
        "documentation": "extract_wisdom",
        "article": "summarize",
        "issue": "extract_wisdom",
        "pr": "extract_wisdom",
        "code": "explain_code",
        "default": "summarize"
    }

    return pattern_map.get(task_type, pattern_map["default"])
