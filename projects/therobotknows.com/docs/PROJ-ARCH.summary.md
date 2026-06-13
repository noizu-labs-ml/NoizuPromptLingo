# Project Architecture — Summary

AI-powered knowledge base for creative world-building. Frontend prototype (Next.js 16 static export) with mock data — no backend or LLM integration yet.

## Core Components

- **Next.js Frontend**: App Router SPA with dashboard and universe-scoped route groups
- **D3.js Knowledge Graph**: Force-directed visualization of entries and connections
- **Consistency Engine**: UI for contradiction flags (logic mocked)
- **Generation Studio**: AI lore generation interface (no LLM wiring)
- **nginx**: Static file server in Docker multi-stage container

## Domain Model

Five entity types: Universe → Entry → Connection, plus Flag (consistency issues) and Generation (AI output). Entry types: character, location, event, faction, object, concept, rule. Entry statuses: canon, generated. Flag severities: error, warning, suggestion.

## Technology Stack

Next.js 16, React 19, Tailwind CSS v4, D3.js, Lucide icons, Google Fonts (Lora, Source Serif 4, Inter, JetBrains Mono). Docker multi-stage build (Node 22 → nginx:alpine).

## Visual Design

"Vellum & Ink" — editorial aesthetic with warm parchment tones, serif headings, monospace metadata, amber/gold accents.

## Key Decisions

Static export (no backend yet), mock data modules (swap for API later), D3.js for graph control, Tailwind v4 for rapid prototyping, seven entry-type taxonomy for world-building primitives.
