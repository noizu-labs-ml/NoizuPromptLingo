# Noizu PromptLingo (NPL) - Agentic Framework

A simplified agentic framework for Claude Code that provides structured prompting syntax and pre-built AI agents for enhanced language model interactions.

## Getting Started

Download: https://github.com/noizu-labs-ml/NoizuPromptLingo/archive/refs/heads/main.zip

## Quick Setup

### 1. Install NPL Framework

Clone or copy the repository to `~/.npl`:

```bash
git clone https://github.com/noizu-labs-ml/NoizuPromptLingo.git ~/.npl
```

### 2. Add Scripts to PATH

Add to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
export PATH="$PATH:$HOME/.npl/core/scripts"
```

Then reload your shell or run `source ~/.bashrc` (or equivalent).

### 3. Install Core Agents and Commands

Copy or symlink core agents to Claude's agent directory:

```bash
# Create Claude directories if they don't exist
mkdir -p ~/.claude/agents ~/.claude/commands

# Symlink core agents
ln -s ~/.npl/core/agents/*.md ~/.claude/agents/

# Optionally add additional agents you want globally available
# ln -s ~/.npl/core/additional-agents/category/agent-name.md ~/.claude/agents/

# Symlink slash commands
ln -s ~/.npl/core/commands ~/.claude/commands
```

### 4. Verify Installation

```bash
npl-load --help      # Should show NPL loader options
npl-persona --help   # Should show persona management options
```

## Project Setup

For each project where you want to use NPL:

### 1. Initialize Project Configuration

In your target repository, run these Claude Code slash commands:

```
/init-project-fast    # Sets up initial CLAUDE.md sections
/update-arch          # Generates docs/PROJECT-ARCH.md and docs/PROJECT-LAYOUT.md
```

### 2. Hydrate Project-Specific Agents (Optional)

Use the `/hydrate-agents` command (pending) to customize agent definitions for your project:

```
/hydrate-agents       # Tailors agents and places them in .claude/available-agents/
```

This uses `@npl-templater` to create project-specific agent definitions.

### 3. Configure Git and Local Agents

```bash
# Add available-agents to your repo
git add .claude/available-agents/

# Add to .gitignore (ignore the overall .claude and .npl folders except available-agents)
echo ".claude/" >> .gitignore
echo "!.claude/available-agents/" >> .gitignore
echo ".npl/" >> .gitignore

# Create local agents directory and symlink agents you want to use
mkdir -p .claude/agents
ln -s ../available-agents/agent-name.md .claude/agents/
```

### 4. Restart Claude Code

Restart Claude Code to make the new agents available in your session.

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
dump-files src/api/ | @npl-technical-writer generate api-doc

# Analyze project structure for architecture decisions
git-tree | @npl-thinker evaluate architecture-patterns

# Assess code organization complexity
git-dir-depth src/ | @npl-grader assess --criteria=organization

# Extract documentation for content review
dump-files docs/ | @npl-technical-writer review --mode=annotate
```

#### Quick Usage Examples

**View Complete Project Structure**
```bash
# Visual tree of entire project
git-tree

# Focus on specific module
git-tree core/agents/
```

**Analyze Directory Complexity**
```bash
# Get depth metrics for project organization
git-dir-depth .

# Focus on specific component
git-tree-depth core/
```

**Extract Code for Analysis**
```bash
# Dump all files in source directory
dump-files src/

# Extract only Markdown files
dump-files . -g "*.md"

# Extract multiple file types
dump-files . -g "*.md" -g "src/*.ts"

# Extract specific module for documentation
dump-files npl/ > npl-docs.txt
```

#### Script Locations

**Available Scripts** (`~/.npl/core/scripts/` - add to PATH)
- `dump-files` - Git-aware file dumping with `-g`/`--glob` pattern filtering
- `git-tree` - Visual directory tree (requires `tree` command)
- `git-tree-depth` - Directory depth analysis
- `npl-load` - NPL component/metadata/style loader with dependency tracking
- `npl-persona` - Comprehensive persona management (lifecycle, journals, tasks, KB)
- `npl-fim-config` - FIM visualization configuration tool

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
~/.npl/                          # NPL Framework (installed here)
├── core/                        # Core framework
│   ├── agents/                  # Core agent definitions (16+ agents)
│   ├── commands/                # Slash commands (/init-project-fast, /update-arch, etc.)
│   ├── scripts/                 # Utility scripts (add to PATH)
│   ├── additional-agents/       # Extended agent library (30+ agents)
│   └── prompts/                 # Prompt templates
├── npl/                         # NPL syntax documentation
│   ├── directive/               # Directive definitions
│   ├── fences/                  # Code fence types
│   ├── formatting/              # Output formatting specs
│   ├── instructing/             # Instruction patterns
│   ├── pumps/                   # Thinking/reasoning patterns
│   └── prefix/                  # Response mode indicators
├── skeleton/                    # Project scaffolding templates
│   ├── CLAUDE.md                # Template for project CLAUDE.md
│   └── agents/                  # Agent templates (.npl-template.md)
├── demo/                        # Examples and demonstrations
├── doc/                         # Technical documentation
├── mcp-server/                  # MCP server implementation
└── meta/                        # Organization/team metadata

~/.claude/                       # Claude Code configuration
├── agents/                      # Symlinks to core/agents/ and selected additional agents
└── commands/                    # Symlink to core/commands/

<your-project>/                  # Per-project structure
├── .claude/
│   ├── available-agents/        # Project-tailored agents (committed to repo)
│   └── agents/                  # Symlinks to available-agents/ (gitignored)
└── docs/
    ├── PROJECT-ARCH.md          # Generated by /update-arch
    └── PROJECT-LAYOUT.md        # Generated by /update-arch
```

## Key Components

### Core Agents (`~/.npl/core/agents/` → symlinked to `~/.claude/agents/`)
- **npl-templater**: Template creation and hydration
- **npl-grader**: NPL syntax and structure evaluation
- **npl-persona**: AI persona development and management
- **npl-thinker**: Complex reasoning and analysis
- **npl-technical-writer**: Technical documentation specialist
- **npl-fim**: Fill-in-middle code completion
- **npl-threat-modeler**: Security analysis and threat modeling

### Agent Templates (`~/.npl/skeleton/agents/`)
- **npl-gopher-scout**: System exploration and analysis
- **npl-qa**: Question answering specialist
- **npl-system-digest**: System analysis and reporting
- **npl-tdd-builder**: Test-driven development assistant
- **npl-tool-forge**: Custom tool creation

### Additional Agents (`~/.npl/core/additional-agents/`)
Extended library of specialized agents organized by category:
- **Infrastructure**: System architecture and deployment agents
- **Marketing**: Content creation and marketing automation
- **QA**: Testing and quality assurance specialists
- **Research**: Data analysis and research assistants
- **Security**: Threat modeling and security analysis
See [Additional Agents Documentation](doc/agents/README.md) for complete list.

### NPL Documentation (`~/.npl/npl/`)
Complete NPL syntax reference including directives, fences, formatting, instruction patterns, and thinking pumps.

## NPL Syntax Framework

NPL uses Unicode symbols for precise semantic communication:

- `⌜⌝`: Agent definition boundaries
- `⟪⟫`: Dynamic content placeholders  
- `↦`: Directive mappings
- `␂␃`: Content delimiters
- `{{#if}}`: Conditional logic blocks

## Workflow

### Initial Setup (One-time)
1. Clone repository to `~/.npl`
2. Add `~/.npl/core/scripts` to PATH
3. Symlink core agents to `~/.claude/agents/`
4. Symlink core commands to `~/.claude/commands/`
5. Restart Claude Code

### Per-Project Setup
1. Run `/init-project-fast` to initialize CLAUDE.md
2. Run `/update-arch` to generate PROJECT-ARCH.md and PROJECT-LAYOUT.md
3. Run `/hydrate-agents` to create project-tailored agents in `.claude/available-agents/`
4. Symlink desired agents from `available-agents/` to `.claude/agents/`
5. Restart Claude Code

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

- Claude Code CLI
- Unix-like environment (Linux, macOS, WSL)
- Git (for repository operations and git-aware scripts)
- `tree` command (optional, for `git-tree` script)
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
The `~/.npl/core/additional-agents/` directory contains an extended library of specialized agents beyond the core set. These agents cover specific domains like infrastructure, marketing, QA, research, and security. Review the [Additional Agents Documentation](doc/agents/README.md) to explore available options.

### Slash Commands
NPL provides slash commands for common setup tasks:
- `/init-project-fast` - Quick project initialization
- `/init-project` - Full interactive project setup
- `/update-arch` - Generate/update PROJECT-ARCH.md and PROJECT-LAYOUT.md
- `/update-layout` - Update PROJECT-LAYOUT.md only
- `/hydrate-agents` - Create project-tailored agents (pending)

## Support

NPL is developed by Noizu Labs ML. This framework provides foundational tools for structured language model interactions through proven prompting methodologies.