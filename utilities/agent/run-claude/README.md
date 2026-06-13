# run-claude - Agent Shim Controller for Claude

Directory-aware model routing via LiteLLM proxy.

## Overview

`run-claude` turns folder context into live inference overrides. When you `cd` into a directory that declares an agent shim profile, the directory's required models get added to a running LiteLLM proxy, and environment variables are set so your tools (Claude Code, etc.) route through the proxy.

## Architecture

The system uses a two-layer configuration:

1. **Model Definitions** (`models.yaml`) - Standalone LiteLLM model configurations
2. **Profiles** - Lightweight references to model definitions (opus/sonnet/haiku tiers)

This separation allows:
- Reuse of model definitions across profiles
- User overrides without duplicating entire profiles
- Cleaner, more maintainable configuration

## Environment Variables

When `run-claude` sets up the system before invoking Claude, it exports these environment variables:

```bash
export ANTHROPIC_AUTH_TOKEN="sk-litellm-proxy"
export ANTHROPIC_BASE_URL="http://localhost:4000"
export API_TIMEOUT_MS=3000000
export ANTHROPIC_DEFAULT_HAIKU_MODEL="${_META_HAIKU}"
export ANTHROPIC_DEFAULT_SONNET_MODEL="${_META_SONNET}"
export ANTHROPIC_DEFAULT_OPUS_MODEL="${_META_OPUS}"
```

The `_META_*` values are populated from the active profile's model definitions.

## Installation

1. Install uv (if not already installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. Sync dependencies (uv will handle this automatically on first run):
   ```bash
   cd tools/run-claude && uv sync
   ```

3. Install shell hooks:
   ```bash
   ./hooks/install.sh
   ```

4. Ensure `run-claude` is in your PATH (or use the symlink in `bin/`).

## Quick Start

1. Configure a folder with a profile:
   ```bash
   cd /path/to/my/project
   run-claude set-folder cerebras
   direnv allow
   ```

2. The folder now uses the Cerebras profile when you enter it.

## Commands

### Directory Management

```bash
run-claude set-folder <profile>   # Configure current directory
run-claude enter <token> <profile> # Activate a profile (used by shell hook)
run-claude leave <token>          # Deactivate a profile (used by shell hook)
run-claude janitor                # Clean up expired model leases
```

### Status

```bash
run-claude status                 # Show current state
```

### Environment

```bash
run-claude env <profile>          # Print environment variables
run-claude env <profile> --export # Print export statements
```

### Proxy Management

```bash
run-claude proxy start            # Start LiteLLM proxy
run-claude proxy stop             # Stop proxy
run-claude proxy status           # Show proxy status
run-claude proxy health           # Health check
```

### Profile Management

```bash
run-claude profiles list          # List available profiles
run-claude profiles show <name>   # Show profile details
run-claude profiles install       # Install built-in profiles to user config
```

### Model Management

```bash
run-claude models list            # List available model definitions
run-claude models show <name>     # Show model definition details
```

### Secrets Management

```bash
run-claude secrets init           # Initialize secrets template
run-claude secrets path           # Show secrets file location
run-claude secrets export         # Export secrets to .env for Docker
```

For detailed secrets management guide, see [SECRETS.md](SECRETS.md).

## Per-Command Wrapper

Use `with-agent-shim` to run a single command with a specific profile:

```bash
with-agent-shim cerebras -- claude
with-agent-shim groq -- python inference.py
```

## Model Definitions

Model definitions are stored in `models.yaml` and define standalone LiteLLM configurations:

```yaml
model_list:
  - model_name: "cerebras/qwen-3-32b.thinking"
    litellm_params:
      model: cerebras/qwen-3-32b
      api_key: os.environ/CEREBRAS_API_KEY
      api_base: https://api.cerebras.ai/v1
      drop_params: true
      additional_drop_params: ["context_management", "thinking"]
```

**Locations:**
- Built-in: `run_claude/models.yaml`
- User overrides: `~/.config/agent-shim/models.yaml`

User definitions override built-in definitions with the same `model_name`.

## Profiles

Profiles are lightweight YAML files that reference model definitions:

```yaml
meta:
  name: "Profile Name"
  opus_model: "model-name-for-opus"
  sonnet_model: "model-name-for-sonnet"
  haiku_model: "model-name-for-haiku"
```

Built-in profiles:
- `cerebras` / `cerebras2` - Cerebras inference (fast)
- `groq` / `groq2` - Groq inference (fast)
- `anthropic` - Native Anthropic
- `openai` - OpenAI models
- `azure` - Azure OpenAI
- `gemini` - Google Gemini
- `grok` - xAI Grok
- `deepseek` - DeepSeek
- `mistral` - Mistral AI
- `perplexity` - Perplexity AI
- `local` - Ollama/vLLM local models
- `multi` - Multi-provider routing

User profiles are stored in `~/.config/agent-shim/profiles/`.

## LiteLLM Config

The proxy is started with a generated config that includes:

```yaml
litellm_settings:
  drop_params: false
  forward_client_headers_to_llm_api: true
general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
model_list:
  # ... all model definitions
```

## How It Works

1. **Shell hook** detects when `AGENT_SHIM_TOKEN` changes (set by direnv)
2. **run-claude enter** registers models with the LiteLLM proxy
3. **Environment variables** are set to route traffic through the proxy
4. **run-claude leave** decrements refcounts when you leave the directory
5. **run-claude janitor** cleans up unused models after 15 minutes

## Files

- State: `~/.local/state/agent-shim/state.json`
- Generated config: `~/.local/state/agent-shim/litellm_config.yaml`
- Proxy PID: `~/.local/state/agent-shim/proxy.pid`
- Proxy log: `~/.local/state/agent-shim/proxy.log`
- User profiles: `~/.config/agent-shim/profiles/`
- User model overrides: `~/.config/agent-shim/models.yaml`
