import { Then } from "@badeball/cypress-cucumber-preprocessor";

Then("I should be on {string}", (path: string) => {
  cy.url().should("include", path);
});

Then("the URL should match {string}", (pattern: string) => {
  cy.url().should("match", new RegExp(pattern));
});
