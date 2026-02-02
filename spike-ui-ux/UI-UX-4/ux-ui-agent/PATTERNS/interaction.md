# Interaction Patterns

> Motion and feedback patterns including micro-interactions, transitions, animations, and user feedback. Guidelines for creating responsive, delightful, and accessible interactions.

---

## 1. Interaction Principles

### 1.1 Purpose of Motion

Motion in interfaces should:

| Purpose | Example |
|---------|---------|
| **Provide feedback** | Button press, form submission |
| **Guide attention** | Highlight changes, direct focus |
| **Show relationships** | Parent-child, cause-effect |
| **Establish hierarchy** | Staggered reveals, importance |
| **Create continuity** | Page transitions, state changes |
| **Add delight** | Celebrations, personality moments |

**Never use motion:**
- As decoration alone
- To delay users
- Without purpose
- At the expense of performance

### 1.2 The 3 Laws of Motion Design

1. **Motion should be invisible** - Users should feel the result, not notice the animation
2. **Motion should be fast** - Most interactions 150-300ms
3. **Motion should be meaningful** - Every animation serves a purpose

---

## 2. Timing & Easing

### 2.1 Duration Guidelines

| Interaction Type | Duration | Rationale |
|------------------|----------|-----------|
| Micro-interaction | 100-150ms | Immediate feedback |
| Button/toggle state | 150ms | Quick acknowledgment |
| Fade in/out | 150-200ms | Smooth without delay |
| Slide/expand | 200-300ms | Perceivable movement |
| Modal open/close | 200-300ms | Context switch |
| Page transition | 300-500ms | Larger context change |
| Complex animation | 300-800ms | Storytelling moments |

**Rule of thumb:** If you notice the animation, it's probably too slow.

### 2.2 Easing Functions

```css
:root {
  /* Standard easings */
  --ease-out: cubic-bezier(0.0, 0.0, 0.2, 1);      /* Decelerate - entering */
  --ease-in: cubic-bezier(0.4, 0.0, 1, 1);         /* Accelerate - exiting */
  --ease-in-out: cubic-bezier(0.4, 0.0, 0.2, 1);   /* Both - moving */
  
  /* Expressive easings */
  --ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);  /* Playful */
  --ease-smooth: cubic-bezier(0.25, 0.1, 0.25, 1);        /* Gentle */
}
```

**When to use each:**

| Easing | Use For |
|--------|---------|
| `ease-out` | Elements entering (fade in, slide in) |
| `ease-in` | Elements leaving (fade out, slide out) |
| `ease-in-out` | Elements moving position |
| `linear` | Continuous motion (spinners, progress) |
| `bounce` | Playful interactions, celebrations |

### 2.3 CSS Transition Best Practices

```css
/* Good: Specific properties */
.button {
  transition: background-color 150ms ease-out, 
              transform 150ms ease-out;
}

/* Avoid: Transition all */
.button {
  transition: all 150ms ease-out; /* Can cause jank */
}

/* Best: Only GPU-accelerated properties */
.card {
  transition: transform 200ms ease-out, 
              opacity 200ms ease-out;
}
```

**GPU-accelerated (prefer):** `transform`, `opacity`

**Cause repaint (use sparingly):** `background-color`, `box-shadow`

**Cause reflow (avoid animating):** `width`, `height`, `margin`, `padding`

---

## 3. Micro-interactions

### 3.1 Button Feedback

```css
.btn {
  transition: background-color 150ms ease-out, 
              transform 100ms ease-out;
}

.btn:hover {
  background-color: var(--color-primary-dark);
}

.btn:active {
  transform: scale(0.98);
}

.btn:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}
```

### 3.2 Toggle/Switch

```css
.toggle {
  width: 48px;
  height: 24px;
  background: var(--color-gray);
  border-radius: 12px;
  position: relative;
  transition: background-color 200ms ease-out;
}

.toggle.active {
  background: var(--color-primary);
}

.toggle-knob {
  width: 20px;
  height: 20px;
  background: white;
  border-radius: 50%;
  position: absolute;
  top: 2px;
  left: 2px;
  transition: transform 200ms ease-out;
}

.toggle.active .toggle-knob {
  transform: translateX(24px);
}
```

### 3.3 Input Focus

```css
.input {
  border: 1px solid var(--color-border);
  transition: border-color 150ms ease-out, 
              box-shadow 150ms ease-out;
}

.input:focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(var(--color-primary-rgb), 0.1);
}
```

### 3.4 Link Hover Underline

```css
.link {
  position: relative;
  text-decoration: none;
}

.link::after {
  content: "";
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 1px;
  background: currentColor;
  transform: scaleX(0);
  transform-origin: right;
  transition: transform 200ms ease-out;
}

.link:hover::after {
  transform: scaleX(1);
  transform-origin: left;
}
```

---

## 4. Component Transitions

### 4.1 Modal Open/Close

```css
/* Backdrop */
.modal-backdrop {
  opacity: 0;
  transition: opacity 200ms ease-out;
}

.modal-backdrop.open {
  opacity: 1;
}

/* Modal content */
.modal-content {
  opacity: 0;
  transform: scale(0.95) translateY(-10px);
  transition: opacity 200ms ease-out, 
              transform 200ms ease-out;
}

.modal-content.open {
  opacity: 1;
  transform: scale(1) translateY(0);
}
```

### 4.2 Dropdown/Menu

```css
.dropdown {
  opacity: 0;
  transform: translateY(-8px);
  pointer-events: none;
  transition: opacity 150ms ease-out, 
              transform 150ms ease-out;
}

.dropdown.open {
  opacity: 1;
  transform: translateY(0);
  pointer-events: auto;
}
```

### 4.3 Accordion/Collapse

```css
.accordion-content {
  display: grid;
  grid-template-rows: 0fr;
  transition: grid-template-rows 300ms ease-out;
}

.accordion-content.open {
  grid-template-rows: 1fr;
}

.accordion-inner {
  overflow: hidden;
}
```

### 4.4 Toast Notification

```css
.toast {
  transform: translateX(100%);
  opacity: 0;
  transition: transform 300ms ease-out, 
              opacity 300ms ease-out;
}

.toast.visible {
  transform: translateX(0);
  opacity: 1;
}

.toast.exiting {
  transform: translateX(100%);
  opacity: 0;
  transition-timing-function: ease-in;
  transition-duration: 200ms;
}
```

---

## 5. Page & View Transitions

### 5.1 View Transitions API (2026)

```css
@view-transition {
  navigation: auto;
}

::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 300ms;
}

/* Named element transition */
.hero-image {
  view-transition-name: hero;
}
```

### 5.2 Scroll Reveal

```css
.reveal {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity 0.6s ease-out, transform 0.6s ease-out;
}

.reveal.visible {
  opacity: 1;
  transform: translateY(0);
}
```

```javascript
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  },
  { threshold: 0.1 }
);

document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
```

### 5.3 Staggered Reveal

```css
.stagger > * {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity 0.4s ease-out, transform 0.4s ease-out;
}

.stagger.visible > *:nth-child(1) { transition-delay: 0ms; }
.stagger.visible > *:nth-child(2) { transition-delay: 100ms; }
.stagger.visible > *:nth-child(3) { transition-delay: 200ms; }
.stagger.visible > *:nth-child(4) { transition-delay: 300ms; }

.stagger.visible > * {
  opacity: 1;
  transform: translateY(0);
}
```

---

## 6. Loading States

### 6.1 Skeleton Screen

```css
.skeleton {
  background: linear-gradient(
    90deg,
    var(--color-skeleton) 0%,
    var(--color-skeleton-highlight) 50%,
    var(--color-skeleton) 100%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

### 6.2 Spinner

```css
.spinner {
  width: 24px;
  height: 24px;
  border: 2px solid var(--color-border);
  border-top-color: var(--color-primary);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
```

### 6.3 Button Loading

```css
.btn-loading {
  position: relative;
  color: transparent;
  pointer-events: none;
}

.btn-loading::after {
  content: "";
  position: absolute;
  width: 16px;
  height: 16px;
  top: 50%;
  left: 50%;
  margin: -8px 0 0 -8px;
  border: 2px solid white;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}
```

---

## 7. Feedback & Celebration

### 7.1 Success Checkmark

```css
.check-circle {
  transform-origin: center;
  animation: scaleIn 0.3s ease-out;
}

.check-path {
  stroke-dasharray: 30;
  stroke-dashoffset: 30;
  animation: drawCheck 0.4s ease-out 0.2s forwards;
}

@keyframes scaleIn {
  from { transform: scale(0); }
  to { transform: scale(1); }
}

@keyframes drawCheck {
  to { stroke-dashoffset: 0; }
}
```

### 7.2 Error Shake

```css
.shake {
  animation: shake 0.4s ease-out;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  20% { transform: translateX(-8px); }
  40% { transform: translateX(8px); }
  60% { transform: translateX(-4px); }
  80% { transform: translateX(4px); }
}
```

### 7.3 Pulse Attention

```css
.pulse {
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.05); opacity: 0.8; }
}
```

---

## 8. Accessibility

### 8.1 Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### 8.2 Focus Indicators

```css
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
  transition: outline-offset 0.15s ease-out;
}
```

### 8.3 Screen Reader Announcements

```html
<div aria-live="polite" class="sr-only" id="announcer"></div>
```

```javascript
function announce(message) {
  document.getElementById('announcer').textContent = message;
}
```

---

## 9. Performance

### 9.1 Animation Budget

- Maximum 2-3 simultaneous animations
- Total interaction duration < 500ms
- Avoid animating during scroll
- Test on low-end devices

### 9.2 Performance Checklist

- [ ] Use `transform` and `opacity` primarily
- [ ] Avoid layout-triggering properties
- [ ] Test at 4x slowdown in DevTools
- [ ] Profile on mobile devices
- [ ] Respect `prefers-reduced-motion`

---

## 10. Implementation Checklist

- [ ] All interactive elements have feedback states
- [ ] Transitions use 150-300ms duration
- [ ] Easing matches interaction type
- [ ] Loading states for async operations
- [ ] Reduced motion alternative exists
- [ ] Focus indicators visible
- [ ] Animations serve purpose
- [ ] Performance tested on mobile

---

*Version: 0.1.0*
*Last updated: 2026-01-29*
