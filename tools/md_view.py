#!/usr/bin/env python3
"""Pipe filter for markdown - stdin to stdout with optional filtering."""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from npl_mcp.markdown.viewer import MarkdownViewer


def create_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Pipe filter for markdown (stdin → stdout)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  cat document.md | md-view --filter "API"
  2md https://example.com | md-view --filter "h2"
  md-view --filter "Installation" < readme.md > install.md
  md-view --bare --filter "Features" < doc.md
  md-view --depth 2 < doc.md  # Collapse deep headings
  md-view --rich --filter "API" < doc.md  # Pretty-print with Rich formatting
        """,
    )

    # Filtering options
    parser.add_argument(
        "--filter", help='Filter selector (e.g., "h2", "API > Reference", "css:#main")'
    )

    # Display options
    parser.add_argument(
        "--bare",
        action="store_true",
        help="Show ONLY filtered content (no collapsed headings)",
    )
    parser.add_argument(
        "--depth",
        type=int,
        metavar="N",
        help="When not --bare, collapse headings below this depth (1-6)",
    )
    parser.add_argument(
        "--rich",
        action="store_true",
        help="Format markdown output with Rich (terminal styling)",
    )

    return parser


def main() -> int:
    """Main entry point."""
    parser = create_parser()
    args = parser.parse_args()

    try:
        # Read from stdin
        content = sys.stdin.read()

        # Apply view transformations
        viewer = MarkdownViewer()
        result = viewer.view(
            content, filter=args.filter, bare=args.bare, depth=args.depth
        )

        # Apply Rich formatting if requested
        if args.rich:
            from rich.markdown import Markdown
            from rich.console import Console

            console = Console()
            console.print(Markdown(result))
        else:
            # Write to stdout
            print(result, end="")

        return 0

    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())
