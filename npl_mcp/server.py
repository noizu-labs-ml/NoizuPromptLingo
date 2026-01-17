"""FastMCP Server with SSE transport."""

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("Noizu Prompt Lingua")


@mcp.tool()
def hello_world(name: str = "World") -> str:
    """Say hello to someone.

    Args:
        name: The name to greet
    """
    return f"Hello, {name}!"


@mcp.resource("greeting://{name}")
def get_greeting(name: str) -> str:
    """Get a personalized greeting resource.

    Args:
        name: The name for the greeting
    """
    return f"Welcome, {name}! This is a greeting resource."


@mcp.prompt()
def hello_prompt(name: str = "World") -> str:
    """A simple hello world prompt template.

    Args:
        name: The name to include in the prompt
    """
    return f"Please greet {name} in a friendly manner."


if __name__ == "__main__":
    mcp.run(transport="sse")
