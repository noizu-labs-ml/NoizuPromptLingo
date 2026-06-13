import React, { useState } from "react";
import { Box, Text, useInput } from "ink";
import { Spinner } from "@inkjs/ui";
import { useRouter } from "../context/RouterContext.js";
import { useApiQuery, apiFetch } from "../hooks/useApi.js";
import { useScroll } from "../hooks/useScroll.js";
import { useTerminalSize } from "../hooks/useTerminalSize.js";
import { SelectableList } from "../components/SelectableList.js";
import { ConfirmDialog } from "../components/ConfirmDialog.js";

interface Dataset {
  name: string;
  description: string;
  version: number;
  entryCount: number;
}

interface DatasetEntry {
  id: string;
  conversationId: string;
  quality: "gold" | "silver" | "bronze";
  messages: Array<{ role: string; content: string }>;
  createdAt: string;
}

const QUALITY_COLORS: Record<string, string> = {
  gold: "yellow",
  silver: "white",
  bronze: "red",
};

export function DatasetDetailPage() {
  const { current, goBack } = useRouter();
  const name = current.params.name;
  const { rows } = useTerminalSize();

  const { data: dsData, loading } = useApiQuery<{ data: Dataset }>(`/datasets/${name}`);
  const { data: entryData, refetch } = useApiQuery<{ data: DatasetEntry[] }>(`/datasets/${name}/entries`);

  const dataset = dsData?.data;
  const entries = entryData?.data ?? [];

  const [confirmDelete, setConfirmDelete] = useState(false);
  const [actionMsg, setActionMsg] = useState("");

  const contentHeight = Math.max(5, rows - 10);
  const scroll = useScroll({
    totalItems: entries.length,
    viewportHeight: contentHeight,
    isActive: !confirmDelete,
  });

  useInput((input, key) => {
    if (confirmDelete) return;
    if (key.escape) goBack();
    else if (input === "d") setConfirmDelete(true);
    else if (input === "1" || input === "2" || input === "3") {
      const format = input === "1" ? "openai" : input === "2" ? "anthropic" : "jsonl";
      handleExport(format);
    }
  }, { isActive: true });

  const handleExport = async (format: string) => {
    try {
      const res = await fetch(`http://localhost:3100/api/datasets/${name}/export?format=${format}`);
      const text = await res.text();
      const filename = `${name}.${format}.jsonl`;
      const { writeFileSync } = await import("fs");
      writeFileSync(filename, text);
      setActionMsg(`Exported to ${filename}`);
      setTimeout(() => setActionMsg(""), 3000);
    } catch {
      setActionMsg("Export failed");
      setTimeout(() => setActionMsg(""), 2000);
    }
  };

  const handleDelete = async () => {
    const entry = entries[scroll.cursor];
    if (!entry) return;
    await apiFetch(`/datasets/${name}/entries/${entry.id}`, { method: "DELETE" });
    setConfirmDelete(false);
    setActionMsg("Entry deleted");
    setTimeout(() => setActionMsg(""), 2000);
    refetch();
  };

  if (loading) return <Spinner label="Loading dataset..." />;
  if (!dataset) return <Text color="red">Dataset not found: {name}</Text>;

  return (
    <Box flexDirection="column">
      <Box flexDirection="column" borderStyle="single" borderColor="cyan" paddingX={1} marginBottom={1}>
        <Text bold color="cyan">{dataset.name}</Text>
        <Text dimColor>{dataset.description}</Text>
        <Text dimColor>v{dataset.version} | {dataset.entryCount} entries</Text>
      </Box>

      <Text dimColor>1:OpenAI 2:Anthropic 3:JSONL d:delete Esc:back</Text>
      {actionMsg && <Text color="green">{actionMsg}</Text>}

      {confirmDelete && (
        <ConfirmDialog
          message="Delete this entry?"
          onConfirm={handleDelete}
          onCancel={() => setConfirmDelete(false)}
        />
      )}

      <Box flexDirection="column" marginTop={1}>
        <SelectableList
          items={entries}
          cursor={scroll.cursor}
          visibleRange={scroll.visibleRange}
          emptyMessage="No entries in this dataset."
          renderItem={(entry, _i, isCursor) => (
            <Box flexDirection="column">
              <Text inverse={isCursor}>
                {isCursor ? "▸ " : "  "}
                <Text color={QUALITY_COLORS[entry.quality] as any} bold>
                  [{entry.quality}]
                </Text>
                {" "}
                <Text dimColor>{entry.conversationId.slice(0, 8)}</Text>
                {" "}
                <Text>{entry.messages.length} messages</Text>
              </Text>
              {isCursor && entry.messages.slice(0, 2).map((m, mi) => (
                <Text key={mi} dimColor wrap="truncate-end">
                  {"    "}{m.role}: {m.content.slice(0, 60)}
                </Text>
              ))}
            </Box>
          )}
        />
      </Box>
    </Box>
  );
}
