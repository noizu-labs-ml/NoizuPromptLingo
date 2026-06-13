# Persona 08: The Accessibility Advocate

**Name:** Kai Rivera
**Age:** 27
**Location:** Chicago, IL
**Occupation:** QA engineer at a fintech company, part-time accessibility consultant
**Device:** iPhone 15, uses VoiceOver and Switch Control daily
**Income:** $78K/year

---

## Profile

Kai has limited fine motor control due to cerebral palsy. He uses iOS Switch Control for most interactions and VoiceOver for screen reading. He's an avid gamer who's been vocal in the accessibility community about mobile games that claim to support assistive tech but don't actually test with it. He's written threads that went viral criticizing specific games, and he's also written glowing reviews of games that got it right.

He found AI Fighter's style guide with its accessibility checklist and was cautiously optimistic. The async, non-twitch gameplay model is inherently more accessible than real-time games. But the graph editor — a drag-and-drop node-and-wire interface — is one of the hardest UI patterns to make accessible. If AI Fighter nails this, Kai will be its loudest advocate. If it doesn't, he'll be its most public critic.

---

## Goals

- Play the full game — build fighters, train them, compete in ranked — using Switch Control and VoiceOver
- Verify that the graph editor is navigable without precise drag-and-drop gestures
- Advocate for accessibility features that benefit all players (clear state indicators, scannable replays, reduced motion)
- Be competitive, not just accommodated — he doesn't want a "simplified mode," he wants the real game to work

## Frustrations

- Drag-and-drop interfaces with no keyboard/switch alternative
- Visual-only state indicators (color alone differentiating node types without shape/icon/label)
- Animations that can't be disabled or that interfere with screen readers
- "Accessibility modes" that strip out game features instead of making the real UI accessible
- Touch targets under 44px
- Unlabeled icons with no text alternative

## Behaviors

- Tests every interactive element with VoiceOver before playing the actual game
- Reports accessibility bugs with detailed reproduction steps and WCAG references
- Plays 3-4 sessions per day when a game is accessible, 0 sessions when it's not
- Will write a public accessibility review within the first week
- Shares accessible games in disability community forums — strong word-of-mouth network
- Will spend money if the game respects his needs ($10-20/season)

---

## Key Scenarios

1. **First session:** Enables VoiceOver, opens the app. Can he navigate the home screen? Are tab bar items labeled? Can he enter the Fighter Studio? Can he add a node to the graph without drag-and-drop (e.g., via a list-based "connect node A to node B" interface)?
2. **Week 1:** Has completed a full accessibility audit. Files 5-15 bug reports ranging from "missing ARIA labels on stat cards" to "graph editor completely inaccessible via Switch Control." Posts a Twitter thread: either "AI Fighter is [surprisingly accessible / completely broken] for disabled gamers"
3. **Month 1:** If accessible: active player at Gold rank, has written a detailed accessibility review that the dev team links to. If not: has moved on, leaving behind a viral criticism thread

---

## Design Implications

- The graph editor MUST have an alternative interaction mode beyond drag-and-drop: a list/menu-based node connection interface ("Connect: [Perception: Distance] → [Decision: Aggression]") that achieves the same result
- All four signal colors (synapse, combat, signal, reward) must have non-color indicators: node category icons, text labels, or distinct shapes
- Touch targets at 48px (the style guide's preferred size, not the 44px minimum)
- All animations must respect `prefers-reduced-motion` — already specified in the style guide, but must be tested with real assistive tech
- VoiceOver must announce battle state changes (health drops, decision events) via live regions
- Screen reader labels must describe game state, not just UI structure: "Attack node, weight 0.7, connected to Aggression decision" not just "Node"
- This persona represents 15-20% of mobile gamers who use some form of assistive technology — not a niche, a market
