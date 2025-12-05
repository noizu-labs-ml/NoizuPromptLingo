# npl-technical-writer

Technical documentation agent that generates specs, PRs, issues, and docs without marketing fluff or LLM verbosity.

## Purpose

Produces clear, actionable technical content. Strips filler words, removes passive voice, and uses exact terminology. Output is direct and implementation-ready.

## Capabilities

- **Document generation**: specs, PRs, issues, READMEs, API docs
- **Review mode**: inline annotations with specific improvement suggestions
- **Diagram support**: Mermaid and PlantUML integration
- **Template-driven**: consistent structure via named templates
- **Anti-pattern filtering**: auto-removes "certainly", "it's worth noting", marketing language
- **House style loading**: hierarchical style guide support

## Usage

```bash
# Generate a technical specification
@writer spec --component=user-authentication

# Create PR description
@writer pr --changes="src/auth.js,test/auth.test.js"

# Review existing document with annotations
@writer review docs/architecture.md --mode=annotate

# Generate README
@writer readme --project-type=nodejs
```

## Commands

| Command | Description |
|---------|-------------|
| `spec` | Technical specifications |
| `pr` | Pull request descriptions |
| `issue` | Bug reports / feature requests |
| `doc` | General documentation |
| `readme` | Project README files |
| `api-doc` | API documentation |
| `annotate` | Add inline feedback |
| `review` | Document editing and rewrite |

## Workflow Integration

```bash
# Generate and evaluate quality
@writer readme > README.md && @grader evaluate README.md

# Multiple reviewer perspectives
@writer review spec.md --persona=senior-architect
@writer review spec.md --persona=security-expert

# Feed context from other agents
@gopher summarize src/ | @writer spec --component=auth
```

## See Also

- Core definition: `core/agents/npl-technical-writer.md`
- House styles: `conventions/technical.house-style`
