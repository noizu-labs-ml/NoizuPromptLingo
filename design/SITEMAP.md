# derobot.is — Site Map

> Corporate landing page for an AI-native venture lab that incubates, validates, and scales digital products under the "therobot" brand family.

**Domain:** derobot.is
**Status:** draft
**Last updated:** 2026-03-25

---

## Page Flow

```mermaid
graph LR
    ROOT["/ Layout"]
    ROOT -->|data-design-theme| HOME["/"]
    ROOT -->|data-design-theme| PORT["/portfolio"]
    ROOT -->|data-design-theme| PROD["/portfolio/[domain]"]
    ROOT -->|data-design-theme| PROC["/process"]
    ROOT -->|data-design-theme| ABOUT["/about"]
    ROOT -->|data-design-theme| CONTACT["/contact"]
    ROOT -->|data-design-theme| SG["/styleguide"]
    ROOT -->|data-design-theme| SM["/sitemap"]
    HOME -->|CTA| PORT
    HOME -->|CTA| CONTACT
    HOME -->|nav| PROC
    HOME -->|nav| ABOUT
    PORT -->|card click| PROD
    PROD -->|external| EXT["product domain ↗"]
    HOME -->|footer| SG
    HOME -->|footer| SM
```

---

## / — Landing Page

Primary entry point. Converts three audiences — potential users, collaborators, and investors — by communicating portfolio breadth, operational methodology, and credibility. Single-page scroll with distinct sections. Portfolio grid is a teaser (top 6); full grid lives at `/portfolio`.

```mermaid
graph TD
    PAGE["/ Landing Page"]
    PAGE --> HERO["Hero Section\nh1 brand + tagline\n'AI-native venture lab'"]
    HERO --> HERO_CTA["button-row\nExplore Portfolio primary → /portfolio\nGet in Touch outline → /contact"]
    PAGE --> PORTFOLIO["Portfolio Teaser Section\n#portfolio"]
    PORTFOLIO --> CARDS["ProductCard × 6\nfeatured products across categories"]
    CARDS --> VIEW_ALL["View All → /portfolio"]
    PAGE --> PROCESS["Process Teaser Section\n#process"]
    PROCESS --> PIPELINE["PipelineViz\nConcept → Validate → Build → Scale"]
    PROCESS --> LEARN_MORE["Learn More → /process"]
    PAGE --> ABOUT_TEASER["About Teaser\n#about"]
    ABOUT_TEASER --> ABOUT_LINK["Read More → /about"]
    PAGE --> CONTACT_TEASER["Contact Teaser\n#contact"]
    CONTACT_TEASER --> CONTACT_LINK["Get in Touch → /contact"]
    PAGE --> FOOTER["Footer"]
    FOOTER --> FOOTER_LINKS["Nav: /portfolio /process /about /contact\nMeta: /styleguide /sitemap"]
```

**Data:**
- Portfolio cards: build-time generation from `projects/*/README.md` (name, domain, category, one-liner)
- All other content: static

---

## /portfolio — Portfolio

Full portfolio grid with all products, grouped by category. Filterable by category. Each card links to `/portfolio/[domain]`.

```mermaid
graph TD
    PAGE["/portfolio"]
    PAGE --> HEADER["Page Header\nh1 'The Portfolio'\nsubtitle: product count + category count"]
    PAGE --> FILTERS["CategoryFilter\nAll | Gaming | Dev Tools | Social | Infrastructure | Security"]
    PAGE --> GRID["Portfolio Grid\nbento layout, 3-col desktop"]
    GRID --> CAT_GAMING["Category: Gaming"]
    CAT_GAMING --> G1["ProductCard\nBlade of Eternity"]
    CAT_GAMING --> G2["ProductCard\nNoizuRPG"]
    CAT_GAMING --> G3["ProductCard\nAI Fighter"]
    GRID --> CAT_DEVTOOLS["Category: Dev Tools"]
    CAT_DEVTOOLS --> D1["ProductCard\nCodeFre.sh"]
    CAT_DEVTOOLS --> D2["ProductCard\nTheRobotMakes"]
    GRID --> CAT_SOCIAL["Category: Social / Knowledge"]
    CAT_SOCIAL --> S1["ProductCard\nTheRobotLives"]
    CAT_SOCIAL --> S2["ProductCard\nTheRobotKnows"]
    CAT_SOCIAL --> S3["ProductCard\nGotta.cc"]
    GRID --> CAT_INFRA["Category: Infrastructure"]
    CAT_INFRA --> I1["ProductCard\nIoTGo"]
    CAT_INFRA --> I2["ProductCard\nRobots-Unite"]
    GRID --> CAT_SECURITY["Category: Security"]
    CAT_SECURITY --> SEC1["ProductCard\nJailbreakingSite"]
```

**Data:**
- Build-time from `projects/*/README.md` (name, domain, category, one-liner, status)
- Category list derived from product data

---

## /portfolio/[domain] — Product Detail

Per-product page generated from the project's README.md at build time. Gives each product a home on derobot.is until it has its own live site.

```mermaid
graph TD
    PAGE["/portfolio/[domain]"]
    PAGE --> BACK["← Back to Portfolio"]
    PAGE --> HEADER["Product Header\nh1 product name\ncategory tag + domain link"]
    PAGE --> PITCH["Elevator Pitch\nfrom README §Elevator Pitch"]
    PAGE --> PROBLEM["Problem Section\nfrom README §Problem"]
    PAGE --> SOLUTION["Solution Section\nfrom README §Solution"]
    PAGE --> STATUS["Status Badge\nConcept | Validation | Building | Live"]
    PAGE --> TECH["Technical Direction\nfrom README §Technical Considerations"]
    PAGE --> CTA["CTA row\nVisit Domain ↗ (if live)\nBack to Portfolio → /portfolio"]
```

**Data:**
- Build-time from `projects/[domain]/README.md` — parsed sections
- Status from README §Status
- Dynamic route: `generateStaticParams()` from project directory listing

---

## /process — Methodology

Deep-dive into the venture lab operating model. Explains the pipeline stages, validation methodology, and decision framework. The landing page teases this; this page explains it seriously.

```mermaid
graph TD
    PAGE["/process"]
    PAGE --> HEADER["Page Header\nh1 'The Process'\nsubtitle: 'How we validate before we build'"]
    PAGE --> INTRO["Intro Block\noperating model narrative"]
    PAGE --> STAGES["Pipeline Stages (expanded)"]
    STAGES --> S1["Stage: Concept\nwhat happens, duration, artifacts"]
    STAGES --> S2["Stage: Validate\nlanding page + ads + KPIs"]
    STAGES --> S3["Stage: Build\nfull product, real users"]
    STAGES --> S4["Stage: Scale\nrevenue, growth"]
    STAGES --> S5["Stage: Spinoff\nown legal entity"]
    PAGE --> PRINCIPLES["Decision Principles\n'The robots build. The robots share.'\nkill criteria, pivot triggers"]
    PAGE --> CTA["CTA\nSee the Portfolio → /portfolio\nGet in Touch → /contact"]
```

**Data:** Static content

---

## /about — About

Team, entity status, location, values. Answers "Who's behind this?"

```mermaid
graph TD
    PAGE["/about"]
    PAGE --> HEADER["Page Header\nh1 'About derobot.is'"]
    PAGE --> STORY["Origin Story\nwhy this exists, the thesis"]
    PAGE --> ENTITY["Entity Status\n'Based in the Netherlands'\npending BV registration"]
    PAGE --> BRAND["Brand Architecture\nthe therobot naming pattern\nproduct independence"]
    PAGE --> VALUES["Values / Principles\ndirect, data-driven, ship fast"]
    PAGE --> CTA["CTA\nWork With Us → /contact"]
```

**Data:** Static content

---

## /contact — Contact

Dedicated contact page with form. More prominent and linkable than the scroll anchor on `/`.

```mermaid
graph TD
    PAGE["/contact"]
    PAGE --> HEADER["Page Header\nh1 'Get in Touch'"]
    PAGE --> AUDIENCES["Audience Cards\n3 cards: Users | Collaborators | Investors\neach with what to expect"]
    PAGE --> FORM["ContactForm\nname + email + role select + message\nsubmit → backend API or mailto fallback"]
    PAGE --> ALT["Alternative Contact\nemail link, optional Calendly embed"]
```

**Data:**
- Form submission: backend API `/api/contact` or mailto fallback
- Role select: User, Collaborator, Investor, Press, Other

---

## /styleguide — Style Guide

Interactive style guide viewer. Showcases the Nocturne (80%) + Bold Expressive (20%) design system for derobot.is.

```mermaid
graph TD
    PAGE["/styleguide"]
    PAGE --> PROVIDER["ThemeConfigProvider\nloads derobot.is theme YAML"]
    PAGE --> SECTIONS["ThemeAwareSections\ndynamic showcase sections"]
    SECTIONS --> COLORS["ColorShowcase\npalette swatches"]
    SECTIONS --> TYPE["TypographyShowcase\nSyne / Geist / JetBrains Mono"]
    SECTIONS --> SPACING["SpacingShowcase\n8px grid system"]
    SECTIONS --> COMPONENTS["ComponentShowcase\nbuttons, cards, forms"]
```

**Data:** Theme YAML config from `theme-style-guide/`

---

## /sitemap — Site Architecture

Documents the information architecture of derobot.is. Renders the content of this SITEMAP.md as an interactive page with mermaid diagrams.

```mermaid
graph TD
    PAGE["/sitemap"]
    PAGE --> FLOW["Page Flow Diagram\nmermaid graph LR"]
    PAGE --> PAGEDEFS["Per-Page Component Trees\nmermaid graph TD per section"]
    PAGE --> INVENTORY["Page Inventory Table\nspec-table"]
```

**Data:** Generated from this document + `loadPageSections()` + `listThemes()`

---

## Page Inventory

| Route | Purpose | Key Components | Data Sources |
|-------|---------|----------------|--------------|
| `/` | Landing — hero, portfolio teaser, process teaser, about teaser, contact teaser | ProductCard, PipelineViz, Footer | Build-time from project READMEs (static) |
| `/portfolio` | Full portfolio grid with category filtering | ProductCard, CategoryFilter | Build-time from project READMEs |
| `/portfolio/[domain]` | Per-product detail page | ProductHeader, StatusBadge, SectionRenderer | Build-time from individual project README |
| `/process` | Methodology deep-dive — pipeline stages and decision framework | PipelineStage, PrinciplesBlock | Static |
| `/about` | Team, entity, values, brand architecture | EntityStatus, BrandArchitecture | Static |
| `/contact` | Contact form with audience routing | ContactForm, AudienceCards | API: /api/contact or mailto |
| `/styleguide` | Interactive design system viewer | ThemeConfigProvider, ThemeAwareSections | Theme YAML |
| `/sitemap` | Site architecture documentation | mermaid.js, spec-table | This document, config, sections |

---

## Navigation

### Primary Nav (top bar)
- Portfolio → `/portfolio`
- Process → `/process`
- About → `/about`
- Contact → `/contact`

### Footer Nav
- All primary nav links
- Style Guide → `/styleguide`
- Site Map → `/sitemap`
- Product domains → external links (when live)

### Auth Gates
- None — all routes are public
