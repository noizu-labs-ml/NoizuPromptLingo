#!/usr/bin/env python3
"""
run-claude - Agent shim controller for Claude.

Directory-aware model routing via LiteLLM proxy.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import sys
import time
from pathlib import Path


def main() -> int:
    # Ensure config is initialized on first run
    from . import profiles, config
    from . import __version__
    profiles.ensure_initialized()

    # Ensure secrets template exists
    debug = "--debug" in sys.argv or "-d" in sys.argv
    config.ensure_secrets_template(debug=debug)

    parser = argparse.ArgumentParser(
        prog="run-claude",
        description="Agent shim controller for Claude - launch claude with mode list profile",
    )
    parser.add_argument("--version", "-V", action="version", version=f"%(prog)s {__version__}")
    parser.add_argument("--debug", "-d", action="store_true", help="Enable debug output")
    parser.add_argument("--enhanced", "-x", action="store_true", help="Shorthand for: run-claude with claude-enhanced")
    parser.add_argument("--kitchen-sink", "-xx", dest="kitchen_sink", action="store_true", help="Shorthand for: run-claude with kitchen-sink (every provider)")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # enter
    enter_p = subparsers.add_parser("enter", help="Enter a shimmed directory")
    enter_p.add_argument("token", help="Directory token")
    enter_p.add_argument("profile", help="Profile name")
    enter_p.add_argument("--dir", help="Directory path (default: cwd)")
    enter_p.add_argument("--refresh", action="store_true", help="Force reload model definitions and re-register with proxy")

    # leave
    leave_p = subparsers.add_parser("leave", help="Leave a shimmed directory")
    leave_p.add_argument("token", help="Directory token")

    # janitor
    janitor_p = subparsers.add_parser("janitor", help="Clean up expired leases")
    janitor_p.add_argument("--quiet", "-q", action="store_true", help="Suppress output")
    janitor_p.add_argument("--force", "-f", action="store_true", help="Run even if recently ran")

    # set-folder
    setfolder_p = subparsers.add_parser("set-folder", help="Configure current directory")
    setfolder_p.add_argument("profile", help="Profile name")
    setfolder_p.add_argument("--dir", help="Directory path (default: cwd)")

    # status
    status_p = subparsers.add_parser("status", help="Show current state")
    status_p.add_argument("--health", action="store_true", help="Show formatted health endpoint response")

    # env
    env_p = subparsers.add_parser("env", help="Print environment variables for a profile")
    env_p.add_argument("profile", help="Profile name")
    env_p.add_argument("--export", "-e", action="store_true", help="Print export statements")

    # proxy subcommands
    proxy_p = subparsers.add_parser("proxy", help="Proxy management")
    proxy_sub = proxy_p.add_subparsers(dest="proxy_command")
    proxy_start_p = proxy_sub.add_parser("start", help="Start proxy")
    proxy_start_p.add_argument("--no-db", action="store_true", help="Don't auto-start database container")
    proxy_stop_p = proxy_sub.add_parser("stop", help="Stop proxy")
    proxy_stop_p.add_argument("--with-db", action="store_true", help="Also stop database container")
    proxy_stop_p.add_argument("--all", action="store_true", help="Stop everything and remove containers")
    proxy_restart_p = proxy_sub.add_parser("restart", help="Restart proxy (stop + start)")
    proxy_restart_p.add_argument("--no-db", action="store_true", help="Don't auto-start database container")
    proxy_supervise_p = proxy_sub.add_parser("supervise", help="(deprecated: use 'watchdog start') Run proxy in foreground, auto-restarting until stopped")
    proxy_supervise_p.add_argument("--no-db", action="store_true", help="Don't auto-start database container")
    proxy_supervise_p.add_argument("--interval", type=float, default=5.0, help="Seconds between liveness checks (default: 5)")
    proxy_sub.add_parser("status", help="Proxy status")
    proxy_sub.add_parser("health", help="Health check")
    proxy_sub.add_parser("db-test", help="Test database connection")

    # watchdog subcommands
    watchdog_p = subparsers.add_parser("watchdog", help="Proxy watchdog management (auto-restart on crash)")
    watchdog_sub = watchdog_p.add_subparsers(dest="watchdog_command")
    watchdog_start_p = watchdog_sub.add_parser("start", help="Start the watchdog daemon")
    watchdog_start_p.add_argument("--interval", type=float, default=5.0, help="Seconds between liveness checks (default: 5)")
    watchdog_stop_p = watchdog_sub.add_parser("stop", help="Stop the watchdog daemon")
    watchdog_stop_p.add_argument("--with-proxy", action="store_true", help="Also stop the proxies")
    watchdog_sub.add_parser("restart", help="Restart the watchdog daemon")
    watchdog_sub.add_parser("status", help="Show watchdog status")

    # db subcommands
    db_p = subparsers.add_parser("db", help="Database container management")
    db_sub = db_p.add_subparsers(dest="db_command")
    db_sub.add_parser("start", help="Start database container")
    db_stop_p = db_sub.add_parser("stop", help="Stop database container")
    db_stop_p.add_argument("--remove", "-r", action="store_true", help="Remove container and volumes")
    db_sub.add_parser("status", help="Database container status")
    db_sub.add_parser("migrate", help="Run prisma migrate with LiteLLM config")

    # profiles subcommands
    profiles_p = subparsers.add_parser("profiles", help="Profile management")
    profiles_sub = profiles_p.add_subparsers(dest="profiles_command")
    profiles_sub.add_parser("list", help="List available profiles")
    show_p = profiles_sub.add_parser("show", help="Show profile details")
    show_p.add_argument("name", help="Profile name")
    profiles_sub.add_parser("install", help="Create user profiles config template")

    # models subcommands
    models_p = subparsers.add_parser("models", help="Model definitions management")
    models_sub = models_p.add_subparsers(dest="models_command")
    models_sub.add_parser("list", help="List available model definitions")
    enabled_p = models_sub.add_parser("enabled", help="List models currently enabled (live in the running proxy)")
    enabled_p.add_argument("--names-only", action="store_true", help="Print only model names, one per line")
    show_model_p = models_sub.add_parser("show", help="Show model definition details")
    show_model_p.add_argument("name", help="Model name")
    avail_p = models_sub.add_parser("avail", help="Show enabled models with descriptions, strengths, and weaknesses")
    avail_p.add_argument("--json", dest="output_json", action="store_true", help="Output as JSON")
    avail_p.add_argument("--short", action="store_true", help="Compact one-line-per-model output")
    wipe_p = models_sub.add_parser("wipe", help="Delete all models from proxy database")
    wipe_p.add_argument("--force", "-f", action="store_true", help="Skip confirmation prompt")

    # keys - runtime named-key registry on go-litellm
    keys_p = subparsers.add_parser("keys", help="Runtime provider key swap (go-litellm)")
    keys_sub = keys_p.add_subparsers(dest="keys_command")
    keys_sub.add_parser("list", help="List named keys and live model bindings")
    add_key_p = keys_sub.add_parser("add", help="Add or replace a named key")
    add_key_p.add_argument("name", help="Short name (e.g. tyna, extra)")
    add_key_p.add_argument(
        "--env", "--from-env", dest="env",
        help="Read the value from this environment variable (and .secrets)",
    )
    add_key_p.add_argument(
        "--value",
        help="Literal key value (prefer --env; the value is not shown later)",
    )
    del_key_p = keys_sub.add_parser("delete", help="Remove a dynamically added named key")
    del_key_p.add_argument("name", help="Named key to delete")
    switch_p = keys_sub.add_parser(
        "switch",
        help="Bind a model family (or model) to a named key, e.g. switch zai tyna",
    )
    switch_p.add_argument("target", nargs="?", help="Family or model (e.g. zai, zai/opus)")
    switch_p.add_argument("key", nargs="?", help="Named key (e.g. tyna)")
    switch_p.add_argument(
        "--using",
        help="Rebind every model currently using this named key",
    )

    # chat - directly exercise an enabled model through the LiteLLM proxy
    chat_p = subparsers.add_parser("chat", help="Chat directly with an enabled model")
    chat_p.add_argument("model", nargs="?", help="Enabled model name (prompts when omitted)")
    chat_p.add_argument("--system", help="System prompt for the chat session")
    chat_p.add_argument("--prompt", help="Send one prompt and exit instead of opening a session")
    chat_p.add_argument(
        "--timeout",
        type=float,
        default=300.0,
        help="Request timeout in seconds (default: 300)",
    )

    # run - run a command with profile environment
    run_p = subparsers.add_parser("with", help="Run Claude with a profile")
    #run_p.add_argument("keyword", choices=["with"], help="Keyword 'with' to specify profile")
    run_p.add_argument("profile", help="Profile name")
    run_p.add_argument("cmd", nargs=argparse.REMAINDER, help="Command to run (default: claude)")
    run_p.add_argument("--refresh", action="store_true", help="Force reload model definitions and re-register with proxy")

    # install - create user config templates and infrastructure
    install_p = subparsers.add_parser("install", help="Create user config templates for profiles and models")
    install_p.add_argument("--force", "-f", action="store_true", help="Overwrite existing files")

    # secrets - manage secrets configuration
    secrets_p = subparsers.add_parser("secrets", help="Manage secrets configuration")
    secrets_sub = secrets_p.add_subparsers(dest="secrets_command")

    init_p = secrets_sub.add_parser("init", help="Initialize secrets template")
    init_p.add_argument("--generate", "-g", action="store_true", help="Generate random passwords")
    init_p.add_argument("--force", "-f", action="store_true", help="Overwrite existing secrets")

    secrets_sub.add_parser("path", help="Show secrets file path")
    secrets_sub.add_parser("export", help="Export secrets to .env file for docker compose")

    args = parser.parse_args()

    if args.kitchen_sink:
        args.command = "with"
        args.profile = "kitchen-sink"
        args.cmd = []
        args.refresh = False
    elif args.enhanced:
        args.command = "with"
        args.profile = "claude-enhanced"
        args.cmd = []
        args.refresh = False

    if args.command is None:
        parser.print_help()
        return 0

    # Dispatch
    if args.command == "enter":
        return cmd_enter(args)
    elif args.command == "leave":
        return cmd_leave(args)
    elif args.command == "janitor":
        return cmd_janitor(args)
    elif args.command == "set-folder":
        return cmd_set_folder(args)
    elif args.command == "status":
        return cmd_status(args)
    elif args.command == "env":
        return cmd_env(args)
    elif args.command == "proxy":
        return cmd_proxy(args)
    elif args.command == "watchdog":
        return cmd_watchdog(args)
    elif args.command == "db":
        return cmd_db(args)
    elif args.command == "profiles":
        return cmd_profiles(args)
    elif args.command == "models":
        return cmd_models(args)
    elif args.command == "keys":
        return cmd_keys(args)
    elif args.command == "chat":
        return cmd_chat(args)
    elif args.command == "with":
        return cmd_run(args)
    elif args.command == "install":
        return cmd_install(args)
    elif args.command == "secrets":
        return cmd_secrets(args)
    else:
        parser.print_help()
        return 1


def cmd_enter(args: argparse.Namespace) -> int:
    """Handle enter command."""
    from . import state, profiles, proxy

    debug = getattr(args, 'debug', False)
    refresh = getattr(args, 'refresh', False)
    token = args.token
    profile_name = args.profile
    directory = args.dir or os.getcwd()

    if refresh:
        print("[REFRESH] Clearing model/profile caches", file=sys.stderr)
        profiles.clear_caches()

    # Load profile
    profile = profiles.load_profile(profile_name, debug=debug)
    if profile is None:
        print(f"Error: Profile not found: {profile_name}", file=sys.stderr)
        return 1

    # Log profile selection and models
    print(f"[PROFILE_SELECTED] '{profile_name}' ({profile.meta.name})", file=sys.stderr)
    print(f"[MODELS_FOR_REGISTRATION] {len(profile.model_list)} models:", file=sys.stderr)
    for m in profile.model_list:
        print(f"  - {m.model_name}", file=sys.stderr)

    # Start front proxy (always-on for all profiles)
    if not proxy.is_front_proxy_running():
        proxy.start_front_proxy(wait=False)

    # Self-heal: ensure the watchdog daemon is alive. enter runs on every prompt
    # in a shimmed dir, so a crashed watchdog is re-spawned here. Cheap idempotent
    # PID check — no-op when already running.
    proxy.start_watchdog()

    # Ensure LiteLLM proxy is running with profile's models.
    # start_proxy handles all cases: not running → start; running but crashed/unhealthy → restart;
    # running and healthy → no-op. This prevents a hang when the process is alive but the HTTP
    # endpoint is down (previously we'd call ensure_models with wait_for_recovery=True and block
    # for up to 5 minutes).
    model_defs = [m.to_dict() for m in profile.model_list]
    config_path = str(proxy.generate_litellm_config(model_defs=model_defs)) if model_defs else None
    proxy_started = proxy.start_proxy(config_path=config_path)
    if not proxy_started:
        print("Warning: Failed to start proxy", file=sys.stderr)
    elif model_defs:
        # Proxy is confirmed healthy by start_proxy — add any missing models without a recovery wait
        added, skipped, failed = proxy.ensure_models(model_defs, debug=debug, wait_for_recovery=False, force=refresh)
        if debug and added > 0:
            print(f"Added {added} model(s) to proxy", file=sys.stderr)
        if failed > 0 and added == 0 and skipped == 0:
            print(f"Error: All {failed} model(s) failed to register", file=sys.stderr)
            return 1

    # Update state
    st = state.load_state()
    state.add_token(st, token, profile_name, directory)
    state.increment_models(st, profile.get_model_names())
    state.save_state(st)

    return 0


def cmd_leave(args: argparse.Namespace) -> int:
    """Handle leave command."""
    from . import state, profiles

    debug = getattr(args, 'debug', False)
    token = args.token

    st = state.load_state()
    token_info = state.get_token(st, token)

    if token_info is None:
        # Token not found, nothing to do
        return 0

    # Load profile to get model names
    profile = profiles.load_profile(token_info.profile, debug=debug)
    if profile:
        state.decrement_models(st, profile.get_model_names())

    state.remove_token(st, token)
    state.save_state(st)

    return 0


def cmd_janitor(args: argparse.Namespace) -> int:
    """Handle janitor command."""
    from . import state, proxy

    st = state.load_state()

    # Rate limit: only run once per minute unless forced
    if not args.force:
        if time.time() - st.last_janitor_run < 60:
            return 0

    st.last_janitor_run = time.time()

    # Find expired leases
    expired = state.get_expired_leases(st)

    if not expired:
        state.save_state(st)
        return 0

    # Delete expired models from proxy
    deleted = 0
    for model in expired:
        if proxy.delete_model(model):
            state.clear_lease(st, model)
            deleted += 1
            if not args.quiet:
                print(f"Deleted model: {model}")

    state.save_state(st)

    if not args.quiet and deleted > 0:
        print(f"Janitor: deleted {deleted} expired model(s)")

    return 0


def cmd_set_folder(args: argparse.Namespace) -> int:
    """Handle set-folder command."""
    from . import profiles

    debug = getattr(args, 'debug', False)
    profile_name = args.profile
    directory = Path(args.dir) if args.dir else Path.cwd()

    # Verify profile exists
    profile = profiles.load_profile(profile_name, debug=debug)
    if profile is None:
        print(f"Error: Profile not found: {profile_name}", file=sys.stderr)
        return 1

    # Generate token from canonical path
    canonical = directory.resolve()
    token = hashlib.sha256(str(canonical).encode()).hexdigest()[:16]

    envrc_path = directory / ".envrc"
    envrc_user_path = directory / ".envrc.user"
    gitignore_path = directory / ".gitignore"

    created_envrc = False

    # Create .envrc if missing
    if not envrc_path.exists():
        envrc_content = f'''# Claude Switch - Auto-generated
# Edit .envrc.user for customization (gitignored)

# Stable token for this directory
export AGENT_SHIM_TOKEN="{token}"

# Load user customizations
source_env_if_exists .envrc.user

# Apply shim configuration
if [[ -n "$AGENT_SHIM_PROFILE" ]]; then
    eval "$(run-claude env "$AGENT_SHIM_PROFILE" 2>/dev/null)"
fi
'''
        envrc_path.write_text(envrc_content)
        created_envrc = True
        print(f"Created: {envrc_path}")

    # Create/update .envrc.user
    envrc_user_content = f'''# Claude Switch User Config
# This file is gitignored - add your customizations here

export AGENT_SHIM_PROFILE="{profile_name}"

# Optional: Override specific models
# export ANTHROPIC_DEFAULT_OPUS_MODEL="custom-opus"
# export ANTHROPIC_DEFAULT_FABLE_MODEL="custom-fable"

# Optional: Client-specific settings
# export AGENT_SHIM_CLIENT="claude"
'''
    envrc_user_path.write_text(envrc_user_content)
    print(f"Created: {envrc_user_path}")

    # Update .gitignore
    gitignore_entries = [".envrc.user"]
    if created_envrc:
        gitignore_entries.append(".envrc")

    if gitignore_path.exists():
        existing = gitignore_path.read_text()
        lines = existing.splitlines()
    else:
        existing = ""
        lines = []

    for entry in gitignore_entries:
        if entry not in lines:
            lines.append(entry)

    new_content = "\n".join(lines)
    if not new_content.endswith("\n"):
        new_content += "\n"

    if new_content != existing:
        gitignore_path.write_text(new_content)
        print(f"Updated: {gitignore_path}")

    print(f"\nProfile '{profile_name}' configured for {directory}")
    print("Run 'direnv allow' to activate")

    return 0


def _print_proxy_layers(proxy_mod, status) -> None:
    """Print Front Proxy + LiteLLM Proxy, naming the live implementation."""
    print("Front Proxy:")
    fp_pid_file = proxy_mod.get_front_proxy_pid_file()
    if proxy_mod.is_front_proxy_running():
        fp_pid = fp_pid_file.read_text().strip() if fp_pid_file.exists() else "?"
        print("  Status: running")
        print(f"  PID: {fp_pid}")
        print(f"  URL: {proxy_mod.get_front_proxy_url()}")
        if status.unified:
            print(f"  Implementation: {status.implementation}")
    else:
        print("  Status: stopped")
        if status.unified:
            print(f"  Configured: {status.configured_implementation}")
    print()

    print("LiteLLM Proxy:")
    print(f"  Implementation: {status.implementation if status.running else status.configured_implementation}")
    if (
        status.running
        and status.configured_implementation
        and status.implementation != status.configured_implementation
    ):
        print(f"  Configured: {status.configured_implementation}")
    if status.unified:
        print("  Mode: unified (same process as Front Proxy)")
    if status.running:
        health = "healthy" if status.healthy else "unhealthy"
        print(f"  Status: running ({health})")
        print(f"  PID: {status.pid}")
        print(f"  URL: {status.url}")
        print(f"  Models: {status.model_count}")
    else:
        print("  Status: stopped")


def cmd_status(args: argparse.Namespace) -> int:
    """Handle status command."""
    import json
    from . import state, proxy, profiles

    # Handle --health flag: show formatted health endpoint response
    if getattr(args, 'health', False):
        health_info = proxy.get_health_info()
        if health_info is None:
            print("Failed to get health info (proxy may not be running)", file=sys.stderr)
            return 1
        print(json.dumps(health_info, indent=2))
        return 0

    st = state.load_state()
    proxy_status = proxy.get_status()

    print("=== Claude Switch Status ===")
    print()

    # Configuration files
    print("Configuration Files:")
    loaded = profiles.get_loaded_files()
    if loaded["profiles"]:
        for profile_file in loaded["profiles"]:
            print(f"  Profiles: {profile_file}")
    if loaded["models"]:
        for model_file in loaded["models"]:
            print(f"  Models: {model_file}")
    if not loaded["profiles"] and not loaded["models"]:
        print("  (none loaded)")
    print()

    _print_proxy_layers(proxy, proxy_status)
    print()

    # Database container status
    print("Database Container:")
    if proxy_status.db_status:
        if not proxy_status.db_status.installed:
            print("  Infrastructure: not installed")
        elif not proxy_status.db_status.container_exists:
            print("  Container: not created")
        elif not proxy_status.db_status.running:
            print(f"  Status: stopped (ID: {proxy_status.db_status.container_id})")
        else:
            health = "healthy" if proxy_status.db_status.healthy else "starting"
            print(f"  Status: running ({health})")
            print(f"  Container ID: {proxy_status.db_status.container_id}")
    else:
        print("  Status: unknown")

    # Database connection status
    db_conn = "connected" if proxy_status.db_healthy else "disconnected"
    print(f"  Connection: {db_conn}")

    print()

    # Active tokens
    print("Active Tokens:")
    if st.active_tokens:
        for token, info in st.active_tokens.items():
            print(f"  {token[:8]}...: {info.profile} ({info.directory})")
    else:
        print("  (none)")

    print()

    # Model refcounts
    print("Model Refcounts:")
    if st.model_refcounts:
        for model, count in sorted(st.model_refcounts.items()):
            print(f"  {model}: {count}")
    else:
        print("  (none)")

    print()

    # Pending leases
    print("Pending Leases:")
    if st.model_leases:
        now = time.time()
        for model, delete_after in sorted(st.model_leases.items()):
            remaining = int(delete_after - now)
            if remaining > 0:
                print(f"  {model}: expires in {remaining}s")
            else:
                print(f"  {model}: expired (pending deletion)")
    else:
        print("  (none)")

    return 0


def cmd_env(args: argparse.Namespace) -> int:
    """Handle env command."""
    from . import profiles, proxy

    debug = getattr(args, 'debug', False)
    profile_name = args.profile

    profile = profiles.load_profile(profile_name, debug=debug)
    if profile is None:
        print(f"Error: Profile not found: {profile_name}", file=sys.stderr)
        return 1

    # Generate environment variables
    from .front_proxy import DEFAULT_PORT as FRONT_PROXY_PORT
    env_vars = {
        "ANTHROPIC_BASE_URL": f"http://127.0.0.1:{FRONT_PROXY_PORT}",
        "API_TIMEOUT_MS": "3000000",
    }

    if profile.meta.haiku_model:
        env_vars["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = profile.meta.haiku_model
    if profile.meta.sonnet_model:
        env_vars["ANTHROPIC_DEFAULT_SONNET_MODEL"] = profile.meta.sonnet_model
    if profile.meta.opus_model:
        env_vars["ANTHROPIC_DEFAULT_OPUS_MODEL"] = profile.meta.opus_model
    fable_model = profile.meta.effective_fable_model()
    if fable_model:
        env_vars["ANTHROPIC_DEFAULT_FABLE_MODEL"] = fable_model

    # Output
    for key, value in env_vars.items():
        if args.export:
            print(f'export {key}="{value}"')
        else:
            print(f"{key}={value}")

    return 0


def cmd_run(args: argparse.Namespace) -> int:
    """Handle run command - execute a command with profile environment."""
    from . import agent_runner

    debug = getattr(args, 'debug', False)

    # Configure for Claude/Anthropic API
    agent_config = agent_runner.AgentConfig(
        agent_name="claude",
        default_cmd=["claude"],
        env_vars_fn=agent_runner.build_env_vars_anthropic,
    )

    return agent_runner.cmd_run_agent(args, agent_config, debug=debug)


def cmd_proxy(args: argparse.Namespace) -> int:
    """Handle proxy commands."""
    from . import proxy

    debug = getattr(args, 'debug', False)

    if args.proxy_command == "start":
        # Start front proxy
        if not proxy.is_front_proxy_running():
            proxy.start_front_proxy(wait=True)
        # Start LiteLLM with empty model list, models are loaded on-demand via profiles
        no_db = getattr(args, 'no_db', False)
        if proxy.start_proxy(empty_config=True, no_db=no_db, debug=debug):
            print("Proxy started")
            # Fresh start clears any prior intentional-stop marker and brings
            # the watchdog up (idempotent no-op if already running).
            proxy.clear_stop_marker()
            proxy.start_watchdog()
            return 0
        else:
            print("Failed to start proxy", file=sys.stderr)
            return 1

    elif args.proxy_command == "stop":
        # Stop front proxy
        proxy.stop_front_proxy()
        # Stop LiteLLM proxy — user_initiated so the watchdog does NOT restart it.
        if not proxy.stop_proxy(user_initiated=True):
            print("Failed to stop proxy", file=sys.stderr)
            return 1
        print("Proxy stopped")

        # Optionally stop database
        with_db = getattr(args, 'with_db', False)
        stop_all = getattr(args, 'all', False)

        if with_db or stop_all:
            print("Stopping database container...")
            if proxy.stop_db_container(remove=stop_all, debug=debug):
                if stop_all:
                    print("Database container removed")
                else:
                    print("Database container stopped")
            else:
                print("Failed to stop database container", file=sys.stderr)
                return 1

        return 0

    elif args.proxy_command == "supervise":
        print("[DEPRECATED] 'proxy supervise' blocks the foreground and restarts on "
              "any stop (including deliberate ones). Prefer the background watchdog:",
              file=sys.stderr)
        print("  run-claude watchdog start   (auto-restart on crash, respects 'proxy stop')",
              file=sys.stderr)
        no_db = getattr(args, 'no_db', False)
        interval = getattr(args, 'interval', 5.0)
        proxy.supervise_proxy(no_db=no_db, debug=debug, interval=interval)
        return 0

    elif args.proxy_command == "restart":
        no_db = getattr(args, 'no_db', False)
        proxy.stop_front_proxy()
        if proxy.is_proxy_running():
            if not proxy.stop_proxy():
                print("Failed to stop proxy", file=sys.stderr)
                return 1
            print("Proxy stopped")
        proxy.start_front_proxy(wait=True)
        if proxy.start_proxy(empty_config=True, no_db=no_db, debug=debug):
            print("Proxy started")
            # restart's internal stop was not user-initiated; clear any stale
            # marker and re-ensure the watchdog.
            proxy.clear_stop_marker()
            proxy.start_watchdog()
            return 0
        else:
            print("Failed to start proxy", file=sys.stderr)
            return 1

    elif args.proxy_command == "status":
        status = proxy.get_status()
        _print_proxy_layers(proxy, status)

        # Database container status
        print()
        print("Database Container:")
        if status.db_status:
            if not status.db_status.installed:
                print("  Infrastructure: not installed")
                print("  Run 'run-claude install' to install")
            elif not status.db_status.container_exists:
                print("  Container: not created")
            elif not status.db_status.running:
                print("  Container: stopped")
                print(f"  Container ID: {status.db_status.container_id}")
            else:
                health = "healthy" if status.db_status.healthy else "starting"
                print(f"  Container: running ({health})")
                print(f"  Container ID: {status.db_status.container_id}")

        # Database connection status
        db_conn = "connected" if status.db_healthy else "disconnected"
        print(f"  Connection: {db_conn}")

        return 0

    elif args.proxy_command == "health":
        if proxy.health_check():
            print("Healthy")
            return 0
        else:
            print("Unhealthy")
            return 1

    elif args.proxy_command == "db-test":
        if proxy.test_db_connection(debug=debug):
            print("Database connection: OK")
            return 0
        else:
            print("Database connection: FAILED")
            return 1

    else:
        print("Usage: run-claude proxy {start|stop|restart|supervise|status|health|db-test}")
        return 1


def cmd_watchdog(args: argparse.Namespace) -> int:
    """Handle watchdog commands.

    The watchdog is a background daemon that auto-restarts the proxy on crash,
    but respects intentional ``proxy stop`` (recorded via a stop marker).
    """
    from . import proxy

    debug = getattr(args, 'debug', False)

    if args.watchdog_command == "start":
        interval = getattr(args, 'interval', 5.0)
        if proxy.start_watchdog(interval=interval, debug=debug):
            print("Watchdog started")
            return 0
        print("Failed to start watchdog", file=sys.stderr)
        return 1

    elif args.watchdog_command == "stop":
        if not proxy.stop_watchdog():
            print("Failed to stop watchdog", file=sys.stderr)
            return 1
        print("Watchdog stopped")
        if getattr(args, 'with_proxy', False):
            print("Stopping proxies...")
            proxy.stop_front_proxy()
            proxy.stop_proxy(user_initiated=True)
            print("Proxies stopped")
        return 0

    elif args.watchdog_command == "restart":
        proxy.stop_watchdog()
        interval = getattr(args, 'interval', 5.0)
        if proxy.start_watchdog(interval=interval, debug=debug):
            print("Watchdog restarted")
            return 0
        print("Failed to restart watchdog", file=sys.stderr)
        return 1

    elif args.watchdog_command == "status":
        pid_file = proxy.get_watchdog_pid_file()
        print("Watchdog:")
        if proxy.is_watchdog_running():
            pid = pid_file.read_text().strip() if pid_file.exists() else "?"
            print(f"  Status: running")
            print(f"  PID: {pid}")
            print(f"  Log: {proxy.get_watchdog_log_file()}")
        else:
            print("  Status: stopped")
        return 0

    else:
        print("Usage: run-claude watchdog {start|stop|restart|status}")
        return 1


def cmd_db(args: argparse.Namespace) -> int:
    """Handle database container commands."""
    from . import proxy

    debug = getattr(args, 'debug', False)

    if args.db_command == "start":
        # Ensure infrastructure is installed
        if not proxy.is_infrastructure_installed():
            print("Installing infrastructure...")
            if not proxy.install_infrastructure(debug=debug):
                print("Failed to install infrastructure", file=sys.stderr)
                return 1

        if proxy.start_db_container(wait=True, debug=debug):
            print("Database container started")
            return 0
        else:
            print("Failed to start database container", file=sys.stderr)
            return 1

    elif args.db_command == "stop":
        remove = getattr(args, 'remove', False)
        if proxy.stop_db_container(remove=remove, debug=debug):
            if remove:
                print("Database container removed")
            else:
                print("Database container stopped")
            return 0
        else:
            print("Failed to stop database container", file=sys.stderr)
            return 1

    elif args.db_command == "status":
        status = proxy.get_db_status()

        print("Database Container:")
        if not status.installed:
            print("  Infrastructure: not installed")
            print("  Run 'run-claude install' to install")
        elif not status.container_exists:
            print("  Container: not created")
            print("  Run 'run-claude db start' to create and start")
        elif not status.running:
            print("  Status: stopped")
            print(f"  Container ID: {status.container_id}")
        else:
            health = "healthy" if status.healthy else "starting"
            print(f"  Status: running ({health})")
            print(f"  Container ID: {status.container_id}")

        # Test actual connection
        print()
        print("Connection Test:")
        if proxy.test_db_connection(debug=debug):
            print("  Status: OK")
        else:
            print("  Status: FAILED")

        return 0

    elif args.db_command == "migrate":
        print("Running prisma migrate...")
        if proxy.run_prisma_migrate(debug=debug):
            print("Migration completed successfully")
            return 0
        else:
            print("Migration failed", file=sys.stderr)
            return 1

    else:
        print("Usage: run-claude db {start|stop|status|migrate}")
        return 1


def cmd_profiles(args: argparse.Namespace) -> int:
    """Handle profiles commands."""
    from . import profiles

    debug = getattr(args, 'debug', False)

    if args.profiles_command == "list":
        available = profiles.list_profiles(debug=debug)
        if available:
            print("Available profiles:")
            for name in available:
                print(f"  {name}")
        else:
            print("No profiles found")
        return 0

    elif args.profiles_command == "show":
        profile = profiles.load_profile(args.name, debug=debug)
        if profile is None:
            print(f"Profile not found: {args.name}", file=sys.stderr)
            return 1

        print(f"Profile: {profile.meta.name}")
        if profile.source_path:
            print(f"Loaded from: {profile.source_path}")

        # Also show model file sources
        loaded = profiles.get_loaded_files()
        if loaded["models"]:
            for model_file in loaded["models"]:
                print(f"Models loaded from: {model_file}")
        print()
        print("Model Aliases:")
        print(f"  opus:   {profile.meta.opus_model or '(not set)'}")
        print(f"  sonnet: {profile.meta.sonnet_model or '(not set)'}")
        print(f"  haiku:  {profile.meta.haiku_model or '(not set)'}")
        print(f"  fable:  {profile.meta.effective_fable_model() or '(not set)'}")
        if profile.meta.extended:
            print()
            print("Extended Models:")
            for ext_model in profile.meta.extended:
                print(f"  - {ext_model}")
        print()
        print("Models:")
        for model in profile.model_list:
            print(f"  - {model.model_name}")
        return 0

    elif args.profiles_command == "install":
        user_profiles = profiles.get_user_profiles_file()
        user_profiles.parent.mkdir(parents=True, exist_ok=True)

        if user_profiles.exists():
            print(f"User profiles already exist: {user_profiles}")
            print("Use 'run-claude install --force' to overwrite")
            return 0

        user_profiles.write_text(profiles._USER_PROFILES_TEMPLATE, encoding="utf-8")
        print(f"Installed: {user_profiles}")
        return 0

    else:
        print("Usage: run-claude profiles {list|show|install}")
        return 1


def cmd_models(args: argparse.Namespace) -> int:
    """Handle models commands."""
    from . import profiles

    if args.models_command == "list":
        available = profiles.list_models()
        if available:
            print("Available model definitions:")
            for name in available:
                print(f"  {name}")
        else:
            print("No model definitions found")
        return 0

    elif args.models_command == "enabled":
        from . import proxy

        if not proxy.is_proxy_running():
            print("Proxy is not running — no models are enabled.", file=sys.stderr)
            print("Start it with: run-claude proxy start", file=sys.stderr)
            return 1

        live = proxy.list_models()
        names = sorted({m.get("model_name", "?") for m in live})

        names_only = getattr(args, "names_only", False)
        if names_only:
            for name in names:
                print(name)
            return 0

        # Active profile aliases (set by direnv when inside a shimmed dir)
        active = os.environ.get("AGENT_SHIM_PROFILE")
        if active:
            profile = profiles.load_profile(active)
            if profile is not None:
                print(f"Active profile: {active} ({profile.meta.name})")
                print("Tier aliases (use these in /model):")
                print(f"  opus:   {profile.meta.opus_model or '(not set)'}")
                print(f"  sonnet: {profile.meta.sonnet_model or '(not set)'}")
                print(f"  haiku:  {profile.meta.haiku_model or '(not set)'}")
                print(f"  fable:  {profile.meta.effective_fable_model() or '(not set)'}")
                print()
        else:
            print("No active profile (AGENT_SHIM_PROFILE not set)")
            print()

        if names:
            print(f"Enabled models ({len(names)}):")
            for name in names:
                print(f"  {name}")
        else:
            print("No models enabled in the proxy")
        return 0

    elif args.models_command == "show":
        model_def = profiles.get_model_definition(args.name)
        if model_def is None:
            print(f"Model definition not found: {args.name}", file=sys.stderr)
            return 1

        print(f"Model: {model_def.model_name}")

        # Show model file sources
        loaded = profiles.get_loaded_files()
        if loaded["models"]:
            for model_file in loaded["models"]:
                print(f"Loaded from: {model_file}")
        print()
        print("LiteLLM Params:")
        for key, value in model_def.litellm_params.items():
            print(f"  {key}: {value}")
        return 0

    elif args.models_command == "avail":
        return cmd_models_avail(args)

    elif args.models_command == "wipe":
        from . import proxy, state

        debug = getattr(args, 'debug', False)

        # Require confirmation unless --force
        if not getattr(args, 'force', False):
            print("This will delete ALL models from the LiteLLM proxy database.")
            print("Models will be re-added when profiles are loaded.")
            try:
                response = input("Continue? [y/N]: ")
                if response.lower() not in ('y', 'yes'):
                    print("Aborted.")
                    return 0
            except (EOFError, KeyboardInterrupt):
                print("\nAborted.")
                return 0

        # Check if proxy is running
        if not proxy.is_proxy_running():
            print("Error: Proxy is not running. Start with: run-claude proxy start", file=sys.stderr)
            return 1

        # Wipe models via API
        deleted, failed = proxy.wipe_all_models(debug=debug)

        # Clear local state
        st = state.load_state()
        st.model_refcounts.clear()
        st.model_leases.clear()
        state.save_state(st)

        print(f"Deleted {deleted} model(s) from database")
        if failed > 0:
            print(f"Failed to delete {failed} model(s)")
            return 1

        print("Local state cleared.")
        print("Run 'run-claude with <profile>' to reload models.")
        return 0

    else:
        print("Usage: run-claude models {list|enabled|avail|show|wipe}")
        return 1


def cmd_models_avail(args: argparse.Namespace) -> int:
    """Show enabled models with descriptions, strengths, and weaknesses."""
    import json as json_mod
    from . import proxy, profiles

    if not proxy.is_proxy_running():
        print("Proxy is not running — no models are enabled.", file=sys.stderr)
        print("Start it with: run-claude proxy start", file=sys.stderr)
        return 1

    live = proxy.list_models()
    live_names = sorted({m.get("model_name", "?") for m in live})

    if not live_names:
        print("No models enabled in the proxy.")
        return 0

    all_defs = profiles.load_model_definitions()

    records = []
    for name in live_names:
        model_def = all_defs.get(name)
        meta = model_def.metadata if model_def else profiles.ModelMetadata()
        provider = meta.provider
        if not provider and model_def:
            litellm_model = model_def.litellm_params.get("model", "")
            provider = litellm_model.split("/")[0] if "/" in litellm_model else ""
        records.append({
            "name": name,
            "provider": provider,
            "description": meta.description,
            "strengths": meta.strengths,
            "weaknesses": meta.weaknesses,
        })

    if getattr(args, "output_json", False):
        print(json_mod.dumps(records, indent=2))
        return 0

    if getattr(args, "short", False):
        for r in records:
            desc = r["description"] or "—"
            print(f"  {r['name']:40s} {desc}")
        return 0

    # Group by provider
    by_provider: dict[str, list[dict]] = {}
    for r in records:
        prov = r["provider"] or "other"
        by_provider.setdefault(prov, []).append(r)

    for prov in sorted(by_provider):
        print(f"\n{'═' * 72}")
        print(f"  {prov.upper()}")
        print(f"{'═' * 72}")
        for r in by_provider[prov]:
            print(f"\n  {r['name']}")
            if r["description"]:
                print(f"    {r['description']}")
            if r["strengths"]:
                print(f"    ✓ {r['strengths']}")
            if r["weaknesses"]:
                print(f"    ✗ {r['weaknesses']}")
            if not r["description"] and not r["strengths"] and not r["weaknesses"]:
                print(f"    (no metadata — add to models.yaml)")

    print(f"\n{len(records)} model(s) enabled")
    return 0


def cmd_keys(args: argparse.Namespace) -> int:
    """Handle runtime named-key commands against go-litellm."""
    from . import proxy, state
    from .keys import (
        KeyAPIUnsupported,
        canonical_key_name,
        env_for_name,
        format_listing,
        predefined_keys,
    )

    proxy.inject_secrets_into_env()
    command = getattr(args, "keys_command", None) or "list"

    def _need_proxy() -> bool:
        if not proxy.is_proxy_running():
            print("Proxy is not running — start it with: run-claude proxy start", file=sys.stderr)
            return False
        return True

    try:
        if command == "list":
            local = predefined_keys()
            payload = None
            if proxy.is_proxy_running():
                try:
                    proxy.ensure_named_keys()
                    payload = proxy.list_named_keys()
                except KeyAPIUnsupported as exc:
                    print(str(exc), file=sys.stderr)
                except Exception as exc:
                    print(f"Could not read live keys: {exc}", file=sys.stderr)
            else:
                print("Proxy is not running; showing local predefined keys only.", file=sys.stderr)
            print(format_listing(payload, local=local))
            st = state.load_state()
            if st.key_families:
                print("\nPersisted family bindings:")
                for fam, key in sorted(st.key_families.items()):
                    print(f"  {fam} -> {key}")
            return 0

        if command == "add":
            if not _need_proxy():
                return 1
            name = canonical_key_name(args.name)
            env = getattr(args, "env", None)
            value = getattr(args, "value", None)
            if not env and not value:
                if not sys.stdin.isatty():
                    print("Provide --env VAR or --value when stdin is not a TTY.", file=sys.stderr)
                    return 2
                import getpass
                value = getpass.getpass(f"API key for {name}: ").strip()
                if not value:
                    print("Empty key; aborted.", file=sys.stderr)
                    return 1
            if env and not os.environ.get(env):
                print(f"Environment variable {env} is empty (check .secrets).", file=sys.stderr)
                return 1
            proxy.upsert_named_key(name, env=env, api_key=value or os.environ.get(env or ""))
            if env:
                st = state.load_state()
                st.named_key_envs[name] = env
                state.save_state(st)
            print(f"Stored named key {name}" + (f" from {env}" if env else ""))
            return 0

        if command == "delete":
            if not _need_proxy():
                return 1
            name = canonical_key_name(args.name)
            proxy.delete_named_key(name)
            st = state.load_state()
            st.named_key_envs.pop(name, None)
            state.save_state(st)
            print(f"Deleted named key {name}")
            return 0

        if command == "switch":
            if not _need_proxy():
                return 1
            proxy.ensure_named_keys()
            target = getattr(args, "target", None)
            key = getattr(args, "key", None)
            using = getattr(args, "using", None)
            if using and not key:
                key = target
                target = None
            if (not using and (not target or not key)) and sys.stdin.isatty():
                target, key = _prompt_key_switch(target, key)
                if not target or not key:
                    return 1
            if not key or (not target and not using):
                print("Usage: run-claude keys switch <target> <key>", file=sys.stderr)
                print("Example: run-claude keys switch zai tyna", file=sys.stderr)
                return 2
            key = canonical_key_name(key)
            env = env_for_name(key)
            if env and os.environ.get(env):
                proxy.upsert_named_key(key, env=env, api_key=os.environ[env])
            result = proxy.switch_named_key(key, target=target, using=using)
            updated = result.get("updated") or []
            print(f"Bound {key} on {len(updated)} model(s)")
            for name in updated:
                print(f"  {name}")
            if not updated:
                print("No matching models. Is the family registered? Try: run-claude models enabled")
            return 0

        print("Usage: run-claude keys {list|add|delete|switch}")
        return 1
    except KeyAPIUnsupported as exc:
        print(str(exc), file=sys.stderr)
        return 1
    except Exception as exc:
        print(f"keys command failed: {exc}", file=sys.stderr)
        return 1


def _prompt_key_switch(target: str | None, key: str | None) -> tuple[str | None, str | None]:
    """Interactive family/key picker for `keys switch`."""
    from . import proxy
    from .keys import family_of

    try:
        listing = proxy.list_named_keys()
    except Exception as exc:
        print(f"Could not list keys: {exc}", file=sys.stderr)
        return None, None

    names = [item.get("name") for item in listing.get("keys", []) if item.get("configured")]
    families: list[str] = []
    seen: set[str] = set()
    for row in listing.get("bindings", []):
        model = row.get("model_name") or ""
        fam = family_of(model)
        if fam and fam not in seen:
            seen.add(fam)
            families.append(fam)

    if not target:
        if not families:
            print("No live model families to switch.", file=sys.stderr)
            return None, None
        print("Families:")
        for i, fam in enumerate(families, 1):
            print(f"  {i}) {fam}")
        try:
            selection = input(f"Family [1-{len(families)} or name]: ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            return None, None
        if not selection:
            target = families[0]
        elif selection.isdigit() and 1 <= int(selection) <= len(families):
            target = families[int(selection) - 1]
        else:
            target = selection

    if not key:
        if not names:
            print("No configured named keys. Add one with: run-claude keys add", file=sys.stderr)
            return None, None
        print("Keys:")
        for i, name in enumerate(names, 1):
            print(f"  {i}) {name}")
        try:
            selection = input(f"Key [1-{len(names)} or name]: ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            return None, None
        if not selection:
            key = names[0]
        elif selection.isdigit() and 1 <= int(selection) <= len(names):
            key = names[int(selection) - 1]
        else:
            key = selection

    return target, key


def cmd_chat(args: argparse.Namespace) -> int:
    """Chat directly with a model enabled in the running LiteLLM proxy."""
    from .chat import run_chat

    return run_chat(
        model=getattr(args, "model", None),
        system_prompt=getattr(args, "system", None),
        prompt=getattr(args, "prompt", None),
        timeout=getattr(args, "timeout", 300.0),
    )


def cmd_install(args: argparse.Namespace) -> int:
    """Install user config templates and infrastructure to user directories."""
    from . import profiles, proxy

    debug = getattr(args, 'debug', False)
    config_dir = profiles.get_config_dir()
    user_profiles_file = profiles.get_user_profiles_file()
    user_models_file = profiles.get_user_models_file()

    # Create config directory
    config_dir.mkdir(parents=True, exist_ok=True)

    installed = 0
    skipped = 0

    # Create models.yaml template (for user overrides)
    if not user_models_file.exists() or args.force:
        user_models_file.write_text(profiles._USER_MODELS_TEMPLATE, encoding="utf-8")
        print(f"Installed: {user_models_file}")
        installed += 1
    else:
        print(f"Skipped (exists): {user_models_file}")
        skipped += 1

    # Create profiles.yaml template (for user overrides)
    if not user_profiles_file.exists() or args.force:
        user_profiles_file.write_text(profiles._USER_PROFILES_TEMPLATE, encoding="utf-8")
        print(f"Installed: {user_profiles_file}")
        installed += 1
    else:
        print(f"Skipped (exists): {user_profiles_file}")
        skipped += 1

    # Install infrastructure (docker-compose files)
    dep_dir = proxy.get_dep_dir()
    if not proxy.is_infrastructure_installed() or args.force:
        if proxy.install_infrastructure(force=args.force, debug=debug):
            print(f"Installed: {dep_dir}/docker-compose.yaml")
            print(f"Installed: {dep_dir}/docker-compose.override.yaml")
            installed += 2
    else:
        print(f"Skipped (exists): {dep_dir}/docker-compose.yaml")
        skipped += 1

    print()
    print(f"Configuration installed to: {config_dir}")
    print(f"Infrastructure installed to: {dep_dir}")
    print(f"  {installed} file(s) installed")
    if skipped > 0:
        print(f"  {skipped} file(s) skipped (use --force to overwrite)")

    return 0


def cmd_secrets(args: argparse.Namespace) -> int:
    """Handle secrets commands."""
    from . import config

    debug = getattr(args, 'debug', False)

    if args.secrets_command == "init":
        generate = getattr(args, 'generate', False)
        force = getattr(args, 'force', False)
        config.ensure_secrets_template(force=force, generate_passwords=generate, debug=debug)
        return 0

    elif args.secrets_command == "path":
        secrets_file = config.get_secrets_file()
        print(str(secrets_file))
        return 0

    elif args.secrets_command == "export":
        try:
            env_file = config.export_env_file(debug=debug)
            print(f"Exported secrets to: {env_file}")
            print(f"\nSecrets automatically loaded by Docker Compose!")
            print(f"  cd dep && docker compose up -d")
            return 0
        except Exception:
            return 1

    else:
        print("Usage: run-claude secrets {init|path|export}")
        return 1


def main_avail_models() -> int:
    """Entry point for rc-avail-models shortcut."""
    from . import profiles
    profiles.ensure_initialized()
    sys.argv = ["run-claude", "models", "avail"] + sys.argv[1:]
    return main()


if __name__ == "__main__":
    sys.exit(main())
