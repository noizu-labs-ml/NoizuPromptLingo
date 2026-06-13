import { loadConfig, loadAllConfigs, listThemes, loadConfigRawForDir } from "@styleguide-engine/config/loader";
import { loadBranding, loadAllBrandings } from "@styleguide-engine/config/branding-loader";
import { generateCSSSections } from "@styleguide-engine/lib/css-gen";
import { ThemeConfigProvider } from "@styleguide-engine/components/ThemeConfigContext";
import { ThemeAwareSectionContent } from "@styleguide-engine/components/ThemeAwareSectionContent";
import { PageContent } from "@styleguide-engine/components/PageContent";
import { LayoutBar } from "@styleguide-engine/components/LayoutBar";
import { ShellChrome } from "@styleguide-engine/components/ShellChrome";
import fs from "fs";
import path from "path";

const SECTIONS = [
  "hui", "controls", "cards", "buttons", "forms", "ui",
  "typography", "color", "tokens", "css", "config", "snippets",
];

export function generateStaticParams() {
  return SECTIONS.map((name) => ({ name }));
}

/** Map section route name → main-page anchor (section-{id}) */
const BACK_ANCHORS: Record<string, string> = {
  hui: "section-ui-elements",
  controls: "section-ui-elements",
  cards: "section-ui-elements",
  buttons: "section-ui-elements",
  forms: "section-ui-elements",
  ui: "section-ui-elements",
  typography: "section-typography",
  color: "section-color",
  tokens: "section-design-tokens",
  css: "section-generated-css",
  config: "section-theme-config",
  snippets: "section-snippets",
};

interface Props {
  params: Promise<{ name: string }>;
}

export default async function SectionPage({ params }: Props) {
  const { name } = await params;

  // ── Server-side: load all themes ──
  const config = loadConfig();
  const branding = loadBranding();
  const allBrandings = loadAllBrandings();
  const allConfigsList = loadAllConfigs();
  const allConfigs: Record<string, typeof config> = {};
  for (const c of allConfigsList) allConfigs[c.slug] = c;

  // Pre-generate CSS sections for all themes
  const allCssSections: Record<string, ReturnType<typeof generateCSSSections>> = {};
  for (const c of allConfigsList) {
    try { allCssSections[c.slug] = generateCSSSections(c); } catch { /* skip broken themes */ }
  }

  // Pre-load raw YAML files for all themes (used by the "config" section)
  const themes = listThemes();
  const allStyleGuideFiles: Record<string, { name: string; content: string }[]> = {};
  const allBrandingYamls: Record<string, string> = {};
  for (const theme of themes) {
    try {
      allStyleGuideFiles[theme.slug] = loadConfigRawForDir(theme.dir);
    } catch { /* skip broken themes */ }
    const brandingFile = path.join(theme.dir, "branding.yaml");
    if (fs.existsSync(brandingFile)) {
      allBrandingYamls[theme.slug] = fs.readFileSync(brandingFile, "utf-8");
    }
  }

  const backAnchor = BACK_ANCHORS[name] || "";

  return (
    <ThemeConfigProvider primaryConfig={config} primaryBranding={branding} allConfigs={allConfigs} allBrandings={allBrandings}>
      <PageContent defaultSelected={config.semanticClasses[0]?.name || ""}>
        <ShellChrome shellLayouts={config.shellLayouts} />
        <LayoutBar pageLayouts={config.pageLayouts} themes={listThemes().map((t) => ({ slug: t.slug, name: t.name }))} />
        <div className="content" style={{ padding: "var(--space-4)" }}>
          {/* Toolbar: back + title */}
          <div style={{ display: "flex", alignItems: "center", gap: "var(--space-2)", marginBottom: "var(--space-3)" }}>
            <a
              href={`/${backAnchor ? `#${backAnchor}` : ""}`}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "var(--space-half)",
                fontFamily: "var(--font-mono)",
                fontSize: "var(--font-size-xs)",
                color: "var(--text-muted)",
                textDecoration: "none",
                padding: "var(--space-half) var(--space-1)",
                border: "1px solid var(--border)",
                borderRadius: "var(--radius)",
              }}
            >
              <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                <path d="M8 2L4 6l4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
              Back
            </a>
            <h2 style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-sm)", textTransform: "uppercase", letterSpacing: "0.08em", color: "var(--text-muted)", margin: 0 }}>
              {name}
            </h2>
          </div>

          {/* Theme-reactive section content */}
          <ThemeAwareSectionContent
            name={name}
            allCssSections={allCssSections}
            allStyleGuideFiles={allStyleGuideFiles}
            allBrandingYamls={allBrandingYamls}
          />
        </div>
      </PageContent>
    </ThemeConfigProvider>
  );
}
