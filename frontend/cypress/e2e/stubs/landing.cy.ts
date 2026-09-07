/**
 * Public Prompt Lingo landing — evangelist surface.
 * Gallery is stubbed so the live engine is not required.
 */

const GALLERY = {
  sections: [
    {
      section: "syntax",
      name: "syntax",
      slug: "syntax",
      title: "NPL Syntax Overview",
      brief: "Foundational formatting, placeholders, and patterns.",
      description: "",
      component_count: 12,
      category_count: 3,
      sample: "⌜NPL@1.0⌝\n##### Placeholder\n\"{term}\"\n: Standard placeholder.",
    },
  ],
};

function visitLanding() {
  cy.intercept("GET", "**/api/v1/npl/gallery", GALLERY).as("gallery");
  cy.visit("/");
  cy.wait("@gallery");
}

describe("Landing page (stubbed)", () => {
  it("sells the syntax and the open-source repo", () => {
    visitLanding();
    cy.contains("h1", "Prompts deserve a real syntax.").should("be.visible");
    cy.get('[data-cy="github-cta"]').should("have.attr", "href").and("include", "NoizuPromptLingo");
    cy.get('[data-cy="mcp-copy"]').should("be.visible");
    cy.get('[data-cy="mcp-cmd"]').should("contain", "claude mcp add");
    cy.get(".tl-hero-art__img").should("be.visible");
  });

  it("offers a VFS mount command", () => {
    visitLanding();
    cy.contains("h2", "Browse the syntax as files").should("be.visible");
    cy.get('[data-cy="vfs-cmd"]').should("contain", "mcp-mount");
    cy.get('[data-cy="vfs-cmd"]').should("contain", "promptlingo.dev/vfs");
  });

  it("shows real convention examples with outputs", () => {
    visitLanding();
    cy.get('[data-cy="npl-examples"]').should("be.visible");
    cy.get('[data-cy="npl-example-placeholder"]').should("contain", "{user.name}");
    cy.get('[data-cy="npl-example-in-fill"]').should("contain", "turquoise");
    cy.get('[data-cy="npl-example-prefixes"]').should("contain", "🖋️➤");
    cy.get('[data-cy="npl-example-cot"]').should("contain", "npl-cot");
  });

  it("does not render tobor locker pricing", () => {
    visitLanding();
    cy.get('[data-cy="pricing"]').should("not.exist");
    cy.contains("Get early access").should("not.exist");
    cy.contains(".tl-feature__name", "Tickets").should("not.exist");
  });
});
