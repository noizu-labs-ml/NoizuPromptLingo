const API_URL = process.env.NEXT_PUBLIC_API_URL || "";

// ─── Response shapes ──────────────────────────────────────────────────────
interface AuthResponse {
  user: { id: string; email: string };
  organization?: { id: string; slug: string; name: string };
  access_token: string;
  refresh_token: string;
}

export interface Organization {
  id: string;
  slug: string;
  name: string;
  role?: string;
  created_at?: string;
}

export interface Prompt {
  id: string;
  slug: string;
  name: string;
  description: string | null;
  current_version_id: string | null;
  archived_at: string | null;
  created_at: string;
  updated_at: string;
  usage_count?: number;
}

export interface PromptVersion {
  id: string;
  version_number: number;
  body: string;
  template_vars: Record<string, unknown>;
  tool_defs: Record<string, unknown>;
  metadata: Record<string, unknown>;
  checksum: string;
  published_at: string;
}

export interface Rubric {
  id: string;
  slug: string;
  name: string;
  description: string | null;
  current_version_id: string | null;
  archived_at: string | null;
  created_at: string;
}

export type ScaleMethod = "continuous" | "discrete" | "ladder" | "enum";

export interface ScaleLadderRow {
  label: string;
  score: number;
}

export interface ScaleConfig {
  method: ScaleMethod;
  min?: number;
  max?: number;
  type?: string;
  ladder?: ScaleLadderRow[];
}

export interface RubricCriterion {
  name: string;
  weight: number;
  direction: "maximize" | "minimize";
}

export interface RubricVersion {
  id: string;
  version_number: number;
  scale: ScaleConfig;
  criteria: RubricCriterion[];
  judge_model: string | null;
  judge_prompt_version_id: string | null;
  n_samples: number;
  checksum: string;
  published_at: string | null;
}

export interface MarketplaceEntry {
  id: string;
  title: string;
  description: string | null;
  domain: string | null;
  author_organization: string;
  download_count: number;
  sample_score?: number | null;
}

export interface MarketplaceRubricVersion {
  id: string;
  version_number: number;
  scale: ScaleConfig;
  criteria: RubricCriterion[];
  judge_model: string | null;
}

export interface PreviewResult {
  rendered_prompt: string;
  estimated_tokens: number;
  mode: string;
}

export interface Persona {
  id: string;
  slug: string;
  name: string;
  description: string | null;
  current_version_id: string | null;
  archived_at: string | null;
}

export interface PersonaVersion {
  id: string;
  version_number: number;
  tone: string | null;
  description: string | null;
  system_prompt_version_id: string | null;
  checksum: string;
  published_at: string | null;
}

export type ExpectationDirection = "pass" | "fail";
export type ExpectationScoringMethod = "exact" | "contains" | "regex" | "rubric" | "llm";

export interface PersonaExpectation {
  id: string;
  persona_version_id: string;
  script_node_id: string | null;
  label: string;
  weight: number;
  direction: ExpectationDirection;
  scoring_method: ExpectationScoringMethod;
  config: Record<string, unknown>;
  inserted_at: string;
}

export interface Script {
  id: string;
  slug: string;
  name: string;
  description: string | null;
  current_version_id: string | null;
  archived_at: string | null;
}

export interface ScriptVersion {
  id: string;
  version_number: number;
  description: string | null;
  root_node_id: string | null;
  checksum: string;
}

export type ScriptNodeKind =
  | "user_turn"
  | "system"
  | "assistant_turn"
  | "terminal"
  | "freeball_anchor";

export interface ScriptNode {
  id: string;
  script_version_id: string;
  node_key: string;
  kind: ScriptNodeKind | string;
  tone: string | null;
  eval_tags: string[] | null;
  freeball_policy: string | null;
  position: { x?: number; y?: number } | null;
  metadata: Record<string, unknown> | null;
  prompt_version_id: string | null;
}

export type EdgeMatchMethod =
  | "always"
  | "regex"
  | "semantic"
  | "intent"
  | "json_path";

export interface ScriptEdge {
  id: string;
  script_version_id: string;
  from_node_id: string;
  to_node_id: string;
  priority: number | null;
  match_method: EdgeMatchMethod | string;
  match_config: Record<string, unknown> | null;
  label: string | null;
}

export interface ScriptExpectation {
  id: string;
  script_node_id: string;
  label: string;
  weight: number;
  direction: "maximize" | "minimize";
  scoring_method: string;
  config: Record<string, unknown> | null;
  rubric_version_id: string | null;
}

export interface ScriptValidationResult {
  valid: boolean;
  warnings?: string[];
  errors?: string[];
}

// ─── Agents ───────────────────────────────────────────────────────────────────
export type AgentAdapter = "openai" | "anthropic" | "langchain" | "http" | "bedrock" | "vertex";

export interface Agent {
  id: string;
  slug: string;
  name: string;
  adapter: AgentAdapter;
  description: string | null;
  current_version_id: string | null;
  archived_at: string | null;
  created_at: string;
  updated_at: string;
  health_status?: "healthy" | "unhealthy" | "stale" | "unchecked";
  health_checked_at?: string | null;
  health_failure_reason?: string | null;
}

export interface AgentConfig {
  model?: string;
  base_url?: string;
  aws_region?: string;
  project_id?: string;
  max_tokens?: number;
  auth_ref?: Record<string, string>;
  headers?: Record<string, string>;
  request_template?: Record<string, unknown>;
}

export interface AgentVersion {
  id: string;
  version_number: number;
  adapter: AgentAdapter;
  config: AgentConfig;
  checksum: string;
  published_at: string | null;
}

export interface AgentHealthResult {
  status: "healthy" | "unhealthy";
  latency_ms: number | null;
  error: string | null;
  checked_at: string;
}

// ─── Runs ─────────────────────────────────────────────────────────────────────
export type RunStatus = "pending" | "running" | "pass" | "warn" | "fail" | "cancelled" | "error";

/** Per-node / per-step verdict reported during a run. */
export type RunVerdict = "pass" | "warn" | "fail" | "freeball";

export interface Run {
  id: string;
  short_id?: string;
  script_id: string;
  script_name?: string;
  script_version_number?: number;
  script_version_id?: string | null;
  agent_id?: string;
  agent_name?: string;
  agent_version_number?: number;
  persona_id?: string | null;
  persona_name?: string | null;
  status: RunStatus;
  verdict?: RunVerdict | null;
  trigger_source?: string;
  started_at?: string | null;
  finished_at?: string | null;
  inserted_at: string;
  duration_ms?: number | null;
  /** Aggregate score for the run, 0..1. */
  score?: number | null;
}

export type RunStepVoice = "author" | "agent" | "evaluator";

export interface RunStep {
  id: string;
  run_id: string;
  /** Linked script node (may be absent for freeball/improvised steps). */
  script_node_id: string | null;
  /** 1-based ordinal within the run. */
  sequence: number;
  voice: RunStepVoice;
  verdict: RunVerdict | null;
  content: string;
  /** Optional rationale written by the evaluator. */
  rationale?: string | null;
  score?: number | null;
  started_at?: string | null;
  finished_at?: string | null;
  duration_ms?: number | null;
}

export interface RunScore {
  id: string;
  run_id: string;
  run_step_id: string | null;
  expectation_id: string | null;
  label: string;
  value: number;
  verdict: RunVerdict;
  /** Human-readable explanation emitted by the judge. */
  rationale?: string | null;
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = typeof window !== "undefined" ? localStorage.getItem("access_token") : null;

  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.error || body.errors?.email?.[0] || `Request failed: ${res.status}`);
  }

  return res.json();
}

export const api = {
  register(email: string, password: string, inviteToken: string) {
    return request<AuthResponse>("/api/v1/auth/register", {
      method: "POST",
      body: JSON.stringify({ user: { email, password }, invite_token: inviteToken }),
    });
  },

  login(email: string, password: string) {
    return request<AuthResponse>("/api/v1/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
  },

  refresh(refreshToken: string) {
    return request<{ access_token: string }>("/api/v1/auth/refresh", {
      method: "POST",
      body: JSON.stringify({ refresh_token: refreshToken }),
    });
  },

  me() {
    return request<{ user: { id: string; email: string } }>("/api/v1/auth/me");
  },

  // ─── Organizations ─────────────────────────────────────────────────────
  listOrganizations() {
    return request<{ organizations: Organization[] }>("/api/v1/organizations");
  },

  createOrganization(name: string, slug?: string) {
    return request<{ organization: Organization }>("/api/v1/organizations", {
      method: "POST",
      body: JSON.stringify({ organization: { name, ...(slug && { slug }) } }),
    });
  },

  getOrganization(id: string) {
    return request<{ organization: Organization }>(`/api/v1/organizations/${id}`);
  },

  // ─── Prompts (US-009/010/011/048/050/114/115) ─────────────────────────
  listPrompts(orgId: string, q?: string) {
    const qs = q ? `?q=${encodeURIComponent(q)}` : "";
    return request<{ prompts: Prompt[] }>(
      `/api/v1/organizations/${orgId}/prompts${qs}`,
    );
  },

  createPrompt(orgId: string, name: string, description?: string, slug?: string) {
    return request<{ prompt: Prompt }>(`/api/v1/organizations/${orgId}/prompts`, {
      method: "POST",
      body: JSON.stringify({ prompt: { name, description, slug } }),
    });
  },

  getPrompt(orgId: string, id: string) {
    return request<{
      prompt: Prompt;
      current_version: PromptVersion | null;
      versions: Array<Pick<PromptVersion, "id" | "version_number" | "checksum" | "published_at">>;
    }>(`/api/v1/organizations/${orgId}/prompts/${id}`);
  },

  publishPromptVersion(
    orgId: string,
    id: string,
    body: string,
    templateVars: Record<string, unknown> = {},
    toolDefs: Record<string, unknown> = {},
  ) {
    return request<{ version: PromptVersion; status: "published" | "noop" }>(
      `/api/v1/organizations/${orgId}/prompts/${id}/publish`,
      {
        method: "POST",
        body: JSON.stringify({
          version: { body, template_vars: templateVars, tool_defs: toolDefs },
        }),
      },
    );
  },

  sandboxPrompt(
    orgId: string,
    id: string,
    bindings: Record<string, unknown> = {},
    version: "current" | string = "current",
  ) {
    return request<{ rendered: string; tool_names: string[]; mode: string; note: string }>(
      `/api/v1/organizations/${orgId}/prompts/${id}/sandbox`,
      { method: "POST", body: JSON.stringify({ version, bindings }) },
    );
  },

  // ─── Rubrics (US-033/034/056/057/058/119/120) ─────────────────────────
  listRubrics(orgId: string) {
    return request<{ rubrics: Rubric[] }>(`/api/v1/organizations/${orgId}/rubrics`);
  },

  createRubric(orgId: string, name: string, description?: string) {
    return request<{ rubric: Rubric }>(`/api/v1/organizations/${orgId}/rubrics`, {
      method: "POST",
      body: JSON.stringify({ rubric: { name, description } }),
    });
  },

  getRubric(orgId: string, id: string) {
    return request<{
      rubric: Rubric;
      current_version: RubricVersion | null;
      versions: Array<Pick<RubricVersion, "id" | "version_number" | "checksum" | "published_at">>;
    }>(`/api/v1/organizations/${orgId}/rubrics/${id}`);
  },

  publishRubricVersion(
    orgId: string,
    id: string,
    scale: ScaleConfig,
    criteria: RubricCriterion[],
    judgeModel: string | null,
    judgePromptVersionId: string | null,
    nSamples: number,
  ) {
    return request<{ version: RubricVersion; status: "published" | "noop" }>(
      `/api/v1/organizations/${orgId}/rubrics/${id}/publish`,
      {
        method: "POST",
        body: JSON.stringify({
          version: {
            scale,
            criteria,
            judge_model: judgeModel,
            judge_prompt_version_id: judgePromptVersionId,
            n_samples: nSamples,
          },
        }),
      },
    );
  },

  previewRubric(
    orgId: string,
    id: string,
    sampleInput: string,
    sampleResponse: string,
  ) {
    return request<PreviewResult>(
      `/api/v1/organizations/${orgId}/rubrics/${id}/preview`,
      {
        method: "POST",
        body: JSON.stringify({ sample_input: sampleInput, sample_response: sampleResponse }),
      },
    );
  },

  listMarketplaceRubrics(domain?: string) {
    const qs = domain ? `?domain=${encodeURIComponent(domain)}` : "";
    return request<{ entries: Array<{ entry: MarketplaceEntry; rubric_version: MarketplaceRubricVersion }> }>(
      `/api/v1/marketplace/rubrics${qs}`,
    );
  },

  importMarketplaceRubric(orgId: string, marketplaceEntryId: string) {
    return request<{ rubric: Rubric; version: RubricVersion }>(
      `/api/v1/organizations/${orgId}/marketplace/rubrics/${marketplaceEntryId}/import`,
      { method: "POST" },
    );
  },

  // ─── Personas (US-035/036/051/053/055) ─────────────────────────────────
  listPersonas(orgId: string, tone?: string) {
    const qs = tone ? `?tone=${encodeURIComponent(tone)}` : "";
    return request<{ personas: Persona[] }>(
      `/api/v1/organizations/${orgId}/personas${qs}`,
    );
  },

  createPersona(orgId: string, name: string, description?: string) {
    return request<{ persona: Persona }>(`/api/v1/organizations/${orgId}/personas`, {
      method: "POST",
      body: JSON.stringify({ persona: { name, description } }),
    });
  },

  listPersonaStarters() {
    return request<{
      starters: Array<{
        slug: string;
        name: string;
        tone: string;
        description: string;
        sample_preamble: string;
      }>;
    }>("/api/v1/persona-library");
  },

  importPersonaStarter(orgId: string, starterSlug: string) {
    return request<{ persona: Persona; version: unknown }>(
      `/api/v1/organizations/${orgId}/persona-library/${starterSlug}/import`,
      { method: "POST" },
    );
  },

  getPersona(orgId: string, personaId: string) {
    return request<{
      persona: Persona;
      current_version: PersonaVersion | null;
      versions: Array<Pick<PersonaVersion, "id" | "version_number" | "checksum" | "published_at">>;
    }>(`/api/v1/organizations/${orgId}/personas/${personaId}`);
  },

  updatePersona(orgId: string, personaId: string, fields: { tone?: string; description?: string; system_prompt_version_id?: string | null }) {
    return request<{ persona: Persona }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}`,
      { method: "PATCH", body: JSON.stringify({ persona: fields }) },
    );
  },

  publishPersonaVersion(orgId: string, personaId: string) {
    return request<{ version: PersonaVersion; status: "published" | "noop" }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/publish`,
      { method: "POST" },
    );
  },

  listPersonaExpectations(orgId: string, personaId: string, versionId: string) {
    return request<{ expectations: PersonaExpectation[] }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/versions/${versionId}/expectations`,
    );
  },

  createPersonaExpectation(
    orgId: string,
    personaId: string,
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
    return request<{ expectation: PersonaExpectation }>(
      `/api/v1/organizations/${orgId}/personas/${personaId}/versions/${versionId}/expectations`,
      { method: "POST", body: JSON.stringify({ expectation }) },
    );
  },

  // ─── Scripts (US-001-008) ─────────────────────────────────────────────
  listScripts(orgId: string) {
    return request<{ scripts: Script[] }>(`/api/v1/organizations/${orgId}/scripts`);
  },

  createScript(orgId: string, name: string, description?: string) {
    return request<{ script: Script; draft_version: ScriptVersion }>(
      `/api/v1/organizations/${orgId}/scripts`,
      {
        method: "POST",
        body: JSON.stringify({ script: { name, description } }),
      },
    );
  },

  getScript(orgId: string, id: string) {
    return request<{
      script: Script;
      draft_version: ScriptVersion | null;
      nodes: ScriptNode[];
      edges: ScriptEdge[];
    }>(`/api/v1/organizations/${orgId}/scripts/${id}`);
  },

  updateScript(
    orgId: string,
    scriptId: string,
    fields: { name?: string; description?: string },
  ) {
    return request<{ script: Script }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}`,
      { method: "PATCH", body: JSON.stringify({ script: fields }) },
    );
  },

  addScriptNode(
    orgId: string,
    scriptId: string,
    nodeKey: string,
    kind: string,
    extra: Record<string, unknown> = {},
  ) {
    return request<{ node: ScriptNode }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/nodes`,
      {
        method: "POST",
        body: JSON.stringify({ node: { node_key: nodeKey, kind, ...extra } }),
      },
    );
  },

  attachPromptToNode(
    orgId: string,
    scriptId: string,
    nodeId: string,
    promptVersionId: string,
  ) {
    return request<{ node: ScriptNode }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/nodes/${nodeId}/prompt`,
      {
        method: "PATCH",
        body: JSON.stringify({ prompt_version_id: promptVersionId }),
      },
    );
  },

  updateScriptNode(
    orgId: string,
    scriptId: string,
    nodeId: string,
    node: Partial<{
      position: { x: number; y: number };
      kind: string;
      tone: string | null;
      eval_tags: string[];
      freeball_policy: string;
      metadata: Record<string, unknown>;
    }>,
  ) {
    return request<{ node: ScriptNode }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/nodes/${nodeId}`,
      {
        method: "PATCH",
        body: JSON.stringify({ node }),
      },
    );
  },

  listNodeExpectations(orgId: string, scriptId: string, nodeId: string) {
    return request<{ expectations: ScriptExpectation[] }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/nodes/${nodeId}/expectations`,
    );
  },

  addNodeExpectation(
    orgId: string,
    scriptId: string,
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
    return request<{ expectation: ScriptExpectation }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/nodes/${nodeId}/expectations`,
      { method: "POST", body: JSON.stringify({ expectation }) },
    );
  },

  addScriptEdge(
    orgId: string,
    scriptId: string,
    edge: {
      from_node_id: string;
      to_node_id: string;
      match_method: string;
      match_config?: Record<string, unknown>;
      priority?: number;
      label?: string;
    },
  ) {
    return request<{ edge: ScriptEdge }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/edges`,
      { method: "POST", body: JSON.stringify({ edge }) },
    );
  },

  publishScript(orgId: string, scriptId: string) {
    return request<{ version: ScriptVersion; status: "published" | "noop" }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/publish`,
      { method: "POST" },
    );
  },

  importScriptYaml(orgId: string, yaml: string) {
    return request<{ script: Script; version: ScriptVersion; status: string }>(
      `/api/v1/organizations/${orgId}/scripts/import`,
      { method: "POST", body: JSON.stringify({ yaml }) },
    );
  },

  forkScript(orgId: string, scriptId: string) {
    return request<{ script: Script; draft_version: ScriptVersion }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/fork`,
      { method: "POST" },
    );
  },

  autoLayoutScript(orgId: string, scriptId: string) {
    return request<{ nodes: ScriptNode[] }>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/auto-layout`,
      { method: "POST" },
    );
  },

  validateScript(orgId: string, scriptId: string) {
    return request<ScriptValidationResult>(
      `/api/v1/organizations/${orgId}/scripts/${scriptId}/validate`,
    );
  },

  exportScriptYamlUrl(orgId: string, scriptId: string): string {
    return `${API_URL}/api/v1/organizations/${orgId}/scripts/${scriptId}/export`;
  },

  async exportScriptYaml(orgId: string, scriptId: string): Promise<string> {
    const token =
      typeof window !== "undefined" ? localStorage.getItem("access_token") : null;
    const res = await fetch(
      `${API_URL}/api/v1/organizations/${orgId}/scripts/${scriptId}/export`,
      { headers: token ? { Authorization: `Bearer ${token}` } : {} },
    );
    if (!res.ok) {
      const body = await res.json().catch(() => ({}));
      throw new Error(body.error || `Export failed: ${res.status}`);
    }
    return res.text();
  },

  // ─── Agents (US-012-014, US-061-065) ──────────────────────────────────────
  listAgents(orgId: string) {
    return request<{ agents: Agent[] }>(`/api/v1/organizations/${orgId}/agents`);
  },

  createAgent(
    orgId: string,
    name: string,
    adapter: AgentAdapter,
    config: AgentConfig,
    description?: string,
    slug?: string,
  ) {
    return request<{ agent: Agent; draft_version: AgentVersion }>(
      `/api/v1/organizations/${orgId}/agents`,
      {
        method: "POST",
        body: JSON.stringify({ agent: { name, adapter, config, description, slug } }),
      },
    );
  },

  getAgent(orgId: string, agentId: string) {
    return request<{ agent: Agent; current_version: AgentVersion | null }>(
      `/api/v1/organizations/${orgId}/agents/${agentId}`,
    );
  },

  updateAgentConfig(orgId: string, agentId: string, config: AgentConfig) {
    return request<{ agent: Agent }>(
      `/api/v1/organizations/${orgId}/agents/${agentId}`,
      { method: "PATCH", body: JSON.stringify({ agent: { config } }) },
    );
  },

  publishAgentVersion(orgId: string, agentId: string) {
    return request<{ version: AgentVersion; status: "published" | "noop" }>(
      `/api/v1/organizations/${orgId}/agents/${agentId}/publish`,
      { method: "POST" },
    );
  },

  checkAgentHealth(orgId: string, agentId: string) {
    return request<AgentHealthResult>(
      `/api/v1/organizations/${orgId}/agents/${agentId}/health`,
    );
  },

  // ─── Runs (US-025-028) ────────────────────────────────────────────────────
  listRuns(
    orgId: string,
    filters?: { script_id?: string; persona_id?: string; status?: RunStatus; date_from?: string; date_to?: string; page?: number },
  ) {
    const params = new URLSearchParams();
    if (filters?.script_id) params.set("script_id", filters.script_id);
    if (filters?.persona_id) params.set("persona_id", filters.persona_id);
    if (filters?.status) params.set("status", filters.status);
    if (filters?.date_from) params.set("date_from", filters.date_from);
    if (filters?.date_to) params.set("date_to", filters.date_to);
    if (filters?.page) params.set("page", String(filters.page));
    const qs = params.toString() ? `?${params.toString()}` : "";
    return request<{ runs: Run[]; total: number; page: number }>(
      `/api/v1/organizations/${orgId}/runs${qs}`,
    );
  },

  triggerRun(
    orgId: string,
    scriptId: string,
    agentId: string,
    personaId?: string,
    config?: Record<string, unknown>,
  ) {
    return request<{ run: Run }>(
      `/api/v1/organizations/${orgId}/runs`,
      {
        method: "POST",
        body: JSON.stringify({
          run: { script_id: scriptId, agent_id: agentId, persona_id: personaId, config },
        }),
      },
    );
  },

  /**
   * Run detail. Returns the run record plus the script graph snapshot at the
   * version the run executed against (nodes + edges), so the forge view can
   * recolor the live graph without another round trip.
   */
  getRun(orgId: string, runId: string) {
    return request<{
      run: Run;
      nodes?: ScriptNode[];
      edges?: ScriptEdge[];
    }>(`/api/v1/organizations/${orgId}/runs/${runId}`);
  },

  listRunSteps(orgId: string, runId: string) {
    return request<{ steps: RunStep[] }>(
      `/api/v1/organizations/${orgId}/runs/${runId}/steps`,
    );
  },

  listRunScores(orgId: string, runId: string) {
    return request<{ scores: RunScore[] }>(
      `/api/v1/organizations/${orgId}/runs/${runId}/scores`,
    );
  },

  cancelRun(orgId: string, runId: string) {
    return request<{ run: Run }>(
      `/api/v1/organizations/${orgId}/runs/${runId}/cancel`,
      { method: "POST" },
    );
  },

  retryRun(orgId: string, runId: string) {
    return request<{ run: Run }>(
      `/api/v1/organizations/${orgId}/runs/${runId}/retry`,
      { method: "POST" },
    );
  },

  // ─── Review queue (Stage 8) ───────────────────────────────────────────────
  listReviewQueue(
    orgId: string,
    filters?: { status?: ReviewStatus; assignee?: string; page?: number },
  ) {
    const params = new URLSearchParams();
    if (filters?.status) params.set("status", filters.status);
    if (filters?.assignee) params.set("assignee", filters.assignee);
    if (filters?.page) params.set("page", String(filters.page));
    const qs = params.toString() ? `?${params.toString()}` : "";
    return request<{ items: ReviewItem[]; total: number }>(
      `/api/v1/organizations/${orgId}/review${qs}`,
    );
  },

  reviewAction(
    orgId: string,
    itemId: string,
    action: "claim" | "approve" | "reject" | "dismiss",
    payload?: Record<string, unknown>,
  ) {
    return request<{ item: ReviewItem }>(
      `/api/v1/organizations/${orgId}/review/${itemId}/${action}`,
      { method: "POST", body: JSON.stringify(payload ?? {}) },
    );
  },

  reviewAssign(orgId: string, itemId: string, assigneeId: string) {
    return request<{ item: ReviewItem }>(
      `/api/v1/organizations/${orgId}/review/${itemId}/assign`,
      { method: "POST", body: JSON.stringify({ assignee_id: assigneeId }) },
    );
  },

  reviewBulk(orgId: string, ids: string[], action: "claim" | "approve") {
    return request<{ updated: number }>(
      `/api/v1/organizations/${orgId}/review/bulk`,
      { method: "POST", body: JSON.stringify({ ids, action }) },
    );
  },

  // ─── Datasets (Stage 9) ───────────────────────────────────────────────────
  listDatasets(orgId: string) {
    return request<{ datasets: Dataset[] }>(`/api/v1/organizations/${orgId}/datasets`);
  },

  createDataset(orgId: string, name: string, description?: string) {
    return request<{ dataset: Dataset }>(`/api/v1/organizations/${orgId}/datasets`, {
      method: "POST",
      body: JSON.stringify({ dataset: { name, description } }),
    });
  },

  publishDatasetVersion(orgId: string, datasetId: string) {
    return request<{ version: unknown; status: string }>(
      `/api/v1/organizations/${orgId}/datasets/${datasetId}/publish`,
      { method: "POST" },
    );
  },

  listCaptures(
    orgId: string,
    filters?: { status?: CaptureStatus; page?: number },
  ) {
    const params = new URLSearchParams();
    if (filters?.status) params.set("status", filters.status);
    if (filters?.page) params.set("page", String(filters.page));
    const qs = params.toString() ? `?${params.toString()}` : "";
    return request<{ captures: Capture[] }>(`/api/v1/organizations/${orgId}/captures${qs}`);
  },

  promoteCapture(orgId: string, captureId: string, datasetId: string) {
    return request<{ capture: Capture }>(
      `/api/v1/organizations/${orgId}/captures/${captureId}/promote`,
      { method: "POST", body: JSON.stringify({ dataset_id: datasetId }) },
    );
  },

  // ─── OTel (Stage 10) ──────────────────────────────────────────────────────
  searchOtelSpans(
    orgId: string,
    query: { run_id?: string; attributes?: Record<string, unknown>; page?: number },
  ) {
    return request<{ spans: OtelSpan[]; total: number }>(
      `/api/v1/organizations/${orgId}/otel/spans`,
      { method: "POST", body: JSON.stringify(query) },
    );
  },

  searchOtelLogs(
    orgId: string,
    query: { run_id?: string; attributes?: Record<string, unknown>; page?: number },
  ) {
    return request<{ logs: OtelLog[]; total: number }>(
      `/api/v1/organizations/${orgId}/otel/logs`,
      { method: "POST", body: JSON.stringify(query) },
    );
  },

  listOtelSamplingPolicies(orgId: string) {
    return request<{ policies: OtelSamplingPolicy[] }>(
      `/api/v1/organizations/${orgId}/otel/sampling-policies`,
    );
  },

  // ─── Webhooks (Stage 11) ──────────────────────────────────────────────────
  listWebhooks(orgId: string) {
    return request<{ webhooks: Webhook[] }>(`/api/v1/organizations/${orgId}/webhooks`);
  },

  createWebhook(orgId: string, payload: WebhookPayload) {
    return request<{ webhook: Webhook }>(`/api/v1/organizations/${orgId}/webhooks`, {
      method: "POST",
      body: JSON.stringify({ webhook: payload }),
    });
  },

  updateWebhook(orgId: string, webhookId: string, payload: Partial<WebhookPayload>) {
    return request<{ webhook: Webhook }>(
      `/api/v1/organizations/${orgId}/webhooks/${webhookId}`,
      { method: "PATCH", body: JSON.stringify({ webhook: payload }) },
    );
  },

  deleteWebhook(orgId: string, webhookId: string) {
    return request<{ ok: boolean }>(
      `/api/v1/organizations/${orgId}/webhooks/${webhookId}`,
      { method: "DELETE" },
    );
  },

  listWebhookDeliveries(orgId: string, webhookId: string) {
    return request<{ deliveries: WebhookDelivery[] }>(
      `/api/v1/organizations/${orgId}/webhooks/${webhookId}/deliveries`,
    );
  },

  retryWebhookDelivery(orgId: string, webhookId: string, deliveryId: string) {
    return request<{ delivery: WebhookDelivery }>(
      `/api/v1/organizations/${orgId}/webhooks/${webhookId}/deliveries/${deliveryId}/retry`,
      { method: "POST" },
    );
  },

  // ─── SSO / Enterprise settings (Stage 12) ─────────────────────────────────
  getSsoConfig(orgId: string) {
    return request<{ sso_config: SsoConfig | null }>(
      `/api/v1/organizations/${orgId}/sso-config`,
    );
  },

  updateSsoConfig(orgId: string, config: Partial<SsoConfig>) {
    return request<{ sso_config: SsoConfig }>(
      `/api/v1/organizations/${orgId}/sso-config`,
      { method: "PUT", body: JSON.stringify({ sso_config: config }) },
    );
  },

  getAuditLogCsvUrl(orgId: string): string {
    return `${API_URL}/api/v1/organizations/${orgId}/audit-log.csv`;
  },
};

// Demo mode override — synchronously replaces api methods with mock data.
// NEXT_PUBLIC_* vars are inlined at build time; dead code is tree-shaken in prod.
if (process.env.NEXT_PUBLIC_DEMO_MODE === 'true') {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { demoApi } = require('./demo-api');
  Object.assign(api, demoApi);
}

// ─── Stage 8–12 shapes ────────────────────────────────────────────────────────
export type ReviewStatus = "pending" | "claimed" | "resolved";

export interface ReviewItem {
  id: string;
  run_id: string;
  status: ReviewStatus;
  assignee_id: string | null;
  assignee_email: string | null;
  notes: string | null;
  inserted_at: string;
  updated_at: string;
}

export interface Dataset {
  id: string;
  name: string;
  description: string | null;
  current_version_id: string | null;
  inserted_at: string;
}

export type CaptureStatus = "pending" | "reviewed" | "promoted";

export interface Capture {
  id: string;
  run_id: string;
  status: CaptureStatus;
  dataset_id: string | null;
  inserted_at: string;
}

export interface OtelSpan {
  span_id: string;
  trace_id: string;
  parent_span_id: string | null;
  run_id: string | null;
  name: string;
  start_time_unix_nano: string;
  end_time_unix_nano: string;
  duration_ns: number;
  status_code: string;
  attributes: Record<string, unknown>;
}

export interface OtelLog {
  id: string;
  trace_id: string | null;
  span_id: string | null;
  run_id: string | null;
  severity_text: string;
  body: string | null;
  attributes: Record<string, unknown>;
  timestamp: string;
}

export interface OtelSamplingPolicy {
  id: string;
  name: string;
  sample_rate: number;
  enabled: boolean;
}

export const WEBHOOK_EVENTS = [
  "run.completed",
  "run.failed",
  "review.approved",
  "review.rejected",
  "dataset.published",
] as const;
export type WebhookEvent = (typeof WEBHOOK_EVENTS)[number];

export interface WebhookPayload {
  url: string;
  events: WebhookEvent[];
  enabled: boolean;
}

export interface Webhook extends WebhookPayload {
  id: string;
  inserted_at: string;
}

export interface WebhookDelivery {
  id: string;
  webhook_id: string;
  event: string;
  status: "delivered" | "failed" | "dead";
  response_status: number | null;
  attempted_at: string;
  next_retry_at: string | null;
}

export interface SsoConfig {
  idp_metadata_url: string;
  entity_id: string;
  certificate: string;
}
