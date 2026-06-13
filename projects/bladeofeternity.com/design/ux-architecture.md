# UX Architecture — Blade of Eternity

Screen-reader-first interaction design for a text RPG where ARIA live regions are the rendering engine and keyboard input is the primary controller.

## Design Constraint

Every feature must work for a blind user using NVDA+Firefox, JAWS+Chrome, or VoiceOver+Safari. Visual presentation is additive. If it can't be announced, it doesn't exist.

---

## 1. Page Architecture

### Landmark Map

```
┌──────────────────────────────────────────────────────────┐
│ <header> — "Blade of Eternity"                           │
│   Skip links: "Skip to story" | "Skip to command input"  │
├───────────────────────────────────┬──────────────────────┤
│ <main> — "Game"                   │ <aside> — "Character"│
│                                   │                      │
│ <h1> Location: Rune — Town Square │ <h2> Stats           │
│                                   │   HP, Energy, Gold   │
│ <section> "Story"                 │                      │
│   <h2> Story                      │ <h2> Equipment       │
│   <div role="log"> narrative...   │   Weapon, Armor      │
│                                   │                      │
│ <section> "Actions"               │ <h2> Effects         │
│   <h2> Available Actions          │   Buffs, Debuffs     │
│   <ul role="menu"> choices...     │                      │
│                                   │                      │
│ <form> "Command input"            │                      │
│   <input> Enter command           │                      │
│                                   │                      │
│ <section> "Alerts"                │                      │
│   <div role="alert"> (hidden)     │                      │
├───────────────────────────────────┴──────────────────────┤
│ <footer> — Connection status, settings                    │
└──────────────────────────────────────────────────────────┘
```

### Heading Hierarchy

Screen reader users navigate by pressing H (next heading) or 1-6 (specific level):

```
h1  Rune — Town Square           ← Current location (changes on move)
  h2  Story                      ← Narrative log
  h2  Available Actions          ← Current choices
  h2  Stats                      ← Character status (in aside)
  h2  Equipment                  ← Gear (in aside)
  h2  Effects                    ← Active buffs/debuffs (in aside)
    h3  [Sub-sections as needed]
```

**Rule:** Never exceed h3. Deep nesting makes heading navigation useless.

### Skip Navigation

Two skip links, visible on focus:

1. **Skip to story** — focuses the narrative log region (`tabindex="-1"` on the `role="log"` div)
2. **Skip to command input** — focuses the input field

These must be the first focusable elements in the DOM.

---

## 2. ARIA Live Region Architecture

Three dedicated live region channels, always present in the DOM:

### Narrative Channel

```html
<div
  role="log"
  aria-live="polite"
  aria-atomic="false"
  aria-relevant="additions"
  aria-label="Story"
>
  <!-- New paragraphs appended here -->
  <!-- Screen reader announces each new addition after finishing current speech -->
</div>
```

**Writes to this channel:**
- Room descriptions on entry
- NPC dialogue
- Quest narrative
- Action outcomes ("You swing your blade...")
- Physics descriptions ("The wall crumbles, dust billowing outward...")
- Crafting results
- Discovery/lore text

**Write rules:**
- One complete thought per write (paragraph or short sequence)
- Never update mid-sentence
- Append only — don't replace content (it's a log)
- Throttle: minimum 200ms between writes to allow screen reader to queue properly

### Alert Channel

```html
<div
  role="alert"
  aria-live="assertive"
  aria-atomic="true"
  aria-label="Game alerts"
  class="sr-only"
>
  <!-- Single message, replaced each time -->
  <!-- Screen reader interrupts current speech to announce -->
</div>
```

**Writes to this channel (use sparingly):**
- Damage taken in combat
- Player death
- Connection lost / reconnected
- Imminent environmental danger ("The ceiling is collapsing!")
- Session timeout warning

**Write rules:**
- Replace content entirely (atomic=true)
- Maximum 1 assertive announcement per 2 seconds
- Clear the element 5 seconds after writing (prevents re-reading on focus)

### Status Channel

```html
<div
  role="status"
  aria-live="polite"
  aria-atomic="true"
  aria-label="Game status"
  class="sr-only"
>
  <!-- Single status line, replaced each time -->
</div>
```

**Writes to this channel:**
- HP/Energy changes (non-combat)
- Buff/debuff applied or expired
- Time of day changes
- Weather changes
- Gold gained/spent
- XP gained / level up

**Write rules:**
- Batch related changes: "You gained 50 gold and 25 XP" not two separate writes
- Replace content entirely
- Lower priority than narrative — okay if user misses these occasionally

---

## 3. Combat Interaction Model

Combat is the most demanding screen reader scenario: rapid state changes, multiple channels, and player input required.

### Turn Flow

```
1. Player submits command         → Focus stays on input
2. Combat engine resolves         → Backend calculates via physics engine
3. AI narrator generates prose    → Structured event → natural language
4. Client receives event batch    → Single WebSocket message with all results
5. Render sequence:
   a. Narrative channel: action prose    (polite — queues)
   b. Alert channel: damage taken        (assertive — if HP critical)
   c. Status channel: HP/effect changes  (polite — queues after narrative)
   d. Actions menu updates               (new options available)
6. Input ready                    → Screen reader cue: "Enter command"
```

### Batching Combat Events

The Elixir backend resolves a full combat round atomically and sends results as a single payload:

```json
{
  "narrative": "Your blade catches the brute's shoulder. He staggers, reaching for the wall. Stone cracks under his grip.",
  "alert": null,
  "status": "HP: 73/100 (-12). The brute is wounded.",
  "actions": ["Attack again", "Use Elusion", "Retreat", "Check inventory"]
}
```

The client writes to channels in sequence with 100ms delays between each to prevent announcement collision.

### Critical HP Threshold

When HP drops below 25%, the alert channel fires: "Warning: health critical. 18 of 100 remaining."

This is the one case where assertive interruption is justified during combat narrative.

---

## 4. Command Input Design

### Input Behavior

```html
<form aria-label="Command input" role="search">
  <label for="command-input" class="sr-only">Enter command</label>
  <input
    id="command-input"
    type="text"
    aria-label="Enter command"
    aria-describedby="input-hint"
    autocomplete="off"
    spellcheck="false"
  />
  <div id="input-hint" class="sr-only">
    Type a command or use arrow keys to browse command history.
    Press Tab to navigate to other game panels.
  </div>
</form>
```

### Command History

- Up arrow: previous command
- Down arrow: next command
- The current history entry replaces the input value
- Screen reader announces the restored command text via input's value change

### Command Autocomplete (Optional Enhancement)

If implemented, use `role="combobox"` with `aria-expanded`, `aria-activedescendant`, and a listbox:

```html
<input
  role="combobox"
  aria-expanded="true"
  aria-controls="command-suggestions"
  aria-activedescendant="suggestion-2"
/>
<ul id="command-suggestions" role="listbox">
  <li id="suggestion-1" role="option">attack</li>
  <li id="suggestion-2" role="option" aria-selected="true">attack brute</li>
  <li id="suggestion-3" role="option">attack with slingshot</li>
</ul>
```

### Context-Sensitive Help

When the input is focused and empty, pressing `?` displays available commands for the current context via the narrative channel:

```
Available commands:
  look        — Examine your surroundings
  go [dir]    — Move north, south, east, west, up, down
  attack      — Engage in combat
  inventory   — Check your belongings
  talk [npc]  — Speak with someone nearby
  help        — Full command reference
```

---

## 5. Choice Menu Pattern

When the game presents explicit choices (dialogue options, quest decisions, the mask or the knife):

```html
<section aria-label="Available actions">
  <h2>Choose your path</h2>
  <ul role="menu" aria-label="Choices">
    <li role="menuitem" tabindex="0">Put on the mask</li>
    <li role="menuitem" tabindex="-1">Use the ritual knife</li>
  </ul>
</section>
```

### Keyboard Behavior

| Key | Action |
|-----|--------|
| Arrow Down | Focus next choice |
| Arrow Up | Focus previous choice |
| Enter | Select focused choice |
| Escape | Return focus to command input (if cancellable) |
| Home | Focus first choice |
| End | Focus last choice |

### Screen Reader Announcement

On menu appearance: "Choose your path. Menu with 2 items. Put on the mask."

Each arrow key press announces the focused option. Enter submits and returns focus to input after the game responds.

---

## 6. Stats Panel (Aside)

The stats panel is always present but never demands attention. It's a reference panel — users navigate to it when they want to check status.

```html
<aside aria-label="Character">
  <h2>Stats</h2>
  <dl>
    <dt>Health</dt>
    <dd aria-live="off">73 / 100</dd>

    <dt>Energy</dt>
    <dd aria-live="off">45 / 50</dd>

    <dt>Gold</dt>
    <dd aria-live="off">1,250</dd>

    <dt>Level</dt>
    <dd>14</dd>

    <dt>Location</dt>
    <dd>Rune — Town Square</dd>
  </dl>

  <h2>Equipment</h2>
  <dl>
    <dt>Weapon</dt>
    <dd>Iron Shortsword (+12 attack)</dd>

    <dt>Armor</dt>
    <dd>Leather Cuirass (+8 defense)</dd>
  </dl>

  <h2>Active Effects</h2>
  <ul aria-label="Active effects">
    <li>Elusion Level 2 — 3 turns remaining</li>
  </ul>
</aside>
```

**Key:** `aria-live="off"` on the stat values. Changes are announced via the status channel, not by the stat elements themselves. This prevents duplicate announcements.

---

## 7. Connection State

The Elixir backend connection is critical. Connection loss must be announced immediately:

```html
<footer>
  <div
    role="status"
    aria-live="assertive"
    aria-label="Connection status"
  >
    <!-- Only populated when connection state changes -->
  </div>
</footer>
```

**States:**
- Connected (silent — no announcement needed)
- "Connection lost. Attempting to reconnect..." (assertive)
- "Reconnected. You are in Rune — Town Square." (assertive, with context restoration)
- "Connection failed. Check your network and refresh." (assertive)

---

## 8. Modal Dialogs

For confirmation prompts, inventory management, or settings:

```html
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-desc"
>
  <h2 id="dialog-title">Confirm Action</h2>
  <p id="dialog-desc">
    Are you sure you want to put on the mask? This cannot be undone.
  </p>
  <button autofocus>Yes, put it on</button>
  <button>No, leave it</button>
</div>
```

**Focus trap:** Tab cycles only within the dialog. Escape dismisses and returns focus to the trigger element (or command input if no trigger).

---

## 9. Responsive Behavior

The game must work on mobile screen readers (VoiceOver on iOS, TalkBack on Android):

- **Single column layout** below 768px — aside collapses into an expandable section within main
- **Touch targets:** minimum 44x44px for all interactive elements
- **Virtual keyboard:** command input must keep the keyboard visible; no layout shift on focus
- **Swipe gestures:** VoiceOver users swipe left/right to navigate elements — ensure logical DOM order matches visual order

---

## 10. Audio Integration Points

Audio supplements text but never replaces it:

| Trigger | Audio | Text Equivalent |
|---------|-------|-----------------|
| Enter new room | Ambient soundscape fades in | Room description in narrative channel |
| Combat hit landed | Impact sound | "Your blade connects..." in narrative |
| Combat damage taken | Pain/grunt sound | Alert: "You take 12 damage" |
| Physics event (collapse) | Rumbling/crash | "The ceiling gives way..." in narrative |
| Item acquired | Chime | Status: "You found Iron Key" |
| Level up | Fanfare | Status: "You reached level 15!" |
| Death | Silence (ambient cuts) | Alert: "You have fallen." |

**Audio controls:** Global mute, volume slider, category toggles (ambient, effects, music). All accessible via settings dialog with proper ARIA labeling.

**Web Audio API** for spatial audio — direction of sounds matches physics engine spatial model. A player using headphones can hear an enemy approaching from the left, matching the text: "Footsteps echo from the passage to your left."

---

## 11. Testing Protocol

### Screen Reader Testing Matrix

| Reader | Browser | OS | Priority |
|--------|---------|-----|----------|
| NVDA | Firefox | Windows | P0 |
| JAWS | Chrome | Windows | P0 |
| VoiceOver | Safari | macOS | P0 |
| VoiceOver | Safari | iOS | P1 |
| TalkBack | Chrome | Android | P1 |

### Automated Checks

- axe-core: 0 critical/serious violations
- Lighthouse accessibility: 100
- All interactive elements keyboard-reachable
- All live regions fire correctly (manual verification required)
- Color contrast: all text meets AAA (7:1) minimum

### Manual Test Scenarios

1. **New player onboarding** — complete character creation and first room using only screen reader
2. **Combat round** — engage enemy, take damage, use skill, survive — verify announcement sequence
3. **Navigation** — move between three rooms, verify location updates in h1 and narrative
4. **Choice resolution** — encounter branching choice (mask/knife), make selection, verify outcome
5. **Connection loss** — simulate disconnect, verify alert, reconnect, verify state restoration
6. **Inventory management** — open inventory dialog, equip item, close dialog, verify focus return
7. **Chat/social** — receive clan message during exploration, verify it doesn't disrupt narrative flow
