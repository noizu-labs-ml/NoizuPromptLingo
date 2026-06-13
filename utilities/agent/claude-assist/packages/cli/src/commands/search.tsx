import React, { useState, useEffect } from "react";
import { Box, Text } from "ink";

const API_BASE = "http://localhost:3100/api";

interface SearchResult {
  conversation: {
    id: string;
    title: string;
    projectPath: string;
    updatedAt: string;
  };
  snippet: string;
  relevance: number;
}

interface SearchCommandProps {
  query: string;
  semantic?: boolean;
  project?: string;
}

export function SearchCommand({ query, semantic, project }: SearchCommandProps) {
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const params = new URLSearchParams({ q: query });
    if (semantic) params.set("mode", "semantic");
    if (project) params.set("project", project);

    fetch(`${API_BASE}/search?${params}`)
      .then((res) => {
        if (!res.ok) throw new Error(`API error: ${res.status}`);
        return res.json();
      })
      .then((body) => {
        setResults(body.data ?? []);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, [query]);

  if (loading) {
    return <Text dimColor>Searching for "{query}"...</Text>;
  }

  if (error) {
    return <Text color="red">Error: {error}</Text>;
  }

  if (results.length === 0) {
    return (
      <Box flexDirection="column">
        <Text>No results for "<Text color="cyan">{query}</Text>"</Text>
        <Text dimColor>Try a different query or run `claude-assist index` to rebuild the index.</Text>
      </Box>
    );
  }

  return (
    <Box flexDirection="column">
      <Text bold>{results.length} results for "<Text color="cyan">{query}</Text>"</Text>
      {results.map((r, i) => (
        <Box key={i} flexDirection="column" marginTop={1}>
          <Text>
            <Text dimColor>{r.conversation.id.slice(0, 8)}</Text>{" "}
            <Text color="cyan" dimColor>[{shortProject(r.conversation.projectPath)}]</Text>{" "}
            <Text bold>{r.conversation.title}</Text>{" "}
            <Text dimColor>{new Date(r.conversation.updatedAt).toLocaleDateString()}</Text>
          </Text>
          <Text dimColor>  {cleanSnippet(r.snippet)}</Text>
        </Box>
      ))}
    </Box>
  );
}

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}

function cleanSnippet(snippet: string): string {
  return snippet.replace(/<<</g, "").replace(/>>>/g, "");
}
