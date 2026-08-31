import React from "react";
import { useParams } from "react-router-dom";
import { MarkdownView } from "../components/MarkdownView.js";

const STYLE_GUIDES: Record<string, { title: string; content: string }> = {
  "2026-Q2-1": {
    title: "Claude Assist Style Guide — 2026 Q2",
    content: "",
  },
};

// ⟦𓀥𓏙𓋒𓋈⟧ StyleGuide :: auto-generated pointer for public function StyleGuide
export function StyleGuide() {
  const { slug } = useParams<{ slug: string }>();
  const guide = slug ? STYLE_GUIDES[slug] : null;

  if (!guide) {
    return (
      <div className="mx-auto max-w-4xl py-12">
        <h1 className="text-xl font-medium text-text-bright mb-4">Style Guides</h1>
        <div className="space-y-2">
          {Object.entries(STYLE_GUIDES).map(([key, g]) => (
            <a key={key} href={`/style-guides/${key}`} className="block rounded-lg border border-border-subtle bg-surface p-4 hover:border-glow/30 transition-colors">
              <span className="text-sm font-medium text-text-bright">{g.title}</span>
            </a>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-4xl pb-16">
      <MarkdownView content={guide.content} />
    </div>
  );
}

// The actual content is below — assigned as a template literal to keep it in one file.

Object.assign(STYLE_GUIDES["2026-Q2-1"]!, {
  content: `# Claude Assist — Style Guide

> **Nocturne (80%) + Minimal Tech (20%)** — a dark-native dev tool that treats the void as canvas and uses luminosity to create hierarchy. Minimal Tech's restraint tempers Nocturne's atmosphere: no gratuitous glow, no ambient drift. Every bright pixel earns its place.

**Version:** 2026-Q2-1
**Glow color:** Plasma Cyan (\`#06B6D4\`)
**Fonts:** Inter (UI) + JetBrains Mono (code/data)

---

## Design Identity

| Principle | Expression |
|-----------|-----------|
| **Professional instrument** | Not a toy, not a dashboard. A tool you reach for daily. |
| **Terminal kinship** | Shares the visual language of dark terminals, monospace, dense information. |
| **Quiet competence** | Works, stays out of the way, surfaces what matters. |
| **Information density** | Every pixel shows data or enables action. Nothing decorative. |

---

## Color System

### Surface Palette

\`\`\`
  Void ────────── #09090B   true black (scrollbar track, deep bg)
  Canvas ──────── #0F0F14   page background
  Surface ─────── #18181F   cards, panels, sidebar
  Surface Raised  #22222E   modals, popovers, elevated cards
  Surface Active  #2A2A38   selected items, hover backgrounds
\`\`\`

### Border & Separator

| Token | Hex | Use |
|-------|-----|-----|
| \`border-subtle\` | \`#2A2A3A\` | Default dividers, card borders |
| \`border-strong\` | \`#3A3A4F\` | Interactive/focused element borders |

### Text Hierarchy (luminosity-driven)

| Token | Hex | Ratio vs Canvas | Use |
|-------|-----|-----------------|-----|
| \`text-dim\` | \`#5C5C72\` | 3.2:1 | Metadata, timestamps (large text only) |
| \`text-muted\` | \`#7A7A94\` | 4.6:1 | Secondary labels, placeholders |
| \`text-secondary\` | \`#9898B0\` | 6.1:1 | Body text, descriptions |
| \`text-primary\` | \`#CDCDE0\` | 11.2:1 | Headings, thread content |
| \`text-bright\` | \`#EDEDF4\` | 15.1:1 | Emphasis, active items |
| \`text-max\` | \`#FFFFFF\` | — | Active focus states only |

### Glow (Plasma Cyan)

| Token | Value | Use |
|-------|-------|-----|
| \`glow\` | \`#06B6D4\` | Primary accent: buttons, links, active states |
| \`glow-bright\` | \`#22D3EE\` | Hover/focus glow expansion |
| \`glow-dim\` | \`#06B6D4\` at 50% | Badges, subtle indicators |
| \`glow-bg\` | \`#06B6D4\` at 8% mixed with surface | Selected row bg, active tab |

### Semantic Colors

| Purpose | Hex | Treatment |
|---------|-----|-----------|
| Success | \`#4ADE80\` | Solid badge, soft green glow |
| Warning | \`#FACC15\` | Solid badge, border accent |
| Error | \`#F87171\` | Solid badge, pulsing glow on critical |
| Info | \`#60A5FA\` | Solid badge, steady glow |

### Color Rules

- Canvas occupies **85%+ of visible area** — the dark IS the design
- Glow color **never used for large fills** — max area: button-sized
- No gradients except on featured/promoted cards
- Depth via brightness stepping only — **no drop shadows**
- \`text-dim\` restricted to **large text (18px+)** or non-essential metadata

---

## Typography

### Font Stack

| Role | Family | Fallback |
|------|--------|----------|
| UI text | Inter | system-ui, -apple-system, sans-serif |
| Code / data | JetBrains Mono | Fira Code, SF Mono, Menlo, monospace |

### Scale

All weights **reduced by one step** for dark canvas (irradiation illusion compensation).

| Level | Size | Weight | Color | Use |
|-------|------|--------|-------|-----|
| Page Title | 28px | 500 | \`text-bright\` | Page headings |
| Section | 20px | 500 | \`text-primary\` | Section headers |
| Subsection | 16px | 500 | \`text-primary\` | Card titles |
| Body | 14px | 400 | \`text-secondary\` | Descriptions |
| Small | 13px | 400 | \`text-muted\` | Secondary info |
| Caption | 12px | 400 | \`text-dim\` | Metadata, line numbers |
| Code | 13px | 400 | varies | Conversation content |

### Letter Spacing

- Body text: \`+0.01em\`
- Headings: \`+0.005em\`
- Captions: \`+0.02em\`

---

## Spacing

8px base grid. Vertical spacing **25% more generous** than light-native equivalents.

| Token | Size | Use |
|-------|------|-----|
| space-1 | 4px | Inline icon gaps |
| space-2 | 8px | Icon-to-label, tight padding |
| space-3 | 12px | Input padding, small cards |
| space-4 | 16px | Standard component spacing |
| space-5 | 20px | Card padding |
| space-6 | 24px | Between component groups |
| space-8 | 32px | Panel padding, section gaps |

---

## Components

### Buttons

Three tiers with clear visual hierarchy:

| Tier | Class | Background | Border | Text | Use |
|------|-------|-----------|--------|------|-----|
| **Primary** | \`btn-action-primary\` | \`glow/15\` | \`glow/25\` | \`glow\` | Edit, Convert — key actions |
| **Neutral** | \`btn-action\` | \`surface\` | \`border-subtle\` | \`text-muted\` | Back, Clone, Rehome — secondary |
| **Danger** | \`btn-action-danger\` | \`red-950/20\` | \`red-900/30\` | \`red-400\` | Archive, Delete — destructive |

All buttons: \`rounded-md\`, \`text-xs\`, \`px-3 py-1.5\`, \`transition-colors duration-150\`.

### Role Badges

| Role | Class | Style |
|------|-------|-------|
| User | \`role-user\` | Cyan pill: \`bg-glow/15 text-glow\`, rounded-full |
| Assistant | \`role-assistant\` | Neutral pill: \`bg-surface-active text-text-primary\`, rounded-full |

### Tag Chips

\`\`\`
.tag-chip — rounded-full, border-glow/20, bg-glow/8, text-glow
  hover: border-glow/35, bg-glow/12
  × button: opacity-0, group-hover:opacity-100
\`\`\`

### Metadata Rows

Consistent left-aligned layout for Dir / Source / Resume:

\`\`\`
.meta-row    — flex items-center gap-2 text-xs
.meta-label  — w-16 shrink-0 text-right text-dim
.meta-value  — rounded bg-canvas px-2.5 py-1 font-mono text-muted select-all
.meta-copy   — shrink-0 rounded px-1.5 py-0.5 text-dim hover:text-glow hover:bg-glow/10
\`\`\`

### Collapsible Blocks (Thinking, Tool Use, Tool Result)

\`\`\`
.collapse-toggle — flex w-full items-center gap-2 rounded px-3 py-2
                   text-xs hover:bg-surface-active/50
\`\`\`

- Chevron: \`▸\` collapsed, \`▾\` expanded (\`text-dim/60\`)
- Tool name: \`font-mono text-glow\`
- Body: \`bg-canvas/50\` border-t, padded
- Expanded code: \`bg-void/50 rounded p-3 font-mono\`

### Search Bar

- \`surface\` bg, \`border-subtle\` border
- Focus: \`glow\` border + subtle box-shadow
- Mode toggle (Text/Semantic) as pills, right-aligned inside input
- Icon left, \`text-dim\`

### Cards (Thread, Stat, Dataset)

- \`surface\` bg, \`border-subtle\` border, \`rounded-lg\`
- Hover: \`border-strong\`, \`surface-active\` bg
- Max border-radius: 8px (keep it technical)

---

## Thread Message Rendering

### User Messages

- Border: \`glow/15\`, Background: \`glow-bg/40\`
- Content: plain text (\`text-primary\`, \`whitespace-pre-wrap\`) — no markdown rendering
- Role badge: \`role-user\` pill

### Assistant Messages

- Border: \`border-subtle\`, Background: \`surface\`
- Content: **rendered markdown** by default with Rendered/Source toggle
- Toggle only shown when content contains markdown formatting
- Role badge: \`role-assistant\` pill + model name in mono

### Markdown Rendering

- \`react-markdown\` + \`remark-gfm\` (tables, strikethrough, task lists)
- \`remark-math\` + \`rehype-katex\` (LaTeX: \`$inline$\` and \`$$display$$\`)
- \`react-syntax-highlighter\` with Prism oneDark theme
- **Mermaid.js** diagrams: \`\\\`\\\`\\\`mermaid\` blocks render as SVG with dark theme
- Code block bg: \`#09090B\` (void)
- Copy button: appears on hover, top-right of code blocks

### Thinking Blocks

- Collapsed by default, dimmed (\`text-dim\`)
- Expands to rendered markdown
- \`bg-canvas/50\` container

### Tool Blocks

- Tool name in \`glow\` monospace
- Collapsed, showing description preview
- Expands to JSON input or text output
- \`bg-void/50\` for expanded content

---

## Layout

### App Shell

\`\`\`
┌──────────────────────────────────────────────────┐
│  Navbar (56px) — logo, search (compact), status  │
├───────────┬──────────────────────────────────────┤
│ Sidebar   │ Main Content                         │
│ (220px)   │ (max-width: 896px, centered)         │
│           │                                      │
│ Dashboard │                                      │
│ Search    │                                      │
│ Browse    │                                      │
│ Datasets  │                                      │
│ ────────  │                                      │
│ Settings  │                                      │
└───────────┴──────────────────────────────────────┘
\`\`\`

- Sidebar: \`surface\` bg, \`border-subtle\` right border
- Active item: \`glow-bg\` bg, \`glow\` left border (3px), \`text-bright\`
- Inactive: \`text-muted\`, no background
- Content: \`canvas\` bg, \`max-w-4xl\` centered

---

## Interaction

| Interaction | Duration | Easing |
|-------------|----------|--------|
| Button hover | 150ms | ease-out |
| Focus ring | 100ms | ease-out |
| Collapse/expand | 150ms | ease-out |
| Page transition | 200ms | ease-in-out |
| Glow expansion | 200ms | ease-out |

### Focus States

\`\`\`css
:focus-visible {
  outline: 2px solid var(--glow);
  outline-offset: 2px;
  box-shadow: 0 0 6px color-mix(in srgb, #06B6D4 50%, transparent);
}
\`\`\`

---

## Accessibility

| Pair | Ratio | WCAG |
|------|-------|------|
| text-secondary on canvas | 6.1:1 | AA body |
| text-primary on canvas | 11.2:1 | AAA |
| text-primary on surface | 8.9:1 | AAA |
| text-muted on canvas | 4.6:1 | AA (large text, UI) |
| text-dim on canvas | 3.2:1 | large text only |
| glow on void | 5.8:1 | AA body |

### Rules

- Body text minimum: \`text-secondary\` (6.1:1)
- \`text-dim\` restricted to large text or non-essential metadata
- All interactive elements: \`:focus-visible\` glow ring
- Collapsible sections: \`aria-expanded\` for screen readers
- Reduced motion: disable glow transitions, instant state changes

---

## Do's and Don'ts

**Do:**
- Trust the void — empty space is canvas, not waste
- Use glow sparingly — 1-2 glowing elements per viewport
- Prefer monospace for conversation content
- Test on OLED (true blacks) and LCD (dark grays)
- Keep information density high in thread/browse views

**Don't:**
- Add ambient glow orbs, drifting gradients, atmospheric effects
- Use pure white for body text
- Apply glow to decorative elements — glow means "interactive" or "active"
- Add loading spinners — use skeleton screens with luminosity sweep
- Create light mode — this is dark-native
- Use border-radius larger than 8px
- Use emoji in the UI
`,
});
