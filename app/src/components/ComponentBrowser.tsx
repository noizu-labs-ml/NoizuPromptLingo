"use client";

import { useState, type ReactNode } from "react";
import type { SemanticClass } from "@styleguide-engine/lib/types";

// ─── Primitives ─────────────────────────────────────────────────────────────
import { StyleGuideBtn } from "./pkg/btn";
import { StyleGuideCard } from "./pkg/card";
import { StyleGuideCardGrid } from "./pkg/card-grid";
import { StyleGuideButtonRow } from "./pkg/button-row";
import { StyleGuideSectionHeader } from "./pkg/section-header";
import { StyleGuideSectionDesc } from "./pkg/section-desc";
import { StyleGuideTokenPreview } from "./pkg/token-preview";
import { StyleGuideTokenCard } from "./pkg/token-card";
import { StyleGuideTypeSpecimen } from "./pkg/type-specimen";
import { StyleGuideNotesList } from "./pkg/notes-list";
import { StyleGuideSpacingScale } from "./pkg/spacing-scale";
import { StyleGuideSpecTable } from "./pkg/spec-table";
import { StyleGuidePrinciples } from "./pkg/principles";
import { StyleGuideScreenFrame } from "./pkg/screen-frame";
import { StyleGuideWidgetDemo } from "./pkg/widget-demo";
import { StyleGuideComponentRef } from "./pkg/component-ref";
import { StyleGuidePhaseTabs } from "./pkg/phase-tabs";
import { StyleGuideStepProgress } from "./pkg/step-progress";
import { StyleGuideStatusIndicator } from "./pkg/status-indicator";
import { StyleGuideStatusGrid } from "./pkg/status-grid";
import { StyleGuideInputGroup } from "./pkg/input-group";
import { StyleGuideInputField } from "./pkg/input-field";
import { StyleGuideSpacingDiagram } from "./pkg/spacing-diagram";
import { StyleGuideColorSwatch } from "./pkg/color-swatch";
import { StyleGuideColorGrid } from "./pkg/color-grid";
import { StyleGuideProductBranding } from "./pkg/product-branding";

// ─── Demos ──────────────────────────────────────────────────────────────────
import { CheckboxRadioDemo } from "./demos/CheckboxRadioDemo";
import { TextInputDemo, SelectDemo, TextareaDemo, FormLayoutDemo, ValidationDemo } from "./demos/FormFieldDemos";
import { FormValidationDemo } from "./demos/FormValidationDemo";
import { ToastsDemo } from "./demos/ToastsDemo";
import { Badge, BadgeShowcase } from "./demos/BadgeShowcase";

// ─── Layout ─────────────────────────────────────────────────────────────────
import { ColorModeToggle } from "./ColorModeToggle";
import { SearchFilter } from "./SearchFilter";
import { CollapsibleSection } from "./CollapsibleSection";
import { SubsectionTabs } from "./SubsectionTabs";
import { GridVisualizer } from "./GridVisualizer";

// ─── Catalog ────────────────────────────────────────────────────────────────

interface CatalogEntry {
  name: string;
  importPath: string;
  description: string;
  render: (() => ReactNode) | null;
}

interface CatalogCategory {
  slug: string;
  label: string;
  description: string;
  entries: CatalogEntry[];
}

function buildCatalog(semanticClasses: SemanticClass[]): CatalogCategory[] {
  const sc = semanticClasses[0];
  const scClass = sc?.class || "primary";

  return [
    {
      slug: "primitives",
      label: "Primitives",
      description: "Low-level building blocks — buttons, cards, inputs, tokens, and indicators",
      entries: [
        {
          name: "StyleGuideBtn",
          importPath: "@noizu/styleguide/primitives",
          description: "Themed button with variant and size props",
          render: () => (
            <div className="flex flex-wrap gap-[var(--space-2)] items-end">
              <StyleGuideBtn variant="black" label="Default" />
              <StyleGuideBtn variant="black" size="sm" label="Small" />
              <StyleGuideBtn variant="black" size="lg" label="Large" />
              <StyleGuideBtn variant="black" size="xl" label="XL" />
            </div>
          ),
        },
        {
          name: "StyleGuideCard",
          importPath: "@noizu/styleguide/primitives",
          description: "Content card with title, body, tags, and optional variant",
          render: () => (
            <StyleGuideCard
              title="Example Card"
              body="This is a card component with title, body, and tags."
              tags={["Tag A", "Tag B"]}
            />
          ),
        },
        {
          name: "StyleGuideCardGrid",
          importPath: "@noizu/styleguide/primitives",
          description: "Responsive grid container for StyleGuideCard",
          render: () => (
            <StyleGuideCardGrid>
              <StyleGuideCard title="Card 1" body="First card in the grid" />
              <StyleGuideCard title="Card 2" body="Second card in the grid" />
              <StyleGuideCard title="Card 3" body="Third card in the grid" />
            </StyleGuideCardGrid>
          ),
        },
        {
          name: "StyleGuideButtonRow",
          importPath: "@noizu/styleguide/primitives",
          description: "Horizontal row of buttons with consistent spacing",
          render: () => (
            <StyleGuideButtonRow>
              <button className={`btn ${scClass}`}>Primary</button>
              <button className={`btn btn-outline ${scClass}`}>Outline</button>
              <button className={`btn accent-${scClass}`}>Accent</button>
            </StyleGuideButtonRow>
          ),
        },
        {
          name: "StyleGuideSectionHeader",
          importPath: "@noizu/styleguide/primitives",
          description: "Numbered section header with title and optional description",
          render: () => <StyleGuideSectionHeader number="01" title="Example Section" desc="A section header with number prefix and description." />,
        },
        {
          name: "StyleGuideSectionDesc",
          importPath: "@noizu/styleguide/primitives",
          description: "Section description text block (renders children as paragraph)",
          render: () => <StyleGuideSectionDesc>A concise description of this section&apos;s purpose and contents.</StyleGuideSectionDesc>,
        },
        {
          name: "StyleGuideTokenPreview",
          importPath: "@noizu/styleguide/primitives",
          description: "Inline preview swatch for a CSS custom property. Types: color, font, space, radius, shadow, size.",
          render: () => (
            <div className="flex gap-[var(--space-3)] items-center">
              <StyleGuideTokenPreview type="color" value="var(--accent)" />
              <StyleGuideTokenPreview type="font" value="var(--font-heading)" />
              <StyleGuideTokenPreview type="space" value="var(--space-4)" />
              <StyleGuideTokenPreview type="radius" value="var(--radius)" />
            </div>
          ),
        },
        {
          name: "StyleGuideTokenCard",
          importPath: "@noizu/styleguide/primitives",
          description: "Card displaying a group of design tokens with name/value pairs and previews",
          render: () => (
            <StyleGuideTokenCard
              title="Spacing Tokens"
              type="space"
              tokens={[
                ["--space-1", "0.25rem"],
                ["--space-2", "0.5rem"],
                ["--space-3", "0.75rem"],
                ["--space-4", "1rem"],
              ]}
            />
          ),
        },
        {
          name: "StyleGuideTypeSpecimen",
          importPath: "@noizu/styleguide/primitives",
          description: "Typography specimen block showing font family, weight, size, and sample text",
          render: () => (
            <StyleGuideTypeSpecimen
              name="Heading"
              font="var(--font-heading)"
              weight={700}
              size="var(--font-size-xl)"
              lineHeight={1.2}
              sample="The quick brown fox jumps over the lazy dog"
              usage="Page titles, section headers"
            />
          ),
        },
        {
          name: "StyleGuideNotesList",
          importPath: "@noizu/styleguide/primitives",
          description: "Bulleted list for design notes and guidelines",
          render: () => <StyleGuideNotesList notes={[
            { label: "Usage", text: "Use sparingly in main content" },
            { label: "Variant", text: "Prefer outlined variant for secondary actions" },
            { label: "A11y", text: "Always include accessible label text" },
          ]} />,
        },
        {
          name: "StyleGuideSpacingScale",
          importPath: "@noizu/styleguide/primitives",
          description: "Visual spacing scale showing spacing steps with px values and labels",
          render: () => <StyleGuideSpacingScale steps={[
            { px: 4, label: "space-1" },
            { px: 8, label: "space-2" },
            { px: 12, label: "space-3" },
            { px: 16, label: "space-4" },
            { px: 24, label: "space-6" },
            { px: 32, label: "space-8" },
          ]} />,
        },
        {
          name: "StyleGuideInputField",
          importPath: "@noizu/styleguide/primitives",
          description: "Themed input field with optional error and disabled states",
          render: () => (
            <div className="flex flex-col gap-[var(--space-2)]" style={{ maxWidth: 320 }}>
              <StyleGuideInputField placeholder="Default input" type="text" />
              <StyleGuideInputField placeholder="Error state" type="text" error />
              <StyleGuideInputField placeholder="Disabled" type="text" disabled />
              <StyleGuideInputField placeholder="Textarea" textarea />
            </div>
          ),
        },
        {
          name: "StyleGuideInputGroup",
          importPath: "@noizu/styleguide/primitives",
          description: "Grouped input fields with label and optional hint/error",
          render: () => (
            <div style={{ maxWidth: 320 }}>
              <StyleGuideInputGroup label="Full Name" hint="Enter first and last name">
                <StyleGuideInputField placeholder="First name" type="text" />
                <StyleGuideInputField placeholder="Last name" type="text" />
              </StyleGuideInputGroup>
            </div>
          ),
        },
        {
          name: "StyleGuideStatusIndicator",
          importPath: "@noizu/styleguide/primitives",
          description: "Status dot/badge with semantic color and label",
          render: () => (
            <div className="flex gap-[var(--space-3)]">
              <StyleGuideStatusIndicator status="success" label="Active" />
              <StyleGuideStatusIndicator status="warning" label="Pending" />
              <StyleGuideStatusIndicator status="error" label="Failed" />
              <StyleGuideStatusIndicator status="info" label="Queued" />
            </div>
          ),
        },
        {
          name: "StyleGuideStatusGrid",
          importPath: "@noizu/styleguide/primitives",
          description: "Grid of status indicators for dashboards",
          render: () => (
            <StyleGuideStatusGrid items={[
              { label: "API", status: "success" },
              { label: "DB", status: "success" },
              { label: "Cache", status: "warning" },
              { label: "Queue", status: "error" },
            ]} />
          ),
        },
        {
          name: "StyleGuideColorSwatch",
          importPath: "@noizu/styleguide/primitives",
          description: "Single color swatch with name and hex value",
          render: () => (
            <div className="flex gap-[var(--space-2)]">
              <StyleGuideColorSwatch name="primary" hex="#3b82f6" />
              <StyleGuideColorSwatch name="accent" hex="#f59e0b" />
              <StyleGuideColorSwatch name="success" hex="#22c55e" />
            </div>
          ),
        },
        {
          name: "StyleGuideColorGrid",
          importPath: "@noizu/styleguide/primitives",
          description: "Grid of color swatches for a palette",
          render: () => (
            <StyleGuideColorGrid colors={[
              { name: "primary", hex: "#3b82f6" },
              { name: "secondary", hex: "#6366f1" },
              { name: "accent", hex: "#f59e0b" },
              { name: "success", hex: "#22c55e" },
              { name: "warning", hex: "#eab308" },
              { name: "error", hex: "#ef4444" },
            ]} />
          ),
        },
        {
          name: "StyleGuideSpecTable",
          importPath: "@noizu/styleguide/primitives",
          description: "Spec table with named columns and row data",
          render: () => (
            <StyleGuideSpecTable
              columns={["Property", "Value", "Usage"]}
              rows={[
                ["Border Radius", "var(--radius)", "Cards, buttons, inputs"],
                ["Shadow", "var(--shadow-sm)", "Elevated surfaces"],
                ["Font Family", "var(--font-body)", "Body text, UI labels"],
              ]}
            />
          ),
        },
        {
          name: "StyleGuidePrinciples",
          importPath: "@noizu/styleguide/primitives",
          description: "Numbered design principles with rule and detail",
          render: () => (
            <StyleGuidePrinciples items={[
              { rule: "Clarity", detail: "Every element should have a clear purpose." },
              { rule: "Consistency", detail: "Reuse patterns, tokens, and components." },
              { rule: "Accessibility", detail: "Design for all users, not just the majority." },
            ]} />
          ),
        },
        {
          name: "StyleGuideScreenFrame",
          importPath: "@noizu/styleguide/primitives",
          description: "Mock device frame with URL bar and screen body",
          render: () => (
            <StyleGuideScreenFrame url="https://app.example.com/dashboard" label="Dashboard">
              <div style={{ padding: "var(--space-4)", textAlign: "center", color: "var(--text-muted)" }}>
                Screen content goes here
              </div>
            </StyleGuideScreenFrame>
          ),
        },
        {
          name: "StyleGuideWidgetDemo",
          importPath: "@noizu/styleguide/primitives",
          description: "Widget card with title, badge, description, and content area",
          render: () => (
            <StyleGuideWidgetDemo title="Active Users" badge="Live" desc="Real-time user count">
              <div style={{ fontSize: "var(--font-size-2xl)", fontWeight: 700 }}>1,247</div>
            </StyleGuideWidgetDemo>
          ),
        },
        {
          name: "StyleGuideComponentRef",
          importPath: "@noizu/styleguide/primitives",
          description: "Component reference card with name, category, description, and props table",
          render: () => (
            <StyleGuideComponentRef
              name="StyleGuideBtn"
              category="primitives"
              desc="Themed button with variant and size props"
              props={[
                { name: "variant", type: "string", default: "'black'", desc: "Button color variant", required: false },
                { name: "size", type: "string", desc: "Size: sm, lg, xl", required: false },
                { name: "label", type: "ReactNode", desc: "Button content", required: false },
              ]}
            />
          ),
        },
        {
          name: "StyleGuidePhaseTabs",
          importPath: "@noizu/styleguide/primitives",
          description: "Phase indicator tabs with optional state styling",
          render: () => (
            <StyleGuidePhaseTabs tabs={[
              { label: "Design", state: "done" },
              { label: "Build", state: "current" },
              { label: "Test" },
              { label: "Deploy" },
            ]} />
          ),
        },
        {
          name: "StyleGuideStepProgress",
          importPath: "@noizu/styleguide/primitives",
          description: "Step progress bar with total, done, and current step",
          render: () => <StyleGuideStepProgress total={5} done={2} current={3} label="Step 3 of 5 — Review" />,
        },
        {
          name: "StyleGuideSpacingDiagram",
          importPath: "@noizu/styleguide/primitives",
          description: "Visual diagram showing viewport, gutter, and content spacing",
          render: () => (
            <StyleGuideSpacingDiagram
              title="Page Layout Spacing"
              blocks={[
                { label: "Header", meta: "48px" },
                { label: "Content", meta: "flex" },
                { label: "Footer", meta: "32px", compact: true },
              ]}
            />
          ),
        },
        {
          name: "StyleGuideProductBranding",
          importPath: "@noizu/styleguide/primitives",
          description: "Product branding card — logo, name, intent, perception, audience, tone, keywords",
          render: null,
        },
      ],
    },
    {
      slug: "demos",
      label: "Demos",
      description: "Interactive form field and interaction demos — self-contained, no props required",
      entries: [
        {
          name: "TextInputDemo",
          importPath: "@noizu/styleguide/demos",
          description: "Text input field demo with states",
          render: () => <TextInputDemo />,
        },
        {
          name: "SelectDemo",
          importPath: "@noizu/styleguide/demos",
          description: "Select dropdown demo",
          render: () => <SelectDemo />,
        },
        {
          name: "TextareaDemo",
          importPath: "@noizu/styleguide/demos",
          description: "Textarea field demo",
          render: () => <TextareaDemo />,
        },
        {
          name: "CheckboxRadioDemo",
          importPath: "@noizu/styleguide/demos",
          description: "Checkbox and radio button demo",
          render: () => <CheckboxRadioDemo />,
        },
        {
          name: "FormLayoutDemo",
          importPath: "@noizu/styleguide/demos",
          description: "Form layout patterns demo",
          render: () => <FormLayoutDemo />,
        },
        {
          name: "ValidationDemo",
          importPath: "@noizu/styleguide/demos",
          description: "Input validation states demo",
          render: () => <ValidationDemo />,
        },
        {
          name: "FormValidationDemo",
          importPath: "@noizu/styleguide/demos",
          description: "Full form validation workflow demo",
          render: () => <FormValidationDemo />,
        },
        {
          name: "ToastsDemo",
          importPath: "@noizu/styleguide/demos",
          description: "Toast notification types — click to trigger live toasts",
          render: () => <ToastsDemo />,
        },
      ],
    },
    {
      slug: "layout",
      label: "Layout",
      description: "Page chrome, navigation, section orchestration, and layout visualization",
      entries: [
        {
          name: "ThemeLogo",
          importPath: "@noizu/styleguide/layout",
          description: "Renders the active theme's logo from branding config. Requires brandings prop (Record<string, BrandingConfig>).",
          render: null,
        },
        {
          name: "ColorModeToggle",
          importPath: "@noizu/styleguide/layout",
          description: "Light/dark mode toggle button",
          render: () => <ColorModeToggle />,
        },
        {
          name: "IntroHero",
          importPath: "@noizu/styleguide/layout",
          description: "Hero banner for the style guide intro. Requires brandings prop (Record<string, BrandingConfig>).",
          render: null,
        },
        {
          name: "SearchFilter",
          importPath: "@noizu/styleguide/layout",
          description: "Search/filter input for section navigation",
          render: () => <SearchFilter />,
        },
        {
          name: "CollapsibleSection",
          importPath: "@noizu/styleguide/layout",
          description: "Expandable/collapsible content section with number, title, and description",
          render: () => (
            <CollapsibleSection number="01" id="example-collapsible" title="Collapsible Example" desc="Click to expand or collapse this section." defaultOpen>
              <div style={{ padding: "var(--space-2)" }}>
                This content can be collapsed and expanded.
              </div>
            </CollapsibleSection>
          ),
        },
        {
          name: "SubsectionTabs",
          importPath: "@noizu/styleguide/layout",
          description: "Tab navigation within a section",
          render: () => (
            <SubsectionTabs tabs={[
              { id: "preview", title: "Preview", content: <div style={{ padding: "var(--space-2)" }}>Preview content</div> },
              { id: "code", title: "Code", content: <div style={{ padding: "var(--space-2)" }}>Code content</div> },
              { id: "notes", title: "Notes", content: <div style={{ padding: "var(--space-2)" }}>Usage notes</div> },
            ]} />
          ),
        },
        {
          name: "GridVisualizer",
          importPath: "@noizu/styleguide/layout",
          description: "Visual column grid overlay with gutter and margin annotations",
          render: () => <GridVisualizer columns={12} gutterPx={16} marginPx={40} />,
        },
        {
          name: "LayoutBar",
          importPath: "@noizu/styleguide/layout",
          description: "Floating control bar for layout mode, theme switching, and dark mode. Shown globally — see bottom of page.",
          render: null,
        },
        {
          name: "PageContent",
          importPath: "@noizu/styleguide/layout",
          description: "Root content wrapper that restores persisted layout state and provides semantic selection context.",
          render: null,
        },
        {
          name: "ShellChrome",
          importPath: "@noizu/styleguide/layout",
          description: "App shell sidebar/header chrome rendered from shellLayouts config.",
          render: null,
        },
        {
          name: "ThemeAwareSections",
          importPath: "@noizu/styleguide/layout",
          description: "Renders numbered section groups, re-renders when the active theme changes.",
          render: null,
        },
        {
          name: "SectionGroup",
          importPath: "@noizu/styleguide/layout",
          description: "Groups related sections under a common heading with collapse behavior.",
          render: null,
        },
        {
          name: "PageLayoutReference",
          importPath: "@noizu/styleguide/layout",
          description: "Reference card showing a page layout definition from config.",
          render: null,
        },
        {
          name: "PageLayoutSummary",
          importPath: "@noizu/styleguide/layout",
          description: "Summary table of all page layouts.",
          render: null,
        },
        {
          name: "ShellLayoutSummary",
          importPath: "@noizu/styleguide/layout",
          description: "Summary table of all shell layout definitions.",
          render: null,
        },
      ],
    },
    {
      slug: "viewers",
      label: "Viewers",
      description: "Inspect and manage generated output — CSS viewer, YAML config viewer, override manager",
      entries: [
        {
          name: "CssViewer",
          importPath: "@noizu/styleguide/viewers",
          description: "Displays generated CSS sections with syntax highlighting. Requires cssSections prop from generateCSSSections().",
          render: null,
        },
        {
          name: "YamlConfigViewer",
          importPath: "@noizu/styleguide/viewers",
          description: "Displays raw YAML config files with tabs per file. Requires styleGuideFiles prop.",
          render: null,
        },
        {
          name: "OverrideManager",
          importPath: "@noizu/styleguide/viewers",
          description: "UI for viewing and editing CSS variable overrides per semantic class.",
          render: null,
        },
      ],
    },
    {
      slug: "providers",
      label: "Providers",
      description: "React context providers — wrap your app to enable theme and semantic selection",
      entries: [
        {
          name: "ThemeConfigProvider",
          importPath: "@noizu/styleguide/providers",
          description: "Provides theme config context. Watches data-design-theme attribute for live theme switching.",
          render: null,
        },
        {
          name: "useThemeConfig",
          importPath: "@noizu/styleguide/providers",
          description: "Hook — access { activeSlug, config, branding, allConfigs, allBrandings } from ThemeConfigProvider.",
          render: null,
        },
        {
          name: "SemanticSelectionProvider",
          importPath: "@noizu/styleguide/providers",
          description: "Provides semantic class selection context for showcase components.",
          render: null,
        },
        {
          name: "useSemanticSelection",
          importPath: "@noizu/styleguide/providers",
          description: "Hook — access { selected, setSelected } for the active semantic class.",
          render: null,
        },
      ],
    },
    {
      slug: "sections",
      label: "Sections",
      description: "Section registry — maps section keys to renderable components",
      entries: [
        {
          name: "sectionRegistry",
          importPath: "@noizu/styleguide/sections",
          description: "Map<string, ComponentType<SectionProps>> — registry of all renderable section components keyed by name.",
          render: null,
        },
      ],
    },
    {
      slug: "product",
      label: "Product Components",
      description: "tobornalp application components — badges, cards, indicators, and interactive controls (Tier 0+)",
      entries: [
        {
          name: "Badge",
          importPath: "tobornalp/components/badge",
          description: "Status badge — pill-shaped label with color coding for priority, agent status, methodology, and source. 9 colors × 3 variants × 2 sizes.",
          render: () => <BadgeShowcase />,
        },
        {
          name: "Badge (Inline)",
          importPath: "tobornalp/components/badge",
          description: "Individual badge — use directly with props for custom compositions.",
          render: () => (
            <div style={{ display: "flex", flexWrap: "wrap", gap: "var(--space-2)", alignItems: "center" }}>
              <span style={{ fontFamily: "var(--font-sans)", fontSize: "var(--font-size-sm)", color: "var(--text)" }}>
                Deploy #847
              </span>
              <Badge label="Production" color="blue" variant="filled" size="sm" />
              <Badge label="v2.4.1" color="default" variant="outline" size="sm" />
              <Badge label="● Healthy" color="emerald" variant="subtle" size="sm" />
            </div>
          ),
        },
      ],
    },
  ];
}

// ─── Browser UI ─────────────────────────────────────────────────────────────

interface Props {
  semanticClasses: SemanticClass[];
  /** When rendered inside a CollapsibleSection, constrain height to viewport */
  embedded?: boolean;
}

export function ComponentBrowser({ semanticClasses, embedded }: Props) {
  const catalog = buildCatalog(semanticClasses);
  const [activeCategory, setActiveCategory] = useState(catalog[0].slug);
  const [activeComponent, setActiveComponent] = useState<string | null>(null);

  const category = catalog.find((c) => c.slug === activeCategory) || catalog[0];
  const entry = activeComponent
    ? category.entries.find((e) => e.name === activeComponent) || null
    : null;

  return (
    <div style={{ display: "flex", flex: 1, overflow: "hidden", ...(embedded ? { minHeight: 480, maxHeight: "70vh" } : {}) }}>
      {/* ── Sidebar ── */}
      <nav
        style={{
          width: 280,
          minWidth: 280,
          borderRight: "1px solid var(--border)",
          overflowY: "auto",
          background: "var(--bg-secondary, var(--bg))",
        }}
      >
        {catalog.map((cat) => (
          <div key={cat.slug}>
            <button
              type="button"
              onClick={() => {
                setActiveCategory(cat.slug);
                setActiveComponent(null);
              }}
              style={{
                display: "block",
                width: "100%",
                textAlign: "left",
                padding: "var(--space-1-5) var(--space-3)",
                fontFamily: "var(--font-mono)",
                fontSize: "var(--font-size-xs)",
                fontWeight: 700,
                textTransform: "uppercase",
                letterSpacing: "0.08em",
                color: activeCategory === cat.slug ? "var(--accent, var(--text))" : "var(--text-muted)",
                background: activeCategory === cat.slug ? "color-mix(in srgb, var(--accent, var(--text)) 8%, transparent)" : "transparent",
                border: "none",
                cursor: "pointer",
                borderBottom: "1px solid var(--border)",
              }}
            >
              {cat.label}
              <span style={{ fontWeight: 400, opacity: 0.6, marginLeft: "var(--space-1)" }}>
                ({cat.entries.length})
              </span>
            </button>

            {activeCategory === cat.slug && (
              <div>
                {cat.entries.map((e) => (
                  <button
                    key={e.name}
                    type="button"
                    onClick={() => setActiveComponent(e.name)}
                    style={{
                      display: "block",
                      width: "100%",
                      textAlign: "left",
                      padding: "var(--space-1) var(--space-3) var(--space-1) var(--space-5)",
                      fontFamily: "var(--font-mono)",
                      fontSize: "var(--font-size-xs)",
                      color: activeComponent === e.name ? "var(--accent, var(--text))" : "var(--text)",
                      background: activeComponent === e.name ? "color-mix(in srgb, var(--accent, var(--text)) 6%, transparent)" : "transparent",
                      border: "none",
                      cursor: "pointer",
                      borderLeft: activeComponent === e.name ? "2px solid var(--accent, var(--text))" : "2px solid transparent",
                    }}
                  >
                    {e.name}
                    {!e.render && (
                      <span style={{ opacity: 0.4, marginLeft: "var(--space-1)", fontSize: "0.7em" }}>
                        (ref)
                      </span>
                    )}
                  </button>
                ))}
              </div>
            )}
          </div>
        ))}
      </nav>

      {/* ── Preview area ── */}
      <div style={{ flex: 1, overflowY: "auto", padding: "var(--space-4)" }}>
        {!entry ? (
          // Category overview
          <div>
            <h3
              style={{
                fontFamily: "var(--font-heading, var(--font-body))",
                fontSize: "var(--font-size-lg)",
                fontWeight: 700,
                color: "var(--text)",
                marginBottom: "var(--space-1)",
              }}
            >
              {category.label}
            </h3>
            <p
              style={{
                fontFamily: "var(--font-body)",
                fontSize: "var(--font-size-sm)",
                color: "var(--text-muted)",
                marginBottom: "var(--space-4)",
                maxWidth: 600,
              }}
            >
              {category.description}
            </p>
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))",
                gap: "var(--space-2)",
              }}
            >
              {category.entries.map((e) => (
                <button
                  key={e.name}
                  type="button"
                  onClick={() => setActiveComponent(e.name)}
                  style={{
                    textAlign: "left",
                    padding: "var(--space-2) var(--space-3)",
                    background: "var(--bg)",
                    border: "1px solid var(--border)",
                    borderRadius: "var(--radius, 6px)",
                    cursor: "pointer",
                  }}
                >
                  <div
                    style={{
                      fontFamily: "var(--font-mono)",
                      fontSize: "var(--font-size-sm)",
                      fontWeight: 600,
                      color: "var(--text)",
                      marginBottom: "var(--space-half)",
                    }}
                  >
                    {e.name}
                  </div>
                  <div
                    style={{
                      fontSize: "var(--font-size-xs)",
                      color: "var(--text-muted)",
                      lineHeight: 1.4,
                    }}
                  >
                    {e.description}
                  </div>
                </button>
              ))}
            </div>
          </div>
        ) : (
          // Component detail
          <div>
            {/* Header */}
            <div style={{ marginBottom: "var(--space-4)" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "var(--space-2)", marginBottom: "var(--space-1)" }}>
                <button
                  type="button"
                  onClick={() => setActiveComponent(null)}
                  style={{
                    fontFamily: "var(--font-mono)",
                    fontSize: "var(--font-size-xs)",
                    color: "var(--text-muted)",
                    background: "transparent",
                    border: "1px solid var(--border)",
                    borderRadius: "var(--radius, 4px)",
                    padding: "2px 8px",
                    cursor: "pointer",
                  }}
                >
                  ← All
                </button>
                <h3
                  style={{
                    fontFamily: "var(--font-mono)",
                    fontSize: "var(--font-size-lg)",
                    fontWeight: 700,
                    color: "var(--text)",
                    margin: 0,
                  }}
                >
                  {entry.name}
                </h3>
              </div>
              <p
                style={{
                  fontFamily: "var(--font-body)",
                  fontSize: "var(--font-size-sm)",
                  color: "var(--text-muted)",
                  marginBottom: "var(--space-2)",
                }}
              >
                {entry.description}
              </p>
              <code
                style={{
                  display: "inline-block",
                  fontFamily: "var(--font-mono)",
                  fontSize: "var(--font-size-xs)",
                  color: "var(--text-muted)",
                  background: "color-mix(in srgb, var(--text) 6%, transparent)",
                  padding: "2px 8px",
                  borderRadius: "var(--radius, 4px)",
                }}
              >
                import {"{"} {entry.name} {"}"} from &quot;{entry.importPath}&quot;
              </code>
            </div>

            {/* Live preview */}
            {entry.render ? (
              <div
                style={{
                  border: "1px solid var(--border)",
                  borderRadius: "var(--radius, 6px)",
                  overflow: "hidden",
                }}
              >
                <div
                  style={{
                    padding: "var(--space-half) var(--space-2)",
                    background: "color-mix(in srgb, var(--text) 4%, transparent)",
                    borderBottom: "1px solid var(--border)",
                    fontFamily: "var(--font-mono)",
                    fontSize: "var(--font-size-xs)",
                    color: "var(--text-muted)",
                    textTransform: "uppercase",
                    letterSpacing: "0.06em",
                  }}
                >
                  Live Preview
                </div>
                <div style={{ padding: "var(--space-4)" }}>
                  {entry.render()}
                </div>
              </div>
            ) : (
              <div
                style={{
                  border: "1px dashed var(--border)",
                  borderRadius: "var(--radius, 6px)",
                  padding: "var(--space-6) var(--space-4)",
                  textAlign: "center",
                  color: "var(--text-muted)",
                  fontFamily: "var(--font-mono)",
                  fontSize: "var(--font-size-sm)",
                }}
              >
                Infrastructure component — no standalone preview.
                <br />
                <span style={{ fontSize: "var(--font-size-xs)", opacity: 0.7 }}>
                  See the main style guide page for this component in context.
                </span>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
