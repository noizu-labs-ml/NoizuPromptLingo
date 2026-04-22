import { Given, When, Then } from "@badeball/cypress-cucumber-preprocessor";

// ── Background ───────────────────────────────────────────────────────────

Given("I am on the chat page", () => {
  cy.visit("/chat");
});

// ── Room Listing ─────────────────────────────────────────────────────────

Then("I should see the chat page", () => {
  cy.getByCy("chat-page").should("exist");
});

Then("the rooms grid should be visible", () => {
  cy.getByCy("rooms-grid").should("be.visible");
});

Then("each room card should show a name, description, and message count", () => {
  cy.getByCy("room-card").first().within(() => {
    cy.getByCy("room-name").should("exist");
    cy.getByCy("room-description").should("exist");
    cy.getByCy("message-count").should("exist");
  });
});

Given("the API is slow to respond", () => {
  cy.intercept("GET", "**/api/chat/rooms*", (req) => {
    req.on("response", (res) => {
      res.setDelay(5000);
    });
  }).as("slowRooms");
});

Then("I should see loading skeletons", () => {
  cy.getByCy("rooms-loading").should("be.visible");
});

// ── Room Creation ────────────────────────────────────────────────────────

When("I click the {string} button", (label: string) => {
  const selectorMap: Record<string, string> = {
    "New Room": "new-room-btn",
    Create: "create-room-btn",
    Cancel: "cancel-room-btn",
    Send: "send-btn",
  };
  const selector = selectorMap[label];
  if (selector) {
    cy.getByCy(selector).click();
  } else {
    cy.contains("button", label).click();
  }
});

Then("I should see the new room form", () => {
  cy.getByCy("new-room-form").should("be.visible");
});

Then("I should see the {string} button", (label: string) => {
  const selectorMap: Record<string, string> = {
    "New Room": "new-room-btn",
  };
  const selector = selectorMap[label];
  if (selector) {
    cy.getByCy(selector).should("be.visible");
  } else {
    cy.contains("button", label).should("be.visible");
  }
});

When("I type {string} into the room name input", (text: string) => {
  cy.getByCy("room-name-input").clear().type(text);
});

Then("a success toast should appear with {string}", (message: string) => {
  cy.contains(message).should("be.visible");
});

Then("the rooms grid should contain a room named {string}", (name: string) => {
  cy.getByCy("rooms-grid").within(() => {
    cy.contains(name).should("exist");
  });
});

Then("the {string} button should be disabled", (label: string) => {
  const selectorMap: Record<string, string> = {
    Create: "create-room-btn",
    Send: "send-btn",
  };
  const selector = selectorMap[label];
  if (selector) {
    cy.getByCy(selector).should("be.disabled");
  } else {
    cy.contains("button", label).should("be.disabled");
  }
});

// ── Room Navigation ──────────────────────────────────────────────────────

Given("there is at least one room", () => {
  cy.getByCy("room-card").should("have.length.at.least", 1);
});

When("I click the first room card", () => {
  cy.getByCy("room-card").first().click();
});

Then("I should be on a chat room detail page", () => {
  cy.url().should("match", /\/chat\/\d+/);
  cy.getByCy("chat-room-page").should("exist");
});
