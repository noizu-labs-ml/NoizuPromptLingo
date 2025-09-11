# NPL House Style Framework - Path Hierarchy Resolution

Detailed specification for the path hierarchy resolution system that enables progressive style override from project root to target directory.

## Overview

Path hierarchy resolution enables style files to be placed at any directory level, with deeper directory styles overriding shallower ones. This allows teams to set global styles at the project level and override them for specific areas like documentation, marketing materials, or client-specific content.

## Resolution Algorithm

### Core Algorithm
```alg
function path_hierarchy_from_project_to_target(project_root, target_path):
  """
  Generate ordered list of directories from project root to target directory.
  Each directory is a potential location for house-style/ subdirectories.
  """
  paths = []
  
  # Always start with project root
  paths.append(project_root)
  
  # Handle case where target is project root
  if target_path == project_root:
    return paths
  
  # Get relative path from project root to target
  try:
    relative_path = target_path.relative_to(project_root)
  except ValueError:
    # target_path is not under project_root
    return paths
  
  # Build hierarchy by walking down the path
  current = project_root
  for part in relative_path.parts:
    current = current / part
    if current.is_dir():
      paths.append(current)
    elif current == target_path:
      # Target is a file, use its parent directory
      paths.append(current.parent)
      break
  
  return paths
```

### Path Examples

#### Basic Directory Hierarchy
```
Project Structure:
/project/
├── docs/
│   ├── api/
│   │   ├── v1/
│   │   │   └── users.md
│   │   └── v2/
│   └── guides/
│       └── setup.md
└── marketing/
    └── campaigns/
        └── 2024-q1/
            └── landing-page.md

Target: /project/docs/api/v1/users.md
Hierarchy:
1. /project
2. /project/docs  
3. /project/docs/api
4. /project/docs/api/v1

Target: /project/marketing/campaigns/2024-q1/landing-page.md
Hierarchy:
1. /project
2. /project/marketing
3. /project/marketing/campaigns
4. /project/marketing/campaigns/2024-q1
```

#### Edge Cases
```
Target: /project (project root)
Hierarchy:
1. /project

Target: /project/file.md (file in root)
Hierarchy:  
1. /project

Target: /outside/project (not under project root)
Hierarchy:
1. /project (only project root returned)
```

## Style File Discovery

### Search Pattern
For each directory in the hierarchy, the framework searches for:
```
{directory}/house-style/{style-type}-style.md
```

### Discovery Examples
```
Hierarchy for /project/docs/api/v1/:
1. /project
2. /project/docs
3. /project/docs/api  
4. /project/docs/api/v1

Style File Search (technical-style):
1. /project/house-style/technical-style.md
2. /project/docs/house-style/technical-style.md
3. /project/docs/api/house-style/technical-style.md
4. /project/docs/api/v1/house-style/technical-style.md

Loading Order (if all exist):
1. /project/house-style/technical-style.md          (base)
2. /project/docs/house-style/technical-style.md     (docs override)
3. /project/docs/api/house-style/technical-style.md (api override)
4. /project/docs/api/v1/house-style/technical-style.md (version override)
```

## Integration with Writer Agents

### Template Integration
```markdown
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/{style-type}-style.md")}}
load {{path}}/house-style/{style-type}-style.md into context.
{{/if}}
{{/for}}
```

### Actual Agent Implementation
```markdown
# Technical Writer Agent
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/technical-style.md")}}
load {{path}}/house-style/technical-style.md into context.
{{/if}}
{{/for}}

# Marketing Writer Agent  
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/marketing-style.md")}}
load {{path}}/house-style/marketing-style.md into context.
{{/if}}
{{/for}}
```

## Directory Structure Patterns

### Standard Project Layout
```
project/
├── .claude/npl-m/house-style/          # Global project styles
│   ├── technical-style.md
│   ├── marketing-style.md
│   └── business-style.md
├── docs/house-style/                   # Documentation-specific styles
│   ├── technical-style.md              # Technical docs style override
│   └── api-style.md                    # API-specific extensions
├── marketing/house-style/              # Marketing team styles
│   ├── marketing-style.md              # Marketing override
│   └── campaign-style.md               # Campaign-specific rules
└── content/
    ├── blog/house-style/              # Blog-specific styles
    │   └── creative-style.md
    └── legal/house-style/             # Legal content styles
        └── legal-style.md
```

### Multi-Client Project Layout
```
project/
├── .claude/npl-m/house-style/          # Base company styles
│   ├── technical-style.md
│   └── marketing-style.md
├── clients/
│   ├── acme-corp/house-style/         # ACME-specific styles
│   │   ├── technical-style.md          # ACME technical overrides
│   │   └── marketing-style.md          # ACME brand voice
│   └── beta-inc/house-style/          # Beta Inc styles
│       ├── technical-style.md
│       └── legal-style.md
└── shared/
    └── docs/house-style/              # Shared documentation styles
        └── technical-style.md
```

### Component-Based Layout
```
project/
├── .claude/npl-m/house-style/          # Global styles
│   └── technical-style.md
├── components/
│   ├── auth/house-style/              # Authentication component styles
│   │   └── technical-style.md
│   ├── api/house-style/               # API component styles
│   │   ├── technical-style.md
│   │   └── api-reference-style.md
│   └── ui/house-style/                # UI component styles
│       ├── technical-style.md
│       └── design-system-style.md
└── features/
    ├── payments/house-style/          # Payment feature styles
    │   ├── technical-style.md
    │   └── security-style.md
    └── reporting/house-style/         # Reporting feature styles
        └── technical-style.md
```

## Common Use Cases

### Documentation Hierarchy
```
Scenario: API documentation with different styles for different versions

Structure:
/project/docs/api/
├── house-style/
│   └── technical-style.md             # Common API documentation style
├── v1/house-style/
│   └── technical-style.md             # v1-specific overrides
└── v2/house-style/
    └── technical-style.md             # v2-specific overrides

Working on: /project/docs/api/v2/endpoints.md
Style loading order:
1. ~/.claude/npl-m/house-style/technical-style.md
2. .claude/npl-m/house-style/technical-style.md
3. /project/house-style/technical-style.md
4. /project/docs/house-style/technical-style.md
5. /project/docs/api/house-style/technical-style.md
6. /project/docs/api/v2/house-style/technical-style.md
```

### Marketing Campaign Overrides
```
Scenario: Campaign-specific marketing styles that override brand defaults

Structure:
/project/marketing/
├── house-style/
│   └── marketing-style.md             # Brand voice guidelines
└── campaigns/
    ├── 2024-q1/house-style/
    │   └── marketing-style.md         # Q1 campaign voice
    └── black-friday/house-style/
        └── marketing-style.md         # Black Friday specific tone

Working on: /project/marketing/campaigns/black-friday/landing-page.md
Style loading order:
1. ~/.claude/npl-m/house-style/marketing-style.md
2. .claude/npl-m/house-style/marketing-style.md
3. /project/house-style/marketing-style.md
4. /project/marketing/house-style/marketing-style.md
5. /project/marketing/campaigns/house-style/marketing-style.md
6. /project/marketing/campaigns/black-friday/house-style/marketing-style.md
```

### Client-Specific Overrides
```
Scenario: Multi-client services with client-specific documentation styles

Structure:
/project/
├── .claude/npl-m/house-style/
│   └── technical-style.md             # Company standard technical style
└── clients/
    ├── enterprise-a/
    │   ├── house-style/
    │   │   └── technical-style.md     # Enterprise A's style requirements
    │   └── integration-docs/
    │       └── api-guide.md
    └── startup-b/
        ├── house-style/
        │   └── technical-style.md     # Startup B's informal style
        └── docs/
            └── quick-start.md

Working on: /project/clients/enterprise-a/integration-docs/api-guide.md
Style loading order:
1. ~/.claude/npl-m/house-style/technical-style.md
2. .claude/npl-m/house-style/technical-style.md
3. /project/house-style/technical-style.md
4. /project/clients/house-style/technical-style.md
5. /project/clients/enterprise-a/house-style/technical-style.md
6. /project/clients/enterprise-a/integration-docs/house-style/technical-style.md
```

## Performance Optimization

### Directory Traversal Limits
```alg
function path_hierarchy_with_limits(project_root, target_path, max_depth=10):
  """Limit hierarchy depth to prevent excessive directory traversal"""
  paths = path_hierarchy_from_project_to_target(project_root, target_path)
  return paths[:max_depth]
```

### Caching Strategy
```alg
function cached_style_discovery(directory, style_type):
  """Cache style file existence checks"""
  cache_key = f"{directory}#{style_type}"
  
  if cache_key in style_file_cache:
    return style_file_cache[cache_key]
  
  style_path = directory / "house-style" / f"{style_type}-style.md"
  exists = style_path.exists() and style_path.is_file()
  
  style_file_cache[cache_key] = exists
  return exists
```

### Efficient File System Access
```alg
function batch_file_exists_check(paths, style_type):
  """Check multiple paths efficiently using stat calls"""
  existing_files = []
  
  for path in paths:
    style_file = path / "house-style" / f"{style_type}-style.md"
    try:
      if style_file.stat():
        existing_files.append(style_file)
    except OSError:
      continue  # File doesn't exist or access denied
  
  return existing_files
```

## Error Handling

### Invalid Project Root
```alg
function safe_path_hierarchy(project_root, target_path):
  """Handle cases where project_root doesn't exist or isn't accessible"""
  try:
    if not project_root.exists() or not project_root.is_dir():
      return [Path.cwd()]  # Fallback to current directory
    
    return path_hierarchy_from_project_to_target(project_root, target_path)
  except (PermissionError, OSError):
    return [Path.cwd()]
```

### Symlink Handling
```alg
function resolve_symlinks(path):
  """Resolve symlinks to prevent infinite loops"""
  try:
    return path.resolve()
  except (RuntimeError, OSError):
    return path  # Keep original if resolution fails
```

### Access Permission Issues
```alg
function accessible_directories_only(paths):
  """Filter out directories without read permission"""
  accessible = []
  
  for path in paths:
    try:
      if path.exists() and os.access(path, os.R_OK):
        accessible.append(path)
    except OSError:
      continue  # Skip inaccessible directories
  
  return accessible
```

## Testing and Validation

### Path Hierarchy Testing
```python
def test_path_hierarchy():
    """Test path hierarchy generation"""
    project = Path("/project")
    target = Path("/project/docs/api/v1/users.md")
    
    expected = [
        Path("/project"),
        Path("/project/docs"),
        Path("/project/docs/api"),
        Path("/project/docs/api/v1")
    ]
    
    result = path_hierarchy_from_project_to_target(project, target)
    assert result == expected
```

### Style Discovery Testing
```python
def test_style_discovery():
    """Test style file discovery across hierarchy"""
    hierarchy = [
        Path("/project"),
        Path("/project/docs"),
        Path("/project/docs/api")
    ]
    
    # Mock file system
    existing_files = {
        "/project/house-style/technical-style.md",
        "/project/docs/api/house-style/technical-style.md"
    }
    
    discovered = discover_style_files(hierarchy, "technical", existing_files)
    expected = [
        Path("/project/house-style/technical-style.md"),
        Path("/project/docs/api/house-style/technical-style.md")
    ]
    
    assert discovered == expected
```

This path hierarchy resolution system provides the sophisticated directory-based style loading required by NPL writer agents while maintaining performance and reliability.