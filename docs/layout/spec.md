# spec/ — Specification & Design

```
spec/
├── api-reference/                    # macOS API research notes
│   ├── assets/                       #   Supporting assets
│   ├── 01-nsevent-global-monitoring.md
│   ├── 02-nswindow-floating-windows.md
│   ├── 03-nsapplication-activation-policy.md
│   ├── 04-swiftui-view-lifecycle.md
│   └── GUIDELINES.md                #   API reference conventions
├── personas/                         # Target user archetypes
│   ├── developer.md                 #   Primary persona
│   └── knowledge-worker.md          #   Secondary persona
├── solution-analysis/                # 10 technical solution documents
│   ├── 01-nspasteboard-api.md       #   NSPasteboard usage
│   ├── 02-global-hotkeys.md         #   Hotkey implementation
│   ├── 03-swiftui-popup.md          #   SwiftUI popup patterns
│   ├── 04-background-daemon.md      #   Background daemon lifecycle
│   ├── 05-clipboard-types.md        #   Type detection
│   ├── 06-sqlite-persistence.md     #   SQLite integration
│   ├── 07-sandboxing.md             #   Sandboxing considerations
│   ├── 08-app-bundle.md             #   App bundle structure
│   ├── 09-launch-agents.md          #   LaunchAgents/Daemons
│   └── 10-ux-patterns.md            #   UX patterns
├── style-guide/                      # Visual design reference
│   ├── style-guide.md               #   Master style guide
│   ├── style-guide-components.md    #   Component specs
│   ├── style-guide-elements.md      #   Element specs
│   ├── style-guide.html             #   Interactive HTML preview
│   ├── style-guide-canvas.html      #   Canvas render preview
│   └── *.png                        #   Mockup screenshots (23 images)
├── user-stories/                     # 158 BDD-formatted user stories
│   ├── SCHEMA.md                    #   Story format definition
│   ├── stories.yaml                 #   Machine-readable story index
│   └── US-001.md … US-158.md       #   Individual stories
├── 00-overview-architecture.md       # System architecture overview
├── 00a-roadmap.md                    # Development roadmap
├── 01-keyboard-chords.md             # Keyboard chord system
├── 02-clipboard-history-panel.md     # History panel spec
├── 03-favorites-tagging.md           # Favorites & tagging
├── 04-macroization-system.md         # Macro system
├── 05-search.md                      # Search functionality
├── 06-provenance-usage-tracking.md   # Usage tracking
├── 07-llm-snippet-library.md         # LLM snippet library
├── 08-editing.md                     # Editing features
├── 09-smart-formatting-paste-modes.md # Smart paste modes
├── 10-image-support.md               # Image handling
├── 11-menu-bar-interface.md          # Menu bar UI
├── 12-sync-system.md                 # Cross-device sync
├── 13-additional-features.md         # Misc features
├── 14-technical-architecture.md      # Technical deep-dive
├── 15-monetization.md                # Monetization strategy
├── asset-manifest.md                 # Design asset inventory
├── CONSTANTS.yaml                    # Shared constants
├── story-grid.md                     # Story overview grid
└── user-stories-review.md            # Multi-perspective story review
```
