## How to: keep my Claude subscription billing while trying other providers

**Goal:** use your Claude Pro/Max subscription for Claude models (no per-token API charges) while still having Cerebras/Z.AI models available to try in the same session.
**Prereqs:** Claude Code already logged in with an active Pro/Max subscription (its own OAuth token, stored by Claude Code itself); run-claude installed.

1. Configure the directory (or run one-off) with the `claude-plan` profile:
   ```bash
   run-claude set-folder claude-plan
   direnv allow
   ```
   or for a single command without touching directory config:
   ```bash
   run-claude with claude-plan -- claude
   ```
2. Just use `claude` as normal. No extra auth setup is needed — Claude Code sends its own OAuth headers, and the front proxy (`:4443`) forwards any request for a `claude-*` model straight to `api.anthropic.com` with those headers untouched.
3. To also try the other providers bundled into this profile (`cerebras-pro/*`, `zai/*` — see `run-claude profiles show claude-plan`), just reference those model names; they route through the LiteLLM proxy with the master key instead, same as any other profile.

**Verify:** `run-claude status` shows `claude-plan` as the active profile. A request for a `claude-*` model won't appear as API usage in your Anthropic console — it draws against your subscription's plan usage instead.
**Gotchas:**
- Passthrough is decided per-request by model name prefix (`claude-`) — only `claude-*` models get OAuth passthrough billing; the `cerebras-pro/*` and `zai/*` models in the same profile still bill as API usage through LiteLLM.
- This only works through the front proxy (`:4443`). If `ANTHROPIC_BASE_URL` somehow points straight at the LiteLLM proxy (`:4444`), passthrough never happens and Claude-model calls bill as API usage too.
- You don't need to set `ANTHROPIC_OAUTH_TOKEN` in `~/.config/run-claude/.secrets` — that's only for making the proxy itself place authenticated Anthropic calls outside of Claude Code. Claude Code supplies its own token per request.
