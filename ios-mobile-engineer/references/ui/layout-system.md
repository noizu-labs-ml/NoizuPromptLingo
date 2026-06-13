# SwiftUI Layout System for Web Developers

SwiftUI layout works inside-out: parent proposes a size, child chooses its own size, parent positions the child. This is the opposite of CSS, where the parent dictates size via constraints. Understanding this inversion is the key to not fighting the layout system.

---

## Core Concept: The Layout Protocol

Every layout negotiation follows three steps:

1. **Parent proposes** a size to the child
2. **Child responds** with its actual size (it can ignore the proposal)
3. **Parent positions** the child within its coordinate space

There is no `display: block` vs `inline` vs `flex`. Every view participates in this same protocol.

---

## HStack / VStack / ZStack (Flexbox Equivalents)

**CSS Flexbox:**
```css
.row { display: flex; flex-direction: row; gap: 12px; align-items: center; }
.col { display: flex; flex-direction: column; gap: 8px; align-items: flex-start; }
```

**SwiftUI:**
```swift
// Horizontal layout (flex-direction: row)
HStack(alignment: .center, spacing: 12) {
    Image(systemName: "star.fill")
    Text("Favorites")
    Spacer()                    // flex-grow: 1 equivalent
    Text("42")
}

// Vertical layout (flex-direction: column)
VStack(alignment: .leading, spacing: 8) {
    Text("Title").font(.headline)
    Text("Subtitle").font(.subheadline)
    Text("Body text goes here").font(.body)
}

// Layered / stacked (position: absolute equivalent)
ZStack(alignment: .bottomTrailing) {
    Image("photo")
        .resizable()
        .frame(width: 200, height: 200)
    Text("NEW")
        .padding(4)
        .background(.red)
        .foregroundStyle(.white)
        .font(.caption)
}
```

### Alignment Mapping

| CSS | HStack | VStack |
|-----|--------|--------|
| `align-items: flex-start` | `.top` | `.leading` |
| `align-items: center` | `.center` | `.center` |
| `align-items: flex-end` | `.bottom` | `.trailing` |
| `align-items: baseline` | `.firstTextBaseline` | N/A |

### Spacer — The Flex-Grow Equivalent

```swift
// Push items to edges (justify-content: space-between)
HStack {
    Text("Left")
    Spacer()
    Text("Right")
}

// Fixed minimum spacing
HStack {
    Text("Left")
    Spacer(minLength: 20)
    Text("Right")
}

// Center an item with equal push from both sides
HStack {
    Spacer()
    Text("Centered")
    Spacer()
}
```

---

## Frame Modifier (Width/Height/Constraints)

```swift
// Fixed size
Text("Box")
    .frame(width: 200, height: 100)

// Min/max constraints (like min-width, max-width)
Text("Flexible")
    .frame(minWidth: 100, maxWidth: 300, minHeight: 44)

// Fill available width (width: 100%)
Text("Full Width")
    .frame(maxWidth: .infinity)

// Fill available space and align within it
Text("Top Left")
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
```

---

## LazyVGrid / LazyHGrid (CSS Grid Equivalent)

**CSS Grid:**
```css
.grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
}
```

**SwiftUI:**
```swift
// Fixed column count (repeat(3, 1fr))
let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
]

LazyVGrid(columns: columns, spacing: 16) {
    ForEach(items) { item in
        CardView(item: item)
    }
}

// Adaptive columns (repeat(auto-fill, minmax(150px, 1fr)))
let adaptive = [
    GridItem(.adaptive(minimum: 150), spacing: 16)
]

LazyVGrid(columns: adaptive, spacing: 16) {
    ForEach(items) { item in
        CardView(item: item)
    }
}

// Fixed-size columns (grid-template-columns: 80px 1fr 80px)
let mixed = [
    GridItem(.fixed(80)),
    GridItem(.flexible()),
    GridItem(.fixed(80))
]

LazyVGrid(columns: mixed) {
    ForEach(items) { item in
        Text(item.name)
    }
}
```

`Lazy` means views are created on demand as they scroll into view — like virtualized lists in React (`react-window`, `react-virtuoso`).

---

## ScrollView

**Web:**
```css
.container { overflow-y: auto; height: 400px; }
```

**SwiftUI:**
```swift
// Vertical scroll (default)
ScrollView {
    VStack(spacing: 12) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
    .padding()
}

// Horizontal scroll
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 12) {
        ForEach(items) { item in
            CardView(item: item)
        }
    }
    .padding(.horizontal)
}

// Scroll to specific position (iOS 17+)
ScrollView {
    LazyVStack {
        ForEach(messages) { message in
            MessageBubble(message: message)
                .id(message.id)
        }
    }
}
.scrollPosition(id: $scrolledID)
.defaultScrollAnchor(.bottom)
```

**Important:** `ScrollView` does not recycle views. For long lists, use `List` (which recycles) or put `LazyVStack`/`LazyVGrid` inside a `ScrollView`.

```swift
// Performant scrolling list — views created lazily
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(thousandsOfItems) { item in
            ItemRow(item: item)
        }
    }
}
```

---

## GeometryReader (Responsive Calculations)

GeometryReader gives you the **proposed size** from the parent — use it for percentage-based layouts and responsive breakpoints.

**CSS:**
```css
.sidebar { width: 30%; }
.main { width: 70%; }
```

**SwiftUI:**
```swift
GeometryReader { geometry in
    HStack(spacing: 0) {
        SidebarView()
            .frame(width: geometry.size.width * 0.3)
        MainContentView()
            .frame(width: geometry.size.width * 0.7)
    }
}

// Responsive breakpoint
GeometryReader { geometry in
    if geometry.size.width > 600 {
        // iPad-like: side by side
        HStack {
            SidebarView()
            DetailView()
        }
    } else {
        // iPhone: stacked
        NavigationStack {
            SidebarView()
        }
    }
}
```

**Warning:** GeometryReader is greedy — it expands to fill all available space. Wrapping small views in GeometryReader causes unexpected layout expansion. Prefer `containerRelativeFrame` (iOS 17+) for simpler cases:

```swift
// iOS 17+: no GeometryReader needed
Image("hero")
    .resizable()
    .containerRelativeFrame(.horizontal) { width, _ in
        width * 0.8
    }
```

---

## Custom Layout Protocol (iOS 16+)

For layouts that CSS Grid and Flexbox cannot express — like radial layouts, flow/tag layouts, or masonry grids.

```swift
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return CGSize(width: maxWidth, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

// Usage — tag cloud
FlowLayout(spacing: 8) {
    ForEach(tags, id: \.self) { tag in
        Text(tag)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.blue.opacity(0.1))
            .clipShape(Capsule())
    }
}
```

---

## Layout Quick Reference

| Web Concept | SwiftUI Equivalent |
|-------------|-------------------|
| `display: flex; flex-direction: row` | `HStack` |
| `display: flex; flex-direction: column` | `VStack` |
| `position: absolute` / stacking | `ZStack` |
| `display: grid` | `LazyVGrid` / `LazyHGrid` |
| `overflow: auto` | `ScrollView` |
| `flex-grow: 1` | `Spacer()` |
| `width: 100%` | `.frame(maxWidth: .infinity)` |
| `gap: 12px` | `spacing: 12` parameter on stacks |
| `padding: 16px` | `.padding(16)` |
| `margin` | No direct equivalent — use `padding` on parent or `Spacer` |
| `@media (min-width: 600px)` | `GeometryReader` or `horizontalSizeClass` |
| `vh` / `vw` units | `GeometryReader` or `containerRelativeFrame` |
| `z-index` | `ZStack` ordering (last child on top) or `.zIndex()` |

There is no `margin` in SwiftUI. Spacing between siblings is controlled by the parent stack's `spacing` parameter. Spacing from edges is `.padding()`. This eliminates margin collapsing entirely.
