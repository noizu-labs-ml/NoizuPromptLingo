#!/usr/bin/env python3
"""NPL Loader CLI - Command-line interface for NPL operations.

This module provides the CLI entry point for the npl-loader command.
All core functionality is in the npl package.

Usage:
    npl-loader --yaml           # Output from YAML files
    npl-loader --yaml --instructions  # Include instructional notes
    npl-loader --sync           # Sync YAML to database
    npl-loader --list           # List YAML files
    npl-loader                  # Output from database (default)
"""

import argparse
import sys
from pathlib import Path

from tools.npl import (
    DBManager,
    Formatter,
    SyncManager,
    YAMLLoader,
    get_npl_dir,
)


def main() -> int:
    """Main CLI entry point.

    Returns:
        Exit code (0 for success, 1 for error)
    """
    parser = argparse.ArgumentParser(
        description="Load and format NPL definitions (default: from database)"
    )
    parser.add_argument(
        "--path", "-p",
        type=str,
        default=None,
        help="Path to NPL directory (default: ~/.npl/npl or ./npl)"
    )
    parser.add_argument(
        "--sync",
        action="store_true",
        help="Sync YAML files to database"
    )
    parser.add_argument(
        "--yaml",
        action="store_true",
        help="Output from YAML files instead of database"
    )
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List all YAML files found"
    )
    parser.add_argument(
        "--with-labels",
        action="store_true",
        help="Include labels in output"
    )
    parser.add_argument(
        "--instructions",
        action="store_true",
        help="Include instructional notes section at the end"
    )

    args = parser.parse_args()

    # Commands that require YAML files
    if args.sync or args.yaml or args.list:
        npl_dir = get_npl_dir(args.path)
        if not npl_dir or not npl_dir.exists():
            print("Error: NPL directory not found")
            print("Use --path to specify the NPL directory location")
            return 1

        # --sync: Sync YAML to database
        if args.sync:
            with SyncManager(npl_dir) as sync:
                sync.sync()
            return 0

        # Load YAML files
        loader = YAMLLoader(npl_dir)
        data = loader.load_all()

        if not data:
            print(f"Error: No YAML files found in {npl_dir}")
            return 1

        # --list: Display file inventory
        if args.list:
            print(f"Found {len(data)} YAML files in {npl_dir}:")
            for key, section_data in sorted(data.items()):
                rel_path = section_data.get('relative_path', key)
                digest = section_data['digest'][:8]
                print(f"  - {rel_path} (digest: {digest}...)")
            return 0

        # --yaml: Output from YAML files
        formatter = Formatter(data, with_labels=args.with_labels)
        output = formatter.format_output(with_instructional_notes=args.instructions)
        print(output)
        return 0

    # Default: Output from database
    try:
        with DBManager() as db:
            data = db.load_from_database()
    except ImportError as e:
        print(f"Error: {e}")
        return 1
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return 1

    if not data:
        print("Error: No data found in database. Run --sync first.")
        return 1

    formatter = Formatter(data, with_labels=args.with_labels)
    output = formatter.format_output(with_instructional_notes=args.instructions)
    print(output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
