# Technical Writer Integration Example

This example shows how to integrate house style loading with NPL technical writer agents.

## Agent Integration Pattern

### Complete House Style Loading Block
```markdown
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

## Usage Scenarios

### Scenario 1: Default Style Loading
**Setup**: No environment variables set

**Directory Structure**:
```
~/.claude/npl-m/house-style/
└── technical-style.md              # Personal preferences

/project/.claude/npl-m/house-style/
└── technical-style.md              # Project-wide technical style

/project/docs/api/house-style/
└── technical-style.md              # API-specific overrides
```

**Working on**: `/project/docs/api/endpoints.md`

**Loading Order**:
1. `~/.claude/npl-m/house-style/technical-style.md`
2. `/project/.claude/npl-m/house-style/technical-style.md`
3. `/project/house-style/technical-style.md` (if exists)
4. `/project/docs/house-style/technical-style.md` (if exists)
5. `/project/docs/api/house-style/technical-style.md`

### Scenario 2: Environment Override with Continuation
**Setup**:
```bash
export HOUSE_STYLE_TECHNICAL="/company/engineering-standards.md"
```

**Contents of `/company/engineering-standards.md`**:
```markdown
# Company Engineering Standards

## Documentation Requirements
- All APIs must include OpenAPI specs
- Code examples must be tested
- Include version compatibility info

+load-default-styles
```

**Loading Order**:
1. `/company/engineering-standards.md`
2. `~/.claude/npl-m/house-style/technical-style.md`
3. `/project/.claude/npl-m/house-style/technical-style.md`
4. Path hierarchy styles...

### Scenario 3: Environment Override without Continuation
**Setup**:
```bash
export HOUSE_STYLE_TECHNICAL="/client/acme-tech-style.md"
```

**Contents of `/client/acme-tech-style.md`** (no `+load-default-styles`):
```markdown
# ACME Corporation Technical Style

## Requirements
- Use ACME terminology
- Include ACME copyright
- Follow ACME format templates
```

**Loading Order**:
1. `/client/acme-tech-style.md`
2. *(stops here - no default loading)*

### Scenario 4: Addendum Pattern
**Setup**:
```bash
export HOUSE_STYLE_TECHNICAL_ADDENDUM="/project/security-requirements.md"
```

**Loading Order**:
1. `/project/security-requirements.md` (addendum loaded first)
2. `~/.claude/npl-m/house-style/technical-style.md`
3. `/project/.claude/npl-m/house-style/technical-style.md`
4. Path hierarchy styles...

### Scenario 5: Combined Override and Addendum
**Setup**:
```bash
export HOUSE_STYLE_TECHNICAL="/corp/base-tech-style.md"
export HOUSE_STYLE_TECHNICAL_ADDENDUM="/project/additional-rules.md"
```

**Contents of `/corp/base-tech-style.md`**:
```markdown
# Corporate Base Technical Style
## Core requirements...
+load-default-styles
```

**Loading Order**:
1. `/project/additional-rules.md` (addendum)
2. `/corp/base-tech-style.md` (primary)
3. `~/.claude/npl-m/house-style/technical-style.md` (defaults continue)
4. `/project/.claude/npl-m/house-style/technical-style.md`
5. Path hierarchy styles...

## Style File Examples

### Personal Technical Style (`~/.claude/npl-m/house-style/technical-style.md`)
```markdown
# Personal Technical Writing Preferences

## Voice
- Prefer active voice
- Use present tense for instructions
- Be direct and concise

## Code Examples
- Always include language specification
- Add comments for complex logic
- Test all examples before including

+load-default-styles
```

### Project Technical Style (`.claude/npl-m/house-style/technical-style.md`)
```markdown
# Project Technical Documentation Style

## Requirements
- Include compatibility matrix
- Use standard template structure
- Reference internal architecture docs

## Code Standards
- Follow project coding conventions
- Include error handling examples
- Document all public APIs

+load-default-styles
```

### API-Specific Style (`docs/api/house-style/technical-style.md`)
```markdown
# API Documentation Specific Guidelines

## API Documentation
- Include complete OpenAPI specs
- Provide working curl examples
- Document all error responses
- Include rate limiting information

## Example Format
```bash
# Good API example
curl -X GET "https://api.example.com/v1/users" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json"
```

+load-default-styles
```

## Agent Implementation Details

### Required Template Functions
```markdown
# These functions must be available in the agent template system:

function file_exists(filepath):
  """Check if file exists and is readable"""
  return os.path.exists(filepath) and os.access(filepath, os.R_OK)

function file_contains(filepath, text):
  """Check if file contains specific text"""
  if file_exists(filepath):
    content = read_file(filepath)
    return text in content
  return false

function path_hierarchy_from_project_to_target(project_root, target_path):
  """Generate hierarchy of directories from project root to target"""
  # See path-resolver.md for implementation details
```

### Integration with Existing Agents
The house style loading block should be inserted into existing technical writer agents between the NPL pump loading and the main agent definition:

```markdown
---
name: npl-technical-writer
description: Technical writer with house style support
---

load .claude/npl.md into context.
load .claude/npl/pumps/npl-intent.md into context.
# ... other pump loads ...

# House Style Context Loading
# Insert complete house style loading block here

---
⌜npl-technical-writer|writer|NPL@1.0⌝
# NPL Technical Writer Agent
# ... rest of agent definition ...
```

## Testing and Validation

### Test Environment Setup
```bash
# Create test directory structure
mkdir -p ~/.claude/npl-m/house-style
mkdir -p test-project/.claude/npl-m/house-style
mkdir -p test-project/docs/api/house-style

# Create test style files
echo "# Personal tech style" > ~/.claude/npl-m/house-style/technical-style.md
echo "# Project tech style" > test-project/.claude/npl-m/house-style/technical-style.md
echo "# API-specific style" > test-project/docs/api/house-style/technical-style.md
```

### Test Cases
```bash
# Test 1: Default loading
cd test-project/docs/api
@npl-technical-writer generate spec --component=auth
# Should load all three style files

# Test 2: Environment override with continuation
export HOUSE_STYLE_TECHNICAL="$PWD/custom-style.md"
echo -e "# Custom style\n+load-default-styles" > custom-style.md
@npl-technical-writer generate readme
# Should load custom style plus defaults

# Test 3: Environment override without continuation
echo "# Custom style only" > custom-style-only.md
export HOUSE_STYLE_TECHNICAL="$PWD/custom-style-only.md"
@npl-technical-writer generate api-doc
# Should load only custom style

# Test 4: Addendum pattern
export HOUSE_STYLE_TECHNICAL_ADDENDUM="$PWD/extra-rules.md"
echo "# Extra rules" > extra-rules.md
@npl-technical-writer generate spec
# Should load extra rules plus defaults

# Clean up
unset HOUSE_STYLE_TECHNICAL
unset HOUSE_STYLE_TECHNICAL_ADDENDUM
```

This integration pattern provides the sophisticated style loading capabilities required by technical writing agents while maintaining compatibility with existing NPL agent architecture.