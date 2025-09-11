# NPL Agentic Setup Instructions

Follow these steps to set up the NPL agentic system with Claude Code:

## Step 1: Copy Agent Files
Copy all agent files from this repository to your Claude Code agents directory:
```bash
cp scaffolding/agents/* ~/.claude/agents/
```

## Step 2: Copy NPL Documentation
Choose your preferred NPL verbosity level and copy the core NPL documentation:

**For verbose version:**
```bash
cp npl/verbose/npl.md ~/.claude/npl.md
```

**For concise version (if available):**
```bash
cp npl/concise/npl.md ~/.claude/npl.md
```

## Step 3: Reload Claude Code Session
Restart your Claude Code session to load the new agents.

## Step 4: Generate CLAUDE.md from Template
Use the npl-templater agent to convert the NPL template into your project's CLAUDE.md:

```
@npl-templater Please read and hydrate the scaffolding/CLAUDE.npl.npl-template.md file, converting it to CLAUDE.npl.md for this project, and copy to CLAUDE.md if not present or edit the existing CLAUDE.md file with instructions to load CLAUDE.npl.md
```

## Step 5: Convert Agent Templates
After the CLAUDE.npl.md is generated and you've reviewed its contents, use the npl-templater agent to convert all agent templates:

```
@npl-templater Please read the CLAUDE.md file for context, then convert all the agent template files in scaffolding/agent-templates/ into actual agent files and place them in ~/.claude/agents/. Process all templates in parallel for efficiency.
```

The agent templates that will be converted include:
- `scaffolding/agent-templates/gopher-scout.npl-template.md`
- `scaffolding/agent-templates/gpt-qa.npl-template.md`
- `scaffolding/agent-templates/system-digest.npl-template.md`
- `scaffolding/agent-templates/tdd-driven-builder.npl-template.md`
- `scaffolding/agent-templates/tool-forge.npl-template.md`

## Verification
After completion, verify your setup by checking:
1. All agents are available in `~/.claude/agents/`
2. NPL documentation is at `~/.claude/npl.md`
3. Project-specific `CLAUDE.md` exists and is properly configured
4. All converted agent files are functional and project-specific

Your NPL agentic system is now ready for use with Claude Code!
