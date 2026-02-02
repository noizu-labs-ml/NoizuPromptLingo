#!/usr/bin/env python3
"""View markdown from any source with optional filtering and collapsing."""

import argparse
import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from npl_mcp.markdown.converter import MarkdownConverter
from npl_mcp.markdown.cache import MarkdownCache
from npl_mcp.markdown.viewer import MarkdownViewer


def create_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Convert and view markdown from any source",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  view-md https://example.com/docs
  view-md https://api.docs/ref --filter "Authentication"
  view-md report.pdf --filter "Results" --bare
  view-md page.html --depth 2
  view-md https://docs.com --filter "Installation" --bare > install.md
  view-md https://docs.com --rich --filter "API"  # Pretty-print with Rich formatting
        """,
    )

    # Positional arguments
    parser.add_argument("source", help="URL, file path, or image to convert and view")
    parser.add_argument("output", nargs="?", help="Output file (default: stdout)")

    # Filtering options
    parser.add_argument(
        "--filter", help='Filter selector (e.g., "API Reference", "h2", "css:#main")'
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
        "--filter-inner-depth",
        type=int,
        metavar="N",
        help="Collapse depth WITHIN filtered sections only (1-6)",
    )
    parser.add_argument(
        "--rich",
        action="store_true",
        help="Format markdown output with Rich (terminal styling, stdout only)",
    )

    # Caching options
    parser.add_argument(
        "--no-cache",
        action="store_true",
        help="Disable caching (force fresh conversion)",
    )
    parser.add_argument(
        "--cache-dir",
        type=Path,
        help="Custom cache directory (default: .tmp/cache/markdown/)",
    )

    # Network options
    parser.add_argument(
        "--timeout",
        type=int,
        default=30,
        help="Request timeout for URLs (default: 30)",
    )

    # Output options
    parser.add_argument(
        "--quiet", "-q", action="store_true", help="Suppress all output except content"
    )

    return parser


async def async_main(args):
    """Async main function."""
    try:
        # Convert source to markdown
        cache = MarkdownCache(cache_dir=args.cache_dir)
        converter = MarkdownConverter(cache)

        conversion_result = await converter.convert(
            args.source, force_refresh=args.no_cache, timeout=args.timeout
        )

        # Extract content from conversion result (strip metadata header)
        lines = conversion_result.split("\n")
        separator_idx = lines.index("---") if "---" in lines else 0
        markdown_content = "\n".join(lines[separator_idx + 1 :])

        # Apply filtering/viewing transformations
        viewer = MarkdownViewer()
        result = viewer.view(
            markdown_content,
            filter=args.filter,
            bare=args.bare,
            depth=args.depth,
            filter_inner_depth=args.filter_inner_depth,
        )

        # Write output
        if args.output:
            Path(args.output).write_text(result)
            if not args.quiet:
                print(f"✅ {args.source} → {args.output}", file=sys.stderr)
        else:
            # Apply Rich formatting if requested (only to stdout, not to files)
            if args.rich:
                from rich.markdown import Markdown
                from rich.console import Console

                console = Console()
                console.print(Markdown(result))
            else:
                print(result, end="")

        return 0

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
