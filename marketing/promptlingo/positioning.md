# Prompt Lingo — positioning

Filled from the marketing messaging worksheet. Evidence: this repo’s convention YAML, MCP tools, and the NPL/agent-kit split.

## Product

- **Name:** Noizu Prompt Lingo (Prompt Lingo)
- **URL / repo:** https://promptlingo.dev · https://github.com/noizu-labs-ml/NoizuPromptLingo
- **One-liner:** An open convention language for prompts that agents load over a public MCP.
- **Stage:** public (syntax corpus + MCP)
- **Pricing:** free / MIT

## Audience

- **Primary:** prompt authors and agent-harness builders (Claude Code, Codex, Cursor, Grok) who already fight vague prompts.
- **Awareness:** problem-aware
- **Secondary:** teams that want one dialect across models

## Job to be done

| Question | Answer |
|----------|--------|
| Trigger | Writing a system prompt / agent spec that must survive the next model and the next teammate |
| Job | Shared, loadable syntax instead of a unique snowflake each session |
| Today | Ad-hoc markdown, invented XML, “write better English” |
| Wrong | Dialect drift; 4k-token dumps; no examples-with-outputs |
| Switch | MCP load path + git corpus |
| Hesitations | Another standard; is this agent-kit; do I need an account |

## Differentiator

Versioned, loadable convention corpus (`NPLLoad` / `NPLSpec`) with a public MCP — not a chat UI and not a prompt marketplace.

## Category POV

- Enemy: every project invents `{placeholder}` soup.
- Shift: agents load tools over MCP; conventions should too.
- New way: syntax is a library, not a vibe.
- Proof: YAML in git + `claude mcp add --transport http npl https://promptlingo.dev/mcp`.

## Message hierarchy

| Level | Copy |
|-------|------|
| Tagline | Syntax for prompts that stay sharp. |
| One-liner | Noizu Prompt Lingo is an open convention language — placeholders, pumps, directives — that agents load over a public MCP. |
| Primary CTA | Star the repo |
| Secondary CTA | Copy MCP add |

## Landing slots

- Headline: Prompts deserve a real syntax.
- Subhead: Placeholders, intuition pumps, and tagged sections — versioned in git, loadable by any MCP client. No account. MIT-licensed.
- Proof: open-source convention corpus · public MCP · no signup
