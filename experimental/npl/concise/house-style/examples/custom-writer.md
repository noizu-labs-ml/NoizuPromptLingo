# Custom Writer Integration Example

This example shows how to integrate house style loading with custom NPL writer agents for specialized writing types.

## Generic Integration Template

### Universal House Style Loading Pattern
```markdown
# House Style Context Loading for {STYLE_TYPE}
# Load {style_type} writing style guides in precedence order
{{if HOUSE_STYLE_{STYLE_TYPE}_ADDENDUM}}
load {{HOUSE_STYLE_{STYLE_TYPE}_ADDENDUM}} into context.
{{/if}}
{{if HOUSE_STYLE_{STYLE_TYPE}}}
load {{HOUSE_STYLE_{STYLE_TYPE}}} into context.
{{if file_contains(HOUSE_STYLE_{STYLE_TYPE}, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
{{else}}
load_default_house_styles: true
{{/if}}

{{if load_default_house_styles}}
# Load style guides in order: home, project .claude, then nearest to target path
{{if file_exists("~/.claude/npl-m/house-style/{style_type}-style.md")}}
load ~/.claude/npl-m/house-style/{style_type}-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/{style_type}-style.md")}}
load .claude/npl-m/house-style/{style_type}-style.md into context.
{{/if}}
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/{style_type}-style.md")}}
load {{path}}/house-style/{style_type}-style.md into context.
{{/if}}
{{/for}}
{{/if}}
```

## Example: Legal Writer Agent

### Legal Writer Definition
```markdown
---
name: npl-legal-writer
description: Legal document writer that generates contracts, policies, and compliance documentation with precise legal language and proper formatting.
model: inherit
color: purple
---

load .claude/npl.md into context.
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-rubric.md into context.

# House Style Context Loading for Legal Writing
{{if HOUSE_STYLE_LEGAL_ADDENDUM}}
load {{HOUSE_STYLE_LEGAL_ADDENDUM}} into context.
{{/if}}
{{if HOUSE_STYLE_LEGAL}}
load {{HOUSE_STYLE_LEGAL}} into context.
{{if file_contains(HOUSE_STYLE_LEGAL, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
{{else}}
load_default_house_styles: true
{{/if}}

{{if load_default_house_styles}}
{{if file_exists("~/.claude/npl-m/house-style/legal-style.md")}}
load ~/.claude/npl-m/house-style/legal-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/legal-style.md")}}
load .claude/npl-m/house-style/legal-style.md into context.
{{/if}}
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/legal-style.md")}}
load {{path}}/house-style/legal-style.md into context.
{{/if}}
{{/for}}
{{/if}}

---
⌜npl-legal-writer|writer|NPL@1.0⌝
# NPL Legal Writer Agent
🙋 @legal-writer @legal contract policy terms privacy

Legal document specialist that creates contracts, policies, terms of service, and compliance documentation with precise legal language and proper legal formatting.
```

### Legal Style Guide Example
```markdown
# Legal Writing Style Guide

## Legal Language Standards
- Use precise legal terminology
- Avoid ambiguous pronouns
- Define all terms clearly
- Use "shall" for obligations, "may" for permissions
- Include jurisdiction specifications

## Document Structure
- Clear section numbering (1., 1.1, 1.1.1)
- Defined terms in quotes or capitalized
- Cross-reference sections properly
- Include effective date and version

## Compliance Requirements
- Include required legal disclaimers
- Reference applicable laws and regulations
- Specify governing jurisdiction
- Include standard legal boilerplate

+load-default-styles
```

### Usage Example
```bash
# Company-specific legal style
export HOUSE_STYLE_LEGAL="/company/legal-dept/style-guide.md"

# Generate privacy policy
@npl-legal-writer generate policy --type="privacy" --jurisdiction="California"

# Generate contract with specific additions
export HOUSE_STYLE_LEGAL_ADDENDUM="/contracts/saas/additional-clauses.md"
@npl-legal-writer generate contract --type="saas-agreement"
```

## Example: Academic Writer Agent

### Academic Writer Definition
```markdown
---
name: npl-academic-writer
description: Academic writing specialist for research papers, dissertations, and scholarly articles with proper citation and academic formatting.
model: inherit
color: navy
---

load .claude/npl.md into context.
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-rubric.md into context.

# House Style Context Loading for Academic Writing
{{if HOUSE_STYLE_ACADEMIC_ADDENDUM}}
load {{HOUSE_STYLE_ACADEMIC_ADDENDUM}} into context.
{{/if}}
{{if HOUSE_STYLE_ACADEMIC}}
load {{HOUSE_STYLE_ACADEMIC}} into context.
{{if file_contains(HOUSE_STYLE_ACADEMIC, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
{{else}}
load_default_house_styles: true
{{/if}}

{{if load_default_house_styles}}
{{if file_exists("~/.claude/npl-m/house-style/academic-style.md")}}
load ~/.claude/npl-m/house-style/academic-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/academic-style.md")}}
load .claude/npl-m/house-style/academic-style.md into context.
{{/if}}
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/academic-style.md")}}
load {{path}}/house-style/academic-style.md into context.
{{/if}}
{{/for}}
{{/if}}

---
⌜npl-academic-writer|writer|NPL@1.0⌝
# NPL Academic Writer Agent
🙋 @academic-writer @scholar paper thesis dissertation article

Academic writing specialist for research papers, theses, dissertations, and scholarly articles with proper citation, methodology, and academic formatting standards.
```

### Academic Style Guide Example
```markdown
# Academic Writing Style Guide

## Academic Voice
- Formal, objective tone
- Third person perspective
- Precise, scholarly language
- Evidence-based arguments

## Citation Standards
- Follow APA/MLA/Chicago style consistently
- Cite all sources properly
- Include page numbers for direct quotes
- Use signal phrases for integration

## Structure Requirements
- Clear thesis statement
- Logical argument progression
- Topic sentences for paragraphs
- Smooth transitions between ideas

## Research Standards
- Use peer-reviewed sources
- Current sources (within 5-10 years)
- Diverse perspectives included
- Primary sources when available

+load-default-styles
```

### Usage Example
```bash
# University-specific academic style
export HOUSE_STYLE_ACADEMIC="/university/writing-center/style-guide.md"

# Generate research paper with APA style
@npl-academic-writer generate paper --topic="machine learning ethics" --style="APA"

# Add journal-specific requirements
export HOUSE_STYLE_ACADEMIC_ADDENDUM="/journals/nature-ai/submission-guidelines.md"
@npl-academic-writer generate article --journal="Nature AI"
```

## Example: Creative Writer Agent

### Creative Writer Definition
```markdown
---
name: npl-creative-writer
description: Creative writing specialist for stories, scripts, poetry, and creative content with engaging narrative voice and literary techniques.
model: inherit
color: magenta
---

load .claude/npl.md into context.
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-mood.md into context.
load .claude/npl/pumps/npl-critique.md into context.

# House Style Context Loading for Creative Writing
{{if HOUSE_STYLE_CREATIVE_ADDENDUM}}
load {{HOUSE_STYLE_CREATIVE_ADDENDUM}} into context.
{{/if}}
{{if HOUSE_STYLE_CREATIVE}}
load {{HOUSE_STYLE_CREATIVE}} into context.
{{if file_contains(HOUSE_STYLE_CREATIVE, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
{{else}}
load_default_house_styles: true
{{/if}}

{{if load_default_house_styles}}
{{if file_exists("~/.claude/npl-m/house-style/creative-style.md")}}
load ~/.claude/npl-m/house-style/creative-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/creative-style.md")}}
load .claude/npl-m/house-style/creative-style.md into context.
{{/if}}
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/creative-style.md")}}
load {{path}}/house-style/creative-style.md into context.
{{/if}}
{{/for}}
{{/if}}

---
⌜npl-creative-writer|writer|NPL@1.0⌝
# NPL Creative Writer Agent
🙋 @creative-writer @story @script @poetry @fiction

Creative writing specialist for stories, screenplays, poetry, and imaginative content with engaging narrative techniques and literary craftsmanship.
```

### Creative Style Guide Example
```markdown
# Creative Writing Style Guide

## Narrative Voice
- Consistent point of view
- Authentic character voices
- Appropriate narrative distance
- Engaging opening hooks

## Literary Techniques
- Show, don't tell
- Sensory details and imagery
- Dynamic dialogue
- Effective pacing and rhythm

## Genre Considerations
- Understand genre conventions
- Meet reader expectations
- Appropriate tone and mood
- Genre-specific language patterns

## Character Development
- Distinct character voices
- Consistent characterization
- Character growth arcs
- Believable motivations

+load-default-styles
```

## Implementation Guide for Custom Writers

### Step 1: Define Style Type
```markdown
# Choose unique style type identifier (lowercase, no spaces)
STYLE_TYPE = "business"  # For business communications
STYLE_TYPE = "scientific"  # For scientific writing
STYLE_TYPE = "tutorial"  # For instructional content
```

### Step 2: Create Agent Template
```markdown
---
name: npl-{style-type}-writer
description: {Description of writing specialization}
model: inherit
color: {appropriate-color}
---

# Standard NPL pump loading
load .claude/npl.md into context.
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-rubric.md into context.

# Add specialized pumps if needed
{{if specialized_context}}
load .claude/npl/pumps/specialized-pump.md into context.
{{/if}}

# House Style Context Loading
# [Insert complete house style loading block with STYLE_TYPE]

---
⌜npl-{style-type}-writer|writer|NPL@1.0⌝
# NPL {Style Type} Writer Agent
🙋 @{style-type}-writer @{aliases}

{Agent description and capabilities}
```

### Step 3: Create Style Template
```markdown
# {Style Type} Writing Style Guide

## Core Principles
# Define the fundamental principles for this writing type

## Voice and Tone
# Specify appropriate voice characteristics

## Structure Guidelines
# Define organizational patterns

## Language Standards
# Specify vocabulary, grammar, and usage rules

## Quality Criteria
# Define what makes good writing in this style

+load-default-styles
```

### Step 4: Define Environment Variables
```bash
# Primary style override
export HOUSE_STYLE_{STYLE_TYPE}="/path/to/custom-style.md"

# Supplementary additions
export HOUSE_STYLE_{STYLE_TYPE}_ADDENDUM="/path/to/additions.md"
```

### Step 5: Test Integration
```bash
# Test default loading
@npl-{style-type}-writer generate {content-type}

# Test environment override
export HOUSE_STYLE_{STYLE_TYPE}="/test/override-style.md"
@npl-{style-type}-writer generate {content-type}

# Test addendum pattern
export HOUSE_STYLE_{STYLE_TYPE}_ADDENDUM="/test/extra-rules.md"
@npl-{style-type}-writer generate {content-type}
```

## Best Practices for Custom Writers

### Style Guide Design
1. **Focus on specifics**: Define what makes this writing type unique
2. **Provide examples**: Include good and bad examples
3. **Address common issues**: Tackle typical problems in this domain
4. **Enable extension**: Always include `+load-default-styles`

### Environment Variable Naming
1. **Use uppercase**: Follow `HOUSE_STYLE_{TYPE}` pattern
2. **Choose clear names**: Style type should be obvious
3. **Avoid conflicts**: Don't reuse existing style type names
4. **Document usage**: Include examples in agent documentation

### Testing Strategy
1. **Test all scenarios**: Default, override, addendum, combination
2. **Verify hierarchy**: Ensure proper loading order
3. **Check compatibility**: Test with existing NPL infrastructure
4. **Validate output**: Ensure style guidelines are followed

This pattern enables any specialized writer agent to leverage the sophisticated house style loading system while maintaining consistency with the NPL framework.