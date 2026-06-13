# Secrets Management - Advanced Features

This guide covers advanced features for managing secrets in run-claude: password generation, environment variable expansion, and distinguishing required vs optional variables.

## Overview

The enhanced secrets system provides:
- **Password Generation**: Cryptographically secure random password generation
- **Environment Variable Expansion**: Substitute variables at export time
- **Variable Documentation**: Clear distinction between required and optional variables
- **Smart Defaults**: Optional variables can be commented out to use Docker defaults

## Quick Commands

```bash
# Initialize with auto-generated secure password
run-claude secrets init --generate

# Export secrets with environment variable expansion
run-claude secrets export
```

## Required vs Optional Variables

### Required Variables (MUST BE SET)

These variables **must** have values and cannot be commented out:

```yaml
# Database password - REQUIRED
# Must be a strong, secure password
RUN_CLAUDE_TIMESCALEDB_PASSWORD: "your-secure-password"

# API token - REQUIRED
# Get from: https://console.anthropic.com/api_keys
ANTHROPIC_API_KEY: "sk-..."
```

**If these are missing or empty**: Docker Compose will fail to start.

### Optional Variables (Can Use Defaults)

These variables have default values in Docker Compose. Comment them out to use defaults, or uncomment to override:

```yaml
# Database user (default: postgres)
# RUN_CLAUDE_TIMESCALEDB_USER: "postgres"

# Database host (default: timescaledb)
# RUN_CLAUDE_TIMESCALEDB_HOST: "timescaledb"

# Database port (default: 5432)
# RUN_CLAUDE_TIMESCALEDB_PORT: "5432"
```

**When commented out**: Docker uses the default value from docker-compose.yaml
**When uncommented**: Your value overrides the default

## Password Generation

### Generate Secure Passwords

Generate a new secrets file with auto-generated passwords:

```bash
run-claude secrets init --generate
```

This creates `~/.config/run-claude/.secrets` with:
- Random 32-character database password
- Placeholder for API token (still needs to be filled manually)

### Password Strength

Generated passwords include:
- Lowercase letters (a-z)
- Uppercase letters (A-Z)
- Numbers (0-9)
- Special characters (!@#$%^&*)
- Minimum 32 characters

Example generated password:
```
ypHmiTgCMH#nOpXooYcqnTcMUI8LItn5
```

### Manual Password Reset

To regenerate passwords:

```bash
run-claude secrets init --generate --force
```

⚠️ **Warning**: This will overwrite your existing secrets file. Make a backup first if needed.


## Workflow Example: Complete Setup

### Step 1: Generate with Passwords

```bash
$ run-claude secrets init --generate
Created secrets template: ~/.config/run-claude/.secrets
Generated secure passwords (review: cat ~/.config/run-claude/.secrets)
Please edit ~/.config/run-claude/.secrets and add your API credentials
```

### Step 2: Review Generated Password

```bash
$ grep EVAL_TIMESCALEDB ~/.config/run-claude/.secrets
RUN_CLAUDE_TIMESCALEDB_PASSWORD: "ypHmiTgCMH#nOpXooYcqnTcMUI8LItn5"
```

### Step 3: Edit to Add API Token

```bash
$ nano ~/.config/run-claude/.secrets
```

Edit this section:
```yaml
ANTHROPIC_API_KEY: "sk-your-token-here"
```

To:
```yaml
ANTHROPIC_API_KEY: "sk-ant-v7-actual-token-here"
```

### Step 4: Export Secrets to .env

```bash
$ run-claude secrets export
Exported secrets to: ~/.config/run-claude/.env
```

### Step 5: Verify .env File

```bash
$ cat ~/.config/run-claude/.env
RUN_CLAUDE_TIMESCALEDB_PASSWORD=ypHmiTgCMH#nOpXooYcqnTcMUI8LItn5
ANTHROPIC_API_KEY=sk-ant-v7-actual-token-here
```

### Step 6: Start Docker

```bash
$ cd dep
$ docker compose up -d
```

Docker automatically loads `~/.config/run-claude/.env` and provides variables to containers.

## CLI Commands Reference

### Initialize Secrets

```bash
# Create template (interactive)
run-claude secrets init

# Create with generated passwords
run-claude secrets init --generate

# Overwrite existing (dangerous!)
run-claude secrets init --force

# Overwrite with new passwords
run-claude secrets init --generate --force
```

### Show Path

```bash
# Show where secrets file is located
run-claude secrets path
/home/user/.config/run-claude/.secrets
```

### Export Secrets

```bash
# Export with variable expansion (default)
run-claude secrets export

# Debug mode - show expanded variables
run-claude secrets export --debug
```

## Advanced Scenarios

### Custom Installation Directory

Use `RUN_CLAUDE_HOME` to override default location:

```bash
export RUN_CLAUDE_HOME=/opt/run-claude
run-claude secrets init --generate
nano $RUN_CLAUDE_HOME/.secrets
run-claude secrets export
# Secrets are now in $RUN_CLAUDE_HOME/.secrets and $RUN_CLAUDE_HOME/.env
```

### Multiple Environments

Create separate secret files for different environments:

```bash
# Development
RUN_CLAUDE_HOME=~/.run-claude-dev run-claude secrets init --generate

# Production
RUN_CLAUDE_HOME=/opt/run-claude-prod run-claude secrets init --generate
```

### CI/CD Integration

Export to `.env` in CI and commit to secure storage:

```bash
# In CI pipeline
run-claude secrets export
# .env file ready for docker compose
```

### Using with direnv

Create `.envrc` to load secrets:

```bash
#!/bin/bash
export $(grep -v '^#' ~/.config/run-claude/.env | xargs)
```

Then:
```bash
direnv allow
```

## Troubleshooting

### Password Not Generated

**Issue**: Template created without password
```
RUN_CLAUDE_TIMESCALEDB_PASSWORD: "your-postgres-password"
```

**Solution**: Regenerate with `--generate` flag:
```bash
run-claude secrets init --generate --force
```

### Variables Not Expanding

**Issue**: Expanded `.env` still contains `${VAR}` syntax

**Solution**: Check if variable is set at export time:
```bash
echo $HOME  # Should output your home directory
run-claude secrets export --debug  # Shows expansion details
```

### Wrong Default Used

**Issue**: Comment shows `default: postgres` but you need something else

**Solution**: Uncomment the optional variable and set your value:
```yaml
# Was commented (uses default postgres):
# RUN_CLAUDE_TIMESCALEDB_USER: "postgres"

# Now active (uses your value):
RUN_CLAUDE_TIMESCALEDB_USER: "myuser"
```

## Security Considerations

### Password Storage

- Generated passwords are **not stored** elsewhere
- Review and save the password when generated
- Keep backups in secure location (encrypted)
- Never share or commit `.secrets` file

### Environment Variable Expansion

- Variables are expanded at **export time** (when you run the command)
- Expanded values are written to `.env`
- Ensure sensitive environment variables are protected

### Secrets File Permissions

All secrets files created with `0600` permissions:
```bash
-rw------- (owner only read/write)
```

Verify:
```bash
ls -la ~/.config/run-claude/.secrets
```

## Reference: All Variables

### Database Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `RUN_CLAUDE_TIMESCALEDB_PASSWORD` | **Required** | None | PostgreSQL password (must be strong) |
| `RUN_CLAUDE_TIMESCALEDB_USER` | Optional | `postgres` | PostgreSQL username |
| `RUN_CLAUDE_TIMESCALEDB_HOST` | Optional | `timescaledb` | Database hostname |
| `RUN_CLAUDE_TIMESCALEDB_PORT` | Optional | `5432` | Database port number |

### API Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ANTHROPIC_API_KEY` | **Required** | None | Anthropic API key |

### Custom Variables

You can add any custom variables needed by your application. Examples:

```yaml
# Application settings
LOG_LEVEL: "info"
DEBUG: "false"

# External services
REDIS_URL: "${REDIS_HOST:-localhost}:6379"
API_TIMEOUT: "30"
```

## Next Steps

- Start with: `run-claude secrets init --generate`
- Read: [SECRETS.md](SECRETS.md) for basic usage
- Explore: [SECRETS_QUICKSTART.md](SECRETS_QUICKSTART.md) for quick reference
