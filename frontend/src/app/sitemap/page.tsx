import { loadConfig, loadPageSections, listThemes } from "@noizu/styleguide/css-gen";
import { loadBranding } from "@noizu/styleguide/css-gen";
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
    ROOT -->|data-design-theme| SG["/styleguide"]
    ROOT -->|data-design-theme| SM["/sitemap"]`}</pre>
        </section>

        {/* ─── / Home Page ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/ &mdash; Home Page</h2>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/ Home Page"]
    PAGE --> HERO["sg-page-title\nh1 + sg-page-intro"]
    PAGE --> CTA["button-row\nStyleGuideBtn primary\nStyleGuideBtn outline"]
    PAGE --> CARDS["StyleGuideCardGrid"]
    CARDS --> C1["StyleGuideCard\nDesign Tokens"]
    CARDS --> C2["StyleGuideCard\nComponents"]
    CARDS --> C3["StyleGuideCard\nStyle Guide"]`}</pre>
        </section>

        {/* ─── /styleguide ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/styleguide &mdash; Style Guide Viewer</h2>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/styleguide"]
    PAGE --> PROVIDER["ThemeConfigProvider\nconfig + branding for all themes"]
    PROVIDER --> SHELL["ShellChrome\nnavbar / sidebar / footer"]
    PROVIDER --> CONTENT["ThemeAwareSections\nmain content area"]
    PROVIDER --> BAR["LayoutBar\ntheme picker / layout / color mode"]

    CONTENT --> VF["Visual Foundation"]
    CONTENT --> STR["Structure"]
    CONTENT --> INT["Interaction"]
    CONTENT --> REF["Reference"]`}</pre>

          <h3 className="sg-sitemap-group-title">Visual Foundation</h3>
          <pre className="mermaid" suppressHydrationWarning>{`graph LR
    VF["Visual Foundation"]
    VF --> TYP["Typography\nTypeSpecimen\nfont scale"]
    VF --> COL["Color Palette\nColorSwatch\nColorGrid"]
    VF --> SPC["Spacing\nSpacingScale\nGridVisualizer"]
    VF --> DIV["Dividers"]
    VF --> GLY["Glyphs"]
    VF --> CODE["Code Blocks"]
    VF --> TERM["Terminal"]`}</pre>

          <h3 className="sg-sitemap-group-title">Structure</h3>
          <pre className="mermaid" suppressHydrationWarning>{`graph LR
    STR["Structure"]
    STR --> SHELL["Shell Layouts\nShellChrome\nShellLayoutSummary"]
    STR --> CLAYOUT["Content Layouts\nPageLayoutReference"]
    STR --> SITE["Site Archetypes\nSiteLayoutShowcase"]
    STR --> NAV["Navigation\nNavbar / Sidebar / Tabs"]`}</pre>

          <h3 className="sg-sitemap-group-title">Interaction</h3>
          <pre className="mermaid" suppressHydrationWarning>{`graph LR
    INT["Interaction"]
    INT --> SEM["Semantic Classes\nSemanticClassSelect\ndanger / success / warning"]
    INT --> STATUS["Status Indicators\nStatusGrid\nbadges / alerts / toasts"]
    INT --> UI["UI Elements\nButtonShowcase\nCardShowcase\nFormsShowcase"]`}</pre>

          <h3 className="sg-sitemap-group-title">Reference</h3>
          <pre className="mermaid" suppressHydrationWarning>{`graph LR
    REF["Reference"]
    REF --> TOK["Design Tokens\nTokenCard groups"]
    REF --> CSS["Generated CSS\nCssViewer"]
    REF --> YAML["Theme Config\nYamlConfigViewer"]
    REF --> SNIP["Snippets\ncss-snippets / jsx-snippets"]`}</pre>
        </section>

        {/* ─── /sitemap ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">/sitemap &mdash; Site Map</h2>
          <pre className="mermaid" suppressHydrationWarning>{`graph TD
    PAGE["/sitemap"]
    PAGE --> FLOW["Page Flow\nmermaid diagram"]
    PAGE --> PAGES["Page Inventory\nspec-table"]
    PAGE --> SECTIONS["Style Guide Sections\ngrouped list"]
    PAGE --> THEMES["Themes\nactive indicator"]`}</pre>
        </section>

        {/* ─── Page Inventory ─── */}
        <section className="sg-sitemap-section">
          <h2 className="sg-section-heading">Page Inventory</h2>
          <div className="admin-table-wrap">
            <table className="spec-table">
            <thead>
              <tr>
                <th>Route</th>
                <th>Purpose</th>
                <th>Key Components</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><a href="/">/</a></td>
                <td>Landing page</td>
                <td>StyleGuideBtn, StyleGuideCard, StyleGuideCardGrid</td>
              </tr>
              <tr>
                <td><a href="/styleguide">/styleguide</a></td>
                <td>Interactive style guide viewer</td>
                <td>ThemeConfigProvider, ThemeAwareSections, ShellChrome, LayoutBar</td>
              </tr>
              <tr>
                <td><a href="/sitemap">/sitemap</a></td>
                <td>Site flow and section inventory</td>
                <td>mermaid.js, spec-table</td>
              </tr>
            </tbody>
            </table>
          </div>
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
