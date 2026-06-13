"""ToolHelp - LLM-driven usage instructions for catalog tools."""

import json

from .catalog import get_tool_by_name, ToolEntry
from .inference_cache import cache_key, cache_get, cache_set
from .llm_client import chat_completion


def _build_help_prompt(
    entry: ToolEntry,
    task: str,
    verbose: int,
) -> list[dict[str, str]]:
    """Build LLM prompt for tool help generation."""
    params_text = json.dumps(entry["parameters"], indent=2)

    detail_instruction = {
        1: (
            "Be brief: 2-3 sentences explaining what to do. "
            "No examples, no parameter listing."
        ),
        2: (
            "Give a clear explanation with parameter guidance. "
            "Include one short example call."
        ),
        3: (
            "Give a thorough explanation with all parameter details, "
            "multiple examples covering common use cases and edge cases, "
            "and tips for combining with other tools if relevant."
        ),
    }.get(verbose, (
        "Give a clear explanation with parameter guidance. "
        "Include one short example call."
    ))

    system_msg = (
        "You are a tool usage assistant. Given a tool definition and a user's task, "
        "explain HOW to use the tool to accomplish the task.\n\n"
        f"Detail level: {detail_instruction}\n\n"
        "Return a clear, actionable response in markdown format. "
        "Do NOT wrap the response in JSON."
    )

    user_msg = (
        f"## Tool\n"
        f"**{entry['name']}** [{entry['category']}]\n"
        f"{entry['description']}\n\n"
        f"### Parameters\n```json\n{params_text}\n```\n\n"
        f"## Task\n{task}"
    )

    return [
        {"role": "system", "content": system_msg},
        {"role": "user", "content": user_msg},
    ]


async def tool_help(tool: str, task: str, verbose: int = 2) -> dict:
    """Generate LLM-driven instructions for using a tool to accomplish a task.

    Args:
        tool: Name of the catalog tool.
        task: Description of what the user is trying to do.
        verbose: Detail level (1=brief, 2=standard, 3=detailed with examples).

    Returns:
        Dict with tool name, task, and generated instructions.
    """
    entry = await get_tool_by_name(tool)
    if entry is None:
        return {
            "tool": tool,
            "status": "error",
            "message": f"Tool '{tool}' not found in catalog.",
        }

    # Clamp verbose to valid range
    verbose = max(1, min(3, verbose))

    key = cache_key("tool_help", tool, task, str(verbose))
    cached = cache_get(key)
    if cached is not None:
        return cached

    try:
        messages = _build_help_prompt(entry, task, verbose)
        response = await chat_completion(messages, max_tokens=3000)
        content = response["choices"][0]["message"]["content"]

        result = {
            "tool": tool,
            "category": entry["category"],
            "task": task,
            "verbose": verbose,
            "instructions": content.strip(),
        }

        cache_set(key, result)
        return result

    except Exception as e:
        return {
            "tool": tool,
            "category": entry["category"],
            "task": task,
            "verbose": verbose,
            "status": "error",
            "message": f"LLM call failed: {type(e).__name__}: {e}",
        }
