# Knowledge Base Design Directions

Three style guides for the same product. Pick a world to live in.

---

## At a Glance

| | Direction A | Direction B | Direction C |
|---|---|---|---|
| **Name** | Vellum & Ink | Scholar's Terminal | Illuminated |
| **File** | [direction-a](direction-a-vellum-ink.md) | [direction-b](direction-b-scholars-terminal.md) | [direction-c](direction-c-illuminated.md) |
| **One-liner** | A library that feels like opening a beautiful book | A power tool that happens to contain beautiful content | A creative workshop where world-building feels playful |
| **System** | Editorial 80% + Minimal Tech 20% | Minimal Tech 80% + Editorial 20% | Editorial 80% + Consumer Playful 20% |
| **Primary font** | Lora (serif) | Inter (sans) | Source Serif 4 (serif) |
| **Body font** | Source Serif 4 16px | Inter 14px | Source Serif 4 16px |
| **Accent** | Saddle brown `#8B4513` | Indigo `#6366F1` | Warm violet `#7C3AED` |
| **Background** | Warm cream `#FAF9F6` | Near-black `#0A0A0A` | Soft parchment `#F7F3ED` |
| **Border radius** | 4-8px | 6-8px | 12-16px |
| **Border weight** | 1px, warm tones | 1px, cool grays | 1px, warm, often invisible |
| **Sidebar** | Slim left sidebar, book-spine feel | Persistent, collapsible, dense | Top nav + collapsible left panel |
| **Graph style** | Dark ink lines on cream, marginalia feel | Force-directed, neon-accented nodes | Illustrated nodes, organic connections |
| **Motion** | Restrained, 200-300ms | Subtle, 150ms | Gentle, 200-400ms with spring easing |
| **Mode** | Light only | Dark only | Light primary, dark available |
| **Risk level** | Low (natural fit for content product) | Medium (tool aesthetic may alienate creatives) | Medium (playful may undermine authority) |

---

## Decision Framework

```
Who is your primary user?
├── Novelists / serious worldbuilders who want the content to feel premium
│   └── Direction A (editorial authority, the content IS the design)
├── Power users who want speed, density, and keyboard shortcuts
│   └── Direction B (tool-first, content is data to be managed)
└── TTRPG GMs / casual creators who want world-building to feel fun
    └── Direction C (warm, inviting, creativity-enabling)

Still unsure?
├── Does the product need to feel like a library or a tool?
│   ├── Library → Direction A
│   └── Tool → Direction B
├── Is dark mode essential for your audience?
│   ├── Yes → Direction B
│   └── No preference → Direction A or C
└── Should the graph view feel technical or organic?
    ├── Technical → Direction B
    └── Organic → Direction A or C
```

## Mixing Directions

These aren't mutually exclusive:

- **A's reading experience + B's graph view:** Use Direction A for entry detail pages (where content is king) and Direction B's dark graph visualization (where technical clarity matters). Switch themes by context.
- **A for product, C for marketing:** Vellum & Ink for the app itself, Illuminated's warmth for the landing page and onboarding.
- **B's density + A's typography:** Keep Direction B's dark mode and information density but swap Inter for serif headings. A lighter neo-editorial developer tool.
- **C's personality on A's structure:** Direction A's layout and typography with Direction C's rounded corners, micro-animations, and playful iconography. Premium content with approachable personality.

## What's Not Covered Here

- Responsive behavior (all three need mobile adaptation, especially for GM session companion)
- Graph rendering technology (D3, Cytoscape, react-flow — separate technical decision)
- Export/PDF styling (the PDF export should match the chosen direction's typography)
- Marketing site / landing page design (separate effort, could use a different direction)

---

## Next Steps

1. **React to these directions** — which world feels right for Knowledge Base?
2. **Select or mix** — pure direction or hybrid
3. **Wireframes** — apply the selected style to actual Knowledge Base screens
4. **Component library** — build out the full component set
5. **Landing page** — design the library.therobotlives.com marketing site
