import { loadConfig, loadConfigRaw, loadPageSections, loadAllPageSections, listThemes, loadAllConfigs } from "@noizu/styleguide/css-gen";
import { loadBranding, loadAllBrandings } from "@noizu/styleguide/css-gen";
import { generateCSSSections } from "@noizu/styleguide/css-gen";
import fs from "fs";
import path from "path";
import StyleGuideViewer from "./viewer";

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

  const themes = listThemes();
  const firstThemeSlug = themes[0]?.slug || "style-guide";
  const brandingYaml = fs.readFileSync(
    path.join(process.env.STYLEGUIDE_CONFIG_ROOT || path.join(process.cwd(), "src", "config"), `theme-${firstThemeSlug}`, "branding.yaml"),
    "utf-8"
  );

  function numberGroups(groups: ReturnType<typeof loadPageSections>) {
    let c = 0;
    return groups.map((group) => ({
      ...group,
      sections: group.sections.map((s) => ({ ...s, number: String(++c).padStart(2, "0") })),
    }));
  }

  const numberedGroups = numberGroups(loadPageSections());
  const allPageSections = loadAllPageSections();
  const allNumberedGroups: Record<string, ReturnType<typeof numberGroups>> = {};
  for (const [slug, ps] of Object.entries(allPageSections)) {
    allNumberedGroups[slug] = numberGroups(ps);
  }

  return (
    <StyleGuideViewer
      config={config} branding={branding} allConfigs={allConfigs} allBrandings={allBrandings}
      allNumberedGroups={allNumberedGroups} numberedGroups={numberedGroups}
      allCssSections={allCssSections} styleGuideFiles={styleGuideFiles}
      brandingYaml={brandingYaml} themes={themes.map((t) => ({ slug: t.slug, name: t.name }))}
    />
  );
}
