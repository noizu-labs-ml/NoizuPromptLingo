# Declarations
<!-- labels: [block, framework, version-control] -->

Framework version boundaries and rule establishment for NPL (Noizu Prompt Lingua).

## NPL Declaration

```syntax
⌜NPL@version⌝
[___]
⌞NPL@version⌟
```

<!-- instructional: conceptual-explanation | level: 0 | labels: [framework, definition] -->
### Purpose

Establishes framework version boundaries, operational context, and core rules for NPL prompt engineering. Declaration blocks create immutable boundaries that define version-specific behaviors, compatibility requirements, and framework constraints.

<!-- instructional: usage-guideline | level: 0 | labels: [framework, guidance] -->
### Usage

Use declarations to:
- Establish framework version and rule boundaries
- Define compatibility requirements between versions
- Create operational contexts for agents and prompts
- Set framework-level constraints and capabilities

### Examples

#### Basic Framework Declaration
<!-- level: 0 -->
```example
⌜NPL@1.0⌝
# Core NPL Framework Rules
[___|Framework-specific rules and guidelines.]

⌞NPL@1.0⌟
```

#### Framework Extension Declaration
<!-- level: 1 -->
```example
⌜extend:NPL@1.0⌝
# Extension to Core Framework
[___|Additional rules enhancing NPL@1.0 capabilities.]

⌞extend:NPL@1.0⌟
```

#### Agent Declaration
<!-- level: 0 -->
```example
⌜agent-name|type|NPL@1.0⌝
# Agent Name
Description of agent and primary function.

[___|behavioral specifications]

⌞agent-name⌟
```

#### Agent Extension
<!-- level: 1 -->
```example
⌜extend:sports-news-agent|service|NPL@1.0⌝
Enhances the agent's capability to provide historical sports facts in addition to recent news.

## Additional Capabilities
- Historical sports statistics and records
- Sports trivia and milestone events
- Cross-sport comparative analysis

⌞extend:sports-news-agent⌟
```