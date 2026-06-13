import { Then } from "@badeball/cypress-cucumber-preprocessor";

Then("a success toast should appear with {string}", (message: string) => {
  cy.contains(message).should("be.visible");
});

Then("an error toast should appear with {string}", (message: string) => {
  cy.contains(message).should("be.visible");
});
