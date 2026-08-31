# Claude Switch Playground

Test directories for validating the run-claude directory-based profile switching.

## Directory Structure

```
playground/
├── cerebras-project/   # Uses cerebras profile (fast inference)
├── groq-project/       # Uses groq profile (fast inference)
├── local-project/      # Uses local profile (Ollama/vLLM)
└── multi-project/      # Uses multi profile (multi-provider routing)
```

## Testing

### Prerequisites

1. Install run-claude hooks:
   ```bash
   ../run-claude/hooks/install.sh
   ```

2. Restart your shell or source your rc file.

### Manual Testing

1. Navigate to a project directory:
   ```bash
   cd cerebras-project
   direnv allow  # First time only
   ```

2. Check the environment:
   ```bash
   echo "Token: $AGENT_SHIM_TOKEN"
   echo "Profile: $AGENT_SHIM_PROFILE"
   env | grep ANTHROPIC
   ```

3. Check run-claude state:
   ```bash
   run-claude status
   ```

4. Navigate away and back:
   ```bash
   cd ..
   run-claude status  # Should show token removed
   cd cerebras-project
   run-claude status  # Should show token active again
   ```

### Automated Test

Run the test script:
```bash
./test-switching.sh
```

## How It Works

Each directory contains:
- `.envrc` - Sets `AGENT_SHIM_TOKEN` and loads `.envrc.user`
- `.envrc.user` - Sets `AGENT_SHIM_PROFILE` (e.g., "cerebras")
- `.gitignore` - Ignores both envrc files

When you `cd` into a directory:
1. direnv loads `.envrc` which sets the token and profile
2. The shell prompt hook detects the token change
3. `run-claude enter` is called to register models with the proxy
4. Environment variables are set to route through the proxy

When you `cd` out:
1. direnv unloads the environment
2. The prompt hook detects the token is gone
3. `run-claude leave` decrements refcounts
4. After 15 minutes, unused models are removed from the proxy
