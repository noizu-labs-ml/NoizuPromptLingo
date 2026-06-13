# Physics Engine

## Overview

A custom Elixir-based spatial simulation that models the game world's physical properties. Each physics-relevant entity runs as an OTP process. The engine simulates, but never renders visually — all output flows through the AI narrator as structured prose.

## Simulation Systems

| System | Description |
|--------|-------------|
| **Spatial** | 3D positions, distances, line-of-sight, room geometry |
| **Kinetic** | Force, momentum, collision, ricochet, knockback |
| **Environmental** | Weather, temperature, light level, sound propagation |
| **Material** | Object properties — weight, breakability, flammability, conductivity |

## Architecture

Each room and significant physics object runs as an OTP `GenServer`:

- **Room process**: Maintains spatial model of all entities within it
- **Object processes**: Track individual state (position, velocity, material degradation)
- **Player processes**: Track player position, orientation, and physics interactions
- **Tick-based updates**: Physics steps run on a configurable interval, emitting events on state change

## Output Contract

The physics engine emits structured events (Elixir structs) consumed by the GenAI narrator. Raw simulation data never reaches the client:

```
Physics Engine (Elixir)  ->  Structured Events  ->  AI Narrator  ->  Prose  ->  ARIA Live Region
```

## Interaction Examples

| Player Action | Physics Simulation | Narrative Output |
|--------------|-------------------|-----------------|
| "throw stone at lantern" | Calculate trajectory, check line-of-sight, resolve collision, trigger secondary effects (oil splash, fire) | "Your stone arcs across the room, catches the lantern dead center — glass shatters, oil sprays across the wall, and flames bloom orange in the dark" |
| "listen" | Sample sound propagation model, check for sources within range, apply environmental filters | "Water drips somewhere ahead. Farther — boots on stone, irregular rhythm, getting closer" |
| "push bookshelf" | Check player strength vs. object weight, simulate topple physics, check for entities in fall path | "The bookshelf groans, tilts — books cascade in a thundering wave — and the whole thing slams flat across the doorway. Nothing's getting through there now" |
