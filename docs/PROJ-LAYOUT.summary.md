# Project Layout — Summary

```
therobotlives.com/
├── design/                         # Visual direction and brand assets
│   ├── direction-{a..d}-*.*       #   4 design directions (md + html)
│   ├── logos/                     #   SVG logos, marks, favicon
│   │   └── concepts/             #     Logo concept explorations
│   └── README.md
├── docs/                           # Project documentation
├── helm/therobotlives/             # Helm chart for K8s deployment
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/                 #   deployment, ingress, service, tls
├── web/                            # Next.js application
│   ├── src/app/                   #   App Router (layout, page, waitlist-form)
│   ├── public/                    #   Static assets
│   ├── Dockerfile                 #   Multi-stage build
│   ├── nginx.conf                 #   Production proxy
│   └── package.json
├── .gemini/                        # Gemini Code Assist config
├── .gitignore
└── README.md                       # Product spec and overview
```
