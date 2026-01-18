"""YAML file loading and parsing operations."""

import hashlib
import re
from pathlib import Path
from typing import Dict, Optional

import yaml


class YAMLLoader:
    """Load and parse YAML files from a directory."""

    def __init__(self, npl_dir):
        """Initialize with NPL directory path.

        Args:
            npl_dir: Path to NPL YAML directory (str or Path)
        """
        self.npl_dir = Path(npl_dir) if isinstance(npl_dir, str) else npl_dir

    def load_file(self, path: Path) -> Optional[dict]:
        """Load and parse a single YAML file.

        Args:
            path: Path to YAML file

        Returns:
            Parsed YAML content, or None if file missing/empty
        """
        if not path.exists():
            return None
        with open(path, "r") as f:
            return yaml.safe_load(f)

    def load_all(self) -> Dict[str, Dict]:
        """Load all YAML files from the NPL directory recursively.

        Returns:
            Dict keyed by relative path (dots replacing slashes), containing:
            - path: absolute path string
            - relative_path: path relative to npl_dir
            - filename: just the filename
            - digest: SHA256 of file contents
            - content: parsed YAML content
        """
        data = {}

        if not self.npl_dir.exists():
            return data

        for yaml_file in self.npl_dir.rglob("*.yaml"):
            relative_path = yaml_file.relative_to(self.npl_dir)
            # Convert path to dot-notation key: "subdir/foo.yaml" -> "subdir.foo"
            key = str(relative_path).replace("/", ".").replace(".yaml", "")

            content = self.load_file(yaml_file)
            if content:
                # Calculate file digest for change detection
                with open(yaml_file, "rb") as f:
                    file_digest = hashlib.sha256(f.read()).hexdigest()

                data[key] = {
                    "path": str(yaml_file),
                    "relative_path": str(relative_path),
                    "filename": yaml_file.name,
                    "digest": file_digest,
                    "content": content
                }

        return data

    def compute_digest(self, component: dict) -> str:
        """Compute SHA256 digest of a component's canonical YAML.

        Uses sorted keys for consistent digests regardless of field order.

        Args:
            component: Dict to hash

        Returns:
            64-character hex SHA256 digest
        """
        yaml_str = yaml.dump(component, sort_keys=True, default_flow_style=False)
        return hashlib.sha256(yaml_str.encode()).hexdigest()

    @staticmethod
    def slugify(text: str) -> str:
        """Convert text to URL-friendly slug.

        Args:
            text: Input text

        Returns:
            Lowercase slug with special chars removed
        """
        text = text.lower()
        text = re.sub(r'[^\w\s-]', '', text)
        text = re.sub(r'[\s_]+', '-', text)
        return text.strip('-')
