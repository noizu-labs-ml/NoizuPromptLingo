# Trigger Language Patterns

How to write the `description` field in SKILL.md YAML frontmatter so agents and routing systems reliably invoke the right skill.

---

## The Formula

A well-formed trigger description has four clauses:

```
[WHAT the skill does] — [WHEN to use it].
Use this skill when [explicit scenarios].
Also trigger when [implicit/oblique requests] — even if they don't say "[core term]."
Also trigger when users mention [keyword list].
```

Each clause serves a distinct function:

| Clause             | Function                                            | Controls    |
|--------------------|-----------------------------------------------------|-------------|
| WHAT               | Names the capability                                | Precision   |
| WHEN (explicit)    | Lists direct invocation scenarios                   | Recall (high confidence) |
| even if they don't say | Catches oblique requests that avoid core terms | Recall (low confidence) |
| Also trigger when  | Keyword anchors for specific platform/tool mentions | Recall (tail) |

---

## Dissecting Real Trigger Descriptions

### Example 1: trl-ai-templates

```yaml
description: >
  Build, launch, and scale AI-powered digital products including prompt libraries,
  automation workflows, GPT configurations, and MCP server packages. Use this skill
  when the user wants to create sellable AI templates, package prompts for sale,
  build automation products, develop ChatGPT/Claude tool bundles, optimize template
  listings, or monetize technical expertise through digital products — even if they
  don't say "AI templates." Also trigger when users mention Gumroad products,
  prompt engineering for sale, or digital product launches.
```

**Clause breakdown:**

- **WHAT:** "Build, launch, and scale AI-powered digital products including prompt libraries, automation workflows, GPT configurations, and MCP server packages"
  - Enumerates specific product types rather than staying abstract. This gives the router concrete anchors.

- **WHEN (explicit):** "create sellable AI templates, package prompts for sale, build automation products, develop ChatGPT/Claude tool bundles, optimize template listings, or monetize technical expertise"
  - Six explicit use cases. Covers both creation and optimization. Includes the monetization frame explicitly.

- **even if they don't say:** "even if they don't say 'AI templates'"
  - Guards against users who want the capability but use different vocabulary (e.g., "I want to sell prompts").

- **Also trigger when:** "Gumroad products, prompt engineering for sale, or digital product launches"
  - Platform-specific and activity-specific keywords. Someone mentioning Gumroad is likely in the AI templates use case even if they haven't said so.

---

### Example 2: trl-user-experience-engineer

```yaml
description: >
  Design and implement production-ready user interfaces from brief through
  implementation across web, terminal, and specification formats. Use this skill
  when the user wants to design a web app, create a landing page, build UI
  components, select a visual style, wireframe an interface, run an accessibility
  audit, generate Next.js or HTML/CSS code from designs, create SVG mockups,
  create SVG logos, prototype with p5.js, design terminal UIs, run a market
  validation sprint, evaluate design quality, or hand off specifications to
  developers — even if they don't say "UX" or "design." Also trigger when users
  mention wireframes, mockups, style guides, design systems, conversion
  optimization, WCAG compliance, responsive design, component libraries, design
  sprints, Figma specs, logos, brand marks, logomarks, logotypes, or landing page
  optimization.
```

**Clause breakdown:**

- **WHAT:** "Design and implement production-ready user interfaces from brief through implementation across web, terminal, and specification formats"
  - Establishes scope (brief through implementation) and output diversity (web, terminal, spec formats).

- **WHEN (explicit):** Fifteen distinct scenarios, covering the full range from "design a web app" to "hand off specifications to developers"
  - Long list because the skill has a wide surface area. Each item is a distinct user goal.

- **even if they don't say:** "even if they don't say 'UX' or 'design'"
  - Critical — users requesting "a logo" or "a landing page" often don't use UX vocabulary.

- **Also trigger when:** Fifteen keywords spanning tools (Figma), standards (WCAG), deliverables (wireframes, mockups), and terminology (logomarks, logotypes)
  - Keyword breadth compensates for the skill's wide surface area. Specific terms like "logotype" catch expert users who use precise vocabulary.

---

### Example 3: trl-monetization-strategy

```yaml
description: >
  Strategic decision framework for choosing and planning passive income streams.
  Use this skill whenever someone is deciding between business models, comparing
  income streams, asking "what should I build first," planning a side hustle,
  evaluating passive income options, or figuring out which skills to monetize.
  Also trigger when users mention revenue goals, time constraints for building
  products, risk tolerance for new ventures, or want a roadmap for their first
  online product — even if they don't use the word "monetization."
```

**Clause breakdown:**

- **WHAT:** "Strategic decision framework for choosing and planning passive income streams"
  - Positions as advisory/decision-making, not execution. Sets expectations correctly.

- **WHEN (explicit):** Six decision-making scenarios. Note "asking 'what should I build first'" — a quoted phrasing that matches natural language exactly.

- **Also trigger when:** Revenue goals, time constraints, risk tolerance — these are signals that appear in the context of a decision even when the user hasn't framed it as monetization strategy yet.

- **even if they don't say:** Placed at the end here, covering "monetization" as the invisible core term.

---

## Common Mistakes

### Too Vague

```yaml
# Bad — matches everything
description: Help users with their digital products and business goals.
```

No specificity. Any business-adjacent request could match. The router can't discriminate.

### Too Specific

```yaml
# Bad — misses oblique requests
description: Use when the user explicitly says they want to audit their SEO
  and optimize their meta tags for Google search rankings.
```

Requires the user to use the exact right words. Someone asking "why isn't my site showing up on Google" won't match.

### Too Long / Noisy

```yaml
# Bad — description becomes a wall of text that obscures the signal
description: >
  This is a comprehensive skill for all types of digital product creation, marketing,
  business strategy, technical implementation, design work, content creation,
  SEO optimization, conversion rate optimization, email marketing, social media
  strategy, and general entrepreneurship guidance for anyone building a business...
```

Keyword stuffing. Everything matches, so nothing matches reliably. Dilutes the signal for the router.

---

## Precision vs. Recall Tradeoff

| Setting   | Behavior                        | Risk                             |
|-----------|---------------------------------|----------------------------------|
| High precision | Only triggers on close matches | Misses oblique requests          |
| High recall   | Triggers on many signals       | False positives, wrong skill invoked |

**Target:** High recall on genuine use cases, high precision against adjacent skills.

Test your trigger by asking: "Would someone asking [scenario] benefit from this skill or a different one?" If the answer is "a different one," don't add that scenario to the trigger.

---

## The "Even If They Don't Say" Clause

This clause handles vocabulary mismatch — when the user wants the capability but doesn't know the canonical term.

**Identify candidates for this clause by asking:**
- What would a non-expert call this?
- What task would someone be doing that requires this skill, without knowing it's a "skill"?
- What is the invisible core term that experts use but users often don't?

**Examples:**
- UXE: users say "make it look good" not "UX design"
- AI Templates: users say "I want to sell this prompt" not "AI template product"
- SEO Guru: users say "help my site rank" not "GEO/AEO optimization"

---

## The "Also Trigger When" Clause

Keyword anchors for tail cases. These are:
- Platform names (Gumroad, Figma, Substack, Redbubble)
- Tool names (Zapier, Make, n8n)
- Standards (WCAG, schema markup, robots.txt)
- Jargon terms used by experts (logotype, GEO, AEO, llms.txt)
- Activity phrases (digital product launches, niche research)

**Rule:** Only add a keyword if a user mentioning it is a genuine signal for this skill and not equally a signal for another skill.

---

## Testing Protocol

Before finalizing a trigger description, generate these ten test scenarios:

### Should Match (5)

Write five realistic user messages that should invoke this skill. Verify each matches at least one clause in your trigger description. Include at least:
- One that uses core vocabulary
- One that uses oblique vocabulary (tests "even if they don't say")
- One that uses a keyword from the "Also trigger when" clause
- One that describes a symptom rather than a solution ("my X isn't working")
- One that uses a platform name or tool name

### Should NOT Match (5)

Write five realistic user messages that should NOT invoke this skill, but that are topically adjacent. Verify none of your trigger clauses would match them. Include at least:
- One request for an adjacent skill (e.g., for SEO Guru: an trl-ai-templates request)
- One generic request that sounds relevant but isn't ("I want to make money online")
- One request that uses a keyword from your trigger but in a different context
- Two requests from a completely different domain

If any should-NOT-match scenario triggers your description, tighten the specific clause that caused the false positive.

---

## Good vs. Bad Trigger Language: Three Pairs

### Pair 1: Specificity

```yaml
# Bad
description: Use when users want to create content.

# Good
description: >
  Build authority and recurring revenue through technical writing, newsletters,
  tutorials, and educational content. Use this skill when the user wants to start
  a newsletter, write technical articles, build a subscriber base, monetize
  writing, plan a content calendar, or develop a content strategy — even if they
  don't say "content publishing." Also trigger when users mention Substack,
  Dev.to, Medium, blogging for income, or building an audience through writing.
```

### Pair 2: Oblique Coverage

```yaml
# Bad — misses the implicit case
description: >
  Use when the user asks about SEO or wants to optimize their search rankings.

# Good — covers the implicit case
description: >
  Audit and optimize content for search engines and AI answer engines.
  Use this skill when the user wants to improve visibility, get cited by AI tools,
  fix technical SEO issues, or understand why their content isn't ranking —
  even if they don't say "SEO." Also trigger when users mention robots.txt,
  llms.txt, schema markup, or AI Overviews.
```

### Pair 3: Scope Boundaries

```yaml
# Bad — scope too broad, competes with adjacent skills
description: >
  Help users design and build products. Use when anyone asks about
  product design, development, or launch — even for physical products.

# Good — scope clearly bounded
description: >
  Design and implement production-ready user interfaces. Use when the user
  wants to design a web app, landing page, or UI component — even if they
  don't say "design." Does not cover backend implementation, product strategy,
  or physical product design.
```
