# NPL House Style Framework - Core Loading Algorithm

This document defines the sophisticated style loading system used by NPL writer agents with environment variable overrides, path hierarchy resolution, and the `+load-default-styles` flag mechanism.

## Loading Algorithm

The framework implements a cascading style loading system with the following precedence (later overrides earlier):

### Phase 1: Environment Variable Addendum
```markdown
{{if HOUSE_STYLE_{TYPE}_ADDENDUM}}
load {{HOUSE_STYLE_{TYPE}_ADDENDUM}} into context.
{{/if}}
```

**Purpose**: Always-loaded supplementary styles that extend any other loaded styles.

### Phase 2: Primary Environment Override
```markdown
{{if HOUSE_STYLE_{TYPE}}}
load {{HOUSE_STYLE_{TYPE}}} into context.
{{if file_contains(HOUSE_STYLE_{TYPE}, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
{{else}}
load_default_house_styles: true
{{/if}}
```

**Purpose**: Primary style override that can optionally disable default cascading.

### Phase 3: Default Style Hierarchy (if enabled)
```markdown
{{if load_default_house_styles}}
# Load style guides in hierarchy order
{{if file_exists("~/.claude/npl-m/house-style/{type}-style.md")}}
load ~/.claude/npl-m/house-style/{type}-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/{type}-style.md")}}
load .claude/npl-m/house-style/{type}-style.md into context.
{{/if}}
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/{type}-style.md")}}
load {{path}}/house-style/{type}-style.md into context.
{{/if}}
{{/for}}
{{/if}}
```

**Purpose**: Load default style hierarchy from global to local, allowing progressive override.

## Style Type Patterns

### Supported Style Types
- `technical`: Technical documentation (npl-technical-writer)
- `marketing`: Marketing copy (npl-marketing-writer)  
- `legal`: Legal documents
- `academic`: Academic papers
- `creative`: Creative writing
- `business`: Business communications

### Environment Variable Naming Convention
```bash
# Primary override (can disable defaults)
HOUSE_STYLE_{TYPE}="/path/to/style.md"

# Always-loaded addendum
HOUSE_STYLE_{TYPE}_ADDENDUM="/path/to/extra.md"

# Examples:
HOUSE_STYLE_TECHNICAL="/company/tech-style.md"
HOUSE_STYLE_TECHNICAL_ADDENDUM="/project/extra-guidelines.md"
HOUSE_STYLE_MARKETING="/brand/marketing-voice.md"
HOUSE_STYLE_MARKETING_ADDENDUM="/campaign/special-rules.md"
```

## Path Hierarchy Resolution

### Resolution Algorithm
```alg
function path_hierarchy_from_project_to_target(project_root, target_path):
  paths = []
  current = project_root
  
  # Add project root
  paths.append(current)
  
  # Split target path relative to project root
  relative_path = target_path.relative_to(project_root)
  parts = relative_path.parts
  
  # Build hierarchy: project_root -> ... -> target_directory
  for i in range(len(parts)):
    current = current / parts[i]
    if current.is_dir():
      paths.append(current)
    
  return paths
```

### Example Hierarchy
```
Project: /project
Target:  /project/docs/api/endpoints/users

Hierarchy:
1. /project
2. /project/docs  
3. /project/docs/api
4. /project/docs/api/endpoints
5. /project/docs/api/endpoints/users

Style Loading Order:
1. ~/.claude/npl-m/house-style/technical-style.md
2. /project/.claude/npl-m/house-style/technical-style.md
3. /project/house-style/technical-style.md
4. /project/docs/house-style/technical-style.md
5. /project/docs/api/house-style/technical-style.md
6. /project/docs/api/endpoints/house-style/technical-style.md
7. /project/docs/api/endpoints/users/house-style/technical-style.md
```

## Control Flags

### +load-default-styles Flag
When present in a style file, this flag indicates that default hierarchy loading should continue despite environment override.

**Usage in style files:**
```markdown
# Company Technical Style Guide

## Voice Guidelines
- Use active voice
- Be concise and direct

## Formatting Rules
- Use ## for section headers
- Include code examples

# This flag allows default styles to load after this override
+load-default-styles
```

**Without flag**: Environment variable completely replaces default loading
**With flag**: Environment variable loads first, then defaults continue loading

### Flag Detection Logic
```markdown
{{if file_contains(HOUSE_STYLE_{TYPE}, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
```

## Integration Patterns

### Writer Agent Template
```markdown
# House Style Context Loading
# Load {type} writing style guides in precedence order
{{if HOUSE_STYLE_{TYPE}_ADDENDUM}}
load {{HOUSE_STYLE_{TYPE}_ADDENDUM}} into context.
{{/if}}
{{if HOUSE_STYLE_{TYPE}}}
load {{HOUSE_STYLE_{TYPE}}} into context.
{{if file_contains(HOUSE_STYLE_{TYPE}, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
{{else}}
load_default_house_styles: true
{{/if}}

{{if load_default_house_styles}}
# Load style guides in order: home, project .claude, then nearest to target path
{{if file_exists("~/.claude/npl-m/house-style/{type}-style.md")}}
load ~/.claude/npl-m/house-style/{type}-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/{type}-style.md")}}
load .claude/npl-m/house-style/{type}-style.md into context.
{{/if}}
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/{type}-style.md")}}
load {{path}}/house-style/{type}-style.md into context.
{{/if}}
{{/for}}
{{/if}}
```

### Function Helpers
```markdown
# Utility functions for agents
function file_contains(filepath, text):
  """Check if file contains specific text"""
  if file_exists(filepath):
    content = read_file(filepath)
    return text in content
  return false

function file_exists(filepath):
  """Check if file exists and is readable"""
  return os.path.exists(filepath) and os.access(filepath, os.R_OK)
```

## Error Handling

### Missing Files
- Non-existent style files are silently skipped
- Invalid paths in environment variables are ignored
- Malformed style files log warnings but don't stop loading

### Circular Dependencies
- Path hierarchy is always resolved upward (root to target)
- Environment variables are loaded in fixed order
- No circular reference protection needed

### Permission Issues
- Files without read permission are skipped
- Network paths require appropriate access
- Relative paths resolved from agent working directory

## Performance Considerations

### File System Efficiency
- Cache `file_exists()` calls during single agent execution
- Use `stat()` calls instead of full file reads for existence checks
- Limit path hierarchy depth to prevent excessive directory traversal

### Memory Management
- Load style files incrementally during agent initialization
- Concatenate styles in memory rather than repeated file access
- Clear style cache between agent sessions

### Network Resources
- Support HTTP/HTTPS URLs in environment variables
- Implement timeout for remote style file loading
- Cache remote styles for offline agent operation

## Debugging and Diagnostics

### Style Loading Trace
Enable verbose logging to show style loading order:
```bash
# Environment variable
export NPL_HOUSE_STYLE_DEBUG=true

# Debug output shows:
# Loading HOUSE_STYLE_TECHNICAL_ADDENDUM: /path/to/extra.md
# Loading HOUSE_STYLE_TECHNICAL: /path/to/main.md (+load-default-styles found)
# Loading ~/.claude/npl-m/house-style/technical-style.md
# Loading .claude/npl-m/house-style/technical-style.md
# Loading ./docs/house-style/technical-style.md
```

### Style Conflict Detection
Warn when styles contain conflicting directives:
```bash
# Example warning:
# WARNING: Style conflict detected
# ~/.claude/npl-m/house-style/technical-style.md: "Use ## for headers"
# ./docs/house-style/technical-style.md: "Use ### for headers"
# Using: ./docs/house-style/technical-style.md (later in precedence)
```

This framework provides the sophisticated style loading capabilities required by NPL writer agents while maintaining simplicity and predictable behavior.