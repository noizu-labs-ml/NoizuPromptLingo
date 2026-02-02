# User Experience Agents

Agents focused on UX design, accessibility, user research, and frontend performance.

## Agents

### npl-accessibility
Ensures accessibility compliance (WCAG), inclusive design practices, and barrier removal for users with disabilities. Validates assistive technology compatibility.

### npl-onboarding
Designs user onboarding flows, first-time user experiences, and learning paths. Reduces friction and accelerates user activation.

### npl-performance
Optimizes frontend performance, perceived performance, and user experience metrics (Core Web Vitals, LCP, FID, CLS). Balances features with performance.

### npl-user-researcher
Conducts user research, interviews, usability testing, and feedback synthesis. Ensures user voice informs product decisions.

## Workflows

**Feature User Experience Design**
1. npl-user-researcher: Conduct user research and feedback
2. npl-onboarding: Design feature onboarding and learning path
3. npl-accessibility: Validate accessibility compliance
4. npl-performance: Optimize performance impact
5. npl-user-researcher: Validate with users (usability testing)

**Accessibility & Inclusion Initiative**
1. npl-accessibility: Audit current state and gaps
2. npl-user-researcher: Test with users with disabilities
3. npl-accessibility: Prioritize remediation by impact
4. npl-performance: Ensure accessibility improvements are performant
5. npl-user-researcher: Validate improvements

## Integration Points

- **Upstream**: prd-editor (feature specs), npl-positioning (user segments)
- **Downstream**: npl-onboarding (rollout), npl-conversion (activation)
- **Cross-functional**: npl-performance (performance optimization), npl-technical-writer (documentation)

## Key Responsibilities

| Agent | Primary | Secondary |
|-------|---------|-----------|
| **accessibility** | WCAG compliance, accessible design | Assistive tech testing, barrier removal |
| **onboarding** | Onboarding design, learning paths | Feature discovery, activation flows |
| **performance** | Frontend performance optimization | Core Web Vitals, UX metrics |
| **user-researcher** | User research, usability testing | User feedback synthesis, insights |

## User Experience Quality Model

```
Research → Design → Accessibility → Performance → Testing → Iteration
```

UX agents work collaboratively to ensure delightful, accessible, performant user experiences.
