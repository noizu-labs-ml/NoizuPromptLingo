## NPL Scripts
The following scripts are available.

dump-files <path>
: - Dumps all file contents recursively with file name header
- Respects `.gitignore`
- Supports glob pattern filter: `./dump-files . -g "*.md"`

git-tree-depth <path>
: - Show directory tree with nesting levels

git-tree <path>
: - Display directory tree
- Uses `tree` command, defaults to current directory

npl-fim-config [item] [options]
: Configuration and query tool for NPL-FIM agent - finds best visualization solutions via natural language queries

npl-load <command> [items...] [options]
: Loads NPL components, metadata, and style guides with dependency tracking and patch support

### npl-fim-config

A command-line tool for querying, editing, and managing NPL-FIM (Noizu Prompt Lingua Fill-In-the-Middle) configuration, solution metadata, and local overrides. Supports natural language queries, compatibility matrix display, artifact path resolution, and delegation to `npl-load` for metadata loading.


### npl-load

A resource loader for NPL components, metadata, and style guides with dependency tracking. Supports hierarchical search (project, user, system), patch overlays, and skip flags to prevent redundant loading. Used for loading definitions, metadata, and style guides as required by NPL agents and scripts.

