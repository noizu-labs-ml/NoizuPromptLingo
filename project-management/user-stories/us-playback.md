# User Stories: TTS Playback & Highlighting

## US-PLY-001
**As** Bob (self-learner),  
**I want** the sentence currently being read highlighted on the page,  
**so that** I can follow along visually even when distracted.

**Acceptance Criteria:**
- Highlight moves sentence-by-sentence in sync with audio
- Highlight color configurable; default is accessible yellow
- Page auto-scrolls to keep highlighted sentence visible

---

## US-PLY-002
**As** Bob,  
**I want to** adjust TTS reading speed from 0.5x to 3x,  
**so that** I can match the pace to my current attention level.

**Acceptance Criteria:**
- Speed slider accessible from playback controls
- Speed change takes effect within the current sentence (not next paragraph)
- Pitch does not change with speed adjustment

---

## US-PLY-003
**As** Yuki (language learner),  
**I want to** choose from multiple TTS voices,  
**so that** I can pick a voice that aids my English comprehension.

**Acceptance Criteria:**
- Minimum 4 voices available (2 male, 2 female, ideally including non-US accents)
- Voice preview before applying
- Voice selection persists per document or globally (user configurable)

---

## US-PLY-004
**As** James (accessibility user),  
**I want** playback to continue when the app is in the background,  
**so that** I can listen while using other applications.

**Acceptance Criteria:**
- Audio continues when app loses focus
- macOS media key controls (play/pause/skip) work globally
- Now Playing widget appears in menu bar / Control Center

---

## US-PLY-005
**As** Bob,  
**I want to** pause and resume with a keyboard shortcut,  
**so that** I don't have to click the UI during a listening session.

**Acceptance Criteria:**
- Spacebar or configurable hotkey pauses/resumes
- Global hotkey option (works even when app is not focused)
- Shortcut shown in tooltip on playback button

---

## US-PLY-006
**As** Maya (researcher),  
**I want to** bookmark the current position with a label,  
**so that** I can return to important passages later.

**Acceptance Criteria:**
- "Bookmark here" command creates a named bookmark at current sentence
- Bookmarks listed in side panel with labels and page numbers
- Click a bookmark to jump to that position and resume from there

---

## US-PLY-007
**As** Bob,  
**I want** the app to automatically resume from where I stopped last time,  
**so that** I never have to find my place manually.

**Acceptance Criteria:**
- Position saved on pause, on close, and every 30 seconds during playback
- On reopen: "Resume from page X, paragraph Y?" prompt with one-click confirm
- Option to start from beginning if desired

---

## US-PLY-008
**As** Alex (tech reviewer),  
**I want to** play at 1.5x–2x speed through familiar sections,  
**so that** I can skim sections I've read before without stopping the audio workflow.

**Acceptance Criteria:**
- Speed adjustable mid-playback without pause
- Chapter/section change does not reset speed
- Speed indicator always visible in playback controls

---

## US-PLY-009
**As** James,  
**I want to** set a sleep timer,  
**so that** playback stops automatically after my specified duration and I don't lose my place.

**Acceptance Criteria:**
- Sleep timer options: 15m, 30m, 45m, 60m, end of chapter, custom
- Countdown visible in menu bar or controls
- Position is saved when sleep timer fires
- "Extend 15 minutes" option when timer is about to expire
