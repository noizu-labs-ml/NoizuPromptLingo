# Accessibility Audit Guide

> Comprehensive accessibility testing procedures combining automated tools with manual evaluation to ensure WCAG 2.1 AA compliance.

---

## 1. Audit Overview

### 1.1 Compliance Levels

| Level | Description | Requirement |
|-------|-------------|-------------|
| **WCAG A** | Minimum accessibility | Required |
| **WCAG AA** | Standard accessibility | Required |
| **WCAG AAA** | Enhanced accessibility | Recommended where feasible |

### 1.2 POUR Principles

All WCAG criteria fall under four principles:

| Principle | Meaning | Examples |
|-----------|---------|----------|
| **Perceivable** | Users can perceive content | Alt text, captions, contrast |
| **Operable** | Users can interact | Keyboard access, timing, navigation |
| **Understandable** | Users can comprehend | Readable, predictable, error help |
| **Robust** | Works with assistive tech | Valid code, ARIA, compatibility |

---

## 2. Automated Testing

### 2.1 Tools to Use

| Tool | Purpose | Coverage |
|------|---------|----------|
| **Axe DevTools** | Browser testing | ~30% of issues |
| **WAVE** | Visual feedback | ~25% of issues |
| **Lighthouse** | Performance + a11y | ~20% of issues |
| **Pa11y** | CI integration | ~25% of issues |

**Important:** Automated tools catch only 30-40% of accessibility issues. Manual testing is essential.

### 2.2 Running Automated Tests

```bash
# Axe CLI
npx @axe-core/cli https://example.com --tags wcag2aa

# Pa11y
npx pa11y https://example.com --standard WCAG2AA

# Lighthouse
lighthouse https://example.com --only-categories=accessibility
```

### 2.3 Interpreting Results

**Axe Severity Mapping:**

| Severity | WCAG Impact | Action |
|----------|-------------|--------|
| Critical | Blocks access | Fix immediately |
| Serious | Major barrier | Fix before launch |
| Moderate | Significant issue | Fix in current sprint |
| Minor | Enhancement | Add to backlog |

---

## 3. Manual Testing Checklist

### 3.1 Keyboard Navigation

Test all interactive elements without a mouse:

```markdown
## Keyboard Navigation Checklist

**Focus Management**
- [ ] All interactive elements are focusable (Tab key)
- [ ] Focus order is logical (left-to-right, top-to-bottom)
- [ ] Focus indicator is always visible
- [ ] No keyboard traps (can Tab away from any element)
- [ ] Skip link works (first Tab stop, links to main content)

**Keyboard Interactions**
- [ ] Buttons activate with Enter and Space
- [ ] Links activate with Enter
- [ ] Checkboxes toggle with Space
- [ ] Radio buttons navigate with Arrow keys
- [ ] Dropdown menus open with Enter/Space/Arrow
- [ ] Modals trap focus when open
- [ ] Modals close with Escape

**Focus Visibility**
- [ ] Focus ring is visible (minimum 2px)
- [ ] Focus ring has sufficient contrast
- [ ] Focus works on all backgrounds
- [ ] Custom focus styles match design

**Test Process:**
1. Start at browser address bar
2. Press Tab repeatedly through page
3. Ensure every interactive element receives focus
4. Verify focus order matches visual order
5. Test all interactions without mouse
```

### 3.2 Screen Reader Testing

**Recommended Screen Readers:**

| Platform | Screen Reader | Browser |
|----------|--------------|---------|
| Windows | NVDA (free) | Chrome/Firefox |
| Windows | JAWS | Chrome/Edge |
| macOS | VoiceOver | Safari |
| iOS | VoiceOver | Safari |
| Android | TalkBack | Chrome |

**Testing Checklist:**

```markdown
## Screen Reader Checklist

**Page Structure**
- [ ] Page has one <main> landmark
- [ ] Headings are hierarchical (h1 → h2 → h3)
- [ ] No skipped heading levels
- [ ] Landmark regions are identified
- [ ] Page title is descriptive

**Images**
- [ ] Decorative images have empty alt (alt="")
- [ ] Informative images have descriptive alt
- [ ] Complex images have extended descriptions
- [ ] Icons with meaning have accessible names

**Forms**
- [ ] All inputs have associated labels
- [ ] Required fields are indicated (not just by color)
- [ ] Error messages are announced
- [ ] Form instructions are clear
- [ ] Fieldsets group related inputs

**Links and Buttons**
- [ ] Link text is descriptive (no "click here")
- [ ] Button text indicates action
- [ ] New window/tab links are indicated
- [ ] Links are distinguishable from text

**Dynamic Content**
- [ ] Loading states are announced
- [ ] Error messages are announced
- [ ] Success messages are announced
- [ ] Live regions work appropriately
- [ ] Modal content is announced when opened

**Test Process:**
1. Turn on screen reader
2. Navigate by headings (H key)
3. Navigate by landmarks (D key in NVDA)
4. Navigate through forms (F key)
5. Test all interactive components
```

### 3.3 Visual Testing

```markdown
## Visual Accessibility Checklist

**Color Contrast**
- [ ] Normal text: 4.5:1 minimum
- [ ] Large text (18px+ bold or 24px+): 3:1 minimum
- [ ] UI components: 3:1 minimum
- [ ] Focus indicators: 3:1 minimum

**Color Independence**
- [ ] Information not conveyed by color alone
- [ ] Links distinguishable without color (underline)
- [ ] Errors indicated beyond red color
- [ ] Charts/graphs have patterns, not just colors

**Text Readability**
- [ ] Body text 16px minimum
- [ ] Line height 1.5 minimum for body
- [ ] Paragraph width max ~80 characters
- [ ] Text can resize to 200% without loss

**Motion and Animation**
- [ ] No content flashes >3 times per second
- [ ] Animations respect prefers-reduced-motion
- [ ] Autoplay can be paused
- [ ] Carousels have controls

**Tools:**
- Contrast checker: WebAIM Contrast Checker
- Color blindness: Stark or Sim Daltonism
- Text resize: Browser zoom to 200%
```

### 3.4 Cognitive Accessibility

```markdown
## Cognitive Accessibility Checklist

**Clear Language**
- [ ] Instructions are simple and clear
- [ ] Jargon is explained or avoided
- [ ] Error messages explain how to fix
- [ ] Success messages confirm action

**Consistent Design**
- [ ] Navigation is consistent across pages
- [ ] Similar elements look similar
- [ ] Patterns are predictable
- [ ] No unexpected changes

**Error Prevention**
- [ ] Destructive actions require confirmation
- [ ] Forms validate before submission
- [ ] Undo is available where possible
- [ ] Important data can be reviewed before submit

**Memory and Attention**
- [ ] Steps in process are numbered
- [ ] Progress is indicated
- [ ] Important info stays visible
- [ ] Timeouts are generous or adjustable
```

---

## 4. Testing by Component

### 4.1 Forms

```markdown
## Form Accessibility Audit

**Labels**
- [ ] Every input has visible label
- [ ] Labels are associated: <label for="id">
- [ ] Placeholder is not sole label
- [ ] Labels describe the expected input

**Required Fields**
- [ ] Required fields marked with * or "required"
- [ ] Required indicator explained
- [ ] aria-required="true" on required inputs
- [ ] Not indicated by color alone

**Validation**
- [ ] Inline validation has aria-live
- [ ] Error messages identify the field
- [ ] Error messages explain how to fix
- [ ] Focus moves to first error on submit
- [ ] Errors use aria-describedby

**Fieldsets**
- [ ] Related fields grouped in <fieldset>
- [ ] Fieldset has <legend>
- [ ] Radio/checkbox groups use fieldset

**Test Code:**
```html
<!-- Good form field -->
<div class="form-group">
  <label for="email">Email address <span aria-hidden="true">*</span></label>
  <input 
    type="email" 
    id="email" 
    name="email"
    aria-required="true"
    aria-describedby="email-error"
  />
  <span id="email-error" role="alert" class="error">
    Please enter a valid email address
  </span>
</div>
```
```

### 4.2 Navigation

```markdown
## Navigation Accessibility Audit

**Skip Link**
- [ ] Skip link is first focusable element
- [ ] Skip link visible on focus
- [ ] Links to main content
- [ ] Works in all browsers

**Main Navigation**
- [ ] Uses <nav> element
- [ ] Has aria-label if multiple navs
- [ ] Current page indicated (aria-current="page")
- [ ] Dropdown menus keyboard accessible

**Breadcrumbs**
- [ ] Uses <nav> with aria-label="Breadcrumb"
- [ ] Uses <ol> for ordered structure
- [ ] Current page not linked
- [ ] Separator is decorative (aria-hidden)

**Pagination**
- [ ] Uses <nav> with aria-label="Pagination"
- [ ] Current page indicated
- [ ] Previous/Next have clear labels
- [ ] Page numbers are links

**Test Code:**
```html
<!-- Skip link -->
<a href="#main" class="skip-link">Skip to main content</a>

<!-- Navigation -->
<nav aria-label="Main">
  <ul>
    <li><a href="/" aria-current="page">Home</a></li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>

<!-- Main content target -->
<main id="main" tabindex="-1">
```
```

### 4.3 Modals/Dialogs

```markdown
## Modal Accessibility Audit

**Structure**
- [ ] Uses role="dialog" or <dialog>
- [ ] Has aria-labelledby pointing to title
- [ ] Has aria-describedby if description exists
- [ ] aria-modal="true" when open

**Focus Management**
- [ ] Focus moves to modal when opened
- [ ] Focus trapped inside modal
- [ ] Focus returns to trigger when closed
- [ ] First focusable element or modal itself focused

**Keyboard**
- [ ] Escape closes modal
- [ ] Tab cycles through modal content
- [ ] Close button is keyboard accessible

**Background**
- [ ] Background content has aria-hidden="true"
- [ ] Background content is inert (if supported)
- [ ] Scroll locked on body

**Test Code:**
```html
<div 
  role="dialog" 
  aria-modal="true"
  aria-labelledby="modal-title"
  aria-describedby="modal-desc"
>
  <h2 id="modal-title">Confirm deletion</h2>
  <p id="modal-desc">This action cannot be undone.</p>
  <button>Cancel</button>
  <button>Delete</button>
</div>
```
```

### 4.4 Tabs

```markdown
## Tabs Accessibility Audit

**Structure**
- [ ] Tab list has role="tablist"
- [ ] Tabs have role="tab"
- [ ] Panels have role="tabpanel"
- [ ] Tabs linked to panels with aria-controls

**State**
- [ ] Active tab has aria-selected="true"
- [ ] Inactive tabs have aria-selected="false"
- [ ] Hidden panels have hidden attribute

**Keyboard**
- [ ] Arrow keys move between tabs
- [ ] Tab key moves to panel content
- [ ] Home/End move to first/last tab
- [ ] Activation on arrow or on Enter/Space

**Test Code:**
```html
<div role="tablist" aria-label="Settings">
  <button 
    role="tab" 
    id="tab-1" 
    aria-selected="true" 
    aria-controls="panel-1"
  >
    Account
  </button>
  <button 
    role="tab" 
    id="tab-2" 
    aria-selected="false" 
    aria-controls="panel-2" 
    tabindex="-1"
  >
    Security
  </button>
</div>
<div 
  role="tabpanel" 
  id="panel-1" 
  aria-labelledby="tab-1"
>
  Panel content...
</div>
```
```

---

## 5. Audit Report Template

```markdown
# Accessibility Audit Report

**Project:** [Name]
**URL:** [URL]
**Date:** [Date]
**Auditor:** [Name]
**Standard:** WCAG 2.1 AA

## Executive Summary

**Overall Score:** [X/100]
**Compliance Level:** [Compliant / Partially Compliant / Non-Compliant]

| Category | Issues | Critical | Serious | Moderate |
|----------|--------|----------|---------|----------|
| Perceivable | X | X | X | X |
| Operable | X | X | X | X |
| Understandable | X | X | X | X |
| Robust | X | X | X | X |
| **Total** | **X** | **X** | **X** | **X** |

## Critical Issues (Must Fix)

### Issue 1: [Title]
- **WCAG Criterion:** [e.g., 1.4.3 Contrast]
- **Location:** [Page/Component]
- **Description:** [What's wrong]
- **Impact:** [Who is affected, how]
- **Recommendation:** [How to fix]
- **Code Example:**
```html
<!-- Current -->
<div style="color: #999">Light gray text</div>

<!-- Recommended -->
<div style="color: #666">Darker gray text</div>
```

## Serious Issues (Fix Before Launch)

### Issue 2: [Title]
...

## Moderate Issues (Fix in Next Sprint)

### Issue 3: [Title]
...

## Testing Summary

### Automated Testing
| Tool | Issues Found |
|------|--------------|
| Axe | X |
| WAVE | X |
| Lighthouse | X% |

### Manual Testing
| Test | Pass/Fail |
|------|-----------|
| Keyboard navigation | ✓/✗ |
| Screen reader (NVDA) | ✓/✗ |
| Screen reader (VoiceOver) | ✓/✗ |
| Color contrast | ✓/✗ |
| Zoom to 200% | ✓/✗ |

## Recommendations

### Immediate Actions
1. [Action 1]
2. [Action 2]

### Training Needs
- [Training recommendation]

### Process Improvements
- [Process recommendation]
```

---

## 6. Common Issues & Fixes

### 6.1 Quick Reference

| Issue | WCAG | Fix |
|-------|------|-----|
| Missing alt text | 1.1.1 | Add descriptive alt or alt="" |
| Low contrast | 1.4.3 | Ensure 4.5:1 ratio |
| No focus indicator | 2.4.7 | Add visible focus styles |
| Missing form labels | 1.3.1, 3.3.2 | Associate label with for/id |
| Keyboard trap | 2.1.2 | Ensure Tab escapes all elements |
| No skip link | 2.4.1 | Add skip link to main content |
| Non-descriptive links | 2.4.4 | Use meaningful link text |
| Missing page title | 2.4.2 | Add unique, descriptive title |
| No heading structure | 1.3.1 | Use proper heading hierarchy |
| Auto-playing media | 1.4.2 | Add pause control |

---

## References

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM Checklist](https://webaim.org/standards/wcag/checklist)
- `automated-checks.md` - Automated testing configuration
- `PATTERNS/accessibility.md` - Accessible design patterns

---

*Version: 0.1.0*
