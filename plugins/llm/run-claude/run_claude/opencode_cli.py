#!/usr/bin/env python3
"""
run-open-code - Agent shim controller for OpenCode.

Directory-aware model routing via LiteLLM proxy.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import sys
import time
from pathlib import Path

# Re-export all the command handlers from cli since they're shared
from .cli import (
    cmd_enter,
    cmd_leave,
    cmd_janitor,
    cmd_set_folder,
    cmd_status,
    cmd_env,
    cmd_proxy,
    cmd_db,
    cmd_profiles,
    cmd_models,
    cmd_install,
    cmd_secrets,
)


def main() -> int:
    # Ensure config is initialized on first run
    from . import profiles, config
    profiles.ensure_initialized()

    # Ensure secrets template exists
    debug = "--debug" in sys.argv or "-d" in sys.argv
    config.ensure_secrets_template(debug=debug)

    parser = argparse.ArgumentParser(
        prog="run-open-code",
        description="Agent shim controller for OpenCode - launch opencode with mode list profile",
    )
    parser.add_argument("--debug", "-d", action="store_true", help="Enable debug output")
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
    proxy_sub.add_parser("status", help="Proxy status")
    proxy_sub.add_parser("health", help="Health check")
    proxy_sub.add_parser("db-test", help="Test database connection")

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
    show_model_p = models_sub.add_parser("show", help="Show model definition details")
    show_model_p.add_argument("name", help="Model name")
    wipe_p = models_sub.add_parser("wipe", help="Delete all models from proxy database")
    wipe_p.add_argument("--force", "-f", action="store_true", help="Skip confirmation prompt")

    # run - run a command with profile environment
    run_p = subparsers.add_parser("with", help="Run OpenCode with a profile")
    run_p.add_argument("profile", help="Profile name")
    run_p.add_argument("cmd", nargs=argparse.REMAINDER, help="Command to run (default: opencode)")
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
    elif args.command == "db":
        return cmd_db(args)
    elif args.command == "profiles":
        return cmd_profiles(args)
    elif args.command == "models":
        return cmd_models(args)
    elif args.command == "with":
        return cmd_run_opencode(args)
    elif args.command == "install":
        return cmd_install(args)
    elif args.command == "secrets":
        return cmd_secrets(args)
    else:
        parser.print_help()
        return 1


def cmd_run_opencode(args: argparse.Namespace) -> int:
    """Handle run command for OpenCode - execute a command with profile environment."""
    from . import agent_runner

    debug = getattr(args, 'debug', False)

    # Configure for OpenAI-compatible API (OpenCode standard)
    agent_config = agent_runner.AgentConfig(
        agent_name="opencode",
        default_cmd=["opencode"],
        env_vars_fn=agent_runner.build_env_vars_openai,
    )

    return agent_runner.cmd_run_agent(args, agent_config, debug=debug)
