# Marketing Writer Integration Example

This example shows how to integrate house style loading with NPL marketing writer agents.

## Agent Integration Pattern

### Complete House Style Loading Block
```markdown
# House Style Context Loading
# Load marketing style guides in precedence order (nearest to target first)
{{if HOUSE_STYLE_MARKETING_ADDENDUM}}
load {{HOUSE_STYLE_MARKETING_ADDENDUM}} into context.
{{/if}}
{{if HOUSE_STYLE_MARKETING}}
load {{HOUSE_STYLE_MARKETING}} into context.
{{if file_contains(HOUSE_STYLE_MARKETING, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
{{else}}
load_default_house_styles: true
{{/if}}

{{if load_default_house_styles}}
# Load style guides in order: home, project .claude, then nearest to target path
{{if file_exists("~/.claude/npl-m/house-style/marketing-style.md")}}
load ~/.claude/npl-m/house-style/marketing-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/marketing-style.md")}}
load .claude/npl-m/house-style/marketing-style.md into context.
{{/if}}
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/marketing-style.md")}}
load {{path}}/house-style/marketing-style.md into context.
{{/if}}
{{/for}}
{{/if}}
```

## Usage Scenarios

### Scenario 1: Brand Voice Hierarchy
**Setup**: No environment variables set

**Directory Structure**:
```
~/.claude/npl-m/house-style/
└── marketing-style.md              # Personal marketing preferences

/company/.claude/npl-m/house-style/
└── marketing-style.md              # Corporate brand voice

/company/marketing/campaigns/house-style/
└── marketing-style.md              # Campaign-specific voice

/company/marketing/campaigns/black-friday/house-style/
└── marketing-style.md              # Black Friday specific tone
```

**Working on**: `/company/marketing/campaigns/black-friday/landing-page.md`

**Loading Order**:
1. `~/.claude/npl-m/house-style/marketing-style.md`
2. `/company/.claude/npl-m/house-style/marketing-style.md`
3. `/company/house-style/marketing-style.md` (if exists)
4. `/company/marketing/house-style/marketing-style.md` (if exists)
5. `/company/marketing/campaigns/house-style/marketing-style.md`
6. `/company/marketing/campaigns/black-friday/house-style/marketing-style.md`

### Scenario 2: Client Brand Override
**Setup**:
```bash
export HOUSE_STYLE_MARKETING="/clients/acme/brand-voice.md"
```

**Contents of `/clients/acme/brand-voice.md`**:
```markdown
# ACME Corporation Brand Voice

## Brand Personality
- Professional yet approachable
- Innovation-focused
- Customer success oriented

## Voice Guidelines
- Use "we" and "our" to show partnership
- Focus on business outcomes
- Include ROI metrics when possible

## Tone by Content Type
- Website: Confident and informative
- Emails: Personal and helpful
- Case studies: Results-driven

+load-default-styles
```

**Loading Order**:
1. `/clients/acme/brand-voice.md`
2. `~/.claude/npl-m/house-style/marketing-style.md`
3. Default hierarchy continues...

### Scenario 3: Campaign-Specific Addition
**Setup**:
```bash
export HOUSE_STYLE_MARKETING_ADDENDUM="/campaigns/q4-2024/holiday-voice.md"
```

**Contents of `/campaigns/q4-2024/holiday-voice.md`**:
```markdown
# Q4 2024 Holiday Campaign Voice

## Campaign-Specific Guidelines
- Emphasize limited-time offers
- Use holiday-themed language sparingly
- Focus on year-end benefits
- Include gift-giving angle for B2B

## Urgency Language
- "Before year-end"
- "While budgets allow"
- "Limited Q4 availability"
- "Start the new year strong"
```

**Loading Order**:
1. `/campaigns/q4-2024/holiday-voice.md` (addendum first)
2. Default hierarchy (corporate brand + project styles)

### Scenario 4: Product Launch Override
**Setup**:
```bash
export HOUSE_STYLE_MARKETING="/product-launches/ai-assistant/launch-voice.md"
export HOUSE_STYLE_MARKETING_ADDENDUM="/product-launches/ai-assistant/beta-messaging.md"
```

**Contents of `/product-launches/ai-assistant/launch-voice.md`**:
```markdown
# AI Assistant Product Launch Voice

## Product Positioning
- Emphasize time-saving benefits
- Position as "smart automation"
- Avoid technical AI jargon
- Focus on practical use cases

## Key Messages
- "Get 2 hours back every day"
- "Works seamlessly with your workflow"
- "No AI expertise required"

+load-default-styles
```

**Contents of `/product-launches/ai-assistant/beta-messaging.md`**:
```markdown
# Beta Launch Specific Messaging

## Beta Program Benefits
- "Be among the first to experience..."
- "Shape the future of the product"
- "Exclusive early access"
- "Direct line to product team"

## Risk Mitigation
- "Full support during beta"
- "Continuous improvements"
- "Priority feedback incorporation"
```

**Loading Order**:
1. `/product-launches/ai-assistant/beta-messaging.md` (addendum)
2. `/product-launches/ai-assistant/launch-voice.md` (primary)
3. Default hierarchy continues...

## Style File Examples

### Corporate Brand Voice (`.claude/npl-m/house-style/marketing-style.md`)
```markdown
# Corporate Marketing Brand Voice

## Brand Personality
- **Professional**: Credible and trustworthy
- **Innovative**: Forward-thinking and modern
- **Customer-Centric**: Always focused on customer success
- **Results-Driven**: Emphasizes outcomes and ROI

## Voice Guidelines
- Use active voice and strong verbs
- Lead with benefits, support with features
- Include specific metrics and outcomes
- Address pain points directly

## Tone by Channel
- **Website**: Confident and informative
- **Email**: Personal and helpful
- **Social**: Engaging and conversational
- **Press**: Authoritative and newsworthy

## Language Standards
- Use "we" and "our" to show partnership
- Say "helps you achieve" not "allows you to"
- Include specific timeframes ("in 30 days")
- Quantify benefits ("save 40%", "reduce by half")

+load-default-styles
```

### Campaign-Specific Style (`marketing/campaigns/house-style/marketing-style.md`)
```markdown
# Campaign Marketing Guidelines

## Campaign Voice Adaptations
- More urgency-focused than general brand voice
- Emphasize limited-time benefits
- Include social proof and FOMO elements
- Stronger calls-to-action

## Campaign Language
- "Limited time offer"
- "Exclusive access"
- "Join [number]+ customers"
- "Don't miss out"

## Offer Presentation
- Lead with discount percentage
- Include original price for context
- Clear expiration dates
- Multiple CTAs throughout content

+load-default-styles
```

### Product-Specific Style (`products/enterprise/house-style/marketing-style.md`)
```markdown
# Enterprise Product Marketing Style

## Enterprise Voice Characteristics
- More formal and business-focused
- Emphasize security and compliance
- Include enterprise-specific benefits
- Address procurement concerns

## Enterprise Language
- "Enterprise-grade security"
- "Scalable architecture" 
- "Compliance-ready"
- "Dedicated support"

## B2B Specific Elements
- Include ROI calculators
- Mention integration capabilities
- Address IT department concerns
- Provide implementation timelines

+load-default-styles
```

## Content Type Integrations

### Landing Page Generation
```bash
# Campaign-specific landing page
export HOUSE_STYLE_MARKETING="/campaigns/webinar-series/landing-voice.md"
@npl-marketing-writer generate landing-page --product="Webinar Series" --audience="marketing professionals"

# Results in landing page with:
# - Campaign-specific voice from environment
# - Corporate brand voice from hierarchy
# - General marketing best practices from templates
```

### Email Campaign Creation
```bash
# Product announcement email
export HOUSE_STYLE_MARKETING_ADDENDUM="/announcements/new-feature/email-tone.md"
@npl-marketing-writer generate email --type="announcement" --subject="New Feature Launch"

# Results in email with:
# - Feature-specific messaging additions
# - Corporate email voice guidelines
# - Standard email best practices
```

### Product Description Writing
```bash
# E-commerce product description
cd /products/consumer-electronics/
@npl-marketing-writer generate product-desc --item="wireless-earbuds"

# Automatically loads:
# - /products/house-style/marketing-style.md (product category style)
# - /products/consumer-electronics/house-style/marketing-style.md (specific category)
# - Corporate and personal styles from hierarchy
```

## Agent Implementation Integration

### Required Context Loading
```markdown
# After NPL pump loading, before agent definition:

load .claude/npl/pumps/npl-mood.md into context.
{{if content_type}}
load .claude/npl/templates/marketing/{{content_type}}.md into context.
{{/if}}

# House Style Context Loading
[Insert complete house style loading block]

---
⌜npl-marketing-writer|writer|NPL@1.0⌝
```

### Mood Integration with House Styles
```markdown
### Content Mood (`npl-mood`)
<npl-mood>
mood:
  emotional_tone: [determined by house style hierarchy]
  energy_level: [adjusted for campaign/product context]
  persuasion_style: [corporate brand + campaign additions]
  brand_personality: [from primary brand voice guidelines]
</npl-mood>
```

## Advanced Usage Patterns

### Multi-Brand Management
```bash
# Switch between brand voices for agency work
export HOUSE_STYLE_MARKETING="/clients/brand-a/voice.md"
@npl-marketing-writer generate landing-page --product="software"

export HOUSE_STYLE_MARKETING="/clients/brand-b/voice.md"  
@npl-marketing-writer generate landing-page --product="software"
# Same product, different brand voice
```

### A/B Testing Voice Variations
```bash
# Version A: Conservative voice
export HOUSE_STYLE_MARKETING="/tests/conservative-voice.md"
@npl-marketing-writer generate ad-copy --audience="enterprise" > version-a.md

# Version B: Bold voice  
export HOUSE_STYLE_MARKETING="/tests/bold-voice.md"
@npl-marketing-writer generate ad-copy --audience="enterprise" > version-b.md
```

### Seasonal Voice Adaptations
```bash
# Holiday season addendum
export HOUSE_STYLE_MARKETING_ADDENDUM="/seasonal/holiday-2024.md"
@npl-marketing-writer generate newsletter --theme="year-end-offers"

# Back-to-school season
export HOUSE_STYLE_MARKETING_ADDENDUM="/seasonal/back-to-school.md"
@npl-marketing-writer generate campaign --audience="students"
```

This integration pattern enables sophisticated brand voice management while maintaining the conversion-focused capabilities of marketing writer agents.