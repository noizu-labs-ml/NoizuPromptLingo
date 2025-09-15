# NPL Template Variables

Template variables enable dynamic content generation and conditional logic in NPL agents and templates. This syntax allows agents to adapt behavior based on context, load resources conditionally, and generate customized content.

## Variable Types

### Single Variable Interpolation
Basic variable substitution using double braces:
```npl
{{variable_name}}
```

**Examples from agents:**
```npl
load .claude/npl/templates/{{document_type}}.md into context.
load {{HOUSE_STYLE_TECHNICAL}} into context.
load {{rubric_file}} into context.
```

### Descriptive Placeholder Variables
Template variables with descriptive metadata:
```npl
{variable_name|description}
```

**Examples from templates:**
```npl
{project_name|Extracted from package.json or directory name}
{db_type|Detected from dependencies and config files}
{system_type|System type}
```

## Conditional Blocks

### Simple If Conditions
```npl
{{if condition}}
content when true
{{/if}}
```

**Usage patterns:**
```npl
{{if document_type}}
load .claude/npl/templates/{{document_type}}.md into context.
{{/if}}

{{if HOUSE_STYLE_TECHNICAL_ADDENDUM}}
load {{HOUSE_STYLE_TECHNICAL_ADDENDUM}} into context.
{{/if}}
```

### If-Else Blocks
```npl
{{if condition}}
content when true
{{else}}
content when false
{{/if}}
```

**Examples:**
```npl
{{if file_contains(HOUSE_STYLE_TECHNICAL, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
```

### Hash-Style Conditional Blocks
```npl
{{#if condition}}
content when true
{{/if}}
```

**Template examples:**
```npl
{{#if has_specialization}}
## {system_type|System type} Specialization
{{/if}}

{{#if load_npl_context}}
load .claude/npl.md into context.
{{/if}}
```

### Nested Conditionals
```npl
{{if outer_condition}}
  {{if inner_condition}}
  nested content
  {{/if}}
{{/if}}
```

**Real usage:**
```npl
{{if load_default_house_styles}}
{{if file_exists("~/.claude/npl-m/house-style/technical-style.md")}}
load ~/.claude/npl-m/house-style/technical-style.md into context.
{{/if}}
{{/if}}
```

## Iteration Patterns

### For-Each Loops
```npl
{{#each collection}}
content for each item
{{/each}}
```

**Template examples:**
```npl
{{#each core_functions}}
- {function_description}
{{/each}}

{{#each focus_areas}}
- **{area_name|Focus area}**: {area_description|What this area covers}
{{/each}}
```

### For-In Loops
```npl
{{for item in collection}}
content for each item
{{/for}}
```

**Agent usage:**
```npl
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/technical-style.md")}}
load {{path}}/house-style/technical-style.md into context.
{{/if}}
{{/for}}
```

## Variable Resolution

### Environment Variables
Variables can reference environment variables or configuration values:
```npl
{{HOUSE_STYLE_TECHNICAL}}
{{NLP_VERSION}}
{{rubric_file}}
```

### Computed Variables
Variables resolved through function calls or expressions:
```npl
{{file_exists("path/to/file")}}
{{file_contains(HOUSE_STYLE_TECHNICAL, "+load-default-styles")}}
```

### Context Variables
Variables derived from project or runtime context:
```npl
{{document_type}}
{{content_type}}
{{path_hierarchy_from_project_to_target}}
```

## Special Functions

### File System Functions
```npl
{{file_exists("path/to/file")}}          # Check if file exists
{{file_contains(file, "pattern")}}       # Check if file contains string
```

### Path Functions
```npl
{{path_hierarchy_from_project_to_target}}  # Generate path hierarchy
{{path}}/house-style/technical-style.md    # Path construction
```

## Variable Scoping

### Global Variables
Available throughout template processing:
- Environment variables (`HOUSE_STYLE_*`, `NLP_VERSION`)
- System variables (`document_type`, `content_type`)
- Configuration variables (`load_default_house_styles`)

### Loop-Scoped Variables
Available only within iteration blocks:
```npl
{{#each items}}
{item_name}           # Available inside loop
{item_description}    # Available inside loop
{{/each}}
```

### Conditional-Scoped Variables
Variables set within conditional blocks:
```npl
{{if condition}}
load_default_house_styles: true
{{/if}}
```

## Template Loading Patterns

### Conditional Resource Loading
```npl
{{if document_type}}
load .claude/npl/templates/{{document_type}}.md into context.
{{/if}}

{{if rubric_file}}
load {{rubric_file}} into context.
{{/if}}
```

### Hierarchical Style Loading
```npl
{{if load_default_house_styles}}
{{if file_exists("~/.claude/npl-m/house-style/technical-style.md")}}
load ~/.claude/npl-m/house-style/technical-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/technical-style.md")}}
load .claude/npl-m/house-style/technical-style.md into context.
{{/if}}
{{/if}}
```

### Dynamic Path Construction
```npl
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/technical-style.md")}}
load {{path}}/house-style/technical-style.md into context.
{{/if}}
{{/for}}
```

## Agent-Specific Patterns

### Technical Writer Agent
```npl
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
{{/if}}
```

### Marketing Writer Agent
```npl
{{if content_type}}
load .claude/npl/templates/marketing/{{content_type}}.md into context.
{{/if}}

{{if HOUSE_STYLE_MARKETING_ADDENDUM}}
load {{HOUSE_STYLE_MARKETING_ADDENDUM}} into context.
{{/if}}
```

### Grader Agent
```npl
{{if rubric_file}}
load {{rubric_file}} into context.
{{/if}}
```

## Template Generation Patterns

### Descriptive Placeholders
```npl
# {Component/Feature Name}
## Overview
[...2-3p|Generate based on README and project structure analysis]

{project_name|Extracted from package.json or directory name}
{db_connection|Extracted from env or config}
```

### Conditional Sections
```npl
{{#if has_database}}
## Database Configuration
- Type: {db_type|Detected from dependencies and config files}
{{/if}}

{{#if has_specialization}}
## {system_type|System type} Specialization
{{/if}}
```

### Iterative Content Generation
```npl
{{#each core_functions}}
- {function_description}
{{/each}}

{{#each integration_patterns}}
- **{pattern_name}**: {pattern_description}
{{/each}}
```

## Best Practices

### Variable Naming
- Use descriptive names: `document_type` not `dt`
- Use snake_case: `house_style_technical` 
- Include context: `HOUSE_STYLE_TECHNICAL_ADDENDUM`

### Conditional Logic
- Check existence before use: `{{if rubric_file}}`
- Provide fallbacks: `{{else}}` blocks for critical paths
- Use descriptive conditions: `has_database`, `load_default_styles`

### Template Design
- Include descriptive metadata: `{variable|description}`
- Use consistent placeholder patterns
- Document expected variables in template headers

### Error Handling
- Always check file existence before loading
- Provide meaningful defaults
- Use conditional loading for optional resources

## Common Variable Patterns

### Configuration Variables
```npl
{{NLP_VERSION}}
{{GPT_PRO_VERSION}}
{{TOOL_OUTPUT_FORMAT}}
```

### House Style Variables
```npl
{{HOUSE_STYLE_TECHNICAL}}
{{HOUSE_STYLE_TECHNICAL_ADDENDUM}}
{{HOUSE_STYLE_MARKETING}}
```

### Template Type Variables
```npl
{{document_type}}
{{content_type}}
{{rubric_file}}
```

### System Context Variables
```npl
{{path_hierarchy_from_project_to_target}}
{{load_default_house_styles}}
{{has_specialization}}
```

This template variable system provides powerful dynamic content generation while maintaining readability and maintainability in NPL agent definitions and templates.