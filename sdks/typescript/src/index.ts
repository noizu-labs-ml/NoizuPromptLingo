/**
 * CodeFresh TypeScript SDK core (US-093).
 *
 * Quickstart:
 * ```ts
 * import { Client } from "@codefresh/sdk";
 *
 * const client = new Client({ apiUrl: "https://api.codefre.sh", token: "cf_..." });
 * const runs = await client.runs.list(orgId);
 * const run = await client.runs.create(orgId, { scriptId, agentId });
 * ```
 *
 * Webhook verification (US-144):
 * ```ts
 * import { verifyWebhookSignature } from "@codefresh/sdk";
 *
 * const ok = await verifyWebhookSignature(secret, bodyText, sigHeader);
 * ```
 */

// ─────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────

export interface Run {
  id: string;
  organization_id: string;
  script_version_id: string;
  agent_version_id: string;
  status: "pending" | "running" | "passed" | "warned" | "failed" | "cancelled" | "errored";
  trigger_source?: string;
  started_at?: string | null;
  finished_at?: string | null;
  summary_metrics?: Record<string, unknown>;
}

export interface Script {
  id: string;
  organization_id: string;
  slug: string;
  name: string;
  current_version_id?: string | null;
}

export interface Webhook {
  id: string;
  name: string;
  endpoint_url: string;
  event_filters: string[];
  active: boolean;
}

export interface CreateRunOptions {
  scriptId: string;
  agentId: string;
  personaVersionIds?: string[];
  runConfig?: Record<string, unknown>;
}

export interface ClientOptions {
  apiUrl?: string;
  token?: string;
  /** Timeout in milliseconds. Default 30_000. */
  timeoutMs?: number;
  /** Override fetch implementation (test / polyfill hook). */
  fetchImpl?: typeof fetch;
}

// ─────────────────────────────────────────────────────────────────────────
// Errors
// ─────────────────────────────────────────────────────────────────────────

export class CodeFreshError extends Error {
  readonly status?: number;
  readonly body?: unknown;
  constructor(message: string, status?: number, body?: unknown) {
    super(message);
    this.name = "CodeFreshError";
    this.status = status;
    this.body = body;
  }
}
export class AuthError extends CodeFreshError {
  constructor(s?: number, b?: unknown) {
    super("auth failed", s, b);
    this.name = "AuthError";
  }
}
export class NotFoundError extends CodeFreshError {
  constructor(s?: number, b?: unknown) {
    super("not found", s, b);
    this.name = "NotFoundError";
  }
}
export class ValidationError extends CodeFreshError {
  constructor(s?: number, b?: unknown) {
    super("validation failed", s, b);
    this.name = "ValidationError";
  }
}
export class RateLimitedError extends CodeFreshError {
  constructor(s?: number, b?: unknown) {
    super("rate limited", s, b);
    this.name = "RateLimitedError";
  }
}
export class CostCapExceededError extends CodeFreshError {
  constructor(s?: number, b?: unknown) {
    super("cost cap exceeded", s, b);
    this.name = "CostCapExceededError";
  }
}

function raiseForStatus(status: number, body: unknown): never | void {
  if (status < 400) return;
  if (status === 401 || status === 403) throw new AuthError(status, body);
  if (status === 404) throw new NotFoundError(status, body);
  if (status === 422) throw new ValidationError(status, body);
  if (status === 429) throw new RateLimitedError(status, body);
  if (status === 402) throw new CostCapExceededError(status, body);
  throw new CodeFreshError(`http ${status}`, status, body);
}

// ─────────────────────────────────────────────────────────────────────────
// Client
// ─────────────────────────────────────────────────────────────────────────

export class Client {
  private readonly apiUrl: string;
  private readonly token: string;
  private readonly timeoutMs: number;
  private readonly fetchImpl: typeof fetch;

  readonly runs: RunsResource;
  readonly scripts: ScriptsResource;
  readonly webhooks: WebhooksResource;

  constructor(opts: ClientOptions = {}) {
    const token = opts.token ?? process.env.CODEFRESH_API_TOKEN;
    if (!token) {
      throw new AuthError(undefined, {
        error: "no api token (pass token or set CODEFRESH_API_TOKEN)",
      });
    }
    this.apiUrl = (opts.apiUrl ?? "https://api.codefre.sh").replace(/\/$/, "");
    this.token = token;
    this.timeoutMs = opts.timeoutMs ?? 30_000;
    this.fetchImpl = opts.fetchImpl ?? fetch;

    this.runs = new RunsResource(this);
    this.scripts = new ScriptsResource(this);
    this.webhooks = new WebhooksResource(this);
  }

  async request<T>(method: string, path: string, body?: unknown): Promise<T> {
    const ctl = new AbortController();
    const timer = setTimeout(() => ctl.abort(), this.timeoutMs);
    try {
      const resp = await this.fetchImpl(this.apiUrl + path, {
        method,
        headers: {
          authorization: `Bearer ${this.token}`,
          "content-type": "application/json",
          accept: "application/json",
        },
        body: body !== undefined ? JSON.stringify(body) : undefined,
        signal: ctl.signal,
      });
      const text = await resp.text();
      const payload = text ? safeJson(text) : undefined;
      raiseForStatus(resp.status, payload);
      return payload as T;
    } finally {
      clearTimeout(timer);
    }
  }
}

function safeJson(t: string): unknown {
  try {
    return JSON.parse(t);
  } catch {
    return { raw: t };
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Resources
// ─────────────────────────────────────────────────────────────────────────

class RunsResource {
  constructor(private readonly c: Client) {}
  async list(orgId: string): Promise<Run[]> {
    const resp = await this.c.request<{ runs: Run[] }>(
      "GET",
      `/api/v1/organizations/${orgId}/runs`,
    );
    return resp.runs ?? [];
  }
  async get(orgId: string, runId: string): Promise<Run> {
    const resp = await this.c.request<{ run: Run }>(
      "GET",
      `/api/v1/organizations/${orgId}/runs/${runId}`,
    );
    return resp.run;
  }
  async create(orgId: string, opts: CreateRunOptions): Promise<Run> {
    const resp = await this.c.request<{ run: Run }>(
      "POST",
      `/api/v1/organizations/${orgId}/runs`,
      {
        script_id: opts.scriptId,
        agent_id: opts.agentId,
        persona_version_ids: opts.personaVersionIds,
        run_config: opts.runConfig,
      },
    );
    return resp.run;
  }
}

class ScriptsResource {
  constructor(private readonly c: Client) {}
  async list(orgId: string): Promise<Script[]> {
    const resp = await this.c.request<{ scripts: Script[] }>(
      "GET",
      `/api/v1/organizations/${orgId}/scripts`,
    );
    return resp.scripts ?? [];
  }
  async importYaml(orgId: string, yaml: string): Promise<Script> {
    const resp = await this.c.request<{ script: Script }>(
      "POST",
      `/api/v1/organizations/${orgId}/scripts/import`,
      { yaml },
    );
    return resp.script;
  }
}

class WebhooksResource {
  constructor(private readonly c: Client) {}
  async list(orgId: string): Promise<Webhook[]> {
    const resp = await this.c.request<{ webhooks: Webhook[] }>(
      "GET",
      `/api/v1/organizations/${orgId}/webhooks`,
    );
    return resp.webhooks ?? [];
  }
  /** Returns `{ webhook, secret }`. The secret is shown exactly once. */
  async create(
    orgId: string,
    attrs: { name: string; endpoint_url: string; event_filters: string[] },
  ): Promise<{ webhook: Webhook; secret: string }> {
    return this.c.request<{ webhook: Webhook; secret: string }>(
      "POST",
      `/api/v1/organizations/${orgId}/webhooks`,
      { webhook: attrs },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Webhook signature verification (US-144)
// ─────────────────────────────────────────────────────────────────────────

/**
 * Verify the `X-Codefresh-Signature` header using HMAC-SHA256.
 * Uses Web Crypto — works in Node 18+, Bun, Deno, edge runtimes.
 */
export async function verifyWebhookSignature(
  secret: string,
  body: string | Uint8Array,
  signatureHeader: string | null | undefined,
): Promise<boolean> {
  if (!signatureHeader?.startsWith("sha256=")) return false;

  const enc = new TextEncoder();
  const keyBytes = enc.encode(secret);
  const bodyBytes = typeof body === "string" ? enc.encode(body) : body;

  const key = await crypto.subtle.importKey(
    "raw",
    keyBytes,
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const mac = await crypto.subtle.sign("HMAC", key, bodyBytes);
  const hex = Array.from(new Uint8Array(mac))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  const expected = `sha256=${hex}`;

  // Constant-time-ish compare: equal length short-circuits first.
  if (expected.length !== signatureHeader.length) return false;
  let diff = 0;
  for (let i = 0; i < expected.length; i++) {
    diff |= expected.charCodeAt(i) ^ signatureHeader.charCodeAt(i);
  }
  return diff === 0;
}
