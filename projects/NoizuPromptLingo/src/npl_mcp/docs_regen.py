"""NPL documentation regeneration.

Generates the full NPL specification markdown by calling
:class:`~npl_mcp.convention_formatter.NPLDefinition` against the
authoritative ``conventions/*.yaml`` source-of-truth directory.

Usage::

    uv run npl-docs-regen                    # writes to npl/npl-full.md
    uv run npl-docs-regen --out path.md      # custom destination
    uv run npl-docs-regen --stdout           # print to stdout instead
    uv run npl-docs-regen --check            # exit non-zero if regen would change file
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from npl_mcp.convention_formatter import NPLDefinition


REPO_ROOT = Path(__file__).resolve().parent.parent.parent
DEFAULT_CONVENTIONS = REPO_ROOT / "conventions"
DEFAULT_OUT = REPO_ROOT / "npl" / "npl-full.md"


def render_full_npl(
    *,
    conventions_dir: Path = DEFAULT_CONVENTIONS,
    concise: bool = False,
    xml: bool = False,
) -> str:
    """Render the complete NPL specification from a conventions directory.

    Returns the markdown string; does not touch the filesystem.
    """
    npl = NPLDefinition(conventions_dir=conventions_dir)
    return npl.format(
        components=None,  # include everything
        rendered=None,
        flags={"concise": concise, "xml": xml},
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="npl-docs-regen",
        description="Regenerate NPL spec markdown from conventions/*.yaml.",
    )
    parser.add_argument(
        "--conventions",
        type=Path,
        default=DEFAULT_CONVENTIONS,
        help="Directory containing convention YAMLs (default: repo/conventions).",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help="Output markdown path (default: repo/npl/npl-full.md).",
    )
    parser.add_argument(
        "--stdout",
        action="store_true",
        help="Print to stdout instead of writing to disk.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit with code 1 if regenerated output would differ from the file on disk.",
    )
    parser.add_argument(
        "--concise",
        action="store_true",
        help="Use brief descriptions (smaller output).",
    )
    parser.add_argument(
        "--xml",
        action="store_true",
        help="Render examples as XML tags instead of fenced code blocks.",
    )
    args = parser.parse_args(argv)

    rendered = render_full_npl(
        conventions_dir=args.conventions,
        concise=args.concise,
        xml=args.xml,
    )

    if args.stdout:
        sys.stdout.write(rendered)
        return 0

    if args.check:
        if not args.out.exists():
            print(f"{args.out} does not exist — regeneration required.", file=sys.stderr)
            return 1
        existing = args.out.read_text(encoding="utf-8")
        if existing == rendered:
            print(f"{args.out} is up to date.")
            return 0
        print(
            f"{args.out} is stale — regenerate with `uv run npl-docs-regen`.",
            file=sys.stderr,
        )
        return 1

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(rendered, encoding="utf-8")
    print(f"Wrote {len(rendered)} chars to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
