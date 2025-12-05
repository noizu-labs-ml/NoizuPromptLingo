# Marketing Agents

Developer-focused marketing agents that drive adoption, engagement, and growth for technical products and open-source projects.

## Overview

Marketing agents in the NPL framework specialize in creating compelling narratives for developer audiences. These agents understand technical decision-making processes and communicate value through code examples, benchmarks, and practical demonstrations rather than traditional marketing rhetoric.

## Available Agents

### [npl-positioning](./npl-positioning.md)
Strategic positioning agent that defines unique value propositions for technical products. Creates differentiation strategies based on technical capabilities, performance metrics, and developer workflow improvements. Analyzes competitive landscapes through feature matrices and benchmarks.

### [npl-marketing-copy](./npl-marketing-copy.md)
Technical copywriting specialist that produces developer-friendly content. Generates documentation-style marketing materials, technical blog posts, and API-focused messaging. Transforms features into developer benefits using code examples and real-world use cases.

### [npl-conversion](./npl-conversion.md)
Conversion optimization agent focused on developer journey mapping. Designs frictionless onboarding experiences, creates compelling CTAs for technical audiences, and optimizes trial-to-paid conversion through developer-centric strategies. Specializes in reducing time-to-first-value.

### [npl-community](./npl-community.md)
Community growth strategist for developer ecosystems. Plans engagement initiatives, designs contributor programs, and creates community-driven content strategies. Builds sustainable open-source communities through recognition systems and collaborative frameworks.

## Developer Marketing Workflows

### Product Launch Campaign
```bash
# Define positioning and messaging
@npl-positioning analyze --product=new-cli-tool --competitors=5

# Generate launch materials
@npl-marketing-copy create --type=announcement --channels="github,devto,hn"

# Optimize conversion paths
@npl-conversion design --funnel=signup-to-activation

# Plan community engagement
@npl-community strategy --launch-week --target=early-adopters
```

### Open Source Growth
```bash
# Position project in ecosystem
@npl-positioning oss-strategy --project=ml-framework

# Create contributor-friendly content
@npl-marketing-copy generate --type=contributing-guide

# Design contributor onboarding
@npl-conversion optimize --journey=first-time-contributor

# Build community infrastructure
@npl-community setup --discord --governance=democratic
```

### Developer Tool Adoption
```bash
# Competitive analysis
@npl-positioning benchmark --category=devtools --metrics=performance,dx

# Technical documentation marketing
@npl-marketing-copy enhance-docs --add-examples --highlight-benefits

# Trial optimization
@npl-conversion analyze --trial-dropoff --segment=enterprise-devs

# User community activation
@npl-community engage --power-users --ambassadors-program
```

## Integration Patterns

### With Technical Agents
```bash
# Combine with documentation for better onboarding
@npl-technical-writer create-quickstart | @npl-marketing-copy enhance

# Performance benchmarks for positioning
@npl-benchmark run-suite | @npl-positioning analyze-results
```

### With Analytics
```bash
# Data-driven conversion optimization
@npl-analytics funnel-analysis | @npl-conversion identify-dropoffs

# Community health metrics
@npl-community metrics --engagement | @npl-analytics visualize
```

## Templaterized Customization

All marketing agents support NPL template syntax for customizable outputs:

```npl
{{#template marketing-campaign}}
  product: {{product_name}}
  audience: {{developer_segment}}
  channels:
    {{#each channels}}
    - {{name}}: {{strategy}}
    {{/each}}
  metrics:
    - adoption_rate
    - time_to_value
    - community_growth
{{/template}}
```

## Best Practices

### Developer-First Messaging
- Lead with code, not claims
- Show performance benchmarks
- Provide working examples
- Focus on integration ease

### Technical Credibility
- Use accurate terminology
- Reference specifications
- Include architecture diagrams
- Cite real-world usage

### Community Building
- Enable contributors early
- Recognize participation
- Share roadmap openly
- Respond to feedback quickly

### Conversion Optimization
- Minimize setup friction
- Provide instant value
- Clear documentation paths
- Developer-friendly trials

## Success Metrics

### Adoption Indicators
- GitHub stars growth rate
- NPM weekly downloads
- Docker pulls
- Fork-to-contributor ratio

### Engagement Metrics
- Documentation views
- API key generations
- Community activity
- Support ticket quality

### Growth Drivers
- Time to first commit
- Trial to paid conversion
- Community contributions
- Developer satisfaction scores

## Common Use Cases

1. **Open Source Launch**: Position project, create announcement, build initial community
2. **Developer Tool Marketing**: Technical positioning, API documentation, conversion optimization
3. **Community Growth**: Contributor programs, engagement strategies, ecosystem development
4. **Technical Content**: Blog posts, tutorials, case studies, benchmarks
5. **Product Adoption**: Onboarding optimization, activation improvement, retention strategies

## Getting Started

```bash
# Analyze current positioning
@npl-positioning audit --current-state

# Generate initial messaging
@npl-marketing-copy baseline --product-brief

# Map developer journey
@npl-conversion map-journey --user-research

# Plan community strategy
@npl-community roadmap --6-months
```

## See Also

- [NPL Agentic Framework](../../npl/agentic/)
- [Virtual Tools Documentation](../../virtual-tools/)
- [Agent Templates](../../npl/agentic/scaffolding/agent-templates/)