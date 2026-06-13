# src/ — Application Source

```
src/
├── app/                                    # Next.js App Router
│   ├── layout.tsx                          #   Root layout (HTML shell, providers)
│   ├── page.tsx                            #   Home page (/)
│   ├── globals.css                         #   Global styles + Tailwind imports
│   ├── about/
│   │   └── page.tsx                        #   About page (/about)
│   ├── contact/
│   │   └── page.tsx                        #   Contact page (/contact)
│   ├── login/
│   │   └── page.tsx                        #   Login page (/login)
│   ├── portfolio/
│   │   ├── page.tsx                        #   Portfolio grid (/portfolio)
│   │   └── [domain]/
│   │       └── page.tsx                    #   Individual project page (/portfolio/:domain)
│   ├── process/
│   │   └── page.tsx                        #   Process/methodology page (/process)
│   ├── signup/
│   │   └── page.tsx                        #   Signup page (/signup)
│   ├── sitemap/
│   │   └── page.tsx                        #   Sitemap page (/sitemap)
│   └── styleguide/
│       └── page.tsx                        #   Style guide viewer (/styleguide)
├── components/                             # Shared React components
│   ├── blur-tagline.tsx                    #   Animated tagline with blur effect
│   ├── decision-flow.tsx                   #   Decision tree visualization
│   ├── hero-section.tsx                    #   Landing page hero
│   ├── logo.tsx                            #   Brand logo component
│   ├── navbar.tsx                          #   Navigation bar
│   ├── pipeline-flow.tsx                   #   Venture pipeline visualization
│   ├── robot-egghead.tsx                   #   Robot character variant
│   ├── robot-foundry.tsx                   #   Robot foundry illustration
│   ├── robot-grid.tsx                      #   Grid of robot illustrations
│   ├── robot-poses.tsx                     #   Robot pose variants
│   ├── verb-cycle.tsx                      #   Rotating verb animation ("builds", "knows", etc.)
│   └── generated/                          #   Auto-generated component code
│       └── demo.ts                         #   Demo/example generated component
├── config/
│   └── theme-style-guide/                  # YAML theme definitions (design system input)
│       ├── branding.yaml                   #   Brand identity tokens
│       ├── style-guide.meta.yaml           #   Theme metadata
│       ├── style-guide.vars.yaml           #   CSS custom property definitions
│       ├── style-guide.scoped-vars.yaml    #   Scoped/component-level variables
│       ├── style-guide.color-palette.yaml  #   Color palette definitions
│       ├── style-guide.color-modes.yaml    #   Light/dark mode mappings
│       ├── style-guide.typography.yaml     #   Font stacks, sizes, weights
│       ├── style-guide.spacing.yaml        #   Spacing scale
│       ├── style-guide.globals.yaml        #   Global CSS rules
│       ├── style-guide.semantic-classes.yaml   # Semantic utility classes
│       ├── style-guide.semantic-groups.yaml    # Grouped semantic tokens
│       ├── style-guide.css-snippets.yaml   #   Reusable CSS snippets
│       ├── style-guide.glyphs.yaml         #   Icon/glyph definitions
│       ├── style-guide.design-sections.yaml    # Design section showcases
│       ├── style-guide.page-layouts.yaml   #   Page layout templates
│       ├── style-guide.page-sections.yaml  #   Page section patterns
│       └── style-guide.shell-layouts.yaml  #   App shell layout definitions
├── context/
│   └── auth.tsx                            # Authentication context provider
├── lib/
│   ├── api.ts                              # API client (backend communication)
│   └── products.ts                         # Portfolio product data
└── scripts/
    └── generate-css.ts                     # Reads YAML themes → writes design-system.generated.css
```
