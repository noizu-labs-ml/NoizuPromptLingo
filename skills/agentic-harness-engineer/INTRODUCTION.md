---
skill: agentic-harness-engineer
version: "1.0"
compatible_with:
  - claude-code
last_updated: 2026-05-28
---

# Agentic Harness Engineer — Introduction

Full-lifecycle skill for designing, implementing, evaluating, and security-hardening production-grade LLM agentic systems. TypeScript is the primary output stack. It covers architecture pattern selection (ReAct, plan-and-execute, supervisor, swarm, router, debate), scaffold generation, eval-driven development, OWASP LLM Top 10 threat modeling, OpenTelemetry instrumentation, and production deployment. Use it when building a new agent from scratch, hardening an existing one, designing multi-agent coordination, building eval suites, or red-teaming an agentic system.

## Input Contract

```yaml
inputs:
  arguments:
    - name: task
      type: freeform
      required: true
      description: "What to build, harden, evaluate, or debug — agent use case or specific workflow"
      example: "build an agent that summarizes support tickets and routes them to the right team"

    - name: workflow
      type: choice
      required: false
      description: "Explicit workflow override: new-agent-harness | security-hardening | eval-design | multi-agent | observability | red-team"
      example: "security-hardening"

  file_conventions:
    - pattern: "requirements.md"
      format: markdown
      description: "Pre-written requirements for the agent — capability matrix, constraints, tool list"
      schema: "Free-form; skill will structure it if absent"
      example: |
        ## Goal
        Route support tickets to teams based on topic.
        ## Tools
        - Zendesk API (read tickets)
        - Slack API (post to channel)
        ## Constraints
        - Max 2s latency p95
        - No PII in logs

    - pattern: "agent-harness/**/*.ts"
      format: custom
      description: "Existing TypeScript harness — provided when hardening or extending"
      schema: "Any valid TypeScript; skill audits structure and guards"
      example: |
        // src/agent.ts
        export async function run(input: string) { ... }

  context_expectations:
    - "Git repository (for scaffold output)"
    - "Node.js project or willingness to scaffold one (package.json, tsconfig.json)"
    - "LLM API key available via environment (ANTHROPIC_API_KEY or equivalent)"
```

## Output Contract

```yaml
outputs:
  artifacts:
    - name: "Agent harness scaffold"
      path: "agent-harness/src/**/*.ts"
      format: custom
      description: "Full TypeScript harness: transport, orchestration, tools, guards, memory, observability"
      example: "agent-harness/src/agent.ts, src/tools/registry.ts, src/guards/input-filter.ts"

    - name: "Architecture decision record"
      path: "agent-harness/ARCH.md"
      format: markdown
      description: "Pattern selection with justification and tradeoff table"
      example: "## Pattern: ReAct Loop\nChosen because task structure is not known in advance..."

    - name: "Security threat model"
      path: "agent-harness/SECURITY.md"
      format: markdown
      description: "STRIDE + OWASP LLM Top 10 coverage, mitigations, residual risk"
      example: "| LLM01 Prompt Injection | Guard | Heuristic + classifier |"

    - name: "Eval suite"
      path: "agent-harness/eval/**"
      format: custom
      description: "Capability map, JSONL datasets, scorer functions, eval runner"
      example: "eval/capability-map.yaml, eval/datasets/accuracy.jsonl, eval/scorers/exact-match.ts"

    - name: "Requirements doc"
      path: "agent-harness/requirements.md"
      format: markdown
      description: "Structured capability matrix and constraints — elicited or refined from input"
      example: "## Capability Matrix\n| Task | Required | Priority |\n| Route ticket | Yes | P0 |"

  side_effects:
    - "None — all output is file-based; no git commits, no deploys"

  handoff:
    - skill: trl-mcp-builder
      artifact: "Agent harness scaffold"
      description: "Extend with MCP server tool definitions"
    - skill: trl-threat-modeler
      artifact: "agent-harness/SECURITY.md"
      description: "Deepen threat model with STRIDE/PASTA"
    - skill: trl-dba-db-designer-and-tuning
      artifact: "Agent harness scaffold"
      description: "Design backing database for agent memory"
```

## Conventions

```yaml
conventions:
  naming:
    - "Scaffold files use kebab-case filenames and PascalCase TypeScript exports"
    - "Eval datasets use the pattern eval/datasets/{type}.jsonl"
  structure:
    - "Every harness has five layers: transport, orchestration, tool, guard, memory"
    - "Evals are written before business logic — eval/ directory ships with the scaffold"
    - "Security hardening is part of every new harness, not a separate phase"
  anti_patterns:
    - "Do not skip the eval suite — behavior is defined by what the agent measurably does, not what the prompt says"
    - "Do not add multi-agent coordination before single-agent evals pass — complexity is earned"
    - "Do not hardcode API keys or secrets — always inject via environment at startup"
    - "Do not use :latest image tags in deployment configurations"
  prerequisites:
    - "For new harnesses: Node.js 20+ and TypeScript 5+ must be available or scaffolded"
    - "For security hardening: existing harness code must be readable in the working tree"
```

## Reading Order

| Priority | File | When to Read |
|----------|------|--------------|
| 1 (always) | `INTRODUCTION.md` | Before any interaction (you're reading it now) |
| 2 (before executing) | `SKILL.md` | For full workflow details, pattern matrix, and layer descriptions |
| 3 (during execution) | `references/agent-playbook.claude-code.md` | When running a specific workflow (new harness, security, eval, etc.) |
| 4 (architecture) | `references/architecture-patterns.md` | When selecting or justifying a pattern |
| 5 (security) | `references/security-threat-model.md` | When threat modeling or hardening |
| 6 (evals) | `references/eval-framework.md` | When designing or implementing eval suites |
| 7 (as needed) | `references/{topic}.md` | observability, multi-agent, memory, tool integration, red-teaming |
## Quick Examples

### New agent from scratch
`/agentic-harness-engineer build an agent that monitors Slack and files GitHub issues from tagged messages`

### Harden an existing agent
`/agentic-harness-engineer security-hardening` — with existing harness code in `agent-harness/`

### Eval suite only
`/agentic-harness-engineer design an eval suite for my ticket-routing agent — accuracy and injection resistance`
