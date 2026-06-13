/**
 * Phase 1: Discover all component pages from the Tailwind Plus sidebar nav.
 *
 * Logs in, visits each section index, scrapes the sidebar for groups + links,
 * screenshots each page, and writes the full sitemap to cypress/fixtures/sitemap.json.
 *
 * Run:
 *   CYPRESS_TW_EMAIL=... CYPRESS_TW_PASSWORD=... npx cypress run --headed --spec cypress/e2e/discover-pages.cy.ts
 */

interface DiscoveredPage {
  section: string;
  group: string;
  name: string;
  href: string;
}

const SECTION_INDEXES = [
  { section: "application-ui", path: "/plus/ui-blocks/application-ui" },
  { section: "marketing", path: "/plus/ui-blocks/marketing" },
  { section: "ecommerce", path: "/plus/ui-blocks/ecommerce" },
];

describe("Tailwind Plus — Discover Pages", () => {
  const allPages: DiscoveredPage[] = [];

  before(() => {
    cy.twLogin();
  });

  SECTION_INDEXES.forEach(({ section, path }) => {
    it(`discovers pages in ${section}`, () => {
      cy.twLogin();
      cy.visit(path);
      cy.wait(2000);
      cy.screenshot(`discovery/${section}-index`, { capture: "fullPage" });

      // Sidebar groups: each is an <li> containing an <h3> (group name) + <ul> of links
      // The sidebar lives in the left column with the autoscroll container
      cy.get('[data-autoscroll="true"] ul[role="list"] > li').each(($li) => {
        const $h3 = $li.find("h3");
        if ($h3.length === 0) return; // skip the top-level section nav (no h3)

        const group = $h3.text().trim();

        $li.find("ul a").each((_i, el) => {
          const $a = Cypress.$(el);
          const name = $a.text().trim();
          const href = $a.attr("href") || "";

          if (href && name) {
            allPages.push({ section, group, name, href });
          }
        });
      });

      cy.task("log", `DISCOVERED ${section}: found groups in sidebar`);
    });
  });

  it("writes sitemap and visits each discovered page", () => {
    // Write the discovered sitemap
    cy.then(() => {
      cy.task("log", `TOTAL DISCOVERED: ${allPages.length} pages`);
      cy.task("writeIndex", {
        category: ".",
        entries: allPages.map((p) => ({
          name: `${p.section}/${p.group}/${p.name}`,
          file: p.href,
        })),
      });

      // Also write a structured sitemap
      cy.writeFile("cypress/fixtures/sitemap.json", JSON.stringify(allPages, null, 2));
    });

    // Visit each discovered page, screenshot it, and log it
    cy.then(() => {
      const visitPage = (index: number) => {
        if (index >= allPages.length) return;

        const page = allPages[index];
        const slug = page.href.split("/").slice(-2).join("/");
        const screenshotName = `pages/${page.section}/${slug}`;

        cy.task("log", `VISIT [${index + 1}/${allPages.length}] ${page.section} > ${page.group} > ${page.name}`);
        cy.visit(page.href);
        cy.wait(1500);
        cy.screenshot(screenshotName, { capture: "fullPage" });

        // Count how many component blocks are on this page
        cy.get("body").then(($body) => {
          // Component blocks typically have a "Code" button or similar toggle
          const codeButtons = $body.find('button:contains("Code")').length;
          cy.task("log", `  → ${page.name}: ${codeButtons} code blocks found`);
        });

        // Recurse to next page
        cy.then(() => visitPage(index + 1));
      };

      visitPage(0);
    });
  });
});
