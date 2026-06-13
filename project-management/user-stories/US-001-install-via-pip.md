---
id: US-001
title: "Install via pip"
slug: "install-via-pip"
personas: [P-001]
epic: "Installation & Onboarding"
priority: "must-have"
complexity: "S"
tags: [installation, cli, python, pip]
---

# US-001: Install via pip

## User Story

**As an** indie AI game developer (P-001),
**I want to** install NoizuRPG with a single `pip install noizurpg` command,
**So that** I can get the framework into my Python environment without manual setup or dependency wrangling.

## Acceptance Criteria

- [ ] Given a Python 3.9+ environment with pip available, when I run `pip install noizurpg`, then the package installs without errors and all required dependencies are resolved automatically.
- [ ] Given a successful pip install, when I run `python -c "import noizurpg; print(noizurpg.__version__)"`, then the version string is printed without import errors.
- [ ] Given a successful pip install, when I run `noizurpg --help` in the terminal, then the CLI help text is displayed listing available commands including `init` and `play`.
- [ ] Given a Python environment below version 3.9, when I run `pip install noizurpg`, then pip displays a clear error message stating the minimum required Python version.

## Notes

The package must be published on PyPI under the name `noizurpg`. The install should add the `noizurpg` CLI entry point to PATH automatically via setuptools or pyproject.toml. See US-003 for CLI project scaffolding and US-004 for LLM provider configuration after install.
