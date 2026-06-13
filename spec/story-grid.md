# Story-to-View Mapping Grid

## Legend & Usage Guide

### How to Use This Grid

1. **Rows** = User Stories grouped by category (stage)
2. **Columns** = Mockup Views (View-0 through View-19)
3. **Cells** = Checkbox markers:
   - `[ ]` = Not yet mapped (empty)
   - `[x]` = Story touches this view
   - `[p]` = Partial touch (minor interaction)

### Stage Categories

| Stage | Category | Description |
|-------|----------|-------------|
| 0 | MVP | Hello World - Global hotkey |
| 1 | Display | Popup display current clipboard |
| 2 | History | Basic history navigation |
| 3 | Persistence | History persistence & configuration |
| 4 | Search | Search functionality |
| 5 | Types | Content type detection & metadata |
| 6 | Config | Configuration & sync foundation |
| 7 | Sync | Encrypted sync |
| -1 | Performance | Performance & reliability |
| -2 | Security | Security & privacy |
| -3 | Accessibility | Accessibility support |
| -4 | Localization | i18n/l10n |
| -5 | Edge Cases | Error handling & recovery |
| -6 | Developer (orig) | CLI & developer tools |
| -7 | Onboarding | Welcome & learning |
| -8 | Favorites | Favorites & quick actions |
| -9 | Foundation | Architecture & testing |
| -10 | AI/ML | AI/ML & LLM Snippets |
| -11 | Analytics | Usage statistics |
| -12 | Sync Protocol | Sync API specification |
| -13 | Macros | Macro system |
| -14 | Keyboard Chords | Keyboard navigation |
| -15 | Paste Formats | Format conversion |
| -16 | Image Support | Image handling |
| -17 | Menu Bar & Prefs | Menu bar & preferences |
| -18 | Developer Features | Integrations & exports |
| -19 | Additional Features | Extra features |

### View Columns (Placeholder Names)

| View | Suggested Name | Description |
|------|----------------|-------------|
| View-0 | Main Popup | Primary clipboard history popup |
| View-1 | Search Panel | Search interface within popup |
| View-2 | Settings/Preferences | Settings window |
| View-3 | Menu Bar Dropdown | Menu bar icon dropdown |
| View-4 | Sync Status | Sync indicator & status |
| View-5 | Onboarding | Welcome wizard |
| View-6 | Macro Editor | Macro creation/editing |
| View-7 | Macro Quick-Insert | Macro selection bar |
| View-8 | Macro Variable Form | Variable input form |
| View-9 | LLM Snippet Library | LLM snippet browser |
| View-10 | LLM Snippet Editor | Snippet creation/editing |
| View-11 | LLM Invocation Form | Snippet input form |
| View-12 | Image Preview | Full-size image preview |
| View-13 | Image Editor | Image annotation editor |
| View-14 | Format Picker | Paste format selection |
| View-15 | Tag Editor | Tag management |
| View-16 | Entry Detail | Entry detail/timeline view |
| View-17 | Usage Stats Dashboard | Analytics dashboard |
| View-18 | Eval Dashboard | LLM eval dashboard |
| View-19 | Misc/Other | Catch-all for other views |

---

## Story Index by Category

### Stage 0: MVP (Hello World)

| Story ID | Title |
|----------|-------|
| US-001 | Global Hotkey Activation |

### Stage 1: Display

| Story ID | Title |
|----------|-------|
| US-002 | Popup Display Current Clipboard |
| US-003 | Dismiss Popup with Escape Key |

### Stage 2: History

| Story ID | Title |
|----------|-------|
| US-004 | View Clipboard History |
| US-005 | Navigate History with Arrow Keys |
| US-006 | Paste Selected History Item |

### Stage 3: Persistence

| Story ID | Title |
|----------|-------|
| US-007 | Click to Paste with Mouse |
| US-008 | Clipboard History Persistence |
| US-009 | Configure Maximum History Size |
| US-010 | Manually Clear History |

### Stage 4: Search

| Story ID | Title |
|----------|-------|
| US-011 | Search Clipboard History |
| US-012 | Case-Insensitive Search |
| US-013 | Search Match Highlighting |

### Stage 5: Types

| Story ID | Title |
|----------|-------|
| US-014 | Detect and Display Content Type |
| US-015 | Display Copy Timestamps |
| US-016 | Filter History by Content Type |
| US-017 | Delete Single History Item |

### Stage 6: Config

| Story ID | Title |
|----------|-------|
| US-018 | Configuration UI for settings |
| US-019 | Hotkey customization |
| US-020 | Auto-start on login |
| US-021 | Exclude specific applications from clipboard monitoring |
| US-022 | Sync target configuration |

### Stage 7: Sync

| Story ID | Title |
|----------|-------|
| US-023 | Display sync status in UI |
| US-024 | Manual sync trigger |
| US-025 | Encryption key setup and management |
| US-026 | Client-side encryption for sync data |
| US-027 | Conflict resolution when devices have divergent history |
| US-028 | Sync activity log |

### Stage -1: Performance

| Story ID | Title |
|----------|-------|
| US-029 | Background daemon startup reliability |
| US-030 | Clipboard change monitoring without excessive polling |
| US-031 | Handle large clipboard content (>10MB) |
| US-032 | Memory management for long-running process |
| US-033 | Popup appears within 50ms of hotkey press |

### Stage -2: Security

| Story ID | Title |
|----------|-------|
| US-034 | Privacy mode (disable history temporarily) |
| US-035 | Password protection for app access |
| US-036 | Export clipboard history as JSON |
| US-037 | Import clipboard history from JSON |
| US-038 | Encrypted local storage |
| US-039 | Secure deletion of sensitive items |
| US-040 | Log clipboard access by other applications |
| US-041 | Audit log of all clipboard changes |
| US-042 | PIN or biometric unlock for popup |

### Stage -3: Accessibility

| Story ID | Title |
|----------|-------|
| US-043 | VoiceOver support for popup menu |
| US-044 | Dynamic type sizing support |
| US-045 | High contrast mode support |
| US-046 | Reduced motion animation option |

### Stage -4: Localization

| Story ID | Title |
|----------|-------|
| US-047 | English language support (base) |
| US-048 | Detect and use system language |
| US-049 | RTL (Right-to-Left) language support for Arabic/Hebrew |

### Stage -5: Edge Cases

| Story ID | Title |
|----------|-------|
| US-050 | Recovery from empty or corrupted database |
| US-051 | Recovery from corrupted history file |
| US-052 | Graceful handling of sync network outages |
| US-053 | Insufficient disk space handling |
| US-054 | Prevent multiple app instances from running |
| US-055 | Graceful crash recovery on restart |

### Stage -6: Developer (original)

| Story ID | Title |
|----------|-------|
| US-056 | CLI interface for clipboard operations |

### Stage -7: Onboarding

| Story ID | Title |
|----------|-------|
| US-057 | Welcome Wizard and Feature Discovery |
| US-058 | Keyboard Shortcut Cheat Sheet and Learning Aids |

### Stage -8: Favorites

| Story ID | Title |
|----------|-------|
| US-059 | Favorites and Pinned Items Management |
| US-060 | Quick Actions for Specific Content Types |

### Stage -9: Foundation

| Story ID | Title |
|----------|-------|
| US-061 | System Architecture Definition |
| US-062 | Database Schema and Migration Framework |
| US-063 | Configuration System |
| US-064 | Automated Testing Framework Setup |
| US-065 | Performance Benchmarking and SLA Definition |

### Stage -10: AI/ML & LLM Snippets

| Story ID | Title |
|----------|-------|
| US-066 | Intelligent Content Categorization |
| US-067 | Smart Duplicate Detection |
| US-068 | Semantic Search with Natural Language |
| US-069 | Context-Aware Suggestions |
| US-087 | Create LLM Snippet |
| US-088 | LLM Snippet Library Panel |
| US-089 | Invoke LLM Snippet |
| US-090 | Rate LLM Snippet Output |
| US-091 | LLM Snippet Version History |
| US-092 | LLM Snippet Invocation History |
| US-093 | LLM Snippet Eval Framework |
| US-094 | Regression Alerts for LLM Snippets |
| US-095 | LLM Snippet Eval Dashboard |
| US-096 | LLM Snippet Tags and Organization |
| US-097 | LLM Snippet Output Editing |
| US-098 | LLM Provider Configuration |
| US-099 | LLM Snippet Import and Export |

### Stage -11: Analytics

| Story ID | Title |
|----------|-------|
| US-070 | Usage Statistics Dashboard |

### Stage -12: Sync Protocol

| Story ID | Title |
|----------|-------|
| US-071 | Sync Protocol and API Specification |

### Stage -13: Macros

| Story ID | Title |
|----------|-------|
| US-072 | Macroize Clipboard Entry |
| US-073 | Macro Variable Types |
| US-074 | Macro Quick Insert Bar |
| US-075 | Macro Variable Form with Live Preview |
| US-076 | Wrapper Variable Auto-Fill from Selection |
| US-077 | LLM-Assisted Macro Variable Fill |
| US-078 | LLM Transform Variable Pipeline |
| US-079 | Macro Generated Output Nesting |
| US-080 | Promote Nested Output to Clipboard History |
| US-081 | Macro Usage Tracking and Statistics |
| US-082 | Macro Variants |
| US-083 | Edit Existing Macro |
| US-084 | Delete Macro |
| US-085 | Macro Export and Import |
| US-086 | Macro Templates and Example Library |

### Stage -14: Keyboard Chords

| Story ID | Title |
|----------|-------|
| US-100 | Focus Search Bar with Hotkey |
| US-101 | Quick-Paste from Suggested Shortlist |
| US-102 | Macroize Entry In-Panel (M Key) |
| US-103 | Tag Entry In-Panel (T Key) |
| US-104 | Inline Edit Entry (E Key) |
| US-105 | Add/Edit Description (D Key) |
| US-106 | Keyboard-Only Navigation |
| US-107 | Chord Navigation State Machine |

### Stage -15: Paste Formats

| Story ID | Title |
|----------|-------|
| US-108 | Paste Format Options |
| US-109 | Option Key Strip Formatting |
| US-110 | Long Press Format Picker |
| US-111 | HTML to Markdown Conversion |
| US-112 | RTF to Markdown Conversion |
| US-113 | Color Value Conversion |
| US-114 | Custom Regex Transform |
| US-115 | Custom LLM Transform |
| US-116 | Color Palette Favoriting |
| US-117 | Paste as Code Block with Language Detection |
| US-118 | Default Paste Format Preference |

### Stage -16: Image Support

| Story ID | Title |
|----------|-------|
| US-119 | Image Type Support |
| US-120 | Image Thumbnail Generation |
| US-121 | Image Full-Size Preview |
| US-122 | Image Metadata Storage |
| US-123 | OCR Text Extraction from Images |
| US-124 | Image Vector Embeddings |
| US-125 | Text-to-Image Generation Macro |
| US-126 | Image-to-Image Transformation |
| US-127 | Image Edit and Annotate |
| US-128 | Image Size Limit and Compression |

### Stage -17: Menu Bar & Prefs

| Story ID | Title |
|----------|-------|
| US-129 | Menu Bar Dropdown |
| US-130 | Menu Bar Sync Status |
| US-131 | Preferences - General Tab |
| US-132 | Preferences - Keyboard Tab |
| US-133 | Preferences - Search Tab |
| US-134 | Preferences - LLM Tab |
| US-135 | Preferences - Sync Tab |
| US-136 | Preferences - Privacy Tab |
| US-137 | Preferences - Appearance Tab |
| US-138 | Source Document URL Detection |
| US-139 | Copy Method Tracking |
| US-140 | Target App Tracking on Paste |
| US-141 | Usage Count Badge |
| US-142 | Per-Entry Usage Timeline |
| US-143 | Menu Bar Analytics Summary |

### Stage -18: Developer Features

| Story ID | Title |
|----------|-------|
| US-144 | CLI Tool - clipstash |
| US-145 | Alfred/Raycast Integration |
| US-146 | Shortcuts.app Integration |
| US-147 | AppleScript/JXA Dictionary |
| US-148 | Webhook Support |
| US-149 | Import from Other Clipboard Managers |
| US-150 | Export Formats (CSV, JSON, Archive) |
| US-151 | Scheduled Backups |

### Stage -19: Additional Features

| Story ID | Title |
|----------|-------|
| US-152 | Clipboard Chains |
| US-153 | Expiring Entries |
| US-154 | URL Preview Card |
| US-155 | Multi-Select Paste |
| US-156 | VoiceOver Accessibility Support |
| US-157 | High Contrast Mode |
| US-158 | Reduced Motion and Animation Control |

---

## Story Grid

### Stage 0: MVP (Hello World)

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-001 | Global Hotkey Activation | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage 1: Display

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-002 | Popup Display Current Clipboard | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-003 | Dismiss Popup with Escape Key | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage 2: History

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-004 | View Clipboard History | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-005 | Navigate History with Arrow Keys | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-006 | Paste Selected History Item | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage 3: Persistence

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-007 | Click to Paste with Mouse | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-008 | Clipboard History Persistence | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-009 | Configure Maximum History Size | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-010 | Manually Clear History | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage 4: Search

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-011 | Search Clipboard History | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-012 | Case-Insensitive Search | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-013 | Search Match Highlighting | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage 5: Types

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-014 | Detect and Display Content Type | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-015 | Display Copy Timestamps | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-016 | Filter History by Content Type | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-017 | Delete Single History Item | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage 6: Config

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-018 | Configuration UI for settings | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-019 | Hotkey customization | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-020 | Auto-start on login | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-021 | Exclude specific applications from clipboard monitoring | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-022 | Sync target configuration | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage 7: Sync

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-023 | Display sync status in UI | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-024 | Manual sync trigger | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-025 | Encryption key setup and management | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-026 | Client-side encryption for sync data | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-027 | Conflict resolution when devices have divergent history | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-028 | Sync activity log | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -1: Performance

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-029 | Background daemon startup reliability | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-030 | Clipboard change monitoring without excessive polling | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-031 | Handle large clipboard content (>10MB) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-032 | Memory management for long-running process | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-033 | Popup appears within 50ms of hotkey press | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -2: Security

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-034 | Privacy mode (disable history temporarily) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-035 | Password protection for app access | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-036 | Export clipboard history as JSON | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-037 | Import clipboard history from JSON | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-038 | Encrypted local storage | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-039 | Secure deletion of sensitive items | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-040 | Log clipboard access by other applications | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-041 | Audit log of all clipboard changes | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-042 | PIN or biometric unlock for popup | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -3: Accessibility

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-043 | VoiceOver support for popup menu | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-044 | Dynamic type sizing support | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-045 | High contrast mode support | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-046 | Reduced motion animation option | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -4: Localization

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-047 | English language support (base) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-048 | Detect and use system language | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-049 | RTL (Right-to-Left) language support for Arabic/Hebrew | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -5: Edge Cases

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-050 | Recovery from empty or corrupted database | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-051 | Recovery from corrupted history file | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-052 | Graceful handling of sync network outages | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-053 | Insufficient disk space handling | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-054 | Prevent multiple app instances from running | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-055 | Graceful crash recovery on restart | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -6: Developer (original)

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-056 | CLI interface for clipboard operations | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -7: Onboarding

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-057 | Welcome Wizard and Feature Discovery | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-058 | Keyboard Shortcut Cheat Sheet and Learning Aids | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -8: Favorites

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-059 | Favorites and Pinned Items Management | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-060 | Quick Actions for Specific Content Types | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -9: Foundation

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-061 | System Architecture Definition | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-062 | Database Schema and Migration Framework | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-063 | Configuration System | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-064 | Automated Testing Framework Setup | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-065 | Performance Benchmarking and SLA Definition | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -10: AI/ML & LLM Snippets

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-066 | Intelligent Content Categorization | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-067 | Smart Duplicate Detection | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-068 | Semantic Search with Natural Language | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-069 | Context-Aware Suggestions | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-087 | Create LLM Snippet | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-088 | LLM Snippet Library Panel | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-089 | Invoke LLM Snippet | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-090 | Rate LLM Snippet Output | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-091 | LLM Snippet Version History | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-092 | LLM Snippet Invocation History | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-093 | LLM Snippet Eval Framework | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-094 | Regression Alerts for LLM Snippets | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-095 | LLM Snippet Eval Dashboard | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-096 | LLM Snippet Tags and Organization | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-097 | LLM Snippet Output Editing | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-098 | LLM Provider Configuration | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-099 | LLM Snippet Import and Export | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -11: Analytics

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-070 | Usage Statistics Dashboard | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -12: Sync Protocol

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-071 | Sync Protocol and API Specification | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -13: Macros

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-072 | Macroize Clipboard Entry | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-073 | Macro Variable Types | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-074 | Macro Quick Insert Bar | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-075 | Macro Variable Form with Live Preview | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-076 | Wrapper Variable Auto-Fill from Selection | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-077 | LLM-Assisted Macro Variable Fill | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-078 | LLM Transform Variable Pipeline | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-079 | Macro Generated Output Nesting | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-080 | Promote Nested Output to Clipboard History | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-081 | Macro Usage Tracking and Statistics | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-082 | Macro Variants | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-083 | Edit Existing Macro | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-084 | Delete Macro | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-085 | Macro Export and Import | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-086 | Macro Templates and Example Library | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -14: Keyboard Chords

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-100 | Focus Search Bar with Hotkey | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-101 | Quick-Paste from Suggested Shortlist | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-102 | Macroize Entry In-Panel (M Key) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-103 | Tag Entry In-Panel (T Key) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-104 | Inline Edit Entry (E Key) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-105 | Add/Edit Description (D Key) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-106 | Keyboard-Only Navigation | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-107 | Chord Navigation State Machine | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -15: Paste Formats

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-108 | Paste Format Options | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-109 | Option Key Strip Formatting | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-110 | Long Press Format Picker | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-111 | HTML to Markdown Conversion | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-112 | RTF to Markdown Conversion | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-113 | Color Value Conversion | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-114 | Custom Regex Transform | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-115 | Custom LLM Transform | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-116 | Color Palette Favoriting | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-117 | Paste as Code Block with Language Detection | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-118 | Default Paste Format Preference | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -16: Image Support

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-119 | Image Type Support | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-120 | Image Thumbnail Generation | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-121 | Image Full-Size Preview | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-122 | Image Metadata Storage | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-123 | OCR Text Extraction from Images | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-124 | Image Vector Embeddings | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-125 | Text-to-Image Generation Macro | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-126 | Image-to-Image Transformation | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-127 | Image Edit and Annotate | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-128 | Image Size Limit and Compression | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -17: Menu Bar & Prefs

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-129 | Menu Bar Dropdown | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-130 | Menu Bar Sync Status | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-131 | Preferences - General Tab | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-132 | Preferences - Keyboard Tab | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-133 | Preferences - Search Tab | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-134 | Preferences - LLM Tab | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-135 | Preferences - Sync Tab | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-136 | Preferences - Privacy Tab | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-137 | Preferences - Appearance Tab | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-138 | Source Document URL Detection | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-139 | Copy Method Tracking | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-140 | Target App Tracking on Paste | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-141 | Usage Count Badge | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-142 | Per-Entry Usage Timeline | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-143 | Menu Bar Analytics Summary | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -18: Developer Features

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-144 | CLI Tool - clipstash | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-145 | Alfred/Raycast Integration | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-146 | Shortcuts.app Integration | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-147 | AppleScript/JXA Dictionary | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-148 | Webhook Support | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-149 | Import from Other Clipboard Managers | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-150 | Export Formats (CSV, JSON, Archive) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-151 | Scheduled Backups | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Stage -19: Additional Features

| Story ID | Title | View-0 | View-1 | View-2 | View-3 | View-4 | View-5 | View-6 | View-7 | View-8 | View-9 | View-10 | View-11 | View-12 | View-13 | View-14 | View-15 | View-16 | View-17 | View-18 | View-19 |
|----------|-------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| US-152 | Clipboard Chains | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-153 | Expiring Entries | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-154 | URL Preview Card | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-155 | Multi-Select Paste | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-156 | VoiceOver Accessibility Support | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-157 | High Contrast Mode | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| US-158 | Reduced Motion and Animation Control | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Total Stories | 158 |
| Total Views | 20 |
| Stage 0-7 (Core) | 28 |
| Stage -1 to -19 (Extended) | 130 |

---

## Next Steps

1. Define the actual mockup views (View-0 through View-19)
2. Mark cells where stories touch each view
3. Use this grid to ensure all stories are covered by at least one view
4. Identify stories that span multiple views for integration testing

<!-- nav -->

---

[Table of Contents](../product-spec.md)

<!-- nav -->
