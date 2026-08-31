"""
Configuration management for run-claude.

Loads secrets and configuration from ~/.config/run-claude/.secrets
Supports both environment variables and dictionary access patterns.
"""

from __future__ import annotations

import os
import secrets
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    yaml = None  # type: ignore


@dataclass
class SecretsConfig:
    """Container for secrets loaded from config file."""
    _data: dict[str, Any]

    def __getitem__(self, key: str) -> str:
        """Get a secret value by key."""
        if key not in self._data:
            raise KeyError(f"Secret key not found: {key}")
        value = self._data[key]
        if value is None:
            raise ValueError(f"Secret key is None: {key}")
        return str(value)

    def get(self, key: str, default: str | None = None) -> str | None:
        """Get a secret value with optional default."""
        if key in self._data:
            value = self._data[key]
            return str(value) if value is not None else default
        return default

    def to_env(self) -> dict[str, str]:
        """Convert secrets to environment variable dict."""
        env = {}
        for key, value in self._data.items():
            if value is not None:
                env[key] = str(value)
        return env


def get_secrets_file() -> Path:
    """Get path to secrets configuration file.

    Priority order:
    1. $RUN_CLAUDE_HOME/.secrets (if set)
    2. $XDG_CONFIG_HOME/run-claude/.secrets (if set)
    3. ~/.config/run-claude/.secrets (default)
    """
    # Check RUN_CLAUDE_HOME first (allows custom installation directory)
    run_claude_home = os.environ.get("RUN_CLAUDE_HOME")
    if run_claude_home:
        return Path(run_claude_home) / ".secrets"

    # Fall back to XDG_CONFIG_HOME
    xdg_config = os.environ.get("XDG_CONFIG_HOME")
    if xdg_config:
        base = Path(xdg_config)
    else:
        base = Path.home() / ".config"
    return base / "run-claude" / ".secrets"


def _require_yaml() -> None:
    """Raise error if PyYAML not installed."""
    if yaml is None:
        raise RuntimeError(
            "PyYAML is required for config loading.\n"
            "Install with: pip install pyyaml"
        )


def generate_random_password(length: int = 32) -> str:
    """Generate a cryptographically secure random password.

    Args:
        length: Password length (default 32 characters)

    Returns:
        Random password with mixed case, numbers, and symbols
    """
    # Use secure random generator
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    password = ''.join(secrets.choice(alphabet) for _ in range(length))
    return password


def load_secrets(debug: bool = False) -> SecretsConfig:
    """
    Load secrets from configuration file.

    Looks for ~/.config/run-claude/.secrets (YAML format)
    Returns a SecretsConfig object for accessing secret values.

    Example .secrets file:
    ---
    RUN_CLAUDE_TIMESCALEDB_PASSWORD: "your-password-here"
    ANTHROPIC_API_KEY: "sk-..."
    OTHER_SECRET: "value"
    """
    _require_yaml()

    secrets_file = get_secrets_file()

    if debug:
        print(f"DEBUG: Loading secrets from: {secrets_file}", file=sys.stderr)
        print(f"DEBUG: Secrets file exists: {secrets_file.exists()}", file=sys.stderr)

    if not secrets_file.exists():
        if debug:
            print(f"DEBUG: Secrets file not found, returning empty config", file=sys.stderr)
        return SecretsConfig(_data={})

    try:
        content = secrets_file.read_text(encoding="utf-8")
        data = yaml.safe_load(content) or {}

        if not isinstance(data, dict):
            raise ValueError(f"Secrets file must contain a YAML dictionary, got {type(data)}")

        if debug:
            keys = list(data.keys())
            print(f"DEBUG: Loaded secrets with keys: {keys}", file=sys.stderr)

        return SecretsConfig(_data=data)

    except Exception as e:
        print(f"Error loading secrets from {secrets_file}: {e}", file=sys.stderr)
        raise


def create_secrets_template(generate_passwords: bool = False, expand_vars: bool = False) -> str:
    """Generate a template .secrets file with documentation.

    Args:
        generate_passwords: If True, generate random passwords for default fields
        expand_vars: If True, expand any environment variables in values

    Returns:
        YAML template string with required and optional variables documented
    """
    # Generate random password if requested
    db_password = generate_random_password() if generate_passwords else "your-postgres-password"

    template = f"""# run-claude Secrets Configuration
# Location: ~/.config/run-claude/.secrets
# Permissions: chmod 600 (owner read/write only)
#
# WARNING: This file contains sensitive information!
# - Never commit to version control
# - Restrict file permissions to owner only
# - Keep backups in secure location
#
# VARIABLE GUIDE:
# ===============
# Required variables (MUST be set):
#   - RUN_CLAUDE_TIMESCALEDB_PASSWORD: Database password (generated with `run-claude secrets init --generate`)
#   - ANTHROPIC_API_KEY: Your Anthropic API key (get from https://console.anthropic.com)
#
# Optional variables (can be commented out to use defaults):
#   - RUN_CLAUDE_TIMESCALEDB_USER: Database user (default: postgres)
#   - RUN_CLAUDE_TIMESCALEDB_DATABASE: Database name (default: postgres)
#
# How to generate secure passwords:
#   $ run-claude secrets init --generate
#
# Docker Compose Usage:
#   The .env file is automatically loaded by Docker Compose.
#   Variables are made available to containers without additional flags.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# REQUIRED VARIABLES (Edit these!)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Database password - REQUIRED
# Generate with: run-claude secrets init --generate
RUN_CLAUDE_TIMESCALEDB_PASSWORD: "{db_password}"

# API key - REQUIRED (for API key profiles like anthropic, cerebras, etc.)
# Get from: https://console.anthropic.com/api_keys
ANTHROPIC_API_KEY: "sk-your-key-here"

# OAuth token - OPTIONAL (for claude-plan profile pass-through)
# Not needed if using claude-plan — Claude Code uses its own OAuth token.
# Only set this if you want the proxy to make Anthropic calls with a stored token.
# ANTHROPIC_OAUTH_TOKEN: "sk-ant-oat01-..."

# Alibaba Token Plan (Qwen) — alibaba profile
# Dedicated Token Plan key (sk-sp-*), not a pay-as-you-go DashScope sk- key.
# QWEN_SUB_KEY: "sk-sp-..."

# Z.AI coding subscription (zai-pro profile, zai/* models)
# ZAI_SUB_KEY: "..."
# Second Z.AI subscription (Tyna). Switch live with: run-claude keys switch zai tyna
# ZAI_SUB_KEY_TYNA: "..."

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OPTIONAL VARIABLES (Uncomment to override defaults)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Database user (default: postgres)
# RUN_CLAUDE_TIMESCALEDB_USER: "postgres"

# Database name (default: postgres)
# RUN_CLAUDE_TIMESCALEDB_DATABASE: "postgres"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CUSTOM VARIABLES (Add your own)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Examples with environment variable expansion:
# CUSTOM_PATH: "${{HOME}}/custom"
# CUSTOM_VALUE: "${{SOME_VAR:-fallback}}"

# Your custom secrets here:
# MY_SECRET: "value"
"""
    return template


def ensure_secrets_template(force: bool = False, generate_passwords: bool = False, debug: bool = False) -> Path:
    """
    Ensure secrets template exists.

    Creates a template .secrets file if it doesn't exist (and force=False),
    with warnings about file permissions.

    Args:
        force: Overwrite existing file
        generate_passwords: Generate random passwords for required fields
        debug: Enable debug output

    Returns the path to the secrets file.
    """
    secrets_file = get_secrets_file()

    if debug:
        print(f"DEBUG: Checking secrets file: {secrets_file}", file=sys.stderr)

    if secrets_file.exists() and not force:
        if debug:
            print(f"DEBUG: Secrets file already exists", file=sys.stderr)
        return secrets_file

    # Create parent directory
    secrets_file.parent.mkdir(parents=True, exist_ok=True)

    # Write template
    template = create_secrets_template(generate_passwords=generate_passwords)
    secrets_file.write_text(template, encoding="utf-8")

    # Restrict permissions to owner only
    try:
        secrets_file.chmod(0o600)
        if debug:
            print(f"DEBUG: Created secrets file with restricted permissions: {secrets_file}", file=sys.stderr)
    except Exception as e:
        print(f"Warning: Could not set file permissions: {e}", file=sys.stderr)

    print(f"Created secrets template: {secrets_file}", file=sys.stderr)
    if generate_passwords:
        print(f"Generated secure passwords (review: cat {secrets_file})", file=sys.stderr)
    print(f"Please edit {secrets_file} and add your API credentials", file=sys.stderr)

    return secrets_file


def export_env_file(debug: bool = False) -> Path:
    """
    Export secrets to Docker Compose .env file.

    Converts secrets (YAML) to .env format suitable for `docker compose`.
    Docker Compose will automatically load this file and make variables available.

    Priority order for output location:
    1. $RUN_CLAUDE_HOME/.env (if set)
    2. $XDG_CONFIG_HOME/run-claude/.env (if set)
    3. ~/.config/run-claude/.env (default)

    Args:
        debug: Enable debug output

    Returns the path to the generated .env file.
    """
    # Check RUN_CLAUDE_HOME first (allows custom installation directory)
    run_claude_home = os.environ.get("RUN_CLAUDE_HOME")
    if run_claude_home:
        env_file = Path(run_claude_home) / ".env"
    else:
        # Fall back to XDG_CONFIG_HOME
        xdg_config = os.environ.get("XDG_CONFIG_HOME")
        if xdg_config:
            base = Path(xdg_config)
        else:
            base = Path.home() / ".config"
        env_file = base / "run-claude" / ".env"

    if debug:
        print(f"DEBUG: Exporting secrets to env file: {env_file}", file=sys.stderr)

    try:
        secrets = load_secrets(debug=debug)
        env_vars = secrets.to_env()

        # Write .env file - Docker Compose will expand variables automatically
        lines = [f"{key}={value}" for key, value in env_vars.items()]
        env_file.write_text("\n".join(lines) + "\n", encoding="utf-8")

        # Restrict permissions for .env file too
        try:
            env_file.chmod(0o600)
            if debug:
                print(f"DEBUG: Created .env file with restricted permissions", file=sys.stderr)
        except Exception as e:
            print(f"Warning: Could not set .env file permissions: {e}", file=sys.stderr)

        if debug:
            print(f"DEBUG: Exported {len(env_vars)} secrets to .env", file=sys.stderr)

        return env_file

    except Exception as e:
        print(f"Error exporting secrets: {e}", file=sys.stderr)
        raise
