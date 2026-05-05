import { Given, When, Then } from "@badeball/cypress-cucumber-preprocessor";

// ── Background ───────────────────────────────────────────────────────────

Given("I am on the chat page", () => {
  cy.intercept("GET", "**/api/chat/rooms*", { fixture: "chat/rooms.json" }).as("listRooms");
  cy.visit("/chat");
  cy.getByCy("chat-page").should("exist");
});

// ── Room Listing ─────────────────────────────────────────────────────────

Then("I should see the chat page", () => {
  cy.getByCy("chat-page").should("exist");
});

Then("the rooms grid should be visible", () => {
  cy.getByCy("rooms-grid").should("exist");
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

Then("the rooms grid should contain a room named {string}", (name: string) => {
  cy.getByCy("rooms-grid").within(() => {
    cy.contains(name).should("exist");
  });
});

Given("the room creation API is stubbed", () => {
  cy.intercept("POST", "**/api/chat/rooms", { fixture: "chat/room-created.json" }).as("createRoom");
});

// ── Room Navigation ──────────────────────────────────────────────────────

Given("there is at least one room", () => {
  cy.getByCy("room-card").should("have.length.at.least", 1);
});

When("I click the first room card", () => {
  cy.intercept("GET", "**/api/chat/rooms/1", { fixture: "chat/room-1.json" }).as("getRoom");
  cy.intercept("GET", "**/api/chat/rooms/1/messages*", { fixture: "chat/messages-1.json" }).as("getMessages");
  cy.getByCy("room-card").first().click();
});

Then("I should be on a chat room detail page", () => {
  cy.url().should("match", /\/chat\/\d+/);
  cy.getByCy("chat-room-page").should("exist");
});
