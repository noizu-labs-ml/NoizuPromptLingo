import { Given, When, Then } from "@badeball/cypress-cucumber-preprocessor";

// ── Background ───────────────────────────────────────────────────────────

Given("I am on the tasks page", () => {
  // Intercept task detail API to prevent navigation side effects
  cy.intercept("GET", /\/api\/tasks\/\d+$/, { fixture: "tasks/detail-1.json" }).as("getTask");
  cy.intercept("GET", "**/api/tasks?*", { fixture: "tasks/list.json" }).as("listTasksFiltered");
  cy.intercept("GET", /\/api\/tasks$/, { fixture: "tasks/list.json" }).as("listTasks");
  cy.visit("/tasks");
  cy.getByCy("tasks-page").should("exist");
});

// ── API Stubs ────────────────────────────────────────────────────────────

Given("the task status update API is stubbed", () => {
  cy.intercept("PATCH", "**/api/tasks/*/status", {
    fixture: "tasks/updated-status.json",
  }).as("updateTaskStatus");
  // After status update, mutate() will refetch the list — return updated fixture
  cy.intercept("GET", /\/api\/tasks(\?.*)?$/, { fixture: "tasks/list-after-update.json" }).as("relistTasks");
});

Given("the tasks API returns no results", () => {
  cy.intercept("GET", "**/api/tasks*", { fixture: "tasks/empty.json" }).as("listTasksEmpty");
});

Given("the task creation API is stubbed", () => {
  cy.intercept("POST", "**/api/tasks", { fixture: "tasks/created.json" }).as("createTask");
});

Given("the task creation API will fail", () => {
  cy.intercept("POST", "**/api/tasks", {
    statusCode: 500,
    body: { detail: "Internal server error" },
  }).as("createTaskFail");
});

// ── Inline Status Change ─────────────────────────────────────────────────

When("I change the status of the first task to {string}", (status: string) => {
  cy.getByCy("tasks-list").should("exist");
  // The select is inside a <Link>; use force to bypass anchor interactability
  cy.getByCy("task-status-select").first().then(($select) => {
    // Programmatically set value and dispatch native change event
    const nativeInputValueSetter = Object.getOwnPropertyDescriptor(
      window.HTMLSelectElement.prototype, "value"
    )!.set!;
    nativeInputValueSetter.call($select[0], status);
    $select[0].dispatchEvent(new Event("change", { bubbles: true }));
  });
  cy.wait("@updateTaskStatus");
});

Then("the first task status select should have value {string}", (value: string) => {
  cy.getByCy("task-status-select").first().should("have.value", value);
});

// ── Task-Specific Buttons ────────────────────────────────────────────────

When("I click the create task button", () => {
  cy.getByCy("create-task-btn").click();
});

When("I click the task form cancel button", () => {
  cy.getByCy("cancel-form-btn").click();
});
