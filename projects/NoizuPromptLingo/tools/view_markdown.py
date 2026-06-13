#!/usr/bin/env python3
"""Filter and view markdown with collapsible sections."""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from npl_mcp.markdown.viewer import MarkdownViewer


def create_parser() -> argparse.ArgumentParser:
    """Create command-line argument parser."""
    parser = argparse.ArgumentParser(
        description="Filter and view markdown with collapsible sections",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  md-view document.md --filter "h2"
  md-view doc.md --filter "Overview > API"
  md-view doc.md --collapse-depth 2
  md-view doc.md --filter "Features" --filtered-only
  cat doc.md | md-view --filter "Installation"
        """,
    )

    # Positional arguments
    parser.add_argument(
        "source", nargs="?", default="-", help='Markdown file or "-" for stdin (default: stdin)'
    )

    # Filtering options
    parser.add_argument("--filter", help='Filter selector (e.g., "h2", "Overview > API", "css:#main")')
    parser.add_argument(
        "--filtered-only",
        action="store_true",
        help="Show only filtered sections (no collapsed headings)",
    )

    # Display options
    parser.add_argument(
        "--collapse-depth",
        type=int,
        metavar="DEPTH",
        help="Collapse headings below this depth (1-6)",
    )

    # Output options
    parser.add_argument("--output", "-o", help="Output file (default: stdout)")

    return parser


def main() -> int:
    """Main entry point."""
    parser = create_parser()
    args = parser.parse_args()

    try:
        # Read input
        if args.source == "-":
            content = sys.stdin.read()
        else:
            content = Path(args.source).read_text()

        # Apply view transformations
        viewer = MarkdownViewer()
        result = viewer.view(
            content,
            filter=args.filter,
            collapsed_depth=args.collapse_depth,
            filtered_only=args.filtered_only,
        )

        # Write output
        if args.output:
            Path(args.output).write_text(result)
            print(f"✅ Filtered markdown → {args.output}", file=sys.stderr)
        else:
            print(result)

        return 0

    except FileNotFoundError as e:
        sys.stderr.write(f"Error: File not found: {e}\n")
        return 1
    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())
