# npl-technical-writer

Technical documentation agent that generates specs, PRs, issues, and docs without marketing fluff or LLM verbosity.

## Purpose

Produces clear, actionable technical content. Strips filler words, removes passive voice, and uses exact terminology. Output is direct and implementation-ready.

See [Detailed Documentation](npl-technical-writer.detailed.md) for complete reference.

## Capabilities

- **Document generation**: specs, PRs, issues, READMEs, API docs ([Document Categories](npl-technical-writer.detailed.md#document-categories))
- **Review mode**: inline annotations with specific improvement suggestions ([Annotation Patterns](npl-technical-writer.detailed.md#annotation-patterns))
- **Diagram support**: Mermaid and PlantUML integration ([Diagram Support](npl-technical-writer.detailed.md#diagram-support))
- **Template-driven**: consistent structure via named templates ([Templates](npl-technical-writer.detailed.md#templates))
- **Anti-pattern filtering**: auto-removes "certainly", "it's worth noting", marketing language ([Anti-Pattern Filters](npl-technical-writer.detailed.md#anti-pattern-filters))
- **House style loading**: hierarchical style guide support ([House Style Loading](npl-technical-writer.detailed.md#house-style-loading))

## Commands

| Command | Description | Details |
|:--------|:------------|:--------|
| `spec` | Technical specifications | [spec command](npl-technical-writer.detailed.md#spec) |
| `pr` | Pull request descriptions | [pr command](npl-technical-writer.detailed.md#pr) |
| `issue` | Bug reports / feature requests | [issue command](npl-technical-writer.detailed.md#issue) |
| `doc` | General documentation | [doc command](npl-technical-writer.detailed.md#doc) |
| `readme` | Project README files | [readme command](npl-technical-writer.detailed.md#readme) |
| `api-doc` | API documentation | [api-doc command](npl-technical-writer.detailed.md#api-doc) |
| `annotate` | Add inline feedback | [annotate command](npl-technical-writer.detailed.md#annotate) |
| `review` | Document editing and rewrite | [review command](npl-technical-writer.detailed.md#review) |

## Quick Examples

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

See [Integration Patterns](npl-technical-writer.detailed.md#integration-patterns) for more workflows.

## Limitations

- Cannot execute code or validate implementations
- Technical depth limited to provided context
- Aggressive fluff removal may occasionally over-trim

See [Limitations](npl-technical-writer.detailed.md#limitations) for complete list.

## See Also

- [Detailed Documentation](npl-technical-writer.detailed.md) - Complete reference
- [Best Practices](npl-technical-writer.detailed.md#best-practices)
- [Templates](npl-technical-writer.detailed.md#templates)
- Core definition: `npl-technical-writer|writer|NPL@1.0`
