# US-082: Open/Load Saved Painting Files

**As a** traditional oil painter,
**I want to** open previously saved painting files,
**So that** I can resume teaching demos or continue multi-session paintings across days.

## Personas
- **Primary:** P2 David Okafor — teaches across sessions, needs reliable load to resume exact canvas state before recording
- **Also relevant:** P1 Maya Chen, P4 James Whitfield

## Acceptance Criteria
- [ ] Cmd+O presents a system file picker filtered to `.trp` files
- [ ] File > Open Recent shows the last 10 opened files
- [ ] Opening a file replaces the current canvas (with unsaved-changes warning if applicable)
- [ ] Load validates file version and shows a clear error if the file is corrupt or from an incompatible future version
- [ ] All layer data, physics simulation state, and canvas metadata are restored identically to the save point
- [ ] Canvas re-renders within 2 seconds for files up to 50 MB on Apple Silicon

## Notes
Load must reconstruct Metal buffers from serialized state; consider whether physics simulation resumes live or requires a warm-up frame to stabilize. File version migration path should be stubbed even if v1 is the only version.
