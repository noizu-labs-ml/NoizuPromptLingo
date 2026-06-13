# Secrets Configuration Guide

This guide explains how to manage secrets (API keys, database passwords, etc.) for the run-claude project using the configuration system.

## Overview

run-claude uses a centralized secrets management system:
- **Secrets file**: `~/.config/run-claude/.secrets` or `$RUN_CLAUDE_HOME/.secrets` (YAML format)
- **Environment export**: `~/.config/run-claude/.env` or `$RUN_CLAUDE_HOME/.env` (auto-loaded by Docker)
- **Secure by default**: Files are created with `0600` permissions (owner read/write only)
- **Never committed**: Secrets are excluded from version control
- **Zero-config Docker**: Docker Compose automatically loads secrets without --env-file flag

## Setup

### 1. Initialize Secrets Template

```bash
run-claude secrets init
```

This creates `~/.config/run-claude/.secrets` with a template containing common secrets:

```yaml
# run-claude Secrets Configuration
# Location: ~/.config/run-claude/.secrets
# Permissions: chmod 600 (owner read/write only)
#
# WARNING: This file contains sensitive information!
# - Never commit to version control
# - Restrict file permissions to owner only
# - Keep backups in secure location

# Database credentials
RUN_CLAUDE_TIMESCALEDB_PASSWORD: "your-postgres-password"

# API credentials
ANTHROPIC_API_KEY: "your-api-key"

# Other secrets as needed
# EXAMPLE_SECRET: "value"
```

### 2. Edit Secrets File

Edit `~/.config/run-claude/.secrets` with your actual values:

```bash
nano ~/.config/run-claude/.secrets
```

Replace placeholder values with your actual credentials:
- `RUN_CLAUDE_TIMESCALEDB_PASSWORD`: Your PostgreSQL password
- `ANTHROPIC_API_KEY`: Your Anthropic API key
- Add any other secrets needed by your deployment

### 3. Verify File Permissions

Ensure the secrets file is only readable by your user:

```bash
ls -la ~/.config/run-claude/.secrets
# Should show: -rw------- (0600)
```

If permissions are wrong, fix them:

```bash
chmod 600 ~/.config/run-claude/.secrets
```

## Usage

### With Python Application

Load secrets in your Python code:

```python
from run_claude.config import load_secrets

# Load all secrets
secrets = load_secrets()

# Access specific secret
password = secrets["RUN_CLAUDE_TIMESCALEDB_PASSWORD"]

# Or use get() with default
token = secrets.get("ANTHROPIC_API_KEY", "default-key")

# Convert to environment variables dict
env_vars = secrets.to_env()
```

### With Docker Compose

#### Automatic Loading (Zero Config)

Docker Compose automatically loads secrets from the standard location:

```bash
# 1. Ensure secrets are exported
run-claude secrets export

# 2. Start Docker - .env is automatically loaded from ~/.config/run-claude/.env
cd dep
docker compose up -d
```

No `--env-file` flag needed! Docker Compose automatically loads from:
1. `$RUN_CLAUDE_HOME/.env` (if RUN_CLAUDE_HOME is set)
2. `~/.config/run-claude/.env` (default location)

#### Custom Location (Optional)

To use a custom secrets location:

```bash
export RUN_CLAUDE_HOME="/path/to/config"
run-claude secrets export
docker compose up -d
```

#### Manual Environment Variables (Alternative)

Pass secrets directly without using .env file:

```bash
export RUN_CLAUDE_TIMESCALEDB_PASSWORD="your-password"
cd dep
docker compose up -d
```

### With direnv

If using direnv, create `.envrc` in your project:

```bash
#!/bin/bash
# Load secrets from run-claude config
SECRETS_FILE="$HOME/.config/run-claude/.secrets"
if [ -f "$SECRETS_FILE" ]; then
    eval "$(python3 -c "
from pathlib import Path
import yaml
secrets = yaml.safe_load(Path('$SECRETS_FILE').read_text())
for k, v in secrets.items():
    print(f'export {k}=\"{v}\"')
")"
fi
```

Then:
```bash
direnv allow
```

## Security Best Practices

### 1. File Permissions
- Secrets file is created with `0600` (owner only)
- Always verify permissions: `chmod 600 ~/.config/run-claude/.secrets`
- Never make the file world-readable

### 2. Backup Strategy
- Keep encrypted backups of secrets
- Store backups separate from source code
- Use a password manager for backup encryption keys

### 3. Secret Rotation
- Regularly rotate API keys and passwords
- Update secrets file and re-export for Docker
- Consider automated rotation for critical secrets

### 4. Access Control
- Only share secrets with authorized users
- Use separate credentials for different environments (dev/staging/prod)
- Never log or print secrets

### 5. Source Control
The `.secrets` and `.env` files are automatically excluded from version control. Verify in `.gitignore`:

```bash
cat .gitignore | grep -E '\.secrets|\.env'
```

## Common Secrets

### Database Credentials
```yaml
RUN_CLAUDE_TIMESCALEDB_PASSWORD: "your-secure-password"
RUN_CLAUDE_TIMESCALEDB_USER: "postgres"
RUN_CLAUDE_TIMESCALEDB_HOST: "timescaledb"
RUN_CLAUDE_TIMESCALEDB_PORT: "5432"
```

### API Keys
```yaml
ANTHROPIC_API_KEY: "sk-..."
OPENAI_API_KEY: "sk-..."
CUSTOM_API_KEY: "..."
```

### Webhook Secrets
```yaml
WEBHOOK_SECRET: "your-webhook-secret"
```

## CLI Commands

### View Secrets File Path
```bash
run-claude secrets path
# Outputs: /home/user/.config/run-claude/.secrets
```

### Initialize/Reset Template
```bash
run-claude secrets init          # Interactive (skips if exists)
run-claude secrets init --force  # Overwrite existing
```

### Export for Docker
```bash
run-claude secrets export
# Outputs: /home/user/.config/run-claude/.env
# Shows Docker command to use the exported file
```

## Troubleshooting

### Secrets file not found
```
Error: Secrets file not found
```
**Solution**: Run `run-claude secrets init` to create the template.

### Permission denied
```
Permission denied: /home/user/.config/run-claude/.secrets
```
**Solution**: Check file permissions with `ls -la` and fix with `chmod 600`.

### Docker Compose not loading secrets
```
database error: RUN_CLAUDE_TIMESCALEDB_PASSWORD not set
```
**Solution**:
1. Verify secrets file exists: `run-claude secrets path`
2. Export to .env: `run-claude secrets export`
3. Use --env-file flag: `docker compose --env-file ~/.config/run-claude/.env up -d`

### YAML parsing error
```
Error loading secrets from ...: ...
```
**Solution**: Verify YAML syntax in ~/.config/run-claude/.secrets. Valid YAML example:
```yaml
KEY1: "value1"
KEY2: "value2"
KEY3: 12345  # Numbers work too
```

## Integration with CI/CD

For CI/CD pipelines, use environment variables or secrets management services:

**GitHub Actions Example:**
```yaml
env:
  RUN_CLAUDE_TIMESCALEDB_PASSWORD: ${{ secrets.DB_PASSWORD }}
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

**GitLab CI Example:**
```yaml
variables:
  RUN_CLAUDE_TIMESCALEDB_PASSWORD: $DB_PASSWORD
  ANTHROPIC_API_KEY: $ANTHROPIC_API_KEY
```

## Project Structure

```
~/.config/run-claude/
├── .secrets           # YAML secrets (owner read/write only)
├── .env              # Exported environment variables (auto-generated)
├── profiles.yaml     # User profiles
├── models.yaml       # Model definitions
└── .initialized      # Marker file for first-run setup
```

## Next Steps

1. Initialize secrets: `run-claude secrets init`
2. Edit the file: `nano ~/.config/run-claude/.secrets`
3. For Docker: `run-claude secrets export`
4. Start services: `docker compose --env-file ~/.config/run-claude/.env up -d`
