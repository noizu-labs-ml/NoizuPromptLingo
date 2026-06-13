import { loadConfig, loadAllConfigs, listThemes } from "@styleguide-engine/config/loader";
import { loadBranding, loadAllBrandings } from "@styleguide-engine/config/branding-loader";
import { ThemeConfigProvider } from "@styleguide-engine/components/ThemeConfigContext";
import { PageContent } from "@styleguide-engine/components/PageContent";
import { LayoutBar } from "@styleguide-engine/components/LayoutBar";
import { ShellChrome } from "@styleguide-engine/components/ShellChrome";
import { ComponentBrowser } from "@styleguide-engine/components/ComponentBrowser";

export default function ComponentsPage() {
  const config = loadConfig();
  const branding = loadBranding();
  const allBrandings = loadAllBrandings();
  const allConfigsList = loadAllConfigs();
  const allConfigs: Record<string, typeof config> = {};
  for (const c of allConfigsList) allConfigs[c.slug] = c;

  return (
    <ThemeConfigProvider
      primaryConfig={config}
      primaryBranding={branding}
      allConfigs={allConfigs}
      allBrandings={allBrandings}
    >
      <PageContent defaultSelected={config.semanticClasses[0]?.name || ""}>
        <ShellChrome shellLayouts={config.shellLayouts} />
        <LayoutBar
          pageLayouts={config.pageLayouts}
          themes={listThemes().map((t) => ({ slug: t.slug, name: t.name }))}
        />
        <div className="content" style={{ padding: 0, display: "flex", flexDirection: "column", height: "100vh" }}>
          {/* Toolbar: back + title */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "var(--space-2)",
              padding: "var(--space-2) var(--space-3)",
              borderBottom: "1px solid var(--border)",
            }}
          >
            <a
              href="/"
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
                <path
                  d="M8 2L4 6l4 4"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
              Back
            </a>
            <h2
              style={{
                fontFamily: "var(--font-mono)",
                fontSize: "var(--font-size-sm)",
                textTransform: "uppercase",
                letterSpacing: "0.08em",
                color: "var(--text-muted)",
                margin: 0,
              }}
            >
              Component Browser
            </h2>
          </div>

          <ComponentBrowser
            semanticClasses={config.semanticClasses}
          />
        </div>
      </PageContent>
    </ThemeConfigProvider>
  );
}
