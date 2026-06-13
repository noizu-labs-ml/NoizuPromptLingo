# Project Layout Summary

```
therobotmakes.com/
├── blueprint/                      # Blueprint theme showcases + CSS
├── brush/                          # Brush (ink/calligraphy) theme
├── cyberpunk/                      # Cyberpunk theme
├── sumi-e/                         # Sumi-e (Japanese ink) theme
├── swiss/                          # Swiss (modernist) theme
├── template/                       # Shared styleguide template assets
│   ├── hui.css
│   ├── sg.css
│   └── sg.js
├── web/                            # Next.js application (primary)
│   ├── src/app/
│   ├── public/
│   ├── Dockerfile
│   ├── build.sh
│   ├── nginx.conf
│   └── package.json
├── web.sumi-e/                     # Next.js application (sumi-e variant)
├── project/                        # Project management
│   ├── personas/                   #   10 persona definitions
│   └── user-stories/               #   100 user stories (INK-001..100)
├── docs/                           # Documentation
│   ├── PROJ-ARCH.md
│   ├── PROJ-LAYOUT.md
│   └── arch/
├── .claude/                        # Claude Code config
│   ├── agents/
│   └── commands/
├── .gemini/                        # Gemini Code Assist config
├── styleguide-*.html               # Standalone HTML style guides
├── styleguide-components.css       # Shared component styles
├── styleguide-components.js        # Shared component JS
├── .gitignore
├── .tool-versions                  # Node.js 22.22.0
└── README.md
```
