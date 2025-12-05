# User Experience Agents

NPL agents focused on optimizing user experience, accessibility, and adoption through research-driven design and performance optimization.

## Overview

The User Experience agent category provides specialized tools for understanding user needs, ensuring accessibility compliance, optimizing performance, and creating effective onboarding experiences. These agents work together to create products that users can easily adopt and effectively use.

## Available Agents

### npl-user-researcher
Conducts user research through surveys, interviews, and usability testing to gather insights about user needs, behaviors, and pain points.

**Key Functions:**
- Design and execute user research studies
- Analyze user feedback and behavioral data
- Create user personas and journey maps
- Generate research-backed recommendations

[Full Documentation →](./npl-user-researcher.md)

### npl-accessibility
Ensures digital products meet accessibility standards (WCAG, ADA) and are usable by people with diverse abilities.

**Key Functions:**
- Audit interfaces for accessibility compliance
- Generate accessible component alternatives
- Create screen reader-friendly content
- Provide keyboard navigation patterns

[Full Documentation →](./npl-accessibility.md)

### npl-performance
Optimizes application performance for better user experience across devices and network conditions.

**Key Functions:**
- Analyze performance metrics and bottlenecks
- Optimize load times and responsiveness
- Implement lazy loading and caching strategies
- Monitor Core Web Vitals

[Full Documentation →](./npl-performance.md)

### npl-onboarding
Creates effective onboarding flows that help new users quickly understand and adopt products.

**Key Functions:**
- Design progressive disclosure patterns
- Create interactive tutorials and tooltips
- Build contextual help systems
- Measure and optimize activation rates

[Full Documentation →](./npl-onboarding.md)

## Improving User Adoption and Satisfaction

These agents collaborate to create a comprehensive UX optimization strategy:

1. **Research-Driven Design**: User researcher identifies needs and pain points
2. **Inclusive Experience**: Accessibility agent ensures everyone can use the product
3. **Fast and Responsive**: Performance agent optimizes speed and efficiency
4. **Smooth Activation**: Onboarding agent helps users reach their first success

## Templaterized Customization

All user experience agents support NPL templating for project-specific customization:

```npl
{{#if industry}}
  # Industry-specific UX patterns for {{industry}}
{{/if}}

{{#if user_base}}
  # Optimized for {{user_base}} users
{{/if}}
```

Templates can be customized for:
- Industry-specific requirements
- Target demographics
- Platform constraints
- Regulatory compliance needs

## UX Optimization Workflows

### Complete UX Audit
```bash
# Research current user experience
@npl-user-researcher analyze --product=app --method=heuristic

# Check accessibility compliance
@npl-accessibility audit --standard=WCAG-2.1-AA

# Measure performance metrics
@npl-performance analyze --device=mobile --network=3g

# Review onboarding effectiveness
@npl-onboarding evaluate --metrics=activation,retention
```

### New Feature UX Design
```bash
# Gather user requirements
@npl-user-researcher survey --topic="feature-needs" --sample=100

# Design accessible interface
@npl-accessibility generate --component=form --level=AAA

# Optimize for performance
@npl-performance optimize --target=first-paint --budget=2s

# Create feature introduction
@npl-onboarding create --type=tooltip --feature=new-dashboard
```

### Mobile UX Optimization
```bash
# Research mobile user patterns
@npl-user-researcher analyze --platform=mobile --behavior=gestures

# Ensure touch accessibility
@npl-accessibility validate --interface=touch --target-size=44px

# Optimize for mobile networks
@npl-performance optimize --network=slow-3g --images=lazy

# Simplify mobile onboarding
@npl-onboarding streamline --platform=mobile --steps=3
```

### Accessibility-First Redesign
```bash
# Identify accessibility barriers
@npl-accessibility audit --deep --report=detailed

# Research assistive technology users
@npl-user-researcher interview --users=screen-reader --count=10

# Optimize performance for assistive tech
@npl-performance optimize --focus=dom-size --animations=reduced

# Create accessible onboarding
@npl-onboarding generate --accessible --multimodal
```

## Integration Examples

### With Development Agents
```bash
# UX research informs development
@npl-user-researcher findings | @npl-code-architect design

# Performance optimization in code
@npl-performance recommendations | @npl-code-reviewer validate
```

### With Design Agents
```bash
# Research-backed design decisions
@npl-user-researcher personas | @npl-design-system incorporate

# Accessible component library
@npl-accessibility patterns | @npl-component-builder implement
```

### With Analytics Agents
```bash
# Data-driven UX improvements
@npl-analytics user-behavior | @npl-user-researcher analyze

# Performance monitoring setup
@npl-performance metrics | @npl-monitoring configure
```

## Best Practices

1. **Start with Research**: Always begin with user research to understand actual needs
2. **Design for Everyone**: Consider accessibility from the beginning, not as an afterthought
3. **Measure Everything**: Use metrics to validate UX improvements
4. **Iterate Based on Feedback**: Continuously refine based on user data
5. **Balance Features and Performance**: Don't sacrifice speed for functionality
6. **Progressive Enhancement**: Build experiences that work for all users, then enhance

## Configuration

Each agent can be configured through environment variables or NPL templates:

```bash
# Set research methodology preferences
export NPL_USER_RESEARCH_METHODS="interviews,surveys,analytics"

# Configure accessibility standards
export NPL_ACCESSIBILITY_STANDARD="WCAG-2.1-AAA"

# Define performance budgets
export NPL_PERFORMANCE_BUDGET="FCP:2s,LCP:2.5s,CLS:0.1"

# Set onboarding goals
export NPL_ONBOARDING_TARGET="activation:80%,day1-retention:60%"
```

## Metrics and KPIs

Track UX improvements with these key metrics:

- **User Satisfaction**: NPS, CSAT scores
- **Accessibility Score**: WCAG compliance percentage
- **Performance Score**: Lighthouse scores, Core Web Vitals
- **Onboarding Success**: Activation rate, time-to-value
- **Task Completion**: Success rate, error rate
- **Engagement**: Session duration, return rate

## Resources

- [NPL Agent Framework Documentation](../../README.md)
- [UX Research Methods Guide](https://www.nngroup.com/articles/)
- [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Web Performance Best Practices](https://web.dev/performance/)
- [Onboarding Pattern Library](https://www.appcues.com/user-onboarding)