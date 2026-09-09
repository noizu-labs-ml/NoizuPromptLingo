// Same-origin convention (see ../api.ts) — inlined so this module stays
// fork-portable (agent-kit's split api/transport layout doesn't exist here).
const API_URL =
  typeof window !== "undefined" ? "" : process.env.NEXT_PUBLIC_API_URL || "";

// ── Web NPL Prompt Builder (public /keyboard page) ──
// Uses raw fetch (not transport.request) because the build endpoint's error
// contract is status-coded (422 purpose-lock, 429 rate/budget with Retry-After)
// and the page needs those statuses + headers.

export interface PromptBuilderBuildResult {
  prompt: string;
  tokens_in: number;
  tokens_out: number;
  est_cost_usd: string;
}

export interface PromptBuilderStatus {
  enabled: boolean;
  requests_per_minute: number;
  daily_cost_cap_usd: string;
  daily_cost_remaining_usd: string;
  resets_at: string;
}

export class PromptBuilderError extends Error {
  status: number;
  retryAfter: number | null;

  constructor(status: number, message: string, retryAfter: number | null = null) {
    super(message);
    this.status = status;
    this.retryAfter = retryAfter;
  }
}

// Opaque per-browser session id — hashed server-side with the client IP into
// the rate-limit/budget key. Never a credential; persists in localStorage.
export function promptBuilderSessionId(): string {
  if (typeof window === "undefined") return "";
  const KEY = "npl_kb_session_id";
  try {
    let id = window.localStorage.getItem(KEY);
    if (!id) {
      id = crypto.randomUUID();
      window.localStorage.setItem(KEY, id);
    }
    return id;
  } catch {
    return "ephemeral";
  }
}

// Attach the auth bearer when present so logged-in users can later be given a
// distinct tier; the endpoint currently keys on IP+session regardless.
function authHeaders(): HeadersInit {
  const headers: Record<string, string> = { "Content-Type": "application/json" };
  if (typeof window !== "undefined") {
    const token = window.localStorage.getItem("access_token");
    if (token) headers.Authorization = `Bearer ${token}`;
  }
  return headers;
}

export async function buildPrompt(description: string, context?: string): Promise<PromptBuilderBuildResult> {
  let res: Response;
  try {
    res = await fetch(`${API_URL}/api/prompt-builder/build`, {
      method: "POST",
      headers: authHeaders(),
      body: JSON.stringify({
        description,
        context: context || undefined,
        session_id: promptBuilderSessionId(),
      }),
    });
  } catch {
    throw new PromptBuilderError(0, "Network error — the prompt compiler is unreachable.");
  }

  const body = await res.json().catch(() => ({}));

  if (res.status === 429) {
    const retryAfter = Number(res.headers.get("retry-after")) || null;
    throw new PromptBuilderError(429, body.error || "Rate limit reached.", retryAfter);
  }

  if (!res.ok) {
    throw new PromptBuilderError(res.status, body.error || "Build failed.");
  }

  return body as PromptBuilderBuildResult;
}

export async function getPromptBuilderStatus(): Promise<PromptBuilderStatus> {
  const session = promptBuilderSessionId();
  const res = await fetch(
    `${API_URL}/api/prompt-builder/status${session ? `?session_id=${encodeURIComponent(session)}` : ""}`,
  );
  if (!res.ok) throw new PromptBuilderError(res.status, "Status unavailable.");
  return res.json();
}

// ── Static catalog (graceful degradation: browsing needs no API quota) ──

export interface CatalogEntry {
  id: string;
  char: string;
  text?: string;
  template?: string;
  name: string;
  tags?: string[];
  category: string;
  subcategory?: string;
  description?: string;
  example?: string;
  npl?: boolean;
}

export interface CategoryDef {
  id?: string;
  name?: string;
  icon?: string;
  description?: string;
  [key: string]: unknown;
}

export async function fetchCatalog(): Promise<CatalogEntry[]> {
  const res = await fetch("/npl-keyboard/catalog.json");
  if (!res.ok) throw new Error("catalog unavailable");
  const data = await res.json();
  return data.entries as CatalogEntry[];
}

export async function fetchCategories(): Promise<CategoryDef[]> {
  const res = await fetch("/npl-keyboard/category-registry.json");
  if (!res.ok) return [];
  const data = await res.json();
  const raw = Array.isArray(data) ? data : (data.categories ?? []);
  return Array.isArray(raw) ? raw : Object.values(raw);
}

export async function fetchUnicodeDb(): Promise<CatalogEntry[]> {
  // 7.8MB — fetched lazily, only when the symbol picker opens.
  const res = await fetch("/npl-keyboard/unicode-db.json");
  if (!res.ok) return [];
  const data = await res.json();
  return (data.entries ?? []) as CatalogEntry[];
}

// ── Showcase gallery (public OP-vs-NPL entries) ──

export interface ShowcaseContextSizes {
  original: { chars: number | null; tokens: number | null };
  npl: { chars: number | null; tokens: number | null };
}

export interface ShowcaseEntry {
  id: string;
  original_prompt: string;
  original_output: string | null;
  npl_prompt: string | null;
  npl_output: string | null;
  score_original: number | null;
  score_npl: number | null;
  winner: "original" | "npl" | "tie" | null;
  context_sizes: ShowcaseContextSizes;
  rubric: Record<string, Record<string, number>> | null;
  difference_analysis: string | null;
  inserted_at: string;
}

export interface ShowcaseResponse {
  entries: ShowcaseEntry[];
  notice: string;
}

export async function fetchShowcase(limit = 50): Promise<ShowcaseResponse> {
  const res = await fetch(`${API_URL}/api/prompt-builder/showcase?limit=${limit}`);
  if (!res.ok) throw new PromptBuilderError(res.status, "Showcase unavailable.");
  return res.json();
}
