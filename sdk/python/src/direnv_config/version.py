from __future__ import annotations

import os
import threading
import time
from pathlib import Path
from typing import Callable


def read_version(store: Path) -> int:
    version_file = store / ".version"
    try:
        contents = version_file.read_text().strip()
        return int(contents)
    except (FileNotFoundError, ValueError, OSError):
        return 0


def bump_version(store: Path) -> int:
    """Atomically increment the version counter. Returns the new version."""
    current = read_version(store)
    new_version = current + 1
    tmp_file = store / ".version.tmp"
    version_file = store / ".version"
    tmp_file.write_text(str(new_version))
    os.rename(tmp_file, version_file)
    return new_version


class DcWatcher:
    def __init__(
        self,
        store: Path,
        callback: Callable[[int], None],
        interval_ms: int = 1000,
    ) -> None:
        self._store = store
        self._callback = callback
        self._interval = interval_ms / 1000.0
        self._last_version = read_version(store)
        self._stop_event = threading.Event()
        self._thread: threading.Thread | None = None

    def _poll(self) -> None:
        while not self._stop_event.is_set():
            current = read_version(self._store)
            if current != self._last_version:
                self._last_version = current
                self._callback(current)
            self._stop_event.wait(self._interval)

    def start(self) -> None:
        if self._thread is not None:
            return
        self._stop_event.clear()
        self._thread = threading.Thread(target=self._poll, daemon=True)
        self._thread.start()

    def stop(self) -> None:
        self._stop_event.set()
        if self._thread is not None:
            self._thread.join(timeout=self._interval * 2)
            self._thread = None

    def __enter__(self) -> DcWatcher:
        self.start()
        return self

    def __exit__(self, *args: object) -> None:
        self.stop()
