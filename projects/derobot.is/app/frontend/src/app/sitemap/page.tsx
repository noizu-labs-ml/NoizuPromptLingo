import { loadConfig, loadPageSections, listThemes } from "@the-robot-lives/styleguide/css-gen";
import { loadBranding } from "@the-robot-lives/styleguide/css-gen";
import Script from "next/script";

export default function SitemapPage() {
  const config = loadConfig();
  const branding = loadBranding();
  const themes = listThemes();
  const pageSections = loadPageSections();

  const sectionList = pageSections.flatMap((group) =>
    group.sections.map((s) => ({ group: group.group, ...s }))
  );

  return (
    <div className="content content--article">
      <main>
        <h1 className="sg-page-title">Site Map</h1>
        <p className="sg-page-meta">
          {branding.name} &mdash; {themes.length} theme{themes.length !== 1 ? "s" : ""} &middot; {sectionList.length} style guide sections
        </p>

        {/* ─── Page Flow ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">Page Flow</h2>
          <pre className="mermaid" suppressHydrationWarning>{`graph LR
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
    HOME -->|footer| SG
    HOME -->|footer| SM`}</pre>
        </section>

        {/* ─── / Landing Page ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/ &mdash; Landing Page</h2>
          <p>Primary entry point. Portfolio teaser (top 6), process teaser, about teaser, contact teaser. Full content lives on dedicated pages.</p>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/ Landing Page"]
    PAGE --> HERO["Hero Section\nh1 brand + tagline\n'AI-native venture lab'"]
    HERO --> HERO_CTA["button-row\nExplore Portfolio → /portfolio\nGet in Touch → /contact"]
    PAGE --> PORTFOLIO["Portfolio Teaser\n6 featured ProductCards"]
    PORTFOLIO --> VIEW_ALL["View All → /portfolio"]
    PAGE --> PROCESS["Process Teaser\nPipelineViz + Learn More → /process"]
    PAGE --> ABOUT_T["About Teaser → /about"]
    PAGE --> CONTACT_T["Contact Teaser → /contact"]
    PAGE --> FOOTER["Footer\nnav + meta links"]`}</pre>
        </section>

        {/* ─── /portfolio ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/portfolio &mdash; Portfolio</h2>
          <p>Full portfolio grid with all 11 products, grouped by category. Filterable. Each card links to /portfolio/[domain].</p>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/portfolio"]
    PAGE --> HEADER["Page Header\nh1 'The Portfolio'"]
    PAGE --> FILTERS["CategoryFilter\nAll | Gaming | Dev Tools | Social | Infrastructure | Security"]
    PAGE --> GRID["Portfolio Grid\nbento layout, 3-col desktop"]
    GRID --> CAT_GAMING["Gaming: 3 cards"]
    GRID --> CAT_DEVTOOLS["Dev Tools: 2 cards"]
    GRID --> CAT_SOCIAL["Social / Knowledge: 3 cards"]
    GRID --> CAT_INFRA["Infrastructure: 2 cards"]
    GRID --> CAT_SECURITY["Security: 1 card"]`}</pre>
        </section>

        {/* ─── /portfolio/[domain] ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/portfolio/[domain] &mdash; Product Detail</h2>
          <p>Per-product page generated from README.md at build time. Each product&apos;s home until it has its own live site.</p>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/portfolio/[domain]"]
    PAGE --> BACK["← Back to Portfolio"]
    PAGE --> HEADER["Product Header\nname + category + domain"]
    PAGE --> PITCH["Elevator Pitch"]
    PAGE --> PROBLEM["Problem Section"]
    PAGE --> SOLUTION["Solution Section"]
    PAGE --> STATUS["Status Badge\nConcept | Validation | Building | Live"]
    PAGE --> TECH["Technical Direction"]
    PAGE --> CTA["Visit Domain ↗ | Back to Portfolio"]`}</pre>
        </section>

        {/* ─── /process ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/process &mdash; Methodology</h2>
          <p>Deep-dive into the venture lab operating model. Pipeline stages, validation methodology, decision framework.</p>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/process"]
    PAGE --> HEADER["Page Header\n'The Process'"]
    PAGE --> INTRO["Operating Model narrative"]
    PAGE --> STAGES["Pipeline Stages"]
    STAGES --> S1["Concept\nartifacts + duration"]
    STAGES --> S2["Validate\nlanding page + ads + KPIs"]
    STAGES --> S3["Build\nfull product"]
    STAGES --> S4["Scale\nrevenue + growth"]
    STAGES --> S5["Spinoff\nown entity"]
    PAGE --> PRINCIPLES["Decision Principles\nkill criteria, pivot triggers"]
    PAGE --> CTA["Portfolio → /portfolio\nContact → /contact"]`}</pre>
        </section>

        {/* ─── /about ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/about &mdash; About</h2>
          <p>Team, entity status, location, values, brand architecture.</p>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/about"]
    PAGE --> STORY["Origin Story"]
    PAGE --> ENTITY["Entity Status\nNetherlands, pending BV"]
    PAGE --> BRAND["Brand Architecture\ntherobot naming pattern"]
    PAGE --> VALUES["Values / Principles"]
    PAGE --> CTA["Work With Us → /contact"]`}</pre>
        </section>

        {/* ─── /contact ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/contact &mdash; Contact</h2>
          <p>Dedicated contact page with audience routing and form.</p>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/contact"]
    PAGE --> AUDIENCES["Audience Cards\nUsers | Collaborators | Investors"]
    PAGE --> FORM["ContactForm\nname + email + role + message"]
    PAGE --> ALT["Alternative: email link\noptional Calendly"]`}</pre>
        </section>

        {/* ─── /styleguide ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/styleguide &mdash; Style Guide</h2>
          <p>Interactive Nocturne design system viewer.</p>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/styleguide"]
    PAGE --> PROVIDER["ThemeConfigProvider\nloads derobot.is theme YAML"]
    PAGE --> SECTIONS["ThemeAwareSections"]
    SECTIONS --> COLORS["ColorShowcase"]
    SECTIONS --> TYPE["TypographyShowcase"]
    SECTIONS --> SPACING["SpacingShowcase"]
    SECTIONS --> COMPONENTS["ComponentShowcase"]`}</pre>
        </section>

        {/* ─── /sitemap ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/sitemap &mdash; Site Architecture</h2>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/sitemap"]
    PAGE --> FLOW["Page Flow Diagram"]
    PAGE --> PAGEDEFS["Per-Page Component Trees"]
    PAGE --> INVENTORY["Page Inventory Table"]`}</pre>
        </section>

        {/* ─── Page Inventory ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">Page Inventory</h2>
          <table className="spec-table">
            <thead>
              <tr>
                <th>Route</th>
                <th>Purpose</th>
                <th>Key Components</th>
                <th>Data Sources</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><a href="/">/</a></td>
                <td>Landing &mdash; hero, portfolio teaser, process teaser</td>
                <td>ProductCard, PipelineViz, Footer</td>
                <td>Build-time from project READMEs</td>
              </tr>
              <tr>
                <td><a href="/portfolio">/portfolio</a></td>
                <td>Full portfolio grid with category filtering</td>
                <td>ProductCard, CategoryFilter</td>
                <td>Build-time from project READMEs</td>
              </tr>
              <tr>
                <td>/portfolio/[domain]</td>
                <td>Per-product detail page</td>
                <td>ProductHeader, StatusBadge, SectionRenderer</td>
                <td>Build-time from individual README</td>
              </tr>
              <tr>
                <td><a href="/process">/process</a></td>
                <td>Methodology &mdash; pipeline stages + decision framework</td>
                <td>PipelineStage, PrinciplesBlock</td>
                <td>Static</td>
              </tr>
              <tr>
                <td><a href="/about">/about</a></td>
                <td>Team, entity, values, brand architecture</td>
                <td>EntityStatus, BrandArchitecture</td>
                <td>Static</td>
              </tr>
              <tr>
                <td><a href="/contact">/contact</a></td>
                <td>Contact form with audience routing</td>
                <td>ContactForm, AudienceCards</td>
                <td>API: /api/contact or mailto</td>
              </tr>
              <tr>
                <td><a href="/styleguide">/styleguide</a></td>
                <td>Interactive design system viewer</td>
                <td>ThemeConfigProvider, ThemeAwareSections</td>
                <td>Theme YAML</td>
              </tr>
              <tr>
                <td><a href="/sitemap">/sitemap</a></td>
                <td>Site architecture documentation</td>
                <td>mermaid.js, spec-table</td>
                <td>This document, config, sections</td>
              </tr>
            </tbody>
          </table>
        </section>

        {/* ─── Navigation ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">Navigation</h2>
          <h3 className="sg-sitemap-group-title">Primary Nav (top bar)</h3>
          <ul className="sg-sitemap-list">
            <li className="sg-sitemap-item">Portfolio &rarr; <a href="/portfolio">/portfolio</a></li>
            <li className="sg-sitemap-item">Process &rarr; <a href="/process">/process</a></li>
            <li className="sg-sitemap-item">About &rarr; <a href="/about">/about</a></li>
            <li className="sg-sitemap-item">Contact &rarr; <a href="/contact">/contact</a></li>
          </ul>
          <h3 className="sg-sitemap-group-title">Footer Nav</h3>
          <ul className="sg-sitemap-list">
            <li className="sg-sitemap-item">All primary nav links</li>
            <li className="sg-sitemap-item">Style Guide &rarr; <a href="/styleguide">/styleguide</a></li>
            <li className="sg-sitemap-item">Site Map &rarr; <a href="/sitemap">/sitemap</a></li>
            <li className="sg-sitemap-item">Product domains &rarr; external links (when live)</li>
          </ul>
          <h3 className="sg-sitemap-group-title">Auth Gates</h3>
          <ul className="sg-sitemap-list">
            <li className="sg-sitemap-item">None &mdash; all routes are public</li>
          </ul>
        </section>

        {/* ─── Style Guide Sections ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">Style Guide Sections</h2>
          {pageSections.map((group) => (
            <div key={group.group} className="sg-sitemap-group">
              <h3 className="sg-sitemap-group-title">{group.group}</h3>
              <ul className="sg-sitemap-list">
                {group.sections.map((s) => (
                  <li key={s.id} className="sg-sitemap-item">
                    <strong>{s.title}</strong>
                    <span className="sg-sitemap-item-id">#{s.id}</span>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </section>

        {/* ─── Themes ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">Themes</h2>
          <ul className="sg-sitemap-list">
            {themes.map((t) => (
              <li key={t.slug} className={`sg-sitemap-item ${t.slug === config.slug ? "sg-sitemap-item--active" : ""}`}>
                <strong>{t.name}</strong>
                <span className="sg-sitemap-item-id">{t.slug}</span>
                {t.slug === config.slug && <span className="sg-sitemap-item-badge">(active)</span>}
              </li>
            ))}
          </ul>
        </section>
      </main>
      <Script id="mermaid-loader" strategy="afterInteractive">{`
        var s = document.createElement('script');
        s.src = 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js';
        s.onload = function() {
          mermaid.initialize({ startOnLoad: false, theme: 'neutral' });
          mermaid.run();
        };
        document.head.appendChild(s);
      `}</Script>
    </div>
  );
}
