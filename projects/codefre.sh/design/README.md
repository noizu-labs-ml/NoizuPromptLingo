# CodeFresh Design Directions

Four style guides for the same product. Pick a world to live in.

---

## At a Glance

| | Direction A | Direction B | Direction C | Direction D |
|---|---|---|---|---|
| **Name** | Minimal Tech | Minimal + Editorial | Neo-Brutalist | Forge |
| **File** | [direction-a](direction-a-minimal-tech.md) | [direction-b](direction-b-minimal-editorial.md) | [direction-c](direction-c-neo-brutalist.md) | [direction-d](direction-d-forge.md) |
| **One-liner** | Eval results *are* the design | Readable conversations, rigorous chrome | Not another dashboard | The product IS the design system |
| **System** | Minimal Tech 100% | MT 80% + Editorial 20% | Bold Expressive | Bespoke (eval-first) |
| **Primary font** | Geist (sans) | Geist (sans) + Source Serif 4 (prose) | Space Mono (mono) | Plus Jakarta Sans |
| **Accent** | Violet `#7C3AED` | Violet `#7C3AED` | Electric Lime `#DCFF00` | Copper `#D4915E` |
| **Border radius** | 6-8px | 6-8px | 0px | 6px (from graph node) |
| **Border weight** | 1px | 1px | 2-3px | 1.5px |
| **Sidebar** | Persistent, collapsible | Persistent, collapsible | None (fullscreen overlay menu) | None (⌘K palette + breadcrumb) |
| **Body font** | Sans 14px | Sans 14px (UI) / Serif 16px (transcripts) | Mono 14px | Sans 14px (UI) / 15px (agent) / Mono 13px (author) |
| **Eval colors** | Standard saturated | Standard saturated | Neon saturated | Warm-shifted, warm bg optimized |
| **Motion** | Subtle, 150ms | Subtle, 150ms + staggered transcript fade | Abrupt, 100ms or instant | 120ms + "forge sequence" on results |
| **Risk level** | Low (safe industry default) | Low (additive refinement) | High (polarizing) | Medium (distinctive but professional) |

---

## Decision Framework

```
Should the design be derived from the product's own concepts?
├── Yes → Direction D (eval states, graph nodes, and three-voice
│         transcripts ARE the design system)
└── No — apply an external style system ─┐
    ├── Is conversation readability a top priority?
    │   ├── Yes → Direction B (editorial serif makes transcripts readable)
    │   └── No/Unsure ─┐
    │                   ├── Do you want to look like Linear/Vercel/Stripe?
    │                   │   ├── Yes → Direction A (industry-default, safe, polished)
    │                   │   └── No → Direction C (challenger brand, polarizing, memorable)
    │                   └── Do you want to stand out at all costs?
    │                       ├── Yes → Direction C
    │                       └── No → Direction A
    └── Want warmth WITHOUT polarization?
        └── Yes → Direction D (copper accent, warm backgrounds, medium risk)
```

## Mixing Directions

These aren't mutually exclusive in concept. Direction B already demonstrates mixing. Other valid combinations:

- **A → B evolution:** Start with A for v1, adopt B's transcript styling once the run-detail view matures
- **C for marketing, A for product:** Neo-Brutalist landing page and docs site, Minimal Tech for the actual app
- **C's accent on A's structure:** Keep A's layout and typography but swap violet accent for electric lime and remove border-radius (a lighter neo-brutalist nod)

## What's Not Covered Here

- Responsive behavior (all three need mobile adaptation)
- Actual graph rendering technology (d3, react-flow, cytoscape)
- CLI output styling (terminal has its own constraints)
- Marketing site / landing page design (separate effort)

---

## Next Steps

1. **React to these directions** — which world feels right?
2. **Select or mix** — pure direction or hybrid
3. **Wireframes** — apply the selected style to actual CodeFresh screens
4. **Component library** — build out the full component set
5. **Landing page** — design the codefre.sh marketing site
