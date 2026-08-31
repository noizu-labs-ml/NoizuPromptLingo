"""
Self-healing watchdog for the run-claude proxy.

Runs as a detached background daemon (setsid) and keeps both the front proxy
(:4443) and the LiteLLM proxy (:4444) alive. When either is found down or
unhealthy, it restarts it via the existing ``start_proxy`` / ``start_front_proxy``
lifecycle helpers — UNLESS the proxy was stopped intentionally.

Intentional stops are recorded via a sentinel ``stop.marker`` file in the state
directory: ``run-claude proxy stop`` (and the watchdog's own shutdown) write it,
so the watchdog knows not to undo a deliberate stop. Internal recovery stops,
``proxy restart``, and crashes never write the marker, so they are treated as
crashes and auto-restarted.

The watchdog is self-healing: ``run-claude proxy start`` and the shell-hook
``enter`` call :func:`start_watchdog` (a cheap, idempotent PID check), so a
crashed watchdog process is re-spawned the next time either fires.
"""

from __future__ import annotations

import argparse
import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

from .state import get_state_dir, get_stop_marker_file


DEFAULT_INTERVAL = 5.0


def get_watchdog_pid_file() -> Path:
    """Get the watchdog PID file path."""
    return get_state_dir() / "watchdog.pid"


def get_watchdog_log_file() -> Path:
    """Get the watchdog log file path."""
    return get_state_dir() / "watchdog.log"


def is_watchdog_running() -> bool:
    """Check if the watchdog daemon is running (cheap PID check, no health probe).

    Mirrors :func:`proxy.is_front_proxy_running`: a stale PID file (process dead)
    is cleaned up and treated as not-running.
    """
    pid_file = get_watchdog_pid_file()
    if not pid_file.exists():
        return False
    try:
        pid = int(pid_file.read_text().strip())
        os.kill(pid, 0)
        return True
    except PermissionError:
        return True
    except (ValueError, ProcessLookupError):
        pid_file.unlink(missing_ok=True)
        return False


def get_watchdog_pid() -> int | None:
    """Get the watchdog PID if running, else None."""
    pid_file = get_watchdog_pid_file()
    if not pid_file.exists():
        return None
    try:
        pid = int(pid_file.read_text().strip())
        os.kill(pid, 0)
        return pid
    except PermissionError:
        return pid
    except (ValueError, ProcessLookupError):
        return None


# ---------------------------------------------------------------------------
# Stop marker: distinguishes a user-initiated stop from a crash
# ---------------------------------------------------------------------------


def mark_user_stop(reason: str = "user") -> None:
    """Record that the proxy was stopped intentionally (do not auto-restart).

    Writes a small JSON record so the reason and timestamp are inspectable.
    """
    marker = get_stop_marker_file()
    marker.parent.mkdir(parents=True, exist_ok=True)
    record = {
        "ts": time.time(),
        "reason": reason,
        "pid": os.getpid(),
    }
    marker.write_text(json.dumps(record), encoding="utf-8")


def clear_stop_marker() -> None:
    """Remove the stop marker so the watchdog resumes auto-restarting on crash."""
    get_stop_marker_file().unlink(missing_ok=True)


def was_user_stopped() -> bool:
    """Return True if an intentional stop marker is present."""
    return get_stop_marker_file().exists()


# ---------------------------------------------------------------------------
# Watchdog lifecycle
# ---------------------------------------------------------------------------


def _log(msg: str, *, file=None) -> None:
    print(msg, file=file if file is not None else sys.stderr)


def start_watchdog(
    interval: float = DEFAULT_INTERVAL,
    debug: bool = False,
    foreground: bool = False,
) -> bool:
    """Start the watchdog daemon if not already running.

    Idempotent: a running watchdog is a no-op, so it is cheap to call from the
    shell-hook ``enter`` path on every prompt.

    Args:
        interval: Seconds between liveness checks.
        debug: Enable debug output.
        foreground: Run the loop in-process (blocking) instead of detaching —
            intended for tests.

    Returns:
        True if the watchdog is running (or was just started).
    """
    if is_watchdog_running():
        _log("[watchdog] Already running")
        return True

    if foreground:
        # In-process loop (tests). Never writes a PID file.
        return run_watchdog_loop(interval=interval, debug=debug) == 0

    state_dir = get_state_dir()
    state_dir.mkdir(parents=True, exist_ok=True)
    log_file = get_watchdog_log_file()

    cmd = [
        sys.executable, "-m", "run_claude.watchdog",
        "--interval", str(interval),
    ]
    if debug:
        cmd.append("--debug")

    with open(log_file, "a") as log_f:
        proc = subprocess.Popen(
            cmd,
            stdout=log_f,
            stderr=log_f,
            start_new_session=True,
        )

    pid_file = get_watchdog_pid_file()
    pid_file.write_text(str(proc.pid))
    _log(f"[watchdog] Started (pid={proc.pid})")

    # Confirm it didn't immediately die (mirrors start_front_proxy).
    time.sleep(0.5)
    if proc.poll() is not None:
        _log("[watchdog] Process exited unexpectedly", file=sys.stderr)
        pid_file.unlink(missing_ok=True)
        return False

    return True


def stop_watchdog() -> bool:
    """Stop the watchdog daemon.

    Writes a stop marker FIRST so a racing duplicate can't immediately restart
    the proxy, then SIGTERMs (escalating to SIGKILL) the watchdog process.
    The proxies themselves are left running.
    """
    mark_user_stop("watchdog-stopped")

    pid = get_watchdog_pid()
    pid_file = get_watchdog_pid_file()
    if pid is None:
        pid_file.unlink(missing_ok=True)
        return True

    try:
        os.kill(pid, signal.SIGTERM)

        # Wait for graceful exit (same shape as stop_proxy).
        for _ in range(10):
            try:
                os.kill(pid, 0)
                time.sleep(0.5)
            except ProcessLookupError:
                pid_file.unlink(missing_ok=True)
                _log(f"[watchdog] Stopped (pid={pid})")
                return True

        # Escalate.
        _log(f"[watchdog] pid {pid} didn't exit after SIGTERM, trying SIGKILL...", file=sys.stderr)
        os.kill(pid, signal.SIGKILL)
        time.sleep(0.5)
        try:
            os.kill(pid, 0)
            _log(f"[watchdog] Failed to kill process {pid}", file=sys.stderr)
            return False
        except ProcessLookupError:
            pid_file.unlink(missing_ok=True)
            return True

    except ProcessLookupError:
        pid_file.unlink(missing_ok=True)
        return True
    except PermissionError:
        _log(f"[watchdog] Permission denied stopping process {pid}", file=sys.stderr)
        return False


def run_watchdog_loop(interval: float = DEFAULT_INTERVAL, debug: bool = False) -> int:
    """Run the supervision loop until SIGINT/SIGTERM.

    Keeps both proxies alive, restarting either on crash unless an intentional
    stop marker is present. Returns a process exit code (0 on clean shutdown).
    """
    # Local import: proxy.py imports this module's functions via bottom-of-file
    # re-exports, so importing at module load would create a cycle.
    from . import proxy

    stop = {"flag": False}

    def _handler(signum, _frame):
        stop["flag"] = True
        _log(f"\n[watchdog] Signal {signum} received — shutting down...")

    signal.signal(signal.SIGINT, _handler)
    signal.signal(signal.SIGTERM, _handler)

    _log(f"[watchdog] Supervising proxy (interval={interval}s) — Ctrl-C/SIGTERM to stop")

    # If the proxy is already up when we start, a lingering marker from a prior
    # stop is stale: clear it so we supervise normally.
    if proxy.is_proxy_running() and proxy.health_check(timeout=5.0):
        clear_stop_marker()

    while not stop["flag"]:
        # Keep the front proxy alive — but honor a deliberate user stop, same as
        # the litellm path below. Without this gate, `proxy stop` + manual
        # restart races the watchdog's relaunch (two gateways contend for the
        # port → eaddrinuse crash loop).
        if not proxy.is_front_proxy_running():
            if was_user_stopped():
                if debug:
                    _log("[watchdog] Front proxy down but stopped by user — not restarting")
            else:
                _log("[watchdog] Front proxy down — starting")
                proxy.start_front_proxy(wait=True)

        proxy_down = not proxy.is_proxy_running() or not proxy.health_check(timeout=5.0)
        if proxy_down:
            if was_user_stopped():
                if debug:
                    _log("[watchdog] Proxy down but stopped by user — not restarting")
            else:
                _log("[watchdog] LiteLLM proxy down — restarting")
                clear_stop_marker()
                if not proxy.start_proxy(empty_config=True, debug=debug):
                    _log("[watchdog] Restart failed — will retry next tick")

        # Sleep in slices so signals are handled promptly.
        slept = 0.0
        while slept < interval and not stop["flag"]:
            time.sleep(0.5)
            slept += 0.5

    # Clean shutdown: record an intentional stop so a freshly-spawned watchdog
    # doesn't immediately bring the proxy back up against the user's intent.
    mark_user_stop("watchdog-shutdown")
    _log("[watchdog] Stopped.")
    return 0


def main() -> None:
    """CLI entry point for running the watchdog daemon standalone."""
    parser = argparse.ArgumentParser(
        prog="run-claude-watchdog",
        description="run-claude proxy watchdog (auto-restart on crash)",
    )
    parser.add_argument("--interval", type=float, default=DEFAULT_INTERVAL,
                        help=f"Seconds between liveness checks (default: {DEFAULT_INTERVAL})")
    parser.add_argument("--debug", action="store_true", help="Enable debug output")
    args = parser.parse_args()

    sys.exit(run_watchdog_loop(interval=args.interval, debug=args.debug))


if __name__ == "__main__":
    main()
