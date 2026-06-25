# FastMCP Summary Brief Generation

**Special handling for synthesizing 11 fastmcp briefs into one "big picture overview"**

## Input
Read the following 11 brief files (that will be created):
- `.tmp/docs/fastmcp/01-installation.brief.md`
- `.tmp/docs/fastmcp/02-core-concepts.brief.md`
- `.tmp/docs/fastmcp/03-tools.brief.md`
- `.tmp/docs/fastmcp/04-resources.brief.md`
- `.tmp/docs/fastmcp/05-prompts.brief.md`
- `.tmp/docs/fastmcp/06-context.brief.md`
- `.tmp/docs/fastmcp/07-client.brief.md`
- `.tmp/docs/fastmcp/08-deployment.brief.md`
- `.tmp/docs/fastmcp/09-migration.brief.md`
- `.tmp/docs/fastmcp/10-examples.brief.md`
- `.tmp/docs/fastmcp/README.brief.md`

## Output
Create: `.tmp/docs/fastmcp/summary.md`

## Structure (800-1200 words)

```markdown
# FastMCP - Big Picture Overview

## What is FastMCP?
[2-3 paragraphs synthesizing purpose from all 11 briefs]
- Core value proposition
- Primary use cases
- Target audience

## Learning Path
[Recommended sequence for learning/implementing]
1. [Concept] → [Which brief(s) cover it]
2. [Concept] → [Which brief(s) cover it]
[6-8 learning steps]

## Core Concepts at a Glance
[Table or bullets with key concepts and brief explanations, pulling from 02-core-concepts]

## Key Components
[Pull from 03-tools, 04-resources, 05-prompts, 06-context, 07-client]

| Component | Purpose | When to Use |
|-----------|---------|------------|
| [Component] | [Purpose from briefs] | [Use case] |

## Implementation Workflow
[Synthesize from 01-installation, 08-deployment, 07-client]
1. Setup → [See 01-installation]
2. Define resources → [See 04-resources]
3. Configure tools → [See 03-tools]
4. Deploy → [See 08-deployment]
5. Client integration → [See 07-client]

## Common Patterns & Examples
[From 10-examples brief]
- [Pattern 1]
- [Pattern 2]
[3-4 key patterns with brief summaries]

## Migration & Upgrades
[From 09-migration brief]
[Key migration considerations, version compatibility]

## Quick Start
[Distill to absolute essentials for someone wanting to get started NOW]
1. [Step 1 with reference to relevant brief]
2. [Step 2]
3. [Step 3]

## Integration with Claude
[Synthesize how FastMCP connects to Claude ecosystem]

## Next Steps
[Guide reader to which brief/section to read based on their goal]
- **Want to get started?** → See 01-installation
- **Need to understand concepts?** → See 02-core-concepts
- **Building tools?** → See 03-tools
- [etc.]

---
**Synthesized from**: 11 FastMCP briefs + source docs
```

## Key Synthesis Rules

1. **Don't repeat** - Brief summaries already exist in individual .brief.md files
2. **Connect concepts** - Show how 10 modules relate to each other
3. **Navigation focused** - Help readers know which brief to read for their need
4. **Big picture** - Abstract away details, focus on relationships
5. **Practical** - Include quick start and common workflows
6. **Accessible** - Assume someone new to FastMCP reading this

## Tone
- Educational but efficient
- Opinionated about learning path
- Tutorial-friendly (not reference-dense)
