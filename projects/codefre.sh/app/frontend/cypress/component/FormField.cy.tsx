import { useState } from "react";
import { FormField } from "@/components/ui/FormField";
import { TextInput } from "@/components/ui/TextInput";

describe("<FormField> + <TextInput>", () => {
  it("wires label, hint, and aria-describedby", () => {
    cy.mount(
      <FormField label="Email" name="email" hint="We never share it" required>
        {(p) => <TextInput {...p} type="email" data-cy="email-input" />}
      </FormField>,
    );
    cy.get("[data-cy='email-input']").then(($input) => {
      const describedBy = $input.attr("aria-describedby");
      expect(describedBy, "aria-describedby is set").to.be.a("string");
      cy.get(`#${describedBy}`).should("contain.text", "We never share it");
    });
  });

  it("surfaces error message", () => {
    cy.mount(
      <FormField label="Email" name="email" error="Bad email" required>
        {(p) => <TextInput {...p} type="email" error data-cy="email-input" />}
      </FormField>,
    );
    cy.contains("Bad email").should("be.visible");
  });

  it("typing updates controlled value", () => {
    function Harness() {
      const [v, setV] = useState("");
      return (
        <FormField label="Name" name="name">
          {(p) => (
            <TextInput
              {...p}
              value={v}
              onChange={(e) => setV(e.target.value)}
              data-cy="name-input"
            />
          )}
        </FormField>
      );
    }
    cy.mount(<Harness />);
    cy.get("[data-cy='name-input']").type("alice").should("have.value", "alice");
  });
});
