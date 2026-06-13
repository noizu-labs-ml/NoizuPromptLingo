# Claude Code Environment Variables

A comprehensive reference for all environment variables recognized by [Claude Code](https://claude.ai/code). Set these in your shell, `.envrc`, or persistently via `settings.json` under the `env` key.

An example `.envrc` file is provided at [`.envrc.claudecode.example`](.envrc.claudecode.example) — copy it, uncomment the variables you need, and source it.

---

## Authentication & API Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `ANTHROPIC_API_KEY` | *(none)* | API key sent as `X-Api-Key` header. Overrides Claude Pro/Team/Enterprise subscription when set. |
| `ANTHROPIC_AUTH_TOKEN` | *(none)* | Custom value for the `Authorization: Bearer` header |
| `ANTHROPIC_BASE_URL` | `https://api.anthropic.com` | Override API endpoint for proxy or gateway routing |
| `ANTHROPIC_CUSTOM_HEADERS` | *(none)* | Extra headers on requests (`Name: Value`, newline-separated) |

## Model Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `ANTHROPIC_MODEL` | *(auto)* | Model setting name |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | *(latest haiku)* | Override default Haiku-class model |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | *(latest sonnet)* | Override default Sonnet-class model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | *(latest opus)* | Override default Opus-class model |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | *(none)* | Model ID to add as custom entry in `/model` picker |
| `ANTHROPIC_CUSTOM_MODEL_OPTION_NAME` | *(model ID)* | Display name for custom model |
| `ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION` | `Custom model (<id>)` | Display description for custom model |
| `ANTHROPIC_SMALL_FAST_MODEL` | *(deprecated)* | Haiku-class model for background tasks |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | *(none)* | AWS region override for Haiku on Bedrock |
| `CLAUDE_CODE_EFFORT_LEVEL` | `auto` | Effort level: `low`, `medium`, `high`, `max` (Opus only), `auto` |
| `CLAUDE_CODE_SUBAGENT_MODEL` | *(inherits parent)* | Model override for subagents |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | *(model default)* | Max output tokens per request |
| `MAX_THINKING_TOKENS` | *(model default)* | Extended thinking token budget (`0` = disable) |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | `0` | `1` to disable adaptive reasoning (Opus/Sonnet 4.6) |
| `CLAUDE_CODE_DISABLE_1M_CONTEXT` | `0` | `1` to disable 1M context window |
| `DISABLE_PROMPT_CACHING` | `0` | `1` to disable prompt caching for all models |
| `DISABLE_PROMPT_CACHING_HAIKU` | `0` | `1` to disable prompt caching for Haiku |
| `DISABLE_PROMPT_CACHING_SONNET` | `0` | `1` to disable prompt caching for Sonnet |
| `DISABLE_PROMPT_CACHING_OPUS` | `0` | `1` to disable prompt caching for Opus |

## Cloud Providers

### AWS Bedrock

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_USE_BEDROCK` | `0` | Enable AWS Bedrock integration |
| `AWS_BEARER_TOKEN_BEDROCK` | *(none)* | Bedrock API key |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | `0` | Skip AWS auth (for LLM gateways) |

### Google Vertex AI

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_USE_VERTEX` | `0` | Enable Vertex AI integration |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | `0` | Skip Google auth |
| `VERTEX_REGION_CLAUDE_3_5_HAIKU` | *(auto)* | Region override for Claude 3.5 Haiku |
| `VERTEX_REGION_CLAUDE_3_7_SONNET` | *(auto)* | Region override for Claude 3.7 Sonnet |
| `VERTEX_REGION_CLAUDE_4_0_OPUS` | *(auto)* | Region override for Claude 4.0 Opus |
| `VERTEX_REGION_CLAUDE_4_0_SONNET` | *(auto)* | Region override for Claude 4.0 Sonnet |
| `VERTEX_REGION_CLAUDE_4_1_OPUS` | *(auto)* | Region override for Claude 4.1 Opus |

### Microsoft Foundry

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_USE_FOUNDRY` | `0` | Enable Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_API_KEY` | *(none)* | Foundry API key |
| `ANTHROPIC_FOUNDRY_RESOURCE` | *(none)* | Foundry resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | *(none)* | Full Foundry base URL |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | `0` | Skip Azure auth |

## Bash & Shell Execution

| Variable | Default | Purpose |
|----------|---------|---------|
| `BASH_DEFAULT_TIMEOUT_MS` | `120000` | Default timeout for bash commands (ms) |
| `BASH_MAX_TIMEOUT_MS` | `600000` | Maximum timeout the model can set (ms) |
| `BASH_MAX_OUTPUT_LENGTH` | *(auto)* | Max characters before middle-truncation |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | `0` | Return to original working dir after each command |
| `CLAUDE_CODE_SHELL` | *(auto-detected)* | Override shell (`bash`, `zsh`) |
| `CLAUDE_CODE_SHELL_PREFIX` | *(none)* | Command prefix wrapping all bash commands |
| `CLAUDECODE` | `1` *(in Claude shells)* | Detect when a script runs inside Claude Code |
| `CLAUDE_ENV_FILE` | *(none)* | Shell script sourced before each Bash command |

## Context Window & Memory

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `95` | Context capacity % at which auto-compaction triggers |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | *(model context window)* | Context capacity in tokens for compaction calculations |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | `0` | `1` to disable auto memory |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | `0` | `1` to load CLAUDE.md from `--add-dir` directories |
| `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | *(auto)* | Token limit for file reads |

## Network & Proxy

| Variable | Default | Purpose |
|----------|---------|---------|
| `HTTP_PROXY` | *(none)* | HTTP proxy server |
| `HTTPS_PROXY` | *(none)* | HTTPS proxy server |
| `NO_PROXY` | *(none)* | Domains/IPs to bypass proxy |
| `CLAUDE_CODE_PROXY_RESOLVES_HOSTS` | `false` | Let proxy handle DNS resolution |

## mTLS & Certificates

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_CLIENT_CERT` | *(none)* | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | *(none)* | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | *(none)* | Passphrase for encrypted client key |

## MCP (Model Context Protocol)

| Variable | Default | Purpose |
|----------|---------|---------|
| `ENABLE_TOOL_SEARCH` | `auto` | Tool search: `true`, `auto`, `auto:N`, `false` |
| `MCP_TIMEOUT` | *(default)* | Server startup timeout (ms) |
| `MCP_TOOL_TIMEOUT` | *(default)* | Tool execution timeout (ms) |
| `MAX_MCP_OUTPUT_TOKENS` | `25000` | Max tokens in MCP responses (warning at 10,000) |
| `MCP_OAUTH_CALLBACK_PORT` | *(auto)* | Fixed port for OAuth redirect |
| `MCP_CLIENT_SECRET` | *(none)* | OAuth client secret for MCP servers |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | `true` | `false` to disable claude.ai MCP servers |

## Plugins

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | `120000` | Git timeout for plugin install/update (ms) |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | *(none)* | Read-only plugin seed directories (`:` separated) |
| `FORCE_AUTOUPDATER_PLUGINS` | `false` | Force plugin auto-updates |

## Automation & Scheduling

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_DISABLE_CRON` | `0` | `1` to disable scheduled tasks and `/loop` |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | `0` | `1` to disable background tasks and Ctrl+B |
| `CLAUDE_CODE_EXIT_AFTER_STOP_DELAY` | *(none)* | Auto-exit delay after idle (ms) |

## UI & Terminal

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` | `0` | `1` to disable terminal title updates |
| `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION` | `true` | `false` to disable prompt suggestions |
| `CLAUDE_CODE_ENABLE_TASKS` | `false` | `true` to enable task tracking in `-p` mode |
| `CLAUDE_CODE_TASK_LIST_ID` | *(none)* | Share task list across sessions |
| `IS_DEMO` | `false` | Demo mode: hides email, skips onboarding |

## Git & Workflows

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | `0` | `1` to strip git/commit/PR instructions from system prompt |

## Telemetry & Reporting

| Variable | Default | Purpose |
|----------|---------|---------|
| `DISABLE_TELEMETRY` | `0` | `1` to opt out of Statsig telemetry |
| `DISABLE_ERROR_REPORTING` | `0` | `1` to opt out of Sentry error reporting |
| `DISABLE_FEEDBACK_COMMAND` | `0` | `1` to disable `/feedback` command |
| `DISABLE_COST_WARNINGS` | `0` | `1` to disable cost warning messages |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | `0` | `1` to disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `0` | Equivalent to disabling autoupdater + feedback + error reporting + telemetry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `0` | `1` to enable OpenTelemetry collection |
| `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS` | `1740000` | OTel headers refresh interval (ms, ~29 min) |

## Installation & Updates

| Variable | Default | Purpose |
|----------|---------|---------|
| `DISABLE_AUTOUPDATER` | `0` | `1` to disable automatic updates |
| `DISABLE_INSTALLATION_CHECKS` | `0` | `1` to disable installation warnings |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | `0` | Skip auto-installation of IDE extensions |

## Directories & Paths

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CONFIG_DIR` | `~/.claude` | Custom config/data directory |
| `CLAUDE_CODE_TMPDIR` | `/tmp` | Override temp directory (appends `/claude/`) |
| `CLAUDE_CODE_NEW_INIT` | `false` | `true` for interactive `/init` setup flow |

## Features & Experimental

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_SIMPLE` | `0` | `1` for minimal/bare mode (no hooks, skills, MCP, etc.) |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | `0` | `1` to disable fast mode |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `0` | `1` to enable agent teams |
| `CLAUDE_CODE_SKIP_FAST_MODE_NETWORK_ERRORS` | `0` | `1` to allow fast mode when org check fails |
| `USE_BUILTIN_RIPGREP` | `1` | `0` to use system-installed `rg` |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | *(auto)* | Character budget for skill metadata |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | `1500` | Max time for SessionEnd hooks (ms) |
| `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` | `0` | `1` to strip `anthropic-beta` headers |

## Account & Organization (SDK Callers)

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_CODE_ACCOUNT_UUID` | *(none)* | Account UUID for SDK callers |
| `CLAUDE_CODE_USER_EMAIL` | *(none)* | User email for SDK callers |
| `CLAUDE_CODE_ORGANIZATION_UUID` | *(none)* | Organization UUID for SDK callers |
