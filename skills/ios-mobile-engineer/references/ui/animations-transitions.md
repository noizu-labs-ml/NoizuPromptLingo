# SwiftUI Animations and Transitions for Web Developers

SwiftUI animations are state-driven. You change a value, and SwiftUI interpolates between the old and new states. There is no imperative `element.animate()` — you declare what the end state looks like and the framework figures out the in-between frames.

---

## Mental Model: CSS vs SwiftUI

| CSS | SwiftUI |
|-----|---------|
| `transition: opacity 0.3s ease` | `.animation(.easeInOut(duration: 0.3), value: opacity)` |
| `@keyframes` + `animation:` | `withAnimation { }` + state changes |
| `transition` on property change | Implicit animation on state change |
| JavaScript `requestAnimationFrame` | `TimelineView` |
| Shared element transition (View Transitions API) | `matchedGeometryEffect` |

The fundamental difference: CSS animates **property changes on existing elements**. SwiftUI animates **state changes that may add, remove, or modify views**.

---

## Implicit Animations

Attach an `.animation` modifier to a view. Any change to the tracked value animates automatically.

**CSS equivalent:**
```css
.box {
    opacity: 1;
    transition: opacity 0.3s ease-in-out;
}
.box.hidden { opacity: 0; }
```

**SwiftUI:**
```swift
struct FadeExample: View {
    @State private var isVisible = true

    var body: some View {
        VStack {
            Button("Toggle") {
                isVisible.toggle()
            }

            Rectangle()
                .fill(.blue)
                .frame(width: 200, height: 200)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isVisible)
        }
    }
}
```

Multiple properties animate together when driven by the same state:

```swift
Circle()
    .fill(isExpanded ? .blue : .red)
    .frame(width: isExpanded ? 200 : 50, height: isExpanded ? 200 : 50)
    .opacity(isExpanded ? 1 : 0.5)
    .animation(.easeInOut(duration: 0.4), value: isExpanded)
```

All three properties (color, size, opacity) animate in sync because they all depend on `isExpanded`.

---

## Explicit Animations

Wrap state changes in `withAnimation` to animate everything that depends on the changed state. This is the more common pattern in production code.

**CSS/JS equivalent:**
```javascript
element.classList.add('animated');
// where .animated has CSS transitions defined
```

**SwiftUI:**
```swift
struct ExplicitExample: View {
    @State private var offset: CGFloat = 0
    @State private var scale: CGFloat = 1

    var body: some View {
        Circle()
            .fill(.purple)
            .frame(width: 60, height: 60)
            .offset(y: offset)
            .scaleEffect(scale)

        Button("Bounce") {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                offset = -100
                scale = 1.2
            }
            // Reset after delay
            withAnimation(.easeOut(duration: 0.3).delay(0.4)) {
                offset = 0
                scale = 1
            }
        }
    }
}
```

`withAnimation` is preferred over `.animation()` because it is explicit about which state changes animate. The implicit modifier can cause unexpected animations on unrelated state changes.

---

## Timing Curves

**CSS:**
```css
transition-timing-function: ease-in-out;
transition-timing-function: cubic-bezier(0.68, -0.55, 0.265, 1.55);
```

**SwiftUI:**
```swift
// Built-in curves (same names as CSS)
.animation(.linear(duration: 0.3), value: state)
.animation(.easeIn(duration: 0.3), value: state)
.animation(.easeOut(duration: 0.3), value: state)
.animation(.easeInOut(duration: 0.3), value: state)

// Custom bezier
.animation(.timingCurve(0.68, -0.55, 0.265, 1.55, duration: 0.5), value: state)
```

---

## Spring Animations

Springs do not exist in CSS. They are the default and recommended animation type in SwiftUI because they feel natural and never overshoot unnaturally.

```swift
// iOS 17+ simplified spring
withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
    isExpanded.toggle()
}

// Classic spring parameters
withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
    isExpanded.toggle()
}

// Bouncy preset
withAnimation(.bouncy) {
    isExpanded.toggle()
}

// Snappy preset (minimal overshoot)
withAnimation(.snappy) {
    isExpanded.toggle()
}

// Smooth preset (no overshoot)
withAnimation(.smooth) {
    isExpanded.toggle()
}
```

| Parameter | Effect |
|-----------|--------|
| `response` | Duration-like feel (lower = faster) |
| `dampingFraction` | 0 = infinite bounce, 1 = no bounce |
| `bounce` | 0 = no bounce, 1 = maximum bounce (iOS 17+) |

---

## Transitions (View Insertion/Removal)

Transitions animate views entering and leaving the view hierarchy. CSS has no direct equivalent — the closest is `@keyframes` with `animation-fill-mode: forwards` and removing elements after animation completes. SwiftUI handles this automatically.

```swift
struct TransitionExample: View {
    @State private var showDetail = false

    var body: some View {
        VStack {
            Button("Toggle Detail") {
                withAnimation(.easeInOut) {
                    showDetail.toggle()
                }
            }

            if showDetail {
                DetailCard()
                    .transition(.slide)              // slides in from leading edge
            }
        }
    }
}
```

### Built-in Transitions

```swift
.transition(.opacity)                        // fade in/out
.transition(.slide)                          // slide from leading edge
.transition(.scale)                          // scale from center
.transition(.move(edge: .bottom))            // slide from specific edge
.transition(.push(from: .bottom))            // push (iOS 16+)

// Combine transitions
.transition(.opacity.combined(with: .scale))

// Asymmetric: different animation for insertion vs removal
.transition(.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
))
```

---

## matchedGeometryEffect (Shared Element Transitions)

This is SwiftUI's equivalent of the View Transitions API or FLIP animations. It smoothly morphs one view into another across different positions in the hierarchy.

```swift
struct SharedTransitionExample: View {
    @Namespace private var animation
    @State private var isExpanded = false

    var body: some View {
        if isExpanded {
            // Expanded state
            VStack {
                Image("photo")
                    .resizable()
                    .matchedGeometryEffect(id: "image", in: animation)
                    .frame(height: 300)

                Text("Full Article Title")
                    .font(.title)
                    .matchedGeometryEffect(id: "title", in: animation)

                Text("Article body content here...")
                    .padding()
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded = false
                }
            }
        } else {
            // Collapsed state
            HStack {
                Image("photo")
                    .resizable()
                    .matchedGeometryEffect(id: "image", in: animation)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("Full Article Title")
                    .font(.headline)
                    .matchedGeometryEffect(id: "title", in: animation)

                Spacer()
            }
            .padding()
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded = true
                }
            }
        }
    }
}
```

The `@Namespace` creates a shared coordinate space. Views with the same `id` in the same namespace animate between their positions, sizes, and shapes.

---

## Repeating and Keyframe Animations

**CSS:**
```css
@keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.1); }
    100% { transform: scale(1); }
}
.pulse { animation: pulse 1s infinite; }
```

**SwiftUI (simple repeat):**
```swift
struct PulseView: View {
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 60, height: 60)
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .animation(
                .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}
```

**SwiftUI Keyframe Animations (iOS 17+):**
```swift
struct KeyframeExample: View {
    @State private var trigger = false

    var body: some View {
        Image(systemName: "bell.fill")
            .font(.largeTitle)
            .keyframeAnimator(initialValue: AnimationValues(), trigger: trigger) { content, value in
                content
                    .rotationEffect(value.rotation)
                    .scaleEffect(value.scale)
            } keyframes: { _ in
                KeyframeTrack(\.rotation) {
                    SpringKeyframe(.degrees(-15), duration: 0.15)
                    SpringKeyframe(.degrees(15), duration: 0.15)
                    SpringKeyframe(.degrees(-10), duration: 0.15)
                    SpringKeyframe(.degrees(0), duration: 0.15)
                }
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.2, duration: 0.15)
                    SpringKeyframe(1.0, duration: 0.45)
                }
            }
            .onTapGesture { trigger.toggle() }
    }
}

struct AnimationValues {
    var rotation: Angle = .zero
    var scale: CGFloat = 1.0
}
```

---

## Phase Animations (iOS 17+)

Multi-step sequential animations — like chaining CSS animations with `animation-delay`.

```swift
enum BouncePhase: CaseIterable {
    case initial, move, scale

    var yOffset: CGFloat {
        switch self {
        case .initial: 0
        case .move: -60
        case .scale: -60
        }
    }

    var scale: CGFloat {
        switch self {
        case .initial: 1
        case .move: 1
        case .scale: 1.3
        }
    }
}

Image(systemName: "star.fill")
    .phaseAnimator(BouncePhase.allCases, trigger: triggerValue) { content, phase in
        content
            .offset(y: phase.yOffset)
            .scaleEffect(phase.scale)
    } animation: { phase in
        switch phase {
        case .initial: .smooth
        case .move: .spring(bounce: 0.4)
        case .scale: .bouncy
        }
    }
```

---

## Reduce Motion Support

Always respect the user's accessibility preference:

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

Button("Animate") {
    if reduceMotion {
        // Instant state change, no animation
        showDetail = true
    } else {
        withAnimation(.spring) {
            showDetail = true
        }
    }
}

// Or use a conditional animation wrapper
withAnimation(reduceMotion ? nil : .spring) {
    showDetail.toggle()
}
```

In CSS, this is `@media (prefers-reduced-motion: reduce)`. In SwiftUI, you read the environment value and conditionally apply animation.
