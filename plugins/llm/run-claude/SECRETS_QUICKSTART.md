# Secrets Management - Quick Start

## 30-Second Setup (with Generated Passwords)

```bash
# 1. Initialize with auto-generated secure password
run-claude secrets init --generate

# 2. Edit to add your API token
nano ~/.config/run-claude/.secrets

# 3. Set your credentials:
# ANTHROPIC_API_KEY: "sk-your-real-token"

# 4. Export for Docker (expands environment variables)
run-claude secrets export

# 5. Start Docker (automatically loads secrets - no flags needed!)
cd dep
docker compose up -d
```

## Alternative: Manual Setup

```bash
# 1. Create template (no password generation)
run-claude secrets init

# 2. Edit and add both password and token
nano ~/.config/run-claude/.secrets

# 3. Continue with export and docker compose up
```

## File Locations

```bash
~/.config/run-claude/.secrets    # Your YAML secrets (0600 perms, never commit)
~/.config/run-claude/.env       # Auto-generated for Docker (0600 perms)
```

## CLI Commands

| Command | Purpose |
|---------|---------|
| `run-claude secrets init` | Create secrets template |
| `run-claude secrets path` | Show secrets file location |
| `run-claude secrets export` | Generate .env for Docker |

## Secrets File Format (YAML)

### Required Variables (MUST be set)
```yaml
# Database password - REQUIRED
# Generate with: run-claude secrets init --generate
RUN_CLAUDE_TIMESCALEDB_PASSWORD: "your-postgres-password"

# API key - REQUIRED
# Get from: https://console.anthropic.com/api_keys
ANTHROPIC_API_KEY: "sk-..."
```

### Optional Variables (Uncomment to override defaults)
```yaml
# Database user (default: postgres)
# RUN_CLAUDE_TIMESCALEDB_USER: "postgres"

# Database host (default: timescaledb)
# RUN_CLAUDE_TIMESCALEDB_HOST: "timescaledb"

# Database port (default: 5432)
# RUN_CLAUDE_TIMESCALEDB_PORT: "5432"
```

### Custom Variables
```yaml
# Add any custom variables needed by your application
LOG_LEVEL: "info"
DEBUG: "false"
```

## Docker Usage

```bash
# Export secrets
run-claude secrets export

# Start Docker (automatically loads .env from standard location)
cd dep
docker compose up -d
```

Docker Compose automatically loads from `~/.config/run-claude/.env` or `$RUN_CLAUDE_HOME/.env`

## Python Usage

```python
from run_claude.config import load_secrets

secrets = load_secrets()

# Access by key
password = secrets["RUN_CLAUDE_TIMESCALEDB_PASSWORD"]

# Or use get with default
token = secrets.get("ANTHROPIC_API_KEY", "default")

# Convert to environment variables dict
env_vars = secrets.to_env()
```

## Security Notes

- ✓ Files created with `0600` permissions (owner only)
- ✓ Never committed to version control
- ✓ Template auto-created on first run
- ✓ Always use absolute paths
- ✓ Keep encrypted backups separately

## Advanced Features

### Generate Secure Passwords
```bash
run-claude secrets init --generate
```
Creates random 32-character password with mixed case, numbers, and symbols.

### Override Defaults
Uncomment optional variables to override Docker defaults:
```yaml
# This overrides the default "timescaledb"
RUN_CLAUDE_TIMESCALEDB_HOST: "db.example.com"
```

### Custom Variables
Add any additional variables needed by your application. Docker will make them available to containers.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Secrets not found | Run `run-claude secrets init` |
| No password generated | Use `--generate` flag: `run-claude secrets init --generate` |
| Permission denied | Check `chmod 600 ~/.config/run-claude/.secrets` |
| Docker can't find .env | Run `run-claude secrets export` first |
| Variables not in container | Verify .env file exists: `ls -la ~/.config/run-claude/.env` |

## Documentation

| File | Purpose |
|------|---------|
| [SECRETS.md](SECRETS.md) | Complete guide with all examples |
| [SECRETS_ADVANCED.md](SECRETS_ADVANCED.md) | Advanced features and scenarios |
| This file | Quick reference for common tasks |
