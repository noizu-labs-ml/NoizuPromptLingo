---
id: US-044
title: "Generated project includes Docker and Kubernetes manifests"
slug: "docker-k8s-manifests"
personas: [P-002, P-001]
epic: "MCP Jumpstart"
priority: "should-have"
complexity: "M"
tags: [mcp-jumpstart, scaffolding, docker, kubernetes, deployment]
---

# US-044: Generated Project Includes Docker and Kubernetes Manifests

## User Story

**As a** Platform Engineer (P-002),
**I want to** the generated MCP project to include production-ready Docker and Kubernetes manifests,
**So that** I can deploy the MCP server to a Kubernetes cluster with minimal customization.

## Acceptance Criteria

- [ ] Given a project is generated (US-041), when the user examines the deployment files, then it includes a `Dockerfile` with multi-stage build, non-root user, health check endpoint, and a `.dockerignore` file.
- [ ] Given the Dockerfile is present, when the user runs `docker build`, then it builds successfully using the language-appropriate base image and produces a minimal production image.
- [ ] Given a project is generated, when the user examines the Kubernetes manifests, then it includes a `k8s/` directory with `deployment.yaml`, `service.yaml`, `configmap.yaml`, and `ingress.yaml` (if SSE/WebSocket transport is selected).
- [ ] Given the Kubernetes deployment manifest, when the user inspects it, then it includes resource requests and limits (CPU/memory), liveness and readiness probes, and security context (read-only filesystem, drop all capabilities).
- [ ] Given the Kubernetes manifests, when the user customizes the deployment, then placeholder values are clearly marked with comments (e.g., `# REPLACE: your registry/image`) and a `kustomization.yaml` or Helm `values.yaml` is provided for overrides.
- [ ] Given the generated project README, when the user reads the deployment section, then it includes step-by-step instructions for building the image, pushing to a registry, and deploying with `kubectl` or Helm.

## Notes

Kubernetes manifests should follow security best practices by default (non-root, read-only filesystem, resource limits). The manifests should be compatible with the MCP Host platform's sandbox model. Related: US-041 (generation), US-042 (transport affects ingress config).
