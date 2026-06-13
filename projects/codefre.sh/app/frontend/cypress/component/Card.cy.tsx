import { Card } from "@/components/ui/Card";

describe("<Card>", () => {
  it("renders children", () => {
    cy.mount(<Card data-cy="card">hello</Card>);
    cy.get("[data-cy='card']").should("contain.text", "hello");
  });

  it("applies each variant class", () => {
    (["default", "active", "pass", "warn", "fail", "freeball"] as const).forEach(
      (variant) => {
        cy.mount(<Card variant={variant} data-cy={`card-${variant}`}>{variant}</Card>);
        cy.get(`[data-cy='card-${variant}']`).should("be.visible");
      },
    );
  });

  it("fires onClick when interactive", () => {
    const onClick = cy.stub().as("onClick");
    cy.mount(<Card interactive onClick={onClick} data-cy="card">Click me</Card>);
    cy.get("[data-cy='card']").click();
    cy.get("@onClick").should("have.been.calledOnce");
  });
});
