# design/ — Design Assets

```
design/
├── logos/                              # Brand identity
│   ├── mcp-host-logomark.svg           #   Primary logomark (color)
│   ├── mcp-host-logomark-mono.svg      #   Monochrome variant
│   ├── mcp-host-logomark-reversed.svg  #   Reversed (light on dark)
│   ├── mcp-host-combo.svg              #   Logomark + wordmark combo
│   ├── justmcp-it-lockup.svg           #   JustMCP.it brand lockup
│   ├── mcp-jumpstart-lockup.svg        #   MCP Jumpstart brand lockup
│   └── safemcp-lockup.svg              #   SafeMCP brand lockup
├── theme/                              # Source-of-truth theme definitions
│   ├── theme-bold/                     #   Bold — high contrast, strong type
│   ├── theme-enterprise/               #   Enterprise — conservative, trust-focused
│   ├── theme-minimal/                  #   Minimal — clean, restrained
│   └── theme-nocturne/                 #   Nocturne — dark-first, developer-oriented
├── wireframes/                         # Page wireframes (SVG)
│   ├── justmcp-landing.svg             #   JustMCP.it landing page
│   ├── deploy-dashboard.svg            #   Server deployment dashboard
│   ├── registry-search.svg             #   MCP registry search view
│   └── safemcp-policy-editor.svg       #   SafeMCP policy editor
├── SITEMAP.md                          # Full page flow diagram and route inventory
├── STYLE-DIRECTION.md                  # Direction A — primary exploration
├── STYLE-DIRECTION-B.md                # Direction B
├── STYLE-DIRECTION-C.md                # Direction C
└── STYLE-DIRECTION-D.md                # Direction D
```

## Theme YAML Structure

Each theme directory contains 12 files driving the design system:

| File | Controls |
|------|----------|
| `branding.yaml` | Logo, brand name, tagline |
| `style-guide.meta.yaml` | Theme metadata and version |
| `style-guide.color-palette.yaml` | Raw color definitions |
| `style-guide.color-modes.yaml` | Light/dark mode mappings |
| `style-guide.typography.yaml` | Font families, scales, weights |
| `style-guide.spacing.yaml` | Spacing scale |
| `style-guide.vars.yaml` | CSS custom property definitions |
| `style-guide.globals.yaml` | Global element styles |
| `style-guide.semantic-classes.yaml` | Semantic utility classes |
| `style-guide.semantic-groups.yaml` | Grouped semantic tokens |
| `style-guide.shell-layouts.yaml` | App shell layout patterns |
| `style-guide.page-layouts.yaml` | Page-level layout patterns |

Theme files in `design/theme/` are the source of truth; copies in `app/frontend/src/config/` are consumed by the CSS generator.
