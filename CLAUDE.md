CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Noizu PromptLingo (NPL) project is a comprehensive framework for structured prompting with language models, developed by Noizu Labs ML. This project provides a well-defined prompting syntax and ecosystem of NPL agents to enhance consistency and effectiveness in language model interactions with Claude Code.

The project focuses on NPL agentic scaffolding for structured AI interactions, providing ready-to-use agents and templates that can be quickly deployed to Claude Code. It's designed to standardize prompting approaches and enable scalable, collaborative development of language model applications through the Claude Code agent system.

## Support MCPs and Scripts

This project includes comprehensive support utilities and scripts to enhance the development workflow:

### Available Scripts

**Project Scripts** (`.claude/scripts/`):
- `dump-dir` - Directory content dumping utility
- `dump-files` - Enhanced file dumping with Git integration and intelligent filtering. Supports `-g`/`--glob` options for filtering files by shell patterns (e.g., `-g "*.md"` for Markdown files)
- `git-dir-depth` - Git directory depth analysis tool
- `git-tree` - Enhanced Git tree visualization

**Scaffolding Scripts** (`agentic/scaffolding/scripts/`):
- `dump-files` - File content extraction for agent analysis with Git-aware filtering. Supports `-g`/`--glob` options for filtering files by shell patterns
- `git-dir-depth` - Repository structure analysis
- `git-tree` - Tree structure visualization for NPL workflows

**Filtering Support**:
- the dump-files, git-dir-gepth git-tree scripts use `git ls-files --cached --others --exclude-standard` for intelligent file filtering:
- Includes tracked files and untracked files not in `.gitignore`
- Respects `.gitignore`, `.git/info/exclude`, and standard Git exclusion patterns
- Provides clean output focused on relevant repository content

### Available MCPs
No MCPs are currently configured in this project. The `.claude/mcp/` directory is not present.

### Script Integration with NPL Workflows

These utilities are designed to work seamlessly with NPL agents for enhanced development workflows:

```bash
# Generate comprehensive project analysis
./.claude/scripts/git-dir-depth

# Export files for NPL agent processing  
./.claude/scripts/dump-files target-directory/

# Export only Markdown files
./.claude/scripts/dump-files . -g "*.md"

# Export multiple file types
./.claude/scripts/dump-files . -g "*.md" -g "src/*.ts"

# Visualize project structure for agent context
./.claude/scripts/git-tree
```

## Architecture Overview

This is an agentic framework designed specifically for Claude Code with the following key characteristics:

- **NPL Agentic System**: Pre-built agents that implement NPL syntax for specialized tasks
- **Agent Scaffolding**: Ready-to-deploy agent files with NPL-structured behavior definitions
- **Template System**: Reusable agent templates that can be hydrated for project-specific needs
- **NPL Syntax Framework**: Structured syntax using Unicode symbols for precise prompt communication
- **House Style Integration**: Dynamic loading of project-specific writing and coding styles

## Key Modules

- `agentic/` - Main agentic system with setup instructions and NPL documentation
- `agentic/scaffolding/agents/` - Pre-built NPL agents (npl-templater, npl-grader, npl-persona, npl-thinker, etc.)
- `agentic/scaffolding/agent-templates/` - Reusable agent templates for project-specific conversion
- `agentic/npl/` - NPL documentation in verbose and concise versions
- `npl/agentic/scaffolding/additional-agents/` - Extended library of specialized agents

## Setup Instructions

Follow the setup workflow to deploy NPL agents to your Claude Code environment:

### Step 1: Copy Agent Files
```bash
cp agentic/scaffolding/agents/* ~/.claude/agents/
```

### Step 2: Copy NPL Documentation
Choose your preferred NPL verbosity level:

**For verbose version (recommended):**
```bash
cp agentic/npl/verbose/npl.md ~/.claude/npl.md
```

**For concise version (experimental):**
```bash
cp agentic/npl/concise/npl.md ~/.claude/npl.md
```

### Step 3: Reload Claude Code
Restart your Claude Code session to load the new agents.

### Step 4: Generate Project-Specific CLAUDE.md
Use the npl-templater agent to convert the NPL template:
```
@npl-templater Please read and hydrate the scaffolding/CLAUDE.npl.template.md file, converting it to CLAUDE.npl.md for this project, and copy to CLAUDE.md if not present or edit the existing CLAUDE.md file with instructions to load CLAUDE.npl.md
```

### Step 5: Convert Agent Templates
Convert all agent templates for project-specific use:
```
@npl-templater Please read the CLAUDE.md file for context, then convert all the agent template files in agentic/scaffolding/agent-templates/ into actual agent files and place them in ~/.claude/agents/. Process all templates in parallel for efficiency.
```

## Key Configuration

### File Locations
- Agent files: `~/.claude/agents/`
- NPL documentation: `~/.claude/npl.md`
- Project config: `CLAUDE.md` (this file)
- House styles: `.claude/npl-m/house-style/` (when using NPL house style system)

### Available Agent Templates
- `gopher-scout.npl-template.md` - Code exploration and analysis agent
- `gpt-qa.npl-template.md` - Question answering and documentation agent
- `system-digest.npl-template.md` - System analysis and summarization agent
- `tdd-driven-builder.npl-template.md` - Test-driven development agent
- `tool-forge.npl-template.md` - Custom tool creation agent

## Using Claude Code Agents for NPL Development

### Available Agents and Their Uses

**@npl-templater** - Template creation and hydration for NPL projects
- Use for converting concrete files into reusable NPL templates
- Ideal for generating project-specific configurations from templates
- Best for creating scaffolding and boilerplate generation

**@npl-grader** - NPL syntax and structure evaluation
- Use for validating NPL prompt syntax compliance
- Ideal for code reviews of prompt definitions
- Best for ensuring NPL standards adherence

**@npl-persona** - AI persona development and management
- Use for creating specialized AI agent personalities
- Ideal for developing domain-specific AI assistants
- Best for customizing agent behavior and response patterns

**@npl-thinker** - Complex reasoning and analysis for NPL contexts
- Use for analyzing prompt effectiveness and optimization
- Ideal for debugging complex prompt chains
- Best for reasoning through multi-step NPL workflows

### Agent Usage Examples

```bash
# Generate project-specific templates using npl-templater
@npl-templater "Create a CLAUDE.md template for this Django project"

# Validate NPL syntax compliance
@npl-grader "Review the NPL syntax in agentic/npl/verbose/npl.md"

# Create specialized agent persona
@npl-persona "Design an AI agent for code documentation in this NPL project"

# Analyze agent effectiveness and workflows
@npl-thinker "Analyze the effectiveness of our current NPL agent setup"
```

### Running Agents in Parallel for NPL Development

```bash
# Parallel analysis of NPL components
@npl-grader "Review agentic/npl/verbose/npl.md syntax" & @npl-thinker "Analyze NPL framework effectiveness"

# Template generation with validation
@npl-templater "Create agent template for code review" & @npl-grader "Validate resulting template syntax"

# Persona development with testing
@npl-persona "Create debugging assistant agent" & @npl-thinker "Evaluate agent effectiveness patterns"
```

## Common Development Patterns

### NPL Prompt Structure
- Use Unicode symbols for precise semantic meaning (↦, ⟪⟫, ␂, ␃)
- Define entities with clear definitions and extensions
- Implement versioned syntax evolution
- Follow NLP directive patterns for structured communication

### Agent Development Patterns
- Use NPL syntax for structured agent behavior definition
- Implement clear separation between agent logic and templates
- Include comprehensive documentation within agent files
- Follow consistent naming patterns for agent identification

### Template System Patterns
- Use NPL template syntax for dynamic content generation
- Implement conditional sections with `{{#if}}` blocks
- Include clear instruction blocks for template hydration
- Follow project-specific naming and structure conventions
- Store templates in `agentic/scaffolding/agent-templates/` for reuse

## Branch Strategy

The project uses a `main` branch as the primary development branch. Development follows a standard Git workflow with feature branches merged back to main.

## Common Development Workflows

### Setting Up NPL Agents for New Projects
1. Follow the setup instructions above to copy agents and NPL documentation
2. Use `@npl-templater` to generate project-specific CLAUDE.md
3. Convert agent templates using `@npl-templater` for project customization
4. Test agent functionality with project-specific contexts
5. Document any project-specific agent modifications

### Creating New Agents
1. Create agent definition in `agentic/scaffolding/agents/`
2. Use NPL syntax for structured behavior definition
3. Test agent behavior and effectiveness in Claude Code
4. Add to template system if reusable across projects
5. Document usage patterns and examples

### Developing Agent Templates
1. Create template file in `agentic/scaffolding/agent-templates/`
2. Use NPL template syntax with `{{}}` placeholders
3. Include clear hydration instructions
4. Test template conversion using `@npl-templater`
5. Add to template library for reuse

### Updating NPL Documentation
1. Modify files in `agentic/npl/verbose/` or `agentic/npl/concise/`
2. Test changes with existing agents
3. Update agent behavior if syntax changes affect them
4. Validate with `@npl-grader` for compliance
5. Update examples and documentation

### Contributing Additional Agents
1. Add specialized agents to `npl/agentic/scaffolding/additional-agents/`
2. Organize by category (infrastructure, marketing, qa, research, etc.)
3. Follow established patterns for agent structure
4. Include comprehensive documentation and usage examples
5. Consider promoting successful agents to main scaffolding
