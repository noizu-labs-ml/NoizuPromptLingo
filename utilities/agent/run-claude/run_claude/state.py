"""
State management for run-claude.

Manages refcounts, leases, and active tokens in XDG-compliant state directory.
"""

from __future__ import annotations

import json
import os
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


def get_state_dir() -> Path:
    """Get XDG-compliant state directory."""
    xdg_state = os.environ.get("XDG_STATE_HOME")
    if xdg_state:
        base = Path(xdg_state)
    else:
        base = Path.home() / ".local" / "state"
    return base / "run-claude"


def get_state_file() -> Path:
    """Get path to state file."""
    return get_state_dir() / "state.json"


@dataclass
class TokenInfo:
    """Information about an active token."""
    profile: str
    last_seen: float
    directory: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "profile": self.profile,
            "last_seen": self.last_seen,
            "dir": self.directory,
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> TokenInfo:
        return cls(
            profile=data.get("profile", ""),
            last_seen=data.get("last_seen", 0.0),
            directory=data.get("dir", ""),
        )


@dataclass
class State:
    """Agent shim state."""
    proxy_pid: int | None = None
    active_tokens: dict[str, TokenInfo] = field(default_factory=dict)
    model_refcounts: dict[str, int] = field(default_factory=dict)
    model_leases: dict[str, float] = field(default_factory=dict)  # model -> delete_after epoch
    last_janitor_run: float = 0.0

    def to_dict(self) -> dict[str, Any]:
        return {
            "proxy_pid": self.proxy_pid,
            "active_tokens": {k: v.to_dict() for k, v in self.active_tokens.items()},
            "model_refcounts": self.model_refcounts,
            "model_leases": self.model_leases,
            "last_janitor_run": self.last_janitor_run,
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> State:
        tokens = {}
        for k, v in data.get("active_tokens", {}).items():
            tokens[k] = TokenInfo.from_dict(v)

        return cls(
            proxy_pid=data.get("proxy_pid"),
            active_tokens=tokens,
            model_refcounts=data.get("model_refcounts", {}),
            model_leases=data.get("model_leases", {}),
            last_janitor_run=data.get("last_janitor_run", 0.0),
        )


def load_state() -> State:
    """Load state from file, returning empty state if not found."""
    state_file = get_state_file()
    if not state_file.exists():
        return State()

    try:
        data = json.loads(state_file.read_text(encoding="utf-8"))
        return State.from_dict(data)
    except (json.JSONDecodeError, OSError):
        return State()


def save_state(state: State) -> None:
    """Save state to file."""
    state_dir = get_state_dir()
    state_dir.mkdir(parents=True, exist_ok=True)

    state_file = get_state_file()
    state_file.write_text(
        json.dumps(state.to_dict(), indent=2),
        encoding="utf-8"
    )


def increment_models(state: State, models: list[str]) -> None:
    """Increment refcounts for models."""
    for model in models:
        state.model_refcounts[model] = state.model_refcounts.get(model, 0) + 1
        # Clear any pending lease when model is activated
        if model in state.model_leases:
            del state.model_leases[model]


def decrement_models(state: State, models: list[str], lease_delay: float = 900.0) -> None:
    """Decrement refcounts for models, setting leases for those hitting zero."""
    delete_after = time.time() + lease_delay

    for model in models:
        count = state.model_refcounts.get(model, 0)
        if count > 0:
            count -= 1
            state.model_refcounts[model] = count

        if count == 0:
            # Set lease for delayed deletion
            state.model_leases[model] = delete_after
            # Clean up zero refcount
            if model in state.model_refcounts:
                del state.model_refcounts[model]


def get_expired_leases(state: State) -> list[str]:
    """Get models with expired leases that should be deleted."""
    now = time.time()
    expired = []

    for model, delete_after in state.model_leases.items():
        if now >= delete_after:
            # Only delete if refcount is still zero
            if state.model_refcounts.get(model, 0) == 0:
                expired.append(model)

    return expired


def clear_lease(state: State, model: str) -> None:
    """Clear a lease for a model."""
    if model in state.model_leases:
        del state.model_leases[model]


def add_token(state: State, token: str, profile: str, directory: str) -> None:
    """Add or update an active token."""
    state.active_tokens[token] = TokenInfo(
        profile=profile,
        last_seen=time.time(),
        directory=directory,
    )


def remove_token(state: State, token: str) -> TokenInfo | None:
    """Remove a token, returning its info if it existed."""
    return state.active_tokens.pop(token, None)


def get_token(state: State, token: str) -> TokenInfo | None:
    """Get info for a token."""
    return state.active_tokens.get(token)
