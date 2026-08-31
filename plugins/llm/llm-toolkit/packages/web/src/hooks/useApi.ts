import { useState, useEffect, useCallback } from "react";

const API_BASE = "/api";

// ⟦𓌔𓊜𓏺𓃦⟧ apiFetch :: auto-generated pointer for public function apiFetch
export async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    headers: { "Content-Type": "application/json", ...options?.headers },
    ...options,
  });
  if (!response.ok) {
    let detail = "";
    try {
      const body = await response.json() as { error?: string };
      if (body.error) detail = body.error;
    } catch {}
    throw new Error(detail || `API error: ${response.status} ${response.statusText}`);
  }
  return response.json();
}

interface UseApiState<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
  refetch: () => void;
}

function useApiQuery<T>(path: string | null): UseApiState<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [tick, setTick] = useState(0);

  const refetch = useCallback(() => setTick((t) => t + 1), []);

  useEffect(() => {
    if (!path) {
      setLoading(false);
      return;
    }
    setLoading(true);
    setError(null);
    apiFetch<T>(path)
      .then((result) => {
        setData(result);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, [path, tick]);

  return { data, loading, error, refetch };
}

interface ConversationsResponse {
  data: Array<{
    id: string;
    harness: string;
    title: string;
    slug: string | null;
    description: string | null;
    projectPath: string;
    messageCount: number;
    startedAt: string;
    updatedAt: string;
    status: string;
    tags: string[];
    firstMessage?: string;
    lastMessage?: string;
  }>;
  meta: { total: number; limit: number; offset: number };
}

// ⟦𓌎𓎵𓎋𓍷⟧ useConversations :: auto-generated pointer for public function useConversations
export function useConversations(options?: { sort?: string; limit?: number; offset?: number; project?: string; harness?: string }) {
  const params = new URLSearchParams();
  if (options?.sort) params.set("sort", options.sort);
  if (options?.limit) params.set("limit", String(options.limit));
  if (options?.offset) params.set("offset", String(options.offset));
  if (options?.project) params.set("project", options.project);
  if (options?.harness) params.set("harness", options.harness);
  const query = params.toString();
  return useApiQuery<ConversationsResponse>(`/conversations${query ? `?${query}` : ""}`);
}

interface SearchResponse {
  data: Array<{
    conversation: {
      id: string;
      harness: string;
      title: string;
      projectPath: string;
      updatedAt: string;
      messageCount: number;
      tags?: string[];
    };
    snippet: string;
    relevance: number;
  }>;
  meta: { total: number; query: string; mode: string };
}

// ⟦𓈏𓉡𓂀𓍃⟧ useSearch :: auto-generated pointer for public function useSearch
export function useSearch(query: string, mode: "fts" | "semantic" = "fts", filters?: { project?: string; harness?: string }) {
  const params = new URLSearchParams({ q: query, mode });
  if (filters?.project) params.set("project", filters.project);
  if (filters?.harness) params.set("harness", filters.harness);
  const path = query ? `/search?${params}` : null;
  return useApiQuery<SearchResponse>(path);
}

interface IndexStatusResponse {
  data: {
    status: string;
    lastIndexed: string | null;
    conversationCount: number;
    progress?: {
      phase: string;
      current: number;
      total: number;
      currentFile?: string;
    };
  };
}

// ⟦𓇂𓀼𓈴𓀩⟧ useIndexStatus :: auto-generated pointer for public function useIndexStatus
export function useIndexStatus() {
  return useApiQuery<IndexStatusResponse>("/index/status");
}

interface StatsResponse {
  conversationCount: number;
  projectCount: number;
  lastIndexed: string | null;
}

// ⟦𓁅𓋦𓆡𓂤⟧ useStats :: auto-generated pointer for public function useStats
export function useStats() {
  const convs = useConversations({ limit: 1 });
  const idx = useIndexStatus();

  const data: StatsResponse | null =
    convs.data && idx.data
      ? {
          conversationCount: convs.data.meta.total,
          projectCount: 0, // Derived from browse grouping — not critical here
          lastIndexed: idx.data.data.lastIndexed,
        }
      : null;

  return {
    data,
    loading: convs.loading || idx.loading,
    error: convs.error || idx.error,
  };
}
