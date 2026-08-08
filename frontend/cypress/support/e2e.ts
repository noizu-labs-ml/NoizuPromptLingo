/// <reference types="cypress" />
import "./authentik";

beforeEach(() => {
  cy.clearCookies();
  cy.clearLocalStorage();
});
