# Gotta.cc Design Directions

Three style guides for the same directory. Pick a world to browse in.

---

## At a Glance

| | Direction A | Direction B | Direction C |
|---|---|---|---|
| **Name** | Ink & Paper | Warm Browse | Retro Revival |
| **File** | [direction-a](direction-a-ink-and-paper.md) | [direction-b](direction-b-warm-browse.md) | [direction-c](direction-c-retro-revival.md) |
| **One-liner** | The web, edited | Someone smart picked these for you | The web is a place again |
| **System** | Editorial 100% | Editorial 80% + Consumer Playful 20% | Bold Expressive (Retro Web) 80% + Consumer Playful 20% |
| **Display font** | Playfair Display (serif) | Fraunces (variable serif) | Space Grotesk (geometric sans) |
| **Body font** | Lora (serif, 18-20px) | Source Serif 4 (serif, 16-18px) | IBM Plex Serif (serif, 16-18px) |
| **UI font** | Inter (sans) | Plus Jakarta Sans (sans) | IBM Plex Mono (mono) |
| **Background** | Warm cream `#FFFCF7` | Warm cream `#FFFCF7` | Warm yellow `#FFF8E7` |
| **Primary accent** | Burgundy `#7F1D1D` | Deep Olive `#4A6741` | Electric Blue `#2563EB` |
| **Secondary accent** | — | Warm Coral `#E8704A` | Warm Red `#DC4A3A` |
| **Border radius** | 4px | 12-16px | 4-6px |
| **Border weight** | 1px | 1px | 2-3px |
| **Score display** | Large serif number (magazine rating) | Coral circle badge | Gold stars ★★★★☆ + number |
| **Category browser** | Typographic list with rules | Bento grid with colored tint cards | Dense list with colored section banners |
| **Navigation** | Minimal header, serif publication name | Friendly header + mobile tab bar | Classic horizontal bar, pipe separators |
| **Card hover** | Border color darkens | Lift + shadow | Border darkens + subtle shadow |
| **"Surprise Me"** | Italic serif link with arrow | Bouncy coral pill button | "I'm Feeling Lucky" red button with spin |
| **Motion** | Minimal, 200ms | Moderate, 150-200ms + bouncy CTAs | Mostly static, classic web |
| **Density** | Medium (editorial breathing room) | Medium (balance of content + space) | High (lots of listings visible) |
| **Risk level** | Low (refined, safe) | Low (warm, balanced) | Medium (polarizing, memorable) |

---

## Decision Framework

```
What should the directory FEEL like?
├── A curated magazine / publication
│   └── Direction A (Ink & Paper)
│       Authority. Restraint. Every listing reads like a review.
│
├── A friendly bookstore / gift guide
│   └── Direction B (Warm Browse)
│       Warmth. Approachability. Browse with delight.
│
└── The old web — but good this time
    └── Direction C (Retro Revival)
        Nostalgia. Exploration. The web as a place, not a tool.

Who is the primary audience?
├── Researchers, journalists, serious curators
│   └── Direction A (content-first, no distractions)
├── Casual explorers, indie web enthusiasts, creators
│   └── Direction B (inviting, low friction, discovery-focused)
└── Web nostalgia crowd, HN/indie-web, anti-slop activists
    └── Direction C (opinionated, distinctive, conversation-starter)
```

---

## Mixing Directions

These aren't mutually exclusive:

- **B is the safe center:** If you can't decide, B is what the README recommends. Editorial authority + enough warmth to feel human. It's the bookstore that also has great coffee.
- **A for content, C for marketing:** Use Ink & Paper for the actual directory experience (reading summaries, browsing categories) and Retro Revival for the landing page and "About" page (memorable, shareable, sets the tone).
- **C's colors on B's structure:** Keep B's rounded cards and friendly layout, but swap in C's warm yellow background and electric blue links. A "modern nostalgia" hybrid.
- **A → B evolution:** Launch with A (minimal, fast to build) and add Playful elements (colored categories, score badges, micro-interactions) over time as features grow.

---

## What's Not Covered Here

- Responsive behavior (all three need mobile adaptation)
- Category taxonomy design (which categories exist, how deep the tree goes)
- AI scoring visualization internals (how the scoring pipeline works)
- Admin/moderation interface (human review queue)
- API documentation styling
- Email/newsletter design (weekly digests)

---

## Next Steps

1. **React to these directions** — which world feels right for gotta.cc?
2. **Select or mix** — pure direction or hybrid
3. **HTML visual guides** — render the selected direction(s) as browsable HTML
4. **Landing page** — build the gotta.cc marketing/launch page in Next.js
5. **Component library** — build out the full component set for the directory app
