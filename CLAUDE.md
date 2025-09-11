# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Noizu PromptLingo (NPL) project is a comprehensive framework for structured prompting with language models, developed by Noizu Labs ML. This Python-based project provides a well-defined prompting syntax and ecosystem of virtual tools/agents to enhance consistency and effectiveness in language model interactions.

The project includes a master prompt chain system, modular virtual tools (gpt-pro, gpt-fim, gpt-git, etc.), and NPL agentic scaffolding for structured AI interactions. It's designed to standardize prompting approaches and enable scalable, collaborative development of language model applications.

## Architecture Overview

This is a modular prompt engineering framework with the following key characteristics:

- **Prompt Chain System**: Collation system (`collate.py`) that combines base NLP prompts with selected virtual tools
- **Virtual Tools Ecosystem**: Modular prompt-based tools for different AI capabilities (code review, documentation, git operations, math, project management, etc.)
- **NPL Syntax Framework**: Structured syntax using Unicode symbols for precise prompt communication
- **Agentic Scaffolding**: NPL-enabled agents with templates for various AI personas and capabilities
- **Version Management**: Versioned prompt definitions supporting multiple NPL versions (0.3, 0.4, 0.5)

## Key Modules

- `nlp/` - Core NLP prompt definitions and versioned syntax rules
- `virtual-tools/` - Modular AI tools including gpt-pro, gpt-fim, gpt-git, gpt-doc, gpt-cr, gpt-math, gpt-pm, nb, pla, gpt-qa
- `npl/agentic/` - NPL agentic framework with scaffolding and agent templates
- `npl/agentic/scaffolding/agents/` - Pre-built agent personas (npl-templater, npl-grader, npl-persona, npl-thinker)
- `npl/agentic/scaffolding/agent-templates/` - Reusable agent templates for different use cases

## Development Commands

### Prompt Chain Generation
```bash
# Generate full prompt chain with all tools
python collate.py all

# Generate minimal prompt chain
python collate.py min

# Generate custom tool combination
python collate.py gpt-pro gpt-git gpt-fim

# Set specific versions (via environment variables)
export NLP_VERSION=0.5
export GPT_PRO_VERSION=0.1
python collate.py gpt-pro
```

### Environment Setup
```bash
# Set NPL version
export NLP_VERSION=0.5

# Set individual tool versions
export GPT_PRO_VERSION=0.1
export GPT_FIM_VERSION=0.5
export GPT_GIT_VERSION=0.5
```

### Working with Virtual Tools
```bash
# List available tools
ls virtual-tools/

# View tool documentation
cat virtual-tools/gpt-pro/README.md

# Check tool versions
ls virtual-tools/gpt-pro/
```

## Key Configuration

### Settings Location
- Main config: Environment variables for version management
- Prompt definitions: `nlp/nlp-{version}.prompt.md`
- Tool definitions: `virtual-tools/{tool}/{tool}-{version}.prompt.md`

### Important Settings
- NPL Version: Controlled via `NLP_VERSION` environment variable
- Tool Versions: Individual `{TOOL}_VERSION` environment variables
- Output: Generated `prompt.chain.md` combines selected components

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
@npl-grader "Review the prompt syntax in nlp/nlp-0.5.prompt.md"

# Create specialized agent persona
@npl-persona "Design an AI agent for code documentation in this NPL project"

# Analyze prompt chain effectiveness
@npl-thinker "Analyze the effectiveness of combining gpt-pro with gpt-git tools"
```

### Running Agents in Parallel for NPL Development

```bash
# Parallel analysis of prompt components
@npl-grader "Review nlp/nlp-0.5.prompt.md syntax" & @npl-thinker "Analyze prompt chain complexity"

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

### Virtual Tool Development
- Create versioned tool definitions in dedicated directories
- Include README.md documentation for each tool
- Use consistent naming patterns: `{tool}-{version}.prompt.md`
- Implement modular, composable tool functionality

### Agent Template Patterns
- Use NPL syntax for dynamic content generation
- Implement conditional sections with `{{#if}}` blocks
- Include clear instruction blocks for template hydration
- Follow project-specific naming and structure conventions

## Branch Strategy

The project uses a `main` branch as the primary development branch. Development follows a standard Git workflow with feature branches merged back to main.

## Common Development Workflows

### Adding New Virtual Tools
1. Create new directory under `virtual-tools/`
2. Add versioned prompt definition file
3. Include README.md with tool documentation
4. Test tool integration with collate.py
5. Update documentation as needed

### Creating New Agents
1. Define agent persona in `npl/agentic/scaffolding/agents/`
2. Use NPL syntax for structured behavior definition
3. Create supporting templates if needed
4. Test agent behavior and effectiveness
5. Document usage patterns and examples

### Updating NPL Syntax
1. Create new version file in `nlp/` directory
2. Update syntax definitions and rules
3. Test backward compatibility with existing tools
4. Update agent templates to use new syntax features
5. Update documentation and examples

### Prompt Chain Development
1. Modify or add virtual tools as needed
2. Test individual tool functionality
3. Use collate.py to generate combined prompt chains
4. Test full chain effectiveness
5. Document optimal tool combinations for different use cases