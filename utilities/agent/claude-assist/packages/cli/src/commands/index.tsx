import React, { useState, useEffect } from "react";
import { Box, Text } from "ink";

const API_BASE = "http://localhost:3100/api";

export function IndexCommand() {
  const [status, setStatus] = useState<string>("starting");
  const [result, setResult] = useState<{ indexed: number; errors: number; skipped: number } | null>(null);

  useEffect(() => {
    setStatus("indexing");
    fetch(`${API_BASE}/index/rebuild`, { method: "POST" })
      .then((res) => {
        if (!res.ok) throw new Error(`API error: ${res.status}`);
        return res.json();
      })
      .then(() => {
        const poll = setInterval(async () => {
          try {
            const res = await fetch(`${API_BASE}/index/status`);
            const body = await res.json();
            if (body.data.status === "idle" && body.data.lastIndexed) {
              clearInterval(poll);
              setResult({ indexed: body.data.conversationCount, errors: 0, skipped: 0 });
              setStatus("done");
            }
          } catch {
            // Keep polling
          }
        }, 1000);
        setTimeout(() => clearInterval(poll), 60000);
      })
      .catch((err) => setStatus(`error: ${err.message}`));
  }, []);

  if (status === "indexing") {
    return <Text dimColor>Indexing conversations...</Text>;
  }

  if (status === "done" && result) {
    return (
      <Box flexDirection="column">
        <Text color="green">Indexing complete</Text>
        <Text dimColor>{result.indexed} conversations indexed</Text>
      </Box>
    );
  }

  if (status.startsWith("error")) {
    return <Text color="red">{status}</Text>;
  }

  return <Text dimColor>Preparing...</Text>;
}
