## NPL Load Directive

When encountering the command `npl_load(item)`, in prompts/agent definitions load the specified item into context if not already loaded.
npl_load() with no arguments indicates to load $NPL_HOME/npl.md if not already in context.

in addition to `npl_load(item)` there is `npl_meta_load(item)` which loads data under .npl/meta and should search first for project dir then $NPL_HOME/meta if no project level file found.
npl_meta_load(persona.steve-k-ux-guru) -> (./.npl/meta/persona.md || $NPL_HOME/meta/persona.md) , then  ./.npl/meta/persona/steve-k-ux-guru.md or $NPL_HOME/meta/persona/steve-k-ux-guru.md 


### Loading Rules

1. **Parse Item Path**: 
   - Simple item: `npl_load(pumps)` → load `$NPL_HOME/npl/pumps.md`
   - Nested item: `npl_load(pumps.cot)` → load `$NPL_HOME/npl/pumps.md` (if not loaded) + `$NPL_HOME/npl/pumps/cot.md`
2. **Skip if Loaded**: Do not reload items already in context

### Path Resolution

- Base path: `${NPL_HOME}/npl/`
- Dot notation creates subdirectories: `item.subitem` → `item/subitem.md`
- Parent items are loaded before children

### Examples

```
npl_load(agents)           → $NPL_HOME/npl/agents.md
npl_load(agents.reasoning) → $NPL_HOME/npl/agents.md + $NPL_HOME/npl/agents/reasoning.md
npl_load(tools.git.status) → $NPL_HOME/npl/tools.md + $NPL_HOME/npl/tools/git.md + $NPL_HOME/npl/tools/git/status.md
```
