describe("Tailwind Plus — Login", () => {
  it("authenticates and reaches the UI blocks page", () => {
    cy.twLogin();
    cy.visit("/plus/ui-blocks");
    cy.contains("Application UI").should("be.visible");
  });
});
