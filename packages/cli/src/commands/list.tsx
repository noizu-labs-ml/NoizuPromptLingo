import React, { useState, useEffect } from "react";
import { Box, Text } from "ink";

const API_BASE = "http://localhost:3100/api";

interface ConversationItem {
  id: string;
  title: string;
  projectPath: string;
  messageCount: number;
  updatedAt: string;
}

interface ListCommandProps {
  args: string[];
}

export function ListCommand({ args }: ListCommandProps) {
  const [conversations, setConversations] = useState<ConversationItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const project = getFlagValue(args, "--project");
  const limit = getFlagValue(args, "--limit") ?? "20";

  useEffect(() => {
    const params = new URLSearchParams({ limit, sort: "updated_at" });
    if (project) params.set("project", project);

    fetch(`${API_BASE}/conversations?${params}`)
      .then((res) => {
        if (!res.ok) throw new Error(`API error: ${res.status}`);
        return res.json();
      })
      .then((body) => {
        setConversations(body.data ?? []);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return <Text dimColor>Loading conversations...</Text>;
  }

  if (error) {
    return <Text color="red">Error: {error}</Text>;
  }

  if (conversations.length === 0) {
    return (
      <Box flexDirection="column">
        <Text>No conversations indexed.</Text>
        <Text dimColor>Run `claude-assist index` to scan for conversations.</Text>
      </Box>
    );
  }

  return (
    <Box flexDirection="column">
      <Text bold>{conversations.length} conversations</Text>
      {conversations.map((c) => (
        <Box key={c.id} marginTop={0}>
          <Text>
            <Text dimColor>{c.id.slice(0, 8)}</Text>{" "}
            <Text color="cyan" dimColor>[{shortProject(c.projectPath)}]</Text>{" "}
            <Text>{c.title}</Text>{" "}
            <Text dimColor>({c.messageCount} msgs)</Text>{" "}
            <Text dimColor>{new Date(c.updatedAt).toLocaleDateString()}</Text>
          </Text>
        </Box>
      ))}
    </Box>
  );
}

function getFlagValue(args: string[], flag: string): string | undefined {
  const idx = args.indexOf(flag);
  if (idx === -1 || idx + 1 >= args.length) return undefined;
  return args[idx + 1];
}

function shortProject(path: string): string {
  const parts = path.split("/").filter(Boolean);
  return parts.length > 2 ? parts.slice(-2).join("/") : path;
}
