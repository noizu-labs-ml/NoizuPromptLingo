"""Configuration constants and utilities for NPL loader."""

import os
from pathlib import Path
from typing import Dict, Optional

# Default section ordering for markdown output
DEFAULT_SECTION_ORDER = {
    "components": [
        "syntax",
        "directives",
        "prefixes",
        "prompt-sections",
        "special-sections",
        "declarations",
        "pumps"
    ]
}

NPL_VERSION = "1.0"


class Config:
    """Database configuration from environment variables."""

    def __init__(self):
        self.db_host = os.environ.get("NPL_DB_HOST", "localhost")
        self.db_port = os.environ.get("NPL_DB_PORT", "5432")
        self.db_name = os.environ.get("NPL_DB_NAME", "npl")
        self.db_user = os.environ.get("NPL_DB_USER", "npl")
        self.db_password = os.environ.get("NPL_DB_PASSWORD", "npl_secret")

    def to_dict(self) -> Dict[str, str]:
        """Convert to dict for psycopg2.connect()."""
        return {
            "host": self.db_host,
            "port": self.db_port,
            "database": self.db_name,
            "user": self.db_user,
            "password": self.db_password,
        }


def get_npl_dir(path: Optional[str]) -> Optional[Path]:
    """Determine NPL directory from explicit path or defaults.

    Resolution order:
    1. Explicit path argument
    2. ~/.npl/npl (user home)
    3. ./npl (current directory)
    """
    if path:
        return Path(path)

    home_npl = Path.home() / ".npl" / "npl"
    local_npl = Path.cwd() / "npl"

    if home_npl.exists():
        return home_npl
    elif local_npl.exists():
        return local_npl

    return None
