# web/ — Next.js Application

Next.js 16 (App Router) with React 19, Tailwind CSS v4, D3.js force-directed graph. Currently a frontend prototype with mock data.

```
web/
├── src/
│   ├── app/
│   │   ├── (dashboard)/                # Route group — dashboard pages
│   │   │   ├── page.tsx                #   / — universe list + recent activity
│   │   │   ├── about/page.tsx          #   /about
│   │   │   ├── new/page.tsx            #   /new — create universe
│   │   │   └── layout.tsx              #   Dashboard shell (top bar)
│   │   ├── (universe)/                 # Route group — universe pages
│   │   │   ├── [universeId]/
│   │   │   │   ├── page.tsx            #   Universe overview
│   │   │   │   ├── entries/page.tsx    #   Entry list with type/era filters
│   │   │   │   ├── entries/[entryId]/page.tsx  # Entry detail + connections
│   │   │   │   ├── graph/page.tsx      #   D3.js knowledge graph
│   │   │   │   ├── timeline/page.tsx   #   Chronological timeline
│   │   │   │   ├── generate/page.tsx   #   AI generation studio
│   │   │   │   ├── consistency/page.tsx #  Consistency flag queue
│   │   │   │   └── layout.tsx          #   Universe shell (sidebar + status bar)
│   │   │   └── layout.tsx              #   Universe route group layout
│   │   ├── globals.css                 #   Tailwind v4 + Vellum & Ink theme
│   │   └── layout.tsx                  #   Root layout (html, fonts, metadata)
│   │
│   ├── components/
│   │   ├── consistency/
│   │   │   └── flag-card.tsx           # Consistency flag display + resolution
│   │   ├── entries/
│   │   │   ├── entry-card.tsx          # Entry card for list views
│   │   │   ├── entry-connections.tsx   # Related entries panel
│   │   │   ├── entry-detail.tsx        # Full entry view
│   │   │   ├── entry-filters.tsx       # Type/era/region filter controls
│   │   │   └── entry-type-icon.tsx     # Icon per entry type (character, location, etc.)
│   │   ├── generation/
│   │   │   ├── generation-form.tsx     # Generation prompt + settings
│   │   │   ├── generation-output.tsx   # Generated content display
│   │   │   ├── recent-generations.tsx  # Generation history list
│   │   │   └── source-list.tsx         # Canon sources the AI will reference
│   │   ├── graph/
│   │   │   ├── knowledge-graph.tsx     # D3.js force-directed graph (main)
│   │   │   ├── graph-controls.tsx      # Zoom, filter, layout controls
│   │   │   └── graph-legend.tsx        # Canon/generated/flagged legend
│   │   ├── layout/
│   │   │   ├── knowledge-base-logo.tsx # SVG logo component
│   │   │   ├── sidebar.tsx             # Universe navigation sidebar
│   │   │   ├── sidebar-entry-list.tsx  # Entry quick-nav in sidebar
│   │   │   ├── status-bar.tsx          # Bottom status (entry count, flags)
│   │   │   └── top-bar.tsx             # Dashboard top navigation
│   │   ├── timeline/
│   │   │   └── timeline-item.tsx       # Single timeline event
│   │   └── ui/
│   │       ├── index.ts                # Barrel export
│   │       ├── badge.tsx               # Status/type badges
│   │       ├── button.tsx              # Button variants
│   │       ├── card.tsx                # Content card
│   │       ├── input.tsx               # Text input
│   │       ├── search-input.tsx        # Search with icon
│   │       ├── select.tsx              # Dropdown select
│   │       └── textarea.tsx            # Multi-line text input
│   │
│   ├── data/                           # Mock data (prototype phase)
│   │   ├── connections.ts              #   Entry-to-entry relationships
│   │   ├── entries.ts                  #   Sample canon + generated entries
│   │   ├── flags.ts                    #   Consistency flags
│   │   ├── generations.ts             #   Generation history
│   │   └── universes.ts               #   Universe metadata
│   │
│   ├── lib/
│   │   ├── cn.ts                       # clsx + tailwind-merge utility
│   │   ├── constants.ts                # App constants (entry types, colors)
│   │   └── mock-data.ts                # Aggregate mock data helpers
│   │
│   └── types/
│       ├── entry.ts                    # Entry, EntryType, EntryStatus
│       ├── flag.ts                     # ConsistencyFlag, Severity
│       ├── generation.ts               # Generation request/response types
│       └── universe.ts                 # Universe project type
│
├── public/
│   └── favicon.svg                     # Site favicon
├── .tool-versions                      # asdf — nodejs 22.22.0
├── .gitignore
├── build.sh                            # Docker build script
├── Dockerfile                          # Multi-stage build (Node → nginx)
├── nginx.conf                          # Production static serving config
├── package.json                        # Dependencies + scripts
├── next.config.ts                      # Next.js configuration
├── postcss.config.mjs                  # PostCSS with @tailwindcss/postcss
└── tsconfig.json                       # TypeScript strict config
```
