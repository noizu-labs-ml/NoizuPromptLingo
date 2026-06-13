import { loadConfig, loadConfigRaw, loadPageSections, loadAllPageSections, listThemes, loadAllConfigs } from "@styleguide-engine/config/loader";
import { loadBranding, loadAllBrandings } from "@styleguide-engine/config/branding-loader";
import { generateCSSSections } from "@styleguide-engine/lib/css-gen";
import { ThemeConfigProvider } from "@styleguide-engine/components/ThemeConfigContext";
import { ThemeAwareSections } from "@styleguide-engine/components/ThemeAwareSections";
import fs from "fs";
import path from "path";
import { PageContent } from "@styleguide-engine/components/PageContent";
import { ShellChrome } from "@styleguide-engine/components/ShellChrome";
import { LayoutBar } from "@styleguide-engine/components/LayoutBar";

export default function Home() {
  const config = loadConfig();
  const branding = loadBranding();
  const allBrandings = loadAllBrandings();
  const allConfigsList = loadAllConfigs();
  const allConfigs: Record<string, typeof config> = {};
  for (const c of allConfigsList) allConfigs[c.slug] = c;
  const allCssSections: Record<string, ReturnType<typeof generateCSSSections>> = {};
  for (const c of allConfigsList) {
    try { allCssSections[c.slug] = generateCSSSections(c); } catch { /* skip broken themes */ }
  }
  const styleGuideFiles = loadConfigRaw();
  const brandingYaml = fs.readFileSync(
    path.join(process.cwd(), "src", "config", "theme-style-guide", "branding.yaml"),
    "utf-8"
  );

  // ─── YAML-driven page layout with auto-numbering ───

  function numberGroups(groups: ReturnType<typeof loadPageSections>) {
    let c = 0;
    return groups.map((group) => ({
      ...group,
      sections: group.sections.map((s) => ({
        ...s,
        number: String(++c).padStart(2, "0"),
      })),
    }));
  }

  const numberedGroups = numberGroups(loadPageSections());

  const allPageSections = loadAllPageSections();
  const allNumberedGroups: Record<string, ReturnType<typeof numberGroups>> = {};
  for (const [slug, ps] of Object.entries(allPageSections)) {
    allNumberedGroups[slug] = numberGroups(ps);
  }

  return (
    <ThemeConfigProvider primaryConfig={config} primaryBranding={branding} allConfigs={allConfigs} allBrandings={allBrandings}>
    <PageContent defaultSelected={config.semanticClasses[0]?.name || ""}>
    <div className="shell-grid">
      <ShellChrome shellLayouts={config.shellLayouts} />
      <div className="content" style={{ paddingBottom: "6rem" }}>
        <ThemeAwareSections
          allNumberedGroups={allNumberedGroups}
          numberedGroups={numberedGroups}
          allCssSections={allCssSections}
          styleGuideFiles={styleGuideFiles}
          brandingYaml={brandingYaml}
        />
      </div>
    </div>
    <LayoutBar pageLayouts={config.pageLayouts} themes={listThemes().map((t) => ({ slug: t.slug, name: t.name }))} />
    </PageContent>
    </ThemeConfigProvider>
  );
}
