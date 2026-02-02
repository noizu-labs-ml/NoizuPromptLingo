#!/usr/bin/env python3
"""Convert web pages, documents, and images to markdown."""

import argparse
import asyncio
import json
import sys
from pathlib import Path

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from npl_mcp.markdown.converter import MarkdownConverter
from npl_mcp.markdown.cache import MarkdownCache


def create_parser() -> argparse.ArgumentParser:
    """Create command-line argument parser."""
    parser = argparse.ArgumentParser(
        description="Convert URLs, files, and images to markdown",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  2md https://example.com/docs
  2md report.pdf
  2md diagram.png --vision-prompt "Describe with LaTeX formulas"
  2md https://api.docs.com/ref --no-cache
  2md page.html --format plain
        """,
    )

    # Positional arguments
    parser.add_argument("source", help="URL, file path, or image to convert")
    parser.add_argument("output", nargs="?", help="Output file (default: stdout or cached .md file)")

    # Format options
    parser.add_argument(
        "--format",
        choices=["rich", "plain", "json"],
        default="rich",
        help="Output format (default: rich with metadata)",
    )

    # Caching
    parser.add_argument("--no-cache", action="store_true", help="Disable caching (force fresh conversion)")
    parser.add_argument("--cache-dir", type=Path, help="Custom cache directory (default: .tmp/cache/markdown/)")

    # Network options
    parser.add_argument("--timeout", type=int, default=30, help="Request timeout for URLs (default: 30)")

    # Image conversion (future)
    parser.add_argument("--vision-prompt", help="Custom prompt for image analysis")

    # Output options
    parser.add_argument("--quiet", "-q", action="store_true", help="Suppress all output except content")

    return parser


async def async_main(args) -> int:
    """Async main function.

    Args:
        args: Parsed command-line arguments

    Returns:
        Exit code (0 for success, 1 for error)
    """
    cache = MarkdownCache(cache_dir=args.cache_dir)
    converter = MarkdownConverter(cache)

    try:
        # Convert source
        result = await converter.convert(
            args.source, force_refresh=args.no_cache, timeout=args.timeout
        )

        # Format output
        if args.format == "plain":
            # Extract content only (strip metadata header)
            lines = result.split("\n")
            separator_idx = lines.index("---") if "---" in lines else 0
            content = "\n".join(lines[separator_idx + 1 :])
        elif args.format == "json":
            # Parse metadata header and create JSON
            lines = result.split("\n")
            metadata = {}
            content = ""
            in_header = True
            for line in lines:
                if line == "---":
                    in_header = False
                    continue
                if in_header and ":" in line:
                    key, value = line.split(":", 1)
                    metadata[key.strip()] = value.strip()
                elif not in_header:
                    content += line + "\n"
            content = json.dumps({"metadata": metadata, "content": content.strip()}, indent=2)
        else:
            # Rich format (default)
            content = result

        # Write output
        if args.output:
            Path(args.output).write_text(content)
            if not args.quiet:
                print(f"✅ Converted {args.source} → {args.output}", file=sys.stderr)
        else:
            print(content)

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
