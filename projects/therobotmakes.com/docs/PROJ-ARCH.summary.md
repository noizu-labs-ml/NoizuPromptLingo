# Architecture Summary

## Overview

therobotmakes.com hosts noizu.ink, a guided pipeline for idea-to-product development. Currently in pre-development/concept stage with static HTML design explorations and bare Next.js scaffolds. The target system follows a 4-phase pipeline: Sketch (Plan) -> Draft (Design) -> Ink (Build) -> Publish (Ship).

## Core Components

- Static HTML Styleguides: 5 themed component showcases (blueprint, brush, cyberpunk, sumi-e, swiss) — built
- Template Assets: Shared CSS/JS for styleguide rendering (hui.css, sg.css, sg.js) — built
- Root Styleguide HTMLs: Self-contained single-file theme previews (v1/v2 per theme) — built
- Next.js Scaffolds: Two bare apps (web/, web.sumi-e/) with default layout, page, globals.css — scaffold only
- Project Management: 10 personas and 47 user stories (INK-001 through INK-047) — built
- FastAPI Backend, Agent Orchestrator, TimescaleDB — all planned, not yet implemented

## Theme System

Five design directions explored as standalone HTML/CSS directories. Each has per-component showcase pages and a shared style.css. Brush theme is most complete with 7 full-page screen mockups. Shared template/ directory provides base UI, styleguide layout, and theme switching JS. Root-level styleguide-*.html files are self-contained single-file previews.

A React-based theme system with CSS custom properties, ThemeProvider, and 14 components x 5 themes is planned but not yet implemented.

## UX Architecture

Target: phase-based navigation wizard with distinct visual treatments. Sketch/Draft use light backgrounds; Ink uses dark backgrounds. Global theme toggle planned. Target component hierarchy: Theme Layer -> Base Components -> Shared Sections -> App Router Pages (100 components total). Currently no custom React components exist.

## Technology Stack

Current: Static HTML/CSS themes (no build step), Next.js 15 scaffolds (TypeScript), Node.js 22.22.0, Docker-ready (Dockerfile + nginx.conf per web app).

Planned: FastAPI backend, TimescaleDB, Elixir/OTP agent runtime, Claude API, Docker sandbox containers.

## Design Principles

Editorial First: Serif headings, generous leading. Minimal Tech: Mono font for code. Bounded Context: Clear pipeline step boundaries. User Control: Approve/reject at boundaries. Token Economy: Structured inputs, cacheable prompts.

## Key Decisions

Static HTML themes first for design validation without build complexity. Next.js App Router for file-based routing, Server Components, and Vercel alignment. CSS Modules planned for theme isolation and designer-friendly workflow. 5 fixed themes to start, dynamic generation planned for later versions.
