# Visual Design Principles

> The theoretical foundations beneath layout, components, and style systems. Covers Gestalt perception, spatial structure, visual hierarchy, communicative meaning, interactive affordance, and systemic coherence — the "why" layer that explains how design works on the human mind.

This document adapts the [Seven Foundations of Design](../../../seven-foundations.md) framework into applied guidance for interface design. For the full theoretical treatment — including historical lineage, structural types (dialectical, sequential, axial), and the directed-graph topology of how foundations relate — see the source framework directly.

**How this relates to other skill references:**
- **typography.md** tells you *why* serif vs sans-serif, kerning vs tracking, modular scales
- **This document** tells you *why* grouping, contrast, white space, hierarchy, affordance
- **styles/*.md** tell you *what* specific choices to make for each visual system
- **patterns/*.md** tell you *how* to implement those choices in code

---

## Table of Contents

- [1. The Seven Foundations](#1-the-seven-foundations)
- [2. Perceptual Organization (Gestalt)](#2-perceptual-organization-gestalt)
- [3. Elemental Form](#3-elemental-form)
- [4. Spatial Structure](#4-spatial-structure)
- [5. Attentional Hierarchy](#5-attentional-hierarchy)
- [6. Communicative Meaning](#6-communicative-meaning)
- [7. Interactive Affordance](#7-interactive-affordance)
- [8. Systemic Coherence](#8-systemic-coherence)
- [9. Integration Index](#9-integration-index)
- [10. Applying Principles to Critique](#10-applying-principles-to-critique)
- [References](#references)

---

## 1. The Seven Foundations

Design theory across Gestalt psychology, Bauhaus pedagogy, Norman's interaction principles, and Rams' reductive philosophy reduces to seven fundamental concepts. Each contains three operations (a *trichotomy*) that describe the essential mechanics within that concept.

| # | Foundation | Trichotomy | What It Governs |
|---|---|---|---|
| 1 | Perceptual Organization | Grouping ← Completion → Segregation | How the mind structures what it sees |
| 2 | Elemental Form | Mark → Shape → Volume | The dimensional building blocks |
| 3 | Spatial Structure | Division ← Balance → Void | How space is organized, weighted, emptied |
| 4 | Attentional Hierarchy | Dominance → Flow → Layering | How design directs the eye |
| 5 | Communicative Meaning | Denotation ‖ Connotation ‖ Convention | How design signifies |
| 6 | Interactive Affordance | Invitation → Response → Constraint | How design invites and guards action |
| 7 | Systemic Coherence | Consistency ‖ Rhythm ‖ Integrity | How design achieves unity |

**Three structural types:**
- **Dialectical** (1, 3): Two poles with a synthesis — identify which dominates and how tension resolves
- **Sequential** (2, 4, 6): Temporal/dimensional progression — trace the stages
- **Axial** (5, 7): Independent dimensions — evaluate each separately

```
Forward flow: Perception → Form → Space → Hierarchy → Meaning → Affordance → Coherence

Feedback loops:
  Meaning → Perception    (knowing what it means changes how you see it)
  Affordance → Space      (required interactions constrain layout)
  Coherence → All         (brand system pre-selects everything)
```

---

## 2. Perceptual Organization (Gestalt)

**How the mind structures what it sees.**
*The foundational question is not "what does this look like?" but "how will this be perceived?"*

The mind does not passively receive visual stimuli — it actively organizes them. The whole is perceived before individual parts. Three operations:

### Grouping

The mind binds elements into perceived units. Gestalt laws that drive grouping:

| Law | Mechanism | Interface Example |
|-----|-----------|-------------------|
| **Proximity** | Elements near each other → perceived as related | Form labels close to their inputs; card content grouped by padding |
| **Similarity** | Elements sharing visual attributes → same group | All primary buttons share color/shape; navigation items share typography |
| **Common region** | Elements within a shared boundary → one unit | Card containers; modal overlays; grouped form sections |
| **Connectedness** | Elements linked by lines/connectors → associated | Stepper progress bars; breadcrumbs; timeline components |
| **Common fate** | Elements moving together → unified | Accordion expand/collapse; carousel slide groups; toast notifications |

**Application:** Every spacing decision is a grouping decision. When you set `gap: 8px` between items within a card and `gap: 24px` between cards, you're using proximity to signal "these items belong together" and "these cards are separate units."

### Segregation

The complementary operation — pulling elements apart so they're perceived as distinct.

**Figure-ground** is the most fundamental spatial principle: what the eye reads as subject versus background. Dark mode, card elevation, modal overlays, and dropdown menus all depend on clear figure-ground separation.

**Contrast** is the primary tool for segregation — it operates across every visual dimension:

| Dimension | Low Contrast → | High Contrast → |
|-----------|----------------|-----------------|
| Size | Flat hierarchy | Clear dominance |
| Color | Subtle grouping | Bold separation |
| Value | Soft, blended | Sharp figure-ground |
| Weight | Gentle emphasis | Strong hierarchy |
| Shape | Uniform system | Intentional anomaly |

**Decision rule:** If two elements are not the same, make them *very* different. Timid contrast reads as a mistake; bold contrast reads as intention.

### Completion (Closure + Continuity)

The mind fills gaps to reach the simplest stable interpretation. Closure fills incomplete shapes (the FedEx arrow, the WWF panda). Continuity makes the eye follow smooth paths rather than see disjointed segments.

**Interface applications:**
- Progress indicators don't need to show every step explicitly — the mind completes the trajectory
- Truncated text with "..." works because closure assumes continuation
- Partially visible cards at viewport edges signal scrollability (the mind completes the hidden portion)
- Icon design relies on closure — simplified shapes work because the mind fills in detail

**Why Rams' "as little design as possible" works:** It trusts the perceptual system to carry meaning beyond what's explicitly rendered.

### Style Spec Manifestation

| Style | Grouping Strategy | Segregation Strategy | Completion |
|-------|-------------------|---------------------|------------|
| **Minimal Tech** | Generous spacing + subtle borders | Single accent color creates one strong figure-ground layer | Heavy reliance — minimal UI depends on the mind completing what's omitted |
| **Corporate Enterprise** | Container cards with clear boundaries | Multi-level hierarchy through size/weight/color | Moderate — explicit labels and boundaries reduce ambiguity |
| **Consumer Playful** | Rounded containers + color-coded sections | Vibrant multi-color palette separates categories | Bento grid partially-visible cells signal more content |
| **Editorial** | Horizontal rules + generous margins | Typography scale creates dominance hierarchy | Strong — generous white space trusts the reader to perceive structure |
| **Bold Expressive** | Overlapping elements create intentional ambiguity | Extreme size contrast (120px vs 12px) | Deliberately plays with incomplete shapes and cut-off text |

---

## 3. Elemental Form

**The dimensional building blocks of visual expression.**
*Mark → Shape → Volume: from the most primitive gesture to full dimensional presence.*

### Mark (Point + Line)

Lines carry communicative weight before they carry content:

| Line Quality | Signal | Where It Appears |
|---|---|---|
| Horizontal | Calm, stability | Horizontal rules (Editorial), section dividers |
| Vertical | Strength, formality | Sidebar borders, vertical nav indicators |
| Diagonal | Dynamism, tension | Bold Expressive decorative elements |
| Curved | Organic, fluid | Consumer Playful border-radius, rounded buttons |
| Thin (1px) | Precision, subtlety | Minimal Tech borders |
| Thick (2-3px) | Confidence, emphasis | Consumer Playful input borders, Bold Expressive underlines |
| Dashed | Impermanence, pending | Upload zones, drag targets, empty states |

**Key insight:** Every border, divider, underline, and stroke in a UI is a *line* with communicative quality. A `1px solid #E5E5E5` border sends a different signal than `3px solid #FF6B6B`.

### Shape

The critical distinction: **geometric** (precise, mathematical, human-made → order and rationality) vs **organic** (irregular, flowing, natural → warmth and dynamism).

| Shape Language | Signal | Style Spec |
|---|---|---|
| Geometric + sharp corners | Technical, precise | Minimal Tech (2-4px radius) |
| Geometric + right angles | Formal, stable | Corporate Enterprise (4-8px radius) |
| Geometric + generous rounding | Friendly, approachable | Consumer Playful (12-16px, pill buttons) |
| Mixed geometric/organic | Considered, crafted | Editorial (4px radius, organic imagery) |
| Geometric + intentional breakage | Rebellious, creative | Bold Expressive (0px or extreme radius) |

**Negative shapes matter equally.** The space *between* cards, the gap *around* content, the margin *beside* a sidebar — all form shapes that the eye perceives. Skilled designers treat positive and negative shapes with equal intentionality.

### Volume (Depth + Dimensionality)

In screen design, volume is illusory — achieved through:

| Technique | Depth Signal | Usage |
|---|---|---|
| `box-shadow` | Elevation, floating | Cards, modals, dropdowns |
| Background blur (`backdrop-filter`) | Depth separation | Modal overlays, glass effects |
| Z-index stacking | Layer hierarchy | Tooltips > Modals > Fixed nav > Content |
| Gradient/value shift | Subtle dimension | Hover states, active states |
| `transform: scale()` | Proximity to viewer | Button press feedback, card hover |

**Style spec depth spectrum:**
- **Minimal Tech**: Nearly flat — 1-2 shadow levels maximum, subtle
- **Corporate Enterprise**: Moderate — card shadows, modal elevation, clear layer hierarchy
- **Consumer Playful**: Expressive — colorful shadows, bouncy transforms, tactile feel
- **Editorial**: Flat — relies on typography hierarchy, not depth
- **Bold Expressive**: Either completely flat or extreme depth — no middle ground

---

## 4. Spatial Structure

**How space is organized, weighted, and emptied.**
*Division and Void are opposing impulses; Balance synthesizes them.*

### Division (Filling + Structuring)

Grids partition space into structured regions:

| Grid Type | Structure | Best For |
|---|---|---|
| Manuscript (single column) | One text block | Long-form reading (Editorial) |
| Column grid | 2-12 columns | Discontinuous content, dashboards |
| Modular grid | Equal modules | Complex layouts, bento grids |
| Hierarchical grid | Varied region sizes | Mixed content importance |
| Baseline grid | Vertical rhythm | Typography-heavy layouts |

**Proportional systems:**
- **Rule of Thirds** — 3×3 matrix; place key elements at intersection "sweet spots"
- **Golden Ratio** (1:1.618) — harmonious division found in classical composition
- These inform asymmetric layouts where content doesn't center mechanically but balances optically

### Void (Intentional Emptiness)

Void operates at two scales with distinct effects:

**Micro void** — between letters, words, lines, small elements:
- Affects legibility directly
- Line height 1.5× minimum for body text
- Kerning, tracking, word-spacing (see [typography.md](typography.md) Sections 5-6)

**Macro void** — margins, section spacing, column gaps, empty regions:
- Affects brand perception independent of content
- Abundant macro void = luxury, sophistication, calm (Google homepage, Apple marketing)
- Dense layouts = informational urgency, utility (news sites, data dashboards)

**Open vs. closed space:**

| Space Type | Character | Interface Equivalent |
|---|---|---|
| **Open** (prospect) | Expansive, possible, exposed | Full-width hero sections, generous margins, landing pages |
| **Closed** (refuge) | Intimate, contained, sheltered | Sidebar panels, card containers, modal dialogs |
| **Threshold** (transition) | Compression → release, reveal | Page transitions, scroll reveals, accordion open |

The threshold between open and closed is where spatial design generates its most powerful effects — the compression-release sequence that makes scrolling through a well-designed page feel like moving through architecture.

**The Japanese concept of *ma* (間)** — meaningful emptiness, the interval, the pause — versus Western *horror vacui* (fear of empty space). The five style specs sit on this spectrum:

```
← ma (void-embracing)                    horror vacui (void-filling) →

  Minimal Tech    Editorial    Corporate    Consumer Playful    Bold Expressive
      ●              ●            ●               ●                  ●
  (structured    (generous     (moderate,     (dense but         (either extreme
   emptiness)    margins)      predictable)    colorful)          void or extreme
                                                                   density)
```

### Balance (Distributing Visual Weight)

Visual weight is determined by: size, color saturation, contrast, texture, density, and isolation.

| Balance Type | Character | Style Spec |
|---|---|---|
| **Symmetrical** | Formal, stable, traditional | Corporate Enterprise |
| **Asymmetrical** | Dynamic, modern, sophisticated | Editorial, Minimal Tech |
| **Radial** | Powerful focal anchor | Used sparingly (hero sections, loading states) |
| **Mosaic** | Distributed, no single focal point | Consumer Playful (bento grids) |
| **Discordant** | Provocative, intentionally unsettled | Bold Expressive |

**Decision rule:** The appropriate balance type follows from brand personality. Corporate clients default to symmetrical; tech/editorial to asymmetrical; creative to discordant. If the balance type conflicts with the brand signal, one of them is wrong.

---

## 5. Attentional Hierarchy

**How design directs the eye and sequences information.**
*Dominance establishes the entry point; Flow creates the path; Layering builds depth.*

### Dominance (What You See First)

The element that differs most from its surroundings becomes the focal point. Mechanisms:

| Mechanism | How It Creates Dominance |
|---|---|
| Size difference | Largest element draws first |
| Color contrast | Saturated accent on neutral background |
| Value contrast | Dark on light (or vice versa) |
| Position | Top-left (in LTR cultures) has natural advantage |
| Isolation | Element surrounded by void gains weight |
| Motion | Animated element captures attention (use sparingly) |

**The Von Restorff effect:** The element breaking a pattern is remembered. Your primary CTA should be the anomaly — one coral button among gray ones.

### Flow (Where the Eye Goes Next)

Default reading patterns emerge when visual hierarchy is weak:

```
F-PATTERN (text-heavy)        Z-PATTERN (minimal copy)       GUTENBERG DIAGRAM

█████████████████            ██───────────────██           ┌─────────┬─────────┐
█████████████                 │               │            │ PRIMARY │ STRONG  │
████████████████              │               │            │ OPTICAL │ FALLOW  │
████                          │               │            │  AREA   │  AREA   │
████                         ██───────────────██           ├─────────┼─────────┤
████                                                       │  WEAK   │TERMINAL │
████                                                       │ FALLOW  │  AREA   │
                                                           └─────────┴─────────┘
```

**Critical insight:** These describe *default behavior absent strong visual cues*. The moment you introduce elements of varying weight, flow becomes designer-controlled. Directional cues override defaults: arrows, leading lines, gaze direction (humans instinctively follow another person's gaze), and continuity all redirect the path.

**Application to style specs:**
- **Minimal Tech**: Clean hierarchy makes flow predictable; sidebar + main follows L-pattern
- **Corporate Enterprise**: F-pattern in content areas; CTAs in terminal area
- **Consumer Playful**: Bento grid creates mosaic flow; color guides the path
- **Editorial**: Single-column flow; vertical scanning with typographic anchors
- **Bold Expressive**: Deliberately disrupts default patterns; creates its own flow through scale extremes

### Layering (How Deep the Information Goes)

Progressive disclosure: show only what's essential at each engagement level, offering depth on demand.

| Layer | Typography Level | Engagement Level | Interface Pattern |
|---|---|---|---|
| **Primary** | H1, Hero | Scanning (2-3 seconds) | Headlines, hero images, primary CTA |
| **Secondary** | H2-H3 | Evaluating (10-30 seconds) | Section headers, key features, social proof |
| **Tertiary** | Body, small | Reading (1-5 minutes) | Body text, details, specifications |
| **On-demand** | Hidden until interaction | Investigating | Accordions, tooltips, "read more," modals |

**Hick's Law:** Decision time increases logarithmically with choice count. Layering manages this by presenting choices progressively rather than all at once.

---

## 6. Communicative Meaning

**How design signifies, connotes, and encodes.**
*Three co-present modes — every design element participates in all three simultaneously.*

### Denotation (What It Literally Is)

The first-order meaning: what a design element depicts or states without interpretation.

- A camera icon *denotes* "camera" or "take photo"
- A product image *denotes* the product's appearance
- Body text *denotes* its literal content
- A data visualization *denotes* quantitative relationships

**Tufte's data-ink ratio** applies: maximize the proportion of design devoted to representing actual information versus decoration. Denotation is design at its most functional.

### Connotation (What It Evokes)

The second-order meaning: what a design element implies through association.

| Design Choice | Denotation | Connotation |
|---|---|---|
| Serif typeface | Letters | Tradition, authority, craft |
| Sans-serif typeface | Letters | Modernity, efficiency, tech |
| Blue palette | A color | Trust, professionalism, calm |
| Rounded corners | A shape | Friendliness, safety, approachability |
| Dark background | Reduced brightness | Sophistication, drama, nightlife |
| Monospace font | Fixed-width letters | Technical, code, raw data |
| Generous white space | Emptiness | Luxury, confidence, premium |
| Dense layout | Filled space | Value, information richness, urgency |

**Critical research finding:** Perceived appropriateness of a design choice to brand personality matters more than individual associations. Context overwhelms stereotype — blue doesn't automatically mean "trustworthy"; blue that *fits the brand's personality* does.

**Albers' relativity principle:** The same color, shape, or element reads differently depending on what surrounds it. A medium gray looks light on dark background, dark on light background. Connotation is always context-dependent.

### Convention (What Culture Agreed It Means)

Meaning established through social agreement, requiring only shared knowledge:

| Convention | Meaning | Type |
|---|---|---|
| Red = stop/danger | Alert, error | Cultural |
| Blue underlined text = link | Clickable | Platform |
| ☰ hamburger icon = menu | Navigation toggle | Learned |
| H1 > H2 > H3 | Heading hierarchy | Semantic |
| Shopping cart icon | View cart | E-commerce |
| × = close | Dismiss | UI standard |
| LTR reading direction | Left-to-right scan | Cultural |

**Norman's insight:** When natural mapping can't make affordances visible, standardization becomes necessary — requiring training only once but functioning universally thereafter.

**When modes conflict, design fails.** A children's hospital with the connotative coldness of a corporate law firm. A playful interface violating platform conventions. A data dashboard where decoration (connotation) overwhelms data (denotation).

### Meaning Analysis by Style Spec

| Style Spec | Primary Mode | Why |
|---|---|---|
| **Minimal Tech** | Convention | Relies heavily on learned UI patterns; denotation in data display |
| **Corporate Enterprise** | Convention + Connotation | Trust signals through conventional cues; blue/serif connote stability |
| **Consumer Playful** | Connotation | Color, shape, motion all evoke emotional responses |
| **Editorial** | Denotation | "Honor content" — typography as transparent vehicle for literal meaning |
| **Bold Expressive** | Connotation | Every choice broadcasts personality before content is read |

---

## 7. Interactive Affordance

**How design invites, responds to, and constrains action.**
*Follows the interaction timeline: before (invitation), during/after (response), protective boundary (constraint).*

### Invitation (Affordance + Signifiers)

Norman distinguished **affordances** (what an element *can* do) from **signifiers** (perceivable cues that *communicate* what it can do). A button affords pressing; its raised surface, color, and label are signifiers.

**Interface signifiers:**

| Signifier | Communicates |
|---|---|
| Elevated surface (shadow) | "I'm clickable / tappable" |
| Color differentiation | "I'm interactive, the surrounding content is not" |
| Cursor change (pointer) | "Hover here = action available" |
| Underline on text | "I'm a link" |
| Arrow/chevron | "More content this direction" |
| Drag handle (⋮⋮) | "I can be repositioned" |
| Border + padding on input | "Type here" |

**The Norman Door problem:** When signifiers contradict affordances. In UI: a flat, unstyled element that's actually clickable. A styled "button" that's actually decorative text. Cards that look clickable but aren't (or vice versa).

**Style spec invitation spectrum:**
- **Minimal Tech**: Understated signifiers — relies on convention and subtle hover states
- **Corporate Enterprise**: Explicit signifiers — clear button borders, labeled actions
- **Consumer Playful**: Enthusiastic signifiers — shadows, color, bouncy hover states
- **Editorial**: Typographic signifiers — underlined links, typographic hierarchy
- **Bold Expressive**: Provocative signifiers — oversized CTAs, unconventional interaction cues

### Response (Feedback + Mapping)

**Feedback** must be immediate, informative, and proportionate:

| Feedback Type | Timing | Example |
|---|---|---|
| Micro-feedback | 50-100ms | Button press acknowledgment, toggle snap |
| Hover feedback | 100-150ms | Color/shadow change, cursor shift |
| Transition feedback | 150-300ms | Page transition, panel open, content swap |
| Result feedback | 300-1000ms | Form submission confirmation, save indicator |

**Norman's two gulfs:**
- **Gulf of Execution** — "How do I do this?" → Bridged by clear signifiers (invitation)
- **Gulf of Evaluation** — "Did that work?" → Bridged by feedback (response)

**The aesthetic-usability effect:** Beautiful interfaces make users more tolerant of minor feedback failures. Aesthetics create an emotional buffer. This is why visual polish matters beyond vanity — it buys forgiveness.

### Constraint (Preventing Wrong Action)

Norman identifies four constraint types:

| Type | Mechanism | Interface Example |
|---|---|---|
| **Physical** | Shape prevents wrong action | Disabled buttons, non-scrollable areas |
| **Cultural** | Social norms guide behavior | Red for errors, green for success |
| **Semantic** | Meaning restricts options | A "reply" button only appears on messages |
| **Logical** | Reasoning eliminates alternatives | If 4 of 5 fields are filled, the empty one is next |

**Forcing functions** — constraint at its most powerful:
- **Interlocks**: Preventing entry to dangerous states (confirm dialogs before destructive actions)
- **Lock-ins**: Preventing exit from desired states (unsaved changes warning)
- **Lock-outs**: Preventing continuation of harmful sequences (rate limiting, CAPTCHA)

**Slips vs mistakes:**
- **Slips** (correct intention, wrong execution): Solved by physical constraints — larger touch targets, adequate spacing between destructive/safe actions
- **Mistakes** (wrong intention): Solved by semantic/logical constraints — clear labeling, progressive disclosure, confirmation steps

---

## 8. Systemic Coherence

**How design achieves unity across space, time, and purpose.**
*Three independent dimensions — evaluated separately.*

### Consistency (Coherence Across Space)

Like elements look and behave alike throughout. Two levels:

| Level | Scope | Mechanism |
|---|---|---|
| **Internal** | Within one interface | Design tokens, component library, spacing scale |
| **External** | Across products/platforms | Platform conventions, brand guidelines, shared patterns |

**Design tokens are consistency infrastructure.** When `--accent: #6366F1` is defined once and used everywhere, consistency is architectural, not effortful. When spacing follows a scale (`4, 8, 12, 16, 24, 32, 48, 64`), alignment consistency is automatic.

**Tufte's signal-to-noise ratio** improves as consistency eliminates arbitrary variation. Every inconsistency is noise the user must process.

### Rhythm (Coherence Across Time)

Patterned recurrence that creates visual cadence:

| Rhythm Type | Character | Interface Example |
|---|---|---|
| **Regular** | Consistent, even | Navigation items, data table rows, grid columns |
| **Flowing** | Organic variation | Masonry layouts, editorial section lengths |
| **Progressive** | Gradual change | Font size scale, feature tiers (basic → pro → enterprise) |

**Rhythm bridges repetition and variety.** Too much regularity deadens; too much variation fragments. The art is controlled variation within an established beat.

In interaction design, rhythm is:
- Consistent animation timing (all hovers at 150ms, all transitions at 200ms)
- Predictable wizard flow pacing
- Measured notification cadence
- Vertical rhythm in typography (consistent baseline spacing)

### Integrity (Coherence Between Form and Purpose)

The deepest dimension — does the design honestly serve its purpose?

**Sullivan:** "Form ever follows function" — but he meant form as *expression of inner life*, not utilitarian efficiency.

**Rams:** "Good design is honest" (promises only what it delivers) and "thorough down to the last detail" (nothing arbitrary).

**Integrity checklist:**
- Does the visual style match the product's actual capability? (Don't make a simple tool look like enterprise software)
- Does the UI complexity match the task complexity? (Don't over-design simple flows)
- Does the brand expression match the user's actual experience? (Don't promise delight and deliver friction)
- Are all decorative choices also functional? (Every animation communicates, every color differentiates)

**The axial relationship in practice:** A design system can be:
- Consistent but lifeless (identical tiles in a grid — coherent spatially, deadening temporally)
- Rhythmic but dishonest (beautiful animations for a product that doesn't work)
- Honest but inconsistent (a hand-crafted one-off that doesn't extend to the product line)

Evaluate all three independently. This separates rigorous critique from vague "something's off."

---

## 9. Integration Index

How the seven foundations map to specific skill files:

| Foundation | Trichotomy | Primary Skill Files | What They Cover |
|---|---|---|---|
| **1. Perceptual Organization** | Grouping | `patterns/layout.md` (spacing), `patterns/components.md` (cards, groups) | Proximity through spacing; similarity through component patterns |
| | Segregation | `patterns/accessibility.md` (contrast), `styles/*.md` (color systems) | Figure-ground through color; contrast through hierarchy |
| | Completion | `patterns/components.md` (truncation, progress), `styles/minimal-tech.md` | Closure in icons; continuity in progress indicators |
| **2. Elemental Form** | Mark | `typography.md` (stroke, weight), `styles/*.md` (border conventions) | Line quality in borders, dividers, type strokes |
| | Shape | `styles/*.md` (border-radius, shape language), `patterns/components.md` | Geometric vs organic; positive vs negative space |
| | Volume | `patterns/interaction.md` (transforms), `styles/*.md` (shadows) | Elevation, depth through shadow and blur |
| **3. Spatial Structure** | Division | `patterns/layout.md` (grids), `patterns/responsive.md` (breakpoints) | Column grids, modular grids, baseline grids |
| | Void | `styles/*.md` (spacing scales), `core-philosophy.md` (restraint) | Micro/macro white space; open vs closed |
| | Balance | `patterns/layout.md` (asymmetric), `styles/bold-expressive.md` (discordant) | Symmetrical, asymmetrical, radial, mosaic |
| **4. Attentional Hierarchy** | Dominance | `eval/rubrics.md` (visual hierarchy), `styles/*.md` (type scale) | Size, contrast, position for focal point |
| | Flow | `patterns/layout.md` (reading patterns), `patterns/responsive.md` | F-pattern, Z-pattern, Gutenberg diagram |
| | Layering | `patterns/components.md` (progressive disclosure), `eval/rubrics.md` | Primary/secondary/tertiary; on-demand depth |
| **5. Communicative Meaning** | Denotation | `eval/rubrics.md` (clarity), `typography.md` (readability) | Literal meaning; data-ink ratio |
| | Connotation | `styles/*.md` (color psychology, type personality), `typography.md` (signals) | Emotional/associative meaning |
| | Convention | `patterns/accessibility.md` (ARIA, semantics), `patterns/components.md` | Platform patterns; learned conventions |
| **6. Interactive Affordance** | Invitation | `patterns/components.md` (button anatomy, input patterns) | Signifiers; discoverability |
| | Response | `patterns/interaction.md` (timing, feedback), `patterns/components.md` (states) | Micro-feedback; transition feedback |
| | Constraint | `patterns/accessibility.md` (keyboard nav), `patterns/components.md` (states) | Disabled states; forcing functions; validation |
| **7. Systemic Coherence** | Consistency | `core-philosophy.md` (design tokens), `styles/*.md` (token systems) | Internal/external consistency |
| | Rhythm | `patterns/layout.md` (vertical rhythm), `patterns/interaction.md` (timing) | Regular, flowing, progressive rhythm |
| | Integrity | `core-philosophy.md` (outcomes, restraint), `eval/rubrics.md` (brand alignment) | Form-purpose alignment; honest design |

---

## 10. Applying Principles to Critique

When evaluating a design (your own or someone else's), walk through each foundation:

### Quick Critique Checklist

**1. Perceptual Organization**
- [ ] Are related elements grouped (proximity, common region)?
- [ ] Are distinct elements clearly separated (contrast, figure-ground)?
- [ ] Does the mind complete the composition correctly (no ambiguous closure)?

**2. Elemental Form**
- [ ] Is the shape language consistent (all geometric or intentionally mixed)?
- [ ] Do line qualities (borders, strokes, dividers) match the brand signal?
- [ ] Is depth used intentionally (not arbitrary shadow values)?

**3. Spatial Structure**
- [ ] Is the grid visible and consistent?
- [ ] Is white space intentional (structured emptiness, not leftover space)?
- [ ] Is the balance type appropriate for the brand personality?

**4. Attentional Hierarchy**
- [ ] Is the entry point (dominant element) immediately clear?
- [ ] Does the eye flow to the next-most-important element naturally?
- [ ] Is information layered (primary → secondary → tertiary → on-demand)?

**5. Communicative Meaning**
- [ ] Is literal content clear and readable (denotation)?
- [ ] Do color, type, and shape choices evoke appropriate associations (connotation)?
- [ ] Are platform conventions respected (convention)?
- [ ] Do the three modes reinforce each other (no contradictions)?

**6. Interactive Affordance**
- [ ] Are interactive elements clearly signaled (invitation)?
- [ ] Does every action produce visible feedback (response)?
- [ ] Are errors prevented where possible (constraint)?
- [ ] Can users recover from errors easily?

**7. Systemic Coherence**
- [ ] Do like elements look and behave alike throughout (consistency)?
- [ ] Is there visual cadence — controlled variation within repetition (rhythm)?
- [ ] Does the design honestly represent the product's capability (integrity)?

---

## References

### Internal
- [Seven Foundations of Design](../../../seven-foundations.md) — Full theoretical framework (source)
- [core-philosophy.md](core-philosophy.md) — Design philosophy and first principles
- [typography.md](typography.md) — Typography fundamentals (Foundation 2: Mark)
- [patterns/layout.md](patterns/layout.md) — Layout patterns (Foundations 3, 4)
- [patterns/components.md](patterns/components.md) — Component patterns (Foundations 1, 6)
- [patterns/interaction.md](patterns/interaction.md) — Interaction patterns (Foundation 6)
- [patterns/accessibility.md](patterns/accessibility.md) — Accessibility patterns (Foundations 1, 5, 6)
- [patterns/responsive.md](patterns/responsive.md) — Responsive patterns (Foundation 3)
- [eval/rubrics.md](eval/rubrics.md) — Visual design rubric (Foundations 4, 7)
- [styles/](styles/) — Five style specs demonstrating all foundations in practice

### External
- Wertheimer, Köhler, Koffka — Gestalt psychology (1910s-1920s)
- Kandinsky — *Point and Line to Plane* (1926)
- Müller-Brockmann — *Grid Systems in Graphic Design* (1981)
- Norman — *The Design of Everyday Things* (1988, revised 2013)
- Rams — Ten Principles of Good Design
- Tufte — *The Visual Display of Quantitative Information* (1983)
- Lidwell, Holden, Butler — *Universal Principles of Design* (2003)
- Barthes — *Mythologies* (1957), semiotic orders of signification
- Sullivan — "The Tall Office Building Artistically Considered" (1896)
