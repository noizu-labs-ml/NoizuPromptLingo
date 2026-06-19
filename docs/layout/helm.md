# helm/ — Kubernetes Deployment

```
helm/
└── npl-mcp/                    # Helm chart for the MCP server
    ├── templates/
    │   ├── _helpers.tpl        #   Template helper functions
    │   ├── deployment.yaml     #   Deployment spec (Elixir + Next.js containers)
    │   ├── hpa.yaml            #   Horizontal Pod Autoscaler
    │   ├── ingress.yaml        #   Ingress rules (subdomain routing)
    │   ├── pdb.yaml            #   Pod Disruption Budget
    │   ├── service.yaml        #   ClusterIP service
    │   └── tls-secret.yaml     #   TLS certificate secret
    ├── .helmignore
    ├── Chart.yaml              #   Chart metadata + version
    └── values.yaml             #   Default values (image tags, replicas, resources)
```
