import { When, Then } from "@badeball/cypress-cucumber-preprocessor";

const BUTTON_SELECTORS: Record<string, string> = {
  "New Room": "new-room-btn",
  Create: "create-room-btn",
  Cancel: "cancel-btn",
  Send: "send-btn",
  "New task": "new-task-btn",
  "New artifact": "new-artifact-btn",
  Save: "save-btn",
  Submit: "submit-btn",
  Back: "back-btn",
  Close: "close-btn",
  Refresh: "refresh-btn",
  Convert: "convert-btn",
  Load: "load-btn",
  Generate: "generate-btn",
  Invoke: "invoke-btn",
  Validate: "validate-btn",
  Evaluate: "evaluate-btn",
  Append: "append-btn",
};

When("I click the {string} button", (label: string) => {
  const selector = BUTTON_SELECTORS[label];
  if (selector) {
    cy.getByCy(selector).click();
  } else {
    cy.contains("button", label).click();
  }
});

Then("the {string} button should be disabled", (label: string) => {
  const selector = BUTTON_SELECTORS[label];
  if (selector) {
    cy.getByCy(selector).should("be.disabled");
  } else {
    cy.contains("button", label).should("be.disabled");
  }
});

When("I type {string} into the {string} input", (text: string, field: string) => {
  cy.getByCy(field).clear().type(text, { parseSpecialCharSequences: false });
});

When("I press Enter in the {string}", (field: string) => {
  cy.getByCy(field).type("{enter}");
});

When("I press Shift+Enter in the {string}", (field: string) => {
  cy.getByCy(field).type("{shift+enter}");
});

When("I press Escape", () => {
  cy.get("body").type("{esc}");
});

When("I press {string}", (keys: string) => {
  const keyMap: Record<string, string> = {
    "Cmd+K": "{meta}k",
    "Ctrl+K": "{ctrl}k",
    Escape: "{esc}",
    Enter: "{enter}",
  };
  cy.get("body").type(keyMap[keys] ?? keys);
});

When("I select {string} from the {string} dropdown", (value: string, field: string) => {
  cy.getByCy(field).select(value);
});

When("I clear the {string} input", (field: string) => {
  cy.getByCy(field).clear();
});
