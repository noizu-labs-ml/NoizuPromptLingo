import { Given, When, Then } from "@badeball/cypress-cucumber-preprocessor";

// ── Background ───────────────────────────────────────────────────────────

Given("I am in chat room {string}", (roomId: string) => {
  if (roomId === "99999") {
    cy.intercept("GET", `**/api/chat/rooms/${roomId}`, {
      statusCode: 404,
      body: { detail: "Not found" },
    }).as("getRoom");
    cy.intercept("GET", `**/api/chat/rooms/${roomId}/messages*`, {
      body: { items: [], count: 0 },
    }).as("getMessages");
  } else {
    cy.intercept("GET", `**/api/chat/rooms/${roomId}`, { fixture: "chat/room-1.json" }).as("getRoom");
    cy.intercept("GET", `**/api/chat/rooms/${roomId}/messages*`, { fixture: "chat/messages-1.json" }).as("getMessages");
  }
  cy.intercept("POST", `**/api/chat/rooms/${roomId}/messages`, {
    statusCode: 200,
    body: { id: 99, room_id: Number(roomId), content: "", author: "user", created_at: "2026-04-23T12:00:00Z" },
  }).as("sendMessage");
  cy.visit(`/chat/${roomId}`);
});

// ── Room Detail ──────────────────────────────────────────────────────────

Then("I should see the chat room page", () => {
  cy.getByCy("chat-room-page").should("exist");
});

Then("the message feed should be visible", () => {
  cy.getByCy("message-feed").should("be.visible");
});

Then("the message composer should be visible", () => {
  cy.getByCy("message-composer").should("be.visible");
});

// ── Empty State ──────────────────────────────────────────────────────────

Given("the room has no messages", () => {
  cy.intercept("GET", "**/api/chat/rooms/*/messages*", {
    statusCode: 200,
    body: { items: [], count: 0 },
  }).as("emptyMessages");
});

Then("I should see the empty messages placeholder", () => {
  cy.getByCy("empty-messages").should("be.visible");
});

// ── Message Display ──────────────────────────────────────────────────────

Given("the room has messages", () => {
  cy.getByCy("message-item").should("have.length.at.least", 1);
});

Then("each message should show an author", () => {
  cy.getByCy("message-item").first().within(() => {
    cy.getByCy("message-author").should("exist").and("not.be.empty");
  });
});

Then("each message should show content", () => {
  cy.getByCy("message-item").first().within(() => {
    cy.getByCy("message-content").should("exist").and("not.be.empty");
  });
});

Then("each message should show a timestamp", () => {
  cy.getByCy("message-item").first().within(() => {
    cy.getByCy("message-time").should("exist");
  });
});

// ── Sending Messages ─────────────────────────────────────────────────────

When("I type {string} into the message input", (text: string) => {
  cy.getByCy("message-input").clear().type(text, { parseSpecialCharSequences: false });
});

Then("the message input should be empty", () => {
  cy.getByCy("message-input").should("have.value", "");
});

Then("the message input should not be empty", () => {
  cy.getByCy("message-input").should("not.have.value", "");
});

Then("the message feed should contain {string}", (text: string) => {
  cy.getByCy("message-feed").should("contain.text", text);
});

When("I press Enter in the message input", () => {
  cy.getByCy("message-input").type("{enter}");
});

When("I press Shift+Enter in the message input", () => {
  cy.getByCy("message-input").type("{shift+enter}");
});

Then("the message should not be sent", () => {
  cy.getByCy("message-input").should("not.have.value", "");
});

Then("the send button should be disabled", () => {
  cy.getByCy("send-btn").should("be.disabled");
});

// ── Room Not Found ───────────────────────────────────────────────────────

Given("I am in a room that returns not found", () => {
  cy.intercept("GET", "**/api/chat/rooms/5", {
    statusCode: 404,
    body: { detail: "Not found" },
  }).as("getRoom404");
  cy.intercept("GET", "**/api/chat/rooms/5/messages*", {
    body: { items: [], count: 0 },
  }).as("getMessages404");
  cy.visit("/chat/5");
});

Then("I should see the room not found state", () => {
  cy.contains("Room not found").should("be.visible");
});

Then("I should see a link back to chat rooms", () => {
  cy.getByCy("back-to-rooms-link").should("be.visible").and("have.attr", "href", "/chat");
});

// ── Error Handling ───────────────────────────────────────────────────────

Given("the API will fail on message send", () => {
  cy.intercept("POST", "**/api/chat/rooms/*/messages", {
    statusCode: 500,
    body: { detail: "Internal server error" },
  }).as("failedSend");
});
