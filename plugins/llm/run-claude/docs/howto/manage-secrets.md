## How to: manage API keys and database secrets

**Goal:** get real provider API keys and the TimescaleDB password into `run-claude` safely, and share them with the Docker Compose stack when needed.
**Prereqs:** run-claude installed; nothing else — the secrets template is auto-created on first CLI run.

1. Create the secrets template (auto-generates a strong DB password too):
   ```bash
   run-claude secrets init --generate
   ```
   Without `--generate` it creates the template but leaves the password field for you to fill in.
2. Edit it and fill in real values:
   ```bash
   nano ~/.config/run-claude/.secrets
   ```
   At minimum set:
   ```yaml
   RUN_CLAUDE_TIMESCALEDB_PASSWORD: "your-postgres-password"
   ANTHROPIC_API_KEY: "sk-your-real-token"
   ```
3. Export to a Docker-Compose-readable `.env`:
   ```bash
   run-claude secrets export
   ```
4. Start the TimescaleDB stack (auto-loads the exported `.env`):
   ```bash
   cd dep
   docker compose up -d
   ```

**Verify:** `run-claude secrets path` prints `~/.config/run-claude/.secrets`; `ls -la ~/.config/run-claude/.env` shows the exported file with `0600` perms after step 3.
**Gotchas:**
- Both `.secrets` and `.env` are written `0600` (owner-only) — if you see permission errors reading them, check ownership, don't loosen the mode.
- `run-claude secrets export` fails silently (returns exit 1, no traceback) if the secrets file is malformed YAML — validate with a YAML linter if export produces no output.
- Never commit either file; they live under `~/.config/run-claude/`, outside the repo, by design.
- For programmatic access from Python: `from run_claude.config import load_secrets; secrets = load_secrets()`, then `secrets.get("KEY", default)` or `secrets.to_env()`.
- Full reference: [SECRETS.md](../../SECRETS.md), [SECRETS_ADVANCED.md](../../SECRETS_ADVANCED.md), [SECRETS_QUICKSTART.md](../../SECRETS_QUICKSTART.md).
