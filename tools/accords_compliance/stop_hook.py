#!/usr/bin/env python3
"""Standalone Claude Code Stop-hook entry point — runnable from any cwd.

Bootstraps ``sys.path`` from this file's location so the package imports
without installation, then delegates to :func:`tools.accords_compliance.hook.main`.

Wire it in ``settings.json``::

    {
      "hooks": {
        "Stop": [
          {
            "hooks": [
              {
                "type": "command",
                "command": "python3 /abs/path/to/NoizuPromptLingo/tools/accords_compliance/stop_hook.py"
              }
            ]
          }
        ]
      }
    }
"""

import sys
from pathlib import Path

# <repo-root>/tools/accords_compliance/stop_hook.py -> parents[2] == repo root.
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.accords_compliance.hook import main

if __name__ == "__main__":
    sys.exit(main())