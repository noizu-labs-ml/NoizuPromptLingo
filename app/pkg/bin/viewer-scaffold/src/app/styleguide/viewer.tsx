"use client";

import { ThemeConfigProvider } from "@noizu/styleguide/viewer";
import { ThemeAwareSections } from "@noizu/styleguide/viewer";
import { PageContent } from "@noizu/styleguide/viewer";
import { ShellChrome } from "@noizu/styleguide/viewer";
import { LayoutBar } from "@noizu/styleguide/viewer";

export default function StyleGuideViewer(props: {
  config: any; branding: any; allConfigs: any; allBrandings: any;
  allNumberedGroups: any; numberedGroups: any; allCssSections: any;
  styleGuideFiles: any; brandingYaml: string; themes: { slug: string; name: string }[];
}) {
  return (
    <ThemeConfigProvider primaryConfig={props.config} primaryBranding={props.branding} allConfigs={props.allConfigs} allBrandings={props.allBrandings}>
      <PageContent defaultSelected={props.config.semanticClasses[0]?.name || ""}>
        <div className="shell-grid">
          <ShellChrome shellLayouts={props.config.shellLayouts} />
          <div className="content" style={{ paddingBottom: "6rem" }}>
            <ThemeAwareSections
              allNumberedGroups={props.allNumberedGroups} numberedGroups={props.numberedGroups}
              allCssSections={props.allCssSections} styleGuideFiles={props.styleGuideFiles}
              brandingYaml={props.brandingYaml}
            />
          </div>
        </div>
        <LayoutBar pageLayouts={props.config.pageLayouts} themes={props.themes} />
      </PageContent>
    </ThemeConfigProvider>
  );
}
