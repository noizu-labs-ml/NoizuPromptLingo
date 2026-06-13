# Project Layout Summary

```
iotgo.io/
├── design/
│   ├── logos/              # SVG logo variants
│   ├── direction-*.md/html # 3 style guide explorations
│   └── README.md           # Decision framework
├── helm/
│   └── iotgo/
│       ├── templates/      # K8s manifests
│       ├── Chart.yaml
│       └── values.yaml
├── web/
│   ├── public/             # Static assets
│   ├── src/app/            # Next.js App Router pages
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
├── docs/
│   ├── PROJ-LAYOUT.md
│   ├── PROJ-LAYOUT.summary.md
│   └── layout/
│       ├── design.md
│       └── web.md
├── .gemini/                # Gemini Code Assist config
├── .gitignore
└── README.md
```
