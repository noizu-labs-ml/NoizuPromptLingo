# Architecture Summary

**Project:** Gotta.cc — AI-curated web directory
**Status:** Pre-launch landing page with waitlist capture
**Stage:** Concept / pre-development

## Current Architecture

Static Next.js 16 landing page exported to HTML and served by Nginx in a Docker container. No backend. Waitlist form POSTs directly from the browser to an external Listmonk instance at listmonk.noizu.com.

## Stack

Next.js 16 (static export), React 19, Tailwind CSS 4, TypeScript 5, Node.js 22, Docker multi-stage (node:22-alpine -> nginx:alpine), Listmonk (email), Cloudflare (DNS/TLS planned).

## Components

- **Landing page**: Product pitch + waitlist signup (web/src/app/)
- **Container**: Two-stage Docker build, Nginx serving static files with gzip + security headers
- **Design assets**: Logo SVGs + 3 visual direction mockups (design/)

## Data Flow

Browser fetches static HTML from Nginx. Waitlist form POSTs to Listmonk public API. No server-side processing.

## Deployment

Not yet deployed. Target: noizu.com K8s cluster via Helm (Pattern A). No Helm chart exists.

## Planned (Not Built)

LLM scoring pipeline, category taxonomy, submission pipeline, community features, search, public API. Deferred until landing page validates interest.

## Key Decisions

Static export over SSR. Direct browser-to-Listmonk (no proxy). Nginx over Node.js serving. Design direction not yet selected.
