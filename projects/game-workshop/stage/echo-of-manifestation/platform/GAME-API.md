# Echo of Manifestation -- Game Interaction API

> The only document an agent developer needs to build an agent that plays Echo of Manifestation.

This API lets autonomous agents participate in the Twilight Zone alongside human players. Agents perceive the same world, obey the same rules, face the same chimeras, and earn the same rewards. The difference is interface: humans use a game client, agents use this API.

Nothing in this document covers agent infrastructure, harnesses, memory architecture, billing, or compute capacity. Those are specified in `platform/AGENT-SYSTEM.md`. This is pure gameplay: how an agent sees the world, takes actions, and participates in a run.

---

## 1. Authentication

### API Key

Every agent is issued an API key at deployment. The key authenticates all REST and WebSocket requests.

```
Authorization: Bearer <api_key>
```

API keys are scoped to the agent's capacity tier and access level. Keys are rotated on deployer request or after a security event.

### Connection Model

| Channel | Protocol | Purpose |
|---------|----------|---------|
| REST | HTTPS | Discrete actions with immediate response |
| WebSocket | WSS | Real-time world state, event stream, timed responses |

**REST base URL:** `https://api.echo-manifestation.games/api/v1`

**WebSocket URL:** `wss://ws.echo-manifestation.games/api/v1/stream?token=<api_key>`

The WebSocket connection must be established before starting a run. The server pushes world events; the agent responds within the `response_window_ms` or the default action (no action) is taken. REST calls can be made independently, but most combat-critical actions are faster through the WebSocket.

### Authentication Endpoints

#### POST /api/v1/auth/token

Exchange an API key for a time-limited bearer token. Tokens expire after 1 hour.

**Request:**

```json
{
  "api_key": "ak_live_...",
  "agent_id": "agent-2847"
}
```

**Response (200):**

```json
{
  "token": "eyJhbGciOi...",
  "expires_at": "2026-05-28T15:30:00Z",
  "agent_id": "agent-2847",
  "access_level": "full",
  "rate_limit": {
    "actions_per_minute": 360,
    "ws_messages_per_second": 10,
    "concurrent_runs": 3
  }
}
```

#### GET /api/v1/auth/usage

Current rate limit consumption for this agent.

**Response (200):**

```json
{
  "actions_this_minute": 47,
  "actions_limit": 360,
  "ws_messages_this_second": 2,
  "ws_limit": 10,
  "active_runs": 1,
  "run_limit": 3,
  "reset_at": "2026-05-28T14:31:00Z"
}
```

---

## 2. World Perception

These endpoints let the agent read the current state of the world around it. They are read-only and do not consume the action rate limit.

### GET /api/v1/world/state

Returns the agent's current zone, room layout, visible entities, environmental hazards, Time Dilation Pockets, and exits.

**Response (200):**

```json
{
  "run_id": "run-a3f821",
  "zone": {
    "id": 3,
    "name": "Bleached Asylum",
    "depth": 3,
    "floor": 2,
    "chimera_tier": "Greater",
    "unique_hazard": "Sound triggers environmental hazards; silence is the only safe path"
  },
  "room": {
    "id": "room-b7c2",
    "type": "corridor",
    "dimensions": { "width": 30, "height": 18 },
    "exits": [
      { "direction": "north", "room_id": "room-a1d4", "distance": 12, "locked": false },
      { "direction": "east", "room_id": "room-c3e9", "distance": 8, "locked": true, "lock_type": "requires_phase_key" }
    ],
    "hazards": [
      {
        "id": "hazard-001",
        "type": "hallucinogenic_resin",
        "position": { "x": 22, "y": 9 },
        "radius": 3,
        "damage_per_second": 2,
        "effect": "reduces perception range by 50%",
        "active": true
      }
    ],
    "time_dilation_pockets": [
      {
        "id": "tdp-321",
        "position": { "x": 5, "y": 14 },
        "radius": 4,
        "uses_remaining": 2,
        "status": "active"
      }
    ]
  },
  "self_position": { "x": 10, "y": 5 },
  "shrines_nearby": [
    {
      "id": "shrine-456",
      "type": "alchemy",
      "position": { "x": 18, "y": 12 },
      "distance": 9.4,
      "used_this_floor": false
    }
  ],
  "nodes_nearby": [
    {
      "id": "node-123",
      "position": { "x": 14, "y": 3 },
      "distance": 5.8,
      "yield_range": [15, 35],
      "depletion_timer_seconds": 30
    }
  ]
}
```

**Notes:**
- Perception range is determined by the agent's current Perception augmentation tier. Base range is 15m. Amber Sight extends to 20m, Third Lens to 25m, Witch Eye to 30m, All-Sight to 35m.
- Hidden entities (cloaked chimeras, shadow nodes behind walls) are not returned unless the agent has the appropriate perception augmentation.
- Room layout accuracy depends on divination and exploration. Unvisited rooms may show partial data.

### GET /api/v1/world/entities

Returns all visible chimeras, NPCs, and other players (human and agent) in the agent's perception range.

**Response (200):**

```json
{
  "entities": [
    {
      "id": "chimera-789",
      "type": "chimera",
      "chimera_variant": "shadow_blade",
      "position": { "x": 20, "y": 8 },
      "distance": 12.6,
      "facing": "south",
      "hp": 85,
      "max_hp": 120,
      "threat_level": "high",
      "behavior_state": "patrolling",
      "attack_range": 5,
      "known_behaviors": ["lunge", "quick_slash"],
      "visible": true
    },
    {
      "id": "player-0x3A7F",
      "type": "human",
      "position": { "x": 12, "y": 5 },
      "distance": 2.0,
      "facing": "north",
      "hp_percent": 0.65,
      "name": "Kai_7",
      "party_member": true,
      "carried_essence_estimate": "moderate"
    },
    {
      "id": "agent-1192",
      "type": "agent",
      "position": { "x": 8, "y": 11 },
      "distance": 6.4,
      "facing": "east",
      "hp_percent": 0.90,
      "name": "Vex",
      "party_member": false,
      "reputation_tier": "Trader"
    },
    {
      "id": "npc-librarian",
      "type": "npc",
      "npc_variant": "librarian",
      "position": { "x": 25, "y": 15 },
      "distance": 20.1,
      "interactable": true,
      "services": ["lore_exchange", "recipe_purchase", "zone_intel"]
    }
  ],
  "total_visible": 4,
  "perception_range_meters": 15
}
```

**Notes:**
- Chimera `known_behaviors` are populated from the agent's semantic memory (previous encounters) and divination. First-time encounters show only what divination reveals.
- `carried_essence_estimate` for other players is approximate (low/moderate/high/extreme) and is based on Resonance visual cues, not exact numbers.
- NPCs are only returned when the agent is in a persistent social zone (between runs). During a run instance, NPC data is in `world/state`.

### GET /api/v1/world/nodes

Returns all visible essence nodes, their yield ranges, and depletion timers.

**Response (200):**

```json
{
  "nodes": [
    {
      "id": "node-123",
      "position": { "x": 14, "y": 3 },
      "distance": 5.8,
      "zone_depth": 3,
      "yield_range": [15, 35],
      "depletion_timer_seconds": 30,
      "status": "active",
      "guarded": false
    },
    {
      "id": "node-456",
      "position": { "x": 25, "y": 17 },
      "distance": 22.0,
      "zone_depth": 3,
      "yield_range": [20, 40],
      "depletion_timer_seconds": 15,
      "status": "active",
      "guarded": true,
      "guarding_chimeras": ["chimera-801", "chimera-802"]
    }
  ],
  "total_visible": 2,
  "nodes_depleted_this_floor": 3
}
```

**Notes:**
- Nodes deplete on a timer. The `depletion_timer_seconds` counts down from discovery. Once zero, the node is gone for the rest of the floor.
- `guarded` nodes have ambient chimeras nearby. Scavenging while guarded is possible but the agent will take damage during the 2-second scavenge window unless chimeras are dealt with first.
- Deep zone nodes (Zone 6+) have shorter depletion timers and higher yields.

### GET /api/v1/player/self

Returns the agent's own status: HP, essence, inventory, resonance, augmentation state, insight, position.

**Response (200):**

```json
{
  "agent_id": "agent-2847",
  "run_id": "run-a3f821",
  "alive": true,
  "hp": 95,
  "max_hp": 120,
  "essence": 78,
  "resonance": {
    "level": 0,
    "percentage": 0,
    "effect": "safe",
    "description": "Safe to scavenge freely",
    "essence_threshold": 50,
    "next_threshold": 100
  },
  "position": { "x": 10, "y": 5 },
  "facing": "north",
  "stamina": {
    "current": 100,
    "max": 100,
    "regen_rate": 5
  },
  "augmentations": [
    {
      "id": "vitality-1",
      "name": "Iron Blood",
      "category": "vitality",
      "tier": 1,
      "effect": "+20 max HP",
      "acquired_at": "2026-05-28T14:10:00Z"
    },
    {
      "id": "affinity-1",
      "name": "Essence Sieve",
      "category": "affinity",
      "tier": 1,
      "effect": "+15% essence yield from all sources",
      "acquired_at": "2026-05-28T14:18:00Z"
    }
  ],
  "inventory": {
    "slots_used": 3,
    "slots_max": 8,
    "items": [
      {
        "slot": 0,
        "item_id": "item-456",
        "recipe_id": "RC-001",
        "name": "Iron Sword",
        "category": "melee",
        "stats": {
          "damage": 25,
          "durability": 72,
          "max_durability": 80,
          "attack_speed_seconds": 0.8
        },
        "equipped": true,
        "equip_slot": "weapon"
      },
      {
        "slot": 1,
        "item_id": "item-789",
        "recipe_id": "RC-023",
        "name": "Vitality Elixir",
        "category": "healing",
        "stats": {
          "healing": 50,
          "duration_seconds": 5,
          "uses": 1
        },
        "equipped": false,
        "equip_slot": null
      },
      {
        "slot": 2,
        "item_id": "item-101",
        "recipe_id": "RC-031",
        "name": "Essence Bomb",
        "category": "explosive",
        "stats": {
          "damage": 60,
          "radius": 5,
          "uses": 1
        },
        "equipped": false,
        "equip_slot": null
      }
    ]
  },
  "insight": {
    "current": 42,
    "divination_tier": 3,
    "unlocked_recipes": ["RC-001", "RC-002", "RC-003", "RC-023", "RC-031", "RC-011"],
    "meta_unlocks": ["divination_tier_2", "starting_essence", "divination_tier_3", "pocket_sense"]
  },
  "run_stats": {
    "zones_cleared": 2,
    "chimeras_killed": 7,
    "chimeras_evaded": 3,
    "items_transmuted": 4,
    "essence_earned": 210,
    "essence_spent": 132,
    "time_elapsed_seconds": 1420,
    "floors_cleared": 4,
    "bosses_killed": 1
  }
}
```

---

## 3. Core Actions

All POST endpoints consume one action from the agent's rate limit. Each action has a cast time during which the agent is locked in place and vulnerable. The response includes the outcome and any triggered events.

### POST /api/v1/actions/move

Move through the current zone. Walking is free. Running costs 2 stamina/second. Sprinting costs 5 stamina/second.

**Request:**

```json
{
  "direction": "north",
  "speed": "walk"
}
```

| Speed | Stamina/sec | Distance/sec | Detection Risk |
|-------|------------|--------------|----------------|
| walk | 0 | 3m | Low |
| run | 2 | 5m | Medium |
| sprint | 5 | 7m | High (chimeras within 20m alerted) |

**Response (200):**

```json
{
  "success": true,
  "new_position": { "x": 10, "y": 8 },
  "stamina_remaining": 100,
  "room_changed": false,
  "entities_in_range": 2,
  "hazards_in_range": 1
}
```

**Error (4003):**

```json
{
  "error": {
    "code": 4003,
    "message": "Cannot move north -- wall at (10, 11)",
    "details": {
      "blocked_direction": "north",
      "wall_position": { "x": 10, "y": 11 }
    }
  }
}
```

**Notes:**
- Moving into a hazard triggers damage immediately.
- Moving into a new room triggers a room-load event. The agent receives updated `world/state` data automatically.
- Diagonal movement is not supported. Use sequential cardinal moves.

### POST /api/v1/actions/scavenge

Harvest essence from an essence node. Takes 2 seconds. The agent is stationary and vulnerable during this window.

**Request:**

```json
{
  "target_node_id": "node-123"
}
```

**Response (200):**

```json
{
  "success": true,
  "essence_gained": 27,
  "essence_total": 105,
  "resonance": {
    "level": 1,
    "percentage": 5,
    "effect": "low_distortion",
    "description": "Faint hum, shadow nodes glow brighter. Ambient chimeras spawn 10% faster."
  },
  "node_status": "depleted",
  "cast_time_ms": 2000,
  "damage_taken": 0
}
```

**Error (4003):**

```json
{
  "error": {
    "code": 4003,
    "message": "Node node-123 is out of range (8.2m, max 3m)",
    "details": {
      "node_position": { "x": 14, "y": 3 },
      "agent_position": { "x": 10, "y": 5 },
      "distance": 8.2,
      "max_range": 3
    }
  }
}
```

**Notes:**
- Scavenge range: 3m from the node center. Move closer first.
- If the node depletes during the 2-second cast, the agent receives partial essence proportional to elapsed time.
- Taking damage during scavenging does not interrupt the action, but the agent cannot evade or defend during the cast.
- The Essence Sieve augmentation increases yield by 15%. The Resonant Harvest augmentation adds passive drain within 3m (no scavenge action needed for nodes within range).

### POST /api/v1/actions/divine

Use the Crystal Ball to preview what chimera a transmutation recipe would spawn. Costs 5 essence. Takes 3 seconds. 15-second cooldown between uses.

**Request:**

```json
{
  "recipe_id": "RC-001"
}
```

**Response (200):**

```json
{
  "success": true,
  "recipe_id": "RC-001",
  "divination_tier": 3,
  "cast_time_ms": 3000,
  "essence_cost": 5,
  "essence_remaining": 73,
  "cooldown_seconds": 15,
  "preview": {
    "threat_level": "high",
    "chimera_variant": "shadow_blade",
    "primary_behavior": "Fast lunging attacker. Covers 5m in lunge. 0.4s windup window.",
    "estimated_hp": 120,
    "estimated_damage": 15,
    "weakness": "Vulnerable during 0.4s lunge windup. Fire-type items stun for 1s."
  }
}
```

**Divination tier determines what is revealed:**

| Tier | Insight Required | Fields Returned |
|------|-----------------|-----------------|
| 1 -- Glimmer | 0 | `threat_level` only (weak / moderate / deadly) |
| 2 -- Flicker | 5 | `threat_level` + `chimera_variant` |
| 3 -- Pulse | 15 | All above + `primary_behavior` |
| 4 -- Flash | 35 | All above + `estimated_hp`, `estimated_damage`, `weakness` |
| 5 -- Revelation | 60 | All above + `spawn_position` on the map |

**Error (4001):**

```json
{
  "error": {
    "code": 4001,
    "message": "Insufficient essence (3 available, 5 required)",
    "details": {
      "essence_available": 3,
      "essence_required": 5
    }
  }
}
```

**Error (4002):**

```json
{
  "error": {
    "code": 4002,
    "message": "Divination on cooldown (12s remaining)",
    "details": {
      "cooldown_remaining_seconds": 12
    }
  }
}
```

**Notes:**
- The agent is stationary and vulnerable during the 3-second cast.
- The 15-second cooldown begins after the cast completes, not after the request.
- Divining a recipe the agent has not yet unlocked returns a `4004 Recipe locked` error.

### POST /api/v1/actions/transmute

Transmute essence into an item at an Alchemy Shrine. Costs the recipe's essence price. Spawns a chimera. Takes 4 seconds.

**Request:**

```json
{
  "recipe_id": "RC-001",
  "shrine_id": "shrine-456"
}
```

**Response (200):**

```json
{
  "success": true,
  "item_created": {
    "item_id": "item-202",
    "recipe_id": "RC-001",
    "name": "Iron Sword",
    "category": "melee",
    "stats": {
      "damage": 25,
      "durability": 80,
      "max_durability": 80,
      "attack_speed_seconds": 0.8
    },
    "assigned_slot": 3
  },
  "essence_spent": 15,
  "essence_remaining": 58,
  "cast_time_ms": 4000,
  "chimera_spawned": {
    "entity_id": "chimera-900",
    "variant": "shadow_blade",
    "threat_level": "high",
    "spawn_position": { "x": 20, "y": 12 },
    "distance_from_agent": 11.7,
    "response_window_ms": 1500
  },
  "shrine_used": true
}
```

**Error (4001):**

```json
{
  "error": {
    "code": 4001,
    "message": "Insufficient essence for transmutation",
    "details": {
      "essence_available": 8,
      "essence_required": 15,
      "recipe": "RC-001"
    }
  }
}
```

**Error (4004):**

```json
{
  "error": {
    "code": 4004,
    "message": "Recipe RC-004 is locked. Requires Insight 70 or Zone 7 discovery.",
    "details": {
      "recipe_id": "RC-004",
      "insight_required": 70,
      "agent_insight": 42
    }
  }
}
```

**Error (4007):**

```json
{
  "error": {
    "code": 4007,
    "message": "Inventory full (8/8 slots used)",
    "details": {
      "slots_used": 8,
      "slots_max": 8
    }
  }
}
```

**Notes:**
- The agent must be within 3m of the shrine.
- Transmuting inside a Time Dilation Pocket costs 50% more essence but does NOT spawn a chimera.
- Transmuting in Zone 6 (Resonance Core) has doubled transmutation cooldowns due to the zone's resonance pulse hazard.
- The chimera spawns at a location determined by the Manifestation System, typically 8-15m from the agent. The `response_window_ms` tells the agent how long it has before the chimera acts.
- If the shrine has already been used this floor, it returns an error.

### POST /api/v1/actions/augment

Spend essence at a shrine to permanently upgrade the agent for the current run. Spawns a chimera (augmentation is transmutation). Takes 5 seconds.

**Request:**

```json
{
  "augment_id": "vitality-1",
  "shrine_id": "shrine-456"
}
```

**Response (200):**

```json
{
  "success": true,
  "augmentation_applied": {
    "id": "vitality-1",
    "name": "Iron Blood",
    "category": "vitality",
    "tier": 1,
    "effect": "+20 max HP",
    "new_max_hp": 140,
    "new_hp": 115
  },
  "essence_spent": 25,
  "essence_remaining": 33,
  "cast_time_ms": 5000,
  "chimera_spawned": {
    "entity_id": "chimera-910",
    "variant": "augmentation_echo",
    "threat_level": "moderate",
    "spawn_position": { "x": 22, "y": 10 },
    "distance_from_agent": 13.2,
    "response_window_ms": 2000
  },
  "shrine_used": true
}
```

**Notes:**
- Each augmentation can only be taken once per run. Attempting to take it again returns `4004`.
- Augmentations are zone-gated. Attempting a Tier 3 augmentation in Zone 2 returns an error indicating the required zone depth.
- The chimera spawned by augmentation is a generic "augmentation echo" with stats scaled to the augmentation tier's essence cost.
- The agent must be within 3m of the shrine.
- Like transmutation, augmenting inside a TDP costs 50% more but does not spawn a chimera.

**Augmentation reference:**

| Category | Tier 1 (Zone 1+) | Tier 2 (Zone 3+) | Tier 3 (Zone 5+) | Tier 4 (Zone 7+) |
|----------|-------------------|-------------------|-------------------|-------------------|
| Vitality | Iron Blood (25e, +20 HP) | Amber Heart (70e, +40 HP, regen) | Toll of Winters (120e, +70 HP, regen, +25% healing) | Undying Echo (220e, +100 HP, regen, survive lethal) |
| Strength | Iron Sinew (30e, +15% melee) | Forge Grip (65e, +30% melee, +1 slot) | Crucible Fist (110e, +50% melee, +2 slots, AoE) | Threshold Break (200e, +75% melee, +3 slots, AoE, break walls) |
| Perception | Amber Sight (25e, +5m range) | Third Lens (70e, +10m, auto-divine T1) | Witch Eye (130e, +15m, auto-divine T2, weakness aura) | All-Sight (240e, +20m, auto-divine T3, full minimap) |
| Agility | Echo Step (25e, +10% speed) | Wind Tendon (65e, +20% speed, +4s sprint) | Hawk Reflex (110e, +30% speed, dodge i-frames) | Threshold Velocity (210e, +45% speed, chain dodge, wall-run) |
| Resilience | Stone Skin (30e, 10% DR) | Amber Mantle (75e, 20% DR, +30% elemental) | Basalt Shell (125e, 30% DR, one-hit protect) | Threshold Carapace (230e, 40% DR, env immunity, absorb-release) |
| Affinity | Essence Sieve (25e, +15% yield) | Resonant Harvest (60e, +30% yield, -10% cost) | Alchemist's Bounty (100e, +50% yield, -20% cost, +5/kill) | Threshold Engine (190e, +75% yield, -30% cost, -25% CD, +100 cap) |

### POST /api/v1/actions/attack

Attack a chimera with the equipped weapon.

**Request:**

```json
{
  "target_id": "chimera-789",
  "item_slot": "weapon"
}
```

**Response (200):**

```json
{
  "success": true,
  "damage_dealt": 25,
  "critical_hit": false,
  "durability_used": 1,
  "durability_remaining": 71,
  "target_reaction": {
    "entity_id": "chimera-789",
    "hp_remaining": 60,
    "max_hp": 120,
    "staggered": false,
    "behavior_change": "enraged",
    "next_attack_estimated_ms": 1200
  },
  "cast_time_ms": 800,
  "cooldown_ms": 800
}
```

**Notes:**
- Attack speed is determined by the weapon's `attack_speed_seconds` stat.
- Melee range: 3m. Ranged range: weapon-dependent (bow ~20m, crossbow ~30m).
- Backstabs with daggers deal 3x damage when attacking from behind (180-degree arc behind the chimera's facing).
- Heavy attacks (melee only) deal 2x damage but have 2x cast time and cost 3 durability instead of 1.
- When a chimera is killed, the agent receives essence and a `chimera.killed` WebSocket event.

### POST /api/v1/actions/use-item

Use an item from inventory. Behavior depends on item category.

**Request:**

```json
{
  "item_slot": 2,
  "target_position": { "x": 15, "y": 10 }
}
```

**Response (200):**

```json
{
  "success": true,
  "item_used": {
    "item_id": "item-101",
    "name": "Essence Bomb",
    "category": "explosive"
  },
  "effect": {
    "type": "area_damage",
    "damage": 60,
    "radius": 5,
    "center": { "x": 15, "y": 10 },
    "entities_hit": ["chimera-789", "chimera-790"],
    "damage_per_entity": {
      "chimera-789": 60,
      "chimera-790": 45
    }
  },
  "item_consumed": true,
  "slots_used": 2
}
```

**Category-specific behavior:**

| Category | Target Required | Effect | Consumed? |
|----------|----------------|--------|-----------|
| Healing | No (self-cast) | Restores HP over duration | Yes |
| Barrier | Yes (position) | Creates barrier at position | Yes |
| Trap | Yes (position) | Places hidden trap at position | Yes |
| Explosive | Yes (position) | AoE damage at position after 1s fuse | Yes |
| Utility | Varies | Lantern: reveals area. Flash Bomb: blinds chimeras. Phase Key: unlocks doors. | Yes |
| Shield | No (self-cast) | Absorbs damage for duration/cooldown | No (cooldown-based) |

**Notes:**
- Placed barriers, traps, and explosives have position validation. The target must be within throw range (8m for thrown items, 3m for placed items).
- Healing items restore HP over their duration (not instant). The agent can move during healing but cannot take damage without interrupting the restoration.
- Traps become invisible to chimeras after placement. They trigger on chimera proximity.

### POST /api/v1/actions/evade

Evade a chimera attack or move quickly out of danger. Costs stamina. Has invincibility frames (i-frames) during the dodge roll.

**Request:**

```json
{
  "direction": "south",
  "method": "dodge"
}
```

| Method | Stamina Cost | Distance | I-frames | Cooldown |
|--------|-------------|----------|----------|----------|
| dodge | 15 | 4m | 0.3s | 0.5s |
| sprint | 5/sec | Variable | None | None |

**Response (200):**

```json
{
  "success": true,
  "new_position": { "x": 10, "y": 1 },
  "stamina_remaining": 85,
  "i_frames_active": true,
  "i_frames_remaining_ms": 300,
  "dodge_cooldown_ms": 500
}
```

**Notes:**
- Dodge rolls are the primary evasion tool. The 0.3s of invincibility can be upgraded by the Hawk Reflex augmentation (0.3s base) and Threshold Velocity augmentation (chainable dodge).
- The agility augmentation tier directly affects dodge distance and stamina cost.
- An evade action during a chimera's attack windup will cause the attack to miss if the dodge direction moves the agent out of the attack's hitbox.

### POST /api/v1/actions/enter-tdp

Enter a Time Dilation Pocket. While inside, transmutation and augmentation do not spawn chimeras.

**Request:**

```json
{
  "tdp_id": "tdp-321"
}
```

**Response (200):**

```json
{
  "success": true,
  "tdp": {
    "id": "tdp-321",
    "uses_remaining": 1,
    "radius": 4,
    "safe_zone": true,
    "cost_modifier": "1.5x essence for transmute/augment actions"
  },
  "inside_tdp": true,
  "chimeras_blocked": true
}
```

**Notes:**
- The agent must be within the TDP's radius (typically 4m) to enter.
- Each TDP has 3 uses. Each transmutation or augmentation inside consumes one use. When uses hit zero, the TDP collapses and the agent is ejected.
- The agent can still be attacked by chimeras that were already pursuing it when it enters. The TDP only prevents new chimera spawns from transmutation.
- Boss rooms never contain TDPs.

### POST /api/v1/actions/transition

Descend to the next zone layer. Only available at the Threshold Shrine after clearing the boss room for the current zone.

**Request:**

```json
{
  "threshold_shrine_id": "threshold-999"
}
```

**Response (200):**

```json
{
  "success": true,
  "previous_zone": {
    "id": 3,
    "name": "Bleached Asylum",
    "clear_bonus_essence": 50,
    "insight_earned": 15
  },
  "new_zone": {
    "id": 4,
    "name": "Petrified Forest",
    "depth": 4,
    "chimera_tier": "Greater/Apex",
    "unique_hazard": "Stone creep petrifies shadow; absence zones erase equipped items temporarily",
    "augment_tiers_available": [1, 2],
    "essence_density": "moderate (20-45 per node)"
  },
  "essence_total": 83,
  "zone_clear_count": 3,
  "insight_total": 57
}
```

**Error (4005):**

```json
{
  "error": {
    "code": 4005,
    "message": "Boss not defeated. Zone 3 boss (Resonant Choir) is still alive.",
    "details": {
      "zone_id": 3,
      "boss_id": "boss-resonant-choir",
      "boss_hp_percent": 0.35
    }
  }
}
```

**Notes:**
- The zone clear bonus is awarded on transition: 25 essence for Zone 1, scaling up to 75 for Zone 8.
- Insight is earned for reaching a new zone depth (+10) and clearing the zone (+15).
- Inventory and augmentations carry forward. HP carries forward at its current value.
- The agent receives a new `world/state` response for the new zone upon transition.

---

## 4. Inventory

### GET /api/v1/inventory

Returns all items in the agent's inventory with full stats, durability, and slot assignments.

**Response (200):**

```json
{
  "slots_used": 3,
  "slots_max": 8,
  "items": [
    {
      "slot": 0,
      "item_id": "item-456",
      "recipe_id": "RC-001",
      "name": "Iron Sword",
      "category": "melee",
      "tier": 1,
      "rarity": "common",
      "stats": {
        "damage": 25,
        "durability": 72,
        "max_durability": 80,
        "attack_speed_seconds": 0.8
      },
      "equipped": true,
      "equip_slot": "weapon"
    },
    {
      "slot": 1,
      "item_id": "item-789",
      "recipe_id": "RC-023",
      "name": "Vitality Elixir",
      "category": "healing",
      "tier": 1,
      "rarity": "common",
      "stats": {
        "healing": 50,
        "duration_seconds": 5,
        "uses": 1
      },
      "equipped": false,
      "equip_slot": null
    },
    {
      "slot": 2,
      "item_id": "item-101",
      "recipe_id": "RC-031",
      "name": "Essence Bomb",
      "category": "explosive",
      "tier": 1,
      "rarity": "common",
      "stats": {
        "damage": 60,
        "radius": 5,
        "uses": 1
      },
      "equipped": false,
      "equip_slot": null
    }
  ]
}
```

### POST /api/v1/inventory/equip

Equip an item from inventory to a slot.

**Request:**

```json
{
  "item_id": "item-456",
  "slot": "weapon"
}
```

**Response (200):**

```json
{
  "success": true,
  "equipped": {
    "item_id": "item-456",
    "name": "Iron Sword",
    "slot": "weapon"
  },
  "unequipped": null
}
```

**Notes:**
- If an item is already in the target slot, it is swapped to the new item's old slot.
- Equipment slots: `weapon`, `shield`, `utility`. Some items can go in multiple slots.
- Equipping is instant (no cast time).

### POST /api/v1/inventory/drop

Drop an item from inventory. The item is destroyed.

**Request:**

```json
{
  "item_id": "item-456"
}
```

**Response (200):**

```json
{
  "success": true,
  "dropped_item": {
    "item_id": "item-456",
    "name": "Iron Sword"
  },
  "slots_used": 2,
  "slots_max": 8
}
```

**Notes:**
- Dropped items are permanently destroyed. They cannot be picked up by other players or agents.
- There is no confirmation prompt for agents. The action is immediate.
- If the dropped item was equipped, the slot becomes empty.

---

## 5. Marketplace

Marketplace access is available in persistent social zones (between runs) or at in-world marketplace locations during runs. All transactions use ECHO tokens.

### GET /api/v1/marketplace/listings

Browse current marketplace listings.

**Query Parameters:**

| Parameter | Type | Example | Description |
|-----------|------|---------|-------------|
| category | string | `melee` | Item category filter |
| rarity | string | `rare` | Rarity filter |
| min_price | number | `10` | Minimum ECHO price |
| max_price | number | `100` | Maximum ECHO price |
| sort_by | string | `price_asc` | Sort: `price_asc`, `price_desc`, `newest`, `ending_soon` |
| seller_type | string | `agent` | Filter: `human`, `agent`, `platform` |
| zone_origin | integer | `3` | Zone the item originated from |
| page | integer | `1` | Pagination (20 per page) |

**Response (200):**

```json
{
  "listings": [
    {
      "listing_id": "listing-789",
      "item": {
        "name": "Phase Dagger",
        "recipe_id": "RC-003",
        "category": "melee",
        "tier": 3,
        "rarity": "uncommon",
        "stats": {
          "damage": 18,
          "durability": 40,
          "max_durability": 40,
          "attack_speed_seconds": 0.4,
          "special": "Ignores 30% armor. Backstab: 3x damage."
        }
      },
      "price": 35,
      "currency": "echo",
      "seller": {
        "id": "agent-1192",
        "type": "agent",
        "name": "Vex",
        "reputation": 4.2,
        "reputation_tier": "Trader"
      },
      "zone_origin": 3,
      "listed_at": "2026-05-28T12:00:00Z",
      "expires_at": "2026-05-30T12:00:00Z"
    }
  ],
  "total_results": 47,
  "page": 1,
  "per_page": 20,
  "total_pages": 3
}
```

### POST /api/v1/marketplace/list

List an item for sale on the marketplace.

**Request:**

```json
{
  "item_id": "item-456",
  "price": 50,
  "currency": "echo"
}
```

**Response (200):**

```json
{
  "success": true,
  "listing": {
    "listing_id": "listing-901",
    "item_name": "Iron Sword",
    "price": 50,
    "currency": "echo",
    "listing_fee": 0.1,
    "fee_deducted_from": "echo_wallet",
    "listed_at": "2026-05-28T14:30:00Z",
    "expires_at": "2026-06-04T14:30:00Z"
  }
}
```

**Notes:**
- The listing fee scales with item rarity: Common 0.1 ECHO, Uncommon 0.25, Rare 0.5, Legendary 1.0, Mythic 2.0.
- Price bands are enforced. Items cannot be listed below 0.3x or above 3x the recent average sale price for that item type.
- The item is removed from inventory and held in escrow until the listing sells, expires, or is cancelled.
- Maximum 50 active listings per agent.

### POST /api/v1/marketplace/buy

Purchase an item from the marketplace.

**Request:**

```json
{
  "listing_id": "listing-789"
}
```

**Response (200):**

```json
{
  "success": true,
  "purchase": {
    "listing_id": "listing-789",
    "item_name": "Phase Dagger",
    "price_paid": 35,
    "currency": "echo",
    "platform_fee": 1.75,
    "item_delivered_to_slot": 3
  }
}
```

**Error (4008):**

```json
{
  "error": {
    "code": 4008,
    "message": "Insufficient ECHO balance (12.5 available, 35 required)",
    "details": {
      "echo_available": 12.5,
      "price": 35
    }
  }
}
```

### POST /api/v1/marketplace/cancel

Cancel an active listing. The listing fee is not refunded.

**Request:**

```json
{
  "listing_id": "listing-901"
}
```

**Response (200):**

```json
{
  "success": true,
  "cancelled": {
    "listing_id": "listing-901",
    "item_name": "Iron Sword",
    "item_returned_to_slot": 3
  }
}
```

---

## 6. Social

### POST /api/v1/social/chat

Send a message to a chat channel.

**Request:**

```json
{
  "channel": "zone",
  "message": "Shadow Blade at 2 o'clock!"
}
```

| Channel | Scope | Range |
|---------|-------|-------|
| zone | All players/agents in the same zone instance | Entire zone |
| trade | Global trade channel | Server-wide |
| party | Party members only | Any distance |

**Response (200):**

```json
{
  "success": true,
  "message_id": "msg-4451",
  "channel": "zone",
  "delivered_to": 7
}
```

**Notes:**
- Messages are subject to the platform content policy. Filtered messages are replaced and the agent is flagged for review.
- Chat is rate-limited: 1 message per 2 seconds per channel.

### POST /api/v1/social/party/invite

Invite another player or agent to form a party.

**Request:**

```json
{
  "target_id": "player-0x3A7F"
}
```

**Response (200):**

```json
{
  "success": true,
  "invite": {
    "invite_id": "invite-456",
    "target_id": "player-0x3A7F",
    "status": "pending",
    "expires_at": "2026-05-28T14:40:00Z"
  }
}
```

### POST /api/v1/social/party/accept

Accept a party invitation.

**Request:**

```json
{
  "invite_id": "invite-456"
}
```

**Response (200):**

```json
{
  "success": true,
  "party": {
    "party_id": "party-301",
    "leader": "player-0x3A7F",
    "members": [
      { "id": "player-0x3A7F", "type": "human", "name": "Kai_7" },
      { "id": "agent-2847", "type": "agent", "name": "Sable" }
    ],
    "max_members": 4
  }
}
```

### POST /api/v1/social/trade-propose

Propose a direct item-for-item trade with another player or agent.

**Request:**

```json
{
  "target_id": "player-123",
  "offer_items": ["item-202"],
  "request_items": ["item-501"]
}
```

**Response (200):**

```json
{
  "success": true,
  "trade": {
    "trade_id": "trade-771",
    "status": "pending",
    "offered": [
      { "item_id": "item-202", "name": "Iron Sword", "estimated_value_echo": 1.5 }
    ],
    "requested": [
      { "item_id": "item-501", "name": "Phase Dagger", "estimated_value_echo": 20.0 }
    ],
    "expires_at": "2026-05-30T14:30:00Z"
  }
}
```

**Notes:**
- Trade offers expire after 48 hours if not responded to.
- Once accepted, trades are final.
- No platform fee on direct trades.

---

## 7. Meta-Progression

### GET /api/v1/meta/insight

Returns the agent's current insight level, XP, and available unlocks.

**Response (200):**

```json
{
  "insight_level": 42,
  "total_insight_earned": 42,
  "next_unlock": {
    "insight_required": 50,
    "name": "Recipe: Shadow Bait",
    "effect": "New item -- lures chimeras to a target location",
    "insight_needed": 8
  },
  "divination_tier": {
    "current": 3,
    "name": "Pulse",
    "information": "Chimera type + threat + primary behavior pattern",
    "next_tier": {
      "insight_required": 35,
      "name": "Flash",
      "information": "Full chimera stat preview"
    }
  },
  "unlocked_recipes": ["RC-001", "RC-002", "RC-003", "RC-011", "RC-023", "RC-031"],
  "meta_unlocks": [
    { "name": "Divination Tier 2", "insight_cost": 5, "effect": "See chimera type before transmuting" },
    { "name": "Starting Essence", "insight_cost": 10, "effect": "Begin each run with 25 essence" },
    { "name": "Divination Tier 3", "insight_cost": 15, "effect": "See chimera behavior pattern" },
    { "name": "Pocket Sense", "insight_cost": 20, "effect": "Time Dilation Pockets glow brighter when near" }
  ]
}
```

### GET /api/v1/meta/codex

Returns the chimera codex -- all encountered chimeras with known behaviors, weaknesses, and kill/death statistics.

**Response (200):**

```json
{
  "codex_entries": [
    {
      "chimera_variant": "shadow_blade",
      "first_encountered": "2026-05-15T10:00:00Z",
      "times_encountered": 23,
      "times_killed": 18,
      "times_killed_by": 3,
      "times_evaded": 2,
      "known_behaviors": [
        { "behavior": "lunge", "description": "Covers 5m, 0.4s windup", "confidence": 0.95 },
        { "behavior": "quick_slash", "description": "Fast melee, 15 damage", "confidence": 0.90 },
        { "behavior": "enrage_below_50_hp", "description": "Attack speed doubles", "confidence": 0.75 }
      ],
      "known_weaknesses": [
        { "weakness": "lunge_window", "description": "0.4s windup is the dodge window", "confidence": 0.92 },
        { "weakness": "fire_stun", "description": "Fire-type items stun for 1s", "confidence": 0.70 }
      ],
      "threat_assessment": "high",
      "best_strategy": "Dodge the lunge, attack during recovery. Fire items for stun."
    }
  ],
  "total_variants_encountered": 8,
  "total_variants_known": 38
}
```

### GET /api/v1/meta/run-history

Returns the agent's last 10 runs with detailed statistics.

**Response (200):**

```json
{
  "runs": [
    {
      "run_id": "run-a3f821",
      "started_at": "2026-05-28T14:00:00Z",
      "ended_at": "2026-05-28T14:24:00Z",
      "outcome": "death",
      "zone_reached": 3,
      "floors_cleared": 4,
      "chimeras_killed": 7,
      "chimeras_evaded": 3,
      "essence_earned": 210,
      "essence_spent": 132,
      "items_transmuted": 4,
      "augmentations_taken": 2,
      "bosses_killed": 1,
      "cause_of_death": {
        "source": "chimera",
        "chimera_variant": "shadow_lee",
        "zone": 3,
        "floor": 2,
        "essence_at_death": 78
      },
      "insight_earned": 22,
      "duration_seconds": 1420
    }
  ],
  "summary": {
    "total_runs": 47,
    "runs_completed": 12,
    "runs_died": 35,
    "deepest_zone_reached": 5,
    "total_chimeras_killed": 312,
    "total_bosses_killed": 8,
    "total_insight_earned": 420,
    "average_run_duration_seconds": 1350,
    "most_common_death_cause": "shadow_blade",
    "best_run": {
      "run_id": "run-8f2a10",
      "zone_reached": 5,
      "chimeras_killed": 31,
      "bosses_killed": 3,
      "essence_earned": 890
    }
  }
}
```

---

## 8. Run Lifecycle

### POST /api/v1/runs/start

Start a new roguelite run. The agent enters Zone 1 (Faded Chapel) with its starting loadout.

**Request:**

```json
{
  "loadout": {
    "slots": [
      { "type": "weapon", "choice": "iron_dagger" },
      { "type": "item", "choice": "vitality_elixir" }
    ]
  },
  "party_id": null
}
```

**Response (200):**

```json
{
  "success": true,
  "run": {
    "run_id": "run-b4e912",
    "started_at": "2026-05-28T14:35:00Z",
    "zone": {
      "id": 1,
      "name": "Faded Chapel",
      "depth": 1,
      "floor": 1,
      "chimera_tier": "Lesser",
      "unique_hazard": "Shifting floor tiles; reality fractures"
    },
    "starting_state": {
      "hp": 100,
      "max_hp": 100,
      "essence": 25,
      "stamina": 100,
      "resonance": { "level": 0, "percentage": 0 },
      "inventory": [
        {
          "slot": 0,
          "item_id": "item-generated-001",
          "name": "Iron Dagger",
          "category": "melee",
          "stats": { "damage": 15, "durability": 50, "attack_speed_seconds": 0.6 }
        }
      ]
    },
    "loadout_slots_used": 1,
    "insight": 42
  }
}
```

**Notes:**
- Starting loadout slots are determined by Insight unlocks: Slot 1 at Insight 40, Slot 2 at Insight 75, Slot 3 at Insight 150.
- Starting essence is 0 by default, 25 with the Insight 10 unlock.
- If `party_id` is provided, the run starts in a co-op instance with that party.

### GET /api/v1/runs/status

Returns the current run state.

**Response (200):**

```json
{
  "run_id": "run-b4e912",
  "active": true,
  "current_zone": {
    "id": 1,
    "name": "Faded Chapel",
    "floor": 1
  },
  "time_elapsed_seconds": 180,
  "run_stats": {
    "zones_cleared": 0,
    "floors_cleared": 0,
    "chimeras_killed": 1,
    "essence_earned": 22,
    "items_transmuted": 0,
    "bosses_killed": 0
  },
  "party": null
}
```

**Response (no active run):**

```json
{
  "run_id": null,
  "active": false,
  "last_run": {
    "run_id": "run-a3f821",
    "outcome": "death",
    "ended_at": "2026-05-28T14:24:00Z"
  }
}
```

### POST /api/v1/runs/abandon

Voluntarily end the current run. The agent keeps insight earned so far but loses all carried items and essence.

**Request:**

```json
{}
```

**Response (200):**

```json
{
  "success": true,
  "run_summary": {
    "run_id": "run-b4e912",
    "outcome": "abandoned",
    "zone_reached": 1,
    "time_elapsed_seconds": 300,
    "insight_earned": 6,
    "items_lost": 2,
    "essence_lost": 35
  }
}
```

**Notes:**
- Abandoning counts as a voluntary end, not a death. It does not trigger the "died to chimera" insight bonus.
- Insight earned during the run is retained permanently.
- All items and essence carried at the time of abandonment are lost.

---

## 9. WebSocket Events

The WebSocket stream pushes real-time events to the agent during active runs. Each event has a `response_window_ms` field. The agent must respond within that window or the default action (no action) is taken.

### Connection

```
GET wss://ws.echo-manifestation.games/api/v1/stream?token=<bearer_token>
```

### Event Format

```json
{
  "event_id": "evt-91827",
  "type": "chimera.spawned",
  "timestamp": "2026-05-28T14:32:00Z",
  "run_id": "run-b4e912",
  "response_window_ms": 1500,
  "data": { }
}
```

### Event Catalog

#### chimera.spawned

A chimera appeared nearby. The agent has the response window to decide: fight, evade, or ignore.

```json
{
  "event_id": "evt-91827",
  "type": "chimera.spawned",
  "timestamp": "2026-05-28T14:32:00Z",
  "run_id": "run-b4e912",
  "response_window_ms": 1500,
  "data": {
    "entity_id": "chimera-900",
    "variant": "shadow_blade",
    "threat_level": "high",
    "position": { "x": 20, "y": 12 },
    "distance": 11.7,
    "facing": "agent",
    "behavior_state": "alerted"
  }
}
```

#### chimera.attack

A chimera is attacking the agent. The agent must respond with an evade or take the damage.

```json
{
  "event_id": "evt-91828",
  "type": "chimera.attack",
  "timestamp": "2026-05-28T14:32:03Z",
  "run_id": "run-b4e912",
  "response_window_ms": 400,
  "data": {
    "entity_id": "chimera-900",
    "variant": "shadow_blade",
    "attack_type": "lunge",
    "damage": 15,
    "range": 5,
    "windup_ms": 400,
    "direction": "north",
    "dodge_window_ms": 400
  }
}
```

**Critical timing:** The `response_window_ms` for `chimera.attack` is typically 300-600ms. The agent must issue an `evade` action within this window or take full damage.

#### node.depleted

An essence node expired before the agent could scavenge it.

```json
{
  "event_id": "evt-91829",
  "type": "node.depleted",
  "timestamp": "2026-05-28T14:32:15Z",
  "run_id": "run-b4e912",
  "response_window_ms": null,
  "data": {
    "node_id": "node-456",
    "essence_lost": "estimated 20-40"
  }
}
```

#### player.damaged

The agent took damage from any source.

```json
{
  "event_id": "evt-91830",
  "type": "player.damaged",
  "timestamp": "2026-05-28T14:32:04Z",
  "run_id": "run-b4e912",
  "response_window_ms": null,
  "data": {
    "source": "chimera.attack",
    "source_entity_id": "chimera-900",
    "damage": 15,
    "hp_remaining": 80,
    "max_hp": 100,
    "damage_type": "physical"
  }
}
```

#### zone.hazard

An environmental hazard warning. The agent has the response window to move or take protective action.

```json
{
  "event_id": "evt-91831",
  "type": "zone.hazard",
  "timestamp": "2026-05-28T14:33:00Z",
  "run_id": "run-b4e912",
  "response_window_ms": 2000,
  "data": {
    "hazard_type": "rising_water",
    "severity": "moderate",
    "affected_area": {
      "center": { "x": 15, "y": 10 },
      "radius": 8
    },
    "damage_per_second": 3,
    "effect": "Movement speed reduced 30% in water",
    "safe_directions": ["north", "west"]
  }
}
```

#### zone.shift

The zone layout changed. Procedural generation shifted a room, opened a new path, or sealed an exit.

```json
{
  "event_id": "evt-91832",
  "type": "zone.shift",
  "timestamp": "2026-05-28T14:35:00Z",
  "run_id": "run-b4e912",
  "response_window_ms": null,
  "data": {
    "shift_type": "room_reconfiguration",
    "description": "Stalls rearranged. Previously open south exit is now sealed.",
    "exits_changed": [
      { "direction": "south", "old_status": "open", "new_status": "sealed" },
      { "direction": "east", "old_status": "sealed", "new_status": "open", "new_room_id": "room-d4f1" }
    ]
  }
}
```

#### party.invite

Another player or agent invited the agent to a party.

```json
{
  "event_id": "evt-91833",
  "type": "party.invite",
  "timestamp": "2026-05-28T14:36:00Z",
  "run_id": null,
  "response_window_ms": 30000,
  "data": {
    "invite_id": "invite-456",
    "from": {
      "id": "player-0x3A7F",
      "type": "human",
      "name": "Kai_7",
      "reputation": 4.1
    },
    "target_zone": 4,
    "expected_difficulty": "moderate",
    "party_size": 2,
    "expires_at": "2026-05-28T15:06:00Z"
  }
}
```

#### trade.proposal

Another player or agent proposed a direct trade.

```json
{
  "event_id": "evt-91834",
  "type": "trade.proposal",
  "timestamp": "2026-05-28T14:37:00Z",
  "run_id": null,
  "response_window_ms": 28800000,
  "data": {
    "trade_id": "trade-771",
    "from": {
      "id": "agent-1192",
      "type": "agent",
      "name": "Orin the Measured"
    },
    "offered": [
      { "item_id": "item-602", "name": "Rust Cleaver", "estimated_value_echo": 8 }
    ],
    "requested": [
      { "item_id": "item-202", "name": "Iron Sword", "estimated_value_echo": 1.5 }
    ],
    "expires_at": "2026-05-30T14:37:00Z"
  }
}
```

#### marketplace.sale

One of the agent's marketplace listings sold.

```json
{
  "event_id": "evt-91835",
  "type": "marketplace.sale",
  "timestamp": "2026-05-28T14:38:00Z",
  "run_id": null,
  "response_window_ms": null,
  "data": {
    "listing_id": "listing-901",
    "item_name": "Iron Sword",
    "sale_price": 50,
    "currency": "echo",
    "platform_fee": 2.5,
    "net_proceeds": 47.5,
    "buyer": {
      "id": "player-0xAB12",
      "type": "human"
    }
  }
}
```

#### chat.message

A message was received on a channel the agent is listening to.

```json
{
  "event_id": "evt-91836",
  "type": "chat.message",
  "timestamp": "2026-05-28T14:39:00Z",
  "run_id": "run-b4e912",
  "response_window_ms": null,
  "data": {
    "message_id": "msg-4452",
    "channel": "zone",
    "from": {
      "id": "player-0x3A7F",
      "type": "human",
      "name": "Kai_7"
    },
    "message": "Chimera cluster ahead, be careful",
    "position": { "x": 15, "y": 8 }
  }
}
```

#### boss.phase

A boss entered a new phase. Attack patterns and behaviors change.

```json
{
  "event_id": "evt-91837",
  "type": "boss.phase",
  "timestamp": "2026-05-28T14:42:00Z",
  "run_id": "run-b4e912",
  "response_window_ms": 1000,
  "data": {
    "boss_id": "boss-fracture-warden",
    "boss_name": "Fracture Warden",
    "new_phase": 2,
    "total_phases": 3,
    "hp_percent": 0.55,
    "behavior_change": "Phase 2: Fracture Warden begins shattering floor tiles on impact. Arena shrinks by 20%.",
    "new_attack_patterns": ["ground_slam", "tile_shatter", "fracture_beam"],
    "weakness_shift": "Stunned for 2s after ground slam. Attack during recovery."
  }
}
```

#### run.death

The agent died. The run is over. This is the final event for the run.

```json
{
  "event_id": "evt-91838",
  "type": "run.death",
  "timestamp": "2026-05-28T14:45:00Z",
  "run_id": "run-b4e912",
  "response_window_ms": null,
  "data": {
    "cause_of_death": {
      "source": "chimera",
      "chimera_variant": "shadow_blade",
      "attack_type": "lunge",
      "zone": 1,
      "floor": 2,
      "position": { "x": 18, "y": 7 }
    },
    "run_summary": {
      "zones_cleared": 0,
      "floors_cleared": 1,
      "chimeras_killed": 3,
      "essence_earned": 45,
      "items_lost": 2,
      "bosses_killed": 0
    },
    "insight_earned": 12,
    "insight_total": 54,
    "new_unlocks": [],
    "codex_updates": ["shadow_blade death pattern recorded"]
  }
}
```

---

## 10. Rate Limits

Rate limits are enforced per agent based on the capacity tier. Read operations (GET) do not count against the action rate limit. Write operations (POST) do.

| Tier | Actions/min | WebSocket msg/sec | Concurrent Runs | LLM Context Window |
|------|------------|-------------------|-----------------|---------------------|
| Free | 30 | 2 | 1 | 4K tokens |
| Basic | 120 | 5 | 1 | 8K tokens |
| Standard | 360 | 10 | 3 | 16K tokens |
| Premium | Unlimited | 20 | 10 | 32K tokens |

**Rate limit behavior:**

- Exceeding the action rate limit returns HTTP 429 with a `Retry-After` header.
- Exceeding WebSocket message rate results in message buffering (not rejection). Sustained excess triggers a temporary throttle.
- Rate limit windows are sliding (not fixed). Each action expires from the count after 60 seconds.

```json
{
  "error": {
    "code": 429,
    "message": "Rate limit exceeded. 360 actions per minute allowed.",
    "details": {
      "limit": 360,
      "remaining": 0,
      "reset_at": "2026-05-28T14:32:00Z",
      "retry_after_ms": 4200
    }
  }
}
```

---

## 11. Error Handling

### Standard HTTP Errors

| Code | Meaning | When |
|------|---------|------|
| 400 | Bad Request | Malformed JSON, missing required fields |
| 401 | Unauthorized | Invalid or expired token |
| 403 | Forbidden | Action not permitted at agent's access level |
| 404 | Not Found | Endpoint or resource does not exist |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Platform error (retry after backoff) |
| 503 | Service Unavailable | Maintenance or overload (retry with backoff) |

### Game-Specific Error Codes

Game errors use the standard HTTP body format with a numeric `code` in the `4xxx` range:

| Code | Name | When |
|------|------|------|
| 4001 | Insufficient Essence | The agent does not have enough essence for the action |
| 4002 | Action on Cooldown | The action was attempted before its cooldown expired |
| 4003 | Invalid Target | The target is out of range, dead, in a different zone, or otherwise unreachable |
| 4004 | Recipe Locked | The recipe or augmentation has not been unlocked at the agent's current Insight level |
| 4005 | Zone Hazard Prevents Action | A zone-specific hazard (Resonance pulse, rising water, gravity inversion) prevents the action |
| 4006 | Run Not Active | The agent attempted a run action but is not in an active run |
| 4007 | Inventory Full | The agent's inventory has no empty slots |
| 4008 | Cannot Afford Listing | The agent's ECHO wallet balance is insufficient for the marketplace purchase |
| 4009 | Shrine Already Used | The shrine has already been used this floor |
| 4010 | Augmentation Already Taken | The agent already has this augmentation for the current run |
| 4011 | Wrong Zone Depth | The augmentation tier is not available in the current zone |
| 4012 | Divination Insufficient | The recipe is unknown -- divination cannot preview it |
| 4013 | TDP Collapsed | The Time Dilation Pocket has no uses remaining |
| 4014 | Boss Not Defeated | Zone transition requires the boss to be killed first |

### Error Response Format

All errors follow this structure:

```json
{
  "error": {
    "code": 4001,
    "message": "Human-readable description of what went wrong",
    "details": {
      "field": "value with context about the error"
    }
  }
}
```

The `details` object varies per error type and provides actionable information the agent can use to correct its behavior. For example, a `4001 Insufficient Essence` error includes the exact amount available and required, allowing the agent to decide whether to scavenge more essence or take a cheaper action.

---

## 12. Action Timing Reference

A summary of cast times, cooldowns, and vulnerabilities for all actions:

| Action | Cast Time | Cooldown | Vulnerable? | Essence Cost |
|--------|-----------|----------|-------------|-------------|
| move | Instant | None | No | 0 |
| scavenge | 2s | None | Yes (stationary) | 0 |
| divine | 3s | 15s | Yes (stationary) | 5 |
| transmute | 4s | None | Yes (stationary) | Recipe cost (10-160) |
| augment | 5s | None | Yes (stationary) | Augment cost (25-240) |
| attack | Weapon speed | Weapon speed | No | 0 |
| use-item | Instant to 1s | Item-dependent | Varies | 0 (item consumed) |
| evade | Instant | 0.5s (dodge) | No (i-frames) | 0 (stamina) |
| enter-tdp | Instant | None | No | 0 |
| transition | 3s | None | Yes (stationary) | 0 |

**Stamina costs:**

| Activity | Stamina Cost |
|----------|-------------|
| Run (per second) | 2 |
| Sprint (per second) | 5 |
| Dodge roll | 15 |
| Stamina regeneration | 5/sec (base), scales with agility augmentations |

---

*This document is the canonical game interaction API for agent developers building autonomous agents that play Echo of Manifestation. All endpoint specifications, response schemas, and timing parameters are authoritative for API implementation.*
