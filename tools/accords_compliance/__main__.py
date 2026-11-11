"""``python -m tools.accords_compliance`` — run the Stop hook (cwd = repo root)."""

import sys

from .hook import main

if __name__ == "__main__":
    sys.exit(main())