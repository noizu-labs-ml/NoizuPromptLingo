# PRD: Automatic Infrastructure Management

## Overview

Automatically manage the TimescaleDB container lifecycle alongside the LiteLLM proxy, eliminating the need for manual `docker compose` commands.

## Problem Statement

Currently, users must manually start the PostgreSQL/TimescaleDB container before running `run-claude proxy start`:

```bash
cd dep/
docker compose up -d
cd ..
run-claude proxy start
```

This creates friction and confusion:
- Users forget to start the database
- Proxy fails with cryptic database connection errors
- No unified lifecycle management
- Infrastructure files live in the source tree, not user space

## Goals

1. **Zero-touch database management** - Proxy start/stop handles database automatically
2. **User-space installation** - Infrastructure files deployed to `~/.local/state/run-claude/dep/`
3. **Graceful degradation** - Clear errors if Docker unavailable
4. **Idempotent operations** - Safe to run multiple times

## Non-Goals

- Multi-node/cluster deployments
- Database migration management (handled by LiteLLM/Prisma)
- Custom database configurations beyond what's in compose file

## User Stories

### US-1: First-time Setup
**As a** new user
**I want** infrastructure to be installed automatically
**So that** I don't need to copy files manually

**Acceptance Criteria:**
- `run-claude install` copies compose files to state directory
- `.env` file generated from secrets
- Directory structure created if missing

### US-2: Start Proxy with Database
**As a** developer
**I want** `run-claude proxy start` to start the database if needed
**So that** I have a single command to launch everything

**Acceptance Criteria:**
- Check if `run-claude-timescaledb` container is running
- If not running, start it via `docker compose up -d`
- Wait for database health check before starting proxy
- Clear error message if Docker not available

### US-3: Stop Proxy with Database
**As a** developer
**I want** `run-claude proxy stop` to optionally stop the database
**So that** I can free resources when done

**Acceptance Criteria:**
- `proxy stop` stops proxy process
- `proxy stop --with-db` also stops the database container
- `proxy stop --all` stops both and removes the container
- Database persists by default (data not lost)

### US-4: Status Check
**As a** developer
**I want** `run-claude proxy status` to show database status
**So that** I can see the full system state

**Acceptance Criteria:**
- Shows proxy status (running/stopped, PID, health)
- Shows database status (running/stopped, container ID)
- Shows connection test result

## Technical Design

### File Locations

```
~/.local/state/run-claude/
├── dep/
│   ├── docker-compose.yaml      # Copied from package
│   └── config/
│       └── timescaledb/
│           └── init-databases.sql
├── state.json
├── proxy.pid
├── proxy.log
└── litellm_config.yaml
```

The `.env` file is loaded from config directory (existing behavior):
```
~/.config/run-claude/.env
```

### Installation Flow

```python
def install_infrastructure(force: bool = False) -> None:
    """Install docker-compose files to state directory."""
    state_dir = get_state_dir()
    dep_dir = state_dir / "dep"

    # Check if already installed
    if (dep_dir / "docker-compose.yaml").exists() and not force:
        return

    # Copy from package
    pkg_dep = Path(__file__).parent.parent / "dep"
    shutil.copytree(pkg_dep, dep_dir, dirs_exist_ok=True)

    # Ensure .env exists
    ensure_env_file()
```

### Container Management

```python
def is_db_container_running() -> bool:
    """Check if TimescaleDB container is running."""
    result = subprocess.run(
        ["docker", "inspect", "-f", "{{.State.Running}}", "run-claude-timescaledb"],
        capture_output=True, text=True
    )
    return result.returncode == 0 and result.stdout.strip() == "true"

def start_db_container(wait: bool = True) -> bool:
    """Start the TimescaleDB container."""
    dep_dir = get_state_dir() / "dep"
    env_file = get_config_dir() / ".env"

    result = subprocess.run(
        ["docker", "compose", "-f", str(dep_dir / "docker-compose.yaml"),
         "--env-file", str(env_file), "up", "-d"],
        capture_output=True, text=True
    )

    if result.returncode != 0:
        return False

    if wait:
        return wait_for_db_healthy()
    return True

def stop_db_container(remove: bool = False) -> bool:
    """Stop the TimescaleDB container."""
    dep_dir = get_state_dir() / "dep"

    cmd = ["docker", "compose", "-f", str(dep_dir / "docker-compose.yaml")]
    if remove:
        cmd.extend(["down", "-v"])  # Remove volumes too
    else:
        cmd.append("stop")

    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0
```

### Updated Proxy Start

```python
def start_proxy(...) -> bool:
    # Ensure infrastructure is installed
    install_infrastructure()

    # Start database if not running
    if not is_db_container_running():
        print("Starting database container...")
        if not start_db_container(wait=True):
            print("ERROR: Failed to start database container", file=sys.stderr)
            print("Is Docker running?", file=sys.stderr)
            return False

    # Existing proxy start logic...
    generate_litellm_config(...)
    # ...
```

### Updated Proxy Stop

```python
def cmd_proxy_stop(args) -> int:
    # Stop proxy
    stop_proxy()

    # Optionally stop database
    if args.with_db or args.all:
        print("Stopping database container...")
        stop_db_container(remove=args.all)

    return 0
```

### CLI Changes

```
run-claude proxy start [--no-db]       # Start proxy (and db if needed)
run-claude proxy stop [--with-db]      # Stop proxy (optionally db)
run-claude proxy stop --all            # Stop everything, remove containers
run-claude proxy status                # Show proxy + db status

run-claude install [--force]           # Install/reinstall infrastructure
run-claude db start                    # Start database only
run-claude db stop                     # Stop database only
run-claude db status                   # Database status only
```

## API Changes

### New Functions in `proxy.py`

| Function | Purpose |
|----------|---------|
| `install_infrastructure(force)` | Copy compose files to state dir |
| `is_db_container_running()` | Check container status |
| `start_db_container(wait)` | Start container, optionally wait for health |
| `stop_db_container(remove)` | Stop container, optionally remove |
| `wait_for_db_healthy(timeout)` | Wait for pg_isready |
| `get_db_status()` | Return DbStatus dataclass |

### New Dataclass

```python
@dataclass
class DbStatus:
    installed: bool          # Compose files present
    container_exists: bool   # Container created
    running: bool            # Container running
    healthy: bool            # Health check passing
    container_id: str | None
```

### Updated `ProxyStatus`

```python
@dataclass
class ProxyStatus:
    running: bool
    pid: int | None
    healthy: bool
    url: str
    model_count: int
    db_healthy: bool
    db_status: DbStatus | None  # NEW
```

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Docker not installed | Error: "Docker not found. Please install Docker." |
| Docker not running | Error: "Docker daemon not running. Please start Docker." |
| Compose files missing | Auto-install, then retry |
| Container fails to start | Error with docker logs excerpt |
| Database unhealthy after timeout | Error: "Database failed to become healthy" |
| Port 5433 in use | Error: "Port 5433 already in use" |

## Migration Path

### Existing Users

1. Run `run-claude install --force` to deploy compose files
2. Existing `dep/` directory in source tree remains for development
3. State directory takes precedence for runtime

### New Users

1. `run-claude secrets init` (existing)
2. `run-claude secrets export` (existing)
3. `run-claude proxy start` (auto-installs infrastructure)

## Testing Plan

### Unit Tests

- `test_is_db_container_running_true`
- `test_is_db_container_running_false`
- `test_install_infrastructure_creates_files`
- `test_install_infrastructure_idempotent`
- `test_start_db_container_success`
- `test_start_db_container_docker_not_found`

### Integration Tests

- Start proxy with database not running → database starts
- Start proxy with database running → database stays
- Stop proxy → database stays running
- Stop proxy --with-db → database stops
- Stop proxy --all → container removed

### Manual Testing

```bash
# Clean state
rm -rf ~/.local/state/run-claude/dep
docker rm -f run-claude-timescaledb

# Test auto-install and start
run-claude proxy start
run-claude proxy status  # Should show db running

# Test stop without db
run-claude proxy stop
docker ps | grep timescaledb  # Should still be running

# Test stop with db
run-claude proxy start
run-claude proxy stop --with-db
docker ps | grep timescaledb  # Should not be running
```

## Rollout Plan

1. **Phase 1**: Add infrastructure management functions (no CLI changes)
2. **Phase 2**: Integrate into `proxy start/stop`
3. **Phase 3**: Add `--no-db`, `--with-db`, `--all` flags
4. **Phase 4**: Add `run-claude db` subcommand
5. **Phase 5**: Update documentation

## Open Questions

1. **Volume management**: Should `proxy stop --all` remove the data volume? (Proposed: Yes, with warning)
2. **Multiple instances**: Support for named instances? (Proposed: Out of scope)
3. **External database**: Flag to skip container management for external DB? (Proposed: `--external-db`)

## Success Metrics

- Zero manual docker commands required for basic usage
- Clear error messages when Docker unavailable
- No data loss from normal stop operations
- Sub-5-second startup when database already running
