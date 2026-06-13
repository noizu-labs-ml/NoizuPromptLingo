# Architecture Summary

IoTGo is an autonomous AI agent layer for IoT fleet management, designed to sit on top of existing platforms (AWS IoT, Azure IoT Hub, ThingsBoard) and close the detect-act loop with persistent, goal-oriented agents.

**Current state:** Pre-development concept. Only a Next.js 16 static landing page is deployed.

## Deployed Architecture

Single-container static site: Next.js 16 static export served by nginx:alpine, deployed to self-hosted K8s via Helm chart (v0.1.0). One replica, Cloudflare-only ingress, TLS via Infisical Operator.

## Target Architecture

Nine planned components: Fleet Connection Layer (MQTT/HTTP/cloud ingest), Telemetry Pipeline, Anomaly Detection Engine (unsupervised ML), Agent Runtime (persistent goal-oriented processes), Playbook Engine (YAML-defined constrained actions), Action Execution Layer (canary deploys, rollback, audit), Agent Studio UI, REST/GraphQL API, and backing data stores (time-series DB, PostgreSQL, Redis).

## Technology Stack

Next.js 16, React 19, Tailwind CSS 4, TypeScript 5. Container: node:22-alpine build, nginx:alpine runtime. K8s with NGINX Ingress, Cloudflare IP whitelist, Infisical TLS sync. Private registry at ops.noizu.com.

## Key Decisions

Static export over SSR (no dynamic data). Cloudflare-only ingress (all noizu.com services). Infisical for TLS (cluster-wide pattern). No backend yet (concept validation first).

## Open Questions

Edge vs. cloud agents. Playbook safety guarantees. Multi-tenant isolation. LLM boundary in agent decisions. Integration depth (deep on 3-4 platforms vs. shallow on 20).
