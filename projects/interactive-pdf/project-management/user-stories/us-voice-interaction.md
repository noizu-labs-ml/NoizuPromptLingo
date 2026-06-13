# User Stories: Voice Commands & Navigation

## US-VOI-001
**As** Bob (self-learner),  
**I want to** say "pause" or "stop" and have playback stop immediately,  
**so that** I can interrupt without reaching for the keyboard.

**Acceptance Criteria:**
- Voice commands recognized within 1 second of utterance end
- Pause/play/stop work reliably across all system noise levels
- No wake word required in push-to-talk mode; optional always-listening mode

---

## US-VOI-002
**As** Bob,  
**I want to** say "go back" or "replay that" and hear the last 1–3 sentences repeated,  
**so that** I can catch things I missed.

**Acceptance Criteria:**
- "Go back" replays the previous sentence by default
- "Go back two sentences" / "go back a paragraph" also works
- Playback resumes forward after replay automatically

---

## US-VOI-003
**As** Sarah (lawyer),  
**I want to** say "jump to Section 9" or "go to the definitions section",  
**so that** I can navigate without stopping what I'm doing.

**Acceptance Criteria:**
- Navigate by section number: "Section 4.2", "Chapter 3"
- Navigate by section name: "go to the indemnification clause"
- App confirms the jump with a spoken acknowledgment ("Jumping to Section 9.2, page 47")

---

## US-VOI-004
**As** James (accessibility user),  
**I want** voice commands to work without push-to-talk (always-listening mode),  
**so that** I never need to touch any input device.

**Acceptance Criteria:**
- Always-listening mode available as a toggle in settings
- Wake word optional (e.g., "Hey Reader") to prevent accidental activations
- Visual indicator shows when mic is active (for users who can see it)
- Privacy: mic data never leaves device; uses Apple Speech Recognition

---

## US-VOI-005
**As** Maya (researcher),  
**I want to** say "summarize this section",  
**so that** I get an AI overview of the current section without reading it in full.

**Acceptance Criteria:**
- App identifies current section from position
- Summary spoken aloud and shown as text in side panel
- Summary sources from the pre-generated section summary, not a live LLM call (fast)

---

## US-VOI-006
**As** Bob,  
**I want to** say "next chapter" or "previous chapter",  
**so that** I can skip around at a coarse level by voice.

**Acceptance Criteria:**
- Chapter/section boundary detection used for navigation
- "Next chapter" jumps to the start of the next detected chapter
- Spoken confirmation: "Moving to Chapter 4: The Industrial Revolution"

---

## US-VOI-007
**As** Yuki (language learner),  
**I want to** say "explain that more simply" after a confusing passage,  
**so that** I get a plain-language restatement without switching apps.

**Acceptance Criteria:**
- App passes the most recently read paragraph to LLM with "explain simply" prompt
- Response spoken aloud and shown in chat panel
- After explanation, offers to continue playback from same position

---

## US-VOI-008
**As** Alex (tech reviewer),  
**I want to** say "find all mentions of [term]",  
**so that** I can quickly audit how a concept is used across the document.

**Acceptance Criteria:**
- Semantic + literal search triggered by voice
- Results listed in side panel with page numbers and context snippets
- "Jump to next mention" voice command cycles through results
