# Sitemap Markdown Output

> Defines the information architecture of a project as a structured markdown file. Created during the design (md) stage, before any code is written. Used as the spec to populate the starter app's `/sitemap/page.tsx` during implementation.

---

## 1. Overview

The sitemap markdown is a **design artifact** — it lives alongside style guides and wireframes in a project's `design/` directory. It documents:

- Every page/route in the application
- The navigation flow between pages
- The component hierarchy within each page
- The purpose and key components of each route

It is the **single source of truth** for information architecture during the design phase. When implementation begins, the starter app's `/sitemap/page.tsx` is populated directly from this document.

---

## 2. File Location

```
projects/{domain}/
  design/
    SITEMAP.md          ← this file
    style-guide.md      ← visual design
    theme/              ← YAML config
```

---

## 3. Document Structure

A sitemap markdown has 4 required sections and 1 optional section:

### 3.1 Header

```markdown
# {Project Name} — Site Map

> {One-line description of the application}

**Domain:** {domain}
**Status:** {draft | review | approved | implemented}
**Last updated:** {YYYY-MM-DD}
```

### 3.2 Page Flow Diagram (required)

A top-level mermaid `graph LR` showing all routes and their relationships:

```markdown
## Page Flow

\`\`\`mermaid
graph LR
    ROOT["/ Layout"]
    ROOT -->|data-design-theme| HOME["/"]
    ROOT -->|data-design-theme| SG["/styleguide"]
    ROOT -->|data-design-theme| SM["/sitemap"]
    ROOT -->|data-design-theme| DASH["/dashboard"]
    ROOT -->|data-design-theme| SETTINGS["/settings"]
    HOME -->|CTA| DASH
    DASH -->|nav| SETTINGS
\`\`\`
```

**Rules:**
- Every route gets a node
- Show navigation relationships (not just hierarchy)
- Label edges with the navigation mechanism (`CTA`, `nav`, `link`, `redirect`, `auth-guard`)
- The root layout node shows the `data-design-theme` cascade
- Group related routes visually

### 3.3 Page Definitions (required)

One section per page, each containing:

1. **A mermaid `graph TD`** showing the component hierarchy
2. **A description** of the page's purpose
3. **Key data** the page needs (props, API calls, config)

```markdown
## / — Home Page

Landing page and primary entry point. Converts visitors to users.

\`\`\`mermaid
graph TD
    PAGE["/ Home Page"]
    PAGE --> HERO["sg-page-title\nh1 + sg-page-intro"]
    PAGE --> CTA["button-row\nStyleGuideBtn primary → /dashboard\nStyleGuideBtn outline → /styleguide"]
    PAGE --> CARDS["StyleGuideCardGrid"]
    CARDS --> C1["StyleGuideCard\nFeature 1"]
    CARDS --> C2["StyleGuideCard\nFeature 2"]
    CARDS --> C3["StyleGuideCard\nFeature 3"]
\`\`\`

**Data:** Static content, no API calls.
```

**Rules for component tree diagrams:**
- Node format: `ID["ComponentName\ndescription or content"]`
- Show nesting via arrows (`-->`)
- Name the actual component being used (from `@noizu/styleguide` or custom)
- Include the content/purpose on the second line of the node label
- Show navigation targets in CTA nodes (`→ /route`)

### 3.4 Page Inventory Table (required)

A summary table of all routes:

```markdown
## Page Inventory

| Route | Purpose | Key Components | Data Sources |
|-------|---------|----------------|--------------|
| `/` | Landing page | StyleGuideBtn, StyleGuideCardGrid | Static |
| `/styleguide` | Design system viewer | ThemeConfigProvider, ThemeAwareSections | Theme YAML |
| `/sitemap` | Site architecture | mermaid.js, spec-table | Config, sections |
| `/dashboard` | User dashboard | ShellChrome, MetricCards | API: /metrics |
| `/settings` | User settings | ShellChrome, FormsShowcase | API: /user |
```

**Columns:**
- **Route** — the URL path
- **Purpose** — one-line description
- **Key Components** — primary components used (from styleguide package or custom)
- **Data Sources** — where the page gets its data (static, theme YAML, API endpoints)

### 3.5 Navigation Model (optional)

For apps with complex navigation, document the nav structure:

```markdown
## Navigation

### Primary Nav (navbar)
- Home → `/`
- Dashboard → `/dashboard`
- Settings → `/settings`

### Secondary Nav (sidebar, only on /dashboard)
- Overview → `/dashboard`
- Analytics → `/dashboard/analytics`
- Reports → `/dashboard/reports`

### Auth Gates
- `/dashboard/*` — requires authenticated session
- `/settings` — requires authenticated session
- `/`, `/styleguide`, `/sitemap` — public
```

---

## 4. Starter Pages

Every project using the styleguide-starter begins with 3 pages. The sitemap markdown must include these as the baseline:

| Route | Purpose | Always Present |
|-------|---------|----------------|
| `/` | Landing / home page | YES |
| `/styleguide` | Interactive style guide viewer | YES |
| `/sitemap` | Site architecture documentation | YES |

New pages are added to the sitemap before they are implemented. The sitemap grows as the design evolves.

---

## 5. From Sitemap Markdown to TSX

When moving from design to implementation, the sitemap markdown populates the starter app's `/sitemap/page.tsx`:

### 5.1 Mapping

| Sitemap Markdown Section | TSX Output |
|---|---|
| Page Flow diagram | Top-level mermaid `<pre className="mermaid">` block |
| Per-page component trees | Individual mermaid `<pre>` blocks per `<section>` |
| Page Inventory table | `<table className="spec-table">` |
| Navigation model | Informs `ShellChrome` config and nav component props |

### 5.2 Translation Process

1. **Copy mermaid diagrams** — each `graph` block becomes a `<pre className="mermaid">` in the TSX
2. **Build the inventory table** — each row in the markdown table becomes a `<tr>` in the spec-table
3. **Add style guide sections** — the TSX dynamically loads these from `loadPageSections()` (no manual translation needed)
4. **Add theme list** — the TSX dynamically loads from `listThemes()` (no manual translation needed)

### 5.3 Example: translating a page definition

**Markdown:**
```markdown
## /dashboard — Dashboard

User's primary workspace after login.

\`\`\`mermaid
graph TD
    PAGE["/dashboard"]
    PAGE --> SHELL["ShellChrome\napp-shell layout"]
    PAGE --> HEADER["DashboardHeader\nuser + org context"]
    PAGE --> METRICS["StyleGuideCardGrid\n4 metric cards"]
\`\`\`

**Data:** API: `/api/metrics`, `/api/user`
```

**TSX:**
```tsx
<section className="sg-sitemap-section">
  <h2 className="sg-section-heading">/dashboard &mdash; Dashboard</h2>
  <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/dashboard"]
    PAGE --> SHELL["ShellChrome\napp-shell layout"]
    PAGE --> HEADER["DashboardHeader\nuser + org context"]
    PAGE --> METRICS["StyleGuideCardGrid\n4 metric cards"]`}</pre>
</section>
```

---

## 6. When to Create the Sitemap

The sitemap is created at the **wireframe stage** of the design workflow, after brief interpretation and style selection but before visual mockups:

```
Brief → Interpret → Select Style → [SITEMAP.md] → Wireframe → Grayscale → Color → Implement
```

It is updated whenever:
- A new page is proposed
- Page structure changes significantly
- Navigation flow changes
- Components are added or swapped

The sitemap is a **living document** during design. Its `Status` field tracks readiness:
- `draft` — actively being shaped
- `review` — ready for stakeholder review
- `approved` — locked for implementation
- `implemented` — TSX sitemap page matches this document

---

## 7. Validation Checklist

Before marking a sitemap as `approved`:

- [ ] Every route in the page flow diagram has a corresponding page definition section
- [ ] Every page definition has a component tree diagram
- [ ] Every page definition appears in the page inventory table
- [ ] Navigation relationships in the flow diagram match the navigation model
- [ ] Component names match actual components from `@noizu/styleguide` or are clearly marked as custom
- [ ] Data sources are identified for each page
- [ ] Auth gates are documented if the app has authentication
- [ ] The 3 starter pages (/, /styleguide, /sitemap) are present
