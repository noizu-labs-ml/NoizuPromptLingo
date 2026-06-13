# Category: AI Coding Assistants

## Overview
Use tools in this category when a skill needs to orchestrate, delegate, or augment code generation, refactoring, or multi-file editing tasks. Relevant during scaffold generation, automated code review loops, and any workflow that benefits from an AI agent executing commands rather than a human typing them. Skill designers should consider which assistant model the end-user is likely to have active — this shapes which MCP integrations are available by default.

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| Claude Code | Local stdio (CLI) | 1M context, hooks, subagents, native MCP host | Reads local files; scope by project dir | Stable |
| Cursor | Hosted IDE / local | Background Agents, Design Mode, rule system | Cloud sync of workspace context | Stable |
| GitHub Copilot CLI | Hosted + CLI | plan/autopilot modes, /fleet multi-agent, built-in GitHub MCP | Sends repo context to GitHub | Stable |
| Windsurf | Local IDE | Cascade engine, 40+ plugins, memory system | Plugin permissions vary | Stable |
| Aider | Local stdio | Git-first, BYOM, auto-commits, repo-map | Commits to local git only | Stable |
| Cline | VS Code extension | Plan/Act modes, MCP marketplace, .clinerules | Extension-level VS Code permissions | Stable |
| Codex CLI | Local stdio (Rust) | Native OS sandbox, MCP client, minimal footprint | Sandboxed by default | Beta |
| Goose | Local stdio | 70+ MCP extensions, prompt injection detection | Active injection defense | Beta |
| Gemini CLI | Local stdio | 1M context, free tier, Google Search grounding | Google account required | Beta |
| OpenCode | Local stdio | LSP integration, multi-session, privacy-first | No telemetry by design | Alpha |
| Roo Code | VS Code extension | Cline fork, multi-agent orchestration modes | Same as Cline | Beta |
| Continue | Local / CI | CI-first pivot, IDE extension still maintained | Context sent to chosen provider | Stable |

---

### Claude Code
- **What it does**: Full agentic CLI that reads, edits, runs commands, and orchestrates subagents inside a terminal session. Native MCP host — any MCP server configured in `.claude/settings.json` is available to all agents.
- **Deployment**: Local stdio; runs in-terminal, no cloud IDE required
- **Key features**: 1M token context window; hooks system for pre/post-tool events; subagent spawning (npl-foreman pattern); first-class MCP server management; CLAUDE.md project instructions; slash commands; background agent support
- **Security considerations**: Runs as the local user — has full filesystem access scoped to working directory by default. Destructive shell commands require explicit approval unless added to allowlist. Prompt injection via malicious file content is a real surface area.
- **When to use**: Primary orchestrator for skill execution when the end-user is a developer working in terminal. Best choice when skill requires multi-step agentic loops, subagent parallelism, or tight MCP server coordination.
- **When to avoid**: When the user's workflow is IDE-first and they resist leaving the editor; when skill output needs visual diff review in a GUI.

---

### Cursor
- **What it does**: AI-native IDE (VS Code fork) with deep model integration. Background Agents run tasks asynchronously while the developer keeps editing. Design Mode translates visual specs into code.
- **Deployment**: Hosted Electron IDE; Background Agents run on Cursor cloud infrastructure
- **Key features**: `.cursorrules` project conventions; Background Agents for long-running tasks; Design Mode for Figma-to-code; multi-file edit with inline diff review; model-switchable (GPT-4o, Claude, Gemini)
- **Security considerations**: Workspace files sent to Cursor servers for context. Background Agent has write access to repo. Review agent-generated diffs before accepting — no git hook enforcement by default.
- **When to use**: When the end-user is IDE-native and wants AI assistance without leaving the editor. Excellent for skills that produce UI code or need inline diff review. Design Mode is uniquely powerful for design-to-code skills.
- **When to avoid**: CLI-heavy workflows; when the user requires full local execution with no cloud context sync; open-source/proprietary codebases with strict data policies.

---

### Aider
- **What it does**: Git-first AI pair programmer that runs in the terminal. Maintains a repo-map of the codebase, auto-commits changes with descriptive messages, and supports any LLM via BYOM (bring your own model).
- **Deployment**: Local stdio; pip install; runs against local git repo
- **Key features**: Repo-map for large codebase navigation; auto-commit with meaningful messages; BYOM (OpenAI, Anthropic, Ollama, etc.); architect/editor mode split for large refactors; watch mode for file-based prompting
- **Security considerations**: Only writes to local git — commits are reversible. Does not send context outside of configured LLM provider. BYOM means security profile depends on chosen provider.
- **When to use**: When git history integrity matters; when the skill involves large refactors across many files; when the user needs model flexibility (local Ollama, cost-optimized providers); automated commit workflows.
- **When to avoid**: When the user needs an IDE GUI; when the task is exploratory and frequent git commits would be noisy; when no git repo exists.

---

### Cline
- **What it does**: VS Code extension that implements a full Plan/Act agentic loop with MCP marketplace integration. `.clinerules` files let skills embed project-specific behavioral constraints.
- **Deployment**: VS Code extension; local execution; connects to MCP servers defined in extension settings
- **Key features**: Plan mode (propose before acting) + Act mode (execute immediately); built-in MCP marketplace for one-click server installs; `.clinerules` for per-project behavior; multi-model support; Roo Code fork adds multi-agent orchestration
- **Security considerations**: Runs as VS Code extension — access to workspace files, terminal, and any MCP servers configured. Plan mode provides human-in-the-loop checkpoint before destructive actions. Extension update surface worth monitoring.
- **When to use**: When the user lives in VS Code and wants Plan/Act control; when skill requires diverse MCP integrations installed via marketplace; when `.clinerules` can encode skill-specific constraints.
- **When to avoid**: When the user is CLI-first; when Cursor's richer IDE features (Design Mode, Background Agents) are needed; when MCP server management outside VS Code is required.

---

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| `aider` | `pip install aider-chat` | Git-first AI pair programmer, BYOM | Automated refactor loops |
| `claude` | `npm i -g @anthropic-ai/claude-code` | Agentic CLI, MCP host, subagents | Primary skill executor |
| `gemini` | `npm i -g @google/gemini-cli` | 1M context, Google Search grounding | Research + large context tasks |
| `goose` | Homebrew / pip | 70+ MCP extensions, injection detection | Multi-MCP orchestration |
| `codex` | Cargo / brew | Rust CLI, native sandbox, MCP client | Sandboxed automation |

---

## Selection Guide

**Choose by primary workflow:**

| Workflow | Best Choice | Fallback |
|----------|------------|---------|
| Terminal-native developer | Claude Code | Aider, Gemini CLI |
| IDE-native (VS Code) | Cline | Roo Code |
| IDE-native (wants best GUI) | Cursor | Windsurf |
| Git history integrity critical | Aider | Claude Code + git hooks |
| Large monorepo, diverse MCP needs | Claude Code | Goose |
| Free tier / cost-constrained | Gemini CLI | Aider + Ollama |
| Privacy-first / air-gapped | OpenCode | Aider + Ollama |
| Design-to-code workflow | Cursor (Design Mode) | Cline + Figma MCP |

**Context window needs:**
- Under 200k tokens → any tool works
- 200k–1M tokens → Claude Code or Gemini CLI
- Repo-map navigation instead of full context → Aider

**Model flexibility:**
- Locked to Anthropic → Claude Code
- BYOM required → Aider, Goose, Continue
- Google ecosystem → Gemini CLI
