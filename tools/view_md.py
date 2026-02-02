#!/usr/bin/env python3
"""Convert and filter markdown in one command (combines 2md + md-view)."""

import argparse
import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from npl_mcp.markdown.converter import MarkdownConverter
from npl_mcp.markdown.cache import MarkdownCache
from npl_mcp.markdown.viewer import MarkdownViewer


def create_parser() -> argparse.ArgumentParser:
    """Create command-line argument parser."""
    parser = argparse.ArgumentParser(
        description="Convert and filter markdown in one command",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  view-md https://example.com/docs --filter "h2"
  view-md report.pdf --filter "Overview > Installation"
  view-md https://docs.python.org/3/library/pathlib.html --collapse-depth 2
  view-md page.html --filter "API Reference" --filtered-only
        """,
    )

    # Positional arguments
    parser.add_argument("source", help="URL, file path, or content to convert and view")

    # Filtering options
    parser.add_argument("--filter", help='Filter selector (e.g., "h2", "Overview > API")')
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

    # Caching options
    parser.add_argument("--no-cache", action="store_true", help="Disable caching (force fresh conversion)")
    parser.add_argument("--cache-dir", type=Path, help="Custom cache directory (default: .tmp/cache/markdown/)")

    # Network options
    parser.add_argument("--timeout", type=int, default=30, help="Request timeout for URLs (default: 30)")

    # Output options
    parser.add_argument("--output", "-o", help="Output file (default: stdout)")
    parser.add_argument("--quiet", "-q", action="store_true", help="Suppress status messages")

    return parser


async def async_main(args) -> int:
    """Async main function.

    Args:
        args: Parsed command-line arguments

    Returns:
        Exit code (0 for success, 1 for error)
    """
    try:
        # Step 1: Convert source to markdown
        cache = MarkdownCache(cache_dir=args.cache_dir)
        converter = MarkdownConverter(cache)

        if not args.quiet:
            print(f"📝 Converting {args.source}...", file=sys.stderr)

        markdown_content = await converter.convert(
            args.source, force_refresh=args.no_cache, timeout=args.timeout
        )

        # Strip metadata header for viewing
        lines = markdown_content.split("\n")
        separator_idx = lines.index("---") if "---" in lines else 0
        content = "\n".join(lines[separator_idx + 1 :]).strip()

        # Step 2: Apply viewer filters/collapsing
        viewer = MarkdownViewer()
        result = viewer.view(
            content,
            filter=args.filter,
            collapsed_depth=args.collapse_depth,
            filtered_only=args.filtered_only,
        )

        # Step 3: Output result
        if args.output:
            Path(args.output).write_text(result)
            if not args.quiet:
                print(f"✅ Converted and filtered {args.source} → {args.output}", file=sys.stderr)
        else:
            print(result)

        return 0

    except FileNotFoundError as e:
        if not args.quiet:
            sys.stderr.write(f"Error: File not found: {e}\n")
        return 1
    except Exception as e:
        if not args.quiet:
            sys.stderr.write(f"Error: {e}\n")
        return 1


def main() -> int:
    """Main entry point."""
    parser = create_parser()
    args = parser.parse_args()

    return asyncio.run(async_main(args))


if __name__ == "__main__":
    sys.exit(main())
