import { Then } from "@badeball/cypress-cucumber-preprocessor";

Then("{string} should be visible", (selector: string) => {
  cy.getByCy(selector).should("be.visible");
});

Then("{string} should exist", (selector: string) => {
  cy.getByCy(selector).should("exist");
});

Then("{string} should not exist", (selector: string) => {
  cy.getByCy(selector).should("not.exist");
});

Then("{string} should be disabled", (selector: string) => {
  cy.getByCy(selector).should("be.disabled");
});

Then("{string} should be enabled", (selector: string) => {
  cy.getByCy(selector).should("not.be.disabled");
});

Then("{string} should contain text {string}", (selector: string, text: string) => {
  cy.getByCy(selector).should("contain.text", text);
});

Then("{string} should have value {string}", (selector: string, value: string) => {
  cy.getByCy(selector).should("have.value", value);
});

Then("{string} should be empty", (selector: string) => {
  cy.getByCy(selector).should("have.value", "");
});

Then("{string} should not be empty", (selector: string) => {
  cy.getByCy(selector).should("not.have.value", "");
});

Then("I should see {int} {string} elements", (count: number, selector: string) => {
  cy.getByCy(selector).should("have.length", count);
});

Then("I should see at least {int} {string} elements", (count: number, selector: string) => {
  cy.getByCy(selector).should("have.length.at.least", count);
});

Then("the page should contain {string}", (text: string) => {
  cy.contains(text).should("be.visible");
});
