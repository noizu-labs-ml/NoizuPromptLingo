import { useState, useEffect, useCallback } from "react";

const API_BASE = "http://localhost:3100/api";

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
    title: string;
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

export function useConversations(options?: { sort?: string; limit?: number; offset?: number; project?: string }) {
  const params = new URLSearchParams();
  if (options?.sort) params.set("sort", options.sort);
  if (options?.limit) params.set("limit", String(options.limit));
  if (options?.offset) params.set("offset", String(options.offset));
  if (options?.project) params.set("project", options.project);
  const query = params.toString();
  return useApiQuery<ConversationsResponse>(`/conversations${query ? `?${query}` : ""}`);
}

interface SearchResponse {
  data: Array<{
    conversation: {
      id: string;
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

export function useSearch(query: string, mode: "fts" | "semantic" = "fts") {
  const params = new URLSearchParams({ q: query, mode });
  const path = query ? `/search?${params}` : null;
  return useApiQuery<SearchResponse>(path);
}

interface IndexStatusResponse {
  data: {
    status: string;
    lastIndexed: string | null;
    conversationCount: number;
  };
}

export function useIndexStatus() {
  return useApiQuery<IndexStatusResponse>("/index/status");
}
