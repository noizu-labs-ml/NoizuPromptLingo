# US-090: Keyboard Shortcut Customization

**As a** professional concept artist with muscle memory from other tools,
**I want to** remap keyboard shortcuts to match my existing workflow,
**So that** I don't have to retrain ingrained habits and can stay in a creative flow state.

## Personas
- **Primary:** P3 Lena Vasquez — speed is critical; conflicting shortcuts with Photoshop/Procreate habits cause errors under deadline
- **Also relevant:** P1 Maya Chen, P6 Alex Kirchner

## Acceptance Criteria
- [ ] Preferences > Keyboard Shortcuts lists all bindable actions with their current key assignment
- [ ] Clicking a shortcut field and pressing a key combination assigns it; conflicts are highlighted with a warning
- [ ] Conflicting system shortcuts (Cmd+Q, Cmd+H, etc.) are blocked with an explanatory message
- [ ] Shortcuts can be reset to defaults individually or globally via a "Reset All" button
- [ ] Custom shortcut map is saved to `~/Library/Application Support/TheRobotPaints/shortcuts.json`
- [ ] Shortcuts are effective immediately after assignment without requiring app restart

## Notes
macOS `NSMenuItem` key equivalents must be updated dynamically when shortcuts change; SwiftUI's `.keyboardShortcut` modifier may need to be bypassed in favor of `NSMenu` manipulation for runtime rebinding to work correctly.
