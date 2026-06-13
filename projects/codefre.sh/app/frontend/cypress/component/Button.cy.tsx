import { Button } from "@/components/ui/Button";

describe("<Button>", () => {
  it("renders label and fires onClick", () => {
    const onClick = cy.stub().as("onClick");
    cy.mount(<Button onClick={onClick} cy="btn">Save</Button>);
    cy.getByCy("btn").should("have.text", "Save").click();
    cy.get("@onClick").should("have.been.calledOnce");
  });

  it("respects loading state (disables + spinner)", () => {
    cy.mount(<Button loading cy="btn">Save</Button>);
    cy.getByCy("btn").should("be.disabled");
  });

  it("renders each variant without crashing", () => {
    (["primary", "secondary", "ghost", "eval"] as const).forEach((v) => {
      cy.mount(<Button variant={v} cy={`btn-${v}`}>{v}</Button>);
      cy.getByCy(`btn-${v}`).should("be.visible");
    });
  });

  it("renders as <a> when href is provided", () => {
    cy.mount(<Button href="/somewhere" cy="btn">Go</Button>);
    cy.getByCy("btn").should("have.attr", "href", "/somewhere");
  });
});
