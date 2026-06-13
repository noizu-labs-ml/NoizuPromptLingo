# US-120: AI Help and Hint System

**Persona:** Elena — Blind teenager (16, VoiceOver+iOS, social play)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Elena, I want to be able to ask for help when I'm stuck without getting a flat list of commands or a spoiler that ruins the puzzle — I want the game to understand what I'm trying to do and give me just enough to get unstuck, delivered in a way my screen reader can handle.

## Acceptance Criteria
- [ ] HELP command with no arguments triggers AI-driven context-aware help: analyzes player's current location, active quests, recent command history, and current inventory to infer what the player is likely trying to accomplish
- [ ] Hint depth is adjustable and explicit: HELP → nudge (direction without specifics), HELP MORE → hint (mechanism without solution), HELP SOLVE → full solution with spoiler warning preamble
- [ ] Hint content is generated fresh per context, never a static help file — the hint references the player's actual situation ("You've been in the crypt for 20 minutes and examined the altar twice; perhaps what you seek is related to what you carry.")
- [ ] Spoiler warning delivered as a distinct ARIA announcement before HELP SOLVE content: "The following hint fully reveals the solution. Press H to continue or any other key to cancel." — VoiceOver and TalkBack compatible interrupt pattern
- [ ] Command reference help available separately via COMMANDS — a structured, screen-reader-navigable list of available commands grouped by category with keyboard navigation by heading
- [ ] Help system understands implicit context: HELP after a failed combat sequence → tactical hints; HELP in an unexplored room → exploration encouragement; HELP while carrying a quest item near its destination → delivery hint
- [ ] Hint generation avoids spoiling quests the player hasn't started: if the solution to the current puzzle unlocks a quest the player doesn't know about, the hint describes the immediate goal without revealing the downstream consequence
- [ ] Help request frequency tracked per player; players requesting help more than 3 times in 10 minutes on the same puzzle trigger an optional "Would you like a complete walkthrough?" offer via ARIA status message

## Notes
Help system implemented as `BladeOfEternity.AI.HelpAdvisor` — GenServer per player session. Maintains: `help_context` (current location, active quests, inventory snapshot, recent command log last 20 commands), `hint_depth` (current depth state for progressive hints), `hint_session` (hints given for current context, to avoid repeating).

Context analysis: before generating a hint, `HelpAdvisor` assembles a context summary: recent commands (pattern recognition — repeated EXAMINE of same object suggests puzzle stuck-point), active quest objectives (unresolved steps), inventory (items not yet "used" in obvious ways), time in current room. This context is the prompt input rather than raw player question, allowing the AI to infer intent.

Hint depth management: HELP resets hint_depth to `:nudge` unless the player recently received a nudge in the same context (within 2 minutes), in which case it auto-advances to `:hint`. HELP MORE always advances one level. HELP SOLVE always goes to `:solution`. Depth state stored per `{player_id, context_hash}` in ETS.

Spoiler interrupt pattern for VoiceOver: delivering a multi-step announcement (warning then content) on VoiceOver iOS requires careful ARIA sequencing. Implementation: inject warning text into `aria-live="assertive"` region (interrupts current announcement), then wait for explicit player confirmation via a keypress handler, then inject solution text. The keypress handler uses Phoenix Channel bidirectional messaging: frontend sends `{:help_confirm, player_id}`, backend dispatches solution generation.

Command reference (COMMANDS): a statically-generated structured document, refreshed nightly or on command set changes. Delivered as a Phoenix Channel response (not AI-generated — static for reliability). Format: `<dl>` with `<dt>` for command name and `<dd>` for description, grouped by category with ARIA heading structure. Screen reader navigable by heading → command name.

Hint generation prompt includes: a "DO NOT REVEAL" list constructed from downstream quest chains — using quest graph (US-106) to identify consequences of current puzzle solution, stripping these from what the hint can reference. Prompt: "The player is stuck. Hint at the `:nudge` level — direction only, no mechanism, no consequence beyond immediate goal."

Frequency tracking: ETS counter per `{player_id, puzzle_context_hash}`. On 3rd help request within 10 minutes: `HelpAdvisor` publishes `{:help_frustrated, player_id}` event → frontend injects polite status message: "It seems this challenge has been testing you. Type HELP GUIDE for a full walkthrough."
