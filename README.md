# Noizu PromptLingo (NPL) - Agentic Framework

A simplified agentic framework for Claude Code that provides structured prompting syntax and pre-built AI agents for enhanced language model interactions.

## Quick Setup

1. **Copy Repository**
   ```bash
   # Copy this entire repository to your local workspace
   cp -r NoizuPromptLingo /your/workspace/
   cd /your/workspace/NoizuPromptLingo
   ```

2. **Follow Setup Instructions**
   ```bash
   # Run the instructions in agentic/INSTRUCTIONS.md with Claude
   # This will copy agents and NPL documentation to your Claude Code environment
   ```

3. **Generate Project Configuration**
   ```
   @npl-templater Please read and hydrate the scaffolding/CLAUDE.npl.npl-template.md file
   ```

4. **Hydrate Agent Templates** (Optional)
   ```
   @npl-templater Please convert all agent templates in scaffolding/agent-templates/
   ```

## Documentation

For comprehensive documentation and examples, please see:
- **[Technical Documentation](doc/README.md)** - Detailed NPL framework documentation
- **[Additional Agents](doc/agents/README.md)** - Extended agent library documentation
- **[Demos and Examples](demo/README.md)** - Interactive demonstrations and usage examples (to be populated with generated artifacts)

## Project Structure

```
├── .claude/                    # Claude Code integration files
│   ├── agents/                 # Claude agent definitions
│   └── npl-m/                  # NPL module system
├── agentic/                    # Main agentic framework
│   ├── INSTRUCTIONS.md         # Setup instructions for Claude
│   ├── npl/                    # NPL documentation (verbose/concise)
│   └── scaffolding/            # Agent scaffolding and templates
│       ├── agents/             # Pre-built NPL agents
│       ├── agent-templates/    # Reusable agent templates
│       └── CLAUDE.npl.template.md # Project template
├── demo/                       # Usage examples and demonstrations (to be populated)
├── doc/                        # Technical documentation
│   └── agents/                 # Additional agent documentation
└── npl/                        # Extended NPL resources
```

## Key Components

### Core Agents (`agentic/scaffolding/agents/`)
- **npl-templater**: Template creation and hydration
- **npl-grader**: NPL syntax and structure evaluation  
- **npl-persona**: AI persona development and management
- **npl-thinker**: Complex reasoning and analysis
- **npl-technical-writer**: Technical documentation specialist
- **npl-fim**: Fill-in-middle code completion
- **npl-threat-modeler**: Security analysis and threat modeling

### Agent Templates (`agentic/scaffolding/agent-templates/`)
- **gopher-scout**: System exploration and analysis
- **gpt-qa**: Question answering specialist
- **system-digest**: System analysis and reporting
- **tdd-driven-builder**: Test-driven development assistant
- **tool-forge**: Custom tool creation

### Additional Agents (`npl/agentic/scaffolding/additional-agents/`)
Extended library of specialized agents organized by category:
- **Infrastructure**: System architecture and deployment agents
- **Marketing**: Content creation and marketing automation
- **QA**: Testing and quality assurance specialists
- **Research**: Data analysis and research assistants
- **Security**: Threat modeling and security analysis
See [Additional Agents Documentation](doc/agents/README.md) for complete list.

### NPL Documentation (`agentic/npl/`)
- **verbose/**: Complete NPL syntax reference
- **concise/**: Streamlined NPL documentation

## NPL Syntax Framework

NPL uses Unicode symbols for precise semantic communication:

- `⌜⌝`: Agent definition boundaries
- `⟪⟫`: Dynamic content placeholders  
- `↦`: Directive mappings
- `␂␃`: Content delimiters
- `{{#if}}`: Conditional logic blocks

## Workflow

### Initial Setup
1. Copy repository to workspace
2. Follow `agentic/INSTRUCTIONS.md` setup process
3. Generate project-specific `CLAUDE.md` using npl-templater
4. Optionally hydrate additional agent templates

### Daily Usage
1. Use pre-built agents for common tasks:
   ```
   @npl-technical-writer generate spec --component=auth-module
   @npl-grader review prompt-definitions/ --syntax-check
   @npl-persona create debugging-assistant --domain=python
   ```

2. Create custom agents from templates:
   ```
   @npl-templater hydrate tool-forge.npl-template.md --tool=api-client
   ```

3. Validate and iterate on agent definitions:
   ```
   @npl-grader evaluate custom-agent.md --rubric=npl-compliance
   ```

## Benefits

### Consistency
Standardized prompting syntax eliminates ambiguity between humans and language models, reducing misinterpretations and improving response accuracy.

### Modularity  
Pre-built agents and templates provide reusable components for common AI tasks, accelerating development of language model applications.

### Collaboration
Shared NPL syntax enables team coordination and knowledge transfer, fostering innovation through common prompting standards.

### Debugging
Well-defined syntax framework simplifies identification and resolution of prompt-related issues through structured error handling.

### Scalability
Template-based approach accommodates new features and use cases while maintaining consistency across growing language model implementations.

## Requirements

- Claude Code environment
- Access to Claude API
- Basic understanding of prompt engineering concepts

## License

MIT License - see LICENSE file for details.

## Notes

### Demo Directory
The `demo/` directory is intended to be populated with actual agent-generated artifacts and examples. Run the agents to generate:
- Interactive visualizations from npl-fim
- Hydrated templates from npl-templater
- Evaluation reports from npl-grader
- Conversation threads from npl-persona
- Analysis outputs from npl-thinker

### Additional Agents
The `npl/agentic/scaffolding/additional-agents/` directory contains an extended library of specialized agents beyond the core set. These agents cover specific domains like infrastructure, marketing, QA, research, and security. Review the [Additional Agents Documentation](doc/agents/README.md) to explore available options.

## Support

NPL is developed by Noizu Labs ML. This framework provides foundational tools for structured language model interactions through proven prompting methodologies.