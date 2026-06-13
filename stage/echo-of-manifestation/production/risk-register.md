# Echo of Manifestation — Risk Register

Key technical and production risks with mitigation strategies.

| Challenge | Risk | Mitigation |
|-----------|------|-----------|
| **Procedural zone generation with consistent macro-structure** | High — rooms must feel hand-crafted while being assembled procedurally; hallway connections must never create impossible geometry | Template-based generation with validated connection graphs. Each room template has entry/exit sockets that only connect to compatible sockets. 200+ playtest runs during alpha to validate generation quality. |
| **Chimera AI for 27 types with distinct behaviors tied to item echoes** | Medium — each chimera mirrors a specific item; AI must feel like a "warped version" of the item's function | Modular AI: base behavior tree (patrol, aggro, combat) + echo-specific module (Shadow Blade gets lunging attacks, Shadow Wall gets barrier-placement behavior). Echo module is a plug-in, not a full rewrite. |
| **Grand Manifestation adaptive boss that mirrors player's most-used item** | High — boss must dynamically change combat pattern based on tracked player statistics | Pre-built boss phases for each item category (8 phases). At encounter start, game queries run statistics and loads the appropriate phase as primary. Remaining phases available as secondary attacks. No procedural boss generation. |
| **Twilight Zone lighting and volumetric shadows on minimum spec** | High — UE5 Lumen + Nanite may not run at 30 FPS on GTX 1660 | Scalability tiers: Low uses baked lighting + traditional LOD. Lumen/Nanite only on Medium+. Minimum spec validated monthly from month 3. Switch uses custom lightweight shadow shader pipeline. |
| **Insight persistence across runs (meta-progression data integrity)** | Low — standard save-game persistence | Cloud save support (Steam Cloud, PlayStation Plus, Xbox Live). Local backup on PC. Corruption recovery from last 3 saves. |
| **Switch performance with 27 chimera types and procedural generation** | Medium — memory budget is tight; 4 GB RAM limits simultaneous entity count | Aggressive entity culling (only chimeras within 40m loaded). Reduced particle effects. Simplified shadow rendering. Target 30 FPS with occasional dips during heavy combat (acceptable per Switch performance guidelines). |
