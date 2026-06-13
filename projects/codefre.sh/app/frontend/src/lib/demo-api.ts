/**
 * demo-api.ts
 *
 * Mock implementation of the `api` object from './api'.
 * Returns canned fixture data with a simulated network delay.
 * Drop-in replacement — same method names, same parameter signatures, same return types.
 */

import type {
  Organization,
  Prompt,
  PromptVersion,
  Rubric,
  RubricVersion,
  RubricCriterion,
  ScaleConfig,
  MarketplaceEntry,
  MarketplaceRubricVersion,
  PreviewResult,
  Persona,
  PersonaVersion,
  PersonaExpectation,
  ExpectationDirection,
  ExpectationScoringMethod,
  Script,
  ScriptVersion,
  ScriptNode,
  ScriptEdge,
  ScriptExpectation,
  ScriptValidationResult,
  Agent,
  AgentAdapter,
  AgentConfig,
  AgentVersion,
  AgentHealthResult,
  Run,
  RunStatus,
  RunStep,
  RunScore,
  ReviewItem,
  ReviewStatus,
  Dataset,
  Capture,
  CaptureStatus,
  OtelSpan,
  OtelLog,
  OtelSamplingPolicy,
  Webhook,
  WebhookPayload,
  WebhookDelivery,
  WebhookEvent,
  SsoConfig,
} from "./api";

// ─── Delay helper ─────────────────────────────────────────────────────────────

function delay<T>(data: T, ms?: number): Promise<T> {
  return new Promise((resolve) =>
    setTimeout(() => resolve(data), ms ?? 50 + Math.random() * 150),
  );
}

function uid(): string {
  return Math.random().toString(36).slice(2, 10);
}

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const DEMO_ORGANIZATIONS: Organization[] = [
  {
    id: "org-1",
    slug: "acme",
    name: "Acme Corp",
    role: "admin",
    created_at: "2024-01-01T00:00:00Z",
  },
  {
    id: "org-2",
    slug: "globex",
    name: "Globex Inc",
    role: "member",
    created_at: "2024-03-15T00:00:00Z",
  },
];

const DEMO_PROMPT_VERSION: PromptVersion = {
  id: "pv-1",
  version_number: 1,
  body: "You are a helpful assistant. User input: {{input}}",
  template_vars: { input: "" },
  tool_defs: {},
  metadata: {},
  checksum: "abc123",
  published_at: "2024-06-01T12:00:00Z",
};

const DEMO_PROMPTS: Prompt[] = [
  {
    id: "prompt-1",
    slug: "greeting",
    name: "Greeting Prompt",
    description: "Generates a friendly greeting",
    current_version_id: "pv-1",
    archived_at: null,
    created_at: "2024-05-01T00:00:00Z",
    updated_at: "2024-06-01T12:00:00Z",
    usage_count: 42,
  },
  {
    id: "prompt-2",
    slug: "summarize",
    name: "Summarization Prompt",
    description: "Summarizes long text",
    current_version_id: null,
    archived_at: null,
    created_at: "2024-05-10T00:00:00Z",
    updated_at: "2024-05-10T00:00:00Z",
    usage_count: 7,
  },
];

const DEMO_RUBRIC_VERSION: RubricVersion = {
  id: "rv-1",
  version_number: 1,
  scale: { method: "continuous", min: 0, max: 1 },
  criteria: [
    { name: "Accuracy", weight: 0.6, direction: "maximize" },
    { name: "Tone", weight: 0.4, direction: "maximize" },
  ],
  judge_model: "gpt-4o",
  judge_prompt_version_id: "pv-1",
  n_samples: 3,
  checksum: "def456",
  published_at: "2024-06-01T12:00:00Z",
};

const DEMO_RUBRICS: Rubric[] = [
  {
    id: "rubric-1",
    slug: "quality",
    name: "Response Quality",
    description: "Evaluates accuracy and tone",
    current_version_id: "rv-1",
    archived_at: null,
    created_at: "2024-05-01T00:00:00Z",
  },
  {
    id: "rubric-2",
    slug: "safety",
    name: "Safety Check",
    description: "Checks for harmful content",
    current_version_id: null,
    archived_at: null,
    created_at: "2024-05-20T00:00:00Z",
  },
];

const DEMO_MARKETPLACE_ENTRIES: Array<{
  entry: MarketplaceEntry;
  rubric_version: MarketplaceRubricVersion;
}> = [
  {
    entry: {
      id: "mkt-1",
      title: "Helpfulness Rubric",
      description: "Industry-standard helpfulness evaluation",
      domain: "customer-support",
      author_organization: "EvalCo",
      download_count: 1204,
      sample_score: 0.87,
    },
    rubric_version: {
      id: "mrv-1",
      version_number: 2,
      scale: { method: "discrete", min: 1, max: 5 },
      criteria: [{ name: "Helpfulness", weight: 1.0, direction: "maximize" }],
      judge_model: "gpt-4o-mini",
    },
  },
];

const DEMO_PERSONA_VERSION: PersonaVersion = {
  id: "perv-1",
  version_number: 1,
  tone: "friendly",
  description: "A warm, conversational support persona",
  system_prompt_version_id: "pv-1",
  checksum: "ghi789",
  published_at: "2024-06-01T12:00:00Z",
};

const DEMO_PERSONAS: Persona[] = [
  {
    id: "persona-1",
    slug: "support-agent",
    name: "Support Agent",
    description: "Friendly customer support persona",
    current_version_id: "perv-1",
    archived_at: null,
  },
  {
    id: "persona-2",
    slug: "tech-expert",
    name: "Tech Expert",
    description: "Knowledgeable technical advisor",
    current_version_id: null,
    archived_at: null,
  },
];

const DEMO_PERSONA_EXPECTATIONS: PersonaExpectation[] = [
  {
    id: "pe-1",
    persona_version_id: "perv-1",
    script_node_id: "node-1",
    label: "Greeting is warm",
    weight: 1.0,
    direction: "pass",
    scoring_method: "contains",
    config: { substring: "hello" },
    inserted_at: "2024-06-01T12:00:00Z",
  },
];

const DEMO_SCRIPT_VERSION: ScriptVersion = {
  id: "sv-1",
  version_number: 1,
  description: "Initial draft",
  root_node_id: "node-1",
  checksum: "jkl012",
};

const DEMO_SCRIPTS: Script[] = [
  {
    id: "script-1",
    slug: "onboarding-flow",
    name: "Onboarding Flow",
    description: "New user onboarding conversation",
    current_version_id: "sv-1",
    archived_at: null,
  },
  {
    id: "script-2",
    slug: "support-triage",
    name: "Support Triage",
    description: "Customer support routing script",
    current_version_id: null,
    archived_at: null,
  },
];

const DEMO_NODES: ScriptNode[] = [
  {
    id: "node-1",
    script_version_id: "sv-1",
    node_key: "start",
    kind: "user_turn",
    tone: "friendly",
    eval_tags: ["greeting"],
    freeball_policy: null,
    position: { x: 100, y: 100 },
    metadata: {},
    prompt_version_id: "pv-1",
  },
  {
    id: "node-2",
    script_version_id: "sv-1",
    node_key: "response",
    kind: "assistant_turn",
    tone: null,
    eval_tags: null,
    freeball_policy: null,
    position: { x: 300, y: 100 },
    metadata: {},
    prompt_version_id: null,
  },
  {
    id: "node-3",
    script_version_id: "sv-1",
    node_key: "end",
    kind: "terminal",
    tone: null,
    eval_tags: null,
    freeball_policy: null,
    position: { x: 500, y: 100 },
    metadata: {},
    prompt_version_id: null,
  },
];

const DEMO_EDGES: ScriptEdge[] = [
  {
    id: "edge-1",
    script_version_id: "sv-1",
    from_node_id: "node-1",
    to_node_id: "node-2",
    priority: 1,
    match_method: "always",
    match_config: null,
    label: null,
  },
  {
    id: "edge-2",
    script_version_id: "sv-1",
    from_node_id: "node-2",
    to_node_id: "node-3",
    priority: 1,
    match_method: "always",
    match_config: null,
    label: "done",
  },
];

const DEMO_NODE_EXPECTATIONS: ScriptExpectation[] = [
  {
    id: "exp-1",
    script_node_id: "node-1",
    label: "Mentions product name",
    weight: 1.0,
    direction: "maximize",
    scoring_method: "contains",
    config: { substring: "Acme" },
    rubric_version_id: null,
  },
];

const DEMO_AGENT_VERSION: AgentVersion = {
  id: "av-1",
  version_number: 1,
  adapter: "openai",
  config: {
    model: "gpt-4o",
    base_url: "https://api.openai.com/v1",
    max_tokens: 2048,
  },
  checksum: "mno345",
  published_at: "2024-06-01T12:00:00Z",
};

const DEMO_AGENTS: Agent[] = [
  {
    id: "agent-1",
    slug: "gpt4o-agent",
    name: "GPT-4o Agent",
    adapter: "openai",
    description: "Primary evaluation agent",
    current_version_id: "av-1",
    archived_at: null,
    created_at: "2024-05-01T00:00:00Z",
    updated_at: "2024-06-01T12:00:00Z",
    health_status: "healthy",
    health_checked_at: "2024-06-10T09:00:00Z",
    health_failure_reason: null,
  },
  {
    id: "agent-2",
    slug: "claude-agent",
    name: "Claude Agent",
    adapter: "anthropic",
    description: "Anthropic Claude-based agent",
    current_version_id: null,
    archived_at: null,
    created_at: "2024-05-15T00:00:00Z",
    updated_at: "2024-05-15T00:00:00Z",
    health_status: "unchecked",
    health_checked_at: null,
    health_failure_reason: null,
  },
];

const DEMO_RUNS: Run[] = [
  {
    id: "run-1",
    short_id: "r1a2b3",
    script_id: "script-1",
    script_name: "Onboarding Flow",
    script_version_number: 1,
    script_version_id: "sv-1",
    agent_id: "agent-1",
    agent_name: "GPT-4o Agent",
    agent_version_number: 1,
    persona_id: "persona-1",
    persona_name: "Support Agent",
    status: "pass",
    verdict: "pass",
    trigger_source: "manual",
    started_at: "2024-06-10T10:00:00Z",
    finished_at: "2024-06-10T10:01:23Z",
    inserted_at: "2024-06-10T10:00:00Z",
    duration_ms: 83000,
    score: 0.91,
  },
  {
    id: "run-2",
    short_id: "r4c5d6",
    script_id: "script-1",
    script_name: "Onboarding Flow",
    script_version_number: 1,
    script_version_id: "sv-1",
    agent_id: "agent-1",
    agent_name: "GPT-4o Agent",
    agent_version_number: 1,
    persona_id: null,
    persona_name: null,
    status: "fail",
    verdict: "fail",
    trigger_source: "ci",
    started_at: "2024-06-09T08:30:00Z",
    finished_at: "2024-06-09T08:31:45Z",
    inserted_at: "2024-06-09T08:30:00Z",
    duration_ms: 105000,
    score: 0.42,
  },
  {
    id: "run-3",
    short_id: "r7e8f9",
    script_id: "script-2",
    script_name: "Support Triage",
    script_version_number: 1,
    script_version_id: null,
    agent_id: "agent-2",
    agent_name: "Claude Agent",
    agent_version_number: 1,
    persona_id: "persona-2",
    persona_name: "Tech Expert",
    status: "running",
    verdict: null,
    trigger_source: "manual",
    started_at: "2024-06-10T11:00:00Z",
    finished_at: null,
    inserted_at: "2024-06-10T11:00:00Z",
    duration_ms: null,
    score: null,
  },
];

const DEMO_RUN_STEPS: RunStep[] = [
  {
    id: "step-1",
    run_id: "run-1",
    script_node_id: "node-1",
    sequence: 1,
    voice: "author",
    verdict: "pass",
    content: "Hello! I'd like to get started with Acme.",
    rationale: "User initiated the conversation correctly.",
    score: 1.0,
    started_at: "2024-06-10T10:00:05Z",
    finished_at: "2024-06-10T10:00:10Z",
    duration_ms: 5000,
  },
  {
    id: "step-2",
    run_id: "run-1",
    script_node_id: "node-2",
    sequence: 2,
    voice: "agent",
    verdict: "pass",
    content: "Welcome to Acme! How can I help you today?",
    rationale: "Agent greeted warmly and offered help.",
    score: 0.95,
    started_at: "2024-06-10T10:00:10Z",
    finished_at: "2024-06-10T10:00:18Z",
    duration_ms: 8000,
  },
];

const DEMO_RUN_SCORES: RunScore[] = [
  {
    id: "score-1",
    run_id: "run-1",
    run_step_id: "step-2",
    expectation_id: "exp-1",
    label: "Mentions product name",
    value: 1.0,
    verdict: "pass",
    rationale: "Response mentions 'Acme'.",
  },
];

const DEMO_REVIEW_ITEMS: ReviewItem[] = [
  {
    id: "rev-1",
    run_id: "run-2",
    status: "pending",
    assignee_id: null,
    assignee_email: null,
    notes: null,
    inserted_at: "2024-06-09T08:35:00Z",
    updated_at: "2024-06-09T08:35:00Z",
  },
  {
    id: "rev-2",
    run_id: "run-1",
    status: "resolved",
    assignee_id: "user-1",
    assignee_email: "reviewer@acme.com",
    notes: "Looks good",
    inserted_at: "2024-06-10T10:05:00Z",
    updated_at: "2024-06-10T10:10:00Z",
  },
];

const DEMO_DATASETS: Dataset[] = [
  {
    id: "ds-1",
    name: "Onboarding Test Set",
    description: "Captured conversations from onboarding runs",
    current_version_id: "dsv-1",
    inserted_at: "2024-06-01T00:00:00Z",
  },
];

const DEMO_CAPTURES: Capture[] = [
  {
    id: "cap-1",
    run_id: "run-1",
    status: "pending",
    dataset_id: null,
    inserted_at: "2024-06-10T10:02:00Z",
  },
  {
    id: "cap-2",
    run_id: "run-2",
    status: "promoted",
    dataset_id: "ds-1",
    inserted_at: "2024-06-09T08:32:00Z",
  },
];

const DEMO_OTEL_SPANS: OtelSpan[] = [
  {
    span_id: "span-1",
    trace_id: "trace-abc",
    parent_span_id: null,
    run_id: "run-1",
    name: "run.execute",
    start_time_unix_nano: "1718013600000000000",
    end_time_unix_nano: "1718013683000000000",
    duration_ns: 83000000000,
    status_code: "OK",
    attributes: { "run.id": "run-1", "run.status": "pass" },
  },
];

const DEMO_OTEL_LOGS: OtelLog[] = [
  {
    id: "log-1",
    trace_id: "trace-abc",
    span_id: "span-1",
    run_id: "run-1",
    severity_text: "INFO",
    body: "Run completed successfully",
    attributes: { "run.id": "run-1" },
    timestamp: "2024-06-10T10:01:23Z",
  },
];

const DEMO_OTEL_POLICIES: OtelSamplingPolicy[] = [
  { id: "policy-1", name: "Default", sample_rate: 1.0, enabled: true },
  { id: "policy-2", name: "High Volume", sample_rate: 0.1, enabled: false },
];

const DEMO_WEBHOOKS: Webhook[] = [
  {
    id: "wh-1",
    url: "https://hooks.acme.com/codefresh",
    events: ["run.completed", "run.failed"],
    enabled: true,
    inserted_at: "2024-05-01T00:00:00Z",
  },
];

const DEMO_WEBHOOK_DELIVERIES: WebhookDelivery[] = [
  {
    id: "wd-1",
    webhook_id: "wh-1",
    event: "run.completed",
    status: "delivered",
    response_status: 200,
    attempted_at: "2024-06-10T10:02:00Z",
    next_retry_at: null,
  },
  {
    id: "wd-2",
    webhook_id: "wh-1",
    event: "run.failed",
    status: "failed",
    response_status: 503,
    attempted_at: "2024-06-09T08:36:00Z",
    next_retry_at: "2024-06-09T08:51:00Z",
  },
];

const DEMO_SSO_CONFIG: SsoConfig = {
  idp_metadata_url: "https://idp.acme.com/metadata.xml",
  entity_id: "https://codefre.sh/sso/acme",
  certificate: "-----BEGIN CERTIFICATE-----\nMIIC...demo...cert\n-----END CERTIFICATE-----",
};

const DEMO_PERSONA_STARTERS = [
  {
    slug: "helpful-assistant",
    name: "Helpful Assistant",
    tone: "friendly",
    description: "A warm, helpful general-purpose assistant persona",
    sample_preamble: "You are a helpful, friendly assistant. Always greet the user warmly.",
  },
  {
    slug: "technical-expert",
    name: "Technical Expert",
    tone: "precise",
    description: "A knowledgeable technical advisor who answers with precision",
    sample_preamble: "You are a technical expert. Provide accurate, concise answers with examples.",
  },
];

// ─── demoApi ──────────────────────────────────────────────────────────────────

const demoApi = {
  // ─── Auth ──────────────────────────────────────────────────────────────────
  register(_email: string, _password: string, _inviteToken: string) {
    return delay({
      user: { id: "user-demo", email: _email },
      organization: { id: "org-1", slug: "acme", name: "Acme Corp" },
      access_token: "demo-access-token",
      refresh_token: "demo-refresh-token",
    });
  },

  login(_email: string, _password: string) {
    return delay({
      user: { id: "user-demo", email: _email },
      organization: { id: "org-1", slug: "acme", name: "Acme Corp" },
      access_token: "demo-access-token",
      refresh_token: "demo-refresh-token",
    });
  },

  refresh(_refreshToken: string) {
    return delay({ access_token: "demo-access-token-refreshed" });
  },

  me() {
    return delay({ user: { id: "user-demo", email: "demo@codefre.sh" } });
  },

  // ─── Organizations ─────────────────────────────────────────────────────────
  listOrganizations() {
    return delay({ organizations: DEMO_ORGANIZATIONS });
  },

  createOrganization(name: string, slug?: string) {
    const org: Organization = {
      id: `org-${uid()}`,
      slug: slug ?? name.toLowerCase().replace(/\s+/g, "-"),
      name,
      role: "admin",
      created_at: new Date().toISOString(),
    };
    return delay({ organization: org });
  },

  getOrganization(id: string) {
    const org = DEMO_ORGANIZATIONS.find((o) => o.id === id) ?? DEMO_ORGANIZATIONS[0];
    return delay({ organization: org });
  },

  // ─── Prompts ───────────────────────────────────────────────────────────────
  listPrompts(_orgId: string, q?: string) {
    const prompts = q
      ? DEMO_PROMPTS.filter(
          (p) =>
            p.name.toLowerCase().includes(q.toLowerCase()) ||
            (p.description ?? "").toLowerCase().includes(q.toLowerCase()),
        )
      : DEMO_PROMPTS;
    return delay({ prompts });
  },

  createPrompt(_orgId: string, name: string, description?: string, slug?: string) {
    const prompt: Prompt = {
      id: `prompt-${uid()}`,
      slug: slug ?? name.toLowerCase().replace(/\s+/g, "-"),
      name,
      description: description ?? null,
      current_version_id: null,
      archived_at: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      usage_count: 0,
    };
    return delay({ prompt });
  },

  getPrompt(_orgId: string, id: string) {
    const prompt = DEMO_PROMPTS.find((p) => p.id === id) ?? DEMO_PROMPTS[0];
    return delay({
      prompt,
      current_version: DEMO_PROMPT_VERSION,
      versions: [
        {
          id: DEMO_PROMPT_VERSION.id,
          version_number: DEMO_PROMPT_VERSION.version_number,
          checksum: DEMO_PROMPT_VERSION.checksum,
          published_at: DEMO_PROMPT_VERSION.published_at,
        },
      ],
    });
  },

  publishPromptVersion(
    _orgId: string,
    _id: string,
    body: string,
    templateVars: Record<string, unknown> = {},
    toolDefs: Record<string, unknown> = {},
  ) {
    const version: PromptVersion = {
      ...DEMO_PROMPT_VERSION,
      id: `pv-${uid()}`,
      body,
      template_vars: templateVars,
      tool_defs: toolDefs,
      published_at: new Date().toISOString(),
    };
    return delay({ version, status: "published" as const });
  },

  sandboxPrompt(
    _orgId: string,
    _id: string,
    bindings: Record<string, unknown> = {},
    _version: "current" | string = "current",
  ) {
    const bindingStr = Object.entries(bindings)
      .map(([k, v]) => `${k}=${v}`)
      .join(", ");
    return delay({
      rendered: `You are a helpful assistant. User input: ${bindingStr || "[no bindings]"}`,
      tool_names: [],
      mode: "chat",
      note: "Demo sandbox render",
    });
  },

  // ─── Rubrics ───────────────────────────────────────────────────────────────
  listRubrics(_orgId: string) {
    return delay({ rubrics: DEMO_RUBRICS });
  },

  createRubric(_orgId: string, name: string, description?: string) {
    const rubric: Rubric = {
      id: `rubric-${uid()}`,
      slug: name.toLowerCase().replace(/\s+/g, "-"),
      name,
      description: description ?? null,
      current_version_id: null,
      archived_at: null,
      created_at: new Date().toISOString(),
    };
    return delay({ rubric });
  },

  getRubric(_orgId: string, id: string) {
    const rubric = DEMO_RUBRICS.find((r) => r.id === id) ?? DEMO_RUBRICS[0];
    return delay({
      rubric,
      current_version: DEMO_RUBRIC_VERSION,
      versions: [
        {
          id: DEMO_RUBRIC_VERSION.id,
          version_number: DEMO_RUBRIC_VERSION.version_number,
          checksum: DEMO_RUBRIC_VERSION.checksum,
          published_at: DEMO_RUBRIC_VERSION.published_at,
        },
      ],
    });
  },

  publishRubricVersion(
    _orgId: string,
    _id: string,
    scale: ScaleConfig,
    criteria: RubricCriterion[],
    judgeModel: string | null,
    judgePromptVersionId: string | null,
    nSamples: number,
  ) {
    const version: RubricVersion = {
      id: `rv-${uid()}`,
      version_number: 2,
      scale,
      criteria,
      judge_model: judgeModel,
      judge_prompt_version_id: judgePromptVersionId,
      n_samples: nSamples,
      checksum: uid(),
      published_at: new Date().toISOString(),
    };
    return delay({ version, status: "published" as const });
  },

  previewRubric(_orgId: string, _id: string, sampleInput: string, sampleResponse: string) {
    return delay<PreviewResult>({
      rendered_prompt: `Evaluate the following:\nInput: ${sampleInput}\nResponse: ${sampleResponse}\n\nScore on a scale of 0 to 1.`,
      estimated_tokens: 128,
      mode: "chat",
    });
  },

  listMarketplaceRubrics(domain?: string) {
    const entries = domain
      ? DEMO_MARKETPLACE_ENTRIES.filter((e) => e.entry.domain === domain)
      : DEMO_MARKETPLACE_ENTRIES;
    return delay({ entries });
  },

  importMarketplaceRubric(_orgId: string, marketplaceEntryId: string) {
    const entry = DEMO_MARKETPLACE_ENTRIES.find((e) => e.entry.id === marketplaceEntryId);
    const rubric: Rubric = {
      id: `rubric-${uid()}`,
      slug: `imported-${marketplaceEntryId}`,
      name: entry?.entry.title ?? "Imported Rubric",
      description: entry?.entry.description ?? null,
      current_version_id: null,
      archived_at: null,
      created_at: new Date().toISOString(),
    };
    const version: RubricVersion = {
      ...(entry?.rubric_version
        ? {
            ...DEMO_RUBRIC_VERSION,
            scale: entry.rubric_version.scale,
            criteria: entry.rubric_version.criteria,
            judge_model: entry.rubric_version.judge_model,
          }
        : DEMO_RUBRIC_VERSION),
      id: `rv-${uid()}`,
      published_at: new Date().toISOString(),
    };
    return delay({ rubric, version });
  },

  // ─── Personas ──────────────────────────────────────────────────────────────
  listPersonas(_orgId: string, tone?: string) {
    const personas = tone
      ? DEMO_PERSONAS.filter((p) => {
          const ver = p.id === "persona-1" ? DEMO_PERSONA_VERSION : null;
          return ver?.tone === tone;
        })
      : DEMO_PERSONAS;
    return delay({ personas });
  },

  createPersona(_orgId: string, name: string, description?: string) {
    const persona: Persona = {
      id: `persona-${uid()}`,
      slug: name.toLowerCase().replace(/\s+/g, "-"),
      name,
      description: description ?? null,
      current_version_id: null,
      archived_at: null,
    };
    return delay({ persona });
  },

  listPersonaStarters() {
    return delay({ starters: DEMO_PERSONA_STARTERS });
  },

  importPersonaStarter(_orgId: string, starterSlug: string) {
    const starter = DEMO_PERSONA_STARTERS.find((s) => s.slug === starterSlug);
    const persona: Persona = {
      id: `persona-${uid()}`,
      slug: starterSlug,
      name: starter?.name ?? starterSlug,
      description: starter?.description ?? null,
      current_version_id: null,
      archived_at: null,
    };
    return delay({ persona, version: null });
  },

  getPersona(_orgId: string, personaId: string) {
    const persona = DEMO_PERSONAS.find((p) => p.id === personaId) ?? DEMO_PERSONAS[0];
    return delay({
      persona,
      current_version: DEMO_PERSONA_VERSION,
      versions: [
        {
          id: DEMO_PERSONA_VERSION.id,
          version_number: DEMO_PERSONA_VERSION.version_number,
          checksum: DEMO_PERSONA_VERSION.checksum,
          published_at: DEMO_PERSONA_VERSION.published_at,
        },
      ],
    });
  },

  updatePersona(
    _orgId: string,
    personaId: string,
    fields: { tone?: string; description?: string; system_prompt_version_id?: string | null },
  ) {
    const base = DEMO_PERSONAS.find((p) => p.id === personaId) ?? DEMO_PERSONAS[0];
    const persona: Persona = { ...base, ...fields };
    return delay({ persona });
  },

  publishPersonaVersion(_orgId: string, _personaId: string) {
    const version: PersonaVersion = {
      ...DEMO_PERSONA_VERSION,
      id: `perv-${uid()}`,
      version_number: 2,
      published_at: new Date().toISOString(),
    };
    return delay({ version, status: "published" as const });
  },

  listPersonaExpectations(_orgId: string, _personaId: string, _versionId: string) {
    return delay({ expectations: DEMO_PERSONA_EXPECTATIONS });
  },

  createPersonaExpectation(
    _orgId: string,
    _personaId: string,
    versionId: string,
    expectation: {
      script_node_id?: string | null;
      label: string;
      weight?: number;
      direction?: ExpectationDirection;
      scoring_method?: ExpectationScoringMethod;
      config?: Record<string, unknown>;
    },
  ) {
    const created: PersonaExpectation = {
      id: `pe-${uid()}`,
      persona_version_id: versionId,
      script_node_id: expectation.script_node_id ?? null,
      label: expectation.label,
      weight: expectation.weight ?? 1.0,
      direction: expectation.direction ?? "pass",
      scoring_method: expectation.scoring_method ?? "contains",
      config: expectation.config ?? {},
      inserted_at: new Date().toISOString(),
    };
    return delay({ expectation: created });
  },

  // ─── Scripts ───────────────────────────────────────────────────────────────
  listScripts(_orgId: string) {
    return delay({ scripts: DEMO_SCRIPTS });
  },

  createScript(_orgId: string, name: string, description?: string) {
    const script: Script = {
      id: `script-${uid()}`,
      slug: name.toLowerCase().replace(/\s+/g, "-"),
      name,
      description: description ?? null,
      current_version_id: null,
      archived_at: null,
    };
    const draft_version: ScriptVersion = {
      id: `sv-${uid()}`,
      version_number: 1,
      description: null,
      root_node_id: null,
      checksum: uid(),
    };
    return delay({ script, draft_version });
  },

  getScript(_orgId: string, id: string) {
    const script = DEMO_SCRIPTS.find((s) => s.id === id) ?? DEMO_SCRIPTS[0];
    return delay({
      script,
      draft_version: DEMO_SCRIPT_VERSION,
      nodes: DEMO_NODES,
      edges: DEMO_EDGES,
    });
  },

  updateScript(_orgId: string, scriptId: string, fields: { name?: string; description?: string }) {
    const base = DEMO_SCRIPTS.find((s) => s.id === scriptId) ?? DEMO_SCRIPTS[0];
    const script: Script = { ...base, ...fields };
    return delay({ script });
  },

  addScriptNode(
    _orgId: string,
    _scriptId: string,
    nodeKey: string,
    kind: string,
    extra: Record<string, unknown> = {},
  ) {
    const node: ScriptNode = {
      id: `node-${uid()}`,
      script_version_id: "sv-1",
      node_key: nodeKey,
      kind,
      tone: (extra.tone as string | null) ?? null,
      eval_tags: (extra.eval_tags as string[] | null) ?? null,
      freeball_policy: (extra.freeball_policy as string | null) ?? null,
      position: (extra.position as { x?: number; y?: number } | null) ?? { x: 0, y: 0 },
      metadata: (extra.metadata as Record<string, unknown> | null) ?? {},
      prompt_version_id: (extra.prompt_version_id as string | null) ?? null,
    };
    return delay({ node });
  },

  attachPromptToNode(
    _orgId: string,
    _scriptId: string,
    nodeId: string,
    promptVersionId: string,
  ) {
    const base = DEMO_NODES.find((n) => n.id === nodeId) ?? DEMO_NODES[0];
    const node: ScriptNode = { ...base, prompt_version_id: promptVersionId };
    return delay({ node });
  },

  updateScriptNode(
    _orgId: string,
    _scriptId: string,
    nodeId: string,
    updates: Partial<{
      position: { x: number; y: number };
      kind: string;
      tone: string | null;
      eval_tags: string[];
      freeball_policy: string;
      metadata: Record<string, unknown>;
    }>,
  ) {
    const base = DEMO_NODES.find((n) => n.id === nodeId) ?? DEMO_NODES[0];
    const node: ScriptNode = { ...base, ...updates };
    return delay({ node });
  },

  listNodeExpectations(_orgId: string, _scriptId: string, nodeId: string) {
    const expectations = DEMO_NODE_EXPECTATIONS.filter((e) => e.script_node_id === nodeId);
    return delay({ expectations });
  },

  addNodeExpectation(
    _orgId: string,
    _scriptId: string,
    nodeId: string,
    expectation: {
      label: string;
      weight?: number;
      direction?: "maximize" | "minimize";
      scoring_method?: string;
      config?: Record<string, unknown>;
      rubric_version_id?: string | null;
    },
  ) {
    const created: ScriptExpectation = {
      id: `exp-${uid()}`,
      script_node_id: nodeId,
      label: expectation.label,
      weight: expectation.weight ?? 1.0,
      direction: expectation.direction ?? "maximize",
      scoring_method: expectation.scoring_method ?? "contains",
      config: expectation.config ?? null,
      rubric_version_id: expectation.rubric_version_id ?? null,
    };
    return delay({ expectation: created });
  },

  addScriptEdge(
    _orgId: string,
    _scriptId: string,
    edge: {
      from_node_id: string;
      to_node_id: string;
      match_method: string;
      match_config?: Record<string, unknown>;
      priority?: number;
      label?: string;
    },
  ) {
    const created: ScriptEdge = {
      id: `edge-${uid()}`,
      script_version_id: "sv-1",
      from_node_id: edge.from_node_id,
      to_node_id: edge.to_node_id,
      priority: edge.priority ?? null,
      match_method: edge.match_method,
      match_config: edge.match_config ?? null,
      label: edge.label ?? null,
    };
    return delay({ edge: created });
  },

  publishScript(_orgId: string, _scriptId: string) {
    const version: ScriptVersion = {
      ...DEMO_SCRIPT_VERSION,
      id: `sv-${uid()}`,
      version_number: 2,
    };
    return delay({ version, status: "published" as const });
  },

  importScriptYaml(_orgId: string, _yaml: string) {
    const script: Script = {
      id: `script-${uid()}`,
      slug: `imported-${uid()}`,
      name: "Imported Script",
      description: "Imported via YAML",
      current_version_id: null,
      archived_at: null,
    };
    const version: ScriptVersion = {
      id: `sv-${uid()}`,
      version_number: 1,
      description: null,
      root_node_id: null,
      checksum: uid(),
    };
    return delay({ script, version, status: "imported" });
  },

  forkScript(_orgId: string, scriptId: string) {
    const base = DEMO_SCRIPTS.find((s) => s.id === scriptId) ?? DEMO_SCRIPTS[0];
    const script: Script = {
      ...base,
      id: `script-${uid()}`,
      slug: `${base.slug}-fork-${uid()}`,
      name: `${base.name} (Fork)`,
      current_version_id: null,
    };
    const draft_version: ScriptVersion = {
      ...DEMO_SCRIPT_VERSION,
      id: `sv-${uid()}`,
    };
    return delay({ script, draft_version });
  },

  autoLayoutScript(_orgId: string, _scriptId: string) {
    const nodes: ScriptNode[] = DEMO_NODES.map((n, i) => ({
      ...n,
      position: { x: 100 + i * 220, y: 200 },
    }));
    return delay({ nodes });
  },

  validateScript(_orgId: string, _scriptId: string) {
    return delay<ScriptValidationResult>({
      valid: true,
      warnings: [],
      errors: [],
    });
  },

  exportScriptYamlUrl(_orgId: string, scriptId: string): string {
    return `#demo-export/${scriptId}`;
  },

  async exportScriptYaml(_orgId: string, _scriptId: string): Promise<string> {
    await delay(null);
    return [
      "version: 1",
      "name: Onboarding Flow",
      "nodes:",
      "  - key: start",
      "    kind: user_turn",
      "  - key: response",
      "    kind: assistant_turn",
      "  - key: end",
      "    kind: terminal",
      "edges:",
      "  - from: start",
      "    to: response",
      "    match: always",
      "  - from: response",
      "    to: end",
      "    match: always",
    ].join("\n");
  },

  // ─── Agents ────────────────────────────────────────────────────────────────
  listAgents(_orgId: string) {
    return delay({ agents: DEMO_AGENTS });
  },

  createAgent(
    _orgId: string,
    name: string,
    adapter: AgentAdapter,
    config: AgentConfig,
    description?: string,
    slug?: string,
  ) {
    const agent: Agent = {
      id: `agent-${uid()}`,
      slug: slug ?? name.toLowerCase().replace(/\s+/g, "-"),
      name,
      adapter,
      description: description ?? null,
      current_version_id: null,
      archived_at: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      health_status: "unchecked",
      health_checked_at: null,
      health_failure_reason: null,
    };
    const draft_version: AgentVersion = {
      id: `av-${uid()}`,
      version_number: 1,
      adapter,
      config,
      checksum: uid(),
      published_at: null,
    };
    return delay({ agent, draft_version });
  },

  getAgent(_orgId: string, agentId: string) {
    const agent = DEMO_AGENTS.find((a) => a.id === agentId) ?? DEMO_AGENTS[0];
    return delay({ agent, current_version: DEMO_AGENT_VERSION });
  },

  updateAgentConfig(_orgId: string, agentId: string, config: AgentConfig) {
    const base = DEMO_AGENTS.find((a) => a.id === agentId) ?? DEMO_AGENTS[0];
    const agent: Agent = { ...base, updated_at: new Date().toISOString() };
    void config;
    return delay({ agent });
  },

  publishAgentVersion(_orgId: string, _agentId: string) {
    const version: AgentVersion = {
      ...DEMO_AGENT_VERSION,
      id: `av-${uid()}`,
      version_number: 2,
      published_at: new Date().toISOString(),
    };
    return delay({ version, status: "published" as const });
  },

  checkAgentHealth(_orgId: string, _agentId: string) {
    return delay<AgentHealthResult>({
      status: "healthy",
      latency_ms: 82,
      error: null,
      checked_at: new Date().toISOString(),
    });
  },

  // ─── Runs ──────────────────────────────────────────────────────────────────
  listRuns(
    _orgId: string,
    filters?: {
      script_id?: string;
      persona_id?: string;
      status?: RunStatus;
      date_from?: string;
      date_to?: string;
      page?: number;
    },
  ) {
    let runs = [...DEMO_RUNS];
    if (filters?.script_id) runs = runs.filter((r) => r.script_id === filters.script_id);
    if (filters?.persona_id) runs = runs.filter((r) => r.persona_id === filters.persona_id);
    if (filters?.status) runs = runs.filter((r) => r.status === filters.status);
    if (filters?.date_from) runs = runs.filter((r) => r.inserted_at >= filters.date_from!);
    if (filters?.date_to) runs = runs.filter((r) => r.inserted_at <= filters.date_to!);
    return delay({ runs, total: runs.length, page: filters?.page ?? 1 });
  },

  triggerRun(
    _orgId: string,
    scriptId: string,
    agentId: string,
    personaId?: string,
    _config?: Record<string, unknown>,
  ) {
    const run: Run = {
      id: `run-${uid()}`,
      short_id: uid(),
      script_id: scriptId,
      script_name: DEMO_SCRIPTS.find((s) => s.id === scriptId)?.name ?? "Unknown Script",
      script_version_number: 1,
      script_version_id: "sv-1",
      agent_id: agentId,
      agent_name: DEMO_AGENTS.find((a) => a.id === agentId)?.name ?? "Unknown Agent",
      agent_version_number: 1,
      persona_id: personaId ?? null,
      persona_name: personaId
        ? (DEMO_PERSONAS.find((p) => p.id === personaId)?.name ?? null)
        : null,
      status: "running",
      verdict: null,
      trigger_source: "manual",
      started_at: new Date().toISOString(),
      finished_at: null,
      inserted_at: new Date().toISOString(),
      duration_ms: null,
      score: null,
    };
    return delay({ run });
  },

  getRun(_orgId: string, runId: string) {
    const run = DEMO_RUNS.find((r) => r.id === runId) ?? DEMO_RUNS[0];
    return delay({ run, nodes: DEMO_NODES, edges: DEMO_EDGES });
  },

  listRunSteps(_orgId: string, runId: string) {
    const steps = DEMO_RUN_STEPS.filter((s) => s.run_id === runId);
    return delay({ steps });
  },

  listRunScores(_orgId: string, runId: string) {
    const scores = DEMO_RUN_SCORES.filter((s) => s.run_id === runId);
    return delay({ scores });
  },

  cancelRun(_orgId: string, runId: string) {
    const base = DEMO_RUNS.find((r) => r.id === runId) ?? DEMO_RUNS[0];
    const run: Run = { ...base, status: "cancelled", finished_at: new Date().toISOString() };
    return delay({ run });
  },

  retryRun(_orgId: string, runId: string) {
    const base = DEMO_RUNS.find((r) => r.id === runId) ?? DEMO_RUNS[0];
    const run: Run = {
      ...base,
      id: `run-${uid()}`,
      status: "running",
      started_at: new Date().toISOString(),
      finished_at: null,
      inserted_at: new Date().toISOString(),
    };
    return delay({ run });
  },

  // ─── Review queue ──────────────────────────────────────────────────────────
  listReviewQueue(
    _orgId: string,
    filters?: { status?: ReviewStatus; assignee?: string; page?: number },
  ) {
    let items = [...DEMO_REVIEW_ITEMS];
    if (filters?.status) items = items.filter((i) => i.status === filters.status);
    if (filters?.assignee) items = items.filter((i) => i.assignee_id === filters.assignee);
    return delay({ items, total: items.length });
  },

  reviewAction(
    _orgId: string,
    itemId: string,
    action: "claim" | "approve" | "reject" | "dismiss",
    _payload?: Record<string, unknown>,
  ) {
    const base = DEMO_REVIEW_ITEMS.find((i) => i.id === itemId) ?? DEMO_REVIEW_ITEMS[0];
    const statusMap: Record<string, ReviewStatus> = {
      claim: "claimed",
      approve: "resolved",
      reject: "resolved",
      dismiss: "resolved",
    };
    const item: ReviewItem = {
      ...base,
      status: statusMap[action] ?? base.status,
      updated_at: new Date().toISOString(),
    };
    return delay({ item });
  },

  reviewAssign(_orgId: string, itemId: string, assigneeId: string) {
    const base = DEMO_REVIEW_ITEMS.find((i) => i.id === itemId) ?? DEMO_REVIEW_ITEMS[0];
    const item: ReviewItem = {
      ...base,
      assignee_id: assigneeId,
      updated_at: new Date().toISOString(),
    };
    return delay({ item });
  },

  reviewBulk(_orgId: string, ids: string[], _action: "claim" | "approve") {
    return delay({ updated: ids.length });
  },

  // ─── Datasets ──────────────────────────────────────────────────────────────
  listDatasets(_orgId: string) {
    return delay({ datasets: DEMO_DATASETS });
  },

  createDataset(_orgId: string, name: string, description?: string) {
    const dataset: Dataset = {
      id: `ds-${uid()}`,
      name,
      description: description ?? null,
      current_version_id: null,
      inserted_at: new Date().toISOString(),
    };
    return delay({ dataset });
  },

  publishDatasetVersion(_orgId: string, _datasetId: string) {
    return delay({ version: { id: `dsv-${uid()}`, version_number: 1 }, status: "published" });
  },

  listCaptures(_orgId: string, filters?: { status?: CaptureStatus; page?: number }) {
    let captures = [...DEMO_CAPTURES];
    if (filters?.status) captures = captures.filter((c) => c.status === filters.status);
    return delay({ captures });
  },

  promoteCapture(_orgId: string, captureId: string, datasetId: string) {
    const base = DEMO_CAPTURES.find((c) => c.id === captureId) ?? DEMO_CAPTURES[0];
    const capture: Capture = { ...base, status: "promoted", dataset_id: datasetId };
    return delay({ capture });
  },

  // ─── OTel ──────────────────────────────────────────────────────────────────
  searchOtelSpans(
    _orgId: string,
    query: { run_id?: string; attributes?: Record<string, unknown>; page?: number },
  ) {
    const spans = query.run_id
      ? DEMO_OTEL_SPANS.filter((s) => s.run_id === query.run_id)
      : DEMO_OTEL_SPANS;
    return delay({ spans, total: spans.length });
  },

  searchOtelLogs(
    _orgId: string,
    query: { run_id?: string; attributes?: Record<string, unknown>; page?: number },
  ) {
    const logs = query.run_id
      ? DEMO_OTEL_LOGS.filter((l) => l.run_id === query.run_id)
      : DEMO_OTEL_LOGS;
    return delay({ logs, total: logs.length });
  },

  listOtelSamplingPolicies(_orgId: string) {
    return delay({ policies: DEMO_OTEL_POLICIES });
  },

  // ─── Webhooks ──────────────────────────────────────────────────────────────
  listWebhooks(_orgId: string) {
    return delay({ webhooks: DEMO_WEBHOOKS });
  },

  createWebhook(_orgId: string, payload: WebhookPayload) {
    const webhook: Webhook = {
      id: `wh-${uid()}`,
      ...payload,
      inserted_at: new Date().toISOString(),
    };
    return delay({ webhook });
  },

  updateWebhook(_orgId: string, webhookId: string, payload: Partial<WebhookPayload>) {
    const base = DEMO_WEBHOOKS.find((w) => w.id === webhookId) ?? DEMO_WEBHOOKS[0];
    const webhook: Webhook = { ...base, ...payload };
    return delay({ webhook });
  },

  deleteWebhook(_orgId: string, _webhookId: string) {
    return delay({ ok: true });
  },

  listWebhookDeliveries(_orgId: string, webhookId: string) {
    const deliveries = DEMO_WEBHOOK_DELIVERIES.filter((d) => d.webhook_id === webhookId);
    return delay({ deliveries });
  },

  retryWebhookDelivery(_orgId: string, _webhookId: string, deliveryId: string) {
    const base = DEMO_WEBHOOK_DELIVERIES.find((d) => d.id === deliveryId) ?? DEMO_WEBHOOK_DELIVERIES[0];
    const delivery: WebhookDelivery = {
      ...base,
      id: `wd-${uid()}`,
      status: "delivered",
      response_status: 200,
      attempted_at: new Date().toISOString(),
      next_retry_at: null,
    };
    return delay({ delivery });
  },

  // ─── SSO / Enterprise ──────────────────────────────────────────────────────
  getSsoConfig(_orgId: string) {
    return delay({ sso_config: DEMO_SSO_CONFIG });
  },

  updateSsoConfig(_orgId: string, config: Partial<SsoConfig>) {
    const sso_config: SsoConfig = { ...DEMO_SSO_CONFIG, ...config };
    return delay({ sso_config });
  },

  getAuditLogCsvUrl(_orgId: string): string {
    return "#demo-audit-log.csv";
  },
};

export { demoApi };
