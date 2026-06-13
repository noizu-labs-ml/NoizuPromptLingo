# iOS Accessibility for Web Developers

Accessibility on iOS maps closely to web ARIA patterns, but the implementation is different. Instead of `aria-label` attributes on HTML elements, you chain accessibility modifiers onto SwiftUI views. The screen reader is VoiceOver (not NVDA/JAWS), and the text scaling system is Dynamic Type (not browser zoom).

Apple reviews apps for accessibility. Failing to support VoiceOver or Dynamic Type can result in App Store rejection, especially for apps targeting education, health, or government.

---

## Web to iOS Accessibility Mapping

| Web (ARIA) | SwiftUI |
|------------|---------|
| `aria-label` | `.accessibilityLabel("...")` |
| `aria-describedby` | `.accessibilityHint("...")` |
| `aria-hidden="true"` | `.accessibilityHidden(true)` |
| `role="button"` | `.accessibilityAddTraits(.isButton)` |
| `role="heading"` | `.accessibilityAddTraits(.isHeader)` |
| `role="img"` | `.accessibilityAddTraits(.isImage)` |
| `aria-live="polite"` | `AccessibilityNotification.Announcement` |
| `aria-valuenow` | `.accessibilityValue("...")` |
| `tabindex` | `.accessibilitySortPriority(...)` |
| `aria-expanded` | `.accessibilityAddTraits(.isExpanded)` / `.accessibilityRemoveTraits(.isExpanded)` |

---

## VoiceOver Support

### Labels — What the Element Is

**Web:**
```html
<button aria-label="Add to favorites">
    <svg><!-- heart icon --></svg>
</button>
```

**SwiftUI:**
```swift
Button(action: addToFavorites) {
    Image(systemName: "heart.fill")
}
.accessibilityLabel("Add to favorites")
```

SwiftUI infers labels automatically for `Text` and `Button` with string titles. You need explicit labels when:
- The view is an icon-only button
- The visible text is not descriptive enough
- The view is a custom drawing or image

### Hints — What Happens When You Activate

```swift
Button(action: toggleFavorite) {
    Image(systemName: isFavorite ? "heart.fill" : "heart")
}
.accessibilityLabel(isFavorite ? "Favorited" : "Not favorited")
.accessibilityHint("Double tap to toggle favorite status")
```

Hints are read after a pause. They explain the action — like `aria-describedby` for interactive elements.

### Value — Current State of a Control

```swift
Slider(value: $brightness, in: 0...100)
    .accessibilityLabel("Brightness")
    .accessibilityValue("\(Int(brightness)) percent")
```

### Traits — What Kind of Element This Is

```swift
// Mark a decorative divider as non-interactive
Divider()
    .accessibilityHidden(true)

// Mark a text view as a heading (like <h2>)
Text("Settings")
    .font(.title)
    .accessibilityAddTraits(.isHeader)

// Mark an image as decorative (skip in VoiceOver)
Image("decorative-swirl")
    .accessibilityHidden(true)

// Custom view that acts like a button
HStack {
    Image(systemName: "gear")
    Text("Settings")
}
.onTapGesture { openSettings() }
.accessibilityElement(children: .combine)    // treat as single element
.accessibilityAddTraits(.isButton)
.accessibilityLabel("Settings")
```

### Grouping Elements

**Web:**
```html
<div role="group" aria-label="User profile">
    <img src="avatar.jpg" alt="" />
    <span>Keith Brings</span>
    <span>Admin</span>
</div>
```

**SwiftUI:**
```swift
HStack {
    Image("avatar")
    VStack(alignment: .leading) {
        Text("Keith Brings")
        Text("Admin")
    }
}
.accessibilityElement(children: .combine)
// VoiceOver reads: "Keith Brings, Admin"

// Or with a custom label overriding children
HStack {
    Image("avatar")
    VStack(alignment: .leading) {
        Text(user.name)
        Text(user.role)
    }
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("\(user.name), \(user.role)")
```

`.accessibilityElement(children: .combine)` merges child labels into one reading. `.accessibilityElement(children: .ignore)` hides children and uses only the parent's label.

---

## Dynamic Type (Scalable Text)

Dynamic Type is the iOS equivalent of browser text zoom, but it is deeply integrated into the system. Users set their preferred text size in Settings, and every app is expected to respect it.

**Web:**
```css
font-size: 1rem;  /* scales with browser zoom */
```

**SwiftUI — automatic support:**
```swift
// These scale automatically with Dynamic Type
Text("Hello").font(.body)
Text("Title").font(.title)
Text("Caption").font(.caption)

// ALL semantic font styles scale automatically:
// .largeTitle, .title, .title2, .title3, .headline,
// .subheadline, .body, .callout, .footnote, .caption, .caption2
```

**Fixed sizes do NOT scale:**
```swift
// This will NOT respect Dynamic Type
Text("Fixed").font(.system(size: 16))

// Make it scale with @ScaledMetric
@ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 24

Image(systemName: "star")
    .font(.system(size: iconSize))  // now scales with Dynamic Type
```

### @ScaledMetric — Scaling Non-Text Values

Use `@ScaledMetric` for padding, icon sizes, and spacing that should scale with text size.

```swift
struct ScaledCard: View {
    @ScaledMetric(relativeTo: .body) var padding: CGFloat = 16
    @ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 32
    @ScaledMetric(relativeTo: .body) var spacing: CGFloat = 12

    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: "bell.fill")
                .font(.system(size: iconSize))
            VStack(alignment: .leading) {
                Text("Notification").font(.headline)
                Text("You have a new message").font(.body)
            }
        }
        .padding(padding)
    }
}
```

### Limiting Scale Range

For layouts that break at extreme sizes:

```swift
Text("Constrained")
    .font(.body)
    .dynamicTypeSize(.small ... .xxxLarge)  // limit range

// Or cap at accessibility sizes
Text("Capped")
    .font(.body)
    .dynamicTypeSize(...DynamicTypeSize.accessibility3)
```

---

## Color and Contrast

### System Colors

System colors adapt to light/dark mode and high contrast settings automatically.

```swift
// These adapt automatically — prefer them over custom colors
Text("Primary").foregroundStyle(.primary)          // black/white depending on mode
Text("Secondary").foregroundStyle(.secondary)      // gray that adapts
Text("Link").foregroundStyle(.accentColor)         // app tint color

// System background colors
Rectangle().fill(Color(.systemBackground))         // white/black
Rectangle().fill(Color(.secondarySystemBackground)) // grouped table bg
Rectangle().fill(Color(.tertiarySystemBackground))  // deeper grouping
```

### High Contrast Support

```swift
@Environment(\.colorSchemeContrast) var contrast

var body: some View {
    Text("Important")
        .foregroundStyle(contrast == .increased ? .primary : .secondary)
}
```

### Color as Non-Sole Indicator

Never use color alone to convey information — same rule as WCAG 1.4.1.

```swift
// Bad: color is the only indicator
Circle()
    .fill(isOnline ? .green : .red)

// Good: color plus icon
HStack {
    Image(systemName: isOnline ? "checkmark.circle.fill" : "xmark.circle.fill")
        .foregroundStyle(isOnline ? .green : .red)
    Text(isOnline ? "Online" : "Offline")
}
```

---

## Reduce Motion

**Web:**
```css
@media (prefers-reduced-motion: reduce) {
    * { animation: none !important; transition: none !important; }
}
```

**SwiftUI:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    CardView()
        .onTapGesture {
            if reduceMotion {
                showDetail = true   // instant, no animation
            } else {
                withAnimation(.spring) {
                    showDetail = true
                }
            }
        }
}

// Conditional transition
if showBanner {
    BannerView()
        .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
}
```

Also check for other accessibility preferences:

```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency
@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
@Environment(\.accessibilityInvertColors) var invertColors

var body: some View {
    Rectangle()
        .fill(reduceTransparency ? .white : .ultraThinMaterial)
}
```

---

## Accessibility Actions

Custom actions for VoiceOver users — like context menus via keyboard.

```swift
struct MessageRow: View {
    let message: Message

    var body: some View {
        VStack(alignment: .leading) {
            Text(message.sender).font(.headline)
            Text(message.body).font(.body)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Reply") {
            replyToMessage(message)
        }
        .accessibilityAction(named: "Delete") {
            deleteMessage(message)
        }
        .accessibilityAction(named: "Forward") {
            forwardMessage(message)
        }
    }
}
```

VoiceOver users swipe up/down to cycle through these actions.

---

## Live Announcements

**Web:**
```html
<div aria-live="polite">Items updated</div>
```

**SwiftUI:**
```swift
// Post an announcement for VoiceOver
AccessibilityNotification.Announcement("3 new messages loaded")
    .post()

// Announce after async operation
func loadData() async {
    let items = await fetchItems()
    self.items = items
    AccessibilityNotification.Announcement("\(items.count) items loaded")
        .post()
}
```

---

## Testing Accessibility

### In Simulator

1. Open **Accessibility Inspector** (Xcode menu: Xcode > Open Developer Tool > Accessibility Inspector)
2. Point it at your running Simulator
3. Hover over elements to see labels, hints, traits
4. Run the built-in audit (click the audit icon) for automated checks

### On Device

1. **Settings > Accessibility > VoiceOver** — enable and navigate your app
2. **Settings > Accessibility > Display & Text Size > Larger Text** — test at maximum size
3. **Settings > Accessibility > Display & Text Size > Increase Contrast** — verify contrast
4. **Settings > Accessibility > Motion > Reduce Motion** — verify animations degrade gracefully

### VoiceOver Gestures

| Gesture | Action |
|---------|--------|
| Swipe right | Next element |
| Swipe left | Previous element |
| Double tap | Activate element |
| Three-finger swipe | Scroll |
| Swipe up/down | Adjust value / cycle actions |
| Two-finger tap | Pause/resume speech |

### Xcode Preview with Accessibility

```swift
#Preview {
    ContentView()
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        .environment(\.colorScheme, .dark)
}
```

Use previews with extreme Dynamic Type sizes to catch layout breakage during development, not after submission.
