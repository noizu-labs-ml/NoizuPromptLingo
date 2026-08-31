import { useState, useEffect, useCallback } from "react";

const API_BASE = "http://localhost:3100/api";

// ⟦𓊞𓀚𓇚𓍑⟧ apiFetch :: auto-generated pointer for public function apiFetch
export async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    headers: { "Content-Type": "application/json", ...options?.headers },
    ...options,
  });
  if (!response.ok) {
    throw new Error(`API error: ${response.status} ${response.statusText}`);
  }
  return response.json();
}

interface UseApiState<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
  refetch: () => void;
}

// ⟦𓆓𓏤𓀾𓁛⟧ useApiQuery :: auto-generated pointer for public function useApiQuery
export function useApiQuery<T>(path: string | null): UseApiState<T> {
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

// ⟦𓉑𓅒𓆆𓏊⟧ useApiMutation :: auto-generated pointer for public function useApiMutation
export function useApiMutation<TBody, TResponse>(
  method: "POST" | "PATCH" | "DELETE" = "POST"
) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const mutate = useCallback(async (path: string, body?: TBody): Promise<TResponse | null> => {
    setLoading(true);
    setError(null);
    try {
      const result = await apiFetch<TResponse>(path, {
        method,
        body: body ? JSON.stringify(body) : undefined,
      });
      setLoading(false);
      return result;
    } catch (err: any) {
      setError(err.message);
      setLoading(false);
      return null;
    }
  }, [method]);

  return { mutate, loading, error };
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

// ⟦𓀚𓃢𓉏𓁶⟧ useConversations :: auto-generated pointer for public function useConversations
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

// ⟦𓍾𓎒𓉎𓎹⟧ useSearch :: auto-generated pointer for public function useSearch
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

// ⟦𓀶𓉐𓁁𓋲⟧ useIndexStatus :: auto-generated pointer for public function useIndexStatus
export function useIndexStatus() {
  return useApiQuery<IndexStatusResponse>("/index/status");
}
