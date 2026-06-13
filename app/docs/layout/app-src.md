# app/src/ — Source Code

## App Router (`app/`)

```
src/app/
├── api/
│   └── save-config/
│       └── route.ts                # POST endpoint — save config changes
├── section/
│   └── [name]/
│       └── page.tsx                # Dynamic route — per-section view
├── design-system.generated.css     # [generated] Full design system CSS
├── globals.css                     # Tailwind imports + custom global styles
├── layout.tsx                      # Root layout
└── page.tsx                        # Home page — full style guide view
```

## Components (`components/`)

```
src/components/
├── demos/                          # Interactive form/toast demos
│   ├── CheckboxRadioDemo.tsx
│   ├── FormFieldDemos.tsx
│   ├── FormValidationDemo.tsx
│   └── ToastsDemo.tsx
├── generated/                      # [generated] Auto-built components
│   └── demo.tsx
├── pkg/                            # Reusable primitive components (35 files)
│   ├── btn.tsx                     #   Button primitive
│   ├── card.tsx / card-grid.tsx    #   Card + grid layout
│   ├── color-swatch.tsx            #   Color display
│   ├── input-field.tsx             #   Form input
│   ├── screen-frame.tsx            #   Screen/device frame
│   ├── section-header.tsx          #   Section chrome
│   ├── token-card.tsx              #   Design token display
│   ├── type-specimen.tsx           #   Typography specimen
│   └── ... (27 more primitives)
├── sections/                       # Top-level style guide sections
│   ├── index.ts                    #   Section registry
│   ├── ink-effects.tsx             #   Ink/wash visual effects (sumi-e)
│   ├── interaction.tsx             #   Interactive elements section
│   ├── reference.tsx               #   Reference section
│   ├── screens.tsx                 #   Screen/viewport showcases
│   ├── structure.tsx               #   Structure/layout section
│   ├── visual-foundation.tsx       #   Colors, typography, spacing
│   └── section-props.ts            #   Shared section prop types
├── ButtonPreview.tsx               # Component showcases (root-level)
├── ButtonShowcase.tsx
├── CardPreview.tsx
├── CardShowcase.tsx
├── CodeBlockShowcase.tsx           #   Code block rendering
├── CollapsibleSection.tsx
├── ColorModeToggle.tsx
├── ColorPalette.tsx
├── CssViewer.tsx
├── DesignSectionShowcase.tsx
├── DesignTokens.tsx
├── DividerShowcase.tsx
├── FormsShowcase.tsx
├── GlyphShowcase.tsx
├── GridVisualizer.tsx
├── HUIShowcase.tsx
├── IntroHero.tsx
├── LayoutBar.tsx
├── NavigationShowcase.tsx
├── OverrideManager.tsx             # YAML override editor
├── PageContent.tsx
├── PageLayoutReference.tsx
├── PageLayoutSummary.tsx
├── SearchFilter.tsx
├── SectionGroup.tsx
├── SemanticClassReference.tsx
├── SemanticClassSelect.tsx
├── SemanticClassSummary.tsx
├── SemanticSelectionContext.tsx
├── ShellChrome.tsx
├── ShellLayoutShowcase.tsx
├── ShellLayoutSummary.tsx
├── SiteLayoutShowcase.tsx
├── SnippetShowcase.tsx
├── SpacingShowcase.tsx
├── StatusIndicatorShowcase.tsx
├── StyleCard.tsx
├── StyleInjector.tsx               # Injects generated CSS at runtime
├── TerminalShowcase.tsx            #   Terminal/CLI rendering
├── ThemeAwareSectionContent.tsx    #   Per-theme section rendering
├── ThemeAwareSections.tsx          #   Theme-aware section wrapper
├── ThemeConfigContext.tsx
├── ThemeLogo.tsx                   #   Per-theme logo rendering
├── TypographyShowcase.tsx
├── UIElementsShowcase.tsx
└── YamlConfigViewer.tsx            # Config viewer/editor
```

## Config (`config/`)

```
src/config/
├── theme-style-guide/              # Default theme — 21 YAML facets + overrides
│   ├── branding.yaml               #   Brand identity tokens
│   ├── style-guide.vars.yaml       #   Design variables
│   ├── style-guide.color-palette.yaml
│   ├── style-guide.color-modes.yaml
│   ├── style-guide.typography.yaml
│   ├── style-guide.spacing.yaml
│   ├── style-guide.globals.yaml
│   ├── style-guide.semantic-classes.yaml
│   ├── style-guide.semantic-groups.yaml
│   ├── style-guide.shell-layouts.yaml
│   ├── style-guide.page-layouts.yaml
│   ├── style-guide.page-sections.yaml
│   ├── style-guide.design-sections.yaml
│   ├── style-guide.css-snippets.yaml
│   ├── style-guide.jsx-snippets.yaml
│   ├── style-guide.glyphs.yaml
│   ├── style-guide.meta.yaml
│   ├── style-guide.scoped-vars.yaml
│   ├── style-guide.overrides.yaml
│   └── *.user.yaml                 #   User override layers
├── theme-cyberpunk/                # Cyberpunk theme — 16 YAML facets
│   ├── branding.yaml
│   └── style-guide.*.yaml          #   Same facet structure as default
├── theme-sumi-e/                   # Sumi-e ink-wash theme — 16 YAML facets
│   ├── branding.yaml
│   └── style-guide.*.yaml          #   Same facet structure as default
├── branding-loader.ts              # Loads branding YAML at build time
└── loader.ts                       # Loads + merges all config facets per theme
```

## Lib (`lib/`)

```
src/lib/
├── css-gen/                        # 23 CSS generator modules
│   ├── index.ts                    #   Generator orchestrator
│   ├── vars.ts                     #   CSS custom properties
│   ├── tokens.ts                   #   Design token classes
│   ├── typography.ts               #   Type scale rules
│   ├── spacing.ts                  #   Spacing utilities
│   ├── buttons.ts                  #   Button styles
│   ├── cards.ts                    #   Card component styles
│   ├── code-terminal.ts            #   Code block + terminal styles
│   ├── css-snippets.ts             #   User-defined CSS snippets
│   ├── defaults.ts                 #   Default/fallback styles
│   ├── dividers.ts                 #   Divider/separator styles
│   ├── forms.ts                    #   Form element styles
│   ├── globals.ts                  #   Global base styles
│   ├── hui-interactive.ts          #   Interactive HUI elements
│   ├── indicators.ts               #   Status indicator styles
│   ├── layout.ts                   #   Grid/layout rules
│   ├── branding.ts                 #   Brand token generation
│   ├── scoped-vars.ts              #   Scoped CSS variable blocks
│   ├── sections.ts                 #   Section-level styles
│   ├── semantic.ts                 #   Semantic class mappings
│   ├── shells.ts                   #   Shell/chrome styles
│   ├── swatches.ts                 #   Color swatch styles
│   └── utilities.ts                #   Utility classes
├── jsx-gen/                        # JSX generation
│   ├── index.ts                    #   JSX generator orchestrator
│   └── collate-imports.ts          #   Import deduplication
├── types.ts                        # Shared TypeScript types
├── normalizer.ts                   # Config normalization
├── topo-sort.ts                    # Topological sort for dependency ordering
├── css-cache.ts                    # Generated CSS caching
├── accent-styles.ts                # Accent color computation
├── section-context.ts              # React context for sections
├── section-cookie.ts               # Section state persistence
└── use-monaco-theme.ts             # Monaco editor theme hook
```

## Scripts (`scripts/`)

```
src/scripts/
├── generate-css.ts                 # Main CSS generation entry point
└── watch-yaml.ts                   # File watcher for dev-time regeneration
```
