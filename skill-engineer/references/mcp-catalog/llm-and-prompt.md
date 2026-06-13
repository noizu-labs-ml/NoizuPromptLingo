# Category: LLM and Prompt

## Overview
Use tools in this category when a skill needs to evaluate prompt quality, route requests across providers, apply curated prompt patterns, or manage cost and latency across multiple LLM backends. This category is essential for trl-ai-templates skills and any skill that generates or optimizes prompts as a core output.

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| MCP Omnisearch | self-hosted / local | Unified search: Tavily + Brave + Kagi + Exa in one interface | API keys per provider; no data pooling | Beta |

### MCP Omnisearch
- **What it does**: Single MCP interface that routes search queries to Tavily, Brave, Kagi, and Exa. Returns unified ranked results without switching tools.
- **Deployment**: Self-hosted local stdio; requires API keys for each enabled provider
- **Key features**: Provider fallback, result deduplication, source attribution; Exa for semantic/neural search, Brave for privacy-first, Tavily for RAG-optimized results
- **Security considerations**: Each provider key is stored in env vars. Kagi is tied to a personal account — avoid using in shared environments. Queries are sent to external providers; do not include PII or secrets in search terms.
- **When to use**: Skills that need multi-source research (trl-market-intelligence, trl-seo-guru, trl-content-publishing). Prefer when a single provider's coverage is insufficient.
- **When to avoid**: Simple single-provider searches where direct API calls suffice; cost-sensitive environments where multiple provider calls per query are prohibitive

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| Promptfoo | `npm install -g promptfoo` | LLM eval framework, red teaming, CI/CD integration | Evaluating prompt quality, catching regressions, safety testing |
| Fabric | `go install github.com/danielmiessler/fabric@latest` | 200+ curated prompt patterns, pipe-based Unix workflow | Applying battle-tested patterns; rapid prompt assembly |
| LiteLLM | `pip install litellm` | Unified API for 100+ providers, MCP gateway, cost tracking | Abstracting provider differences; routing; local cost accounting |
| OpenRouter | API / `npm install openrouter` | Model routing, cost comparison, automatic fallback | Comparing model outputs; cost optimization at request level |
| Bifrost | self-hosted Docker | Self-hosted LLM gateway, routing, latency optimization | Production gateway for teams; full data sovereignty |

### Promptfoo
- **What it does**: Evaluates LLM outputs against defined criteria. Runs test suites across providers and models. Includes 50+ red-teaming vulnerability probes used by OpenAI and Anthropic.
- **Install**: `npm install -g promptfoo` or `npx promptfoo`
- **Key features**:
  - YAML-defined test cases with assertions (contains, regex, LLM-graded, similarity)
  - Side-by-side model comparison (e.g., Sonnet vs GPT-4o on the same prompts)
  - Red team mode: jailbreak, PII extraction, prompt injection, OWASP LLM Top 10
  - CI/CD integration via `promptfoo eval --ci` with pass/fail exit codes
  - Web UI for result visualization (`promptfoo view`)
- **Security considerations**: Red team probes generate adversarial inputs — run against non-production endpoints. Eval results may contain sensitive completions; treat output files as potentially sensitive.
- **When to use**: Any skill that ships prompts as a product (trl-ai-templates). Run evals before publishing a prompt library. Use in CI to catch prompt regressions after model updates.
- **When to avoid**: Quick one-off prompt testing where mental evaluation suffices; environments where npm is not available

### Fabric
- **What it does**: CLI tool with 200+ curated, community-contributed prompt patterns. Each pattern is a standalone markdown file. Composes via Unix pipes: `cat article.txt | fabric --pattern summarize`.
- **Install**: `go install github.com/danielmiessler/fabric@latest` then `fabric --setup`
- **Key features**:
  - Patterns for: summarization, extraction, essay writing, code review, security analysis, content scoring, video transcription, podcast notes
  - Pipe-composable: `yt https://youtube.com/... | fabric --pattern extract_wisdom`
  - Custom pattern directory (`~/.config/fabric/patterns/`)
  - Provider-agnostic: supports Ollama, OpenAI, Anthropic, Groq
- **Security considerations**: Prompts are sent to whichever provider is configured. Local models via Ollama keep data on-device. No telemetry in the core tool.
- **When to use**: trl-content-publishing skill for drafting; trl-ai-templates skill for pattern inspiration; rapid prototyping of prompt structures before formalizing in Promptfoo. Best when you want proven patterns rather than inventing from scratch.
- **When to avoid**: Production automated pipelines (no structured output guarantees); when you need assertion-based quality control (use Promptfoo instead)

### LiteLLM
- **What it does**: Python library and proxy server that provides a unified OpenAI-compatible API surface for 100+ LLM providers. Tracks cost, latency, and token usage per call.
- **Install**: `pip install litellm` (library) or `pip install 'litellm[proxy]'` (proxy server)
- **Key features**:
  - Single API call format works across OpenAI, Anthropic, Cohere, Mistral, Ollama, Bedrock, Vertex AI, and 90+ more
  - Built-in cost tracking (`litellm.completion_cost()`)
  - Async support, streaming, function calling normalization
  - Can serve as an MCP gateway — wrap LiteLLM proxy as an MCP server endpoint
  - Fallback routing: try model A, fall back to model B on error or latency threshold
- **Security considerations**: Proxy mode listens on a local port by default — do not expose to public internet without auth. API keys stored in env vars or a `.env` file; never hardcode.
- **When to use**: Skills that need provider flexibility without rewriting call logic. Essential for trl-ai-templates skill when packaging prompts that should work across models. Use proxy mode to give a team a single endpoint with centralized key management.
- **When to avoid**: Single-provider projects where abstraction adds unnecessary complexity; environments where Python is not available (prefer OpenRouter API directly)

## Selection Guide

Choose based on primary use case:

| Use Case | Primary Tool | Notes |
|----------|-------------|-------|
| Evaluating prompt quality | Promptfoo | Assertion-based, CI-ready |
| Red teaming / safety testing | Promptfoo | 50+ built-in vulnerability probes |
| Applying proven prompt patterns | Fabric | 200+ community patterns, pipe-composable |
| Drafting content with prompts | Fabric | Fast, Unix-native workflow |
| Routing across 100+ providers | LiteLLM | Unified API, cost tracking |
| Provider abstraction in code | LiteLLM | Drop-in OpenAI compatibility |
| Cost comparison at request level | OpenRouter | Per-call model routing |
| Self-hosted gateway (team) | Bifrost | Full data sovereignty, no SaaS dependency |
| Multi-source research | MCP Omnisearch | Tavily + Brave + Kagi + Exa unified |

**Common stacks**:
- **Prompt product development**: Fabric (pattern inspiration) → Promptfoo (validation) → LiteLLM (multi-provider delivery)
- **Cost optimization**: OpenRouter (routing) + LiteLLM (tracking) + Promptfoo (quality gate)
- **Air-gapped / data-sovereign**: Fabric with Ollama + LiteLLM proxy + Bifrost gateway
