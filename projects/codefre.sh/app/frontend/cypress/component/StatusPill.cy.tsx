import { StatusPill } from "@/components/ui/StatusPill";

describe("<StatusPill>", () => {
  const states = [
    "pending",
    "running",
    "pass",
    "warn",
    "fail",
    "freeball",
    "cancelled",
    "error",
  ] as const;

  states.forEach((state) => {
    it(`renders ${state} with redundant color + label encoding`, () => {
      cy.mount(<StatusPill state={state} cy={`pill-${state}`} />);
      cy.getByCy(`pill-${state}`).should("be.visible");
      cy.getByCy(`pill-${state}`).should("have.attr", "data-cy-value", state);
    });
  });
});
