# mallm — man pages for LLMs

`mallm` is `man` for AI agents. It provides structured, LLM-friendly documentation for CLI tools — so agents know *when* to use a tool, *how* to call it, *what patterns* work, and *what gotchas* to avoid.

## The Problem

`--help` gives you flags. `man` gives you prose. Neither tells an LLM agent:
- When should I use this tool vs alternatives?
- What's the typical multi-step workflow?
- What are the gotchas that'll waste 3 retries?
- Where can I learn more (skills, extended docs)?

## The Solution

A `mallm.yaml` file per tool, with structured sections an LLM can parse:

```yaml
mallm: "1.0"
name: helm-upgrade
summary: Orchestrated multi-project Helm chart upgrade utility

context:
  when_to_use: |
    Use when deploying Kubernetes services. Prefer over raw
    `helm upgrade` for multi-chart deployments.
  when_not_to_use: |
    Don't use for single-chart one-off installs.
  common_patterns:
    - name: Full deployment
      steps:
        - "docker-build"
        - "docker-push"
        - "helm-upgrade --dry-run"
        - "helm-upgrade"
  gotchas:
    - "preApply manifests are kubectl-applied, not helm-managed"
```

## Resolution Order

mallm looks for documentation in this order:

1. **Project-local** — `.mallm/<app>.yaml` in the nearest git root
2. **User config** — `~/.config/mallm/<app>/mallm.yaml`
3. **Native** — runs `<app> --mallm` (for mallm-aware tools)
4. **Help fallback** — parses `<app> --help` output into a basic mallm structure

## Install

```sh
cd utilities/mallm
npm install
npm run build
npm link  # makes `mallm` available globally
```

## Usage

```sh
# Look up a tool (shorthand)
mallm helm-upgrade

# Explicit show with JSON output
mallm show docker-build --json

# Create a mallm.yaml stub (seeds from --help)
mallm init my-tool
mallm init my-tool --global

# List all known definitions
mallm list

# Validate a mallm.yaml
mallm validate .mallm/my-tool.yaml

# Print the JSON Schema
mallm schema
```

## Output Formats

**Markdown (default)** — readable prose with tables, code blocks, and sections. LLMs parse this well, and humans can read it too.

**JSON (`--json`)** — structured data for programmatic consumption. Includes all fields plus `_meta` with source and timestamp.

## For Tool Authors: `--mallm` Protocol

Tools can natively support mallm by responding to `--mallm` with valid YAML output matching the mallm schema. This is optional — the config file system works without it.

```sh
# Your tool responds to --mallm with YAML
my-tool --mallm
# => prints mallm.yaml content to stdout
```

## Schema

The full JSON Schema is at `schemas/mallm.schema.json`. Key sections:

| Section | Purpose |
|---------|---------|
| `summary` | One-line description |
| `usage.examples` | Concrete command examples |
| `arguments` | Typed argument definitions (flag, option, positional) |
| `subcommands` | Nested command structure |
| `environment` | Required/optional env vars |
| `context` | LLM guidance: when to use, patterns, gotchas |
| `skills` | Links to extended documentation / skill definitions |
| `related` | Related commands |
| `output` | What stdout/stderr/exit codes mean |

## Examples

See `examples/` for complete mallm.yaml files:
- `helm-upgrade.mallm.yaml` — multi-option orchestrator tool
- `docker-build.mallm.yaml` — simpler build tool
