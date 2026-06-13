# src/ — Application Source

```
src/
├── app/                                # Next.js App Router
│   ├── papers/                         # Published research papers section
│   │   ├── building-the-accord/        #   "Building the Accord" paper
│   │   │   ├── content.tsx             #     Paper body content
│   │   │   └── page.tsx                #     Route page wrapper
│   │   ├── cognitive-architecture/     #   "Cognitive Architecture" paper
│   │   │   ├── content.tsx
│   │   │   └── page.tsx
│   │   ├── manifesto/                  #   "Manifesto" paper
│   │   │   ├── content.tsx
│   │   │   └── page.tsx
│   │   ├── the-accord/                 #   "The Accord" paper
│   │   │   ├── content.tsx
│   │   │   └── page.tsx
│   │   ├── accord-content.ts           #   Shared Accord content data
│   │   └── page.tsx                    #   Papers index page
│   ├── projects/                       # Projects showcase
│   │   └── page.tsx                    #   Projects listing page
│   ├── globals.css                     # Global styles (Tailwind base)
│   ├── layout.tsx                      # Root layout (metadata, fonts, providers)
│   ├── page.tsx                        # Homepage — scroll-driven landing
│   ├── robots.ts                       # robots.txt generation
│   ├── sitemap.ts                      # sitemap.xml generation
│   ├── icon.svg                        # Favicon
│   └── apple-icon.svg                  # Apple touch icon
├── components/                         # React components
│   ├── hero/                           # Hero section SVG layers
│   │   ├── HeroCircuitSVG.tsx          #   Animated circuit board overlay
│   │   ├── HeroGridSVG.tsx             #   Grid background pattern
│   │   ├── HeroNodesSVG.tsx            #   Floating node network
│   │   └── HeroPhotoLayers.tsx         #   Photo parallax layers
│   ├── sequences/                      # Scroll-driven page sequences
│   │   ├── HeroSequence.tsx            #   Hero animation sequence
│   │   ├── ServicesSequence.tsx         #   Services section sequence
│   │   ├── ProjectsSequence.tsx        #   Projects showcase sequence
│   │   ├── TestimonialsSequence.tsx     #   Testimonials sequence
│   │   └── CTASequence.tsx             #   Call-to-action sequence
│   ├── CircuitComponents.tsx           # Reusable circuit board elements
│   ├── ContactModal.tsx                # Contact form modal
│   ├── DrawOnPath.tsx                  # SVG path drawing animation
│   ├── FadeIn.tsx                      # Fade-in animation wrapper
│   ├── Footer.tsx                      # Site footer
│   ├── JsonLd.tsx                      # Structured data (JSON-LD)
│   ├── Logo.tsx                        # Site logo component
│   ├── MagneticButton.tsx              # Cursor-magnetic button effect
│   ├── MermaidDiagram.tsx              # Mermaid diagram renderer
│   ├── MouseLightCard.tsx              # Mouse-tracking light card
│   ├── Navbar.tsx                      # Navigation bar
│   ├── PaperLayout.tsx                 # Paper page layout wrapper
│   ├── ParallaxSection.tsx             # Parallax scroll section
│   ├── ScrollProgress.tsx              # Page scroll progress indicator
│   ├── ScrollSequence.tsx              # Scroll sequence orchestrator
│   ├── ScrollSequenceContext.tsx        # Scroll sequence React context
│   ├── SVGParallaxLayer.tsx            # SVG-based parallax layer
│   ├── TextReveal.tsx                  # Text reveal animation
│   ├── TiltCard.tsx                    # 3D tilt card effect
│   └── TypedText.tsx                   # Typewriter text effect
└── hooks/                              # Custom React hooks
    └── useMediaQuery.ts                # Responsive breakpoint hook
```

## Architecture Notes

- **Scroll sequences** (`sequences/`) drive the homepage — each sequence maps to a viewport section and orchestrates child animations via `ScrollSequenceContext`
- **Hero SVG layers** (`hero/`) compose into the top-fold parallax scene
- **Papers** use a shared `PaperLayout` component with per-paper `content.tsx` for body text
- **Animation components** (FadeIn, TextReveal, DrawOnPath, ParallaxSection) are composable wrappers using Framer Motion
