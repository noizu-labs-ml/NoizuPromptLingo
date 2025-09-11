# Marketing Writing Style Guide

This is a template for marketing writing style guides used by NPL marketing writer agents.

## Brand Voice and Personality

### Core Voice Attributes
- **Authentic**: Genuine and honest in all communications
- **Engaging**: Captures attention and maintains interest
- **Professional**: Credible and trustworthy
- **Customer-focused**: Always addresses audience needs and desires

### Tone Variations by Context
- **Website copy**: Confident and informative
- **Email campaigns**: Personal and conversational
- **Social media**: Friendly and approachable
- **Press releases**: Authoritative and newsworthy
- **Product descriptions**: Benefit-focused and compelling

## Writing Principles

### Emotional Connection
- **Lead with benefits**: Focus on what customers gain, not just features
- **Address pain points**: Acknowledge and empathize with customer challenges
- **Tell stories**: Use narratives to make content memorable
- **Build trust**: Include social proof, testimonials, and credentials

### Persuasive Language
- **Power words**: Transform, discover, exclusive, proven, guaranteed
- **Action verbs**: Boost, accelerate, streamline, optimize, deliver
- **Sensory language**: Smooth, crisp, vibrant, rich, powerful
- **Urgency creators**: Limited time, while supplies last, don't miss out

### Audience Focus
- **Customer-centric**: Write in second person ("you" and "your")
- **Benefit-driven**: Answer "What's in it for me?"
- **Clear value proposition**: Make benefits obvious within 5 seconds
- **Objection handling**: Address common concerns proactively

## Content Structure

### Headline Formulas
- **Problem + Solution**: "Stop [Pain Point]: [Solution] That [Benefit]"
- **How-to + Benefit**: "How to [Achieve Goal] in [Timeframe]"
- **Number + Benefit**: "[Number] Ways to [Desired Outcome]"
- **Question + Answer**: "Looking for [Need]? Here's [Solution]"

### Body Copy Framework
1. **Hook**: Grab attention with relatable problem or surprising fact
2. **Problem**: Agitate the pain point they're experiencing
3. **Solution**: Introduce your offering as the answer
4. **Benefits**: Explain what they'll gain (not just features)
5. **Proof**: Provide testimonials, stats, or case studies
6. **Call-to-Action**: Clear next step with compelling reason to act now

### Landing Page Structure
```
Hero Section:
- Compelling headline
- Clear value proposition
- Hero image/video
- Primary CTA button

Problem Section:
- Empathetic pain point description
- Relatable scenarios
- Cost of inaction

Solution Section:
- Product/service introduction
- Key benefits highlighted
- How it works (simple steps)

Social Proof:
- Customer testimonials
- Usage statistics
- Company logos/case studies

Call-to-Action:
- Clear, benefit-focused CTA
- Risk reversal (guarantee/trial)
- Urgency or scarcity element
```

## Language Guidelines

### Power Words and Phrases
**Achievement**: Accomplish, achieve, attain, master, succeed
**Improvement**: Boost, enhance, optimize, upgrade, transform
**Ease**: Effortless, simple, streamlined, automated, instant
**Exclusivity**: Exclusive, limited, premium, select, insider
**Safety**: Guaranteed, secure, protected, safe, risk-free

### Emotional Triggers
- **Fear of missing out**: Limited availability, deadline approaching
- **Desire for status**: Premium, exclusive, professional-grade
- **Need for security**: Guaranteed, protected, reliable, proven
- **Want for convenience**: Instant, automatic, effortless, simple
- **Aspiration**: Transform, elevate, advance, breakthrough

### Avoid These Patterns
- ❌ Generic superlatives ("amazing," "incredible," "revolutionary")
- ❌ Overused clichés ("game-changer," "cutting-edge," "next-level")
- ❌ Obvious statements ("high-quality," "user-friendly")
- ❌ Weak qualifiers ("perhaps," "maybe," "might be")
- ❌ Industry jargon without explanation

### Use These Instead
- ✅ Specific benefits with numbers/outcomes
- ✅ Customer-focused language ("you save 2 hours daily")
- ✅ Action-oriented verbs
- ✅ Concrete examples and scenarios
- ✅ Social proof and testimonials

## Call-to-Action Guidelines

### CTA Button Text
**Action-oriented**:
- "Get Started Now"
- "Claim Your Discount"
- "Download Your Guide"
- "Book Your Demo"
- "Start Your Trial"

**Benefit-focused**:
- "Save 40% Today"
- "Get Instant Access"
- "See Results in 30 Days"
- "Join 10,000+ Users"
- "Unlock Premium Features"

### CTA Placement
- Above the fold (visible without scrolling)
- After benefit descriptions
- Following social proof sections
- At the end of long-form content
- Multiple strategic locations for long pages

## Conversion Optimization

### A/B Testing Elements
- Headlines and subheadlines
- CTA button text and colors
- Value proposition statements
- Social proof placement
- Form field requirements

### Trust Signals
- Customer testimonials with photos/names
- Company logos and case studies
- Security badges and certifications
- Money-back guarantees
- Contact information and support options

### Urgency and Scarcity
**Appropriate urgency**:
- Time-limited offers with real deadlines
- Stock availability (if genuinely limited)
- Enrollment periods for courses/programs
- Early bird pricing with clear end dates

**Avoid false urgency**:
- Fake countdown timers
- "Only 3 left" without real inventory limits
- Constant "limited time" offers
- Misleading scarcity claims

## Brand Consistency

### Voice Consistency Checklist
- [ ] Matches established brand personality
- [ ] Appropriate tone for channel and audience
- [ ] Consistent terminology and messaging
- [ ] Aligned with company values
- [ ] Reflects target customer language

### Message Hierarchy
1. **Primary message**: Core value proposition
2. **Supporting messages**: Key benefits and differentiators
3. **Proof points**: Testimonials, stats, case studies
4. **Call-to-action**: Clear next step

## Content Types

### Product Descriptions
- Lead with primary benefit
- Include 3-5 key features with benefit explanations
- Add social proof (ratings, reviews)
- End with compelling CTA
- Use sensory and emotional language

### Email Campaigns
- Subject line: Benefit-focused, under 50 characters
- Opening: Personal greeting, immediate value
- Body: Single focused message, scannable format
- CTA: Clear, benefit-oriented, repeated 2-3 times
- P.S.: Restate key benefit or add urgency

### Landing Pages
- Single focused objective
- Clear value proposition above fold
- Progressive information disclosure
- Multiple trust signals throughout
- Strong, prominent CTAs

---

# Style Control Flag
+load-default-styles

## Usage Notes

This template can be customized for specific brands, campaigns, or market segments while maintaining compatibility with NPL marketing writer agents. The `+load-default-styles` flag above ensures that additional style guides in the hierarchy will also be loaded.

### Customization Areas
- Adjust brand voice and personality
- Add industry-specific language guidelines
- Include campaign-specific messaging rules
- Define approval and review processes

### Integration with NPL Agents
This style guide is automatically loaded by `npl-marketing-writer` agents when placed in the appropriate directory hierarchy:

- `~/.claude/npl-m/house-style/marketing-style.md` (personal/global)
- `.claude/npl-m/house-style/marketing-style.md` (project-wide)
- `{path}/house-style/marketing-style.md` (directory-specific)

Environment variable override:
```bash
export HOUSE_STYLE_MARKETING="/path/to/custom-brand-style.md"
```

### Campaign-Specific Extensions
For campaigns requiring additional guidelines:
```bash
export HOUSE_STYLE_MARKETING_ADDENDUM="/path/to/campaign-rules.md"
```