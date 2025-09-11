# NPL Context Loading Mechanisms

Documentation for the NPL agent context loading system, including path resolution, conditional loading, error handling, and loading order precedence.

## Overview

The NPL framework uses a sophisticated context loading system that allows agents to dynamically load relevant NPL components, pump definitions, templates, and style guides based on agent requirements and project context.

## Core Loading Syntax

### Basic Load Statement
```npl
load .claude/npl/pumps/npl-intent.md into context.
```

**Pattern**: `load <path> into context.`
- Path can be absolute or relative to project root
- Files are loaded into agent context for immediate use
- Loading occurs before agent prompt execution

### Conditional Loading
```npl
{{if document_type}}
load .claude/npl/templates/{{document_type}}.md into context.
{{/if}}
```

**Handlebars Integration**: Uses Handlebars templating for conditional logic
- Variable interpolation: `{{variable_name}}`
- Conditional blocks: `{{#if condition}}...{{/if}}`
- For loops: `{{#for item in collection}}...{{/for}}`

## Loading Categories

### 1. Core NPL Framework Loading
Base NPL framework and pump definitions:
```npl
load .claude/npl.md into context.
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-rubric.md into context.
```

### 2. Agent-Specific Pump Loading
Different agents load relevant pumps based on their function:

**npl-technical-writer**:
```npl
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-rubric.md into context.
load .claude/npl/pumps/npl-panel-inline-feedback.md into context.
```

**npl-persona**:
```npl
loads:
  - npl/pumps/npl-cot.md
  - npl/pumps/npl-critique.md
  - npl/pumps/npl-intent.md
  - npl/pumps/npl-mood.md
  - npl/pumps/npl-panel-group-chat.md
  - npl/pumps/npl-panel-inline-feedback.md
  - npl/pumps/npl-panel-reviewer-feedback.md
  - npl/pumps/npl-panel.md
  - npl/pumps/npl-reflection.md
  - npl/pumps/npl-rubric.md
  - npl/pumps/npl-tangent.md
```

**npl-grader**:
```npl
load .claude/npl.md into context.
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-reflection.md into context.
load .claude/npl/pumps/npl-rubric.md into context.
```

### 3. Template Loading
Dynamic template loading based on content type:
```npl
{{if document_type}}
load .claude/npl/templates/{{document_type}}.md into context.
{{/if}}

{{if content_type}}
load .claude/npl/templates/marketing/{{content_type}}.md into context.
{{/if}}
```

### 4. Custom Rubric Loading
```npl
{{if rubric_file}}
load {{rubric_file}} into context.
{{/if}}
```

## Advanced Loading Patterns

### House Style Loading System
Sophisticated precedence-based loading for style guides:

```npl
# House Style Context Loading
# Load technical writing style guides in precedence order (nearest to target first)
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
# Load style guides in order: home, project .claude, then nearest to target path
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

## Path Resolution

### Resolution Priority
1. **Absolute paths**: `/full/path/to/file.md`
2. **Home directory**: `~/.claude/npl-m/house-style/technical-style.md`
3. **Project relative**: `.claude/npl/pumps/npl-intent.md`
4. **Environment variables**: `{{HOUSE_STYLE_TECHNICAL}}`

### Path Hierarchy Loading
```alg
function loadHouseStyles(target_path):
  if HOUSE_STYLE_TECHNICAL_ADDENDUM:
    load(HOUSE_STYLE_TECHNICAL_ADDENDUM) // Override/addendum file first
  
  if HOUSE_STYLE_TECHNICAL:
    load(HOUSE_STYLE_TECHNICAL)
    if not file_contains("+load-default-styles"):
      return // Skip default loading unless explicitly enabled
  
  // Default hierarchy loading
  load("~/.claude/npl-m/house-style/technical-style.md") // Home global
  load(".claude/npl-m/house-style/technical-style.md")  // Project global
  
  // Path-specific loading from project root to target
  for path in path_hierarchy(project_root, target_path):
    if exists(path + "/house-style/technical-style.md"):
      load(path + "/house-style/technical-style.md")
```

### Dynamic Path Variables
- `path_hierarchy_from_project_to_target`: Array of directory paths from project root to target file
- `HOUSE_STYLE_*`: Environment variable overrides
- `document_type`, `content_type`: Context-dependent template selectors

## Conditional Loading Functions

### File Existence Checks
```npl
{{if file_exists("~/.claude/npl-m/house-style/technical-style.md")}}
load ~/.claude/npl-m/house-style/technical-style.md into context.
{{/if}}
```

### Content-Based Conditions
```npl
{{if file_contains(HOUSE_STYLE_TECHNICAL, "+load-default-styles")}}
load_default_house_styles: true
{{/if}}
```

### Variable-Based Loading
```npl
{{if document_type}}
load .claude/npl/templates/{{document_type}}.md into context.
{{/if}}

{{if rubric_file}}
load {{rubric_file}} into context.
{{/if}}
```

## Loading Order and Precedence

### Standard Loading Order
1. **Core NPL Framework**: `.claude/npl.md`
2. **Required Pumps**: Agent-specific pump definitions
3. **Conditional Templates**: Based on document/content type
4. **Environment Overrides**: `HOUSE_STYLE_*` variables
5. **Style Hierarchy**: From global to local (project → directory → target)

### Precedence Rules
**Later loads override earlier ones**:
- Environment variables override defaults
- Local style guides override global ones  
- Path-specific styles override project-wide styles
- Addendum files override base style files

### Example Loading Sequence
For `npl-technical-writer` generating a spec in `/project/docs/api/`:
```sequence
1. load .claude/npl.md
2. load .claude/npl/pumps/npl-intent.md  
3. load .claude/npl/pumps/npl-critique.md
4. load .claude/npl/pumps/npl-rubric.md
5. load .claude/npl/pumps/npl-panel-inline-feedback.md
6. IF document_type="spec": load .claude/npl/templates/spec.md
7. IF HOUSE_STYLE_TECHNICAL_ADDENDUM: load $HOUSE_STYLE_TECHNICAL_ADDENDUM
8. IF HOUSE_STYLE_TECHNICAL: load $HOUSE_STYLE_TECHNICAL
9. load ~/.claude/npl-m/house-style/technical-style.md (if exists)
10. load .claude/npl-m/house-style/technical-style.md (if exists)
11. load ./house-style/technical-style.md (if exists)
12. load ./docs/house-style/technical-style.md (if exists)
13. load ./docs/api/house-style/technical-style.md (if exists)
```

## Error Handling

### Missing File Handling
**Graceful Degradation**: Loading continues even if files are missing
```npl
{{if file_exists("~/.claude/npl-m/house-style/technical-style.md")}}
load ~/.claude/npl-m/house-style/technical-style.md into context.
{{/if}}
```
- No error if file doesn't exist
- Agent continues with available context
- Warns in debug mode but doesn't fail

### Invalid Path Handling
```npl
# These patterns handle invalid paths gracefully:
{{if HOUSE_STYLE_TECHNICAL}}
load {{HOUSE_STYLE_TECHNICAL}} into context.  # Only if variable is set
{{/if}}
```

### Content Validation
```npl
{{if file_contains(HOUSE_STYLE_TECHNICAL, "+load-default-styles")}}
# Only proceed if file contains expected content
load_default_house_styles: true
{{/if}}
```

## Agent-Specific Loading Examples

### Example 1: npl-technical-writer
```npl
# Core framework
load .claude/npl.md into context.

# Technical writing pumps
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-rubric.md into context.
load .claude/npl/pumps/npl-panel-inline-feedback.md into context.

# Document-specific templates
{{if document_type}}
load .claude/npl/templates/{{document_type}}.md into context.
{{/if}}

# House style hierarchy
{{if HOUSE_STYLE_TECHNICAL_ADDENDUM}}
load {{HOUSE_STYLE_TECHNICAL_ADDENDUM}} into context.
{{/if}}
# ... (full hierarchy as shown above)
```

### Example 2: npl-grader  
```npl
# Core framework
load .claude/npl.md into context.

# Evaluation-focused pumps
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-reflection.md into context.
load .claude/npl/pumps/npl-rubric.md into context.

# Custom rubric loading
{{if rubric_file}}
load {{rubric_file}} into context.
{{/if}}
```

### Example 3: npl-persona
```npl
# Comprehensive pump loading for persona simulation
loads:
  - npl/pumps/npl-cot.md
  - npl/pumps/npl-critique.md
  - npl/pumps/npl-intent.md
  - npl/pumps/npl-mood.md
  - npl/pumps/npl-panel-group-chat.md
  - npl/pumps/npl-panel-inline-feedback.md
  - npl/pumps/npl-panel-reviewer-feedback.md
  - npl/pumps/npl-panel.md
  - npl/pumps/npl-reflection.md
  - npl/pumps/npl-rubric.md
  - npl/pumps/npl-tangent.md
```

## Available Pump Definitions

Based on analysis of existing agents, the following pumps are available:

### Core Reasoning Pumps
- `npl-intent.md`: Intent declaration and step tracking
- `npl-cot.md`: Chain-of-thought reasoning
- `npl-critique.md`: Critical analysis and feedback
- `npl-reflection.md`: Post-response self-assessment
- `npl-rubric.md`: Structured evaluation criteria

### Communication Pumps
- `npl-mood.md`: Emotional context and tone
- `npl-panel.md`: Multi-perspective discussion
- `npl-panel-group-chat.md`: Group discussion simulation
- `npl-panel-inline-feedback.md`: Inline annotation system
- `npl-panel-reviewer-feedback.md`: Structured review feedback
- `npl-tangent.md`: Tangential thinking and exploration

## Environment Variables

### Style Guide Variables
- `HOUSE_STYLE_TECHNICAL`: Path to technical writing style guide
- `HOUSE_STYLE_TECHNICAL_ADDENDUM`: Path to style guide override/addition
- `HOUSE_STYLE_MARKETING`: Path to marketing style guide  
- `HOUSE_STYLE_MARKETING_ADDENDUM`: Path to marketing style override

### Template Variables
- `document_type`: Selects document template (spec, pr, issue, doc, readme, api-doc)
- `content_type`: Selects marketing content template
- `rubric_file`: Path to custom evaluation rubric

### Loading Control Variables
- `load_default_house_styles`: Boolean controlling default style loading
- `path_hierarchy_from_project_to_target`: Array of directory paths

## Best Practices

### Loading Organization
1. **Load core framework first**: Always start with `.claude/npl.md`
2. **Load required pumps early**: Ensure essential reasoning tools are available
3. **Use conditional loading**: Only load what's needed for the specific use case
4. **Implement hierarchical overrides**: Allow local customization of global settings

### Performance Considerations
1. **Minimize redundant loading**: Use conditional checks to avoid loading unnecessary files
2. **Order by frequency**: Load commonly used files first
3. **Cache strategy**: Framework handles caching automatically

### Error Prevention
1. **Always use existence checks**: Wrap optional loads in `{{if file_exists(...)}}`
2. **Provide fallbacks**: Ensure agents work with minimal context
3. **Validate variables**: Check variable existence before using in paths

### Documentation Guidelines
1. **Document loading intent**: Comment why specific pumps/files are loaded
2. **Maintain load order**: Document the sequence and reasoning
3. **Update when modifying**: Keep loading patterns synchronized with agent capabilities

## Future Extensions

The loading system is designed to support:
- **Dynamic pump discovery**: Auto-loading based on task analysis
- **Dependency resolution**: Automatic loading of pump dependencies  
- **Context optimization**: Loading only relevant sections of large files
- **Remote loading**: Supporting HTTP/HTTPS resource loading
- **Version management**: Loading specific versions of pumps and templates