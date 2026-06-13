# US-257: Event Scripting Engine

**Persona:** Dave — MUD veteran who wants to author world events without requiring code deploys
**Priority:** P1
**Epic:** Admin, GM & Infrastructure

## Story
As Dave, I want a text-based scripting system for authoring world events so that I can create trigger-based, branching event sequences that respond to player actions without writing Elixir code or pushing to production.

## Acceptance Criteria
- [ ] Script authoring via a dedicated web-based script editor accessible to Senior GM+ role; editor provides: syntax highlighting, inline validation, a command reference panel, and a preview/test mode that runs the script in a sandboxed environment
- [ ] Script language supports: trigger conditions (player enters room, item picked up, NPC killed, time elapsed, player count threshold reached, custom flag set), actions (narrate text to room/region/world, spawn NPC, spawn item, teleport player, set world flag, send mail, trigger sub-script), and control flow (if/else on world flags and player attributes, delay, repeat, branch on player choice)
- [ ] Player choice branching: scripts can present players with a choice prompt navigable via screen reader; choices stored as local or world flags; example: "A hooded figure approaches. [Accept the quest] [Decline politely] [Demand payment]" — each choice triggers a different script branch
- [ ] Scripts are versioned: each save creates a new version; previous versions browsable and restorable; active version explicitly set by GM; version history shows author, timestamp, change summary
- [ ] Test mode executes script in isolated sandbox: simulates triggers with mock player data, outputs what would be narrated to whom, validates syntax and logic errors, identifies unreachable branches; no sandbox execution affects live game state
- [ ] Script scheduling: scripts can be set to trigger on a real-world schedule (cron-style: "every Monday at 18:00 UTC"), on in-game time events (at dawn of each in-game season), or on-demand via GM trigger command `/gm run [script-id]`
- [ ] Script resource limits enforced: maximum 100 actions per script execution, maximum 10 sub-script nesting depth, maximum 30-second execution window; scripts exceeding limits are terminated with error logged; prevents runaway scripts from impacting server performance
- [ ] Scripts reference content by stable ID (room IDs, NPC IDs, item IDs) not by name; ID resolution validated at script save time; invalid IDs produce a validation error with suggested matches; this prevents scripts from silently failing when content is renamed

## Notes
Dave's background as a sysadmin means he has scripting experience — he can handle a DSL more complex than a visual node editor. But the requirement "non-engineer scriptable" in the original brief means the language must also be learnable by community managers and storytellers without programming backgrounds. The target user is "comfortable with spreadsheet formulas and markdown, never written code."

The script language should be YAML-based (not Lua, not JavaScript) for accessibility reasons: YAML is readable, structure is implied by indentation, and it maps naturally to the game's existing YAML-heavy infrastructure. A representative snippet:

```yaml
trigger:
  type: player_enters_room
  room_id: "room_dark_cave_entrance"
on_trigger:
  - action: narrate
    text: "A low growl echoes from the depths."
    target: triggering_player
  - action: delay
    seconds: 3
  - action: choice
    text: "Do you proceed?"
    options:
      - label: "Enter carefully"
        branch: enter_cave
      - label: "Turn back"
        branch: flee
branches:
  enter_cave:
    - action: teleport
      player: triggering_player
      room_id: "room_dark_cave_interior"
  flee:
    - action: narrate
      text: "Wisdom, perhaps."
      target: triggering_player
```

This is readable by a non-programmer and executable by the Elixir backend without needing a general-purpose interpreter. The backend compiles scripts to an Elixir-native AST on save, catches errors at compile time, and executes the AST on trigger.

The test mode sandbox is the feature that makes the scripting engine trustworthy. Dave should be able to run "simulate player Marcus entering room X with level 20 and clan rank Officer" and see exactly what narration would be delivered, what items spawned, what flags set. This catches mistakes before they go live.

World flags are the state mechanism: global key-value pairs persisted in the database, settable and readable by scripts. Example: `summer_festival_active: true`, `boss_defeated_count: 47`. Flag names must be namespaced by script family to prevent collision: `event_summer_2026_festival_active`. Flags should be browsable via GM panel with current values.
