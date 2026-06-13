"""Shared agent runner logic for Claude and OpenCode."""

from __future__ import annotations

import argparse
import hashlib
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Callable


class AgentConfig:
    """Configuration for which agent to run."""

    def __init__(self, agent_name: str, default_cmd: list[str], env_vars_fn: Callable):
        """
        Args:
            agent_name: 'claude' or 'opencode'
            default_cmd: Default command to run (e.g., ['claude'] or ['opencode'])
            env_vars_fn: Function that takes profile and proxy info and returns dict of env vars
        """
        self.agent_name = agent_name
        self.default_cmd = default_cmd
        self.env_vars_fn = env_vars_fn


def build_env_vars_anthropic(profile, proxy_url: str, api_key: str) -> dict[str, str]:
    """Build environment variables for Anthropic API."""
    from .front_proxy import DEFAULT_PORT as FRONT_PROXY_PORT
    env = {}
    env["ANTHROPIC_BASE_URL"] = f"http://127.0.0.1:{FRONT_PROXY_PORT}"
    env["API_TIMEOUT_MS"] = "3000000"

    if profile.meta.haiku_model:
        env["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = profile.meta.haiku_model
    if profile.meta.sonnet_model:
        env["ANTHROPIC_DEFAULT_SONNET_MODEL"] = profile.meta.sonnet_model
    if profile.meta.opus_model:
        env["ANTHROPIC_DEFAULT_OPUS_MODEL"] = profile.meta.opus_model

    return env


def build_env_vars_openai(profile, proxy_url: str, api_key: str) -> dict[str, str]:
    """Build environment variables for OpenAI-compatible API."""
    env = {}
    env["OPENAI_API_KEY"] = api_key
    env["OPENAI_BASE_URL"] = proxy_url

    return env


def cmd_run_agent(
    args: argparse.Namespace,
    agent_config: AgentConfig,
    debug: bool = False,
) -> int:
    """Run an agent with profile environment.

    Args:
        args: Parsed arguments (must have 'profile' and 'cmd' attributes)
        agent_config: AgentConfig specifying which agent to run
        debug: Enable debug output

    Returns:
        Exit code from subprocess
    """
    from . import profiles, proxy

    # argparse.REMAINDER absorbs --refresh into args.cmd; extract it manually
    refresh = getattr(args, 'refresh', False)
    if hasattr(args, 'cmd') and '--refresh' in args.cmd:
        args.cmd = [a for a in args.cmd if a != '--refresh']
        refresh = True

    profile_name = args.profile

    if refresh:
        print("[REFRESH] Clearing model/profile caches", file=sys.stderr)
        profiles.clear_caches()

    profile = profiles.load_profile(profile_name, debug=debug)
    if profile is None:
        print(f"Error: Profile not found: {profile_name}", file=sys.stderr)
        return 1

    # Log profile selection and models
    print(f"[PROFILE_SELECTED] '{profile_name}' ({profile.meta.name})", file=sys.stderr)
    print(f"[MODELS_FOR_REGISTRATION] {len(profile.model_list)} models:", file=sys.stderr)
    for m in profile.model_list:
        print(f"  - {m.model_name}", file=sys.stderr)

    # Verify profile has models resolved
    if not profile.model_list:
        print(f"Warning: Profile '{profile_name}' has no models resolved.", file=sys.stderr)
        print(f"  Check that model definitions exist for:", file=sys.stderr)
        if profile.meta.opus_model:
            print(f"    opus_model: {profile.meta.opus_model}", file=sys.stderr)
        if profile.meta.sonnet_model:
            print(f"    sonnet_model: {profile.meta.sonnet_model}", file=sys.stderr)
        if profile.meta.haiku_model:
            print(f"    haiku_model: {profile.meta.haiku_model}", file=sys.stderr)

    # Get model definitions for config generation
    model_defs = [m.to_dict() for m in profile.model_list]

    # Ensure proxy is running with profile's models
    # start_proxy handles: stale PIDs, unhealthy state, and retries on transient failures
    config_path = str(proxy.generate_litellm_config(model_defs=model_defs)) if model_defs else None
    if not proxy.start_proxy(config_path=config_path, debug=debug):
        print("Error: Failed to start proxy after retries", file=sys.stderr)
        log_lines = proxy.tail_proxy_log(20)
        if log_lines:
            print("  Recent proxy log output:", file=sys.stderr)
            for line in log_lines:
                print(f"    {line}", file=sys.stderr)
        else:
            print(f"  No log output found at {proxy.get_log_file()}", file=sys.stderr)
        return 1

    # Proxy is running and healthy — ensure models are registered
    if model_defs:
        added, skipped, failed = proxy.ensure_models(model_defs, debug=debug, wait_for_recovery=True, force=refresh)
        if debug and added > 0:
            print(f"Added {added} model(s) to proxy", file=sys.stderr)
        if failed > 0 and added == 0 and skipped == 0:
            print(f"Error: All {failed} model(s) failed to register", file=sys.stderr)
            return 1

    # Build environment
    env = os.environ.copy()

    # Add agent-specific environment variables
    proxy_url = proxy.get_proxy_url()
    api_key = proxy.get_api_key()
    agent_env = agent_config.env_vars_fn(profile, proxy_url, api_key)
    env.update(agent_env)

    # Determine command to run
    cmd = args.cmd if args.cmd else agent_config.default_cmd

    # Print status (reuse existing function if needed)
    from . import state
    st = state.load_state()
    proxy_status = proxy.get_status()

    print(f"\n=== {agent_config.agent_name.capitalize()} Agent Status ===", file=sys.stderr)
    if proxy_status.running:
        health = "healthy" if proxy_status.healthy else "unhealthy"
        print(f"Proxy: running ({health}) - {proxy_status.url}", file=sys.stderr)
        print(f"Models: {proxy_status.model_count}", file=sys.stderr)
    print(f"Profile: {profile_name} ({profile.meta.name})", file=sys.stderr)
    print(f"Command: {' '.join(cmd)}\n", file=sys.stderr)

    # Execute
    try:
        result = subprocess.run(cmd, env=env)
        return result.returncode
    except FileNotFoundError:
        print(f"Error: Command not found: {cmd[0]}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        return 130
