# Scroll Sequences

## Pattern

The homepage (`src/app/page.tsx`) composes five full-viewport sequence components in a vertical stack:

1. **HeroSequence** — Multi-layer SVG parallax with circuit board, grid, nodes, and photo layers
2. **ProjectsSequence** — Open-source project showcase
3. **ServicesSequence** — Fractional CTO / Principal Engineer offerings
4. **TestimonialsSequence** — Client testimonials
5. **CTASequence** — Contact call-to-action

Each sequence receives a `zIndex` prop for stacking order. Sequences use `clip-path: inset(0)` to create a "card stack" effect where each section clips its overflow and reveals the next as the user scrolls.

## Hero Sub-Components

Located in `src/components/hero/`:

| Component | Role |
|-----------|------|
| `HeroCircuitSVG` | Animated circuit board background layer |
| `HeroGridSVG` | Dot grid overlay |
| `HeroNodesSVG` | Floating node particles |
| `HeroPhotoLayers` | Portrait with parallax depth |

## Animation Stack

- **Framer Motion** — Entry/exit animations, scroll-triggered transitions, gesture handling
- **D3** — Data-driven visualizations within sequences
- **CSS utilities** — `.gradient-text`, `.glass`, `.glass-hover`, `.glow`, `.parallax-image`
- **Accessibility** — All animations respect `prefers-reduced-motion: reduce`

## Interaction Components

Reusable animated primitives in `src/components/`:

- `MouseLightCard` — Card with cursor-following light effect
- `MagneticButton` — Button that attracts toward cursor
- `TiltCard` — 3D tilt on hover
- `TypedText` — Typewriter text reveal
- `TextReveal` — Word-by-word scroll reveal
- `FadeIn` — Intersection observer fade-in
- `ParallaxSection` — Scroll-speed differential
- `SVGParallaxLayer` — SVG element with parallax offset
- `DrawOnPath` — SVG path drawing animation
- `ScrollProgress` — Scroll position indicator
