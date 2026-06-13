# Style Guide: CodeFresh — Direction B: Minimal Tech + Editorial

> Rigorous testing interface with readability-optimized conversation views.

**Style System:** Minimal Tech 80% + Editorial 20%
**Source Specs:** minimal-tech.md + editorial.md
**Scenario:** AI agent behavioral testing platform — emphasis on conversation transcript readability

---

## Scenario

CodeFresh is a behavioral testing framework for AI agents. Direction A (pure Minimal Tech) treats conversation transcripts as code — monospaced, dense, developer-native. But a core CodeFresh workflow is **reading multi-turn conversations** between test scripts and agents, then judging behavioral quality. These conversations are prose, not code. When an engineer is reviewing a 12-turn freeball deviation to decide whether to promote it to a permanent branch, readability matters.

This direction brings **Editorial's reading-optimized typography and spacing** into the conversation review experience, while keeping the graph editor, dashboard, and all interactive chrome pure Minimal Tech. The 20% Editorial influence creates a clear visual distinction between "building tests" (Minimal Tech) and "reading results" (Editorial warmth).

**Signals:** Intelligence + depth. "We're precise about testing, and we take the conversation content seriously."

**Mix rationale:** Minimal Tech provides the structural foundation (monochrome palette, sidebar layout, functional interactions, developer density). Editorial contributes **serif typography for conversation transcripts**, **generous line spacing in review panels**, and **pull-quote styling for highlighted agent responses**.

---

## Color Palette

```css
:root {
  /* 80% — Minimal Tech foundation (dark mode) */
  --bg-primary: #09090B;
  --bg-surface: #141418;
  --bg-elevated: #1C1C22;

  --text-primary: #EDEDF0;
  --text-secondary: #8E8E9A;
  --text-tertiary: #56566A;

  --border-default: #27272F;
  --border-subtle: #1C1C22;

  /* Accent — Violet */
  --accent: #7C3AED;
  --accent-hover: #8B5CF6;
  --accent-muted: rgba(124, 58, 237, 0.12);

  /* Eval Results */
  --eval-pass: #22C55E;
  --eval-pass-muted: rgba(34, 197, 94, 0.12);
  --eval-warn: #EAB308;
  --eval-warn-muted: rgba(234, 179, 8, 0.12);
  --eval-fail: #EF4444;
  --eval-fail-muted: rgba(239, 68, 68, 0.12);
  --eval-freeball: #F97316;
  --eval-freeball-muted: rgba(249, 115, 22, 0.12);

  --info: #60A5FA;

  /* No Editorial color additions — palette stays 100% Minimal Tech */
}
```

**Usage rules:** Identical to Direction A. The palette is entirely Minimal Tech — Editorial's contribution is typographic, not chromatic.

---

## Typography

**Font stack:**
```css
/* 80% — Minimal Tech: UI, graph, nav, code */
--font-sans: 'Geist', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--font-mono: 'Geist Mono', 'JetBrains Mono', 'Fira Code', Consolas, monospace;

/* 20% — Editorial influence: conversation transcript body */
--font-prose: 'Source Serif 4', 'Georgia', serif;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| H1 | Sans | 28px | 600 | 1.2 | Page titles |
| H2 | Sans | 22px | 600 | 1.25 | Panel titles, script names |
| H3 | Sans | 18px | 600 | 1.3 | Node labels, card headers |
| Body (UI) | Sans | 14px | 400 | 1.6 | Default interface text |
| **Body (Transcript)** | **Serif** | **16px** | **400** | **1.75** | **Conversation transcripts in review** |
| **Agent Response** | **Serif** | **16px** | **400** | **1.75** | **Agent output in detail panels** |
| Code | Mono | 13px | 400 | 1.5 | Prompts, YAML, expectations |
| Caption | Sans | 11px | 500 | 1.4 | Metadata, scores |
| Body Small | Sans | 12px | 400 | 1.5 | Timestamps, annotations |

**Typography notes:**
- **The 20% element:** Conversation transcripts and agent responses in review panels use Source Serif 4 at 16px with 1.75 line height. This makes reviewing 12-turn conversations significantly less fatiguing than monospace.
- Prompt inputs (what the script *sends*) remain in mono — they're code-like instructions. Agent *responses* (what you're evaluating) render in serif — they're prose you need to read and judge.
- Serif appears ONLY within `.transcript` and `.agent-response` containers — never in navigation, graph editor, sidebars, or code views.
- Expectation definitions and YAML scripts always render in mono regardless of context.

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Geist | Vercel | Free / OFL | [GitHub](https://github.com/vercel/geist-font) |
| Geist Mono | Vercel | Free / OFL | [GitHub](https://github.com/vercel/geist-font) |
| Source Serif 4 | Adobe (original) | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/source-serif) \| [Google Fonts](https://fonts.google.com/specimen/Source+Serif+4) |

---

## Spacing & Layout

**Spacing scale:** 4, 8, 12, 16, 24, 32, 48, 64, 96px (Minimal Tech — unchanged)

**Grid:** Identical to Direction A.

**Layout pattern:** Same sidebar + main workspace as Direction A. The 20% Editorial influence appears inside the **run detail view**, where the conversation transcript gets generous spacing:

```
+------------------------------------------------------------------+
|  RUN DETAIL: onboarding-flow × hostile persona                   |
+----------+-------------------------------------------------------+
|          |  ┌──────────────────────────────────────────────────┐  |
| GRAPH    |  │  CONVERSATION TRANSCRIPT (Editorial styling)    │  |
| VIEW     |  │                                                  │  |
| (left)   |  │  SCRIPT:                                         │  |
|          |  │  "Design a website for learning a second         │  |
|          |  │  language" ← mono, 13px                          │  |
| Nodes    |  │                                                  │  |
| colored  |  │  AGENT:                                          │  |
| by eval  |  │  The agent responded with a thoughtful           │  |
| result   |  │  breakdown of the project scope, asking          │  |
|          |  │  about target audience and proficiency            │  |
|          |  │  levels... ← serif, 16px, 1.75 leading           │  |
|          |  │                                                  │  |
|          |  │  EXPECTATIONS:                                    │  |
|          |  │  ✓ asks clarifying questions (0.92)              │  |
|          |  │  ✓ doesn't correct grammar (1.00)                │  |
|          |  │  ⚠ proposes concrete structure (0.45)            │  |
|          |  │                                                  │  |
|          |  └──────────────────────────────────────────────────┘  |
+----------+-------------------------------------------------------+
```

**20% Editorial influence on spacing:**
- Within transcript panels, vertical spacing between turns increases from 16px to 28px
- Agent response blocks get 24px internal padding (vs. 12px in Direction A)
- Max width for transcript text: 72ch (prevents ultra-wide line lengths in detail panels)

---

## Component Styling

### Buttons, Inputs, Navigation, Graph Nodes

Identical to Direction A. The 20% Editorial accent does not touch interactive components — these remain pure Minimal Tech.

### Transcript-Specific Treatments (20% Editorial Influence)

```css
/* Conversation transcript container */
.transcript {
  max-width: 72ch;
}

/* Agent response — the primary Editorial element */
.agent-response {
  font-family: var(--font-prose);
  font-size: 16px;
  line-height: 1.75;
  color: var(--text-primary);
  padding: 16px 20px;
  margin: 8px 0;
  border-left: 2px solid var(--border-default);
}
.agent-response p + p {
  margin-top: 20px;
}

/* Script prompt — stays mono */
.script-prompt {
  font-family: var(--font-mono);
  font-size: 13px;
  line-height: 1.5;
  color: var(--text-secondary);
  padding: 8px 12px;
  background: var(--bg-elevated);
  border-radius: 4px;
}

/* Turn separator — generous spacing */
.turn-separator {
  margin: 28px 0;
  border: none;
  border-top: 1px solid var(--border-subtle);
}

/* Highlighted agent quote — Editorial pull-quote influence */
.agent-highlight {
  font-family: var(--font-prose);
  font-size: 18px;
  font-style: italic;
  line-height: 1.6;
  border-left: 3px solid var(--accent);
  padding: 12px 20px;
  margin: 24px 0;
  color: var(--text-primary);
}

/* Expectation results within transcript */
.expectation-result {
  font-family: var(--font-sans);
  font-size: 13px;
  line-height: 1.5;
  padding: 8px 12px;
  background: var(--bg-surface);
  border-radius: 4px;
  margin: 16px 0;
}
```

---

## Interaction & Motion

Identical to Direction A. All 150ms ease transitions, functional-only animations. Editorial does not influence interaction patterns.

One addition: in the transcript view, conversation turns can fade in sequentially as the user scrolls (200ms fade, 50ms stagger) to create a "replay" feeling. This is the only animation specific to the Editorial-influenced surfaces.

---

## Asset Guidelines

Same as Direction A. No photography, Lucide icons, monochrome data visualizations.

---

## Mixing Notes

### Elements Carrying the 20% Editorial Accent (3 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Agent response typography** | Mono → Serif (Source Serif 4), 13px → 16px, line-height 1.5 → 1.75 | Agent responses are natural language prose. Engineers need to *read and judge tone, helpfulness, and behavioral quality* — not scan code. Serif type at readable size reduces fatigue during long review sessions. |
| **Turn spacing in transcripts** | 16px → 28px between turns | Conversation turns need clear visual separation. Each turn is a distinct evaluative moment — the engineer needs to see where one ends and the next begins without scanning. |
| **Agent response highlight (pull-quote)** | No equivalent in Direction A → italic serif with accent border-left | When reviewing deviations, engineers need to flag specific agent responses for team discussion. The Editorial pull-quote pattern provides a visually distinct "this is the important part" marker. |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| Serif for script prompts too | Prompts are authored input — they're closer to code than prose. Keeping them mono preserves the "I wrote this / the agent wrote that" visual distinction. |
| Drop caps on first agent response | Too magazine-like for a testing tool. Would signal "editorial publication," not "test results." |
| Reading progress bar on transcripts | Transcripts aren't read linearly — engineers jump between turns. A progress bar would be misleading. |
| Serif for graph node labels | Breaks consistency with the graph editor. Nodes are functional UI elements, not reading content. |
| Warm cream background for transcript panels | Conflicts with dark mode palette and creates a jarring context switch. |

---

## Implementation Checklist

- [ ] Geist (sans) for all UI, navigation, graph, dashboard
- [ ] Source Serif 4 (serif) for agent response text and transcript body only
- [ ] Geist Mono for prompts, YAML, expectations, code
- [ ] Serif appears ONLY in `.transcript` and `.agent-response` containers
- [ ] Transcript max-width: 72ch
- [ ] Turn spacing: 28px (not 16px)
- [ ] Agent response padding: 16px 20px
- [ ] All other components unchanged from Direction A
- [ ] Agent highlight uses italic + accent border-left
- [ ] Dark mode only
- [ ] Accessible contrast: serif text on dark bg meets AA (Source Serif 4 at 16px, #EDEDF0 on #141418 = 13.3:1)

---

*Derived from: minimal-tech.md + editorial.md*
