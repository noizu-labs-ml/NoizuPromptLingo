# BloggersCompete — Style Direction

> AI-powered blog discovery and competition platform

**Domain:** bloggerscompete.com
**Style:** Consumer Playful (80%) + Minimal Tech (20%)
**Status:** draft
**Last updated:** 2026-05-26

---

## Rationale

BloggersCompete is a community-driven platform where bloggers submit content, compete in challenges, and climb leaderboards. The primary audience is indie bloggers — creative, social, and motivated by recognition. **Consumer Playful** gives the product warmth, approachability, and competitive energy without feeling corporate. The **Minimal Tech** accent keeps the AI-powered analytics dashboards, scoring overlays, and data visualizations feeling credible and intelligent.

### Signal Balance

| Signal | Source | Where It Shows |
|--------|--------|---------------|
| Fun, community, energy | Consumer Playful | Landing page, competition cards, leaderboard, badges |
| Intelligence, trust | Minimal Tech | AI score breakdowns, analytics dashboard, blog evaluation UI |
| Approachability | Consumer Playful | Onboarding, copy tone, illustrations |
| Credibility | Minimal Tech | Methodology explanations, transparency pages |

---

## Color System

### Palette

```
Primary:    #A855F7 (Purple — creative energy, stands out in blogging space)
Secondary:  #F97316 (Orange — competition warmth, urgency, CTAs)
Accent:     #22C55E (Green — success, ranking up, positive feedback)
Background: #FFFBF7 (Cream — warm, inviting)
Surface:    #F5F3FF (Light purple tint — subtle branding in cards)
Text:       #1F1F1F (Soft black)
Text Secondary: #6B6B6B (Warm gray)
Border:     #E8E5F0 (Purple-tinted neutral)
```

### Semantic Colors

```
Success:  #22C55E (rank up, challenge won)
Warning:  #FBBF24 (approaching deadline, review needed)
Error:    #EF4444 (submission rejected, rule violation)
Info:     #3B82F6 (tips, AI insights)
```

### Dark Mode

Dark mode uses Minimal Tech palette structure for the dashboard/analytics views:

```
Background: #0F0B1A (Deep purple-black)
Surface:    #1A1525 (Elevated purple-dark)
Text:       #F5F3FF
Accent:     #C084FC (Lighter purple for dark bg)
```

---

## Typography

### Font Stack

- **Headings:** Plus Jakarta Sans (geometric, friendly, modern)
- **Body:** Inter (workhorse, excellent readability)
- **Data/Code:** JetBrains Mono (analytics, scores, blog metadata)

### Scale (fluid, `clamp()`)

| Token | Min | Preferred | Max | Usage |
|-------|-----|-----------|-----|-------|
| `--text-xs` | 0.75rem | — | — | Badges, labels |
| `--text-sm` | 0.8125rem | — | — | Captions, metadata |
| `--text-base` | 1rem | — | — | Body text |
| `--text-lg` | 1.125rem | — | — | Card titles |
| `--text-xl` | 1.25rem | clamp(1.25rem, 2vw, 1.5rem) | 1.5rem | Section headers |
| `--text-2xl` | 1.5rem | clamp(1.5rem, 3vw, 2rem) | 2rem | Page titles |
| `--text-hero` | 2rem | clamp(2rem, 5vw, 3.5rem) | 3.5rem | Hero headlines |

---

## Spacing

8px base grid. Spacing tokens:

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Inline gaps, badge padding |
| `--space-2` | 8px | Component internal padding |
| `--space-3` | 12px | Tight groups |
| `--space-4` | 16px | Standard padding, card padding |
| `--space-6` | 24px | Section gaps |
| `--space-8` | 32px | Section padding |
| `--space-12` | 48px | Page sections |
| `--space-16` | 64px | Hero padding |
| `--space-24` | 96px | Major section breaks |

---

## Shape Language

| Element | Radius | Rationale |
|---------|--------|-----------|
| Buttons | 12px | Rounded, friendly |
| Cards | 16px | Soft, inviting |
| Badges/Pills | 9999px (full) | Playful, tag-like |
| Modals | 20px | Generous, modern |
| Avatars | 50% (circle) | Community, identity |
| Input fields | 8px | Slightly rounded, functional |
| Data panels (Minimal Tech zone) | 8px | Crisper, analytical feel |

---

## Motion

| Interaction | Duration | Easing |
|-------------|----------|--------|
| Button hover | 100ms | ease-out |
| Card hover lift | 200ms | ease-out |
| Page transition | 300ms | ease-in-out |
| Leaderboard position change | 400ms | spring(1, 80, 10) |
| Score count-up animation | 800ms | ease-out |
| Badge earned celebration | 600ms | spring with overshoot |
| `prefers-reduced-motion` | Instant / none | — |

---

## Illustration Style

- Flat vector with subtle gradients (purple → orange)
- Rounded, geometric characters (if used)
- Trophy, podium, and rank iconography for competition themes
- Blog/writing motifs: pen, notebook, cursor, text blocks
- AI motifs: sparkle, brain, graph nodes (kept subtle, not sci-fi)

---

## Voice & Tone

| Context | Register | Example |
|---------|----------|---------|
| Marketing | Enthusiastic, direct | "Show the world what your blog can do." |
| Onboarding | Encouraging, simple | "Add your blog URL — we'll handle the rest." |
| Competition | Competitive but supportive | "You're in the top 15%. Keep climbing." |
| AI Feedback | Constructive, specific | "Strong opening hook. Consider tightening paragraph 3." |
| Error states | Helpful, not blaming | "We couldn't reach that URL. Double-check and try again." |
| Empty states | Motivating | "No competitions joined yet. Browse open challenges →" |
