# Section 12 — Screens

> Full-page mockups that prove the design system works as a whole.

---

## Why This Section Exists

Screens come last because they're the culmination. Every token, color, type choice, spacing rule, and component from Sections 01-11 comes together in a real page layout. If the system works, these screens feel cohesive — like they were designed by one mind. If something is off, you'll see it here: a button that's too small for its context, a color that clashes at page scale, spacing that looked fine in isolation but breaks in a real layout.

Screens are the integration test for the design system.

## What to Include

### Screen Selection

Show 2-5 key screens that represent the core user journey. Not every page — just the ones that tell the product's story:

- **Primary screen** — the home, hub, or dashboard. The screen users see most.
- **Data-heavy screen** — tables, lists, metrics. Proves the type and spacing system handles density.
- **Creation screen** — forms, editors, input flows. Shows interactive components in context.
- **Detail/focus screen** — a single item expanded. Proves the hierarchy works at depth.
- **Empty/error state** (optional) — what the product looks like with no data or when something fails.

### Fidelity Level

Wireframe-to-mid-fidelity. Enough detail to validate the design system, not so much that it becomes a prototype:

- Real colors, real typography, real spacing from the token system
- Realistic content and data
- Component outlines and arrangements, not pixel-perfect production art
- Inline styles for screen-specific layout elements that don't exist as reusable components

### Content Requirements

Use realistic content throughout:

- Real product names, not "Product Name Here"
- Real data values, not "XX.XX" or "N/A"
- Real navigation labels, not "Link 1, Link 2, Link 3"
- Real status text, not "Status"

The screens should let someone understand what the product does without reading a PRD.

### Scroll & Motion Effects

For each screen, document how the page behaves as the user scrolls or navigates:

- **Parallax layers** — which background/foreground elements move at different scroll rates? Specify the rate (e.g., "hero background scrolls at 0.5x, foreground content at 1x")
- **Scroll-triggered reveals** — elements that animate in on scroll (fade-up, slide-in). Specify trigger point (e.g., "when 25% visible"), animation, and duration
- **Sticky elements** — headers, sidebars, filter bars that pin on scroll. Specify the sticky offset and z-index
- **Scroll-snap sections** — full-viewport sections that snap into place
- **Infinite scroll / lazy loading** — where paginated content loads progressively
- **`prefers-reduced-motion` fallback** — for every motion effect, state the static fallback (e.g., "elements visible immediately, no animation")

In the HTML output, annotate scroll effects with CSS comments or `data-scroll-*` attributes so implementers can find them.

### Stock Art & Image Descriptions

For every placeholder image in a screen, provide a **search-ready description** that works for both stock photo search and AI image generation:

- **Format:** `data-image-brief="[description]"` attribute on the HTML element, plus descriptive `alt` text
- **Include:** Subject, mood, lighting, composition, color palette, aspect ratio
- **Stock search example:** `"diverse engineering team reviewing dashboard on large monitor, natural office lighting, warm tones, 16:9 landscape"`
- **AI generation example:** `"isometric illustration of a robotic arm assembling circuits, flat design, cyan and orange palette on dark background, 1:1 square"`
- **Be specific enough to get useful results** — "person at computer" is too vague; "senior developer reviewing pull request on ultrawide monitor, dark IDE theme, over-the-shoulder angle, shallow DOF" returns something usable

## Best Practices

- **Start with the most important screen.** The dashboard, the hub, the home view — whatever users see most goes first.
- **Include variety.** At minimum: one data-heavy screen and one content-creation screen. This tests both dense and spacious layout modes.
- **Maintain design system rules.** Even in custom screen layouts, use the spacing scale, color tokens, and typography from earlier sections. Screens that break the rules signal a system problem.
- **Annotate every screen.** Use `screen-label` to explain what each screen represents: "Sprint Dashboard — active iteration view" not just "Dashboard."
- **Screens can diverge from the style guide shell.** A dark-themed application can have dark screens inside a light style guide wrapper. The `ScreenFrame` isolates the screen's color context.
- **Keep the count low.** 2-3 screens that are clearly valuable beat 7 screens that blur together. Every screen should teach something new about the system.

## Template Usage

### ScreenFrame Component

Props:
- `url` — the URL shown in the browser chrome bar (e.g., "app.example.com/dashboard")
- `label` — annotation text explaining what this screen shows (e.g., "Primary dashboard — team overview with active sprint")

The frame renders browser chrome (traffic light dots, URL bar) to ground the content as a real interface.

### Screen Content

Build screen content inside `ScreenFrame` using:

- Inline styles for screen-specific layout (grid columns, fixed headers, sidebar widths)
- Components from Sections 05-11 for interface elements
- Color tokens from Section 02 for the screen's own palette

The `screen-body` container has no padding — content fills the full viewport width and height.

### Color Context

Screens often have a different color scheme from the style guide shell. A style guide might use a light neutral background, but the app itself might be dark-themed. This is expected. The `ScreenFrame` creates a boundary where the screen's own design language applies.

### Example Structure

```
<ScreenFrame url="app.example.com/dashboard" label="Sprint Dashboard — active iteration with backlog and live output">
  <div style={{ display: 'grid', gridTemplateColumns: '280px 1fr 320px', height: '100%' }}>
    {/* Sidebar: navigation + filters */}
    {/* Main: backlog list + metrics */}
    {/* Panel: live terminal output */}
  </div>
</ScreenFrame>
```

## Anti-Patterns

- **Screens that break the design system.** If a screen uses a button size, color, or spacing value not defined in Sections 01-04, the system has a gap. Fix the system, don't work around it in the screen.
- **Lorem ipsum in user-facing text.** Placeholder text hides real problems — string lengths, line wrapping, truncation, content hierarchy. Use real words.
- **Too many screens.** More than 5 screens dilutes the signal. Each additional screen has diminishing returns for validating the design system. If you need more, the style guide is becoming a prototype.
- **Screens without labels.** An unlabeled screen is ambiguous. Is this the admin view or the user view? The empty state or the loaded state? Annotate.
- **Screens that are just component collections.** A screen is not "all the buttons and inputs arranged on a page." It's a real interface solving a real user problem. If it doesn't tell a story, it's not a screen.
- **Inconsistent screens.** If the dashboard uses 16px gutters but the detail page uses 24px, the spacing system is broken. Screens should reinforce consistency, not expose drift.

## Dependencies

| Section | What It Provides |
|---|---|
| 01 — Design Tokens | All spacing, radius, shadow, and animation values |
| 02 — Color Tokens | Full palette for screen backgrounds, surfaces, text |
| 03 — Typography | All type scales and font stacks |
| 04 — Spacing | Grid system, layout columns, gutters |
| 05 — Buttons | Interactive controls placed in screen context |
| 06 — Navigation | Headers, sidebars, breadcrumbs in screen layouts |
| 08 — Status & Metadata | Status indicators and metadata in data-heavy screens |
| 09 — Cards | Content containers within screen panels |
| 10 — Core Components | Headless UI widgets in interactive screens |
| 11 — Project Components | Domain-specific composites assembled into screen layouts |
