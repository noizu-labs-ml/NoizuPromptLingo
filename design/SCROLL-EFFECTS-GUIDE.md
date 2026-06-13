# Scroll Effects Design Guide

> Principles and techniques for building smooth scroll-driven animations with proper section transitions, avoiding z-index wars, overlap bugs, and janky motion.

## The Core Problem

Scroll-driven animations pin content to the viewport using `position: sticky` while the user scrolls through a tall container. When multiple sticky sections stack on a page, three problems emerge:

1. **Overlap bleeding** — Later sections' sticky containers paint on top of earlier ones (DOM order), but if backgrounds are transparent/semi-transparent, earlier content bleeds through.
2. **Stacking context traps** — `sticky`, `transform`, `opacity < 1`, and `clip-path` all create new stacking contexts. Z-index only works within the same stacking context, so z-index across sibling sticky sections is unreliable.
3. **Motion sickness** — Too much scroll distance, too many simultaneous animations, or animations that fight the scroll direction create disorientation.

## Architecture: The Scroll Sequence Pattern

### Container Structure

```
<div style="height: 200vh; clip-path: inset(0)">   ← scroll distance + clip boundary
  <div class="sticky top-0 h-screen overflow-hidden"> ← pinned viewport
    <Layer speed={0.3} />                              ← parallax layers
    <Layer speed={0.5} />
    <Content />                                        ← text, cards, UI
  </div>
</div>
```

**Key decisions:**

| Property | Where | Why |
|----------|-------|-----|
| `height: Xvh` | Outer container | Controls how much scrolling drives the animation (more height = slower animation) |
| `clip-path: inset(0)` | Outer container | Clips sticky content to container bounds — prevents overlap with adjacent sections |
| `sticky top-0` | Inner container | Pins content to viewport while outer container scrolls |
| `h-screen` | Inner container | Fills exactly one viewport |
| `overflow-hidden` | Inner container | Prevents absolute-positioned children from escaping |

### Why `clip-path: inset(0)` is the Fix

The `clip-path` property on the **outer** scroll container is the critical piece that solves the overlap problem:

- It creates a clipping boundary at the container's edges
- When the container scrolls out of view, its sticky child gets clipped away
- It also creates a new stacking context, isolating z-index within the section
- Unlike `overflow: hidden`, it doesn't break `position: sticky` (overflow hidden on a parent kills sticky behavior)

```css
/* This breaks sticky: */
.parent { overflow: hidden; } /* ← kills sticky on children */
.child  { position: sticky; }

/* This works: */
.parent { clip-path: inset(0); } /* ← clips without breaking sticky */
.child  { position: sticky; }
```

### Section Transition Order

Later DOM elements paint on top of earlier ones. For scroll sequences, this means each new section naturally slides up and covers the previous one. Lean into this:

```
Section 1 (Hero)         ← First in DOM, painted first (behind)
Section 2 (Projects)     ← Slides up over Hero
Section 3 (Services)     ← Slides up over Projects
Section 4 (Testimonials) ← Slides up over Services
```

**Do NOT fight DOM order with z-index.** Instead:
- Give each section an opaque or near-opaque background (`bg-zinc-950/90` minimum)
- Use `clip-path: inset(0)` on each outer container
- Let natural DOM order handle the stacking

## Scroll Distance Tuning

### The Ratio

`scrollHeight / viewportHeight` = how many "screens" of scrolling drive the animation.

| Ratio | Feel | Use For |
|-------|------|---------|
| 1.2-1.5vh | Fast, snappy | Simple fade/reveal, minimal content |
| 1.5-2.0vh | Natural | Standard section with 3-6 animated elements |
| 2.0-3.0vh | Deliberate | Complex multi-phase sequences (Apple-style) |
| 3.0vh+ | Sluggish | Almost never appropriate for web — feels broken |

**Rule of thumb:** Start at 150vh. Only increase if the animation has distinct phases that need breathing room.

### Common Mistake: Too Much Scroll

If you have 5 sections at 300vh each, the user scrolls 1500vh (15x the viewport). On a 1080px screen, that's 16,200px of scrolling. A user scrolling at ~100px per mouse wheel tick needs **162 ticks** to reach the bottom. This feels broken.

**Target:** Total page scroll should be 600-800vh max for a 5-section page. That's ~6-8 screens of scrolling, which feels like a normal long page.

## Animation Timing Within a Scroll Sequence

### Progress Mapping

`scrollYProgress` goes from 0 to 1 over the container's scroll height. Map sub-ranges to specific animations:

```typescript
// DON'T: Pack everything into a tiny range (animations fight each other)
const opacity = useTransform(progress, [0, 0.1], [0, 1]);   // Too fast
const scale  = useTransform(progress, [0, 0.1], [0.5, 1]);  // Same range = simultaneous

// DO: Spread animations with overlap for smooth handoffs
const opacity = useTransform(progress, [0, 0.3], [0, 1]);   // Gradual
const scale  = useTransform(progress, [0.1, 0.4], [0.5, 1]); // Starts slightly after opacity
```

### The "Overlap and Handoff" Principle

Adjacent animations should overlap by 10-20% of their range. This creates smooth visual handoffs instead of jarring sequential steps:

```
Progress: 0.0 ──────────────────────────────── 1.0

Element A:  ████████████░░░░░░░░░░░░░░░░░░░░░  (0.0 - 0.35)
Element B:  ░░░░░░░████████████░░░░░░░░░░░░░░  (0.15 - 0.55)  ← overlaps A by 0.2
Element C:  ░░░░░░░░░░░░░░████████████░░░░░░░  (0.35 - 0.75)  ← overlaps B by 0.2
Element D:  ░░░░░░░░░░░░░░░░░░░░░████████████  (0.55 - 1.0)   ← overlaps C by 0.2
```

### Easing in Scroll Space

`useTransform` interpolates linearly between keyframes by default. For smoother motion, use more keyframes to approximate easing:

```typescript
// Linear (can feel mechanical):
const opacity = useTransform(progress, [0, 1], [0, 1]);

// Approximated ease-out (fast start, gentle end):
const opacity = useTransform(progress, [0, 0.3, 0.6, 1], [0, 0.7, 0.9, 1]);

// Approximated ease-in-out:
const opacity = useTransform(progress, [0, 0.15, 0.5, 0.85, 1], [0, 0.05, 0.5, 0.95, 1]);
```

### Property Animation Guidelines

| Property | Notes |
|----------|-------|
| `opacity` | GPU-accelerated, always safe. Use for fades. |
| `transform: translate` | GPU-accelerated. Keep values small (5-20px or 2-5%). Large values feel disconnected from scroll. |
| `transform: scale` | GPU-accelerated. Range 0.9-1.1 for subtle, 0.5-1.5 for dramatic. |
| `filter: blur()` | **Expensive.** Limit to 1-2 elements max. Pre-blur images instead of animating blur live. |
| `clip-path` | Moderate cost. Good for reveal effects. Use `inset()` or `circle()`. |
| `width/height/margin` | **Never animate these.** They cause layout reflow on every frame. |

## Parallax Layers

### Speed Conventions

```
Background layer:  speed 0.15-0.3x  (moves slowly, feels far away)
Mid layer:         speed 0.3-0.5x   (medium depth)
Content layer:     speed 1.0x       (moves with scroll — this is normal scroll)
Foreground layer:  speed 1.2-1.5x   (moves faster, feels close)
```

### Parallax Within Sticky Containers

Inside a sticky scroll sequence, "parallax" means different elements respond to `scrollYProgress` at different rates:

```typescript
const bgY = useTransform(progress, [0, 1], ["0%", "5%"]);    // Barely moves
const midY = useTransform(progress, [0, 1], ["0%", "10%"]);   // Moves a bit
const fgY = useTransform(progress, [0, 1], ["0%", "20%"]);    // Moves more
```

**Keep values small.** Inside a sticky container, there's no actual page scroll — you're simulating depth. Values over 20% look disconnected.

### Image Sizing for Parallax

Images that translate need to be oversized to avoid revealing edges:

```
Translate range ±10%  →  Image height: 120% of container (-inset-y-[10%])
Translate range ±15%  →  Image height: 130% of container (-inset-y-[15%])
Translate range ±20%  →  Image height: 140% of container (-inset-y-[20%])
```

## Section Backgrounds and Bleed Prevention

### The Opacity Stack Problem

```
Fixed background:  opacity 0.3 (always visible)
Section A:         bg-zinc-950/70 (70% opaque)
Section B:         bg-zinc-950/70 (70% opaque)
```

When A and B overlap during transition, you see:
- Section B at 70% opacity
- Section A bleeding through at 30% × 70% = 21%
- Fixed background at 30% × 30% = 9%

Result: muddy, layered mess.

### Fix: Gradient Backgrounds

Instead of uniform semi-transparent backgrounds, use gradients that are opaque at the top (covering the previous section) and transparent at the bottom (revealing depth):

```css
.section-bg {
  background: linear-gradient(
    to bottom,
    rgb(9, 9, 11) 0%,        /* fully opaque at top — covers prev section */
    rgba(9, 9, 11, 0.9) 30%,  /* nearly opaque */
    rgba(9, 9, 11, 0.7) 100%  /* semi-transparent at bottom — shows depth */
  );
}
```

### Per-Section Strategy

| Section | Background | Why |
|---------|-----------|-----|
| Hero | Transparent | Shows fixed background, fiber optics burst |
| Projects | 90% opaque | Covers hero, circuit traces image shows through slightly |
| Services | 90% opaque | Covers projects, blueprint SVG lives inside |
| Testimonials | 100% opaque | Clean break, constellation is its own visual world |
| CTA | 100% opaque | Beacon glow effect is self-contained |

## Performance Budget

| Metric | Target | Danger Zone |
|--------|--------|-------------|
| Simultaneous animated elements | 3-5 | 8+ |
| Animated `filter: blur()` elements | 0-1 | 3+ |
| Total parallax layers | 3-4 | 6+ |
| Image layers per section | 1-2 | 4+ |
| Total page scroll height | 600-800vh | 1200vh+ |

### DevTools Profiling

1. Open Chrome DevTools → Performance tab
2. Start recording, scroll through the page slowly
3. Look for:
   - Green bars (paint) — should be minimal
   - Purple bars (layout) — should be zero during scroll
   - Frame drops below 60fps — indicates too many layers or expensive filters

## Reduced Motion

Every scroll sequence must have a fallback:

```typescript
function Section() {
  const isMobile = useMediaQuery("(max-width: 767px)");
  const reduced = useReducedMotion();

  if (isMobile || reduced) {
    return <StaticFallback />;  // Standard FadeIn layout
  }

  return (
    <ScrollSequence scrollHeight="150vh">
      <AnimatedContent />
    </ScrollSequence>
  );
}
```

The fallback should render the same content with simple `whileInView` fade animations — no sticky containers, no parallax, no scroll-driven transforms.

## Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| Animations only visible after scrolling 50%+ of the page | Reduce scroll heights, front-load animations |
| Content invisible on initial load (opacity: 0) | Start text at opacity 1, fade *out* on scroll |
| Hero text disappears completely | Floor opacity at 0.3-0.4, never reach 0 |
| Sections overlap visually | `clip-path: inset(0)` on outer container |
| `z-index` doesn't work across sections | Don't use z-index; rely on DOM order + clip-path |
| `overflow: hidden` on parent breaks sticky | Use `clip-path: inset(0)` instead |
| Scroll feels sluggish/endless | Total page ≤ 800vh; each section 130-180vh |
| Animations jank on scroll | Only animate `opacity` and `transform`; avoid `blur` on multiple elements |
| Mobile scroll feels broken | Disable scroll sequences on mobile; use `whileInView` fallback |
| Parallax images show edges | Oversize images by 20-30% (`-inset-y-[15%]`) |

## References

- [Apple-style scroll animations with CSS view-timeline](https://www.builder.io/blog/view-timeline)
- [CSS-Tricks: Apple product page scroll animations](https://css-tricks.com/lets-make-one-of-those-fancy-scrolling-animations-used-on-apple-product-pages/)
- [Framer Motion useScroll documentation](https://motion.dev/docs/react-scroll-animations)
- [Framer Motion useTransform documentation](https://motion.dev/docs/react-use-transform)
- [CodyHouse: Overscroll Section component](https://codyhouse.co/ds/components/info/overscroll-section)
- [SuperHi: Parallax overlapping sections with sticky](https://library.superhi.com/posts/parallax-overlapping-sections-using-sticky-positioning)
- [MDN: Stacking context](https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Positioned_layout/Stacking_context)
- [MDN: clip-path](https://developer.mozilla.org/en-US/docs/Web/CSS/clip-path)
- [CSS animation trends 2026](https://webpeak.org/blog/css-js-animation-trends/)
- [LogRocket: React scroll animations with Framer Motion](https://blog.logrocket.com/react-scroll-animations-framer-motion/)
