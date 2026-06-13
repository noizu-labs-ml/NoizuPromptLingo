# noizu.ink — User Personas

10 personas spanning the full spectrum of potential users, from expert developers to non-technical creators. Organized by segment and mapped to pipeline phases and pricing tiers.

## Persona Map

| # | Name | Segment | Pipeline Entry → Exit | Tier Fit |
|---|------|---------|----------------------|----------|
| 01 | [Marcus Chen](01-marcus-chen.md) | Solo Developer | Sketch → Ink | Builder ($49) |
| 02 | [Jules Okafor](02-jules-okafor.md) | Indie Hacker | Sketch → Publish | Launch ($99) |
| 03 | [Rina Patel](03-rina-patel.md) | Small Team Lead | Sketch → Ink | Builder ($49) |
| 04 | [David Liu](04-david-liu.md) | Non-Technical Founder | Sketch → Draft | Pro ($19) |
| 05 | [Sofia Reyes](05-sofia-reyes.md) | UX Designer | Draft → Ink | Builder ($49) |
| 06 | [Tom Brennan](06-tom-brennan.md) | CS Instructor | Sketch → Ink | Free / Pro ($19) |
| 07 | [Aisha Mohammed](07-aisha-mohammed.md) | Agency Director | Sketch → Draft | Pro ($19) |
| 08 | [Kevin Tanaka](08-kevin-tanaka.md) | Product Manager | Sketch → Draft | Pro ($19) |
| 09 | [Chen Wei](09-chen-wei.md) | Enterprise Innovation | Sketch → Ink | Builder ($49) |
| 10 | [Maya Jackson](10-maya-jackson.md) | Content Creator | Sketch → Publish | Launch ($99) |

## Segmentation Summary

### By Technical Proficiency

| Level | Personas | Implication |
|-------|----------|-------------|
| **Expert** | Marcus, Jules, Rina, Tom | Will use Ink phase heavily; care about code quality and export |
| **Moderate** | Sofia, Kevin, Aisha, Chen Wei | Value Draft phase outputs; may or may not enter Ink |
| **Low** | David, Maya | Need the full pipeline to be fully guided; can't self-serve on code |

### By Pipeline Phase Value

| Phase | Primary Value For |
|-------|-------------------|
| **Sketch (Plan)** | Kevin, Tom, David — the spec is the product |
| **Draft (Design)** | Sofia, Aisha — mockups close deals or validate designs |
| **Ink (Build)** | Marcus, Jules, Rina, Chen Wei — working code is the goal |
| **Publish (Ship)** | Jules, Maya — need deployment because they ship to real users |

### By Pricing Tier

| Tier | Personas | Revenue Signal |
|------|----------|----------------|
| **Free** | Tom's students | Volume + word-of-mouth in education |
| **Pro ($19)** | David, Tom, Aisha, Kevin | Highest conversion potential — Sketch + Draft alone is valuable |
| **Builder ($49)** | Marcus, Rina, Sofia, Chen Wei | Core power users — need agent-built code |
| **Launch ($99)** | Jules, Maya | Full pipeline users — highest ARPU, highest expectations |

## Design Implications

1. **The wizard must work for non-technical users** — David and Maya can't be expected to understand technical jargon. Plain English in, structured output out.
2. **Phase boundaries are natural monetization gates** — Pro users get massive value from Sketch + Draft without ever touching code.
3. **Export quality matters more than agent sophistication for the mid-tier** — Aisha and Kevin judge the tool by the spec/mockup output, not the code.
4. **Education is a Trojan horse** — Tom's students become Marcus in 3 years. Free tier for students is a long-term acquisition play.
5. **Enterprise is a stretch goal, not MVP** — Chen Wei's security requirements (SSO, data residency, self-hosting) are real but shouldn't drive v0.1 architecture.
6. **"Build in public" creators are organic marketing** — Maya generates content about using the tool. This persona is worth cultivating for growth.
