# Component Library Index

Extracted from the 42 screen files in `project-management/screens/` by identifying UI elements that repeat across screens, share complex interaction patterns, or carry meaningful size/state variants — per Phase 3 of the extraction methodology. Several components are direct 1:1 counterparts of real source files (`TagChips.tsx`, `Pagination.tsx`, `ConfirmDialog.tsx`, `InputModal.tsx`, `StatusLine.tsx`, `StepIndicator.tsx`, `MessageBlock.tsx` under `packages/cli/src/interactive/components/`); most others are design-level patterns implied by `design/SITEMAP.md`'s component trees and confirmed against the actual page implementations, since the web app itself does not extract most of these into standalone React components (`packages/web/src/components/` currently holds only `Layout.tsx` and `MarkdownView.tsx`).

**Total: 40 components**

## By Category

| Category | Count | Components |
|----------|-------|-------------|
| Input & Forms | 5 | CMP-01 Search Bar, CMP-02 Filter Bar, CMP-03 Tag Chips, CMP-24 Save Bar, CMP-31 Provider Config Panel |
| Data Display | 5 | CMP-04 Stat Row, CMP-06 Search Result Row, CMP-11 Quality Label Badge, CMP-12 Source Badge, CMP-29 Output Preview |
| Cards & Tiles | 3 | CMP-05 Conversation List Item, CMP-07 Project Sidebar/Card, CMP-09 Dataset Card |
| Navigation & Layout | 7 | CMP-08 Group Header, CMP-13 Thread Header, CMP-14 Action Bar, CMP-21 Edit Toolbar, CMP-25 Step Wizard, CMP-32 Command Palette, CMP-37 Pagination |
| Feedback & Indicators | 4 | CMP-10 Quality Bar, CMP-33 Index Status, CMP-34 Empty State, CMP-39 Status Line |
| AI-Specific | 5 | CMP-17 Message Block, CMP-18 Thinking Block, CMP-19 Tool Use/Result Block, CMP-23 Simplify Panel, CMP-26 Candidate Panel |
| Modals & Overlays | 4 | CMP-22 Inject Panel, CMP-35 Confirm Dialog, CMP-36 Input Modal/Inline Edit, CMP-40 Help Overlay |
| Tables & Lists | 3 | CMP-20 Diff View, CMP-30 Dataset Entry Preview, CMP-38 Selectable List |
| Domain-Specific | 4 | CMP-15 Thread Timeline, CMP-16 Version Timeline, CMP-27 Compare View, CMP-28 Assembly Zone |

## Full Index

| ID | Name | Surfaces | Used In (count) | Category |
|----|------|----------|------------------|----------|
| CMP-01 | Search Bar | web, cli-ink | 2 | Input & Forms |
| CMP-02 | Filter Bar | web, cli-ink | 4 | Input & Forms |
| CMP-03 | Tag Chips | web, cli-ink | 9 | Input & Forms |
| CMP-04 | Stat Row / Stat Card | web | 2 | Data Display |
| CMP-05 | Conversation List Item | web, cli-ink | 6 | Cards & Tiles |
| CMP-06 | Search Result Row | web, cli-ink, cli-command | 3 | Data Display |
| CMP-07 | Project Sidebar / Card | web, cli-ink | 4 | Cards & Tiles |
| CMP-08 | Group Header | web, cli-ink | 2 | Navigation & Layout |
| CMP-09 | Dataset Card | web, cli-ink | 2 | Cards & Tiles |
| CMP-10 | Quality Bar | web, cli-ink | 4 | Feedback & Indicators |
| CMP-11 | Quality Label Badge / Selector | web, cli-ink | 2 | Data Display |
| CMP-12 | Source Badge | web, cli-ink | 4 | Data Display |
| CMP-13 | Thread Header | web, cli-ink | 2 | Navigation & Layout |
| CMP-14 | Action Bar | web, cli-ink | 2 | Navigation & Layout |
| CMP-15 | Thread Timeline | web | 1 | Domain-Specific |
| CMP-16 | Version Timeline | web | 1 | Domain-Specific |
| CMP-17 | Message Block | web, cli-ink | 6 | AI-Specific |
| CMP-18 | Thinking Block | web, cli-ink | 2 | AI-Specific |
| CMP-19 | Tool Use / Result Block | web, cli-ink | 3 | AI-Specific |
| CMP-20 | Diff View | web | 1 | Tables & Lists |
| CMP-21 | Edit Toolbar | web, cli-ink | 2 | Navigation & Layout |
| CMP-22 | Inject Panel | web, cli-ink | 2 | Modals & Overlays |
| CMP-23 | Simplify Panel | web, cli-ink | 2 | AI-Specific |
| CMP-24 | Save Bar | web, cli-ink | 2 | Input & Forms |
| CMP-25 | Step Wizard / Indicator | web, cli-ink | 2 | Navigation & Layout |
| CMP-26 | Candidate Panel | web, cli-ink | 2 | AI-Specific |
| CMP-27 | Compare View / Thread Panel | web | 1 | Domain-Specific |
| CMP-28 | Assembly Zone / Merged Section | web | 1 | Domain-Specific |
| CMP-29 | Output Preview | web, cli-ink | 3 | Data Display |
| CMP-30 | Dataset Entry Preview | web, cli-ink | 2 | Tables & Lists |
| CMP-31 | Provider Config Panel | web, cli-ink | 2 | Input & Forms |
| CMP-32 | Command Palette | web | 1 | Navigation & Layout |
| CMP-33 | Index Status Indicator | web, cli-ink | 4 | Feedback & Indicators |
| CMP-34 | Empty State | web, cli-ink | 10 | Feedback & Indicators |
| CMP-35 | Confirm Dialog | web, cli-ink, tui-ratatui | 9 | Modals & Overlays |
| CMP-36 | Input Modal / Inline Edit | web, cli-ink, tui-ratatui | 8 | Modals & Overlays |
| CMP-37 | Pagination | web, cli-ink | 4 | Navigation & Layout |
| CMP-38 | Selectable List | cli-ink, tui-ratatui | 12 | Tables & Lists |
| CMP-39 | Status Line / Key Legend | cli-ink, tui-ratatui | 16 | Feedback & Indicators |
| CMP-40 | Help Overlay | tui-ratatui | 3 | Modals & Overlays |

## Notes

- Eight components (CMP-15, 16, 20, 27, 28, 32) appear on only one screen; each is included anyway because it carries a complex, multi-part interaction pattern (drag-and-drop assembly, side-by-side diffing, global overlay routing) per the extraction methodology's "complex interaction patterns" inclusion criterion, not the "2+ screens" one.
- CMP-38 (Selectable List) and CMP-39 (Status Line) are the two highest-reuse components in the library — they're the terminal-surface foundation nearly every `cli-ink` and `tui-ratatui` screen builds on, standing in for the visible buttons/menus that don't exist in a terminal UI.
- CMP-35 (Confirm Dialog) and CMP-36 (Input Modal) are the only components documented across all three interactive surfaces (web, cli-ink, tui-ratatui) — the same gate-before-destructive-action and focused-input-capture patterns recur identically in the React app, the Ink TUI, and skill-manage's ratatui TUI.

See `project-management/components/index.yaml` for the machine-readable index (id, category, surfaces, used-in screens, file).
