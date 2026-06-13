/**
 * Cypress intercept helper module.
 *
 * Provides stub functions for every API namespace so tests can
 * declaratively wire up fixture-backed responses.
 *
 * Pattern:
 *   stubXxxList()    — intercept the list/index endpoint
 *   stubXxxDetail()  — intercept a single-resource GET
 *   stubXxxCreate()  — intercept the POST creation endpoint
 *
 * All functions accept an optional `fixture` override.
 */

// ── Tasks ───────────────────────────────────────────────────────────────

export function stubTasksList(fixture = "tasks/list.json") {
  cy.intercept("GET", "**/api/tasks*", { fixture }).as("listTasks");
}

export function stubTasksDetail(id: string | number, fixture = "tasks/detail-1.json") {
  cy.intercept("GET", `**/api/tasks/${id}`, { fixture }).as("getTask");
}

export function stubTasksCreate(fixture = "tasks/created.json") {
  cy.intercept("POST", "**/api/tasks", { fixture }).as("createTask");
}

export function stubTasksUpdateStatus(id: string | number, fixture = "tasks/detail-1.json") {
  cy.intercept("PATCH", `**/api/tasks/${id}/status`, { fixture }).as("updateTaskStatus");
}

// ── Artifacts ───────────────────────────────────────────────────────────

export function stubArtifactsList(fixture = "artifacts/list.json") {
  cy.intercept("GET", "**/api/artifacts*", { fixture }).as("listArtifacts");
}

export function stubArtifactsDetail(id: string | number, fixture = "artifacts/detail-1.json") {
  cy.intercept("GET", `**/api/artifacts/${id}*`, { fixture }).as("getArtifact");
}

export function stubArtifactsCreate(fixture = "artifacts/created.json") {
  cy.intercept("POST", "**/api/artifacts", { fixture }).as("createArtifact");
}

// ── Instructions ────────────────────────────────────────────────────────

export function stubInstructionsList(fixture = "instructions/list.json") {
  cy.intercept("GET", "**/api/instructions*", { fixture }).as("listInstructions");
}

export function stubInstructionsDetail(uuid: string, fixture = "instructions/detail-1.json") {
  cy.intercept("GET", `**/api/instructions/${uuid}`, { fixture }).as("getInstruction");
}

export function stubInstructionsCreate(fixture = "instructions/detail-1.json") {
  cy.intercept("POST", "**/api/instructions", { fixture }).as("createInstruction");
}

// ── Projects ────────────────────────────────────────────────────────────

export function stubProjectsList(fixture = "projects/list.json") {
  cy.intercept("GET", "**/api/projects", { fixture }).as("listProjects");
}

export function stubProjectsDetail(id: string, fixture = "projects/detail-1.json") {
  cy.intercept("GET", `**/api/projects/${id}`, { fixture }).as("getProject");
}

export function stubProjectsCreate(fixture = "projects/detail-1.json") {
  cy.intercept("POST", "**/api/projects", { fixture }).as("createProject");
}

export function stubProjectPersonas(projectId: string, fixture = "projects/personas-1.json") {
  cy.intercept("GET", `**/api/projects/${projectId}/personas`, { fixture }).as("listPersonas");
}

export function stubProjectStories(projectId: string, fixture = "projects/stories-1.json") {
  cy.intercept("GET", `**/api/projects/${projectId}/stories*`, { fixture }).as("listStories");
}

// ── Sessions ────────────────────────────────────────────────────────────

export function stubSessionsList(fixture = "sessions/list.json") {
  cy.intercept("GET", "**/api/sessions*", { fixture }).as("listSessions");
}

export function stubSessionsDetail(uuid: string, fixture = "sessions/detail-1.json") {
  cy.intercept("GET", `**/api/sessions/${uuid}`, { fixture }).as("getSession");
}

export function stubSessionsAppendNote(uuid: string, fixture = "sessions/detail-1.json") {
  cy.intercept("POST", `**/api/sessions/${uuid}/notes`, { fixture }).as("appendNote");
}

// ── Tools / Catalog ─────────────────────────────────────────────────────

export function stubToolsList(fixture = "tools/list.json") {
  cy.intercept("GET", "**/api/catalog", { fixture }).as("listTools");
}

export function stubToolsDetail(name: string, fixture = "tools/detail-1.json") {
  cy.intercept("GET", `**/api/catalog/tool/${name}`, { fixture }).as("getTool");
}

export function stubToolsInvoke(fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        body: {
          tool: "mock",
          status: "ok",
          result: { mock: true },
          duration_ms: 100,
        },
      };
  cy.intercept("POST", "**/api/catalog/invoke", response).as("invokeTool");
}

export function stubToolsCategories(fixture = "tools/categories.json") {
  cy.intercept("GET", "**/api/catalog/categories", { fixture }).as("listCategories");
}

// ── PRDs ────────────────────────────────────────────────────────────────

export function stubPrdsList(fixture = "prds/list.json") {
  cy.intercept("GET", "**/api/prds", { fixture }).as("listPrds");
}

export function stubPrdsDetail(id: string, fixture = "prds/detail-1.json") {
  cy.intercept("GET", `**/api/prds/${id}`, { fixture }).as("getPrd");
}

// ── Agents ──────────────────────────────────────────────────────────────

export function stubAgentsList(fixture = "agents/list.json") {
  cy.intercept("GET", "**/api/agents", { fixture }).as("listAgents");
}

export function stubAgentsDetail(name: string, fixture = "agents/detail-1.json") {
  cy.intercept("GET", `**/api/agents/${name}`, { fixture }).as("getAgent");
}

// ── Chat ────────────────────────────────────────────────────────────────

export function stubChatRoomsList(fixture = "chat/rooms.json") {
  cy.intercept("GET", "**/api/chat/rooms*", { fixture }).as("listRooms");
}

export function stubChatRoomDetail(id: string | number, fixture = "chat/room-1.json") {
  cy.intercept("GET", `**/api/chat/rooms/${id}`, { fixture }).as("getRoom");
}

export function stubChatRoomCreate(fixture = "chat/room-created.json") {
  cy.intercept("POST", "**/api/chat/rooms", { fixture }).as("createRoom");
}

export function stubChatMessages(roomId: string | number, fixture = "chat/messages-1.json") {
  cy.intercept("GET", `**/api/chat/rooms/${roomId}/messages*`, { fixture }).as("getMessages");
}

export function stubChatSendMessage(roomId: string | number, fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        statusCode: 200,
        body: {
          id: 99,
          room_id: Number(roomId),
          content: "",
          author: "user",
          created_at: "2026-04-23T12:00:00Z",
        },
      };
  cy.intercept("POST", `**/api/chat/rooms/${roomId}/messages`, response).as("sendMessage");
}

// ── NPL ─────────────────────────────────────────────────────────────────

export function stubNplElements(fixture?: string) {
  const response = fixture ? { fixture } : { body: [] };
  cy.intercept("GET", "**/api/npl/elements", response).as("listNplElements");
}

export function stubNplLoad(fixture?: string) {
  const response = fixture
    ? { fixture }
    : { body: { markdown: "# Mock NPL Load\n", char_count: 17 } };
  cy.intercept("POST", "**/api/npl/load", response).as("nplLoad");
}

export function stubNplSpec(fixture?: string) {
  const response = fixture
    ? { fixture }
    : { body: { markdown: "# Mock NPL Spec\n", char_count: 17 } };
  cy.intercept("POST", "**/api/npl/spec", response).as("nplSpec");
}

// ── Orchestration ───────────────────────────────────────────────────────

export function stubOrchestrationAgents(fixture = "orchestration/agents.json") {
  cy.intercept("GET", "**/api/orchestration/agents", { fixture }).as("listOrchAgents");
}

export function stubOrchestrationRuns(fixture = "orchestration/runs.json") {
  cy.intercept("GET", "**/api/orchestration/runs", { fixture }).as("listOrchRuns");
}

export function stubOrchestrationTrigger(fixture = "orchestration/triggered.json") {
  cy.intercept("POST", "**/api/orchestration/trigger", { fixture }).as("triggerOrch");
}

// ── Health ──────────────────────────────────────────────────────────────

export function stubHealthCheck(fixture = "health/report.json") {
  cy.intercept("GET", "**/api/health", { fixture }).as("healthCheck");
}

// ── Explorer ────────────────────────────────────────────────────────────

export function stubExplorerTree(fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        body: {
          name: "root",
          path: "",
          kind: "directory",
          children: [],
        },
      };
  cy.intercept("GET", "**/api/project/tree*", response).as("explorerTree");
}

export function stubExplorerFile(fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        body: {
          path: "mock.txt",
          content: "Mock file content",
          size: 18,
          truncated: false,
        },
      };
  cy.intercept("GET", "**/api/project/file*", response).as("explorerFile");
}

// ── Metrics ─────────────────────────────────────────────────────────────

export function stubMetricsToolCalls(fixture = "metrics/tool-calls.json") {
  cy.intercept("GET", "**/api/metrics/tool-calls*", { fixture }).as("metricToolCalls");
}

export function stubMetricsLlmCalls(fixture = "metrics/llm-calls.json") {
  cy.intercept("GET", "**/api/metrics/llm-calls*", { fixture }).as("metricLlmCalls");
}

export function stubMetricsErrors(fixture = "metrics/errors.json") {
  cy.intercept("GET", "**/api/errors*", { fixture }).as("metricErrors");
}

// ── Skills ──────────────────────────────────────────────────────────────

export function stubSkillsValidate(fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        body: {
          valid: true,
          errors: [],
          warnings: [],
          summary: { yaml_parseable: true, has_frontmatter: true, has_body: true },
        },
      };
  cy.intercept("POST", "**/api/skills/validate", response).as("validateSkill");
}

// ── Browser ─────────────────────────────────────────────────────────────

export function stubBrowserToMarkdown(fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        body: {
          markdown: "# Mock Markdown\n\nConverted content.",
          source: "https://example.com",
          char_count: 38,
        },
      };
  cy.intercept("POST", "**/api/browser/to-markdown", response).as("toMarkdown");
}

// ── Pipes ───────────────────────────────────────────────────────────────

export function stubPipesInput(fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        body: {
          status: "ok",
          agent: "mock",
          agent_handle: "mock-agent",
          groups: [],
          entries: 0,
          dashboard: {},
        },
      };
  cy.intercept("POST", "**/api/pipes/input", response).as("pipeInput");
}

export function stubPipesOutput(fixture?: string) {
  const response = fixture
    ? { fixture }
    : { body: { status: "ok", upserted: 1, sender: "mock" } };
  cy.intercept("POST", "**/api/pipes/output", response).as("pipeOutput");
}

// ── Reviews ─────────────────────────────────────────────────────────────

export function stubReviewsCreate(fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        body: {
          review_id: 1,
          artifact_id: 1,
          revision_id: 1,
          reviewer_persona: "dave",
          review_status: "open",
          overall_comment: null,
          created_at: "2026-04-23T12:00:00Z",
          comments: [],
        },
      };
  cy.intercept("POST", "**/api/reviews", response).as("createReview");
}

export function stubReviewsDetail(id: string | number, fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        body: {
          review_id: Number(id),
          artifact_id: 1,
          revision_id: 1,
          reviewer_persona: "dave",
          review_status: "open",
          overall_comment: null,
          created_at: "2026-04-23T12:00:00Z",
          comments: [],
        },
      };
  cy.intercept("GET", `**/api/reviews/${id}*`, response).as("getReview");
}

// ── Taskers ─────────────────────────────────────────────────────────────

export function stubTaskersSpawn(fixture?: string) {
  const response = fixture
    ? { fixture }
    : {
        body: {
          tasker_id: "tasker-001",
          task: "mock-task",
          patterns: [],
          parent_agent_id: "root",
          chat_room_id: 1,
          session_id: null,
          status: "active",
          timeout_minutes: 30,
          nag_minutes: 10,
          created_at: "2026-04-23T12:00:00Z",
          last_activity: null,
          terminated_at: null,
          termination_reason: null,
        },
      };
  cy.intercept("POST", "**/api/taskers", response).as("spawnTasker");
}

export function stubTaskersList(fixture?: string) {
  const response = fixture ? { fixture } : { body: [] };
  cy.intercept("GET", "**/api/taskers", response).as("listTaskers");
}

// ── Common Error Stubs ──────────────────────────────────────────────────

export function stubError(
  method: "GET" | "POST" | "PATCH" | "PUT" | "DELETE",
  pattern: string,
  status = 500,
  fixture?: string,
) {
  const errorFixtures: Record<number, string> = {
    404: "_errors/404.json",
    422: "_errors/422.json",
    500: "_errors/500.json",
  };
  const response = fixture
    ? { statusCode: status, fixture }
    : errorFixtures[status]
      ? { statusCode: status, fixture: errorFixtures[status] }
      : { statusCode: status, body: { detail: `Error ${status}` } };
  cy.intercept(method, pattern, response).as(`error${status}`);
}
