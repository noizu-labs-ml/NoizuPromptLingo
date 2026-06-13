import { Then } from "@badeball/cypress-cucumber-preprocessor";

Then("I should see a loading state", () => {
  cy.get("[class*=animate-pulse], [class*=animate-spin]").should("exist");
});
