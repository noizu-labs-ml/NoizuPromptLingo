# Style Guide Construction

> Step-by-step methodology for building a client-specific style guide from the five design system specifications. Covers pure styles and mixed (80/20) ratios.

This document covers the *construction process* — mechanically deriving a complete style guide from a chosen style spec. For the *discovery process* (figuring out which style to choose), see [core-philosophy.md Section 5](../core-philosophy.md#5-style-guide-development).

---

## Table of Contents

- [1. Overview](#1-overview)
- [2. Prerequisites](#2-prerequisites)
- [3. Pure Style Construction](#3-pure-style-construction)
- [4. Mixed Style Construction](#4-mixed-style-construction)
- [5. Output Template](#5-output-template)
- [6. Worked Examples](#6-worked-examples)

---

## 1. Overview

### When to Use This Process

Use this after the discovery phase is complete — you know:
- Who the audience is
- What signals the brand needs to send
- Which style system (or mix) fits

### Inputs Required

| Input | Source |
|-------|--------|
| Completed design brief | [process/brief-interpretation.md](brief-interpretation.md) |
| Style selection | [SKILL.md Style Selector table](../../SKILL.md) |
| Brand positioning | [core-philosophy.md Section 5.1](../core-philosophy.md) |
| Existing brand assets (if any) | Client-provided (logo, colors, fonts) |

### Output

A complete applied style guide document following the [Output Template](#5-output-template) format — ready to hand off for implementation.

---

## 2. Prerequisites

Before construction, confirm:

- [ ] Design brief completed and approved
- [ ] Style system selected (pure or mixed, with ratio)
- [ ] Brand positioning established (3-5 personality adjectives)
- [ ] Target audience defined
- [ ] Reference/anti-reference sites identified
- [ ] Existing brand assets collected (or confirmed none exist)

---

## 3. Pure Style Construction

Follow these steps sequentially. Steps 1–4 build the **foundation** (sections 00–04). Steps 5–8 build **components** (sections 05–12) — these can be parallelized. Steps 9–11 cover **cross-cutting concerns** and validation. Each step produces a numbered section of the final style guide matching the HTML template.

### Step 1: Header & Brand Identity (§00)

Write the design philosophy and brand identity sections:

1. **State what this guide is for** — which product, sub-brand, or initiative
2. **Define what signals need to be sent** — map the brand's personality adjectives to the style system's positioning section
3. **Explain why this style was selected** — reference the style spec's "Best Use Cases" and confirm alignment
4. **Write "What this IS" and "What this IS NOT"** — concrete, opinionated statements that prevent design drift
5. **List 3-5 design principles** — ranked, each with a one-line expansion
6. **Brand identity block** — intent, perception, audience, tone, keywords
7. **Logo usage rules** (if logo exists)

**Decision point:** If the brand's adjectives conflict with the style system's signals, reconsider the style selection before proceeding.

**Output:** Design philosophy + brand identity — maps to `StyleGuideStyleCard` + `StyleGuideProductBranding` in HTML.

### Step 2: Design Tokens (§01)

Write the complete CSS custom properties block. This is the **single source of truth** — every other section references these values.

**Process:**
1. Read the spec's palette structure diagram (the ASCII box in each style file)
2. Organize tokens by category: surfaces, text hierarchy, borders, accents, semantic colors, shadows, spacing, radii, transitions, typography
3. For **background and text**: adopt the spec's defaults unless brand guidelines override
4. For **accent color**: choose one that aligns with brand identity AND fits the spec's accent rules
5. For **semantic colors**: inherit the spec's defaults (success/warning/error/info)
6. Include ALL tokens — spacing, radii, durations, easings — not just colors

**Decision tree for accent color:**
```
Does the brand have an existing accent color?
├── Yes → Does it fit the style spec's accent constraints?
│   ├── Yes → Use it
│   └── No → Adjust hue/saturation to fit, document deviation
└── No → Choose from the spec's accent options based on brand personality
```

**Output:** Complete CSS custom properties block, organized by category — maps to `StyleGuideTokenCard` components in HTML.

### Step 3: Color Palette (§02)

Expand the color tokens into a full palette reference with usage rules and accessibility verification.

**Process:**
1. List every color with its name, hex value, and intended use
2. Build ASCII palette diagram showing relationships
3. Define **usage rules** specific to this application (e.g., "accent appears only on primary CTAs and active sidebar items")
4. Build **contrast verification table**: foreground | background | ratio | WCAG AA | status
5. Test all text-on-background combinations at their actual use sizes

**Output:** Palette visualization + usage rules + contrast table — maps to `StyleGuideColorGrid` + `StyleGuideNotesList` in HTML.

### Step 4: Typography (§03)

Select fonts from the style spec's recommendations. Adjust scale to content needs.

> For the foundational principles behind typeface selection — why serif vs sans-serif,
> how x-height affects readability, classification systems, and font pairing methodology
> — see [typography.md](../typography.md).

**Process:**
1. Review the spec's font recommendations
2. Select primary font (and secondary if the spec allows two families)
3. If brand has an existing typeface, check compatibility with spec constraints (e.g., Minimal Tech requires geometric sans-serif — a script font won't work)
4. Adopt the spec's type scale as baseline
5. Adjust for content density: data-heavy interfaces may need tighter scale; editorial may need looser
6. **Document font sources** with licensing and links. For each font in the stack:
   - Provide the primary source link (Adobe Fonts preferred if available, then Google Fonts / Fontshare / foundry site)
   - Note the license type (OFL, paid commercial, etc.)
   - If the primary font is paid/premium, provide an Adobe Fonts alternative and a free open-source alternative
   - Include fallback system fonts in the CSS declaration

**Common font source hierarchy:**
1. **Adobe Fonts** — preferred if the team has Creative Cloud (syncs automatically, no hosting)
2. **Google Fonts** — free, self-hostable, widest selection of open-source fonts
3. **Fontshare** — free commercial-use fonts from Indian Type Foundry
4. **Foundry direct** — for premium fonts (Klim, Pangram Pangram, Commercial Type, etc.)

**Output:** Font stack declarations + type scale table + font source table with links — maps to `StyleGuideTypeSpecimen` in HTML.

### Step 5: Spacing & Layout (§04)

**Process:**
1. Inherit the style spec's base unit and spacing scale (these rarely need customization)
2. Build component spacing table: component | padding | gap | notes
3. Adopt the spec's grid system breakpoints
4. Adjust max-width if content type demands it (e.g., editorial content needs narrower max-width for readability)
5. Document product-specific layout patterns (e.g., "Task Board is single-column with sticky filter bar")
6. Document any deviations from the spec's defaults

**Output:** Spacing scale + component spacing + grid specification + layout patterns — maps to `StyleGuideSpacingScale` + `StyleGuideSpecTable` + `StyleGuidePrinciples` in HTML.

### Step 6: Buttons (§05) + Input Fields (§06)

Apply the color, typography, and spacing decisions to interactive controls.

**Buttons (§05):**
1. Define all button variants: primary, secondary, ghost, destructive, + any product-specific (e.g., tournament enter)
2. All states: default, hover, focus, active, disabled
3. Size variants: sm, md, lg
4. Write button usage rules

**Input Fields (§06):**
1. Define styles for: text input, textarea, select, checkbox, radio
2. All states: default, hover, focus, error, disabled
3. Labels, helper text, error message styling
4. Write input usage rules

**Process:**
1. Start with the spec's component CSS snippets
2. Substitute your derived color tokens
3. Substitute your chosen fonts
4. Verify border-radius follows the spec's conventions
5. Check all interactive states exist

**Output:** CSS snippets for buttons and inputs as separate sections — maps to `StyleGuideBtn`/`StyleGuideButtonRow` and `StyleGuideInputGroup`/`StyleGuideInputField` in HTML.

### Step 7: Navigation (§07) + Status Indicators (§08) + Cards (§09)

**Navigation (§07):**
1. Define navigation patterns the product uses: tabs, breadcrumbs, sidebar, mobile nav, progress steppers
2. CSS snippets for each pattern
3. Responsive behavior notes
4. If not applicable, write a one-line stub: "Not applicable — [reason]"

**Status Indicators (§08):**
1. Define status states: active, complete, error, warning, pending, disabled
2. CSS snippets for each state (shape, color, animation)
3. When to use which state
4. If not applicable, write a one-line stub

**Cards (§09):**
1. Define card variants with CSS snippets
2. Card anatomy: title, body, tags, actions
3. Grid/layout behavior for card collections

**Output:** Three separate sections — maps to `StyleGuidePhaseTabs`/`StyleGuideStepProgress`, `StyleGuideStatusGrid`/`StyleGuideStatusIndicator`, and `StyleGuideCard`/`StyleGuideCardGrid` in HTML.

### Step 8: Core Components (§10) + Project Components (§11) + Screens (§12)

**Core Components (§10):**
1. List which Headless UI primitives this product uses: Menu, Dialog, Disclosure, Switch, Tabs, etc.
2. CSS snippets or descriptions for each included primitive
3. Only include what's relevant — not every product needs all 16
4. If not applicable, write a one-line stub

**Project Components (§11):**
1. Composite widgets unique to this product (e.g., Agent Chassis Card, Tournament Bracket)
2. Description + CSS for each
3. Full-page composites (dashboards, multi-panel layouts)
4. If not applicable, write a one-line stub: "To be defined as product takes shape"

**Screens (§12):**
1. Describe key screens: what they show, how they compose components from §05–§11
2. Use realistic content — these tell the product's story
3. At least: primary screen, secondary screen, empty/error state
4. For each screen, include:
   - **Scroll & motion effects** — parallax layers, scroll-triggered reveals, sticky headers, infinite scroll, scroll-snap sections. Describe what moves, at what rate, and the fallback for `prefers-reduced-motion`
   - **Stock art / image descriptions** — for each placeholder image, write a search-ready description suitable for stock photo search or AI image generation (e.g., "Overhead view of a circuit board with blue LED traces, dark background, shallow depth of field, 16:9 landscape")
5. If not applicable, write a one-line stub

**Output:** Three separate sections — maps to `StyleGuideWidgetDemo` and `StyleGuideScreenFrame` in HTML.

### Step 9: Interaction & Motion

**Process:**
1. Inherit the spec's animation philosophy (duration ranges, easing curves)
2. Map specific interactions to components: what happens on hover? On click? On load?
3. **Scroll effects** — document any parallax, scroll-triggered animations, scroll-snap, sticky positioning, or reveal-on-scroll behavior. For each effect specify: trigger point, animation, duration, and `prefers-reduced-motion` fallback
4. **Page-level transitions** — how do pages/views enter and exit?
5. Ensure `prefers-reduced-motion` is respected for ALL motion
6. Define one "signature" interaction if the brand warrants it (most don't — restraint)

**Output:** Interaction specification table + scroll/parallax spec.

### Step 10: Asset Guidelines

**Process:**
1. Define **photography style** — for each image context in the product, write a search-ready description:
   - Subject, mood, lighting, composition, aspect ratio
   - Format as stock photo search queries (e.g., "diverse team collaborating at whiteboard, natural light, warm tones, 3:2")
   - Also format as AI generation prompts if applicable (e.g., "isometric illustration of a robotic arm assembling circuits, flat design, cyan and orange palette, white background")
2. Define **iconography conventions** — style, stroke weight, size, source library
3. Define **illustration approach** (if applicable)
4. Document **logo usage rules** (if not covered in §00)

**Output:** Asset guidelines with search-ready image descriptions.

### Step 11: Validation Checklist

**Process:**
1. Run through the source style spec's implementation checklist
2. Cross-reference [core-philosophy.md quality defaults](../core-philosophy.md#6-quality-defaults)
3. Verify accessibility baselines: contrast ratios, touch targets, keyboard nav
4. Confirm internal consistency: do all components use the same tokens?
5. Verify all 13 sections (§00–§12) are present, even if stubbed

**Output:** Completed checklist confirming the guide is self-consistent and meets baselines.

---

## 4. Mixed Style Construction

### 4.1 The Mixing Principle

When mixing styles at an 80/20 ratio:
- The **dominant style (80%)** controls the overall system: structure, primary palette, body typography, spacing, interaction philosophy
- The **accent style (20%)** influences a small number of specific elements that add character without undermining the dominant system

**The rule of 3-5:** A mixed guide should have exactly 3-5 elements influenced by the 20% style. Fewer feels imperceptible; more creates incoherence.

### 4.2 The Mixing Decision Matrix

Use this to decide what each percentage controls:

| Design Element | 80% Style Controls | 20% Style Influences |
|---|---|---|
| **Color palette** | Primary, background, text, semantic | Accent color or hover state color |
| **Typography** | Body font, type scale, line heights | Display/headline font OR pull quote styling |
| **Spacing** | Base unit, scale, grid, breakpoints | — (never mix spacing systems) |
| **Border radii** | Primary radius scale | — (never mix radius systems) |
| **Buttons** | Shape, padding, sizing, states | Hover effect style OR micro-interaction |
| **Cards** | Structure, padding, layout | Border treatment OR shadow style |
| **Navigation** | Layout, structure, breakpoints | Visual treatment (e.g., type style) |
| **Animation** | Duration range, easing, philosophy | One signature interaction |
| **Imagery** | Primary style (photo/illustration) | Accent treatment on featured images |

**Never mix:** Spacing systems, grid systems, border radius scales. These are structural — mixing them creates visual incoherence.

### 4.3 Step-by-Step Mixing Process

1. **Build the full guide using the 80% style** — complete Steps 1-8 from Section 3
2. **Identify 3-5 accent elements** — consult the matrix above; choose elements where the 20% style adds value without disrupting structure
3. **For each accent element:**
   - Read the corresponding section of the 20% style spec
   - Derive the accent value within the 20% spec's constraints
   - Substitute it into the guide
   - Document WHY this element was chosen for accent treatment
4. **Verify compatibility:**
   - Do the accent elements create conflicting visual signals?
   - Does the mix appear in SKILL.md's "Risky" combinations list?
   - Would a user perceive this as intentional or as a mistake?
5. **Write the Mixing Notes section** — explicitly list what carries the 20% and why

### 4.4 Compatibility Verification

Check your mix against SKILL.md's compatibility guidance:

| Pairing | Status | Risk |
|---------|--------|------|
| Minimal Tech + Editorial | Compatible | Low — typography enriches austerity |
| Corporate + Minimal Tech | Compatible | Low — tech polish modernizes |
| Playful + Editorial | Compatible | Low — content + warmth |
| Bold Expressive + Corporate | Risky | High — conflicting trust signals |
| Playful + Dense Data | Risky | High — cognitive overload |

**If your mix is unlisted:** It's novel, not forbidden. Proceed with extra scrutiny at step 4.

**If your mix is risky:** Consider reducing the accent to 10%, or limit it to a single element instead of 3-5.

---

## 5. Output Template

Every completed style guide should follow this canonical structure. Sections are numbered to match the HTML style guide template (`styleguide-template.html`), ensuring the markdown source and the HTML view stay in sync. The markdown is the **source of truth** — it must be at least as complete as the HTML it generates.

Sections marked *(stub if not applicable)* may be a single line noting "Not applicable — [reason]" or "See [Component Styling](#component-styling) for [topic]." They must still appear as headings so the HTML conversion has a 1:1 mapping.

```markdown
# Style Guide: [Company] — [Product/Initiative Name]

> [One-line description of the visual approach]

**Style System:** [Pure: style-name] or [Mix: primary-80% + accent-20%]
**Source Spec(s):** [link(s) to reference style spec(s)]
**Scenario:** [Brief context for this guide's application]

---

## 00 — Header & Brand Identity
[Design philosophy: what this style IS, what it IS NOT, 3-5 design principles]
[Brand identity: intent, perception, audience, tone, keywords]
[Logo usage rules (if logo exists)]
<!-- HTML: StyleGuideStyleCard + StyleGuideProductBranding -->
<!-- See: styleguide-sections/00-header-branding.md -->

## 01 — Design Tokens
[Complete CSS custom properties block — this is the single source of truth]
[Organized by category: surfaces, text, borders, accents, semantic, shadows, spacing, radii, transitions]
<!-- HTML: StyleGuideTokenCard components -->
<!-- See: styleguide-sections/01-design-tokens.md -->

## 02 — Color Palette
[Color swatches with names, hex values, and intended use]
[ASCII palette diagram]
[Contrast verification table (foreground | background | ratio | WCAG status)]
[Usage rules: 3-5 bullets]
<!-- HTML: StyleGuideColorGrid + StyleGuideNotesList -->
<!-- See: styleguide-sections/02-color-palette.md -->

## 03 — Typography
[Font stack with fallbacks]
[Type scale table: level | font | size | weight | line-height | letter-spacing | use]
[Typography rules: 2-5 bullets]
[Font sources table: font | source | license | link(s)]
[Adobe Fonts alternatives for any paid/premium fonts]
<!-- HTML: StyleGuideTypeSpecimen components -->
<!-- See: styleguide-sections/03-typography.md -->

## 04 — Spacing & Layout
[Spacing scale (base unit + full scale)]
[Component spacing table: component | padding | gap | notes]
[Grid specification: breakpoint | columns | gutter | margin | max-width]
[Layout patterns specific to this product]
<!-- HTML: StyleGuideSpacingScale + StyleGuideSpecTable + StyleGuidePrinciples -->
<!-- See: styleguide-sections/04-spacing.md -->

## 05 — Buttons
[CSS snippets for all button variants: primary, secondary, ghost, destructive, + product-specific]
[All states: default, hover, focus, active, disabled]
[Size variants: sm, md, lg]
[Button usage rules]
<!-- HTML: StyleGuideBtn + StyleGuideButtonRow -->
<!-- See: styleguide-sections/05-buttons.md -->

## 06 — Input Fields
[CSS snippets for: text input, textarea, select, checkbox, radio]
[All states: default, hover, focus, error, disabled]
[Labels, helper text, error messages]
[Input usage rules]
<!-- HTML: StyleGuideInputGroup + StyleGuideInputField -->
<!-- See: styleguide-sections/06-inputs.md -->

## 07 — Navigation *(stub if not applicable)*
[Navigation patterns: tabs, breadcrumbs, sidebar, mobile nav, progress steppers]
[CSS snippets for each pattern]
[Responsive behavior notes]
<!-- HTML: StyleGuidePhaseTabs + StyleGuideStepProgress -->
<!-- See: styleguide-sections/07-navigation.md -->

## 08 — Status Indicators *(stub if not applicable)*
[Status states: active, complete, error, warning, pending, disabled]
[CSS snippets for each state]
[When to use which state]
<!-- HTML: StyleGuideStatusGrid + StyleGuideStatusIndicator -->
<!-- See: styleguide-sections/08-status-indicators.md -->

## 09 — Cards
[Card variants with CSS snippets]
[Card anatomy: title, body, tags, actions]
[Grid/layout behavior for card collections]
<!-- HTML: StyleGuideCard + StyleGuideCardGrid -->
<!-- See: styleguide-sections/09-cards.md -->

## 10 — Core Component Reference *(stub if not applicable)*
[Headless UI primitives styled for this design: Menu, Dialog, Disclosure, Switch, Tabs, etc.]
[CSS snippets or descriptions for each included primitive]
[Only include primitives relevant to this product]
<!-- HTML: StyleGuideWidgetDemo with Headless UI components -->
<!-- See: styleguide-sections/10-core-components.md -->

## 11 — Project Components *(stub if not applicable)*
[Composite widgets unique to this product — things that don't exist in a generic library]
[Description + CSS for each: e.g., Agent Chassis Card, Tournament Bracket, Execution Stream]
[Full-page composites (dashboards, multi-panel layouts) if applicable]
<!-- HTML: StyleGuideWidgetDemo -->
<!-- See: styleguide-sections/11-project-components.md -->

## 12 — Screens *(stub if not applicable)*
[Key screens described or wireframed: what they show, how they compose components from §05–§11]
[Use realistic content — these tell the product's story]
[At least: primary screen, secondary screen, empty/error state]
[For each screen:]
[  - Scroll & motion effects: parallax layers, scroll-triggered reveals, sticky headers, scroll-snap, infinite scroll]
[  - Stock art descriptions: search-ready queries for each placeholder image (e.g., "aerial view of server farm at night, blue lighting, 16:9")]
[  - AI generation prompts for illustrations/graphics if applicable]
<!-- HTML: StyleGuideScreenFrame -->
<!-- See: styleguide-sections/12-screens.md -->

## Interaction & Motion
[Table: element | effect | duration | easing]
[Scroll effects: parallax layers, scroll-triggered reveals, sticky elements, scroll-snap]
[For each scroll effect: trigger point, animation, speed/rate, prefers-reduced-motion fallback]
[Page-level transitions: how views enter/exit]
[Signature interaction (if any)]
[prefers-reduced-motion handling for ALL motion]

## Asset Guidelines
[Photography style per context — written as stock-photo-search-ready descriptions]
[Example: "Overhead view of circuit board with blue LED traces, dark background, shallow DOF, 16:9"]
[AI generation prompts for illustrations if applicable]
[Iconography: style, stroke weight, size, source library]
[Illustration approach (if applicable)]
[Logo usage rules (if not covered in §00)]

## Mixing Notes (mixed styles only)
[Which 3-5 elements carry the 20% accent]
[Why each was chosen]
[What was considered and rejected]

## Implementation Checklist
[Derived from source spec's checklist, applied to this context]

---
*Derived from: [spec name(s)]*
```

---

## 6. Worked Examples

Ten complete style guide examples are available for "Ipso The Lorem, Inc." — a fictional creative technology consultancy.

### Pure Styles

| # | Example | Key Learning |
|---|---------|-------------|
| 01 | [Minimal Tech 100%](../styles/examples/01-minimal-tech-100.md) | Restraint, single accent, developer audience |
| 02 | [Corporate Enterprise 100%](../styles/examples/02-corporate-enterprise-100.md) | Trust signals, serif + sans combo, blue palette |
| 03 | [Consumer Playful 100%](../styles/examples/03-consumer-playful-100.md) | Multi-color, rounded corners, bento grid |
| 04 | [Editorial 100%](../styles/examples/04-editorial-100.md) | Typography as design, 65ch measure, generous spacing |
| 05 | [Bold Expressive 100%](../styles/examples/05-bold-expressive-100.md) | Intentional rule-breaking, extreme scale contrast |

### Mixed Styles (80/20)

| # | Example | Key Learning |
|---|---------|-------------|
| 06 | [MT 80% + ED 20%](../styles/examples/06-minimal-tech-80-editorial-20.md) | Adding editorial warmth to technical austerity |
| 07 | [CE 80% + MT 20%](../styles/examples/07-corporate-80-minimal-tech-20.md) | Modernizing corporate with tech minimalism |
| 08 | [CP 80% + BE 20%](../styles/examples/08-playful-80-bold-expressive-20.md) | Adding expressive surprise to playful warmth |
| 09 | [ED 80% + CP 20%](../styles/examples/09-editorial-80-playful-20.md) | Adding consumer warmth to editorial authority |
| 10 | [BE 80% + MT 20%](../styles/examples/10-bold-expressive-80-minimal-20.md) | Grounding bold chaos with structural discipline |

See the [examples README](../styles/examples/README.md) for full company context and usage instructions.

---

## References

- [core-philosophy.md Section 5](../core-philosophy.md#5-style-guide-development) — Style discovery workflow (precedes construction)
- [styles/](../styles/) — The five source style specifications
- [process/brief-interpretation.md](brief-interpretation.md) — Brief completion (prerequisite)
- [eval/rubrics.md](../eval/rubrics.md) — Quality evaluation (post-construction)
- [SKILL.md](../../SKILL.md) — Style Selector table and mixing compatibility rules
