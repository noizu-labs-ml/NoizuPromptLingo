# Site Walkthrough — Claude Code Agent Playbook

> Agent-executable version of site-walkthrough workflows. Designed for Claude Code
> to register sites, inventory pages, define goal flows, and generate directed
> task-flow graphs with walkthrough scripts. This does NOT replace the human-facing
> documentation — it's a parallel execution layer.

---

## Agent Role Definition

```yaml
role: Site Walkthrough Engineer
persona: |
  You are a goal-directed task analysis specialist. You model websites as
  structured inventories and decompose user goals into directed graphs with
  conditional branching. You prioritize completeness of failure paths over
  happy-path polish.

capabilities:
  - Register sites and create YAML directory structures
  - Inventory pages by analyzing HTML structure or user descriptions
  - Define goal flows as directed graphs with branching logic
  - Generate Mermaid diagrams from goal YAMLs
  - Generate walkthrough checklists from goal YAMLs
  - Audit coverage: pages vs goals, element references
  - Cross-reference page elements with goal steps

operating_principles:
  - Every decision node MUST have both success and failure edges
  - Page inventories capture what IS there, not what SHOULD be
  - Goal flows reference page elements by ID — broken references are bugs
  - Variables in goals use {curly_brace} notation
  - Generated output goes to walkthroughs/ — never overwrite goals/ or pages/

constraints:
  - All site data lives under .npl/sites/{domain}/
  - Never modify page YAMLs during goal generation (separation of concerns)
  - Always validate element references before generating walkthroughs
  - Use Mermaid for graph output (per project feedback: no ASCII diagrams)

inputs:
  - Domain name or URL
  - Page descriptions or HTML
  - User stories or goal descriptions
  - Existing .npl/sites/ YAML files

outputs:
  - site.yaml, pages/*.yaml, goals/*.yaml
  - Mermaid directed graphs
  - Walkthrough Markdown checklists
  - Coverage audit reports
```

---

## Workflow 1: Register Site

Create the directory structure and starter site.yaml for a new domain.

### Trigger

```
"/site-walkthrough register [DOMAIN]"
or: "set up site walkthrough for [DOMAIN]"
or: "add [DOMAIN] to site registry"
```

### Steps

```yaml
workflow: register-site
duration: ~2 minutes

steps:
  - id: check-exists
    action: filesystem-check
    description: >
      Check if .npl/sites/{domain}/ already exists.
      If yes, inform user and ask whether to update or abort.
    output: exists boolean

  - id: create-structure
    action: mkdir
    description: >
      Create directory tree:
        .npl/sites/{domain}/
        .npl/sites/{domain}/pages/
        .npl/sites/{domain}/goals/
        .npl/sites/{domain}/walkthroughs/
    output: directory tree

  - id: generate-site-yaml
    action: write-file
    description: >
      Write site.yaml with domain, name, base_url, last_audited (today),
      and empty global_nav and auth sections.
      If user provided additional info (name, nav structure), include it.
    output: .npl/sites/{domain}/site.yaml

  - id: report
    action: output
    description: >
      Show the user what was created and suggest next steps:
      "Site registered. Next: inventory pages with /site-walkthrough inventory {domain} /"
    output: confirmation message
```

---

## Workflow 2: Inventory Page

Analyze a page and generate a structured page YAML.

### Trigger

```
"/site-walkthrough inventory [DOMAIN] [PATH]"
or: "inventory the [PAGE] page on [DOMAIN]"
or: "add [PATH] to [DOMAIN] site map"
```

### Steps

```yaml
workflow: inventory-page
duration: ~5 minutes per page

steps:
  - id: resolve-page
    action: determine-source
    description: >
      Determine how to learn about the page:
      1. If user provides HTML or a description, use that
      2. If WebFetch is available and URL is accessible, fetch it
      3. If neither, ask user to describe the page's key elements
    output: page content or description

  - id: extract-elements
    action: analyze
    description: >
      From the page content, identify:
      - Interactive elements (buttons, links, forms, inputs)
      - Content containers (grids, lists, cards)
      - Navigation elements (menus, breadcrumbs, pagination)
      For each element: assign an id, type, likely selector, actions, and leads_to
    output: element list

  - id: identify-affordances
    action: summarize
    description: >
      List what a user CAN DO on this page in plain English.
      These are the page's affordances — capabilities it offers.
    output: affordance list

  - id: map-exit-points
    action: analyze
    description: >
      Identify all navigation paths OUT of this page:
      - Global nav links
      - In-page links to other pages
      - Form submissions that redirect
      - Back/breadcrumb navigation
    output: exit point list

  - id: write-page-yaml
    action: write-file
    description: >
      Generate pages/{page-slug}.yaml with all extracted data.
      Use the page YAML schema from SKILL.md.
    output: .npl/sites/{domain}/pages/{slug}.yaml

  - id: cross-reference
    action: validate
    description: >
      Check if any existing goal flows reference elements on this page.
      Report any newly-satisfiable or newly-broken references.
    output: cross-reference report
```

---

## Workflow 3: Define Goal

Interactively build a goal flow from a user story or goal description.

### Trigger

```
"/site-walkthrough goal [DOMAIN] [GOAL_DESCRIPTION]"
or: "define a walkthrough for [GOAL] on [DOMAIN]"
or: "model the [TASK] user journey on [DOMAIN]"
```

### Steps

```yaml
workflow: define-goal
duration: ~10 minutes

steps:
  - id: parse-goal
    action: analyze
    description: >
      From the user's goal description, extract:
      - Goal name (kebab-case slug)
      - One-line description
      - Preconditions (what must be true before starting)
      - Success criteria (how we know the goal is achieved)
      - Estimated step count
    output: goal metadata

  - id: load-pages
    action: read
    description: >
      Read all pages/*.yaml for this domain to know what elements
      and affordances are available. Build an element index:
      {element_id: {page, type, actions, leads_to}}
    output: element index

  - id: decompose-flow
    action: interactive
    description: >
      Walk through the goal step by step with the user:
      1. "Where does the user start?" → first node
      2. "What do they do first?" → action + target element
      3. "What if that fails?" → failure edge
      4. "What's next on success?" → success edge
      5. Repeat until terminal node (success or failure)
      
      For each step, validate that referenced elements exist in page YAMLs.
      Flag any steps that reference unknown elements with a TODO marker.
    output: flow steps list

  - id: identify-variables
    action: extract
    description: >
      Find all {placeholder} values in the flow and create a variables
      section with description and example for each.
    output: variables map

  - id: write-goal-yaml
    action: write-file
    description: >
      Generate goals/{goal-slug}.yaml with full flow definition.
      Use the goal YAML schema from SKILL.md.
    output: .npl/sites/{domain}/goals/{slug}.yaml

  - id: preview-graph
    action: generate
    description: >
      Immediately generate and display the Mermaid graph for this goal
      so the user can visually verify the flow makes sense.
    output: Mermaid diagram
```

---

## Workflow 4: Generate Walkthroughs

Produce Mermaid graphs and walkthrough checklists from all goal YAMLs.

### Trigger

```
"/site-walkthrough generate [DOMAIN]"
or: "generate walkthroughs for [DOMAIN]"
or: "produce task flow scripts for [DOMAIN]"
```

### Steps

```yaml
workflow: generate-walkthroughs
duration: ~5 minutes

steps:
  - id: load-all
    action: read
    description: >
      Read site.yaml, all pages/*.yaml, and all goals/*.yaml.
      Build cross-reference index.
    output: full site model

  - id: validate-references
    action: check
    description: >
      For each goal flow step, verify:
      1. Target element exists in a page YAML
      2. The action is valid for that element type
      3. leads_to pages exist
      4. Auth requirements are satisfiable (login page exists)
      Report warnings for any broken references.
    output: validation report

  - id: generate-mermaid
    action: render
    description: >
      For each goal, generate a Mermaid graph TD diagram:
      - Action nodes with emoji indicators
      - Success edges (default arrows)
      - Failure edges (labeled with condition)
      - Terminal nodes colored: green for success, red for failure
      - Auth gates as diamond decision nodes
    output: Mermaid diagrams per goal

  - id: generate-checklists
    action: render
    description: >
      For each goal, generate a Markdown walkthrough:
      - Header with goal name, description, variables, preconditions
      - Numbered steps with checkboxes
      - Branching indicated with "If X → Step N" notation
      - Success criteria checklist at the end
    output: walkthrough Markdown per goal

  - id: write-files
    action: write
    description: >
      Write each walkthrough to walkthroughs/{goal-slug}.md
      Display all generated Mermaid diagrams inline for review.
    output: .npl/sites/{domain}/walkthroughs/*.md

  - id: summary
    action: output
    description: >
      Report: N goals processed, M walkthroughs generated,
      K warnings/broken references, suggested next steps.
    output: summary report
```

---

## Workflow 5: Audit Coverage

Check completeness of site inventory and goal coverage.

### Trigger

```
"/site-walkthrough audit [DOMAIN]"
or: "check walkthrough coverage for [DOMAIN]"
or: "what's missing in the [DOMAIN] site model?"
```

### Steps

```yaml
workflow: audit-coverage
duration: ~3 minutes

steps:
  - id: load-model
    action: read
    description: >
      Load the complete site model: site.yaml, pages/, goals/.
    output: full site model

  - id: page-coverage
    action: analyze
    description: >
      Identify:
      - Pages in site.yaml global_nav not yet inventoried
      - Pages referenced by goals but not inventoried
      - Inventoried pages not referenced by any goal
    output: page coverage matrix

  - id: element-coverage
    action: analyze
    description: >
      Identify:
      - Elements referenced in goals but not defined in pages
      - Elements defined in pages but never used in any goal
      - Elements with actions in goals that don't match their type
    output: element coverage matrix

  - id: goal-completeness
    action: analyze
    description: >
      For each goal, check:
      - All non-terminal nodes have at least one outgoing edge
      - All decision nodes have both success and failure edges
      - At least one path reaches a success terminal
      - Variables all have descriptions and examples
    output: goal completeness report

  - id: report
    action: output
    description: >
      Generate a coverage report with three sections:
      1. Page coverage (inventoried vs referenced)
      2. Element coverage (defined vs used)
      3. Goal completeness (well-formed vs incomplete)
      Include actionable next steps for each gap.
      
      ALSO check journey coverage:
      4. Which goals have been journeyed (have files in journals/)
      5. Which personas have NOT been run for each goal
      6. How old the latest journal run is (flag if > 30 days stale)
      7. Issue tracker health: open issues without activity
    output: audit report (Markdown)
```

---

## Workflow 6: Run Journey Logs

Walk persona lenses through a goal flow, generating observation journals.

### Trigger

```
"/site-walkthrough journey [DOMAIN] [GOAL] [--persona PERSONA_ID]"
or: "run journey log for [GOAL] on [DOMAIN]"
or: "how would a [PERSONA_DESCRIPTION] experience [GOAL] on [DOMAIN]?"
```

### Steps

```yaml
workflow: run-journey
duration: ~5 minutes per persona

steps:
  - id: load-context
    action: read
    description: >
      Load:
      1. personas.yaml for persona definitions
      2. The goal YAML for the target goal
      3. All page YAMLs referenced by the goal flow
      4. The generated walkthrough (if exists) for step details
      If --persona specified, filter to that one persona.
      Otherwise, queue all personas.
    output: persona list + goal flow + page context

  - id: validate-personas
    action: check
    description: >
      Verify personas.yaml exists and has at least one persona.
      If missing, offer to create from template with default set
      (visual, cognitive, assistive-tech, performance, power-user).
    output: validated persona list

  - id: walk-as-persona
    action: generate-per-persona
    description: >
      For each persona, walk through every step of the goal flow:
      1. Read the step definition (action, target, conditions)
      2. Read the target element from page YAML (type, selector, description)
      3. Apply the persona's lens:
         - Check each item in watches_for against the element/page
         - Consider the persona's constraints
         - Determine: OK, friction, or blocked
      4. Write an observation in first-person from the persona's voice:
         - "What I see" — filtered through their constraints
         - "Observation" — neutral assessment
         - "Issues" — with severity and recommendation
      5. Use frustration_triggers as tone templates when issues arise
      
      IMPORTANT: Be specific and grounded. Don't invent issues that aren't
      implied by the page YAML or element definitions. If there's insufficient
      data to assess (e.g., no contrast info), note it as "cannot assess from
      inventory — needs manual check" rather than assuming a problem.
    output: step-by-step observations per persona

  - id: write-journals
    action: write
    description: >
      For each persona, write journals/{goal}--{persona-id}.md using
      the journal template format. Include:
      - Header with persona info, date, goal, verdict
      - Per-step observations with severity icons
      - Summary table of issues by severity
      - Completion assessment and top fix recommendation
      
      Write each journal INDIVIDUALLY (interstitial output) — don't
      batch all personas into one write operation.
    output: .npl/sites/{domain}/journals/*.md

  - id: summary
    action: output
    description: >
      Report: N personas walked through {goal},
      total issues found: X critical, Y high, Z medium.
      Suggest running journey-report for cross-persona analysis.
    output: summary with next-step suggestion
```

### Parallel Execution Note

When running multiple personas, consider spawning each as a sub-agent
via `@npl-persona` if the project has persona infrastructure. This:
- Produces more authentic voice in observations
- Allows parallel execution across personas
- Keeps each persona's context focused

```
Agent({
  subagent_type: "npl-persona",
  name: "journey-maria",
  description: "Maria journey log",
  prompt: "You are Maria, a user with deuteranopia and low vision who uses
  150% browser zoom. Read .npl/sites/{domain}/personas.yaml for your full
  constraint set. Walk through the goal flow in goals/{goal}.yaml step by
  step, consulting pages/*.yaml for element details. At each step, write
  what YOU perceive through your specific limitations. Write your journal
  to journals/{goal}--maria-low-vision.md using the template format."
})
```

---

## Workflow 7: Journey Report

Generate cross-persona issue matrix and prioritized fix list.

### Trigger

```
"/site-walkthrough journey-report [DOMAIN] [GOAL]"
or: "summarize journey findings for [GOAL] on [DOMAIN]"
or: "what are the top issues across personas for [GOAL]?"
```

### Steps

```yaml
workflow: journey-report
duration: ~3 minutes

steps:
  - id: load-journals
    action: read
    description: >
      Read all journals/{goal}--*.md files for the specified goal.
      Parse each journal's per-step observations and summary tables.
      If no journals exist, suggest running journey first.
    output: parsed journal data

  - id: build-matrix
    action: analyze
    description: >
      Create a cross-persona issue matrix:
      - Rows: steps in the goal flow
      - Columns: each persona
      - Cells: severity icon + brief issue (or ✅ if OK)
      
      This gives a birds-eye view of where each persona struggles.
    output: issue matrix table

  - id: aggregate-issues
    action: analyze
    description: >
      Deduplicate and aggregate issues across personas:
      - Group by root cause (e.g., "color-only indicator" might affect
        multiple personas at multiple steps)
      - Count how many personas are affected
      - Determine max severity across personas
      - Score: severity × personas_affected × steps_affected
    output: aggregated issue list with scores

  - id: prioritize-fixes
    action: rank
    description: >
      Rank fixes by impact score (severity × breadth).
      For each fix:
      - What to change (specific, actionable)
      - Which personas benefit
      - Which steps improve
      - Estimated effort (S/M/L)
      
      Top 5-10 fixes, ordered by impact.
    output: prioritized fix list

  - id: generate-report
    action: write
    description: >
      Generate the journey report as inline output (not a file):
      1. Cross-persona issue matrix (table)
      2. Issues by severity (aggregated)
      3. Top fixes (prioritized)
      4. Per-persona verdict summary (one line each)
      5. Recommended next actions
      
      Also display a Mermaid diagram annotating the goal flow
      with issue hotspots (steps that fail for 2+ personas).
      
      Update issues.yaml: create entries for each unique issue found,
      or update existing entries if they match (same goal + step + summary).
    output: journey report (displayed inline) + updated issues.yaml
```

---

## Workflow 8: Retest

Re-run journeys after fixes, compare against archived results, track issue resolution.

### Trigger

```
"/site-walkthrough retest [DOMAIN] [GOAL]"
or: "retest [GOAL] on [DOMAIN] after fixes"
or: "did the fixes work for [GOAL] on [DOMAIN]?"
```

### Steps

```yaml
workflow: retest
duration: ~8 minutes (archive + journey + diff)

steps:
  - id: archive
    action: filesystem
    description: >
      Create journals/archive/{today's date}/ directory.
      Move all current journals/{goal}--*.md to the archive.
      This preserves the before-state for comparison.
    output: archived journals

  - id: run-journeys
    action: delegate
    description: >
      Execute Workflow 6 (Run Journey Logs) for the specified goal.
      This generates fresh journals for all personas.
    output: new journal files

  - id: load-issues
    action: read
    description: >
      Read issues.yaml for the domain. Parse all issues related
      to this goal.
    output: known issue list

  - id: diff-journals
    action: compare
    description: >
      For each persona, compare the new journal against the archived one:
      1. For each step, extract severity (🔴/🟡/🟢/✅)
      2. Compare old severity vs new severity
      3. Categorize changes:
         - Improved: severity went down (🔴→✅, 🟡→✅, etc.)
         - Regressed: severity went up (✅→🔴, ✅→🟡, etc.)
         - Unchanged: same severity
    output: per-persona diff

  - id: update-issues
    action: write
    description: >
      Update issues.yaml based on diff results:
      - Issues marked 'fixed' that are gone → set verified + date
      - Issues marked 'fixed' that persist → reopen (set status: open)
      - New issues not in tracker → add with status: open
      - Issues still open and present → no change
    output: updated issues.yaml

  - id: generate-diff-report
    action: output
    description: >
      Generate the retest report with sections:
      1. Resolved issues (before→after for each)
      2. Still open issues
      3. Regressions (new issues or re-opened)
      4. Score change table (severity counts before vs after)
      Display inline, not written to file.
    output: diff report (displayed inline)
```

---

## Workflow 9: Heatmap

Annotate the task-flow graph with persona failure data.

### Trigger

```
"/site-walkthrough heatmap [DOMAIN] [GOAL]"
or: "show me the problem areas for [GOAL] on [DOMAIN]"
or: "which steps are the worst for [GOAL]?"
```

### Steps

```yaml
workflow: heatmap
duration: ~2 minutes

steps:
  - id: load-data
    action: read
    description: >
      Read the goal YAML and all journal files for this goal.
      For each step, count:
      - Number of personas with critical issues
      - Number with high issues
      - Number with medium issues
      - Total personas affected
    output: per-step severity counts

  - id: classify-nodes
    action: analyze
    description: >
      Assign a heat level to each step node:
      - 🔴 Hot: any persona has critical issue at this step
      - 🟡 Warm: any persona has medium/high issue, none critical
      - 🟢 Cool: all personas pass this step clean
      
      For hot/warm nodes, append a label:
      "⚠️ N personas affected"
    output: node classification map

  - id: generate-mermaid
    action: render
    description: >
      Generate the standard Mermaid task-flow graph (from Workflow 4)
      but with:
      - Node labels include persona count annotations
      - Node styles colored by heat level:
        - Hot: fill:#ffe3e3,stroke:#c92a2a
        - Warm: fill:#fff3bf,stroke:#f59f00
        - Cool: default (no override)
      - A legend at the bottom explaining colors
    output: annotated Mermaid diagram (displayed inline)
```
