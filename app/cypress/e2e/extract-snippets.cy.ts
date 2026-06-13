/**
 * Extracts React code snippets from Tailwind Plus UI Blocks.
 *
 * Run:
 *   npx cypress run --spec cypress/e2e/extract-snippets.cy.ts
 *
 * Or interactively:
 *   npx cypress open
 *
 * Credentials via env:
 *   CYPRESS_TW_EMAIL=you@example.com CYPRESS_TW_PASSWORD=secret npx cypress run ...
 *   or create cypress.env.json (gitignored)
 */

interface ComponentPage {
  category: string;
  slug: string;
  path: string;
}

const APP_UI: ComponentPage[] = [
  { category: "app-ui/shells", slug: "stacked-layouts", path: "/plus/ui-blocks/application-ui/application-shells/stacked" },
  { category: "app-ui/shells", slug: "sidebar-layouts", path: "/plus/ui-blocks/application-ui/application-shells/sidebar" },
  { category: "app-ui/shells", slug: "multi-column-layouts", path: "/plus/ui-blocks/application-ui/application-shells/multi-column" },
  { category: "app-ui/headings", slug: "page-headings", path: "/plus/ui-blocks/application-ui/headings/page-headings" },
  { category: "app-ui/headings", slug: "card-headings", path: "/plus/ui-blocks/application-ui/headings/card-headings" },
  { category: "app-ui/headings", slug: "section-headings", path: "/plus/ui-blocks/application-ui/headings/section-headings" },
  { category: "app-ui/data-display", slug: "description-lists", path: "/plus/ui-blocks/application-ui/data-display/description-lists" },
  { category: "app-ui/data-display", slug: "stats", path: "/plus/ui-blocks/application-ui/data-display/stats" },
  { category: "app-ui/data-display", slug: "calendars", path: "/plus/ui-blocks/application-ui/data-display/calendars" },
  { category: "app-ui/lists", slug: "stacked-lists", path: "/plus/ui-blocks/application-ui/lists/stacked-lists" },
  { category: "app-ui/lists", slug: "tables", path: "/plus/ui-blocks/application-ui/lists/tables" },
  { category: "app-ui/lists", slug: "grid-lists", path: "/plus/ui-blocks/application-ui/lists/grid-lists" },
  { category: "app-ui/lists", slug: "feeds", path: "/plus/ui-blocks/application-ui/lists/feeds" },
  { category: "app-ui/forms", slug: "form-layouts", path: "/plus/ui-blocks/application-ui/forms/form-layouts" },
  { category: "app-ui/forms", slug: "input-groups", path: "/plus/ui-blocks/application-ui/forms/input-groups" },
  { category: "app-ui/forms", slug: "select-menus", path: "/plus/ui-blocks/application-ui/forms/select-menus" },
  { category: "app-ui/forms", slug: "sign-in-forms", path: "/plus/ui-blocks/application-ui/forms/sign-in-forms" },
  { category: "app-ui/forms", slug: "textareas", path: "/plus/ui-blocks/application-ui/forms/textareas" },
  { category: "app-ui/forms", slug: "radio-groups", path: "/plus/ui-blocks/application-ui/forms/radio-groups" },
  { category: "app-ui/forms", slug: "checkboxes", path: "/plus/ui-blocks/application-ui/forms/checkboxes" },
  { category: "app-ui/forms", slug: "toggles", path: "/plus/ui-blocks/application-ui/forms/toggles" },
  { category: "app-ui/forms", slug: "action-panels", path: "/plus/ui-blocks/application-ui/forms/action-panels" },
  { category: "app-ui/forms", slug: "comboboxes", path: "/plus/ui-blocks/application-ui/forms/comboboxes" },
  { category: "app-ui/feedback", slug: "alerts", path: "/plus/ui-blocks/application-ui/feedback/alerts" },
  { category: "app-ui/feedback", slug: "empty-states", path: "/plus/ui-blocks/application-ui/feedback/empty-states" },
  { category: "app-ui/navigation", slug: "navbars", path: "/plus/ui-blocks/application-ui/navigation/navbars" },
  { category: "app-ui/navigation", slug: "pagination", path: "/plus/ui-blocks/application-ui/navigation/pagination" },
  { category: "app-ui/navigation", slug: "tabs", path: "/plus/ui-blocks/application-ui/navigation/tabs" },
  { category: "app-ui/navigation", slug: "vertical-navigation", path: "/plus/ui-blocks/application-ui/navigation/vertical-navigation" },
  { category: "app-ui/navigation", slug: "sidebar-navigation", path: "/plus/ui-blocks/application-ui/navigation/sidebar-navigation" },
  { category: "app-ui/navigation", slug: "breadcrumbs", path: "/plus/ui-blocks/application-ui/navigation/breadcrumbs" },
  { category: "app-ui/navigation", slug: "progress-bars", path: "/plus/ui-blocks/application-ui/navigation/progress-bars" },
  { category: "app-ui/navigation", slug: "command-palettes", path: "/plus/ui-blocks/application-ui/navigation/command-palettes" },
  { category: "app-ui/overlays", slug: "modal-dialogs", path: "/plus/ui-blocks/application-ui/overlays/modal-dialogs" },
  { category: "app-ui/overlays", slug: "drawers", path: "/plus/ui-blocks/application-ui/overlays/drawers" },
  { category: "app-ui/overlays", slug: "notifications", path: "/plus/ui-blocks/application-ui/overlays/notifications" },
  { category: "app-ui/elements", slug: "avatars", path: "/plus/ui-blocks/application-ui/elements/avatars" },
  { category: "app-ui/elements", slug: "badges", path: "/plus/ui-blocks/application-ui/elements/badges" },
  { category: "app-ui/elements", slug: "dropdowns", path: "/plus/ui-blocks/application-ui/elements/dropdowns" },
  { category: "app-ui/elements", slug: "buttons", path: "/plus/ui-blocks/application-ui/elements/buttons" },
  { category: "app-ui/elements", slug: "button-groups", path: "/plus/ui-blocks/application-ui/elements/button-groups" },
  { category: "app-ui/layout", slug: "containers", path: "/plus/ui-blocks/application-ui/layout/containers" },
  { category: "app-ui/layout", slug: "cards", path: "/plus/ui-blocks/application-ui/layout/cards" },
  { category: "app-ui/layout", slug: "list-containers", path: "/plus/ui-blocks/application-ui/layout/list-containers" },
  { category: "app-ui/layout", slug: "media-objects", path: "/plus/ui-blocks/application-ui/layout/media-objects" },
  { category: "app-ui/layout", slug: "dividers", path: "/plus/ui-blocks/application-ui/layout/dividers" },
  { category: "app-ui/pages", slug: "home-screens", path: "/plus/ui-blocks/application-ui/page-examples/home-screens" },
  { category: "app-ui/pages", slug: "detail-screens", path: "/plus/ui-blocks/application-ui/page-examples/detail-screens" },
  { category: "app-ui/pages", slug: "settings-screens", path: "/plus/ui-blocks/application-ui/page-examples/settings-screens" },
];

const MARKETING: ComponentPage[] = [
  { category: "marketing/sections", slug: "heroes", path: "/plus/ui-blocks/marketing/sections/heroes" },
  { category: "marketing/sections", slug: "feature-sections", path: "/plus/ui-blocks/marketing/sections/feature-sections" },
  { category: "marketing/sections", slug: "cta-sections", path: "/plus/ui-blocks/marketing/sections/cta-sections" },
  { category: "marketing/sections", slug: "bento-grids", path: "/plus/ui-blocks/marketing/sections/bento-grids" },
  { category: "marketing/sections", slug: "pricing", path: "/plus/ui-blocks/marketing/sections/pricing" },
  { category: "marketing/sections", slug: "header", path: "/plus/ui-blocks/marketing/sections/header" },
  { category: "marketing/sections", slug: "newsletter-sections", path: "/plus/ui-blocks/marketing/sections/newsletter-sections" },
  { category: "marketing/sections", slug: "stats-sections", path: "/plus/ui-blocks/marketing/sections/stats-sections" },
  { category: "marketing/sections", slug: "testimonials", path: "/plus/ui-blocks/marketing/sections/testimonials" },
  { category: "marketing/sections", slug: "blog-sections", path: "/plus/ui-blocks/marketing/sections/blog-sections" },
  { category: "marketing/sections", slug: "contact-sections", path: "/plus/ui-blocks/marketing/sections/contact-sections" },
  { category: "marketing/sections", slug: "team-sections", path: "/plus/ui-blocks/marketing/sections/team-sections" },
  { category: "marketing/sections", slug: "content-sections", path: "/plus/ui-blocks/marketing/sections/content-sections" },
  { category: "marketing/sections", slug: "logo-clouds", path: "/plus/ui-blocks/marketing/sections/logo-clouds" },
  { category: "marketing/sections", slug: "faq-sections", path: "/plus/ui-blocks/marketing/sections/faq-sections" },
  { category: "marketing/sections", slug: "footers", path: "/plus/ui-blocks/marketing/sections/footers" },
  { category: "marketing/elements", slug: "headers", path: "/plus/ui-blocks/marketing/elements/headers" },
  { category: "marketing/elements", slug: "flyout-menus", path: "/plus/ui-blocks/marketing/elements/flyout-menus" },
  { category: "marketing/elements", slug: "banners", path: "/plus/ui-blocks/marketing/elements/banners" },
  { category: "marketing/feedback", slug: "404-pages", path: "/plus/ui-blocks/marketing/feedback/404-pages" },
  { category: "marketing/pages", slug: "landing-pages", path: "/plus/ui-blocks/marketing/page-examples/landing-pages" },
  { category: "marketing/pages", slug: "pricing-pages", path: "/plus/ui-blocks/marketing/page-examples/pricing-pages" },
  { category: "marketing/pages", slug: "about-pages", path: "/plus/ui-blocks/marketing/page-examples/about-pages" },
];

const ECOMMERCE: ComponentPage[] = [
  { category: "ecommerce/components", slug: "product-overviews", path: "/plus/ui-blocks/ecommerce/components/product-overviews" },
  { category: "ecommerce/components", slug: "product-lists", path: "/plus/ui-blocks/ecommerce/components/product-lists" },
  { category: "ecommerce/components", slug: "category-previews", path: "/plus/ui-blocks/ecommerce/components/category-previews" },
  { category: "ecommerce/components", slug: "shopping-carts", path: "/plus/ui-blocks/ecommerce/components/shopping-carts" },
  { category: "ecommerce/components", slug: "category-filters", path: "/plus/ui-blocks/ecommerce/components/category-filters" },
  { category: "ecommerce/components", slug: "product-quickviews", path: "/plus/ui-blocks/ecommerce/components/product-quickviews" },
  { category: "ecommerce/components", slug: "product-features", path: "/plus/ui-blocks/ecommerce/components/product-features" },
  { category: "ecommerce/components", slug: "store-navigation", path: "/plus/ui-blocks/ecommerce/components/store-navigation" },
  { category: "ecommerce/components", slug: "promo-sections", path: "/plus/ui-blocks/ecommerce/components/promo-sections" },
  { category: "ecommerce/components", slug: "checkout-forms", path: "/plus/ui-blocks/ecommerce/components/checkout-forms" },
  { category: "ecommerce/components", slug: "reviews", path: "/plus/ui-blocks/ecommerce/components/reviews" },
  { category: "ecommerce/components", slug: "order-summaries", path: "/plus/ui-blocks/ecommerce/components/order-summaries" },
  { category: "ecommerce/components", slug: "order-history", path: "/plus/ui-blocks/ecommerce/components/order-history" },
  { category: "ecommerce/components", slug: "incentives", path: "/plus/ui-blocks/ecommerce/components/incentives" },
  { category: "ecommerce/pages", slug: "storefront-pages", path: "/plus/ui-blocks/ecommerce/page-examples/storefront-pages" },
  { category: "ecommerce/pages", slug: "product-pages", path: "/plus/ui-blocks/ecommerce/page-examples/product-pages" },
  { category: "ecommerce/pages", slug: "category-pages", path: "/plus/ui-blocks/ecommerce/page-examples/category-pages" },
  { category: "ecommerce/pages", slug: "shopping-cart-pages", path: "/plus/ui-blocks/ecommerce/page-examples/shopping-cart-pages" },
  { category: "ecommerce/pages", slug: "checkout-pages", path: "/plus/ui-blocks/ecommerce/page-examples/checkout-pages" },
  { category: "ecommerce/pages", slug: "order-detail-pages", path: "/plus/ui-blocks/ecommerce/page-examples/order-detail-pages" },
  { category: "ecommerce/pages", slug: "order-history-pages", path: "/plus/ui-blocks/ecommerce/page-examples/order-history-pages" },
];

const ALL_PAGES = [...APP_UI, ...MARKETING, ...ECOMMERCE];

function extractFromPage(page: ComponentPage) {
  it(`${page.category}/${page.slug}`, () => {
    cy.task("log", `START ${page.category}/${page.slug} — ${page.path}`);
    cy.visit(page.path);
    cy.wait(2000);

    // Screenshot the full page (preview state)
    const screenshotPrefix = `${page.category}/${page.slug}`;
    cy.screenshot(`${screenshotPrefix}/preview`, { capture: "fullPage" });

    // Switch each component block to React view and extract the code
    cy.get("body").then(($body) => {
      const snippetBlocks = $body.find('[data-component-id], [id^="component-"]').toArray();

      if (snippetBlocks.length === 0) {
        cy.get('button').filter(':contains("Code")').then(($codeButtons) => {
          if ($codeButtons.length === 0) {
            cy.task("log", `SKIP ${page.category}/${page.slug} — no code buttons found`);
            return;
          }

          cy.task("log", `FOUND ${$codeButtons.length} code blocks on ${page.slug}`);
          const entries: { name: string; file: string }[] = [];

          $codeButtons.each((index) => {
            const variantName = `${page.slug}-${String(index + 1).padStart(2, "0")}`;

            cy.get('button').filter(':contains("Code")').eq(index).click({ force: true });
            cy.wait(500);

            // Switch to React tab if available
            cy.get('body').then(($b) => {
              const reactTab = $b.find('button:contains("React"), [data-language="react"], [data-language="jsx"]');
              if (reactTab.length > 0) {
                cy.wrap(reactTab.first()).click({ force: true });
                cy.wait(300);
              }
            });

            // Screenshot the code view for this variant
            cy.screenshot(`${screenshotPrefix}/${variantName}`, { capture: "viewport" });

            // Extract the code content
            cy.get('pre code, [data-code], .code-block code, textarea[readonly]')
              .eq(index)
              .then(($code) => {
                const code = $code.text().trim();
                if (code.length > 10) {
                  cy.task("log", `EXTRACT ${variantName} — ${code.length} chars`);
                  cy.task("writeSnippet", {
                    category: page.category,
                    name: variantName,
                    code,
                  }).then((file) => {
                    entries.push({ name: variantName, file: file as string });
                  });
                } else {
                  cy.task("log", `EMPTY ${variantName} — only ${code.length} chars`);
                }
              });
          });

          cy.then(() => {
            if (entries.length > 0) {
              cy.task("writeIndex", { category: page.category, entries });
              cy.task("log", `DONE ${page.category}/${page.slug} — ${entries.length} snippets extracted`);
            } else {
              cy.task("log", `DONE ${page.category}/${page.slug} — no snippets extracted`);
            }
          });
        });
      }
    });
  });
}

describe("Tailwind Plus — Extract React Snippets", () => {
  before(() => {
    cy.twLogin();
  });

  beforeEach(() => {
    cy.twLogin();
  });

  // Split into separate describe blocks so failures don't stop the whole suite
  describe("Application UI", () => {
    APP_UI.forEach(extractFromPage);
  });

  describe("Marketing", () => {
    MARKETING.forEach(extractFromPage);
  });

  describe("Ecommerce", () => {
    ECOMMERCE.forEach(extractFromPage);
  });
});
