---
id: US-032
title: "Dynamic weather system"
slug: "weather-system"
personas: [P-001, P-002]
epic: "World State Manager"
priority: "could-have"
complexity: "M"
tags: [world-state, weather, atmosphere, environment]
---

# US-032: Dynamic Weather System

## User Story

**As a** narrative designer crafting immersive IF experiences (P-002),
**I want to** attach a dynamic weather model to locations that evolves over time and responds to world events,
**So that** the Narrative Engine can include current weather in prompts, enriching prose atmosphere without manual per-scene configuration.

## Acceptance Criteria

- [ ] Given a location with a weather profile (e.g. `{"base_climate": "temperate", "storm_probability": 0.2}`), when I call `world.get_weather(location_id, tick)`, then a `WeatherState` object is returned with fields `condition`, `intensity`, and `description`.
- [ ] Given a weather state at tick T, when I advance to tick T+1 via `world.advance_tick()`, then weather conditions evolve according to the climate profile with appropriate probabilistic transitions (e.g. clear → overcast before storm).
- [ ] Given a world event tagged `"volcanic_eruption"`, when it is recorded on the timeline for a region, then nearby location weather states incorporate `ashfall` condition for a configurable duration.
- [ ] Given a location with current weather, when the Narrative Engine assembles context, then the weather description is available as a named context variable (`{{weather}}`).
- [ ] Given weather disabled via `world.config.weather_enabled = False`, when I call `world.get_weather(location_id, tick)`, then `None` is returned and no weather block appears in context assembly.

## Notes

Weather is atmospheric enrichment, not core game logic, hence `could-have` priority. P-002 uses weather to set scene tone; P-001 may use it to gate certain quest triggers. Depends on US-026 (locations) and US-029 (timeline).
