import React, { useState, useEffect } from "react";
import { Box, Text } from "ink";

const API_BASE = "http://localhost:3100/api";

interface Message {
  conversationId: string;
  role: string;
  content: string;
  timestamp: string;
}

interface ConversationMeta {
  id: string;
  title: string;
  projectPath: string;
  messageCount: number;
  startedAt: string;
  updatedAt: string;
}

interface ShowCommandProps {
  id?: string;
}

export function ShowCommand({ id }: ShowCommandProps) {
  if (!id) {
    return <Text color="red">Usage: claude-assist show &lt;conversation-id&gt;</Text>;
  }

  const [meta, setMeta] = useState<ConversationMeta | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    Promise.all([
      fetch(`${API_BASE}/conversations/${id}`).then((r) => {
        if (!r.ok) throw new Error(r.status === 404 ? "Conversation not found" : `API error: ${r.status}`);
        return r.json();
      }),
      fetch(`${API_BASE}/conversations/${id}/messages`).then((r) => {
        if (!r.ok) throw new Error(`API error: ${r.status}`);
        return r.json();
      }),
    ])
      .then(([convBody, msgBody]) => {
        setMeta(convBody.data);
        setMessages(msgBody.data ?? []);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, [id]);

  if (loading) {
    return <Text dimColor>Loading conversation {id}...</Text>;
  }

  if (error) {
    return <Text color="red">Error: {error}</Text>;
  }

  if (!meta) {
    return <Text color="red">Conversation not found: {id}</Text>;
  }

  return (
    <Box flexDirection="column">
      <Box borderStyle="single" borderColor="cyan" paddingX={1} marginBottom={1}>
        <Box flexDirection="column">
          <Text bold color="cyan">{meta.title}</Text>
          <Text dimColor>
            Project: {meta.projectPath} | Messages: {meta.messageCount} | {meta.startedAt?.slice(0, 10)}
          </Text>
        </Box>
      </Box>

      {messages.map((msg, i) => (
        <Box key={i} flexDirection="column" marginBottom={1}>
          <Text bold color={msg.role === "user" ? "cyan" : "white"}>
            {msg.role === "user" ? "▸ You" : "◂ Assistant"}
            <Text dimColor> {msg.timestamp?.slice(11, 19) ?? ""}</Text>
          </Text>
          <Text wrap="wrap">{truncate(msg.content, 500)}</Text>
        </Box>
      ))}

      <Text dimColor>— end of thread ({messages.length} messages) —</Text>
    </Box>
  );
}

function truncate(text: string, max: number): string {
  if (text.length <= max) return text;
  return text.slice(0, max) + `\n  [...${text.length - max} chars truncated]`;
}
