## How to: keep the proxy pair alive across crashes

**Goal:** run the front proxy (:4443) and LiteLLM proxy (:4444) so they auto-restart on crash, without an intentional `proxy stop` getting silently undone.
**Prereqs:** run-claude installed.

1. Start the watchdog daemon explicitly (it also self-starts on every `run-claude enter`, so this is mostly for standalone use):
   ```bash
   run-claude watchdog start
   run-claude watchdog start --interval 10   # check liveness every 10s (default 5)
   ```
2. Check status:
   ```bash
   run-claude watchdog status
   # Watchdog:
   #   Status: running
   #   PID: <pid>
   #   Log: ~/.local/state/run-claude/watchdog.log
   ```
3. Stop it (proxies keep running unless you say otherwise):
   ```bash
   run-claude watchdog stop                # stop watchdog only
   run-claude watchdog stop --with-proxy   # also stop front + LiteLLM proxy
   ```
4. Manage the proxies directly when you don't need the watchdog:
   ```bash
   run-claude proxy start [--no-db]     # LiteLLM proxy (auto-starts TimescaleDB unless --no-db)
   run-claude proxy stop [--with-db|--all]
   run-claude proxy restart
   run-claude proxy status
   run-claude proxy health
   ```

**Verify:** kill the LiteLLM proxy process manually (`kill <pid>` from `run-claude proxy status`) while the watchdog is running — within one interval it respawns, visible in `run-claude proxy status` again.
**Gotchas:**
- A deliberate `run-claude proxy stop` writes a `stop.marker` sentinel so the watchdog does *not* fight you and restart it — but this means if you delete that marker file by hand, an already-running watchdog will bring the proxy back up on its next check.
- `run-claude proxy supervise` is deprecated in favor of `run-claude watchdog start` — same self-healing intent, but the watchdog is a detached daemon rather than a foreground process you have to keep a terminal open for.
- `enter` re-spawns the watchdog on every prompt in a shimmed directory as a self-heal — this is intentional and cheap (idempotent PID check), not a sign of a bug if you see it fire repeatedly.
- Database container management is separate from the proxy watchdog: `run-claude db start|stop|status|migrate`. `proxy start` auto-starts the DB unless you pass `--no-db`.
