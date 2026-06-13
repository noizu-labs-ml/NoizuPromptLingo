# Task-Flow Theory

Background on the analytical methods behind site-walkthrough's approach.

## Goal-Directed Task Analysis (GDTA)

Originally from Endsley (1993) for complex systems analysis. Core idea: decompose high-level goals into subgoals, then into specific decisions and information requirements.

### Why It Works for Websites

Websites are task environments. Users arrive with goals ("buy shoes," "find a doctor," "pay a bill"). GDTA maps those goals to the site's affordances — what the site actually lets you do — and reveals gaps.

### Key Concepts

| Concept | Definition | In This Skill |
|---------|-----------|---------------|
| **Goal** | What the user wants to accomplish | `goals/*.yaml` → `goal:` field |
| **Subgoal** | A necessary intermediate achievement | Flow steps that aren't terminal |
| **Decision** | A point where the user chooses between paths | `on_success` / `on_failure` branching |
| **Information requirement** | What the user needs to know to decide | `note:` fields on flow steps |
| **Affordance** | What the interface offers | `affordances:` in page YAMLs |

## Cognitive Walkthrough

Method from Wharton et al. (1994). A structured evaluation where you step through a task as a user would, asking at each step:

1. **Will the user try to achieve the right effect?** (Do they know what to do?)
2. **Will the user notice the correct action is available?** (Is the element visible?)
3. **Will the user associate the correct action with the effect?** (Does the label make sense?)
4. **Will the user see progress toward the goal?** (Is there feedback?)

### Mapping to This Skill

- Questions 1-2 map to **page inventory**: are the elements there and discoverable?
- Question 3 maps to **element descriptions** and **affordances**: does the labeling match intent?
- Question 4 maps to **flow transitions**: does `leads_to` make sense after each action?

## Directed Graph Fundamentals

A task flow is a directed graph where:
- **Nodes** = actions the user takes
- **Edges** = transitions between actions
- **Decision nodes** = branch points with multiple outgoing edges
- **Terminal nodes** = end states (success or failure)

### Properties of Well-Formed Task Flows

1. **Reachability**: Every node is reachable from the start node
2. **Termination**: Every path eventually reaches a terminal node (no infinite loops without explicit loop constructs)
3. **Failure coverage**: Every decision node has at least one failure edge
4. **Determinism**: From any node, the conditions for choosing each edge are unambiguous

### Loop Constructs

Some tasks have legitimate loops ("keep walking north until you find trees"). Model these as:

```yaml
- id: walk-north
  action: navigate
  target: north
  repeat_until: "trees visible"
  on_success: found-trees
  on_failure: walk-north  # self-edge = loop
  max_iterations: 10
  on_max: give-up
```

The `max_iterations` + `on_max` pattern prevents infinite loops in the model.

## Task Complexity Classification

| Complexity | Characteristics | Example |
|-----------|----------------|---------|
| **Linear** | No branching, single path | "Read the about page" |
| **Branching** | 1-2 decision points | "Search or browse for item" |
| **Complex** | 3+ decision points, auth gates, loops | "Purchase with promo code, handle OOS" |
| **Multi-session** | Spans multiple visits or requires external action | "Apply for loan, wait for approval, sign docs" |

This skill handles Linear through Complex natively. Multi-session flows require explicit session boundaries in the goal YAML.

## Sources

- Endsley, M.R. (1993). "A Survey of Situation Awareness Requirements in Air-to-Air Combat Fighters." *Int'l J. Aviation Psychology.*
- Wharton, C. et al. (1994). "The Cognitive Walkthrough Method: A Practitioner's Guide." In *Usability Inspection Methods.*
- Card, S.K., Moran, T.P., & Newell, A. (1983). *The Psychology of Human-Computer Interaction.* (GOMS framework)
- Nielsen, J. (1994). "Heuristic Evaluation." In *Usability Inspection Methods.*
