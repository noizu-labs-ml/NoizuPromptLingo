---
skill: agent-architect
version: "1.0"
compatible_with:
  - claude-code
last_updated: 2026-05-28
---

# Agent Architect — Introduction

Design, build, and validate AI agents using research-backed patterns from Anthropic, OpenAI, and academic sources (2025–2026). This skill covers the full lifecycle: requirements discovery, architecture selection, context engineering, tool design, memory systems, guardrails, NPL integration, and quality evaluation. It targets engineers building Claude Code subagents, multi-agent systems, or standalone autonomous agents. Primary value: translating a task description into a production-ready, well-architected agent definition with appropriate complexity level.

## Input Contract

```yaml
inputs:
  arguments:
    - name: task_description
      type: freeform
      required: true
      description: "What the agent should do, or what system needs to be designed"
      example: "build a subagent that monitors EKS pod restarts and summarizes root causes"

    - name: existing_agent_file
      type: file-path
      required: false
      description: "Path to an existing agent definition file for evaluation or enhancement"
      example: ".claude/agents/deploy-monitor.md"

    - name: npl_mode
      type: choice
      required: false
      description: "Whether to generate NPL-enhanced output (auto-detected if omitted)"
      example: "npl"

  file_conventions:
    - pattern: ".claude/agents/{name}.md"
      format: markdown
      description: "Claude Code agent definition file — the primary output and input for evaluation"
      schema: "See SKILL.md Phase 4: Implementation for the required frontmatter + body structure"
      example: |
        ---
        name: my-agent
        description: Trigger description for this agent
        model: sonnet
        ---
        # My Agent
        ## Identity
        role: What this agent does
        lifecycle: ephemeral

    - pattern: "assets/agent-checklist.md"
      format: markdown
      description: "Validation checklist consumed during Workflow 2 (evaluate) and Workflow 1 (validate phase)"
      schema: "Pass/fail checklist items organized by category"
      example: |
        - [ ] Agent has a clear single responsibility
        - [ ] All tools have error handling

  context_expectations:
    - "Git repository (agent files written to .claude/agents/)"
    - "Optional: NPLLoad/NPLSpec MCP tools or $NPL_PROJECT env var for NPL mode"
    - "Optional: existing agent file when evaluating or enhancing"
```

## Output Contract

```yaml
outputs:
  artifacts:
    - name: "Agent definition file"
      path: ".claude/agents/{agent-name}.md"
      format: markdown
      description: "Complete agent definition with frontmatter, identity, interface, behavior, and guardrails"
      example: |
        ---
        name: deploy-monitor
        description: Monitors EKS pod restarts and summarizes root causes
        model: sonnet
        ---
        # Deploy Monitor
        ## Identity
        agent_id: deploy-monitor
        role: EKS observability assistant

    - name: "Architecture diagram"
      path: "inline (mermaid in response)"
      format: markdown
      description: "Mermaid diagram of the agent or multi-agent coordination topology"
      example: |
        graph TD
          IN[Trigger] --> A[Agent]
          A --> T1[Tool: kubectl]
          A --> OUT[Summary]

    - name: "Evaluation report"
      path: "inline (response output)"
      format: markdown
      description: "Checklist results, complexity assessment, and scored recommendations (Workflow 2 only)"
      example: |
        | Check | Result | Note |
        |-------|--------|------|
        | Single responsibility | PASS | |
        | Guardrails present | FAIL | No boundary checks |

  side_effects:
    - "Creates .claude/agents/ directory if absent when writing agent files"

  handoff:
    - skill: mcp-architect
      artifact: "Agent definition file"
      description: "Hand off to mcp-architect when the agent requires custom MCP tool design"
    - skill: skill-engineer
      artifact: "Agent definition file"
      description: "Hand off to skill-engineer when packaging the agent as a reusable Claude Code skill"
```

## Conventions

```yaml
conventions:
  naming:
    - "Agent files use kebab-case: deploy-monitor.md, not DeployMonitor.md"
    - "Agent name in frontmatter must match the filename (without .md)"
  structure:
    - "Always walk the Complexity Ladder before selecting architecture — see SKILL.md"
    - "Context layers must be designed explicitly (see SKILL.md Phase 3), not implied"
    - "Multi-agent systems require a failure mode matrix before implementation"
  anti_patterns:
    - "Do not skip the Complexity Ladder — Level 5-7 for tasks that need Level 1-2 is the #1 agent failure mode"
    - "Do not design guardrails as afterthoughts — they belong at every model boundary in the architecture"
    - "Do not emit a single massive agent file in one pass — write incrementally (interstitial output rule)"
    - "Do not suggest NPL patterns unless NPL availability is confirmed or user explicitly requests it"
  prerequisites:
    - "Task description or existing agent file must be provided"
    - "For evaluation workflows, the agent file must be readable"
```

## Reading Order

| Priority | File | When to Read |
|----------|------|--------------|
| 1 (always) | `INTRODUCTION.md` | Before any interaction (you're reading it now) |
| 2 (before executing) | `SKILL.md` | Full workflow details, Complexity Ladder, Phase 1-5 design process |
| 3 (during execution) | `references/agent-playbook.claude-code.md` | Workflow-specific step sequences (design, evaluate, NPL, multi-agent) |
| 4 (architecture) | `references/architecture-patterns.md` | When selecting or justifying a topology |
| 5 (context/memory) | `references/memory-and-context.md` | When designing context layers or memory systems |
| 6 (tools) | `references/tool-design.md` | When designing tools for the agent |
| 7 (guardrails) | `references/guardrails-and-safety.md` | When hardening an agent or doing security review |
| 8 (NPL) | `references/npl-agent-patterns.md` | Only when NPL mode is active |

## Quick Examples

### Design a new subagent
`/agent-architect build a subagent that watches for failed GitHub Actions runs and posts a Slack summary`

### Evaluate an existing agent
`/agent-architect` with `.claude/agents/deploy-monitor.md` already in the project — the skill will run Workflow 2 (evaluate) automatically

### Multi-agent system
`/agent-architect design a multi-agent pipeline: one agent that fetches PR diffs, one that reviews them, one that posts comments`
