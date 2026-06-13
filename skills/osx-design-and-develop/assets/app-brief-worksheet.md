# macOS App Brief Worksheet

Fill in each section before beginning architecture or design work. Leave fields blank if unknown — blanks are better than guesses.

---

## 1. App Overview

| Field | Value |
|-------|-------|
| App name | |
| Tagline (one sentence) | |
| Core purpose | |
| Primary user persona | |
| Secondary user persona | |
| Problem being solved | |
| Existing alternatives | |
| Why this is better | |

---

## 2. Platform & Environment

| Field | Value |
|-------|-------|
| Minimum macOS version | |
| Target macOS version | |
| Apple Silicon native? (yes/no/universal) | |
| Also targets iOS/iPadOS? | |
| Mac Catalyst? | |
| Expected hardware (laptop / desktop / both) | |
| External display support needed? | |

---

## 3. App Type

Check all that apply:

- [ ] Single-window app
- [ ] Multi-window app
- [ ] Document-based app (each file = a window)
- [ ] Menu bar utility (no Dock icon)
- [ ] Menu bar + main window hybrid
- [ ] System extension / XPC service
- [ ] Background daemon / LaunchAgent

---

## 4. Window Topology

| Field | Value |
|-------|-------|
| Primary window layout | (e.g. NavigationSplitView, TabView, single view) |
| Sidebar? (yes/no) | |
| Inspector panel? (yes/no) | |
| Toolbar style | (unified / expanded / none) |
| Modal sheets needed | |
| Panels / floating windows needed | |
| Min window size (W × H) | |
| Resizable? (yes/no) | |
| Full-screen support? (yes/no) | |

---

## 5. Data & Backend

| Field | Value |
|-------|-------|
| Persistence model | (Core Data / SwiftData / files / UserDefaults / remote API / none) |
| File format(s) | |
| iCloud sync? | |
| Remote API? (URL if known) | |
| Authentication needed? | |
| Offline-first? | |
| Data migration strategy | |

---

## 6. Distribution Path

| Field | Value |
|-------|-------|
| Distribution channel | (Mac App Store / direct DMG / TestFlight / enterprise) |
| Sandboxed? (required for App Store) | |
| Hardened runtime required? | |
| Notarization required? | |
| Auto-update mechanism | (Sparkle / App Store / none) |
| Pricing model | (free / paid / freemium / subscription) |
| Target launch date | |

---

## 7. System Integrations

Check all required:

- [ ] NSPasteboard / clipboard
- [ ] Drag and drop (in / out / both)
- [ ] Services menu integration
- [ ] Share extension
- [ ] Quick Look plugin
- [ ] Spotlight / Core Spotlight indexing
- [ ] Notifications (local / push)
- [ ] Touch Bar (legacy)
- [ ] Accessibility / VoiceOver
- [ ] AppleScript / Automation
- [ ] Global keyboard shortcuts
- [ ] Launch at login
- [ ] File system access (beyond sandbox)
- [ ] Camera / microphone
- [ ] Location services
- [ ] Network access

---

## 8. Design Requirements

| Field | Value |
|-------|-------|
| Visual style | (system default / custom / dark-only / branded) |
| Color scheme | |
| Typography | |
| Icon style | |
| Existing brand assets? | |
| Accessibility target (WCAG level) | |
| Localization needed? Languages: | |
| Animation level | (none / subtle / rich) |
| Reference apps for style | |

---

## 9. Open Questions

List anything unresolved that will affect architecture decisions:

1.
2.
3.
4.
5.

---

## 10. Out of Scope (v1)

List features explicitly deferred to avoid scope creep:

1.
2.
3.
