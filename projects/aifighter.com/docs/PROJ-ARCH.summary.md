# Project Architecture — Summary

AI Fighter: mobile game where players design neural-net decision graphs for async PvP combat. Concept stage with live waitlist site.

**Current**: Next.js 16 static export → nginx Docker container → K8s (Noizu cluster) → Cloudflare CDN at aifighter.com.

**Planned MVP**: Mobile client (Unity/Godot) + server-side battle simulation (Rust/Go) + Postgres/Redis backend. Five subsystems: Fighter Studio (graph editor), Training Gym (sparring sim), Arena (async PvP + ELO), Laboratory (community), Battle Engine (deterministic server-side resolution).

**Design**: "Neural Neon" dark theme — electric mint (#00FFAA), hot pink (#FF3366), electric blue (#3366FF). Monument Extended + Inter + JetBrains Mono typography.

**Key decisions**: Static export (no dynamic content yet), server-side battle sim (anti-cheat), JSON graph format (portable fighter definitions), async-first PvP (mobile-friendly).

**Stack**: Next.js 16.1.6, React 19.2.3, Tailwind 4, Node 22, nginx:alpine, Docker, Kubernetes, Cloudflare.
