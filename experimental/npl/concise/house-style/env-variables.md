# NPL House Style Framework - Environment Variables

Complete documentation for house style environment variable patterns supporting sophisticated style loading used by NPL writer agents.

## Variable Naming Convention

### Primary Style Variables
```bash
HOUSE_STYLE_{TYPE}="/path/to/style.md"
```

**Purpose**: Primary style override that can completely replace default loading hierarchy.

**Behavior**: 
- If set, loads this style file first (after addendum)
- If file contains `+load-default-styles`, continues with default hierarchy
- If file lacks `+load-default-styles`, stops default loading

### Addendum Style Variables  
```bash
HOUSE_STYLE_{TYPE}_ADDENDUM="/path/to/extra.md"
```

**Purpose**: Supplementary styles that are always loaded regardless of other settings.

**Behavior**:
- Always loaded first if present
- Never prevents default style loading
- Useful for project-specific additions to standard styles

## Supported Style Types

### Core Types (implemented by agents)
- **`TECHNICAL`**: Technical documentation styles (npl-technical-writer)
- **`MARKETING`**: Marketing copy styles (npl-marketing-writer)

### Extended Types (framework ready)
- **`LEGAL`**: Legal document styles
- **`ACADEMIC`**: Academic writing styles  
- **`CREATIVE`**: Creative writing styles
- **`BUSINESS`**: Business communication styles
- **`API`**: API documentation styles
- **`TUTORIAL`**: Tutorial and instructional styles

## Environment Variable Patterns

### Single Style Override
```bash
# Replace default technical styles entirely
export HOUSE_STYLE_TECHNICAL="/company/styles/engineering-guide.md"

# Agent behavior:
# 1. Load /company/styles/engineering-guide.md
# 2. If engineering-guide.md lacks +load-default-styles, stop
# 3. If engineering-guide.md has +load-default-styles, continue with defaults
```

### Style with Default Continuation
```bash
# Override with continuation
export HOUSE_STYLE_TECHNICAL="/company/base-tech-style.md"

# Contents of /company/base-tech-style.md:
# # Company Technical Style
# ## Voice: Direct and professional
# +load-default-styles

# Agent behavior:
# 1. Load /company/base-tech-style.md  
# 2. See +load-default-styles flag
# 3. Continue loading: ~/.claude/npl-m/house-style/technical-style.md
# 4. Continue loading: .claude/npl-m/house-style/technical-style.md
# 5. Continue with path hierarchy
```

### Addendum Pattern
```bash
# Keep defaults but add project-specific rules
export HOUSE_STYLE_MARKETING_ADDENDUM="/project/brand-specific.md"

# Agent behavior:
# 1. Load /project/brand-specific.md (addendum first)
# 2. Load default hierarchy:
#    - ~/.claude/npl-m/house-style/marketing-style.md
#    - .claude/npl-m/house-style/marketing-style.md  
#    - Path hierarchy styles
```

### Combined Override and Addendum
```bash
# Complex configuration
export HOUSE_STYLE_TECHNICAL="/corp/engineering-standards.md"
export HOUSE_STYLE_TECHNICAL_ADDENDUM="/project/api-specific-rules.md"

# Contents of /corp/engineering-standards.md:
# # Corporate Engineering Standards
# ## Documentation must include version info
# +load-default-styles

# Agent behavior:
# 1. Load /project/api-specific-rules.md (addendum)
# 2. Load /corp/engineering-standards.md (primary)
# 3. See +load-default-styles, continue with defaults
# 4. Load ~/.claude/npl-m/house-style/technical-style.md
# 5. Load .claude/npl-m/house-style/technical-style.md
# 6. Load path hierarchy styles
```

## File Path Resolution

### Absolute Paths
```bash
# Direct file paths
export HOUSE_STYLE_TECHNICAL="/usr/local/share/styles/tech.md"
export HOUSE_STYLE_MARKETING="/home/user/company-brand.md"
```

### Relative Paths
```bash
# Relative to agent working directory
export HOUSE_STYLE_TECHNICAL="./styles/local-tech.md"
export HOUSE_STYLE_MARKETING="../shared-styles/marketing.md"
```

### Home Directory Expansion
```bash
# Shell expansion supported
export HOUSE_STYLE_TECHNICAL="~/company-styles/engineering.md"
export HOUSE_STYLE_MARKETING="~/.config/writing-styles/brand.md"
```

### Network Resources
```bash
# HTTP/HTTPS URLs supported
export HOUSE_STYLE_TECHNICAL="https://company.com/styles/tech-guide.md"
export HOUSE_STYLE_MARKETING="https://brand.intranet/marketing-voice.md"
```

## Environment Variable Precedence

### Within Same Type
1. `HOUSE_STYLE_{TYPE}_ADDENDUM` (always loaded first)
2. `HOUSE_STYLE_{TYPE}` (primary override)
3. Default hierarchy (if enabled by primary override)

### Cross-Agent Considerations
```bash
# Different agents use different type variables
export HOUSE_STYLE_TECHNICAL="/path/tech.md"     # npl-technical-writer
export HOUSE_STYLE_MARKETING="/path/market.md"   # npl-marketing-writer
export HOUSE_STYLE_LEGAL="/path/legal.md"        # npl-legal-writer

# Agents only load their specific type
```

## Dynamic Environment Management

### Session-Specific Styles
```bash
# Temporary override for current session
export HOUSE_STYLE_TECHNICAL="/tmp/review-specific-style.md"
@npl-technical-writer generate spec --component=auth
unset HOUSE_STYLE_TECHNICAL
```

### Project-Specific Environment Files
```bash
# .env file in project root
cat > .env << EOF
HOUSE_STYLE_TECHNICAL=./styles/project-tech.md
HOUSE_STYLE_MARKETING=./styles/project-brand.md
EOF

# Load and use
source .env
@npl-technical-writer generate readme
```

### Shell Function Helpers
```bash
# Convenience functions for style management
function set_tech_style() {
    export HOUSE_STYLE_TECHNICAL="$1"
    echo "Technical style set to: $1"
}

function set_marketing_style() {
    export HOUSE_STYLE_MARKETING="$1"
    echo "Marketing style set to: $1"
}

function clear_house_styles() {
    unset HOUSE_STYLE_TECHNICAL
    unset HOUSE_STYLE_TECHNICAL_ADDENDUM
    unset HOUSE_STYLE_MARKETING  
    unset HOUSE_STYLE_MARKETING_ADDENDUM
    echo "House styles cleared"
}

# Usage
set_tech_style "./docs/engineering-style.md"
set_marketing_style "./brand/voice-guide.md"
```

## Configuration Examples

### Development Environment
```bash
# Developer personal styles
export HOUSE_STYLE_TECHNICAL="~/.config/npl/dev-tech-style.md"
export HOUSE_STYLE_MARKETING="~/.config/npl/dev-marketing-style.md"
```

### CI/CD Environment
```bash
# Automated documentation generation
export HOUSE_STYLE_TECHNICAL="/ci/templates/release-notes-style.md"
export HOUSE_STYLE_API="/ci/templates/api-doc-style.md"
```

### Team Shared Environment
```bash
# Network-accessible team styles
export HOUSE_STYLE_TECHNICAL="https://team.company.com/styles/engineering.md"
export HOUSE_STYLE_MARKETING="https://team.company.com/styles/product-marketing.md"
```

### Client-Specific Environment
```bash
# Client customization with fallbacks
export HOUSE_STYLE_TECHNICAL="/clients/acme/tech-style.md"
export HOUSE_STYLE_TECHNICAL_ADDENDUM="/clients/acme/special-requirements.md"

# Contents of /clients/acme/tech-style.md includes:
# +load-default-styles
# This ensures ACME gets their custom style plus company defaults
```

## Validation and Testing

### Environment Variable Testing
```bash
# Verify environment setup
function test_house_style_env() {
    echo "=== House Style Environment ==="
    echo "HOUSE_STYLE_TECHNICAL: ${HOUSE_STYLE_TECHNICAL:-not set}"
    echo "HOUSE_STYLE_TECHNICAL_ADDENDUM: ${HOUSE_STYLE_TECHNICAL_ADDENDUM:-not set}"
    echo "HOUSE_STYLE_MARKETING: ${HOUSE_STYLE_MARKETING:-not set}"
    echo "HOUSE_STYLE_MARKETING_ADDENDUM: ${HOUSE_STYLE_MARKETING_ADDENDUM:-not set}"
    
    # Test file accessibility
    for var in HOUSE_STYLE_TECHNICAL HOUSE_STYLE_TECHNICAL_ADDENDUM HOUSE_STYLE_MARKETING HOUSE_STYLE_MARKETING_ADDENDUM; do
        if [[ -n "${!var}" ]]; then
            if [[ -f "${!var}" ]]; then
                echo "✓ $var file exists: ${!var}"
            else
                echo "✗ $var file missing: ${!var}"
            fi
        fi
    done
}
```

### Style Loading Simulation
```bash
# Simulate agent style loading order
function simulate_style_loading() {
    local style_type="$1"
    local target_path="$2"
    
    echo "=== Style Loading Simulation for $style_type ==="
    
    # Phase 1: Addendum
    local addendum_var="HOUSE_STYLE_${style_type}_ADDENDUM"
    if [[ -n "${!addendum_var}" ]]; then
        echo "1. Load addendum: ${!addendum_var}"
    fi
    
    # Phase 2: Primary override
    local primary_var="HOUSE_STYLE_${style_type}"
    if [[ -n "${!primary_var}" ]]; then
        echo "2. Load primary: ${!primary_var}"
        if grep -q "+load-default-styles" "${!primary_var}" 2>/dev/null; then
            echo "   (+load-default-styles found - continuing with defaults)"
            load_defaults=true
        else
            echo "   (no +load-default-styles - stopping default loading)"
            load_defaults=false
        fi
    else
        load_defaults=true
    fi
    
    # Phase 3: Default hierarchy
    if [[ "$load_defaults" == "true" ]]; then
        echo "3. Load defaults:"
        echo "   ~/.claude/npl-m/house-style/${style_type,,}-style.md"
        echo "   .claude/npl-m/house-style/${style_type,,}-style.md"
        echo "   [path hierarchy to $target_path]"
    fi
}

# Usage
simulate_style_loading "TECHNICAL" "/project/docs/api"
```

## Error Handling

### Missing Files
```bash
# Environment points to non-existent file
export HOUSE_STYLE_TECHNICAL="/missing/file.md"

# Agent behavior:
# - Log warning about missing file
# - Continue with default style loading
# - Don't fail agent execution
```

### Invalid Paths
```bash
# Malformed paths are ignored
export HOUSE_STYLE_TECHNICAL="invalid:::path"

# Agent behavior:
# - Skip invalid environment variable
# - Continue with default loading
# - Log warning about invalid path
```

### Permission Issues
```bash
# File exists but not readable
export HOUSE_STYLE_TECHNICAL="/root/private-style.md"

# Agent behavior:
# - Skip inaccessible file
# - Log permission warning
# - Continue with default loading
```

This environment variable system provides powerful and flexible style management while maintaining predictable fallback behavior for NPL writer agents.