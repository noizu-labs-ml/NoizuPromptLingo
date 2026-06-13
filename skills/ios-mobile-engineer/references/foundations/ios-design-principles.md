# iOS Design Principles for Web Designers

Apple's Human Interface Guidelines (HIG) distilled into what web designers need to know — and what they need to unlearn.

---

## The Fundamental Difference

**Web design** is about building from scratch. You choose your typography, your buttons, your navigation pattern, your form controls, your color system. Everything is custom.

**iOS design** is about working within a system. Apple provides components, patterns, and conventions that users already understand. The best iOS apps feel native — they extend the system rather than replace it.

This is the hardest shift for web designers: your job is not to make something that looks unique. Your job is to make something that feels *right*.

---

## The Three Pillars of Apple HIG

### 1. Clarity

- Text is legible at every size
- Icons are precise and understandable
- Adornments are subtle and purposeful
- Functionality motivates the design

### 2. Deference

- The UI helps people understand content, not compete with it
- Fluid motion, crisp interfaces, translucent materials
- The content is the interface — minimize chrome

### 3. Depth

- Visual layers and realistic motion create hierarchy
- Transitions explain changes in state
- Touch and discoverability enable exploration

---

## How iOS Design Differs from Web Design

### Platform Conventions

iOS users have built-in expectations from years of muscle memory. Violating them creates friction.

| Convention | What Users Expect | Web Equivalent |
|---|---|---|
| Back gesture | Swipe from left edge to go back | Browser back button |
| Pull to refresh | Pull down to reload content | No standard pattern |
| Tab bar | Primary navigation lives at the bottom | Top nav bar |
| Long press | Context menu on any tappable element | Right-click |
| Swipe actions | Swipe list rows to reveal actions (delete, archive) | No standard |
| Search bar | Pull down on lists to reveal search | Search icon in nav |

### Touch Targets

The minimum touch target on iOS is **44x44 points**. This is not optional — it's an accessibility requirement enforced by App Store review.

| Platform | Minimum Target | Typical |
|---|---|---|
| Web (desktop) | No standard | ~32px |
| Web (mobile) | 48x48px (Google rec) | Variable |
| iOS | 44x44pt | 44x44pt |

A "point" on iOS is 1pt = 1px on non-Retina, 2px on Retina, 3px on Super Retina. Design in points, not pixels.

### Safe Areas

iOS devices have the status bar, Dynamic Island / notch, and home indicator. Content must respect the **safe area**.

```
┌──────────────────────────┐
│      Status Bar          │  ← Safe area inset top
│  ┌──────────────────┐    │
│  │                  │    │
│  │  Your Content    │    │  ← Safe area
│  │                  │    │
│  └──────────────────┘    │
│      Home Indicator      │  ← Safe area inset bottom
└──────────────────────────┘
```

SwiftUI handles safe areas by default. Content won't underlap system UI unless you explicitly opt out with `.ignoresSafeArea()`.

Web equivalent: `env(safe-area-inset-top)` etc., but it's opt-in on web and opt-out on iOS.

---

## Typography

### SF Pro: The System Font

iOS uses **SF Pro** (sans-serif) and **SF Mono** (monospaced). You don't need to bundle fonts — they're available system-wide. Using the system font means your app automatically supports:

- **Dynamic Type** — user-controlled text size (accessibility requirement)
- **Font weight optimization** — the system picks optical sizes automatically
- **Locale-specific adjustments** — line height, character spacing

### Text Styles (Not Font Sizes)

Do not hardcode font sizes. Use **semantic text styles** that scale with Dynamic Type.

| Text Style | Default Size | Usage |
|---|---|---|
| `.largeTitle` | 34pt | Screen titles, hero text |
| `.title` | 28pt | Section headers |
| `.title2` | 22pt | Sub-section headers |
| `.title3` | 20pt | Group headers |
| `.headline` | 17pt (bold) | Emphasized body text |
| `.body` | 17pt | Primary content |
| `.callout` | 16pt | Secondary content with emphasis |
| `.subheadline` | 15pt | Secondary labels |
| `.footnote` | 13pt | Tertiary content |
| `.caption` | 12pt | Timestamps, metadata |
| `.caption2` | 11pt | Fine print |

```swift
Text("Welcome Back")
    .font(.largeTitle)      // Scales with Dynamic Type
    .fontWeight(.bold)

Text("Your latest updates")
    .font(.subheadline)
    .foregroundStyle(.secondary)
```

### Dynamic Type Compliance

If a user sets their system text size to "Extra Extra Large," your app must honor it. This is a requirement, not a suggestion. SwiftUI handles this automatically when you use text styles instead of fixed sizes.

**Web brain:** "I set `font-size: 16px` and it's always 16px."
**iOS brain:** "I set `.body` and it's whatever the user needs it to be."

---

## Color

### System Colors

Apple provides semantic colors that adapt to light/dark mode, high contrast, and accessibility settings.

| Color | Light Mode | Dark Mode | Usage |
|---|---|---|---|
| `.primary` | Black | White | Main text |
| `.secondary` | Gray (60%) | Gray (60%) | Secondary text |
| `.tertiary` | Gray (30%) | Gray (30%) | Disabled/tertiary |
| `.accentColor` | App tint | App tint | Interactive elements |
| `.background` | White | Near-black | View backgrounds |
| `.secondarySystemBackground` | Light gray | Dark gray | Grouped content |

```swift
Text("Title")
    .foregroundStyle(.primary)      // Adapts automatically

Text("Subtitle")
    .foregroundStyle(.secondary)

Button("Action") { }
    .tint(.accentColor)
```

### Dark Mode

Dark mode is not optional on iOS. Your app must look correct in both modes.

**Rules:**
1. Never hardcode `Color.white` for backgrounds or `Color.black` for text
2. Use semantic colors (`.primary`, `.secondary`, `.background`)
3. Use the asset catalog for custom colors with light/dark variants
4. Use `.colorScheme` environment value to detect mode if needed
5. Test both modes — the simulator toggle is `Cmd + Shift + A`

### Materials and Vibrancy

iOS uses translucent materials (blur effects) extensively. These adapt to the content behind them.

```swift
Text("Overlay")
    .padding()
    .background(.regularMaterial)    // Frosted glass effect
    .background(.thinMaterial)       // Lighter blur
    .background(.ultraThinMaterial)  // Barely there
```

There is no CSS equivalent. `backdrop-filter: blur()` is the closest, but iOS materials are far more sophisticated — they adjust tint, saturation, and luminance based on the underlying content.

---

## Navigation Paradigms

### Tab Bar (Primary Navigation)

The tab bar sits at the bottom of the screen and provides top-level navigation. It is always visible.

**Rules:**
- 3-5 tabs maximum
- Use SF Symbols for icons
- Labels are short (1-2 words)
- The active tab is highlighted with the accent color
- Never hide the tab bar on sub-screens (use `NavigationStack` for drill-down)

```swift
TabView {
    Tab("Home", systemImage: "house") {
        HomeView()
    }
    Tab("Search", systemImage: "magnifyingglass") {
        SearchView()
    }
    Tab("Profile", systemImage: "person") {
        ProfileView()
    }
}
```

### Drill-Down Navigation (NavigationStack)

The hierarchical navigation pattern: tap an item to push a detail view. Swipe back or tap the back button to return.

```swift
NavigationStack {
    List(items) { item in
        NavigationLink(item.title) {
            ItemDetailView(item: item)
        }
    }
    .navigationTitle("Items")
}
```

**Rules:**
- The back button always appears automatically
- The navigation title shows in the top bar
- Large titles (`.navigationBarTitleDisplayMode(.large)`) are standard for root screens
- Inline titles (`.inline`) for detail screens

### Modals (Sheets and Full-Screen Covers)

Modals overlay the current screen. Use them for self-contained tasks (compose, settings, filters).

```swift
// Sheet — slides up from bottom, can be dismissed by swiping down
.sheet(isPresented: $showCompose) {
    ComposeView()
}

// Full-screen cover — takes over entirely, requires explicit dismiss
.fullScreenCover(isPresented: $showOnboarding) {
    OnboardingView()
}
```

**Rules:**
- Sheets are dismissible by swiping down (don't fight this)
- Provide a cancel/done button for complex sheets
- Full-screen covers need an explicit close button
- Avoid nesting modals (sheet inside sheet) — it's confusing

### Split View (iPad and Large iPhones)

`NavigationSplitView` provides sidebar + detail layout on iPad and collapses to a stack on iPhone.

```swift
NavigationSplitView {
    // Sidebar
    List(categories, selection: $selected) { category in
        Label(category.name, systemImage: category.icon)
    }
} detail: {
    // Detail view
    if let selected {
        CategoryDetailView(category: selected)
    }
}
```

---

## Common Mistakes Web Designers Make on iOS

### 1. Custom Navigation Bars

**Wrong:** Building a custom header with your own back button.
**Right:** Use `NavigationStack` with `.navigationTitle()` and `.toolbar {}`.

Users expect the system back gesture (swipe from left edge). Custom navigation breaks this.

### 2. Hamburger Menus

**Wrong:** Three-line menu icon that opens a drawer.
**Right:** Use a `TabView` for primary navigation. Use `.sheet()` or `.toolbar` for secondary actions.

The hamburger menu is a web pattern. iOS users expect tab bars.

### 3. Custom Scrollbars

**Wrong:** Styled scrollbars or scroll indicators.
**Right:** Let the system handle scrolling. iOS scrollbars are thin, appear on scroll, and disappear automatically.

### 4. Fixed-Position Elements

**Wrong:** `position: fixed` bottom bar for actions.
**Right:** Use `.toolbar` with `.bottomBar` placement, or `.safeAreaInset(edge: .bottom)`.

```swift
.toolbar {
    ToolbarItem(placement: .bottomBar) {
        Button("Submit") { }
    }
}
```

### 5. Web-Style Form Layouts

**Wrong:** Stacked labels above inputs with custom styling.
**Right:** Use `Form` with `Section` for grouped settings and inputs.

```swift
Form {
    Section("Account") {
        TextField("Name", text: $name)
        TextField("Email", text: $email)
    }
    Section("Preferences") {
        Toggle("Notifications", isOn: $notifications)
        Picker("Theme", selection: $theme) {
            Text("Light").tag(Theme.light)
            Text("Dark").tag(Theme.dark)
            Text("System").tag(Theme.system)
        }
    }
}
```

`Form` automatically handles grouping, separators, tap targets, and keyboard management.

### 6. Ignoring Dynamic Type

**Wrong:** Hardcoding `font-size: 14px` because it looks nice.
**Right:** Using text styles and testing at every Dynamic Type size.

Users who set large text sizes are often doing so out of necessity, not preference. If your app doesn't scale, you fail accessibility review.

### 7. Pixel-Perfect Thinking

**Wrong:** "This element must be exactly 375px wide."
**Right:** Use flexible layouts with `frame(maxWidth:)`, `GeometryReader` only when necessary, and trust the layout system.

iOS has 6+ screen sizes. Your layout must adapt to all of them, including iPad.

### 8. Reinventing System Components

**Wrong:** Custom toggle switch, custom date picker, custom action sheet.
**Right:** Use `Toggle`, `DatePicker`, `.confirmationDialog()`.

System components are accessible, localizable, and familiar. Custom versions are none of these by default.

---

## Gestures

| Gesture | Usage | SwiftUI |
|---|---|---|
| Tap | Primary interaction | `.onTapGesture {}` or `Button` |
| Long press | Context menu, secondary actions | `.contextMenu {}` or `.onLongPressGesture {}` |
| Swipe (edge) | Back navigation | Built into `NavigationStack` |
| Swipe (row) | Delete, archive, flag | `.swipeActions {}` on list rows |
| Pull down | Refresh content | `.refreshable { await reload() }` |
| Pinch | Zoom images/maps | `MagnifyGesture` |
| Drag | Reorder, move | `DragGesture` |

---

## Haptics

iOS has a sophisticated haptic engine. Use it for feedback — it's part of the design language.

```swift
// Impact feedback (button press, collision)
let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()

// Notification feedback (success, warning, error)
let notification = UINotificationFeedbackGenerator()
notification.notificationOccurred(.success)

// Selection feedback (picker changes, toggles)
let selection = UISelectionFeedbackGenerator()
selection.selectionChanged()

// SwiftUI shorthand
.sensoryFeedback(.impact, trigger: someValue)
```

There is no web equivalent. Haptics are a core part of making an app feel physical and responsive.

---

## Design Checklist for Web-to-iOS Transitions

- [ ] Tab bar (not hamburger) for primary navigation
- [ ] System fonts with text styles (not hardcoded sizes)
- [ ] Semantic colors that adapt to dark mode
- [ ] 44pt minimum touch targets
- [ ] Dynamic Type support (test at all sizes)
- [ ] Safe area respected (content doesn't underlap system UI)
- [ ] System components used where available (Form, Toggle, Picker)
- [ ] Back gesture works (using NavigationStack)
- [ ] Pull to refresh on scrollable content
- [ ] Swipe actions on list rows where appropriate
- [ ] Haptic feedback on meaningful interactions
- [ ] No custom scrollbars or scroll behavior
- [ ] Large titles on root screens
- [ ] Sheets dismissible by swipe-down
- [ ] Works in both portrait and landscape (or explicitly locks orientation)
