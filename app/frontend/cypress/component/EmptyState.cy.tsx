import { EmptyState } from "@/components/ui/EmptyState";
import { Button } from "@/components/ui/Button";

describe("<EmptyState>", () => {
  it("renders headline and glyph", () => {
    cy.mount(
      <EmptyState
        glyph="scripts"
        headline="No scripts yet"
        body="Create your first script to get started"
        cy="empty"
      />,
    );
    cy.getByCy("empty").should("contain.text", "No scripts yet");
    cy.getByCy("empty").find("svg").should("exist");
  });

  it("renders primary action", () => {
    const onClick = cy.stub().as("onClick");
    cy.mount(
      <EmptyState
        glyph="runs"
        headline="No runs"
        primaryAction={<Button onClick={onClick} cy="cta">Start run</Button>}
      />,
    );
    cy.getByCy("cta").click();
    cy.get("@onClick").should("have.been.calledOnce");
  });
});
