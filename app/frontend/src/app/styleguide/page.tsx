import { loadConfig, loadConfigRaw, loadPageSections, loadAllPageSections, listThemes, loadAllConfigs } from "@the-robot-lives/styleguide/css-gen";
import { loadBranding, loadAllBrandings } from "@the-robot-lives/styleguide/css-gen";
import { generateCSSSections } from "@the-robot-lives/styleguide/css-gen";
import { ThemeConfigProvider } from "@the-robot-lives/styleguide/viewer";
import { ThemeAwareSections } from "@the-robot-lives/styleguide/viewer";
import { PageContent } from "@the-robot-lives/styleguide/viewer";
import { ShellChrome } from "@the-robot-lives/styleguide/viewer";
import { LayoutBar } from "@the-robot-lives/styleguide/viewer";
import { RobotGrid } from "@/components/robot-grid";
import { RobotFoundry } from "@/components/robot-foundry";
import { RobotEgghead } from "@/components/robot-egghead";
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
  const brandingYaml = fs.readFileSync(
    path.join(process.cwd(), "src", "config", "theme-style-guide", "branding.yaml"),
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

        {/* ─── Robot Character Sheet ─── */}
        <div className="sg-section" style={{ marginTop: "var(--space-6)" }}>
          <div className="sg-collapsible-header" style={{ display: "flex", alignItems: "center", gap: "var(--space-2)", marginBottom: "var(--space-2)" }}>
            <span className="sg-section-number" style={{ background: "var(--text-link)", color: "var(--surface)" }}>◈</span>
            <h2 className="sg-section-title" style={{ margin: 0 }}>Robot Character Sheet</h2>
          </div>
          <p className="sg-section-desc" style={{ marginBottom: "var(--space-4)" }}>
            The robot foundry. 12 body types × multiple poses. Isometric wireframe construction, cyan visor accent.
          </p>

          <h3 style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase", color: "var(--text-link)", marginBottom: "var(--space-2)", marginTop: "var(--space-4)" }}>
            Isometric Grid — 5 Types × 6 Actions
          </h3>
          <RobotGrid />

          <h3 style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase", color: "var(--text-link)", marginBottom: "var(--space-2)", marginTop: "var(--space-6)" }}>
            Egghead Turntable — 10 Rotational Views
          </h3>
          <RobotEgghead />

          <h3 style={{ fontFamily: "var(--font-mono)", fontSize: "var(--font-size-xs)", fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase", color: "var(--text-link)", marginBottom: "var(--space-2)", marginTop: "var(--space-6)" }}>
            Metropolis Foundry — 7 Variants × 10 Poses
          </h3>
          <RobotFoundry />
        </div>

      </div>
    </div>
    <LayoutBar pageLayouts={config.pageLayouts} themes={listThemes().map((t) => ({ slug: t.slug, name: t.name }))} />
    </PageContent>
    </ThemeConfigProvider>
  );
}
