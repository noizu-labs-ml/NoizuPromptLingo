# Accessibility on macOS

SwiftUI accessibility for VoiceOver, keyboard navigation, reduced motion, high contrast, and the Accessibility Inspector.

---

## Core Accessibility Modifiers

Apply to any view. These map directly to NSAccessibility attributes.

```swift
Image(systemImage: "star.fill")
    .accessibilityLabel("Favorite")                    // What VoiceOver reads
    .accessibilityHint("Double-tap to toggle favorite") // Instruction after pause
    .accessibilityValue("Selected")                    // Current state/value
    .accessibilityHidden(true)                         // Exclude decorative elements

// Remove child labels, expose parent as single element
HStack {
    Image(systemName: "envelope")
    Text(message.subject)
    Text(message.sender)
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(message.subject), from \(message.sender)")

// Ignore children entirely (custom drawing)
Canvas { context, size in
    // custom chart rendering
}
.accessibilityLabel("Sales chart, 42% increase in Q3")
.accessibilityElement(children: .ignore)
```

---

## VoiceOver — Roles and Traits

Help VoiceOver announce the correct role and behavior.

```swift
// Announce as a button even if it's a custom view
CustomCardView()
    .accessibilityAddTraits(.isButton)
    .accessibilityRemoveTraits(.isImage)

// Static header (e.g., section title in a custom list)
Text("Recent Files")
    .accessibilityAddTraits(.isHeader)

// Link behavior
Text("Learn more")
    .accessibilityAddTraits(.isLink)
    .onTapGesture { openURL(learnMoreURL) }

// Selected state (custom tab bar)
TabButton(label: "Home", isSelected: selectedTab == .home)
    .accessibilityAddTraits(selectedTab == .home ? .isSelected : [])

// Summary element (read first in container)
VStack {
    SummaryRow(title: "Total", value: "$1,240")
        .accessibilityAddTraits(.isSummaryElement)
    DetailRows()
}
```

---

## @FocusState — Keyboard Focus Management

```swift
enum Field: Hashable { case username, password, submit }

@FocusState private var focusedField: Field?

var body: some View {
    VStack {
        TextField("Username", text: $username)
            .focused($focusedField, equals: .username)
        SecureField("Password", text: $password)
            .focused($focusedField, equals: .password)
        Button("Log In") { login() }
            .focused($focusedField, equals: .submit)
    }
    .onAppear { focusedField = .username }
    .onSubmit {
        switch focusedField {
        case .username: focusedField = .password
        case .password: focusedField = .submit
        default: login()
        }
    }
}

// Programmatic focus after async operation
func login() async {
    do {
        try await authService.login(username, password)
    } catch {
        focusedField = .password  // Return focus on failure
        errorMessage = error.localizedDescription
    }
}
```

---

## .focusable — Custom Focusable Views

Make non-interactive views keyboard-focusable (required for arrow key navigation in custom lists).

```swift
struct SelectableRow: View {
    let item: Item
    let isSelected: Bool
    var onSelect: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text(item.title)
            Spacer()
            if isSelected { Image(systemName: "checkmark") }
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.15) : .clear)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isFocused ? Color.accentColor : .clear, lineWidth: 2)
        )
        .focusable()
        .focused($isFocused)
        .onKeyPress(.space) { onSelect(); return .handled }
        .onKeyPress(.return) { onSelect(); return .handled }
        .onTapGesture { onSelect() }
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}
```

---

## Keyboard Navigation Patterns

### Tab Order

SwiftUI tab order follows view tree order by default. Override with `.accessibilitySortPriority`.

```swift
VStack {
    TextField("Last Name", text: $lastName)
        .accessibilitySortPriority(2)  // Higher = focused first
    TextField("First Name", text: $firstName)
        .accessibilitySortPriority(3)
}
```

### Arrow Key Navigation in Custom Lists

```swift
struct ArrowNavigableList: View {
    @State private var items: [Item]
    @State private var focusedIndex: Int? = 0

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { i in
                ItemRow(item: items[i], isFocused: focusedIndex == i)
                    .focusable()
                    .onKeyPress(.downArrow) {
                        focusedIndex = min((focusedIndex ?? 0) + 1, items.count - 1)
                        return .handled
                    }
                    .onKeyPress(.upArrow) {
                        focusedIndex = max((focusedIndex ?? 0) - 1, 0)
                        return .handled
                    }
            }
        }
    }
}
```

### Escape Key Handling

```swift
.onKeyPress(.escape) {
    if isEditing { isEditing = false; return .handled }
    if showPanel { showPanel = false; return .handled }
    return .ignored  // Let parent handle
}
```

---

## Accessibility Actions

Custom actions appear in VoiceOver's rotor (swipe up/down on iOS; on Mac, exposed via accessibility API).

```swift
MessageRow(message: message)
    .accessibilityAction(named: "Reply") { reply(to: message) }
    .accessibilityAction(named: "Archive") { archive(message) }
    .accessibilityAction(named: "Delete") { delete(message) }

// Custom action with system intent
FileRow(file: file)
    .accessibilityAction(.delete) { deleteFile(file) }  // Rotor "delete" action
```

---

## Reduced Motion

Always check before running animations. Mac users with vestibular disorders rely on this.

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

var body: some View {
    content
        .animation(reduceMotion ? .none : .spring(duration: 0.3), value: isExpanded)
}

// Helper modifier
extension View {
    func accessibleAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        modifier(AccessibleAnimationModifier(animation: animation, value: value))
    }
}

struct AccessibleAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? .none : animation, value: value)
    }
}

// Usage
.accessibleAnimation(.easeInOut(duration: 0.25), value: showDetail)
```

---

## High Contrast and Color

```swift
@Environment(\.colorSchemeContrast) private var contrast
@Environment(\.colorScheme) private var colorScheme

var borderColor: Color {
    contrast == .increased
        ? (colorScheme == .dark ? .white : .black)
        : .secondary.opacity(0.3)
}

// Differentiate by shape/pattern, not color alone
HStack {
    Circle()
        .fill(status == .active ? .green : .red)
    // Add label so status isn't color-only
    Text(status == .active ? "Active" : "Inactive")
        .foregroundStyle(.secondary)
}

// Check for sufficient contrast in custom color usage
// WCAG AA: 4.5:1 for text, 3:1 for large text / UI components
```

---

## Accessibility Inspector — Workflow

The Accessibility Inspector (Xcode → Open Developer Tool → Accessibility Inspector) is the primary debugging tool.

**Key workflows:**

1. **Audit** — Run automated audit for missing labels, small touch targets, contrast failures.
2. **Inspection** — Hover over elements to see VoiceOver label, role, value, traits.
3. **Navigation simulation** — Tab through elements to verify focus order.
4. **VoiceOver preview** — Enable in Inspector to hear read-out without full VoiceOver.

**Common audit failures and fixes:**

| Issue | Fix |
|-------|-----|
| "Image has no description" | Add `.accessibilityLabel()` or `.accessibilityHidden(true)` |
| "Element has no label" | Add `.accessibilityLabel()` to button/control |
| "Text contrast too low" | Increase contrast or use semantic colors |
| "Element too small" | Add `.frame(minWidth: 44, minHeight: 44)` hit area |
| "Duplicate label" | Use `.accessibilityElement(children: .combine)` |

---

## Semantic Colors (System-Adaptive)

Always prefer semantic colors over hardcoded values — they adapt to dark mode and high contrast.

```swift
Color(nsColor: .labelColor)          // Primary text
Color(nsColor: .secondaryLabelColor) // Secondary text
Color(nsColor: .tertiaryLabelColor)  // Placeholder-level text
Color(nsColor: .controlBackgroundColor) // Input background
Color(nsColor: .windowBackgroundColor)  // Window background
Color(nsColor: .separatorColor)      // Dividers
Color(nsColor: .selectedContentBackgroundColor) // Selection (active window)
Color(nsColor: .unemphasizedSelectedContentBackgroundColor) // Selection (inactive)
```

---

## Checklist — Accessibility Review

- [ ] Every interactive element has `.accessibilityLabel`
- [ ] Decorative images have `.accessibilityHidden(true)`
- [ ] Custom controls have correct `.accessibilityAddTraits`
- [ ] Focus order is logical (matches visual layout)
- [ ] All actions available via keyboard
- [ ] Animations respect `accessibilityReduceMotion`
- [ ] Status/state not communicated by color alone
- [ ] Accessibility Inspector audit passes (0 errors)
- [ ] Tested with VoiceOver cursor navigation
