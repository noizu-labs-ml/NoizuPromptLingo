# Noizu PromptLingo (NPL) - Agentic Framework

A simplified agentic framework for Claude Code that provides structured prompting syntax and pre-built AI agents for enhanced language model interactions.

## Getting Started
|                                                                 |                                          |
| --------------------------------------------------------------- | ---------------------------------------- |
| ![image](https://github.com/noizu-labs-ml/NoizuPromptLingo/assets/6298118/52afeecb-a211-4a56-b03a-8b4c5577e562) | Download: https://github.com/noizu-labs-ml/NoizuPromptLingo/archive/refs/heads/main.zip <br> Follow setup: `agentic/INSTRUCTIONS.md` |

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

## Support Scripts and Utilities

<!-- SUPPORT_SCRIPTS_DOCUMENTATION_SECTION_START -->
### Developer Utilities

NPL includes a comprehensive set of Git-aware utility scripts designed to enhance development workflows for both human developers and NPL agents. These scripts automatically respect `.gitignore` rules and provide consistent, formatted output for codebase exploration and analysis.

#### Core Script Categories

**File Content Extraction**
- **`dump-files`**: Extracts and formats file contents with structured headers
  - Outputs each file with a clear header (`# filename`) and separator (`* * *`)
  - **Git-Aware Filtering**: Uses `git ls-files --cached --others --exclude-standard` to:
    - Include all tracked files (`--cached`)
    - Include untracked files that aren't ignored (`--others`)
    - Respect `.gitignore`, `.git/info/exclude`, and Git's standard ignore patterns (`--exclude-standard`)
  - Perfect for feeding file contents to NPL agents for analysis

- **`dump-dir`**: Basic directory content dumping utility
  - Simplified version available in `.claude/scripts/`
  - Provides quick file content extraction for development tasks

**Repository Structure Analysis**
- **`git-tree`**: Visual directory tree generator
  - Uses Git file listing with `tree --fromfile` for clean visualization  
  - Shows complete repository structure while respecting `.gitignore`
  - Essential for understanding project organization and architecture

- **`git-dir-depth`**: Directory structure analysis with depth metrics
  - Lists directories with their nesting depth relative to target folder
  - Provides depth analysis for complexity assessment
  - Useful for identifying overly nested structures and refactoring opportunities

#### NPL Agent Integration

These scripts are specifically designed to work seamlessly with NPL agents, providing structured input for AI-powered development tasks:

```bash
# Generate API documentation from codebase analysis
./.claude/scripts/dump-files src/api/ | @npl-technical-writer generate api-doc

# Analyze project structure for architecture decisions
./.claude/scripts/git-tree | @npl-thinker evaluate architecture-patterns

# Assess code organization complexity
./.claude/scripts/git-dir-depth src/ | @npl-grader assess --criteria=organization

# Extract documentation for content review
./agentic/scaffolding/scripts/dump-files docs/ | @npl-technical-writer review --mode=annotate
```

#### Quick Usage Examples

**View Complete Project Structure**
```bash
# Visual tree of entire project
./.claude/scripts/git-tree

# Focus on specific module
./agentic/scaffolding/scripts/git-tree agentic/scaffolding/
```

**Analyze Directory Complexity**
```bash
# Get depth metrics for project organization
./.claude/scripts/git-dir-depth .

# Focus on specific component
./agentic/scaffolding/scripts/git-dir-depth src/components/
```

**Extract Code for Analysis**
```bash
# Dump all files in source directory
./.claude/scripts/dump-files src/

# Extract only Markdown files
./.claude/scripts/dump-files . -g "*.md"

# Extract multiple file types
./.claude/scripts/dump-files . -g "*.md" -g "src/*.ts"

# Extract specific module for documentation
./agentic/scaffolding/scripts/dump-files agentic/npl/ > npl-docs.txt
```

#### Script Locations and Versions

**Primary Scripts** (`.claude/scripts/`)
- `dump-dir` - Directory content extraction
- `dump-files` - Enhanced file dumping with Git integration. Supports `-g`/`--glob` options for filtering files by shell patterns (e.g., `-g "*.md"` for Markdown files)
- `git-dir-depth` - Directory depth analysis  
- `git-tree` - Git-aware tree visualization

**Scaffolding Scripts** (`agentic/scaffolding/scripts/`)
- `dump-files` - File content extraction for agent workflows. Supports `-g`/`--glob` options for filtering files by shell patterns
- `git-dir-depth` - Repository structure analysis
- `git-tree` - Tree visualization for NPL contexts

Both locations provide identical core functionality, with scaffolding versions optimized for NPL agent integration and template generation workflows.

#### Development Benefits

**For NPL Development**
- **Context Extraction**: Provide rich codebase context to NPL agents
- **Structure Analysis**: Understand project organization for agent template creation
- **Content Processing**: Format code and documentation for agent analysis
- **Workflow Integration**: Seamless integration with NPL agent commands

**For General Development**  
- **Clean Output**: Git-aware file listing respects ignore rules
- **Consistent Formatting**: Standardized output format across all scripts
- **Repository Analysis**: Quick insights into project structure and complexity
- **Cross-Platform**: Bash scripts work across Unix-like environments

#### Requirements

- **Git Repository**: All scripts must be run within a Git repository
- **System Tools**: `tree` command required for `git-tree` script
- **Bash Environment**: Scripts use `bash` with strict error handling (`set -euo pipefail`)

All scripts include comprehensive error checking and will exit gracefully if requirements are not met.
<!-- SUPPORT_SCRIPTS_DOCUMENTATION_SECTION_END -->

## Project Structure

```
├── .claude/                    # Claude Code integration files
│   ├── agents/                 # Claude agent definitions
│   ├── scripts/                # Project utility scripts
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