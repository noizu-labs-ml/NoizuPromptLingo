# Python Code Generation
Generate Python code artifacts for automation, web development, data processing, and system integration using NPL-FIM.
[Documentation](https://docs.python.org/3/)

## WWHW
**What:** Create Python scripts, modules, packages, and applications across diverse domains
**Why:** Accelerate development, ensure code consistency, and implement best practices automatically
**How:** Transform requirements into production-ready Python code through NPL-FIM structured prompting
**When:** Building APIs, automating workflows, processing data, or developing any Python-based solution

## When to Use
- Creating web applications with Flask/Django/FastAPI frameworks
- Building command-line tools and system automation scripts
- Developing REST APIs and microservices architectures
- Implementing data pipelines and ETL processes
- Generating test suites and documentation utilities

## Key Outputs
`.py scripts`, `modules/`, `packages/`, `.ipynb notebooks`, `CLI tools`, `API endpoints`

## Quick Example
```python
#!/usr/bin/env python3
"""Configuration-driven task automation script."""

import argparse
import logging
from pathlib import Path

def process_files(src_dir: Path, pattern: str) -> int:
    """Process matching files with configurable operations."""
    matches = list(src_dir.glob(pattern))
    logging.info(f"Processing {len(matches)} files")

    for filepath in matches:
        # Apply transformations
        pass
    return len(matches)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--src", type=Path, required=True)
    parser.add_argument("--pattern", default="*.txt")
    args = parser.parse_args()

    result = process_files(args.src, args.pattern)
    print(f"Processed {result} files")
```

## Extended Reference
[Python Patterns](https://python-patterns.guide/) | [FastAPI](https://fastapi.tiangolo.com/) | [Packaging](https://packaging.python.org/) | [Effective Python](https://effectivepython.com/) | [Real Python](https://realpython.com/) | [Stdlib](https://docs.python.org/3/library/)