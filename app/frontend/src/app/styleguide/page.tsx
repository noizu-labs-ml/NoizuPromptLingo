import { loadConfig, loadConfigRaw, loadPageSections, loadAllPageSections, listThemes, loadAllConfigs } from "@the-robot-lives/styleguide/css-gen";
import { loadBranding, loadAllBrandings } from "@the-robot-lives/styleguide/css-gen";
import { generateCSSSections } from "@the-robot-lives/styleguide/css-gen";
import { ThemeConfigProvider } from "@the-robot-lives/styleguide/viewer";
import { ThemeAwareSections } from "@the-robot-lives/styleguide/viewer";
import { PageContent } from "@the-robot-lives/styleguide/viewer";
import { ShellChrome } from "@the-robot-lives/styleguide/viewer";
import { LayoutBar } from "@the-robot-lives/styleguide/viewer";
import fs from "fs";
import path from "path";

export default function StyleGuidePage() {
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

  const firstThemeDir = fs.readdirSync(path.join(process.cwd(), "src", "config"))
    .filter((d) => d.startsWith("theme-"))
    .sort()[0];
  const brandingYaml = fs.readFileSync(
    path.join(process.cwd(), "src", "config", firstThemeDir, "branding.yaml"),
    "utf-8"
  );

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
