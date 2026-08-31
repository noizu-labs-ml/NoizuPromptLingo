"""Tests for run_claude.watchdog module.

Covers the stop-marker logic, watchdog lifecycle idempotency, stale-PID
cleanup, and the supervision loop's restart decision.

Note: these tests import the watchdog/state modules directly and stub the
proxy module for the loop tests, so they do not require litellm to be
installed (the proxy module imports httpx lazily and references litellm
elsewhere). Marker tests monkeypatch get_state_dir to a tmp_path.
"""

import json
import os
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from run_claude import watchdog


@pytest.fixture
def tmp_state_dir(tmp_path, monkeypatch):
    """Redirect the watchdog state dir to a tmp_path."""
    monkeypatch.setattr(watchdog, "get_state_dir", lambda: tmp_path)
    # state.get_stop_marker_file is resolved at call time from get_state_dir,
    # but watchdog imported the symbol by value — patch it directly too.
    monkeypatch.setattr(watchdog, "get_stop_marker_file", lambda: tmp_path / "stop.marker")
    return tmp_path


# ---------------------------------------------------------------------------
# Stop marker
# ---------------------------------------------------------------------------


class TestStopMarker:
    def test_mark_creates_marker(self, tmp_state_dir):
        assert not watchdog.was_user_stopped()
        watchdog.mark_user_stop("test-reason")
        assert watchdog.was_user_stopped()
        record = json.loads((tmp_state_dir / "stop.marker").read_text())
        assert record["reason"] == "test-reason"
        assert "ts" in record and "pid" in record

    def test_clear_removes_marker(self, tmp_state_dir):
        watchdog.mark_user_stop("user")
        assert watchdog.was_user_stopped()
        watchdog.clear_stop_marker()
        assert not watchdog.was_user_stopped()

    def test_clear_when_absent_is_noop(self, tmp_state_dir):
        # Should not raise if no marker exists.
        watchdog.clear_stop_marker()
        assert not watchdog.was_user_stopped()

    def test_was_user_stopped_false_when_absent(self, tmp_state_dir):
        assert watchdog.was_user_stopped() is False


# ---------------------------------------------------------------------------
# Watchdog lifecycle
# ---------------------------------------------------------------------------


class TestWatchdogLifecycle:
    def test_is_watchdog_running_false_when_no_pidfile(self, tmp_state_dir):
        assert watchdog.is_watchdog_running() is False

    def test_is_watchdog_running_cleans_stale_pid(self, tmp_state_dir):
        # Write a PID that is guaranteed not to exist.
        bogus_pid = 2**31 - 1
        (tmp_state_dir / "watchdog.pid").write_text(str(bogus_pid))
        assert watchdog.is_watchdog_running() is False
        # Stale pidfile should have been removed.
        assert not (tmp_state_dir / "watchdog.pid").exists()

    def test_get_watchdog_pid_none_when_no_pidfile(self, tmp_state_dir):
        assert watchdog.get_watchdog_pid() is None

    def test_get_watchdog_pid_returns_live_pid(self, tmp_state_dir):
        # Use our own process as a stand-in for a live pid.
        (tmp_state_dir / "watchdog.pid").write_text(str(os.getpid()))
        assert watchdog.get_watchdog_pid() == os.getpid()

    def test_start_watchdog_noop_when_already_running(self, tmp_state_dir):
        """A running watchdog must not spawn a second subprocess."""
        with patch.object(watchdog, "is_watchdog_running", return_value=True):
            with patch("run_claude.watchdog.subprocess.Popen") as popen:
                assert watchdog.start_watchdog() is True
                popen.assert_not_called()

    def test_start_watchdog_foreground_runs_loop(self, tmp_state_dir):
        """foreground=True runs the loop in-process instead of detaching."""
        with patch.object(watchdog, "run_watchdog_loop", return_value=0) as loop:
            with patch.object(watchdog, "is_watchdog_running", return_value=False):
                assert watchdog.start_watchdog(foreground=True) is True
                loop.assert_called_once()

    def test_start_watchdog_spawns_detached_process(self, tmp_state_dir):
        """When not foreground and not running, a detached subprocess is spawned."""
        fake_proc = MagicMock()
        fake_proc.pid = 4242
        fake_proc.poll.return_value = None  # still alive after 0.5s
        with patch.object(watchdog, "is_watchdog_running", return_value=False):
            with patch("run_claude.watchdog.subprocess.Popen", return_value=fake_proc) as popen:
                with patch("run_claude.watchdog.time.sleep"):  # skip the 0.5s wait
                    assert watchdog.start_watchdog() is True
                    popen.assert_called_once()
                    # PID file written.
                    assert (tmp_state_dir / "watchdog.pid").read_text() == "4242"
                    # Detached via start_new_session.
                    kwargs = popen.call_args.kwargs
                    assert kwargs.get("start_new_session") is True

    def test_start_watchdog_detects_immediate_death(self, tmp_state_dir):
        """If the spawned process exits immediately, start fails and cleans up."""
        fake_proc = MagicMock()
        fake_proc.pid = 9999
        fake_proc.poll.return_value = 1  # died
        with patch.object(watchdog, "is_watchdog_running", return_value=False):
            with patch("run_claude.watchdog.subprocess.Popen", return_value=fake_proc):
                with patch("run_claude.watchdog.time.sleep"):
                    assert watchdog.start_watchdog() is False
                    assert not (tmp_state_dir / "watchdog.pid").exists()


class TestStopWatchdog:
    def test_stop_marks_user_stop_first(self, tmp_state_dir):
        """stop_watchdog writes a stop marker so a racing duplicate won't restart."""
        # Pretend there is no live watchdog process.
        with patch.object(watchdog, "get_watchdog_pid", return_value=None):
            assert watchdog.stop_watchdog() is True
        assert watchdog.was_user_stopped() is True

    def test_stop_kills_running_pid(self, tmp_state_dir):
        (tmp_state_dir / "watchdog.pid").write_text(str(os.getpid()))
        kills = []

        def fake_kill(pid, sig):
            if pid == os.getpid():
                # Don't actually kill the test process.
                raise ProcessLookupError

        with patch("run_claude.watchdog.os.kill", side_effect=fake_kill):
            with patch("run_claude.watchdog.time.sleep"):
                assert watchdog.stop_watchdog() is True
        # pidfile removed.
        assert not (tmp_state_dir / "watchdog.pid").exists()


# ---------------------------------------------------------------------------
# Supervision loop restart decision
# ---------------------------------------------------------------------------


@pytest.fixture
def stub_proxy(monkeypatch):
    """Inject a fake proxy module into sys.modules so the loop's local import finds it."""
    fake = MagicMock()
    fake.is_front_proxy_running.return_value = True
    fake.is_proxy_running.return_value = True
    fake.health_check.return_value = True
    fake.start_proxy.return_value = True
    fake.start_front_proxy.return_value = True
    monkeypatch.setitem(__import__("sys").modules, "run_claude.proxy", fake)
    monkeypatch.setattr("run_claude.proxy", fake, raising=False)
    return fake


class TestWatchdogLoop:
    """Loop tests drive the loop to exit by sending SIGTERM to ourselves after
    N sleep calls — the loop's real signal handler then sets its stop flag.
    """

    def _sigterm_after(self, n):
        """Return a fake sleep that sends SIGTERM to this process on the Nth call."""
        import signal as _signal

        def fake_sleep(seconds):
            fake_sleep.calls += 1
            if fake_sleep.calls >= n:
                os.kill(os.getpid(), _signal.SIGTERM)

        fake_sleep.calls = 0
        return fake_sleep

    def test_restarts_proxy_on_crash(self, tmp_state_dir, stub_proxy):
        """Proxy down + NOT user-stopped -> start_proxy called."""
        stub_proxy.is_proxy_running.return_value = False
        stub_proxy.health_check.return_value = False
        watchdog.clear_stop_marker()

        with patch("run_claude.watchdog.time.sleep", side_effect=self._sigterm_after(2)):
            watchdog.run_watchdog_loop(interval=0.1)

        stub_proxy.start_proxy.assert_called()
        # The restart path clears the marker before starting; the marker that's
        # present now is the watchdog's own shutdown marker (written on clean
        # exit), NOT a user stop that suppressed the restart. The restart
        # happening at all is the proof it wasn't treated as a user stop.

    def test_does_not_restart_when_user_stopped(self, tmp_state_dir, stub_proxy):
        """Proxy down + user-stopped -> start_proxy NOT called."""
        stub_proxy.is_proxy_running.return_value = False
        stub_proxy.health_check.return_value = False
        watchdog.mark_user_stop("proxy-stop")

        with patch("run_claude.watchdog.time.sleep", side_effect=self._sigterm_after(2)):
            watchdog.run_watchdog_loop(interval=0.1, debug=True)

        # The key behavior: a user stop marker suppresses the restart entirely.
        stub_proxy.start_proxy.assert_not_called()
        # Marker present (still the original proxy-stop marker — restart path,
        # which would have cleared it, never ran).
        assert watchdog.was_user_stopped()

    def test_no_restart_when_healthy(self, tmp_state_dir, stub_proxy):
        """Everything healthy -> no restart."""
        stub_proxy.is_proxy_running.return_value = True
        stub_proxy.health_check.return_value = True
        stub_proxy.is_front_proxy_running.return_value = True

        with patch("run_claude.watchdog.time.sleep", side_effect=self._sigterm_after(2)):
            watchdog.run_watchdog_loop(interval=0.1)

        stub_proxy.start_proxy.assert_not_called()
        stub_proxy.start_front_proxy.assert_not_called()

    def test_restarts_front_proxy_when_down(self, tmp_state_dir, stub_proxy):
        """Front proxy down -> start_front_proxy called."""
        stub_proxy.is_front_proxy_running.return_value = False
        stub_proxy.is_proxy_running.return_value = True
        stub_proxy.health_check.return_value = True

        with patch("run_claude.watchdog.time.sleep", side_effect=self._sigterm_after(2)):
            watchdog.run_watchdog_loop(interval=0.1)

        stub_proxy.start_front_proxy.assert_called()

    def test_clean_shutdown_marks_user_stop(self, tmp_state_dir, stub_proxy):
        """On clean SIGTERM shutdown the loop writes a stop marker."""
        stub_proxy.is_proxy_running.return_value = True
        stub_proxy.health_check.return_value = True
        watchdog.clear_stop_marker()

        with patch("run_claude.watchdog.time.sleep", side_effect=self._sigterm_after(1)):
            rc = watchdog.run_watchdog_loop(interval=0.1)

        assert rc == 0
        # Shutdown path wrote the marker.
        assert watchdog.was_user_stopped()


# ---------------------------------------------------------------------------
# stop_proxy(user_initiated=...) integration via stubbed proxy import
# ---------------------------------------------------------------------------


class TestStopProxyIntegration:
    def test_user_initiated_stop_writes_marker(self, tmp_state_dir):
        """Calling the real stop_proxy(user_initiated=True) writes the marker.

        We invoke stop_proxy through the real proxy module but stub out the
        process-kill path so no real process is touched.
        """
        from run_claude import proxy

        # This exercises the legacy litellm-proxy stop path (the unified gateway
        # is the default now and stops via stop_front_proxy instead).
        # No PID file -> stop_proxy's get_proxy_pid() returns None -> pgrep path.
        with patch.object(proxy, "use_unified_gateway", return_value=False), \
             patch.object(proxy, "get_proxy_pid", return_value=None):
            with patch("run_claude.proxy.subprocess.run") as run:
                # pgrep finds nothing -> return code 1 -> stop returns True.
                run.return_value = MagicMock(returncode=1, stdout="")
                result = proxy.stop_proxy(user_initiated=True)

        assert result is True
        assert watchdog.was_user_stopped() is True

    def test_default_stop_does_not_write_marker(self, tmp_state_dir):
        """stop_proxy() with default args does NOT trip the marker (crash path)."""
        from run_claude import proxy

        watchdog.clear_stop_marker()
        with patch.object(proxy, "get_proxy_pid", return_value=None):
            with patch("run_claude.proxy.subprocess.run") as run:
                run.return_value = MagicMock(returncode=1, stdout="")
                proxy.stop_proxy()

        assert watchdog.was_user_stopped() is False
