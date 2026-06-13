# User Stories: Settings & Accessibility

## US-SET-001
**As** Bob (self-learner),  
**I want** my preferred voice and speed to be set once and remembered forever,  
**so that** I never have to configure them again.

**Acceptance Criteria:**
- Global defaults for: voice, speed, highlight color
- Per-document overrides possible (stored with document)
- Settings accessible in ≤2 clicks from any screen

---

## US-SET-002
**As** Maya (researcher),  
**I want to** configure which LLM backend handles Q&A (local QWEN vs OpenAI GPT-4o),  
**so that** I can balance privacy and quality based on the document's sensitivity.

**Acceptance Criteria:**
- Settings: LLM provider (Local / OpenAI / Anthropic), model selection per provider
- Per-document override: "Always use local LLM for this document"
- Cloud LLM calls shown with a visual indicator so user knows when data leaves device

---

## US-SET-003
**As** James (accessibility user),  
**I want** the entire app navigable by keyboard with logical tab order and visible focus rings,  
**so that** I can use it without a mouse.

**Acceptance Criteria:**
- Tab order: Library → Reader → Controls → Side panel → Back
- All interactive elements reachable by keyboard
- Focus ring clearly visible (3px, high contrast, not hidden by system preferences)
- Keyboard shortcut reference accessible via ? key

---

## US-SET-004
**As** James,  
**I want** all app state changes announced to VoiceOver,  
**so that** I know when playback starts, pauses, a chapter changes, or Q&A answers arrive.

**Acceptance Criteria:**
- Live region announcements for: playback state change, chapter advance, Q&A answer available
- Custom VoiceOver labels for all UI elements
- Tested with VoiceOver on macOS Sonoma

---

## US-SET-005
**As** Bob,  
**I want to** increase the font size of the in-app text display,  
**so that** I can read the highlighted text comfortably on my large monitor.

**Acceptance Criteria:**
- Font size slider: 12pt – 32pt
- Change applies immediately without page reload
- Size remembered per document and globally

---

## US-SET-006
**As** all users,  
**I want to** see a clear indicator of mic status (active/inactive),  
**so that** I always know when the app is listening.

**Acceptance Criteria:**
- Persistent, always-visible mic status indicator (not just a modal)
- Visual + optional audio cue when mic activates
- One-click to disable mic entirely from main UI
- Mic permission revocation in macOS Privacy respected immediately

---

## US-SET-007
**As** Maya,  
**I want to** configure where the app stores its document index,  
**so that** I can point it to an external drive or a cloud-synced folder.

**Acceptance Criteria:**
- Storage location picker in settings (defaults to `~/Library/Application Support/iPDF/`)
- Moving storage location migrates all existing indexes
- Warning if selected location is cloud-synced (performance implication)
