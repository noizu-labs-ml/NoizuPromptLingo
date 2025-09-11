# NPL House Style Framework

Minimal framework for house style loading supporting environment variable overrides, path hierarchy resolution, and the `+load-default-styles` flag mechanism used by writer agents.

## Overview

The NPL House Style Framework provides a standardized system for loading writing style guides with sophisticated precedence rules. It supports:

- **Environment Variable Overrides**: `HOUSE_STYLE_*` variables for custom style loading
- **Path Hierarchy Resolution**: Automatic style discovery from project root to target
- **Default Style Control**: `+load-default-styles` flag to control cascading
- **Multiple Style Types**: Technical, marketing, and extensible custom styles

This framework is used by 40% of NPL agents and provides the foundation for consistent, scalable writing style management across projects and teams.

## Architecture

```
house-style/
├── README.md                   # This documentation
├── framework.md                # Core loading algorithm
├── env-variables.md            # Environment variable patterns
├── path-resolver.md            # Path hierarchy system
├── templates/                  # Style guide templates
│   ├── technical-style.md      # Technical writing template
│   ├── marketing-style.md      # Marketing writing template
│   └── base-style.md          # Universal style template
└── examples/                   # Usage examples
    ├── technical-writer.md     # Technical writer integration
    ├── marketing-writer.md     # Marketing writer integration
    └── custom-writer.md       # Custom writer example
```

## Quick Start

### 1. Environment Variables
```bash
# Override with specific style file
export HOUSE_STYLE_TECHNICAL="/path/to/custom-tech-style.md"

# Add supplementary styles
export HOUSE_STYLE_TECHNICAL_ADDENDUM="/path/to/extra-guidelines.md"

# Marketing styles
export HOUSE_STYLE_MARKETING="/path/to/brand-style.md"
```

### 2. Directory Structure
```
project/
├── .claude/npl-m/house-style/
│   ├── technical-style.md      # Project-wide technical style
│   └── marketing-style.md      # Project-wide marketing style
├── docs/house-style/
│   └── technical-style.md      # Documentation-specific overrides
└── marketing/house-style/
    └── marketing-style.md      # Marketing team overrides
```

### 3. Style Guide Content
```markdown
# Technical Writing Style Guide

## Voice and Tone
- Direct and precise
- Active voice preferred
- Present tense for instructions

## Structure
- Lead with key information
- Use bullet points for lists
- Include code examples

# Control flag (optional)
+load-default-styles
```

## Loading Precedence

The framework loads styles in this order (later overrides earlier):

1. **Environment Addendum**: `HOUSE_STYLE_{TYPE}_ADDENDUM` (always loaded first)
2. **Environment Override**: `HOUSE_STYLE_{TYPE}` (can disable defaults with `+load-default-styles`)
3. **Home Global**: `~/.claude/npl-m/house-style/{type}-style.md` (if defaults enabled)
4. **Project Global**: `.claude/npl-m/house-style/{type}-style.md` (if defaults enabled)
5. **Path Hierarchy**: From project root toward target directory (if defaults enabled)

### Key Features
- **Addendum First**: Supplementary styles loaded before all others
- **Override Control**: Primary override can disable entire default hierarchy
- **Flag Control**: `+load-default-styles` in override files continues default loading
- **Progressive Override**: Path hierarchy allows local overrides of global styles

## Integration with Writer Agents

```markdown
# In your agent definition:

# House Style Context Loading
{{if HOUSE_STYLE_TECHNICAL_ADDENDUM}}
load {{HOUSE_STYLE_TECHNICAL_ADDENDUM}} into context.
{{/if}}
{{if HOUSE_STYLE_TECHNICAL}}
load {{HOUSE_STYLE_TECHNICAL}} into context.
{{if file_contains(HOUSE_STYLE_TECHNICAL, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
{{else}}
load_default_house_styles: true
{{/if}}

{{if load_default_house_styles}}
# Load style guides in hierarchy order
{{if file_exists("~/.claude/npl-m/house-style/technical-style.md")}}
load ~/.claude/npl-m/house-style/technical-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/technical-style.md")}}
load .claude/npl-m/house-style/technical-style.md into context.
{{/if}}
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/technical-style.md")}}
load {{path}}/house-style/technical-style.md into context.
{{/if}}
{{/for}}
{{/if}}
```

## Supported Style Types

- **technical**: Technical documentation and specifications
- **marketing**: Marketing copy and promotional content  
- **legal**: Legal documents and compliance content
- **academic**: Academic papers and research content
- **creative**: Creative writing and storytelling
- **business**: Business communications and reports

## Usage Examples

### Technical Writer with Custom Style
```bash
# Set project-specific technical style
export HOUSE_STYLE_TECHNICAL="/path/to/company-tech-style.md"

# Agent will load custom style instead of defaults
@npl-technical-writer generate spec --component=auth
```

### Marketing Writer with Addendum
```bash
# Use default styles plus campaign-specific additions
export HOUSE_STYLE_MARKETING_ADDENDUM="/path/to/campaign-guidelines.md"

# Agent loads defaults + campaign guidelines
@npl-marketing-writer generate landing-page --product="new-feature"
```

### Path-Based Style Override
```
project/
├── .claude/npl-m/house-style/marketing-style.md    # General marketing style
└── campaigns/black-friday/house-style/
    └── marketing-style.md                          # Campaign-specific override

# When working in campaigns/black-friday/, both styles are loaded
# with campaign-specific style taking precedence
```

## Best Practices

1. **Start Simple**: Begin with basic templates and expand as needed
2. **Document Precedence**: Always document which styles override others
3. **Test Combinations**: Verify style loading works as expected
4. **Version Control**: Keep style guides in version control
5. **Team Alignment**: Ensure all writers understand the precedence system

## Framework Files

### Core Documentation
- **`framework.md`** (268 lines): Core loading algorithm and implementation details
- **`env-variables.md`** (341 lines): Complete environment variable documentation  
- **`path-resolver.md`** (422 lines): Path hierarchy resolution system
- **`compatibility.md`** (246 lines): Validation of compatibility with existing agents

### Style Guide Templates  
- **`templates/base-style.md`** (172 lines): Universal writing style template
- **`templates/technical-style.md`** (158 lines): Technical writing template
- **`templates/marketing-style.md`** (236 lines): Marketing writing template

### Integration Examples
- **`examples/technical-writer.md`** (289 lines): Technical writer integration
- **`examples/marketing-writer.md`** (362 lines): Marketing writer integration  
- **`examples/custom-writer.md`** (419 lines): Custom writer example

**Total Framework Size**: 3,098 lines of comprehensive documentation and templates

This framework is used by 40% of NPL agents and provides the foundation for consistent, scalable writing style management across projects and teams.