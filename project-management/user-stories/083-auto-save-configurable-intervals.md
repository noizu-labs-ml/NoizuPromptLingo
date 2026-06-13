# US-083: Auto-Save at Configurable Intervals

**As a** concept artist working in fast-paced sprints,
**I want to** have the app automatically save my work at configurable intervals,
**So that** a crash or accidental close never costs me more than a few minutes of work.

## Personas
- **Primary:** P3 Lena Vasquez — fast iteration pace means frequent unsaved state; auto-save prevents catastrophic loss
- **Also relevant:** P1 Maya Chen, P5 Suki Tanaka

## Acceptance Criteria
- [ ] Auto-save interval is configurable in Preferences (off, 1 min, 5 min, 10 min, 30 min); default is 5 min
- [ ] Auto-save writes to a separate `.trp.autosave` file alongside the main file, not overwriting it
- [ ] A subtle status bar indicator shows "Auto-saved at HH:MM" after each successful auto-save
- [ ] Auto-save does not interrupt painting — runs on a background thread and pauses if a brush stroke is in progress
- [ ] On app launch after a crash, if an autosave file exists newer than the main file, the user is prompted to restore it
- [ ] Autosave file is deleted after a successful manual save

## Notes
Auto-save should be disabled when no file path has been set (new unsaved canvas) unless a scratch autosave directory is configured. The crash-recovery prompt must appear before any new canvas state is initialized.
