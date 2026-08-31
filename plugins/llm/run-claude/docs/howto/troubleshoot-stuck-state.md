## How to: get out of a stuck/half-registered directory state

**Goal:** recover when a directory's models aren't showing up, a profile change isn't taking effect, or the proxy's model table looks inconsistent with state.json.
**Prereqs:** run-claude installed.

1. Look at overall state first:
   ```bash
   run-claude status                # token/profile/proxy summary for this directory
   run-claude proxy health          # is the LiteLLM proxy actually answering
   run-claude models enabled        # what's really live in the proxy right now
   ```
2. Force a full reload of model/profile definitions and re-register with the proxy (clears caches, re-adds models even if the loader thinks they're already there):
   ```bash
   run-claude enter "$AGENT_SHIM_TOKEN" "$AGENT_SHIM_PROFILE" --refresh
   # or, for a one-off run:
   run-claude with <profile> --refresh -- claude
   ```
3. If refcounts/leases look wrong (e.g. a model won't go away after leaving a directory), run the janitor manually — it only auto-runs once a minute:
   ```bash
   run-claude janitor --force
   ```
   Expired leases (models at refcount 0 for 15+ minutes) get deleted from the proxy at this point.
4. As a last resort, wipe every model from the proxy's database and let the next `enter` re-register from scratch:
   ```bash
   run-claude models wipe --force
   ```

**Verify:** after `--refresh` or `janitor --force`, `run-claude models enabled` matches what the active profile(s) actually declare.
**Gotchas:**
- `enter` no longer blocks for minutes on a crashed-but-alive proxy process — it detects the unhealthy HTTP endpoint and restarts the proxy instead of waiting on `wait_for_recovery`. If you're on an older build and see multi-minute hangs on `cd`, that's the bug this behavior fixed; update.
- `run-claude leave` is a no-op if the token isn't found in state — don't expect an error if you `leave` a directory you never `enter`ed (e.g. after a state.json wipe).
- `models wipe` deletes from the proxy's model table directly; it does not touch your `models.yaml` definitions, only what's currently registered.
- If nothing above helps, check `run-claude proxy status` for the log path and read `~/.local/state/run-claude/proxy.log` — sensitive keys are redacted there, so it's safe to paste for debugging.
